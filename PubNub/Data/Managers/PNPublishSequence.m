#import "PNPublishSequence.h"
#import "PNPrivateStructures.h"
#import "PNConfiguration.h"
#import "PubNub+Core.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNPublishSequence ()


#pragma mark - Information

/// Queue which is used to serialize access to shared client state information.
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/// Whether stored sequence number for `publishKey` has been changed or not.
@property (nonatomic, assign) BOOL sequenceNumberChanged;

/// Sequence number which has been used for recent message publish API usage.
@property (nonatomic, assign) NSUInteger sequenceNumber;


#pragma mark - Initialization and Configuration

/// Dictionary which store initialized publish sequence number managers.
///
/// - Returns: Dictionary where publish sequence numbers stored under publish keys which is used for **PubNub** client
/// configuration.
+ (NSMutableDictionary<NSString *, PNPublishSequence *> *)sequenceManagers;

/// Initialize published messages sequence manager.
///
/// - Parameter client: Client for which published messages sequence manager should be created.
/// - Returns: Initialized and ready to use client published messages sequence manager.
- (instancetype)initForClient:(PubNub *)client;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPublishSequence


#pragma mark - Information

- (NSUInteger)sequenceNumber {
    __block NSUInteger sequenceNumber = 0;

    dispatch_sync(self.resourceAccessQueue, ^{
        sequenceNumber = self->_sequenceNumber;
    });
    
    return sequenceNumber;
}

- (NSUInteger)nextSequenceNumber:(BOOL)shouldUpdateCurrent {
    __block NSUInteger sequenceNumber = 0;

    dispatch_block_t block = ^{
        sequenceNumber = self->_sequenceNumber == NSUIntegerMax ? 1 : self->_sequenceNumber + 1;

        if (shouldUpdateCurrent) {
            self->_sequenceNumber = sequenceNumber;
            self->_sequenceNumberChanged = YES;
        }
    };

    if (shouldUpdateCurrent) dispatch_barrier_sync(self.resourceAccessQueue, block);
    else dispatch_sync(self.resourceAccessQueue, block);
    
    return sequenceNumber;
}


#pragma mark - Initialization and Configuration

+ (instancetype)sequenceForClient:(PubNub *)client {
    PNPublishSequence *manager = nil;
    NSMutableDictionary<NSString *, PNPublishSequence *> *sequenceManagers = [self sequenceManagers];
    
    @synchronized (sequenceManagers) {
        manager = sequenceManagers[client.currentConfiguration.publishKey];
        
        if (!manager) {
            manager = [[self alloc] initForClient:client];
            sequenceManagers[client.currentConfiguration.publishKey] = manager;
        }
    }
    
    return manager;
}

+ (NSMutableDictionary<NSString *, PNPublishSequence *> *)sequenceManagers {
    static NSMutableDictionary<NSString *, PNPublishSequence *> *_sharedSequenceManagers;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedSequenceManagers = [NSMutableDictionary new];
    });
    
    return _sharedSequenceManagers;
}

- (instancetype)initForClient:(PubNub *)client {
    if ((self = [super init])) {
        const char *queueIdentifier = "com.pubnub.publish-sequence";
        _resourceAccessQueue = dispatch_queue_create(queueIdentifier, DISPATCH_QUEUE_CONCURRENT);
        dispatch_set_target_queue(_resourceAccessQueue, NULL);
    }
    
    return self;
}

- (void)reset {
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        self->_sequenceNumberChanged = YES;
        self->_sequenceNumber = 0;
    });
}

#pragma mark -


@end
    
