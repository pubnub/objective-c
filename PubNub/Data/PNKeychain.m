/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNKeychain+Private.h"
#import <Security/Security.h>
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNKeychain ()


#pragma mark - Information

/**
 * @brief Shared \a Keychain resources access serialisation queue.
 *
 * @note Queue used only by \c defaultKeychain.
 *
 * @since 4.15.3
 */
@property (nonatomic, nullable, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief Identifier which is used to scope stored data.
 */
@property (nonatomic, copy) NSString *serviceIdentifier;



#pragma mark - Initialization & Configuration

/**
 * @brief Initialise \a Keychain access helper.
 *
 * @param identifier Unique identifier which will be used to scope data in different "keychains" (used as service identifier).
 *
 * @return Initialised and ready to use \c Keychain access helper.
 *
 * @since 4.15.3
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;


#pragma mark - Storage

/**
 * @brief Storage which is used for environment where Keychain access DB not available.
 *
 * @discussion In multi-user systems before user authorise system is unable to provide information about Keychain because it
 *   doesn't know for which user. Used only by macOS because iOS is always single user.
 *
 * @return \a NSDictionary which should be used as temporary in-memory Keychain access DB replacement.
 *
 * @since 4.6.2
 */
- (NSMutableDictionary *)inMemoryStorage;


#pragma mark - Keychain query

/**
 * @brief Help to debug Keychain query error status.
 *
 * @param status One of \c OSStatus types.
 */
- (void)debugKeychainQueryStatus:(OSStatus)status;

/**
 * @brief Check whether item described with query already exist in Keychain or not.
 *
 * @param query \a NSDictionary which contain base item information which should be checked.
 *
 * @return \c YES in case if \a Keychain entry found with specified \c query.
 */
- (BOOL)checkExistingDataWithQuery:(NSMutableDictionary *)query;

/**
 * @brief Allow to search for item in Keychain and if requested will pull out values which it stores.
 *
 * @param query \a NSDictionary which contain base item information which should be found.
 * @param shouldFetchData Flag which specify whether item's data should be returned or not.
 *
 * @return Array of two elements where first is value and second is boolean on whether request failed or not (request also failed in
 * case if array contains only one boolean \b true value).
 */
- (NSArray *)searchWithQuery:(NSMutableDictionary *)query fetchData:(BOOL)shouldFetchData;

/**
 * @brief Update item value.
 *
 * @param value Value which should be stored for the item in Keychain.
 * @param query \a NSDictionary which contain base item information which should be updated.
 *
 * @return \c YES in case if value update was successful.
 */
- (BOOL)update:(nullable id)value usingQuery:(NSMutableDictionary *)query;


#pragma mark - Keychain data archiving

/**
 * @brief Allow to pack passed value to bytes.
 *
 * @discussion This method is used to store values in Keychain which accept only binaries for value.
 *
 * @param data Object which should be packed to binary.
 *
 * @return Packed binary object.
 */
- (NSData *)packedData:(id)data;

/**
 * @brief Allow to unpack stored value to native objects.
 *
 * @discussion This method is used to extract data stored in Keychain and return native objects.
 *
 * @param data Binary object which should be unpacked.
 *
 * @return Unpacked foundation object.
 */
- (id)unpackedData:(NSData *)data;


#pragma mark - Misc

/**
 * @brief Location where Keychain replacement for macOS will be stored.
 *
 * @return Full path to the file.
 *
 * @since 4.8.1
 */
- (NSString *)fileBasedStoragePath;

/**
 * @brief Construct dictionary which will describe item storage or access information.
 *
 * @param key Key under which item should be stored or searched.
 *
 * @return Prepared base item description.
 */
- (NSMutableDictionary *)baseInformationForItemWithKey:(NSString *)key;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNKeychain


#pragma mark - Information

+ (PNKeychain *)defaultKeychain {
    static PNKeychain *_sharedDefaultKeychain;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedDefaultKeychain = [self keychainWithIdentifier:NSBundle.mainBundle.bundleIdentifier];
    });
    
    return _sharedDefaultKeychain;
}


#pragma mark - Initialization & Configuration

+ (instancetype)keychainWithIdentifier:(NSString *)identifier {
    return [[self alloc] initWithIdentifier:identifier];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if ((self = [super init])) {
        _serviceIdentifier = [identifier copy];
        
        if (NSClassFromString(@"XCTestExpectation")) {
            _serviceIdentifier = @"com.pubnub.objc-tests";
        }
    }
    
    return self;
}


#pragma mark - Storage

- (NSMutableDictionary *)inMemoryStorage {
    static NSMutableDictionary *_inMemoryStorage;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
#if TARGET_OS_OSX
        NSFileManager *fileManager = NSFileManager.defaultManager;
        NSString *filePath = [self fileBasedStoragePath];
        NSString *workingDirectory = [filePath stringByDeletingLastPathComponent];
        
        if (![fileManager fileExistsAtPath:workingDirectory isDirectory:NULL]) {
            [fileManager createDirectoryAtPath:workingDirectory
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
        
        NSDictionary *storedData = [NSDictionary dictionaryWithContentsOfFile:filePath];
        _inMemoryStorage = [NSMutableDictionary dictionaryWithDictionary:storedData];
#else
        _inMemoryStorage = [NSMutableDictionary new];
#endif // TARGET_OS_OSX
    });
    
    return _inMemoryStorage;
}


#pragma mark - Storage manipulation

+ (void)storeValue:(id)value
               forKey:(NSString *)key
  withCompletionBlock:(void(^)(BOOL stored))block {

#if !TARGET_OS_OSX
    BOOL shouldWriteInMemory = ![self isKeychainAvailable];
#else
    BOOL shouldWriteInMemory = YES;
#endif // !TARGET_OS_OSX
    PNKeychain *keychain = self.defaultKeychain;

    dispatch_barrier_async(keychain.resourceAccessQueue, ^{
        BOOL stored = NO;
        
        if (!shouldWriteInMemory) {
            stored = [keychain storeValue:value forKey:key];
        } else {
            [keychain inMemoryStorage][key] = value;
#if TARGET_OS_OSX
            [[keychain inMemoryStorage] writeToFile:[keychain fileBasedStoragePath] atomically:YES];
#endif // TARGET_OS_OSX
            stored = YES;
        }
        
        if (block) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block(stored);
            });
        }
    });
}

+ (void)valueForKey:(NSString *)key withCompletionBlock:(void(^)(id value))block {
#if !TARGET_OS_OSX
    BOOL shouldReadFromMemory = ![self isKeychainAvailable];
#else
    BOOL shouldReadFromMemory = YES;
#endif // !TARGET_OS_OSX
    PNKeychain *keychain = self.defaultKeychain;
    
    if (!block) {
        return;
    }
    
    dispatch_async(keychain.resourceAccessQueue, ^{
        id data = nil;
        
        if (!shouldReadFromMemory) {
            NSArray *results = [keychain searchWithQuery:[keychain baseInformationForItemWithKey:key]
                                               fetchData:YES];
            
            data = results.count == 2 ? results.firstObject : nil;
        } else {
            data = [keychain inMemoryStorage][key];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(data);
        });
    });
}

+ (void)removeValueForKey:(NSString *)key withCompletionBlock:(void(^)(BOOL))block {
#if !TARGET_OS_OSX
    BOOL shouldWriteInMemory = ![self isKeychainAvailable];
#else
    BOOL shouldWriteInMemory = YES;
#endif // !TARGET_OS_OSX
    PNKeychain *keychain = self.defaultKeychain;
    
    dispatch_barrier_async(keychain.resourceAccessQueue, ^{
        BOOL removed = YES;
        
        if (!shouldWriteInMemory) {
            removed = [keychain removeValueForKey:key];
        } else {
            [[keychain inMemoryStorage] removeObjectForKey:key];
#if TARGET_OS_OSX
            [[keychain inMemoryStorage] writeToFile:[keychain fileBasedStoragePath] atomically:YES];
#endif // TARGET_OS_OSX
            removed = YES;
        }
        
        if (block) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block(removed);
            });
        }
    });
}

- (BOOL)storeValue:(id)value forKey:(NSString *)key {
    return [self update:value usingQuery:[self baseInformationForItemWithKey:key]];
}

- (id)valueForKey:(NSString *)key {
    NSArray *results = [self searchWithQuery:[self baseInformationForItemWithKey:key] fetchData:YES];
    
    return results.count == 2 ? results.firstObject : nil;
}

- (BOOL)removeValueForKey:(NSString *)key {
    BOOL removed = YES;
    
    if ([self checkExistingDataWithQuery:[self baseInformationForItemWithKey:key]]) {
        removed = [self update:nil usingQuery:[self baseInformationForItemWithKey:key]];
    }
    
    return removed;
}

- (void)updateEntries:(NSArray<NSString *> *)entryNames accessibilityTo:(CFStringRef)accessibility {
    for (NSString *entryKey in entryNames) {
        NSMutableDictionary *query = [self baseInformationForItemWithKey:entryKey];
        query[(__bridge id)kSecReturnAttributes] = (__bridge id)(kCFBooleanTrue);
        query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
        [query removeObjectForKey:(__bridge id)(kSecAttrAccessible)];
        CFDictionaryRef searchedItem = NULL;
        id data = nil;
        
        OSStatus searchStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query,
                                                    (CFTypeRef *)&searchedItem);

        if (searchedItem && searchStatus == errSecSuccess) {
            NSDictionary *entryAttributes = (__bridge NSDictionary *)searchedItem;
            NSString *itemAccessibility = entryAttributes[(__bridge id)(kSecAttrAccessible)];

            if (![itemAccessibility isEqualToString:(__bridge id)accessibility]) {
                if (CFDictionaryContainsKey(searchedItem, kSecValueData)) {
                    NSData *packedData = ((__bridge NSDictionary *)searchedItem)[(__bridge id)kSecValueData];
                    data = [self unpackedData:packedData];
                }
                
                SecItemDelete((__bridge CFDictionaryRef)query);
            }

            if (data) {
                [self storeValue:data forKey:entryKey];
            }
        }

        if (searchedItem) {
            CFRelease(searchedItem);
        }
    }
}


#pragma mark - Keychain query

- (void)debugKeychainQueryStatus:(OSStatus)status {
#ifdef DEBUG
    switch (status) {
        case errSecParam:
        case errSecBadReq:
            NSLog(@"Keychain: Wrong set of parameters has been used.");
            break;
        case errSecDuplicateItem:
            NSLog(@"Keychain: Item already exist.");
            break;
        case errSecItemNotFound:
            NSLog(@"Keychain: Item doesn't exist.");
            break;
        default:
            break;
    }
#endif
}

- (BOOL)checkExistingDataWithQuery:(NSMutableDictionary *)query {
    NSArray *result = [self searchWithQuery:query fetchData:NO];
    
    return result.count == 2 || !((NSNumber *)result.lastObject).boolValue;
}

- (NSArray *)searchWithQuery:(NSMutableDictionary *)query fetchData:(BOOL)shouldFetchData {
    CFDictionaryRef searchedItem = NULL;
    id data = nil;
    
    if (shouldFetchData) {
        query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
        query[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    }
    
    OSStatus searchStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query,
                                                (shouldFetchData ? (CFTypeRef *)&searchedItem
                                                                 : NULL));
    [query removeObjectsForKeys:@[(__bridge id)kSecReturnData, (__bridge id)kSecReturnAttributes]];
    
    if (searchStatus != errSecItemNotFound) {
        [self debugKeychainQueryStatus:searchStatus];
    }
    
    if (searchedItem && searchStatus == errSecSuccess &&
        CFDictionaryContainsKey(searchedItem, kSecValueData)) {
        
        NSData *packedData = ((__bridge NSDictionary *)searchedItem)[(__bridge id)kSecValueData];
        data = [self unpackedData:packedData];
    }
    
    if (searchedItem) {
        CFRelease(searchedItem);
    }
    
    return data ? @[data, @(searchStatus != errSecSuccess)] : @[@(searchStatus != errSecSuccess)];
}

- (BOOL)update:(id)value usingQuery:(NSMutableDictionary *)query {
    NSData *packedData = [self packedData:value];
    BOOL updated = NO;
    
    if (packedData) {
        BOOL exist = [self checkExistingDataWithQuery:query];
        NSDictionary *data = @{ (__bridge id)(kSecValueData): packedData };
        OSStatus updateStatus = errSecParam;
        
        if (exist) {
            updateStatus = SecItemUpdate((__bridge CFDictionaryRef)query,
                                         (__bridge CFDictionaryRef)data);
        } else {
            [query addEntriesFromDictionary:data];
            
            updateStatus = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
            [query removeObjectsForKeys:data.allKeys];
        }
        
        [self debugKeychainQueryStatus:updateStatus];
        updated = updateStatus == errSecSuccess;
    } else if (value == nil) {
        OSStatus deleteStatus = SecItemDelete((__bridge CFDictionaryRef)query);
        
        [self debugKeychainQueryStatus:deleteStatus];
        updated = deleteStatus == errSecSuccess;
    }
    
    return updated;
}


#pragma mark - Keychain data archiving

- (NSData *)packedData:(id)data {
    NSData *packedData = nil;
    NSError *error = nil;
    
    if (data) {
        if ([data respondsToSelector:@selector(count)]) {
            packedData = [NSJSONSerialization dataWithJSONObject:data
                                                         options:(NSJSONWritingOptions)0
                                                           error:&error];
        } else if ([data isKindOfClass:NSData.class]) {
            packedData = data;
        } else {
            packedData = [(NSString *)data dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    return packedData;
}

- (id)unpackedData:(NSData *)data {
    NSError *error = nil;
    id unpackedData = nil;
    
    if (data) {
        unpackedData = [NSJSONSerialization JSONObjectWithData:data
                                                       options:(NSJSONReadingOptions)0
                                                         error:&error];
        
        if (error != nil) {
            unpackedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    
    return unpackedData ?: data;
}


#pragma mark - Misc

+ (void)updateEntries:(NSArray<NSString *> *)entryNames accessibilityTo:(CFStringRef)accessibility {
#if !TARGET_OS_OSX
    BOOL shouldWriteInMemory = ![self isKeychainAvailable];
#else
    BOOL shouldWriteInMemory = YES;
#endif // !TARGET_OS_OSX
    
    if (shouldWriteInMemory) {
        return;
    }
    
    PNKeychain *keychain = self.defaultKeychain;
    
    dispatch_barrier_async(keychain.resourceAccessQueue, ^{
        [keychain updateEntries:entryNames accessibilityTo:accessibility];
    });
}

- (NSString *)fileBasedStoragePath {
    static NSString *_fileBasedStoragePath;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSSearchPathDirectory searchPath = NSApplicationSupportDirectory;
        NSProcessInfo *processInfo = NSProcessInfo.processInfo;
        NSBundle *mainBundle = NSBundle.mainBundle;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
        
        NSString *baseDirectory = (paths.count > 0 ? paths.firstObject : NSTemporaryDirectory());
        NSString *applicationName = processInfo.processName ?: mainBundle.bundleIdentifier;
        
        NSString *storeDirectory = [baseDirectory stringByAppendingPathComponent:applicationName];
        _fileBasedStoragePath = [storeDirectory stringByAppendingPathComponent:@"pnkc.db"];
    });
    
    return _fileBasedStoragePath;
}

+ (BOOL)isKeychainAvailable {
    static dispatch_once_t onceToken;
    static BOOL available;
    
    dispatch_once(&onceToken, ^{
#if TARGET_OS_OSX
        SecKeychainRef keychain;
        available = SecKeychainCopyDefault(&keychain) == errSecSuccess;
        
        if(available) {
            CFRelease(keychain);
        }
#else
        available = YES;
#endif
    });
    
    return available;
}

- (NSMutableDictionary *)baseInformationForItemWithKey:(NSString *)key {
    NSMutableDictionary *query = [NSMutableDictionary new];
    query[(__bridge id)(kSecClass)] = (__bridge id)(kSecClassGenericPassword);
    query[(__bridge id)(kSecAttrSynchronizable)] = (__bridge id)(kCFBooleanFalse);
    query[(__bridge id)(kSecAttrAccessible)] = (__bridge id)(kSecAttrAccessibleAfterFirstUnlock);
    query[(__bridge id)(kSecAttrService)] = self.serviceIdentifier;
    query[(__bridge id)(kSecAttrAccount)] = key;
    
    return query;
}

#pragma mark - 


@end
