#import "PNLock.h"
#import "PNFunctions.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNLock ()


#pragma mark - Properties

/// Isolation queue to protect ``PNLock`` shared resources.
///
/// ``PNLock`` track list of created subsystem queues, which is accessed from multiple thread when new lock
/// created. This queue allows making access safe to mutable map.
@property(class, strong, nonatomic, readonly) dispatch_queue_t sharedResourcesQueue;

/// Resources isolation queue.
///
/// Queue which is used to isolate resources accessed within GCD blocks provided by lock.
@property(strong, nonatomic) dispatch_queue_t queue;

/// Synchronous write lock status.
///
/// Stores whether currently synchronous write lock is active or not.
@property(assign, atomic, getter=isWriteLockAcquired) BOOL writeLockAcquired;


#pragma mark - Initialization and configuration

/// Initialize lock with name.
///
/// Lock allows protecting mutable resources, accessed from multiple thread on read and write. Lock
/// implemented as MRSW, which allows having multiple readers and single writer.
///
/// > Note: Implementation of this lock allows avoiding threads starvation issue by targeting single
/// concurrent subsystem queue (as target of named queue).
///
/// - Parameters:
///   - queueName: Name of shared resources isolation queue.
///   - queueIdentifier: Identifier of queue which used by subsystem.
/// - Returns: Shared resources lock.
- (instancetype)initWithIsolationQueueName:(NSString *)queueName
                  subsystemQueueIdentifier:(NSString *)queueIdentifier;


#pragma mark - Helpers

/// Retrieve concurrent queue for subsystem resources isolation.
///
/// - Parameter identifier: Identifier which is unique for an instance or set of instances in the subsystem.
/// - Returns: Concurrent isolation queue.
+ (dispatch_queue_t)subsystemQueueWithIdentifier:(NSString *)identifier;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNLock


#pragma mark - Properties

+ (dispatch_queue_t)sharedResourcesQueue {
    static dispatch_queue_t _sharedResourcesQueue;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedResourcesQueue = dispatch_queue_create("com.pubnub.core.lock-shared", DISPATCH_QUEUE_SERIAL);
    });

    return _sharedResourcesQueue;
}


#pragma mark - Initialization and configuration

+ (instancetype)lockWithIsolationQueueName:(NSString *)queueName
                  subsystemQueueIdentifier:(NSString *)queueIdentifier {
    return [[self alloc] initWithIsolationQueueName:queueName subsystemQueueIdentifier:queueIdentifier];
}

- (instancetype)initWithIsolationQueueName:(NSString *)queueName
                  subsystemQueueIdentifier:(NSString *)queueIdentifier {
    if ((self = [super init])) {
        NSString *label = [NSString stringWithFormat:@"%@.%@", queueIdentifier, queueName];
        const char *queueLabel = [label cStringUsingEncoding:NSUTF8StringEncoding];
        dispatch_queue_t targetQueue = [[self class] subsystemQueueWithIdentifier:queueIdentifier];
        self.queue = dispatch_queue_create_with_target(queueLabel, DISPATCH_QUEUE_CONCURRENT, targetQueue);
    }

    return self;
}


#pragma mark - Read / write locks

- (void)readAccessWithBlock:(dispatch_block_t)block {
    [self syncReadAccessWithBlock:block];
}

- (void)writeAccessWithBlock:(dispatch_block_t)block {
    [self asyncWriteAccessWithBlock:block];
}


#pragma mark - Synchronous read / write locks

- (void)syncReadAccessWithBlock:(dispatch_block_t)block {
    if (self.isWriteLockAcquired) {
        NSDictionary *userInfo = @{
            NSLocalizedRecoverySuggestionErrorKey: @"Exclusive lock already acquired and there is no need to "
                                                    "use -syncReadAccessWithBlock:."
        };
        @throw [NSException exceptionWithName:@"PNLockExclusiveWrite"
                                       reason:@"Deadlock prevention exception. Called from within write block"
                                     userInfo:userInfo];
    }

    dispatch_sync(self.queue, block);
}

- (void)syncWriteAccessWithBlock:(dispatch_block_t)block {
    dispatch_barrier_sync(self.queue, ^{
        self.writeLockAcquired = YES;
        block();
        self.writeLockAcquired = NO;
    });
}


#pragma mark - Asynchronous read / write locks

- (void)asyncReadAccessWithBlock:(dispatch_block_t)block {
    dispatch_async(self.queue, block);
}

- (void)asyncWriteAccessWithBlock:(dispatch_block_t)block {
    dispatch_barrier_async(self.queue, ^{
        self.writeLockAcquired = YES;
        block();
        self.writeLockAcquired = NO;
    });
}


#pragma mark - Helpers

+ (dispatch_queue_t)subsystemQueueWithIdentifier:(NSString *)identifier {
    static NSMapTable<NSString *,dispatch_queue_t> * _subsystemQueues;
    static dispatch_once_t onceToken;
    __block dispatch_queue_t queue;

    dispatch_once(&onceToken, ^{
        // Creating map with weak objects to make it possible for queue to be removed from list, when last
        // reference on lock which use this subsystem queue will be released.
        // Because queues created with `dispatch_queue_create_with_target`, it will keep subsystem queue
        // valid.
        _subsystemQueues = [NSMapTable strongToWeakObjectsMapTable];
    });

    dispatch_sync(self.sharedResourcesQueue, ^{
        queue = [_subsystemQueues objectForKey:identifier];

        if (!queue) {
            const char *queueIdentifier = [identifier cStringUsingEncoding:NSUTF8StringEncoding];
            queue = dispatch_queue_create(queueIdentifier, DISPATCH_QUEUE_CONCURRENT);
            [_subsystemQueues setObject:queue forKey:identifier];
        }
    });

    return queue;
}

#pragma mark -


@end
