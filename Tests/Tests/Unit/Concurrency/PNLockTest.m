/**
 * @brief Thread safety tests for PNLock (GCD-based MRSW lock) and PNLockSupport (pthread mutex helpers).
 *
 * These tests verify that the locking primitives work correctly under contention, do not deadlock,
 * and properly enforce mutual exclusion and reader-writer semantics.
 *
 * @author PubNub Tests
 * @copyright 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <stdatomic.h>
#import <PubNub/PNLock.h>
#import <PubNub/PNLockSupport.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNLockTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNLockTest


#pragma mark - Tests :: PNLock :: Basic read/write

- (void)testPNLockBasicSyncRead {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"basic-read"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock"];
    __block BOOL blockExecuted = NO;

    [lock syncReadAccessWithBlock:^{
        blockExecuted = YES;
    }];

    XCTAssertTrue(blockExecuted, @"Synchronous read block should execute.");
}

- (void)testPNLockBasicSyncWrite {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"basic-write"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock"];
    __block BOOL blockExecuted = NO;

    [lock syncWriteAccessWithBlock:^{
        blockExecuted = YES;
    }];

    XCTAssertTrue(blockExecuted, @"Synchronous write block should execute.");
}

- (void)testPNLockBasicAsyncRead {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"async-read"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async read completes"];

    [lock asyncReadAccessWithBlock:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testPNLockBasicAsyncWrite {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"async-write"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async write completes"];

    [lock asyncWriteAccessWithBlock:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testPNLockShorthandReadUsesSync {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"shorthand-read"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock"];
    __block BOOL executed = NO;

    [lock readAccessWithBlock:^{
        executed = YES;
    }];

    // readAccessWithBlock is synchronous, so it should have completed by now.
    XCTAssertTrue(executed, @"readAccessWithBlock should be synchronous.");
}

- (void)testPNLockShorthandWriteUsesAsync {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"shorthand-write"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Shorthand write completes"];

    [lock writeAccessWithBlock:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}


#pragma mark - Tests :: PNLock :: Contention

- (void)testPNLockMultipleThreadsCompeteForWriteAccess {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"contention-write"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock.contention"];
    __block _Atomic(int32_t) counter = 0;
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [lock syncWriteAccessWithBlock:^{
                atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
            }];
            dispatch_group_leave(group);
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"All write operations should complete without deadlock.");
    XCTAssertEqual(counter, iterations, @"All %d write blocks should have executed.", iterations);
}

- (void)testPNLockMultipleThreadsCompeteForReadAccess {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"contention-read"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock.contention"];
    __block _Atomic(int32_t) counter = 0;
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [lock syncReadAccessWithBlock:^{
                atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
            }];
            dispatch_group_leave(group);
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"All read operations should complete without deadlock.");
    XCTAssertEqual(counter, iterations, @"All %d read blocks should have executed.", iterations);
}


#pragma mark - Tests :: PNLock :: Read-Write pattern

- (void)testPNLockConcurrentReadsWithExclusiveWrites {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"rw-pattern"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock.rw"];
    __block NSMutableArray *sharedArray = [NSMutableArray new];
    int readIterations = 100;
    int writeIterations = 50;
    dispatch_group_t group = dispatch_group_create();

    // Launch concurrent reads.
    for (int i = 0; i < readIterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [lock syncReadAccessWithBlock:^{
                // Just read the count; should never see a partially modified array.
                __unused NSUInteger count = sharedArray.count;
            }];
            dispatch_group_leave(group);
        });
    }

    // Launch exclusive writes.
    for (int i = 0; i < writeIterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [lock syncWriteAccessWithBlock:^{
                [sharedArray addObject:@(i)];
            }];
            dispatch_group_leave(group);
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"All operations should complete without deadlock.");

    // Read the final state under the lock.
    __block NSUInteger finalCount;
    [lock syncReadAccessWithBlock:^{
        finalCount = sharedArray.count;
    }];
    XCTAssertEqual(finalCount, (NSUInteger)writeIterations, @"All writes should have been applied.");
}

- (void)testPNLockInterleavedReadsAndWrites {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"interleaved"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock.interleaved"];
    __block NSInteger sharedValue = 0;
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (i % 3 == 0) {
                [lock syncWriteAccessWithBlock:^{
                    sharedValue++;
                }];
            } else {
                [lock syncReadAccessWithBlock:^{
                    __unused NSInteger val = sharedValue;
                }];
            }
            dispatch_group_leave(group);
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"Interleaved reads and writes should complete without deadlock.");
}


#pragma mark - Tests :: PNLock :: Deadlock detection via timeout

- (void)testPNLockDoesNotDeadlockUnderContention {
    PNLock *lock = [PNLock lockWithIsolationQueueName:@"deadlock-test"
                             subsystemQueueIdentifier:@"com.pubnub.test.lock.deadlock"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"No deadlock under contention"];
    int iterations = 100;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (i % 2 == 0) {
                [lock syncWriteAccessWithBlock:^{
                    [NSThread sleepForTimeInterval:0.001];
                }];
            } else {
                [lock syncReadAccessWithBlock:^{
                    [NSThread sleepForTimeInterval:0.001];
                }];
            }
            dispatch_group_leave(group);
        });
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:30 handler:nil];
}


#pragma mark - Tests :: PNLock :: Multiple lock instances

- (void)testMultiplePNLockInstancesDoNotInterfere {
    PNLock *lockA = [PNLock lockWithIsolationQueueName:@"lockA"
                              subsystemQueueIdentifier:@"com.pubnub.test.lock.multi"];
    PNLock *lockB = [PNLock lockWithIsolationQueueName:@"lockB"
                              subsystemQueueIdentifier:@"com.pubnub.test.lock.multi"];
    __block _Atomic(int32_t) counterA = 0;
    __block _Atomic(int32_t) counterB = 0;
    int iterations = 100;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [lockA syncWriteAccessWithBlock:^{
                atomic_fetch_add_explicit(&counterA, 1, memory_order_relaxed);
            }];
            dispatch_group_leave(group);
        });

        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [lockB syncWriteAccessWithBlock:^{
                atomic_fetch_add_explicit(&counterB, 1, memory_order_relaxed);
            }];
            dispatch_group_leave(group);
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"All operations should complete.");
    XCTAssertEqual(counterA, iterations, @"Lock A operations should all complete.");
    XCTAssertEqual(counterB, iterations, @"Lock B operations should all complete.");
}


#pragma mark - Tests :: PNLockSupport :: Basic lock/unlock

- (void)testPNLockSupportBasicLockUnlock {
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    __block BOOL executed = NO;

    pn_lock(&mutex, ^{
        executed = YES;
    });

    XCTAssertTrue(executed, @"Block within pn_lock should execute.");
    pthread_mutex_destroy(&mutex);
}

- (void)testPNLockSupportTryLock {
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    __block BOOL executed = NO;

    pn_trylock(&mutex, ^{
        executed = YES;
    });

    XCTAssertTrue(executed, @"Block within pn_trylock should execute when lock is available.");
    pthread_mutex_destroy(&mutex);
}


#pragma mark - Tests :: PNLockSupport :: Contention

- (void)testPNLockSupportContention {
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    __block _Atomic(int32_t) counter = 0;
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            pn_lock(&mutex, ^{
                atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
            });
            dispatch_group_leave(group);
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"All pn_lock operations should complete.");
    XCTAssertEqual(counter, iterations, @"All %d blocks should have executed under pn_lock.", iterations);
    pthread_mutex_destroy(&mutex);
}

- (void)testPNLockSupportTryLockContention {
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    __block _Atomic(int32_t) counter = 0;
    int iterations = 200;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // trylock may skip the block if lock is held, but should not crash.
            pn_trylock(&mutex, ^{
                atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
            });
            dispatch_group_leave(group);
        });
    }

    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    XCTAssertEqual(result, 0, @"All pn_trylock operations should complete (even if some skipped).");
    // counter may be less than iterations because trylock can fail to acquire.
    XCTAssertGreaterThan(counter, 0, @"At least some trylock operations should succeed.");
    pthread_mutex_destroy(&mutex);
}


#pragma mark - Tests :: PNLockSupport :: Async lock

- (void)testPNLockSupportAsyncLock {
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async lock completes"];

    pn_lock_async(&mutex, ^(dispatch_block_t complete) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Simulate async work.
            [NSThread sleepForTimeInterval:0.01];
            complete();
            [expectation fulfill];
        });
    });

    [self waitForExpectationsWithTimeout:5 handler:nil];
    pthread_mutex_destroy(&mutex);
}

- (void)testPNLockSupportAsyncLockContention {
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    __block _Atomic(int32_t) counter = 0;
    int iterations = 50;
    XCTestExpectation *expectation = [self expectationWithDescription:@"All async lock operations complete"];
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            pn_lock_async(&mutex, ^(dispatch_block_t complete) {
                atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
                complete();
                dispatch_group_leave(group);
            });
        });
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:30 handler:nil];
    XCTAssertEqual(counter, iterations, @"All async lock blocks should execute.");
    pthread_mutex_destroy(&mutex);
}


#pragma mark - Tests :: PNLockSupport :: Deadlock detection

- (void)testPNLockSupportDoesNotDeadlockUnderContention {
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    XCTestExpectation *expectation = [self expectationWithDescription:@"No deadlock with pn_lock"];
    int iterations = 100;
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            pn_lock(&mutex, ^{
                [NSThread sleepForTimeInterval:0.001];
            });
            dispatch_group_leave(group);
        });
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:30 handler:nil];
    pthread_mutex_destroy(&mutex);
}


#pragma mark - Tests :: PNLockSupport :: Data integrity under mutex

- (void)testPNLockSupportProtectsSharedDataIntegrity {
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    NSMutableArray *sharedArray = [NSMutableArray new];
    __block _Atomic(int32_t) counter = 0;
    int iterations = 100;
    XCTestExpectation *expectation = [self expectationWithDescription:@"All lock operations complete"];
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < iterations; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            pn_lock(&mutex, ^{
                [sharedArray addObject:@(counter)];
                atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
            });
            dispatch_group_leave(group);
        });
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:30 handler:nil];
    XCTAssertEqual(counter, iterations, @"Counter should reach %d.", iterations);
    XCTAssertEqual(sharedArray.count, (NSUInteger)iterations,
                   @"Array should contain exactly %d elements without corruption.", iterations);
    pthread_mutex_destroy(&mutex);
}

#pragma mark -


@end
