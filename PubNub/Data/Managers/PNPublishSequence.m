/**
 * @author Sergey Mamontov
 * @version 4.11.0
 * @since 4.5.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNPublishSequence.h"

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

/**
 * @brief Key under which in Keychain stored information about previously used sequence number for
 * message publish.
 */
static NSString * const kPNPublishSequenceDataKey = @"pn_publishSequence";

/**
 * @brief Maximum age of \c publish key inactivity after which it will be removed and count for it
 * will be reset to \b 0.
 *
 * @note \b Default: 30 days
 */
static NSUInteger const kPNMaximumPublishSequenceDataAge = (30 * 24 * 60 * 60);

/**
 * @brief Spin-lock which is used to protect access to shared resources from multiple threads.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
static os_unfair_lock publishSequenceKeychainAccessLock = OS_UNFAIR_LOCK_INIT;
#pragma clang diagnostic pop


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


#pragma mark - Private interface declaration

@interface PNPublishSequence () {
    /**
     * @brief Spin-lock which is used to protect access to current message sequence number which can
     * be changed at any moment.
     */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
    os_unfair_lock _lock;
#pragma clang diagnostic pop
}


#pragma mark - Information

/**
 * @brief Client for which state cache manager created.
 */
@property (nonatomic, weak) PubNub *client;

/**
 * @brief Sequence number which has been used for recent message publish API usage.
 */
@property (nonatomic, assign) NSUInteger sequenceNumber;

/**
 * @brief Whether stored sequence number for \b publishKey has been changed or not.
 */
@property (nonatomic, assign) BOOL sequenceNumberChanged;

/**
 * @brief Current \b PubNub client publish key.
 */
@property (nonatomic, copy) NSString *publishKey;


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
    
    pn_lock(&_lock, ^{
        sequenceNumber = self->_sequenceNumber;
    });
    
    return sequenceNumber;
}

- (NSUInteger)nextSequenceNumber:(BOOL)shouldUpdateCurrent {
    __block NSUInteger sequenceNumber = 0;
    
    pn_lock(&_lock, ^{
        sequenceNumber = self->_sequenceNumber == NSUIntegerMax ? 1 : self->_sequenceNumber + 1;
        
        if (shouldUpdateCurrent) {
            self->_sequenceNumber = sequenceNumber;
            self->_sequenceNumberChanged = YES;
        }
    });
    
    return sequenceNumber;
}

- (BOOL)sequenceNumberChanged {
    __block BOOL sequenceNumberChanged = 0;
    
    pn_lock(&_lock, ^{
        sequenceNumberChanged = self->_sequenceNumberChanged;
    });
    
    return sequenceNumberChanged;
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
        } else {
            manager.client = client;
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
        _client = client;
        _publishKey = client.currentConfiguration.publishKey;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
        _lock = OS_UNFAIR_LOCK_INIT;
#pragma clang diagnostic pop
        
        [self loadFromPersistentStorage];
        [self cleanUpIfRequired];
        [self subscribeOnNotifications];
    }
    
    return self;
}

- (void)reset {
    pn_lock(&_lock, ^{
        self->_sequenceNumberChanged = YES;
        self->_sequenceNumber = 0;
    });
    
    [self saveToPersistentStorage];
}


#pragma mark - Data storage

- (void)loadFromPersistentStorage {
    pn_lock_async(&publishSequenceKeychainAccessLock, ^(dispatch_block_t completion) {
        [PNKeychain valueForKey:kPNPublishSequenceDataKey
            withCompletionBlock:^(NSDictionary *sequences) {
            
            NSMutableDictionary *mutableSequences = [(sequences?: @{}) mutableCopy];
            NSMutableDictionary *sequenceData = [(mutableSequences[self.publishKey]?: @{}) mutableCopy];
            NSNumber *sequenceNumber = (NSNumber *)sequenceData[PNPublishSequenceData.sequence];
            sequenceData[PNPublishSequenceData.lastSaveDate] = @([NSDate date].timeIntervalSince1970);
            self->_sequenceNumber = sequenceNumber.unsignedIntegerValue;
            
            [PNKeychain storeValue:mutableSequences
                            forKey:kPNPublishSequenceDataKey
               withCompletionBlock:^(BOOL stored) {
                   
                   completion();
               }];
        }];
    });
}

- (void)saveToPersistentStorage {
    if (!self.sequenceNumberChanged) {
        return;
    }

    pn_lock(&_lock, ^{
        self->_sequenceNumberChanged = NO;
    });
    
    pn_lock_async(&publishSequenceKeychainAccessLock, ^(dispatch_block_t completion) {
        [PNKeychain valueForKey:kPNPublishSequenceDataKey
            withCompletionBlock:^(NSDictionary *sequences) {
                
            NSMutableDictionary *mutableSequences = [(sequences?: @{}) mutableCopy];
            NSMutableDictionary *sequenceData = [(mutableSequences[self.publishKey]?: @{}) mutableCopy];
            sequenceData[PNPublishSequenceData.sequence] = @(self.sequenceNumber);
            sequenceData[PNPublishSequenceData.lastSaveDate] = @([NSDate date].timeIntervalSince1970);
            mutableSequences[self.publishKey] = sequenceData;
            
            [PNKeychain storeValue:mutableSequences
                            forKey:kPNPublishSequenceDataKey
               withCompletionBlock:^(BOOL stored) {
                   
                   completion();
               }];
        }];
    });
}

- (void)cleanUpIfRequired {
    NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
    
    pn_lock_async(&publishSequenceKeychainAccessLock, ^(dispatch_block_t completion) {
        [PNKeychain valueForKey:kPNPublishSequenceDataKey withCompletionBlock:^(NSDictionary *sequences) {
            
            NSMutableDictionary *mutableSequences = [(sequences?: @{}) mutableCopy];
            [mutableSequences enumerateKeysAndObjectsUsingBlock:^(NSString *publishKey,
                                                                  NSDictionary *sequenceData,
                                                                  BOOL *sequencesEnumeratorStop) {
                
                if (![publishKey isEqualToString:self.publishKey]) {
                    NSNumber *lastUpdateDate = sequenceData[PNPublishSequenceData.lastSaveDate];
                    NSTimeInterval lastUpdateTimestamp = lastUpdateDate.doubleValue;
                    
                    if (ABS(currentTimestamp - lastUpdateTimestamp) > kPNMaximumPublishSequenceDataAge) {
                        mutableSequences[publishKey] = nil;
                    }
                }
            }];
            
            [PNKeychain storeValue:mutableSequences
                            forKey:kPNPublishSequenceDataKey
               withCompletionBlock:^(BOOL stored) {
                   
                   completion();
               }];
        }];
    });
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
    
