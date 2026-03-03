/**
 * @brief Thread safety tests for the PubNub client.
 *
 * These tests verify that concurrent access to the PubNub client does not cause crashes,
 * deadlocks, or data corruption. They exercise listener management, channel list access,
 * configuration copying, publish, subscribe/unsubscribe, callback queue verification, and
 * concurrent property access.
 *
 * @author PubNub Tests
 * @copyright 2010-2026 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <stdatomic.h>
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types and structures

/// Simple listener object that conforms to PNEventsListener.
///
/// Used by thread-safety tests to add/remove listeners concurrently.
@interface PNTestListener : NSObject <PNEventsListener>

/// Track whether any callback was received.
@property (nonatomic, assign) BOOL didReceiveStatus;

@end

@implementation PNTestListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    self.didReceiveStatus = YES;
}

@end


#pragma mark - Interface declaration

@interface PNThreadSafetyTest : PNRecordableTestCase


#pragma mark - Properties

/// All PubNub clients created during the current test.
///
/// Tracked so ``tearDown`` can ensure proper cleanup. Without this, residual async operations from
/// previous tests' clients accumulate on the shared ``PNLock`` subsystem queues
/// (`com.pubnub.subscriber`, `com.pubnub.transport`, `com.pubnub.serializer`) and eventually exhaust
/// the GCD thread pool — causing `dispatch_sync` callers to stall (deadlock via thread starvation).
@property (nonatomic, strong) NSMutableArray<PubNub *> *testClients;

/// Lock that protects concurrent access to ``testClients`` array.
@property (nonatomic, strong) NSLock *testClientsLock;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNThreadSafetyTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Teardown

- (void)setUp {
    [super setUp];

    self.testClients = [NSMutableArray new];
    self.testClientsLock = [NSLock new];
}

- (void)tearDown {
    // Unsubscribe and remove self-listeners for every tracked client so that in-flight subscribe
    // cycles and network requests are cancelled as quickly as possible.
    [self.testClientsLock lock];
    NSArray<PubNub *> *clients = [self.testClients copy];
    [self.testClients removeAllObjects];
    [self.testClientsLock unlock];

    // Use @autoreleasepool to ensure clients are deallocated immediately after cleanup.
    // Client dealloc calls -[PNURLSessionTransport invalidate] which cancels all pending HTTP
    // requests via -[NSURLSession invalidateAndCancel]. Releasing references BEFORE the drain
    // wait ensures the invalidation actually happens during that window — otherwise pending
    // requests from earlier tests accumulate on the shared PNLock subsystem target queues
    // (com.pubnub.transport, com.pubnub.subscriber, etc.) and can exhaust the GCD thread pool.
    @autoreleasepool {
        for (PubNub *client in clients) {
            [client unsubscribeFromAll];
            [client removeListener:client];
        }

        clients = nil;
    }

    // Wait for GCD to process dealloc-triggered network invalidation and drain remaining async
    // work (dispatch_barrier_async for transport invalidation, subscribe cycle teardown, etc.).
    [self waitTask:@"asyncOperationsDrain" completionFor:0.5];

    [super tearDown];
}


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Helpers

/// Create a standalone PubNub client for testing.
///
/// Creates a client with "demo" keys on a background callback queue, suitable for concurrency
/// testing without any VCR/network dependency.
- (PubNub *)createTestClient {
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
                                                                    subscribeKey:@"demo"
                                                                          userID:[[NSUUID UUID] UUIDString]];
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PubNub *client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
    [self trackClient:client];
    return client;
}

/// Keep a strong reference so ``tearDown`` can clean the client up.
- (void)trackClient:(PubNub *)client {
    [self.testClientsLock lock];
    [self.testClients addObject:client];
    [self.testClientsLock unlock];
}


#pragma mark - Tests :: Concurrent listener management

- (void)testConcurrentAddAndRemoveListeners {
    PubNub *client = [self createTestClient];
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNTestListener *listener = [PNTestListener new];
            [client addListener:listener];
            [client removeListener:listener];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent listener add/remove should complete without deadlock.");
}

- (void)testConcurrentAddListenersFromMultipleThreads {
    PubNub *client = [self createTestClient];
    int iterations = 100;
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray<PNTestListener *> *listeners = [NSMutableArray new];
    NSLock *arrayLock = [NSLock new];

    for (int i = 0; i < iterations; i++) {
        PNTestListener *listener = [PNTestListener new];
        [arrayLock lock];
        [listeners addObject:listener];
        [arrayLock unlock];

        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [client addListener:listener];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent addListener should complete without deadlock.");

    // Clean up: remove all listeners.
    for (PNTestListener *listener in listeners) {
        [client removeListener:listener];
    }
}

- (void)testConcurrentAddRemoveWithInterleavedOperations {
    PubNub *client = [self createTestClient];
    int iterations = 150;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNTestListener *listener = [PNTestListener new];
            [client addListener:listener];

            // Interleave with a property read.
            __unused NSArray *channels = [client channels];

            [client removeListener:listener];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Interleaved listener and channel access should not deadlock.");
}


#pragma mark - Tests :: Concurrent channel list access

- (void)testConcurrentChannelAndChannelGroupAccess {
    PubNub *client = [self createTestClient];
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __unused NSArray *channels = [client channels];
            __unused NSArray *groups = [client channelGroups];
            __unused NSArray *presenceChannels = [client presenceChannels];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent channel list reads should complete without crash.");
}

- (void)testConcurrentChannelReadWithSubscribeUnsubscribe {
    PubNub *client = [self createTestClient];
    int iterations = 20;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *channel = [NSString stringWithFormat:@"test-channel-%d", i];
            PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[channel]
                                                                    channelGroups:nil];
            [client subscribeWithRequest:request];
        });

        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __unused NSArray *channels = [client channels];
            __unused NSArray *groups = [client channelGroups];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent subscribe + channel read should not deadlock or crash.");

    [client unsubscribeFromAll];
}


#pragma mark - Tests :: Concurrent configuration copy

- (void)testConcurrentCopyWithConfiguration {
    PubNub *client = [self createTestClient];
    int iterations = 50;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNConfiguration *config = [client currentConfiguration];
            config.userID = [NSString stringWithFormat:@"user-%d-%@", i, [[NSUUID UUID] UUIDString]];

            [client copyWithConfiguration:config completion:^(PubNub *newClient) {
                XCTAssertNotNil(newClient, @"Copied client should not be nil.");
                [self trackClient:newClient];
                dispatch_group_leave(group);
            }];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent copyWithConfiguration should complete without deadlock.");
}

- (void)testConcurrentCopyWithConfigurationAndCallbackQueue {
    PubNub *client = [self createTestClient];
    int iterations = 30;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t customQueue = dispatch_queue_create("com.pubnub.test.custom-callback", DISPATCH_QUEUE_SERIAL);

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNConfiguration *config = [client currentConfiguration];
            config.userID = [NSString stringWithFormat:@"user-%d-%@", i, [[NSUUID UUID] UUIDString]];

            [client copyWithConfiguration:config callbackQueue:customQueue completion:^(PubNub *newClient) {
                XCTAssertNotNil(newClient, @"Copied client should not be nil.");
                [self trackClient:newClient];
                dispatch_group_leave(group);
            }];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent copyWithConfiguration with custom queue should complete.");
}


#pragma mark - Tests :: Concurrent publish

- (void)testConcurrentPublishFromMultipleThreads {
    PubNub *client = [self createTestClient];
    int iterations = 20;
    dispatch_group_t group = dispatch_group_create();
    __block _Atomic(int32_t) completionCount = 0;

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"test-channel"];
            request.message = @{@"index": @(i), @"text": @"concurrent test"};

            [client publishWithRequest:request completion:^(PNPublishStatus *status) {
                // We expect errors since "demo" keys may not support publish, but no crashes.
                atomic_fetch_add_explicit(&completionCount, 1, memory_order_relaxed);
                dispatch_group_leave(group);
            }];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"All concurrent publishes should complete without deadlock.");
    XCTAssertEqual(completionCount, iterations, @"All publish completion blocks should fire.");
}

- (void)testConcurrentPublishToMultipleChannels {
    PubNub *client = [self createTestClient];
    int iterations = 20;
    dispatch_group_t group = dispatch_group_create();
    __block _Atomic(int32_t) completionCount = 0;

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *channel = [NSString stringWithFormat:@"channel-%d", i];
            PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
            request.message = @{@"data": @"test"};

            [client publishWithRequest:request completion:^(PNPublishStatus *status) {
                atomic_fetch_add_explicit(&completionCount, 1, memory_order_relaxed);
                dispatch_group_leave(group);
            }];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"All publishes to different channels should complete.");
    XCTAssertEqual(completionCount, iterations, @"All completion blocks should fire.");
}


#pragma mark - Tests :: Concurrent subscribe/unsubscribe

- (void)testConcurrentSubscribeAndUnsubscribe {
    PubNub *client = [self createTestClient];
    int iterations = 20;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *channel = [NSString stringWithFormat:@"sub-channel-%d", i % 20];
            PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[channel]
                                                                    channelGroups:nil];
            [client subscribeWithRequest:request];
        });

        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *channel = [NSString stringWithFormat:@"sub-channel-%d", i % 20];
            PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithChannels:@[channel]
                                                                            channelGroups:nil];
            [client unsubscribeWithRequest:request];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent subscribe/unsubscribe should not deadlock or crash.");

    [client unsubscribeFromAll];
}

- (void)testConcurrentSubscribeToChannelsAndGroups {
    PubNub *client = [self createTestClient];
    int iterations = 20;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *channel = [NSString stringWithFormat:@"channel-%d", i];
            PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[channel]
                                                                    channelGroups:nil];
            [client subscribeWithRequest:request];
        });

        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *channelGroup = [NSString stringWithFormat:@"group-%d", i];
            PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:nil
                                                                    channelGroups:@[channelGroup]];
            [client subscribeWithRequest:request];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent channel + group subscribes should complete.");

    [client unsubscribeFromAll];
}

- (void)testConcurrentUnsubscribeFromAll {
    PubNub *client = [self createTestClient];
    int iterations = 20;
    dispatch_group_t group = dispatch_group_create();

    // First subscribe to some channels.
    for (int i = 0; i < 10; i++) {
        NSString *channel = [NSString stringWithFormat:@"unsub-channel-%d", i];
        PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[channel] channelGroups:nil];
        [client subscribeWithRequest:request];
    }

    // Concurrently unsubscribe from all.
    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [client unsubscribeFromAll];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent unsubscribeFromAll should not deadlock.");
}


#pragma mark - Tests :: Listener callback thread verification

- (void)testCallbackArrivesOnSpecifiedQueue {
    dispatch_queue_t callbackQueue = dispatch_queue_create("com.pubnub.test.callback-verify",
                                                            DISPATCH_QUEUE_SERIAL);
    dispatch_queue_set_specific(callbackQueue,
                                 (__bridge const void *)@"test-queue-key",
                                 (__bridge void *)@YES,
                                 NULL);

    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
                                                                    subscribeKey:@"demo"
                                                                          userID:[[NSUUID UUID] UUIDString]];
    PubNub *client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
    [self trackClient:client];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback on expected queue"];

    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"test-queue-channel"];
    request.message = @"test";

    [client publishWithRequest:request completion:^(PNPublishStatus *status) {
        BOOL onExpectedQueue = (dispatch_get_specific((__bridge const void *)@"test-queue-key") != NULL);
        XCTAssertTrue(onExpectedQueue,
                       @"Publish callback should arrive on the specified callbackQueue.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testDefaultCallbackQueueIsMainQueue {
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
                                                                    subscribeKey:@"demo"
                                                                          userID:[[NSUUID UUID] UUIDString]];
    // Pass nil for callbackQueue; should default to main.
    PubNub *client = [PubNub clientWithConfiguration:configuration];
    [self trackClient:client];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback on main queue"];

    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"main-queue-channel"];
    request.message = @"test";

    [client publishWithRequest:request completion:^(PNPublishStatus *status) {
        XCTAssertTrue([NSThread isMainThread], @"Default callback should arrive on main thread.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}


#pragma mark - Tests :: Concurrent state access

- (void)testConcurrentCurrentConfigurationAccess {
    PubNub *client = [self createTestClient];
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNConfiguration *config = [client currentConfiguration];
            XCTAssertNotNil(config, @"Configuration should not be nil.");
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent configuration access should complete.");
}

- (void)testConcurrentUserIDAccess {
    PubNub *client = [self createTestClient];
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *userID = [client userID];
            XCTAssertNotNil(userID, @"userID should not be nil.");
            XCTAssertGreaterThan(userID.length, 0u, @"userID should not be empty.");
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent userID access should complete.");
}

- (void)testConcurrentFilterExpressionAccess {
    PubNub *client = [self createTestClient];
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (i % 2 == 0) {
                client.filterExpression = [NSString stringWithFormat:@"type == 'test-%d'", i];
            } else {
                __unused NSString *filter = client.filterExpression;
            }
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent filterExpression read/write should not crash.");
}

- (void)testConcurrentStateAccessWhilePublishing {
    PubNub *client = [self createTestClient];
    int iterations = 20;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        // Read state from one thread.
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __unused NSString *userID = [client userID];
            __unused PNConfiguration *config = [client currentConfiguration];
            __unused NSString *filter = client.filterExpression;
            __unused NSArray *channels = [client channels];
        });

        // Publish from another thread.
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"state-test"];
            request.message = @{@"i": @(i)};

            [client publishWithRequest:request completion:^(PNPublishStatus *status) {
                dispatch_group_leave(group);
            }];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Concurrent state access while publishing should not crash or deadlock.");
}


#pragma mark - Tests :: Mixed concurrent operations

- (void)testMixedConcurrentOperations {
    PubNub *client = [self createTestClient];
    int iterations = 20;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        // Add/remove listeners.
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNTestListener *listener = [PNTestListener new];
            [client addListener:listener];
            [client removeListener:listener];
        });

        // Read channels.
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __unused NSArray *channels = [client channels];
            __unused NSArray *groups = [client channelGroups];
        });

        // Access configuration properties.
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __unused NSString *userID = [client userID];
            __unused PNConfiguration *config = [client currentConfiguration];
        });

        // Publish.
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"mixed-ops"];
            request.message = @(i);

            [client publishWithRequest:request completion:^(PNPublishStatus *status) {
                dispatch_group_leave(group);
            }];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Mixed concurrent operations should complete without deadlock or crash.");
}

- (void)testRapidSubscribeUnsubscribeWithListenerManagement {
    PubNub *client = [self createTestClient];
    int iterations = 20;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *channel = [NSString stringWithFormat:@"rapid-%d", i % 10];
            PNSubscribeRequest *subReq = [PNSubscribeRequest requestWithChannels:@[channel]
                                                                   channelGroups:nil];
            [client subscribeWithRequest:subReq];
        });

        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *channel = [NSString stringWithFormat:@"rapid-%d", i % 10];
            PNPresenceLeaveRequest *leaveReq = [PNPresenceLeaveRequest requestWithChannels:@[channel]
                                                                             channelGroups:nil];
            [client unsubscribeWithRequest:leaveReq];
        });

        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNTestListener *listener = [PNTestListener new];
            [client addListener:listener];
            [client removeListener:listener];
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0,
                   @"Rapid subscribe/unsubscribe with listener management should not crash.");

    [client unsubscribeFromAll];
}

#pragma mark -

#pragma clang diagnostic pop

@end
