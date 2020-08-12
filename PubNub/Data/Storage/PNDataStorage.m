/**
 * @brief \b PubNub client data storage provider.
 *
 * @author Serhii Mamontov
 * @version 4.15.3
 * @since 4.15.3
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNDataStorage.h"
#import "PNKeychain+Private.h"
#import "PNKeychainStorage.h"
#import "PNInMemoryStorage.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNDataStorage ()


#pragma mark - Information

/**
 * @brief Queue which is used to synchronise access to shared resources.
 *
 * @note Queue used indirectly as target queue for storage components.
 */
@property (class, nonatomic, readonly, strong) dispatch_queue_t resourcesAccessQueue;

/**
 * @brief Dictionary which is used to store previously initialised storages.
 */
@property (class, nonatomic, readonly, strong) NSMutableDictionary *storages;


#pragma mark - Misc

/**
 * @brief Generate unique \c storage instance store identifier.
 *
 * @param identifier Unique identifier from which portion should be cut out to build new identifier.
 * @param type Type of storage for which identifier should be created.
 *
 * @return Storage identifier.
 */
+ (NSString *)identifierFrom:(NSString *)identifier forStorageWithType:(NSString *)type;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNDataStorage


#pragma mark - Information

+ (dispatch_queue_t)resourcesAccessQueue {
    static dispatch_queue_t _sharedDataStorageAccessQueue;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        const char *queueIdentifier = "com.pubnub.data-storage.shared-queue";
        _sharedDataStorageAccessQueue = dispatch_queue_create(queueIdentifier,
                                                              DISPATCH_QUEUE_CONCURRENT);
    });

    return _sharedDataStorageAccessQueue;
}

+ (NSMutableDictionary *)storages {
    static NSMutableDictionary *_sharedStorageInstances;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedStorageInstances = [NSMutableDictionary new];
    });
    
    return _sharedStorageInstances;
}


#pragma mark - Initialization and Configuration

+ (id<PNKeyValueStorage>)persistentClientDataWithIdentifier:(NSString *)identifier {
    NSString *storageIdentifier = [self identifierFrom:identifier forStorageWithType:@"clientData"];
    id storage = nil;
    
    @synchronized ([self storages]) {
        storage = [self storages][storageIdentifier];
        
        if (!storage) {
#if !TARGET_OS_OSX
            if ([PNKeychain isKeychainAvailable]) {
                const char *queueIdentifier = "com.pubnub.data-storage.keychain";
                dispatch_queue_t queue = dispatch_queue_create(queueIdentifier,
                                                               DISPATCH_QUEUE_CONCURRENT);
                dispatch_set_target_queue(queue, self.resourcesAccessQueue);
                
                storage = [PNKeychainStorage storageWithIdentifier:storageIdentifier queue:queue];
            } else {
                const char *queueIdentifier = "com.pubnub.data-storage.in-memory";
                dispatch_queue_t queue = dispatch_queue_create(queueIdentifier,
                                                               DISPATCH_QUEUE_CONCURRENT);
                dispatch_set_target_queue(queue, self.resourcesAccessQueue);
                
                storage = [PNInMemoryStorage storageWithIdentifier:storageIdentifier queue:queue];
            }
#else
            const char *queueIdentifier = "com.pubnub.data-storage.in-memory";
            dispatch_queue_t queue = dispatch_queue_create(queueIdentifier,
                                                           DISPATCH_QUEUE_CONCURRENT);
            dispatch_set_target_queue(queue, self.resourcesAccessQueue);
                
            storage = [PNInMemoryStorage storageWithIdentifier:storageIdentifier queue:queue];
#endif // TARGET_OS_OSX
        }
        
        [self storages][storageIdentifier] = storage;
    }
    
    return storage;
}


#pragma mark - Misc

+ (NSString *)identifierFrom:(NSString *)identifier forStorageWithType:(NSString *)type {
    NSArray<NSString *> *identifiedComponents;
    
    if (identifier.length > 10) {
        identifiedComponents = @[
            [identifier substringToIndex:7],
            type,
            [identifier substringFromIndex:(identifier.length - 4)]
        ];
    } else {
        identifiedComponents = @[type, identifier];
    }
    
    return [identifiedComponents componentsJoinedByString:@"-"];
}

#pragma mark -


@end
