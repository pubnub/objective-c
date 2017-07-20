/**
 @author Sergey Mamontov
 @since 4.x.1
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNKeychain.h"
#import <Security/Security.h>
#import "PNHelpers.h"


#pragma mark Static

/**
 @brief  Spin-lock which is used to protect access to shared resources from multiple threads.
 
 @since 4.6.2
 */
static os_unfair_lock keychainAccessLock = OS_UNFAIR_LOCK_INIT;


#pragma mark Private interface declaration

@interface PNKeychain ()


#pragma mark - Temporary storage

/**
 @brief      Reference on storage which is used for environment where Keychain access DB not
             available.
 @discussion In multi-user systems before user authorize system is unable to provide information 
             about Keychain because it doesn't know for which user. Used only by macOS because iOS 
             is always single user.
 
 @since 4.6.2
 
 @return Reference on dictionary which should be used as temporary in-memory Keychain access DB
         replacement.
 */
+ (NSMutableDictionary *)inMemoryStorage;


#pragma mark - Keychain query

/**
 @brief  Help to debug Keychain query error status.
 
 @param status One of \c OSStatus types.
 */
+ (void)debugKeychainQueryStatus:(OSStatus)status;

/**
 @brief  Check whether item described with query already exist in Keychain or not.
 
 @param query Reference on dictionary which contain base item information which should be checked.
 @param block Reference on block which will be called when check will be completed. Block pass only
              one argument - whether item exist or not.
 */
+ (void)checkExistingDataWithQuery:(NSMutableDictionary *)query completionBlock:(void(^)(BOOL))block;

/**
 @brief  Allow to search for item in Keychain and if requested will pull out values which it stores.
 
 @param query           Reference on dictionary which contain base item information which should be
                        found.
 @param shouldFetchData Flag which specify whether item's data should be returned or not.
 @param block           Reference on block which will be called when search will be completed. Block
                        pass two arguments: \c value - searched item stored value if requested;
                        \c error - whether error occurred or not.
 */
+ (void)searchWithQuery:(NSMutableDictionary *)query fetchData:(BOOL)shouldFetchData
        completionBlock:(void(^)(id, BOOL))block;

/**
 @brief  Update item value.
 
 @param value Reference on value which should be stored for the item in Keychain.
 @param query Reference on dictionary which contain base item information which should be updated.
 @param block Reference on block which will be called when update will be completed. Block pass only
              one argument - whether error occurred or not.
 */
+ (void)update:(id)value usingQuery:(NSMutableDictionary *)query completionBlock:(void(^)(BOOL))block;


#pragma mark - Keychain data archiving

/**
 @brief      Allow to pack passed value to bytes.
 @discussion This method is used to store values in Keychain which accept only binaries for value.
 
 @param data Reference on object which should be packed to binary.
 
 @return Packed binary object.
 */
+ (NSData *)packedData:(id)data;

/**
 @brief      Allow to unpack stored value to native objects.
 @discussion This method is used to extract data stored in Keychain and return native objects.
 
 @param data Reference on binary object which should be unpacked.
 
 @return Unpacked foundation object.
 */
+ (id)unpackedData:(NSData *)data;


#pragma mark - Misc

/**
 @brief Check whether system is able to provide access to Keychain (even locked) or not.
 
 @return \c NO in case if client is used in milti-user macOS environment and user not authorized 
         yet.
 */
+ (BOOL)isKeychainAvailable;

/**
 @brief  Construct dictionary which will describe item storage or access information.
 
 @param key Reference on key under which item should be stored or searched.
 
 @return Prepared base item description.
 */
+ (NSMutableDictionary *)baseInformationForItemWithKey:(NSString *)key;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNKeychain


#pragma mark - Temporary storage

+ (NSMutableDictionary *)inMemoryStorage {
    
    static NSMutableDictionary *_inMemoryStorage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _inMemoryStorage = [NSMutableDictionary new]; });
    
    return _inMemoryStorage;
}


#pragma mark - Storage manipulation

+ (void)storeValue:(id)value forKey:(NSString *)key withCompletionBlock:(void(^)(BOOL stored))block {
    
    if ([self isKeychainAvailable]) {
        
        [self update:value usingQuery:[self baseInformationForItemWithKey:key] completionBlock:block];
    } else {
        
        pn_trylock(&keychainAccessLock, ^{
            
            [self inMemoryStorage][key] = value;
            if (block) { block(YES); }
        });
    }
}

+ (void)valueForKey:(NSString *)key withCompletionBlock:(void(^)(id value))block {
    
    if ([self isKeychainAvailable]) {
        
        [self searchWithQuery:[self baseInformationForItemWithKey:key] fetchData:YES
              completionBlock:^(id data, BOOL error) { if (block) { block(data); } }];
    } else { pn_trylock(&keychainAccessLock, ^{ block([self inMemoryStorage][key]); }); }
}

+ (void)removeValueForKey:(NSString *)key withCompletionBlock:(void(^)(BOOL))block {
    
    if ([self isKeychainAvailable]) {
        
        [self checkExistingDataWithQuery:[self baseInformationForItemWithKey:key]
                         completionBlock:^(BOOL exists) {
                             
            if (exists) {

                [self update:nil usingQuery:[self baseInformationForItemWithKey:key]
             completionBlock:block];
            }
        }];
    } else {
        
        pn_trylock(&keychainAccessLock, ^{
            
            [[self inMemoryStorage] removeObjectForKey:key];
            if (block) { block(YES); }
        });
    }
}


#pragma mark - Keychain query

+ (void)debugKeychainQueryStatus:(OSStatus)status {
    
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

+ (void)checkExistingDataWithQuery:(NSMutableDictionary *)query completionBlock:(void(^)(BOOL))block {
    
    [self searchWithQuery:query fetchData:NO completionBlock:^(id value, BOOL error) {
        
        if (block) { block(value || !error); }
    }];
}

+ (void)searchWithQuery:(NSMutableDictionary *)query fetchData:(BOOL)shouldFetchData
        completionBlock:(void(^)(id, BOOL))block {
    
    if (shouldFetchData) {
        
        query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
        query[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    }
    
    // Run search query
    CFDictionaryRef searchedItem = NULL;
    OSStatus searchStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query,
                                                (shouldFetchData ? (CFTypeRef *)&searchedItem : NULL));
    [query removeObjectsForKeys:@[(__bridge id)kSecReturnData, (__bridge id)kSecReturnAttributes]];
    
    // Processing keychain query results.
    id data = nil;
    [self debugKeychainQueryStatus:searchStatus];
    // Check whether search performed w/o any errors or not.
    if (searchStatus == errSecSuccess && searchedItem && CFDictionaryContainsKey(searchedItem, kSecValueData)) {
        
        // Extract fetched data.
        data = [self unpackedData:((__bridge NSDictionary *)searchedItem)[(__bridge id)kSecValueData]];
    }
    
    if (searchedItem) {
        
        CFRelease(searchedItem);
    }
    
    if (block) { block(data, (searchStatus != errSecSuccess)); }
}

+ (void)update:(id)value usingQuery:(NSMutableDictionary *)query completionBlock:(void(^)(BOOL))block {
    
    NSData *packedData = [self packedData:value];
    if (packedData) {
        
        // Checking whether value under specified key already stored in keychain or not.
        [self checkExistingDataWithQuery:query completionBlock:^(BOOL exist) {
            
            NSDictionary *data = @{(__bridge id)(kSecValueData): packedData};
            OSStatus updateStatus = errSecParam;
            if (exist) {
                
                updateStatus = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)data);
            }
            else {
                
                [query addEntriesFromDictionary:data];
                updateStatus = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
                [query removeObjectsForKeys:data.allKeys];
            }
            
            [self debugKeychainQueryStatus:updateStatus];
            
            if (block) { block((updateStatus == errSecSuccess)); }
        }];
    }
    else if(value == nil) {
        
        OSStatus deleteStatus = SecItemDelete((__bridge CFDictionaryRef)query);
        [self debugKeychainQueryStatus:deleteStatus];
        
        if (block) { block((deleteStatus == errSecSuccess)); }
    }
}


#pragma mark - Keychain data archiving

+ (NSData *)packedData:(id)data {
    
    NSData *packedData = nil;
    if (data) {
        
        if ([data respondsToSelector:@selector(count)]) {
            
            NSError *error = nil;
            packedData = [NSJSONSerialization dataWithJSONObject:data options:(NSJSONWritingOptions)0
                                                           error:&error];
        }
        else if ([data isKindOfClass:NSData.class]) { packedData = data; }
        else { packedData = [(NSString *)data dataUsingEncoding:NSUTF8StringEncoding]; }
    }
    
    return packedData;
}

+ (id)unpackedData:(NSData *)data {
    
    NSError *error = nil;
    id unpackedData = nil;
    
    if (data) {
        
        unpackedData = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0
                                                         error:&error];
        if (error != nil) {
            
            unpackedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    
    return (unpackedData?: data);
}


#pragma mark - Misc

+ (BOOL)isKeychainAvailable {
    static BOOL available;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_OS_OSX
        SecKeychainRef keychain;
        available = SecKeychainCopyDefault(&keychain) == errSecSuccess;
        if(available) { CFRelease(keychain); }
#else
        available = YES;
#endif
    });
    
    return available;
}

+ (NSMutableDictionary *)baseInformationForItemWithKey:(NSString *)key {
    
    // Compose base item description query.
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    // In case if we client used from tests environment configuration should use specified
    // device identifier.
    if (NSClassFromString(@"XCTestExpectation")) { bundleIdentifier = @"com.pubnub.objc-tests"; }
    NSMutableDictionary *query = [NSMutableDictionary new];
    query[(__bridge id)(kSecClass)] = (__bridge id)(kSecClassGenericPassword);
    query[(__bridge id)(kSecAttrSynchronizable)] = (__bridge id)(kCFBooleanFalse);
    query[(__bridge id)(kSecAttrAccessible)] = (__bridge id)(kSecAttrAccessibleAlways);
    query[(__bridge id)(kSecAttrService)] = bundleIdentifier;
    query[(__bridge id)(kSecAttrAccount)] = key;
    
    return query;
}

#pragma mark - 


@end
