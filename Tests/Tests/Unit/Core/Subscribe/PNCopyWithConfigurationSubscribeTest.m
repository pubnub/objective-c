#import "PNRecordableTestCase.h"
#import <OCMock/OCMock.h>
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNStatus+Private.h>
#import "PubNub+SubscribePrivate.h"
#import "PNSubscribeStatus+Private.h"
#import "PNTransportConfiguration+Private.h"
#import "PNTransportRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNURLSessionTransport.h"


#pragma mark Slow subscribe protocol

/// URL protocol that holds subscribe requests indefinitely (simulating a slow / non-responsive origin).
///
/// The protocol accepts `/v2/subscribe/` requests and never calls `-[NSURLProtocolClient URLProtocolDidFinishLoading:]`,
/// effectively simulating a connection that has been established but never receives a response.
/// Call `+completeAllPendingWithError:` to finish all in-flight requests with the specified error.
@interface PNSlowSubscribeProtocol : NSURLProtocol

#pragma mark -

@end

static NSMutableArray<PNSlowSubscribeProtocol *> *_pendingProtocols;
static dispatch_queue_t _pendingProtocolsQueue;


#pragma mark - Slow protocol implementation

@implementation PNSlowSubscribeProtocol

+ (void)initialize {
    if (self == [PNSlowSubscribeProtocol class]) {
        _pendingProtocols = [NSMutableArray new];
        _pendingProtocolsQueue = dispatch_queue_create("com.pubnub.test.slow-subscribe", DISPATCH_QUEUE_SERIAL);
    }
}

+ (void)reset {
    dispatch_sync(_pendingProtocolsQueue, ^{
        [_pendingProtocols removeAllObjects];
    });
}

+ (NSUInteger)pendingCount {
    __block NSUInteger count;
    dispatch_sync(_pendingProtocolsQueue, ^{
        count = _pendingProtocols.count;
    });
    return count;
}

/// Finish all in-flight requests with the given error (simulating a network failure).
+ (void)completeAllPendingWithError:(NSError *)error {
    __block NSArray<PNSlowSubscribeProtocol *> *snapshot;
    dispatch_sync(_pendingProtocolsQueue, ^{
        snapshot = [_pendingProtocols copy];
        [_pendingProtocols removeAllObjects];
    });

    for (PNSlowSubscribeProtocol *protocol in snapshot) {
        [protocol.client URLProtocol:protocol didFailWithError:error];
    }
}

/// Finish all in-flight requests with a successful HTTP 200 subscribe response.
+ (void)completeAllPendingWithSuccess {
    __block NSArray<PNSlowSubscribeProtocol *> *snapshot;
    dispatch_sync(_pendingProtocolsQueue, ^{
        snapshot = [_pendingProtocols copy];
        [_pendingProtocols removeAllObjects];
    });

    for (PNSlowSubscribeProtocol *protocol in snapshot) {
        NSData *data = [@"{\"t\":{\"t\":\"17000000000000000\",\"r\":2},\"m\":[]}"
                        dataUsingEncoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:protocol.request.URL
                                                                  statusCode:200
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:@{@"Content-Type": @"application/json"}];
        [protocol.client URLProtocol:protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [protocol.client URLProtocol:protocol didLoadData:data];
        [protocol.client URLProtocolDidFinishLoading:protocol];
    }
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [request.URL.path containsString:@"/v2/subscribe/"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    dispatch_sync(_pendingProtocolsQueue, ^{
        [_pendingProtocols addObject:self];
    });
}

- (void)stopLoading {
    dispatch_sync(_pendingProtocolsQueue, ^{
        [_pendingProtocols removeObject:self];
    });
}

#pragma mark -


@end


#pragma mark - Subscriber state constants

/// Mirror of the PNSubscriberState enum defined in PNSubscriber.m (not exposed in any public/private header).
static const NSUInteger PNTestInitializedSubscriberState = 0;
static const NSUInteger PNTestDisconnectedSubscriberState = 1;
static const NSUInteger PNTestConnectedSubscriberState = 3;


#pragma mark - Private subscriber methods exposure

@interface PNSubscriber (CopyTestAccess)

/// Current subscriber state (PNSubscriberState, stored as NSUInteger).
@property (assign, nonatomic) NSUInteger currentState;

/// Current time token used in subscribe loop.
@property (strong, nonatomic) NSNumber *currentTimeToken;

/// Previous time token.
@property (strong, nonatomic) NSNumber *lastTimeToken;

/// Subscription channels set.
@property (strong, nonatomic, readonly) NSMutableSet<NSString *> *channelsSet;

/// Handle subscribe status (success or failure).
- (void)handleSubscriptionStatus:(PNSubscribeStatus *)status;

/// Start subscribe cycle.
- (void)subscribe:(BOOL)initialSubscribe
   usingTimeToken:(nullable NSNumber *)timeToken
        withState:(nullable NSDictionary<NSString *, id> *)state
  queryParameters:(nullable NSDictionary *)queryParameters
       completion:(nullable PNSubscriberCompletionBlock)block;

@end


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

@interface PNCopyWithConfigurationSubscribeTest : PNRecordableTestCase
@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNCopyWithConfigurationSubscribeTest


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}

#pragma mark - Setup / Teardown

- (void)setUp {
    [super setUp];
    [PNSlowSubscribeProtocol reset];
}

- (void)tearDown {
    [PNSlowSubscribeProtocol reset];
    [super tearDown];
}


#pragma mark - Tests :: State inheritance during mid-subscribe

/// Test that `inheritStateFromSubscriber:` preserves the source subscriber's `Initialized` state when the source has
/// not yet completed its initial subscribe handshake.
///
/// When the source subscriber has channels but is still in `PNInitializedSubscriberState` (initial subscribe in-flight),
/// the new subscriber should inherit that same `Initialized` state — not jump to `Disconnected`. This ensures that
/// `copyWithConfiguration:` continuation logic can detect the incomplete handshake and use an initial subscribe
/// (`subscribe:YES`) instead of a long-poll continuation.
- (void)testInheritStatePreservesInitializedWhenSourceHasNotConnected {
    PNSubscriber *source = self.client.subscriberManager;
    [source addChannels:@[@"test-channel"]];

    // Source is freshly initialized — still in PNInitializedSubscriberState (no subscribe response yet).
    XCTAssertEqual(source.currentState, PNTestInitializedSubscriberState,
                   @"Source subscriber should be in Initialized state before subscribe completes");

    PubNub *newClient = [PubNub clientWithConfiguration:self.client.configuration
                                          callbackQueue:dispatch_get_main_queue()];
    [newClient.subscriberManager inheritStateFromSubscriber:source];

    XCTAssertEqual(newClient.subscriberManager.currentState, PNTestInitializedSubscriberState,
                   @"New subscriber should inherit Initialized state from source that hasn't connected yet");
    XCTAssertTrue([newClient.subscriberManager.channelsSet containsObject:@"test-channel"],
                  @"Channels should be inherited");
}

/// Test that `inheritStateFromSubscriber:` sets `Disconnected` state when the source subscriber was previously
/// connected.
///
/// When the source has completed a subscribe handshake (state = `Connected`), the new subscriber should start in
/// `Disconnected` because it needs to re-establish its own connection.
- (void)testInheritStateSetsDisconnectedWhenSourceWasConnected {
    PNSubscriber *source = self.client.subscriberManager;
    [source addChannels:@[@"test-channel"]];
    source.currentState = PNTestConnectedSubscriberState;
    source.currentTimeToken = @17000000000000000;

    PubNub *newClient = [PubNub clientWithConfiguration:self.client.configuration
                                          callbackQueue:dispatch_get_main_queue()];
    [newClient.subscriberManager inheritStateFromSubscriber:source];

    XCTAssertEqual(newClient.subscriberManager.currentState, PNTestDisconnectedSubscriberState,
                   @"New subscriber should be Disconnected when source was Connected");
    XCTAssertTrue([newClient.subscriberManager.channelsSet containsObject:@"test-channel"],
                  @"Channels should be inherited");
    XCTAssertEqualObjects(newClient.subscriberManager.currentTimeToken, @17000000000000000,
                          @"Should inherit the non-zero time token from connected source");
}

/// Test that `inheritStateFromSubscriber:` copies time tokens from the source.
///
/// When `copyWithConfiguration:` is called mid-subscribe, the source's `currentTimeToken` is `0` (initial subscribe
/// resets it). The new subscriber should inherit this `0` value.
- (void)testInheritStateCopiesZeroTimeTokenDuringInitialSubscribe {
    PNSubscriber *source = self.client.subscriberManager;
    [source addChannels:@[@"test-channel"]];
    source.currentTimeToken = @0;
    source.lastTimeToken = @12345;

    PubNub *newClient = [PubNub clientWithConfiguration:self.client.configuration
                                          callbackQueue:dispatch_get_main_queue()];
    [newClient.subscriberManager inheritStateFromSubscriber:source];

    XCTAssertEqualObjects(newClient.subscriberManager.currentTimeToken, @0,
                          @"Should inherit the zero time token from mid-subscribe source");
    XCTAssertEqualObjects(newClient.subscriberManager.lastTimeToken, @12345,
                          @"Should inherit the last time token from source");
}


#pragma mark - Tests :: Unexpected disconnect after copyWithConfiguration during mid-subscribe

/// Test that when `copyWithConfiguration:` is called while the original client's initial subscribe is in-flight and the
/// new client's initial subscribe fails with a network error, the `PNUnexpectedDisconnectCategory` status is delivered to
/// listeners.
///
/// ## Scenario:
/// 1. Client A starts subscribing (TT=0) but the connection is slow — response hasn't arrived yet.
/// 2. `copyWithConfiguration:completion:` creates Client B, inheriting state from A.
///    - After fix: `inheritStateFromSubscriber:` preserves `PNInitializedSubscriberState` and `_currentTimeToken = 0`.
/// 3. Client B's continuation detects the `Initialized` state and calls `subscribe:YES` (initial subscribe).
/// 4. That subscribe request fails with a network error.
///
/// ## Expected (after fix):
/// Listeners should receive a status with `PNUnexpectedDisconnectCategory`.
/// The `Initialized → DisconnectedUnexpectedly` transition is in the allowed set, so `updateStateTo:` handles it.
- (void)testCopyWithConfigurationDuringMidSubscribeNotifiesUnexpectedDisconnectOnNetworkFailure {
    // Set up transport that holds subscribe requests without completing them.
    PNURLSessionTransport *transport = [PNURLSessionTransport new];
    PNTransportConfiguration *config = [PNTransportConfiguration new];
    config.maximumConnections = 1;
    [transport setupWithConfiguration:config];

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfig.protocolClasses = @[[PNSlowSubscribeProtocol class]];
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    NSURLSession *testSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:queue];
    [transport setValue:testSession forKey:@"session"];

    // Replace client's subscription transport with the slow one.
    self.client.subscriptionNetwork = transport;

    // Step 1: Start subscribing on the original client. The subscribe request will hang (slow origin).
    [self.client.subscriberManager addChannels:@[@"test-channel"]];
    [self.client.subscriberManager subscribe:YES usingTimeToken:@0 withState:nil queryParameters:nil completion:nil];
    
    // Wait for the slow protocol to capture the original client's request.
    [self waitForCondition:^BOOL {
        return [PNSlowSubscribeProtocol pendingCount] > 0;
    } withTimeout:3.0 description:@"Initial subscribe request should be in-flight"];

    // Drain the original client's pending request so it doesn't interfere with the new client's.
    [PNSlowSubscribeProtocol reset];

    // Step 2: Create a new client via copyWithConfiguration (simulated).
    PNConfiguration *newConfig = [self.client.configuration copy];
    PubNub *newClient = [PubNub clientWithConfiguration:newConfig
                                          callbackQueue:dispatch_get_main_queue()];
    [newClient.subscriberManager inheritStateFromSubscriber:self.client.subscriberManager];
    [newClient.listenersManager inheritStateFromListener:self.client.listenersManager];
    [newClient removeListener:(id <PNEventsListener>)self.client];

    // Verify preconditions: after fix, new subscriber should be Initialized (source hadn't connected).
    XCTAssertEqual(newClient.subscriberManager.currentState, PNTestInitializedSubscriberState,
                   @"New subscriber should inherit Initialized state from mid-subscribe source");
    XCTAssertEqualObjects(newClient.subscriberManager.currentTimeToken, @0,
                          @"New subscriber should have TT=0 (inherited from mid-subscribe source)");

    // Step 3: Set up transport for the new client that will fail with a network error.
    PNURLSessionTransport *failTransport = [PNURLSessionTransport new];
    PNTransportConfiguration *failConfig = [PNTransportConfiguration new];
    failConfig.maximumConnections = 1;
    [failTransport setupWithConfiguration:failConfig];

    NSURLSessionConfiguration *failSessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    failSessionConfig.protocolClasses = @[[PNSlowSubscribeProtocol class]];
    NSOperationQueue *failQueue = [NSOperationQueue new];
    failQueue.maxConcurrentOperationCount = 1;
    NSURLSession *failSession = [NSURLSession sessionWithConfiguration:failSessionConfig
                                                              delegate:nil
                                                         delegateQueue:failQueue];
    [failTransport setValue:failSession forKey:@"session"];
    newClient.subscriptionNetwork = failTransport;

    // Step 4: Listen for unexpected disconnect on the new client.
    XCTestExpectation *unexpectedDisconnectExpectation =
        [self expectationWithDescription:@"Should receive PNUnexpectedDisconnectCategory"];
    unexpectedDisconnectExpectation.assertForOverFulfill = YES;

    [self addStatusHandlerForClient:newClient withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
        if (status.category == PNUnexpectedDisconnectCategory) {
            *remove = YES;
            [unexpectedDisconnectExpectation fulfill];
        }
    }];

    // Step 5: Trigger subscription restoration (the real code path from copyWithConfiguration:).
    [newClient.subscriberManager continueSubscriptionCycleIfRequiredRestoringSubscription:YES completion:nil];

    // Wait for the NEW client's subscribe request to be captured (pending count was 0 after reset).
    [self waitForCondition:^BOOL {
        return [PNSlowSubscribeProtocol pendingCount] > 0;
    } withTimeout:3.0 description:@"New client's subscribe request should be in-flight"];

    // Step 6: Simulate network failure — only the new client's request is pending now.
    NSError *networkError = [NSError errorWithDomain:NSURLErrorDomain
                                                code:NSURLErrorNetworkConnectionLost
                                            userInfo:nil];
    [PNSlowSubscribeProtocol completeAllPendingWithError:networkError];

    // Step 7: Verify that the unexpected disconnect status is delivered.
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


/// Test that when `copyWithConfiguration:` is called during mid-subscribe and the new client's initial subscribe succeeds,
/// listeners receive a `PNConnectedCategory` status.
///
/// This validates the success path: `PNInitializedSubscriberState → PNConnectedSubscriberState` with TT=0 triggers
/// `PNConnectedCategory`, which is a valid transition.
- (void)testCopyWithConfigurationDuringMidSubscribeNotifiesConnectedOnSuccess {
    // Step 1: Set up original client with channels (simulating mid-subscribe).
    [self.client.subscriberManager addChannels:@[@"test-channel"]];
    self.client.subscriberManager.currentTimeToken = @0;

    // Step 2: Create new client and inherit state.
    PNConfiguration *newConfig = [self.client.configuration copy];
    PubNub *newClient = [PubNub clientWithConfiguration:newConfig
                                          callbackQueue:dispatch_get_main_queue()];
    [newClient.subscriberManager inheritStateFromSubscriber:self.client.subscriberManager];
    [newClient.listenersManager inheritStateFromListener:self.client.listenersManager];
    [newClient removeListener:(id <PNEventsListener>)self.client];

    // Step 3: Set up transport that will succeed.
    PNURLSessionTransport *successTransport = [PNURLSessionTransport new];
    PNTransportConfiguration *transportConfig = [PNTransportConfiguration new];
    transportConfig.maximumConnections = 1;
    [successTransport setupWithConfiguration:transportConfig];

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfig.protocolClasses = @[[PNSlowSubscribeProtocol class]];
    NSOperationQueue *opQueue = [NSOperationQueue new];
    opQueue.maxConcurrentOperationCount = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:opQueue];
    [successTransport setValue:session forKey:@"session"];
    newClient.subscriptionNetwork = successTransport;

    // Step 4: Listen for connected status.
    XCTestExpectation *connectedExpectation =
        [self expectationWithDescription:@"Should receive PNConnectedCategory"];

    [self addStatusHandlerForClient:newClient withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
        if (status.category == PNConnectedCategory) {
            *remove = YES;
            [connectedExpectation fulfill];
        }
    }];

    // Step 5: Trigger subscription restoration (the real code path from copyWithConfiguration:).
    [newClient.subscriberManager continueSubscriptionCycleIfRequiredRestoringSubscription:YES completion:nil];

    // Wait for the request to be captured, then complete it successfully.
    [self waitForCondition:^BOOL {
        return [PNSlowSubscribeProtocol pendingCount] > 0;
    } withTimeout:3.0 description:@"Subscribe request should be in-flight"];

    [PNSlowSubscribeProtocol completeAllPendingWithSuccess];

    // Step 6: Verify connected status.
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: State transition validation

/// Verify that listener notification works correctly for the `Initialized → DisconnectedUnexpectedly` transition.
///
/// This is the key transition for the mid-subscribe `copyWithConfiguration:` scenario. After the fix, the new subscriber
/// inherits `Initialized` state and uses `subscribe:YES`. If that fails, the `Initialized → DisconnectedUnexpectedly`
/// transition must fire `PNUnexpectedDisconnectCategory` to listeners.
- (void)testInitializedToUnexpectedDisconnectTransitionNotifiesListeners {
    PNSubscriber *subscriber = self.client.subscriberManager;
    [subscriber addChannels:@[@"test-channel"]];

    // Subscriber starts in PNInitializedSubscriberState by default.
    XCTAssertEqual(subscriber.currentState, PNTestInitializedSubscriberState);

    XCTestExpectation *statusExpectation =
        [self expectationWithDescription:@"Should notify unexpected disconnect from Initialized state"];

    [self addStatusHandlerForClient:self.client withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
        if (status.category == PNUnexpectedDisconnectCategory) {
            *remove = YES;
            [statusExpectation fulfill];
        }
    }];

    PNSubscribeStatus *errorStatus = [PNSubscribeStatus objectWithOperation:PNSubscribeOperation
                                                                   category:PNTimeoutCategory
                                                                   response:nil];
    [subscriber handleSubscriptionStatus:errorStatus];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Listener inheritance (union vs replace)

/// Verify that `inheritStateFromListener:` merges (unions) listeners rather than replacing them.
///
/// When `copyWithConfiguration:` creates a new PubNub client, the client adds itself as a listener during `init`.
/// Then `inheritStateFromListener:` is called to copy listeners from the old client. Before the fix, this **replaced**
/// the listener tables, wiping out the new client's self-listener. After the fix, it **unions** them so the new client
/// retains its self-listener and gains the old client's listeners.
- (void)testInheritStateFromListenerMergesInsteadOfReplacing {
    // Create a new client — it adds itself as a listener during init.
    PNConfiguration *newConfig = [self.client.configuration copy];
    PubNub *newClient = [PubNub clientWithConfiguration:newConfig
                                          callbackQueue:dispatch_get_main_queue()];

    // Verify newClient is in its own listener list.
    NSHashTable *listenersBeforeInherit = [newClient.listenersManager valueForKey:@"stateListeners"];

    // Wait for async dispatch in addListener to complete.
    XCTestExpectation *dispatchExpectation = [self expectationWithDescription:@"Listener dispatch"];
    dispatch_async([newClient.listenersManager valueForKey:@"resourceAccessQueue"], ^{
        [dispatchExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertTrue([listenersBeforeInherit containsObject:newClient],
                  @"New client should be in its own state listeners after init");

    // Now inherit from the original client (which has its own self-listener).
    [newClient.listenersManager inheritStateFromListener:self.client.listenersManager];

    // Wait for async dispatch in inheritStateFromListener to complete.
    XCTestExpectation *inheritExpectation = [self expectationWithDescription:@"Inherit dispatch"];
    dispatch_async([newClient.listenersManager valueForKey:@"resourceAccessQueue"], ^{
        [inheritExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    NSHashTable *listenersAfterInherit = [newClient.listenersManager valueForKey:@"stateListeners"];

    // After union, newClient should still be in the list (not wiped out by the old client's listeners).
    XCTAssertTrue([listenersAfterInherit containsObject:newClient],
                  @"New client must remain in state listeners after inheritStateFromListener: (union, not replace)");
}


#pragma mark - Tests :: continueSubscriptionCycleIfRequiredRestoringSubscription:completion: initial subscribe detection

/// Verify that `continueSubscriptionCycleIfRequiredRestoringSubscription:completion:` calls `subscribe:YES` when restoring
/// and the subscriber is in `PNInitializedSubscriberState`, triggering a proper initial subscribe handshake.
- (void)testContinuationUsesInitialSubscribeWhenStateIsInitialized {
    PNSubscriber *subscriber = self.client.subscriberManager;
    [subscriber addChannels:@[@"test-channel"]];

    // State is Initialized (default) — continuation should detect this and use subscribe:YES.
    XCTAssertEqual(subscriber.currentState, PNTestInitializedSubscriberState);

    // Partial mock on the subscriber to intercept subscribe:usingTimeToken:withState:queryParameters:completion:
    // and verify the initialSubscribe argument.
    __block BOOL capturedInitialSubscribe = NO;
    __block BOOL subscribeCalled = NO;
    id subscriberMock = [self mockForObject:subscriber];
    OCMStub([subscriberMock subscribe:YES
                       usingTimeToken:[OCMArg any]
                            withState:[OCMArg any]
                      queryParameters:[OCMArg any]
                           completion:[OCMArg any]])
        .andDo(^(__unused NSInvocation *invocation) {
            capturedInitialSubscribe = YES;
            subscribeCalled = YES;
        });

    OCMStub([subscriberMock subscribe:NO
                       usingTimeToken:[OCMArg any]
                            withState:[OCMArg any]
                      queryParameters:[OCMArg any]
                           completion:[OCMArg any]])
        .andDo(^(__unused NSInvocation *invocation) {
            capturedInitialSubscribe = NO;
            subscribeCalled = YES;
        });

    [subscriber continueSubscriptionCycleIfRequiredRestoringSubscription:YES completion:nil];

    XCTAssertTrue(subscribeCalled, @"subscribe:usingTimeToken:... should have been called");
    XCTAssertTrue(capturedInitialSubscribe,
                  @"Continuation from Initialized state should call subscribe:YES (initial subscribe)");
}

/// Verify that `continueSubscriptionCycleIfRequiredRestoringSubscription:completion:` calls `subscribe:NO` when restoring
/// and the subscriber is in `PNConnectedSubscriberState`, using the existing timetoken for a long-poll continuation.
- (void)testContinuationUsesLongPollWhenStateIsConnected {
    PNSubscriber *subscriber = self.client.subscriberManager;
    [subscriber addChannels:@[@"test-channel"]];
    subscriber.currentState = PNTestConnectedSubscriberState;
    subscriber.currentTimeToken = @17000000000000000;

    __block BOOL capturedInitialSubscribe = YES;
    __block BOOL subscribeCalled = NO;
    id subscriberMock = [self mockForObject:subscriber];
    OCMStub([subscriberMock subscribe:YES
                       usingTimeToken:[OCMArg any]
                            withState:[OCMArg any]
                      queryParameters:[OCMArg any]
                           completion:[OCMArg any]])
        .andDo(^(__unused NSInvocation *invocation) {
            capturedInitialSubscribe = YES;
            subscribeCalled = YES;
        });

    OCMStub([subscriberMock subscribe:NO
                       usingTimeToken:[OCMArg any]
                            withState:[OCMArg any]
                      queryParameters:[OCMArg any]
                           completion:[OCMArg any]])
        .andDo(^(__unused NSInvocation *invocation) {
            capturedInitialSubscribe = NO;
            subscribeCalled = YES;
        });

    [subscriber continueSubscriptionCycleIfRequiredRestoringSubscription:YES completion:nil];

    XCTAssertTrue(subscribeCalled, @"subscribe:usingTimeToken:... should have been called");
    XCTAssertFalse(capturedInitialSubscribe,
                   @"Continuation from Connected state should call subscribe:NO (long-poll)");
}


#pragma mark - Tests :: copyWithConfiguration unsubscribe behavior

/// Verify that `copyWithConfiguration:completion:` does **not** trigger an unsubscribe when only `authKey` changes.
///
/// When a token expires and is refreshed, the client should seamlessly continue its subscription on the new instance
/// without sending a leave request with the old (possibly expired) credentials. The new client inherits subscriber state
/// and resubscribes with the fresh auth key automatically.
- (void)testCopyWithConfigurationDoesNotUnsubscribeWhenOnlyAuthKeyChanges {
    [self.client.subscriberManager addChannels:@[@"test-channel"]];
    self.client.subscriberManager.currentState = PNTestConnectedSubscriberState;

    id clientMock = [self mockForObject:self.client];

    OCMReject([clientMock unsubscribeFromChannels:[OCMArg any]
                                           groups:[OCMArg any]
                                     withPresence:YES
                                  queryParameters:[OCMArg any]
                                       completion:[OCMArg any]]);

    PNConfiguration *newConfig = [self.client.configuration copy];
    newConfig.authKey = @"new-auth-token";

    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"copyWithConfiguration: should complete"];

    // Set up transport that will succeed for the new client's subscribe.
    PNURLSessionTransport *transport = [PNURLSessionTransport new];
    PNTransportConfiguration *transportConfig = [PNTransportConfiguration new];
    transportConfig.maximumConnections = 1;
    [transport setupWithConfiguration:transportConfig];

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfig.protocolClasses = @[[PNSlowSubscribeProtocol class]];
    NSOperationQueue *opQueue = [NSOperationQueue new];
    opQueue.maxConcurrentOperationCount = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:opQueue];
    [transport setValue:session forKey:@"session"];

    [self.client copyWithConfiguration:newConfig completion:^(PubNub *client) {
        client.subscriptionNetwork = transport;
        [completionExpectation fulfill];
    }];

    // Complete the new client's subscribe request so the completion fires.
    [self waitForCondition:^BOOL {
        return [PNSlowSubscribeProtocol pendingCount] > 0;
    } withTimeout:3.0 description:@"New client's subscribe request should be in-flight"];
    [PNSlowSubscribeProtocol completeAllPendingWithSuccess];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    OCMVerifyAll(clientMock);
}

/// Verify that `copyWithConfiguration:completion:` **does** trigger an unsubscribe when `userID` changes.
///
/// A user identity change means the server-side presence state (join/leave) is tied to the old identity.
/// The old client must send a leave so presence accurately reflects that the old user departed, before the new client
/// subscribes under the new identity.
- (void)testCopyWithConfigurationUnsubscribesWhenUserIDChanges {
    [self.client.subscriberManager addChannels:@[@"test-channel"]];
    self.client.subscriberManager.currentState = PNTestConnectedSubscriberState;

    __block BOOL unsubscribeCalled = NO;
    id clientMock = [self mockForObject:self.client];

    OCMStub([clientMock unsubscribeFromChannels:[OCMArg any]
                                         groups:[OCMArg any]
                                   withPresence:YES
                                queryParameters:[OCMArg any]
                                     completion:([OCMArg invokeBlockWithArgs:[NSNull null], nil])])
        .andDo(^(__unused NSInvocation *invocation) {
            unsubscribeCalled = YES;
        });

    PNConfiguration *newConfig = [self.client.configuration copy];
    newConfig.userID = @"different-user-id";

    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"copyWithConfiguration: should complete"];

    [self.client copyWithConfiguration:newConfig completion:^(PubNub *client) {
        [completionExpectation fulfill];
    }];

    // Complete the new client's subscribe request.
    [self waitForCondition:^BOOL {
        return [PNSlowSubscribeProtocol pendingCount] > 0;
    } withTimeout:3.0 description:@"New client's subscribe request should be in-flight"];
    [PNSlowSubscribeProtocol completeAllPendingWithSuccess];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertTrue(unsubscribeCalled,
                  @"copyWithConfiguration: should unsubscribe from old identity when userID changes");
}


#pragma mark - Helpers



/// Poll until `condition` returns YES or `timeout` elapses.
- (void)waitForCondition:(BOOL (^)(void))condition
             withTimeout:(NSTimeInterval)timeout
             description:(NSString *)description {
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeout];

    while (!condition() && [deadline timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
    }

    XCTAssertTrue(condition(), @"%@", description);
}

#pragma mark -


@end
