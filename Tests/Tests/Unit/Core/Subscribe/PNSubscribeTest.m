#import "PNRecordableTestCase.h"
#import <OCMock/OCMock.h>
#import <PubNub/PubNub+CorePrivate.h>
#import "PNSubscribeMessageEventData+Private.h"
#import "PNSubscribeEventData+Private.h"
#import "PNSubscribeStatus+Private.h"
#import "PNTransportConfiguration+Private.h"
#import "PNTransportRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNURLSessionTransport.h"


#pragma mark - Subscribe retry test protocol

static NSInteger _PNSubscribeRetryProtocolRequestCount = 0;

/// URL protocol that returns HTTP 500 on the first subscribe request and HTTP 200 on the retry.
@interface PNSubscribeRetryTestProtocol : NSURLProtocol
@end

@implementation PNSubscribeRetryTestProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [request.URL.path containsString:@"/v2/subscribe/"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    _PNSubscribeRetryProtocolRequestCount++;

    if (_PNSubscribeRetryProtocolRequestCount == 1) {
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                  statusCode:500
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        NSData *data = [@"{\"t\":{\"t\":\"17000000000000000\",\"r\":2},\"m\":[]}"
                        dataUsingEncoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                  statusCode:200
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:@{@"Content-Type": @"application/json"}];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)stopLoading {}

@end


#pragma mark - Private subscriber methods exposure

@interface PNSubscriber (TestAccess)

/// Generation counter for subscribe cycle.
@property (assign, nonatomic) NSUInteger subscribeCycleGeneration;

/// Process live feed events from subscribe response.
- (void)handleLiveFeedEvents:(PNSubscribeStatus *)status
      forInitialSubscription:(BOOL)initialSubscription
           overrideTimeToken:(nullable NSNumber *)overrideTimeToken;

/// Start subscribe cycle.
- (void)subscribe:(BOOL)initialSubscribe
   usingTimeToken:(nullable NSNumber *)timeToken
        withState:(nullable NSDictionary<NSString *, id> *)state
  queryParameters:(nullable NSDictionary *)queryParameters
       completion:(nullable PNSubscriberCompletionBlock)block;

@end


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNSubscribeTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNSubscribeTest


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}

#pragma mark - Tests :: Request

- (void)testItShouldSetProperRequestValues {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch-a"] channelGroups:@[@"gr-a"]];

    id clientTransportMock = [self mockForObject:self.client.subscriptionNetwork];
    id recorded = OCMExpect([clientTransportMock sendRequest:[OCMArg isKindOfClass:[PNTransportRequest class]]
                                         withCompletionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNTransportRequest *transportRequest = [self objectForInvocation:invocation argumentAtIndex:1];
            NSLog(@"CALLED");

            XCTAssertEqual(transportRequest.timeout, self.client.configuration.subscribeMaximumIdleTime);
            XCTAssertTrue(transportRequest.cancellable);
            XCTAssertTrue(transportRequest.retriable);
        });

    [self waitForObject:clientTransportMock recordedInvocationCall:recorded afterBlock:^{
        [self.client subscribeWithRequest:request];
    }];
}


#pragma mark - Tests :: Subscribe cycle continuation

/// Test that the subscribe loop continues normally when no new subscribe cycle interrupts event processing.
- (void)testItShouldContinueSubscriptionCycleWhenGenerationUnchanged {
    PNSubscriber *subscriber = self.client.subscriberManager;
    [subscriber addChannels:@[@"ch-a"]];

    NSUInteger generationBefore = subscriber.subscribeCycleGeneration;

    __block NSInteger sendRequestCount = 0;
    id transportMock = [self mockForObject:self.client.subscriptionNetwork];
    OCMStub([transportMock sendRequest:[OCMArg any] withCompletionBlock:[OCMArg any]])
        .andDo(^(__unused NSInvocation *invocation) { sendRequestCount++; });

    id mockStatus = [self mockSubscribeStatusWithEvents];

    // Trigger event handling without starting a new cycle (generation stays the same).
    [subscriber handleLiveFeedEvents:mockStatus forInitialSubscription:NO overrideTimeToken:nil];

    // Wait for the async block on listenersManager.resourceAccessQueue to complete.
    [self waitForAsyncOperationsWithDelay:0.5];

    XCTAssertEqual(subscriber.subscribeCycleGeneration, generationBefore,
                   @"Generation should not change when no new cycle starts");
    // Continuation should have fired, triggering one sendRequest call.
    XCTAssertEqual(sendRequestCount, 1, @"Normal continuation should trigger a subscribe request");
}

/// Test that a stale continuation from an old subscribe cycle is suppressed when a new cycle has started.
///
/// This reproduces the race condition:
/// 1. Long-poll response arrives with events, `handleLiveFeedEvents:` captures the current generation and dispatches
///    continuation async to `listenersManager.resourceAccessQueue`.
/// 2. User subscribes to new channels — `subscribe:YES` increments the generation counter.
/// 3. The async block from step 1 checks the generation, sees a mismatch, and skips the stale continuation.
///
/// Without the generation counter fix, step 3 would proceed with the stale continuation, creating a duplicate
/// subscribe loop.
- (void)testItShouldNotContinueStaleSubscriptionCycleWhenNewCycleStarted {
    PNSubscriber *subscriber = self.client.subscriberManager;
    [subscriber addChannels:@[@"ch-a"]];

    NSUInteger generationBefore = subscriber.subscribeCycleGeneration;

    __block NSInteger sendRequestCount = 0;
    id transportMock = [self mockForObject:self.client.subscriptionNetwork];
    OCMStub([transportMock sendRequest:[OCMArg any] withCompletionBlock:[OCMArg any]])
        .andDo(^(__unused NSInvocation *invocation) { sendRequestCount++; });

    id mockStatus = [self mockSubscribeStatusWithEvents];

    // Step 1: Trigger event handling — captures generation and dispatches async continuation.
    [subscriber handleLiveFeedEvents:mockStatus forInitialSubscription:NO overrideTimeToken:nil];

    // Step 2: Start a new subscribe cycle (increments generation under the lock).
    // This synchronously sends one subscribe request via the mocked transport.
    [subscriber subscribe:YES usingTimeToken:@0 withState:nil queryParameters:nil completion:nil];

    // Wait for the async block on listenersManager.resourceAccessQueue to complete.
    [self waitForAsyncOperationsWithDelay:0.5];

    XCTAssertGreaterThan(subscriber.subscribeCycleGeneration, generationBefore,
                         @"Generation should have incremented after subscribe:YES");
    // Only the explicit subscribe:YES request should have been sent.
    // The stale continuation from handleLiveFeedEvents should have been suppressed by the generation check.
    XCTAssertEqual(sendRequestCount, 1, @"Stale continuation should not trigger an additional subscribe request");
}


#pragma mark - Tests :: Subscribe retry

/// Test that the transport retries a subscribe request when the server responds with HTTP 500.
///
/// Uses a custom `NSURLProtocol` to return 500 on the first attempt and 200 on the retry.
/// Verifies that the transport's retry mechanism kicks in and the final response is successful.
- (void)testSubscribeRequestShouldBeRetriedOnServerError {
    _PNSubscribeRetryProtocolRequestCount = 0;

    // Set up transport with retry configuration (short delay for fast tests).
    PNURLSessionTransport *transport = [PNURLSessionTransport new];
    PNTransportConfiguration *config = [PNTransportConfiguration new];
    config.maximumConnections = 1;
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay:0.1f
                                                                                            maximumRetry:2
                                                                                       excludedEndpoints:0];
    config.retryConfiguration = retryConfig;
    [transport setupWithConfiguration:config];

    // Replace the transport's session with one that uses our test protocol.
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfig.protocolClasses = @[[PNSubscribeRetryTestProtocol class]];
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    NSURLSession *testSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:queue];
    [transport setValue:testSession forKey:@"session"];

    // Build a subscribe-like transport request.
    PNTransportRequest *request = [PNTransportRequest new];
    request.origin = @"https://ps.pndsn.com";
    request.path = @"/v2/subscribe/demo/test-channel/0";
    request.timeout = 10;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Subscribe retry"];

    [transport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                         id<PNTransportResponse> response,
                                                         PNError *error) {
        XCTAssertNil(error, @"Final response should not have an error after successful retry");
        XCTAssertEqual(response.statusCode, 200, @"Final response should be 200 after retry");
        XCTAssertEqual(req.retryAttempt, 1, @"Request should have been retried once");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    XCTAssertEqual(_PNSubscribeRetryProtocolRequestCount, 2,
                   @"Protocol should have seen exactly 2 requests (initial + 1 retry)");
}


#pragma mark - Helpers

/// Create a mock `PNSubscribeStatus` with one event to exercise the async `notifyWithBlock:` path.
- (id)mockSubscribeStatusWithEvents {
    id mockCursor = OCMClassMock([PNSubscribeCursorData class]);
    OCMStub([mockCursor timetoken]).andReturn(@"17000000000000000");
    OCMStub([(PNSubscribeCursorData *)mockCursor region]).andReturn(@2);

    id mockEvent = OCMClassMock([PNSubscribeMessageEventData class]);
    OCMStub([(PNSubscribeEventData *)mockEvent messageType]).andReturn(@0);
    OCMStub([mockEvent timetoken]).andReturn(@17000000000000000);
    OCMStub([mockEvent channel]).andReturn(@"ch-a");
    OCMStub([mockEvent subscription]).andReturn(@"ch-a");
    OCMStub([mockEvent message]).andReturn(@{@"text": @"hello"});

    id mockData = OCMClassMock([PNSubscribeData class]);
    OCMStub([mockData updates]).andReturn(@[mockEvent]);
    OCMStub([mockData cursor]).andReturn(mockCursor);

    id mockStatus = OCMClassMock([PNSubscribeStatus class]);
    OCMStub([mockStatus isError]).andReturn(NO);
    OCMStub([(PNSubscribeStatus *)mockStatus category]).andReturn(PNAcknowledgmentCategory);
    OCMStub([mockStatus isInitialSubscription]).andReturn(NO);
    OCMStub([mockStatus data]).andReturn(mockData);

    return mockStatus;
}

/// Block the current thread until async operations have had time to complete.
- (void)waitForAsyncOperationsWithDelay:(NSTimeInterval)delay {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)((delay + 2) * NSEC_PER_SEC)));
}

#pragma mark -

@end
