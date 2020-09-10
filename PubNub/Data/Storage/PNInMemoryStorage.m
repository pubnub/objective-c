/**
 * @author Serhii Mamontov
 * @version 4.15.4
 * @since 4.15.3
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNInMemoryStorage.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNInMemoryStorage ()


#pragma mark - Information

/**
 * @brief Dictionary which is used to keep values stored by multiple sessions of \b PubNub client.
 *
 * @since 4.15.4
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *sharedStorage;

/**
 * @brief Shared in-memory resources access queue.
 */
@property (nonatomic, strong) dispatch_queue_t resourcesAccessQueue;

/**
 * @brief Dictionary which is used to keep values stored during \b PubNub client usage.
 */
@property (nonatomic, strong) NSMutableDictionary *storage;

/**
 * @brief Unique identifier for storage which should be \c "linked" with managed values.
 */
@property (nonatomic, copy) NSString *storageIdentifier;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialise \c key/value in-memory storage.
 *
 * @param identifier Unique identifier with which managed values should be \c "linked".
 * @param queue Resources access serialisation queue.
 *
 * @return Initialised and ready to use \c key/value in-memory storage.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier queue:(dispatch_queue_t)queue;


#pragma mark - Misc

/**
 * @brief Location where macOS in-memory storage content should be stored / loaded to / from.
 *
 * @return Full path to the file.
 */
- (NSString *)storagePath;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNInMemoryStorage


#pragma mark - Information

- (NSMutableDictionary *)sharedStorage {
    static NSMutableDictionary *_sharedInMemoryStorage;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
#if !TARGET_OS_OSX
        _sharedInMemoryStorage = [NSMutableDictionary new];
#else
        NSFileManager *fileManager = NSFileManager.defaultManager;
        NSString *filePath = [self storagePath];
        NSString *workingDirectory = [filePath stringByDeletingLastPathComponent];
        
        if (![fileManager fileExistsAtPath:workingDirectory isDirectory:NULL]) {
            [fileManager createDirectoryAtPath:workingDirectory
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
        
        NSDictionary *storedData = [NSDictionary dictionaryWithContentsOfFile:filePath];
        _sharedInMemoryStorage = [NSMutableDictionary dictionaryWithDictionary:storedData];
        
        // Migrate previous
        if (!((NSDictionary *)_sharedInMemoryStorage[self.storageIdentifier]).count &&
            !_sharedInMemoryStorage[@"pn_storage_migrated"]) {
            
            NSMutableDictionary *storage = [NSMutableDictionary new];
            
            for (NSString *key in _sharedInMemoryStorage) {
                storage[key] = _sharedInMemoryStorage[key];
            }
            
            [_sharedInMemoryStorage removeAllObjects];
            _sharedInMemoryStorage[self.storageIdentifier] = storage;
            _sharedInMemoryStorage[@"pn_storage_migrated"] = @YES;
            
            [_sharedInMemoryStorage writeToFile:filePath atomically:YES];
        }
#endif
    });
    
    return _sharedInMemoryStorage;
}


#pragma mark - Initialization & Configuration

+ (instancetype)storageWithIdentifier:(NSString *)identifier queue:(dispatch_queue_t)queue {
    return [[self alloc] initWithIdentifier:identifier queue:queue];
}

- (instancetype)initWithIdentifier:(NSString *)identifier queue:(dispatch_queue_t)queue {
    if ((self = [super init])) {
        _storageIdentifier = [identifier copy];
        _storage = self.sharedStorage[_storageIdentifier];
        _resourcesAccessQueue = queue;
        
        if (!_storage) {
            _storage = [NSMutableDictionary new];
            self.sharedStorage[_storageIdentifier] = _storage;
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
    if (value) {
        self.storage[key] = value;
    } else {
        [self.storage removeObjectForKey:key];
    }
                
#if TARGET_OS_OSX
    [self.sharedStorage writeToFile:[self storagePath] atomically:YES];
#endif // TARGET_OS_OSX
    
    return YES;
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
    return self.storage[key];
}

- (nullable id)syncValueForKey:(NSString *)key {
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


#pragma mark - Misc

- (NSString *)storagePath {
    static NSString *_inMemoryStoragePath;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSSearchPathDirectory searchPath = NSApplicationSupportDirectory;
        NSProcessInfo *processInfo = NSProcessInfo.processInfo;
        NSBundle *mainBundle = NSBundle.mainBundle;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
        
        NSString *baseDirectory = (paths.count > 0 ? paths.firstObject : NSTemporaryDirectory());
        NSString *applicationName = processInfo.processName ?: mainBundle.bundleIdentifier;
        
        NSString *storeDirectory = [baseDirectory stringByAppendingPathComponent:applicationName];
        _inMemoryStoragePath = [storeDirectory stringByAppendingPathComponent:@"pnkc.db"];
    });
    
    return _inMemoryStoragePath;
}

#pragma mark -


@end
