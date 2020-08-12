/**
 * @author Serhii Mamontov
 * @version 4.15.3
 * @since 4.15.3
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNKeychainStorage.h"
#import "PNKeychain+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNKeychainStorage ()


#pragma mark - Information

/**
 * @brief Shared Keychain resources access queue.
 */
@property (nonatomic, strong) dispatch_queue_t resourcesAccessQueue;

/**
 * @brief \a Keychain which is managed by this storage.
 */
@property (nonatomic, strong) PNKeychain *keychain;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialise \c key/value Keychain storage.
 *
 * @param identifier Unique identifier with which managed values should be \c "linked".
 * @param queue Resources access serialisation queue. 
 *
 * @return Initialised and ready to use \c key/value Keychain storage.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier queue:(dispatch_queue_t)queue;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNKeychainStorage


#pragma mark - Initialization & Configuration

+ (instancetype)storageWithIdentifier:(NSString *)identifier queue:(dispatch_queue_t)queue {
    return [[self alloc] initWithIdentifier:identifier queue:queue];
}

- (instancetype)initWithIdentifier:(NSString *)identifier queue:(dispatch_queue_t)queue {
    if ((self = [super init])) {
        _keychain = [PNKeychain keychainWithIdentifier:identifier];
        _resourcesAccessQueue = queue;
        
        if (!PNKeychain.defaultKeychain.resourceAccessQueue) {
            PNKeychain.defaultKeychain.resourceAccessQueue = queue;
        }
    }
    
    return self;
}


#pragma mark - Batch

- (void)batchSyncAccessWithBlock:(dispatch_block_t)block {
    dispatch_barrier_sync(self.resourcesAccessQueue, block);
}

- (void)batchAsyncAccessWithBlock:(void(^)(dispatch_block_t completion))block {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_barrier_async(self.resourcesAccessQueue, ^{
        block(^{
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC));
        dispatch_semaphore_wait(semaphore, popTime);
    });
}


#pragma mark - Value store

- (BOOL)storeValue:(id)value forKey:(NSString *)key {
    BOOL updated = NO;
    
    if (value) {
        updated = [self.keychain storeValue:value forKey:key];
    } else {
        updated = [self.keychain removeValueForKey:key];
    }
    
    return updated;
}

- (BOOL)syncStoreValue:(id)value forKey:(NSString *)key {
    __block BOOL updated = NO;
    
    dispatch_barrier_sync(self.resourcesAccessQueue, ^{
        updated = [self storeValue:value forKey:key];
    });
    
    return updated;
}

- (void)asyncStoreValue:(id)value forKey:(NSString *)key withCompletion:(void(^)(BOOL stored))block {
    dispatch_barrier_async(self.resourcesAccessQueue, ^{
        BOOL updated = [self storeValue:value forKey:key];
        
        if (block) {
            block(updated);
        }
    });
}


#pragma mark - Value read

- (id)valueForKey:(NSString *)key {
    return [self.keychain valueForKey:key];
}

- (id)syncValueForKey:(NSString *)key {
    __block id value = nil;
    
    dispatch_sync(self.resourcesAccessQueue, ^{
        value = [self valueForKey:key];
    });
    
    return value;
}

- (void)asyncValueForKey:(NSString *)key withCompletion:(void(^)(id value))block {
    dispatch_async(self.resourcesAccessQueue, ^{
        block([self valueForKey:key]);
    });
}


#pragma mark - Data storage

- (void)updateEntries:(NSArray<NSString *> *)entryNames accessibilityTo:(CFStringRef)accessibility {
    dispatch_barrier_async(self.resourcesAccessQueue, ^{
        [self.keychain updateEntries:entryNames accessibilityTo:accessibility];
    });
}

#pragma mark -


@end
