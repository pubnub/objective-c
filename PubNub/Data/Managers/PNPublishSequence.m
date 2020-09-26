/**
 * @author Sergey Mamontov
 * @version 4.15.3
 * @since 4.5.2
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNPublishSequence.h"
#import "PNPrivateStructures.h"
#import "PNKeychain+Private.h"
#import "PNDataStorage.h"

#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
    #import <AppKit/AppKit.h>
#endif // TARGET_OS_OSX

#import "PNConfiguration.h"
#import "PubNub+Core.h"
#import "PNKeychain.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Static

NSString * const kPNPublishSequenceDataKey = @"pn_publishSequence";

/**
 * @brief Maximum age of \c publish key inactivity after which it will be removed and count for it
 * will be reset to \b 0.
 *
 * @note \b Default: 30 days
 */
static NSUInteger const kPNMaximumPublishSequenceDataAge = (30 * 24 * 60 * 60);


#pragma mark - Structures

/**
 * @brief Storable sequence manager data structure.
 */
struct PNPublishSequenceDataStructure {
    /**
     * @brief Key under which stored date when sequence last has been re-saved / modified.
     */
    __unsafe_unretained NSString *lastSaveDate;
    
    /**
     * @brief Key under which stored last saved sequence number value.
     */
    __unsafe_unretained NSString *sequence;
};

struct PNPublishSequenceDataStructure PNPublishSequenceData = {
    .lastSaveDate = @"sd",
    .sequence = @"sn"
};


#pragma mark - Protected interface declaration

@interface PNPublishSequence ()


#pragma mark - Information

/**
 * @brief Queue which is used to serialize access to shared client state information.
 *
 * @since 4.15.3
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief Storage which is used to store information about current publish sequence number.
 *
 * @since 4.15.3
 */
@property (nonatomic, strong) id<PNKeyValueStorage> dataStorage;

/**
 * @brief Sequence number which has been used for recent message publish API usage.
 */
@property (nonatomic, assign) NSUInteger sequenceNumber;

/**
 * @brief Whether stored sequence number for \b publishKey has been changed or not.
 */
@property (nonatomic, assign) BOOL sequenceNumberChanged;


#pragma mark - Initialization and Configuration

/**
 * @brief Dictionary which store initialized publish sequence number managers.
 *
 * @return Dictionary where publish sequence numbers stored under publish keys which is used for
 * \b PubNub client configuration.
 */
+ (NSMutableDictionary<NSString *, PNPublishSequence *> *)sequenceManagers;

/**
 * @brief Initialize published messages sequence manager.
 *
 * @param client Client for which published messages sequence manager should be created.
 *
 * @return Initialized and ready to use client published messages sequence manager.
 */
- (instancetype)initForClient:(PubNub *)client;


#pragma mark - Data storage

/**
 * @brief Fetch sequence information from \b Keychain.
 */
- (void)loadFromPersistentStorage;

/**
 * @brief Store in-memory sequence information to \b Keychain.
 */
- (void)saveToPersistentStorage;

/**
 * @brief Clean-up sequence information from information about \c old publish keys.
 */
- (void)cleanUpIfRequired;


#pragma mark - Storage

/**
 * @brief Migrate previously stored client data in default storage to new one (identifier-based storage).
 *
 * @param identifier Unique identifier of storage to which information should be moved from default storage.
 */
- (void)migrateDefaultToStorageWithIdentifier:(NSString *)identifier;


#pragma mark - Handlers

/**
 * @brief Handle application transition between different execution contexts.
 *
 * @param notification Notification which triggered callback.
 */
- (void)handleContextTransition:(NSNotification *)notification;


#pragma mark - Misc

/**
 * @brief Subscribe to application context change notifications.
 *
 * @discussion Context change allow to react and if required save sequence data information into
 * persistent storage.
 */
- (void)subscribeOnNotifications;

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

    if (shouldUpdateCurrent) {
        dispatch_barrier_sync(self.resourceAccessQueue, block);
    } else {
        dispatch_sync(self.resourceAccessQueue, block);
    }
    
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
        NSString *subscribeKey = client.currentConfiguration.subscribeKey;
        NSString *publishKey = client.currentConfiguration.publishKey;
        NSString *storageIdentifier = publishKey ?: subscribeKey;
        [self migrateDefaultToStorageWithIdentifier:storageIdentifier];
        
        const char *queueIdentifier = "com.pubnub.publish-sequence";
        _resourceAccessQueue = dispatch_queue_create(queueIdentifier, DISPATCH_QUEUE_CONCURRENT);
        dispatch_set_target_queue(_resourceAccessQueue, NULL);
        
        _dataStorage = [PNDataStorage persistentClientDataWithIdentifier:storageIdentifier];
        
        [self loadFromPersistentStorage];
        [self cleanUpIfRequired];
        [self subscribeOnNotifications];
    }
    
    return self;
}

- (void)reset {
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        self->_sequenceNumberChanged = YES;
        self->_sequenceNumber = 0;
    });
    
    [self saveToPersistentStorage];
}


#pragma mark - Data storage

- (void)loadFromPersistentStorage {
    NSString *key = kPNPublishSequenceDataKey;
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        [self.dataStorage batchAsyncAccessWithBlock:^(dispatch_block_t completion) {
            NSMutableDictionary *sequenceData = [([self.dataStorage valueForKey:key]?: @{}) mutableCopy];
            NSNumber *sequenceNumber = (NSNumber *)sequenceData[PNPublishSequenceData.sequence];
            sequenceData[PNPublishSequenceData.lastSaveDate] = @([NSDate date].timeIntervalSince1970);
            self->_sequenceNumber = sequenceNumber.unsignedIntegerValue;
            
            [self.dataStorage storeValue:sequenceData forKey:key];
            completion();
        }];
    });
}

- (void)saveToPersistentStorage {
    NSString *key = kPNPublishSequenceDataKey;
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        if (!self.sequenceNumberChanged) {
            return;
        }
        
        self.sequenceNumberChanged = NO;
        
        [self.dataStorage batchAsyncAccessWithBlock:^(dispatch_block_t completion) {
            NSMutableDictionary *sequenceData = [([self.dataStorage valueForKey:key]?: @{}) mutableCopy];
            sequenceData[PNPublishSequenceData.sequence] = @(self->_sequenceNumber);
            sequenceData[PNPublishSequenceData.lastSaveDate] = @([NSDate date].timeIntervalSince1970);
            
            [self.dataStorage storeValue:sequenceData forKey:key];
            completion();
        }];
    });
}

- (void)cleanUpIfRequired {
    NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
    NSString *key = kPNPublishSequenceDataKey;
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        [self.dataStorage batchAsyncAccessWithBlock:^(dispatch_block_t completion) {
            NSMutableDictionary *sequenceData = [self.dataStorage valueForKey:key];
            
            NSNumber *lastUpdateDate = sequenceData[PNPublishSequenceData.lastSaveDate];
            NSTimeInterval lastUpdateTimestamp = lastUpdateDate.doubleValue;
            
            if (ABS(currentTimestamp - lastUpdateTimestamp) > kPNMaximumPublishSequenceDataAge) {
                [self.dataStorage storeValue:nil forKey:key];
            }
            
            completion();
        }];
    });
}


#pragma mark - Storage

- (void)migrateDefaultToStorageWithIdentifier:(NSString *)identifier {
    id<PNKeyValueStorage> storage = [PNDataStorage persistentClientDataWithIdentifier:identifier];
    PNKeychain *defaultKeychain = PNKeychain.defaultKeychain;
    
    NSDictionary *sequenceData = [defaultKeychain valueForKey:kPNPublishSequenceDataKey];
    
    if (sequenceData.count) {
        sequenceData = sequenceData[sequenceData.allKeys.lastObject];
        
        /**
         * 'sequenceData' expected to be dictionary which stored some metrics for specific publish key.
         */
        if ([sequenceData isKindOfClass:[NSDictionary class]]) {
            [storage syncStoreValue:sequenceData forKey:kPNPublishSequenceDataKey];
        }
        
        [defaultKeychain removeValueForKey:kPNPublishSequenceDataKey];
    }
}


#pragma mark - Handlers

- (void)handleContextTransition:(NSNotification *)notification {
    [self saveToPersistentStorage];
}


#pragma mark - Misc

- (void)subscribeOnNotifications {
#if TARGET_OS_IOS
    NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
    
    [notificationCenter addObserver:self
                           selector:@selector(handleContextTransition:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(handleContextTransition:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
#elif TARGET_OS_WATCH
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleContextTransition:)
                               name:NSExtensionHostWillResignActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(handleContextTransition:)
                               name:NSExtensionHostDidEnterBackgroundNotification
                             object:nil];
#elif TARGET_OS_OSX
    NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleContextTransition:)
                               name:NSWorkspaceWillSleepNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(handleContextTransition:)
                               name:NSWorkspaceSessionDidResignActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(handleContextTransition:)
                               name:NSWorkspaceDidDeactivateApplicationNotification
                             object:nil];
#endif // TARGET_OS_OSX
}

#pragma mark -


@end
    
