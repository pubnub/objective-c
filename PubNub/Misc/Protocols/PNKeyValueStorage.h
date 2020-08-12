#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Interface for work with key/value storage types.
 *
 * @author Serhii Mamontov
 * @version 4.15.3
 * @since 4.15.3
 * @copyright © 2010-2020 PubNub, Inc.
 */
@protocol PNKeyValueStorage <NSObject>


#pragma mark - Batch

/**
 * @brief Start batch changed / read from storage using private queue.
 *
 * @note \a dispatch_barrier_sync will be used to call provided block.
 *
 * @warning Only \c store* / \c value* method should be called within provided \c block.
 *
 * @param block Block which contain storage manipulation code.
 */
- (void)batchSyncAccessWithBlock:(dispatch_block_t)block;

/**
 * @brief Start batch changed / read from storage using private queue.
 *
 * @note \a dispatch_barrier_async will be used to call provided block.
 *
 * @warning Only \c store* / \c value* method should be called within provided \c block.
 * @warning Completion block will return after 5 seconds if not called by caller.
 *
 * @param block Block which contain storage manipulation code and pass async completion block which should be called by caller.
 */
- (void)batchAsyncAccessWithBlock:(void(^)(dispatch_block_t completion))block;


#pragma mark - Value store

/**
 * @brief Store \c value under specified \c key using same queue on which call has been done.
 *
 * @param value Value which should be stored. \c nil will cause removal of value stored under specified \c key.
 * @param key Key under which value should be stored and available later.
 *
 * @return \c YES in case if \c value has been stored.
 */
- (BOOL)storeValue:(nullable id)value forKey:(NSString *)key;

/**
 * @brief Store \c value under specified \c key using private queue.
 *
 * @param value Value which should be stored. \c nil will cause removal of value stored under specified \c key.
 * @param key Key under which value should be stored and available later.
 *
 * @return \c YES in case if \c value has been stored.
 */
- (BOOL)syncStoreValue:(nullable id)value forKey:(NSString *)key;

/**
 * @brief Store \c value under specified \c key using private queue.
 *
 * @param value Value which should be stored. \c nil will cause removal of value stored under specified \c key.
 * @param key Key under which value should be stored and available later.
 * @param block Store completion block which will be called at the end of operation.
 */
- (void)asyncStoreValue:(nullable id)value
                 forKey:(NSString *)key
         withCompletion:(nullable void(^)(BOOL stored))block;


#pragma mark - Value read

/**
 * @brief Read value stored under specified \c key using same queue on which call has been done.
 *
 * @param key Key for which previous value should be fetched.
 *
 * @return Value which has been stored before or \c nil if value is missing.
 */
- (nullable id)valueForKey:(NSString *)key;

/**
 * @brief Read value stored under specified \c key using private queue.
 *
 * @param key Key for which previous value should be fetched.
 *
 * @return Value which has been stored before or \c nil if value is missing.
 */
- (nullable id)syncValueForKey:(NSString *)key;

/**
 * @brief Read value stored under specified \c key using private queue.
 *
 * @param key Key for which previous value should be fetched.
 * @param block Read completion block which will be called at the end of operation and provide value which has been stored before
 * or \c nil if value is missing..
 */
- (void)asyncValueForKey:(NSString *)key withCompletion:(void(^)(id _Nullable value))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
