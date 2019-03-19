#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class provide simplified access to values manipulation inside of Keychain.
 *
 * @since 4.x.1
 *
 * @author Serhii Mamontov
 * @version 4.8.5
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNKeychain : NSObject


#pragma mark - Storage manipulation

/**
 * @brief Place passed \c value in Keychain under specified \c key.
 *
 * @note Asynchronous operation if required will be performed on secondary queue.
 *
 * @param value Object which should be placed into Keychain.
 * @param key String which should be used for data storing and access.
 * @param block GCD block / closure which will be called at the end of store operation.
 *     GCD block / closure pass only one argument - whether error occurred or not.
 */
+ (void)storeValue:(id)value
                 forKey:(NSString *)key
    withCompletionBlock:(nullable void(^)(BOOL stored))block;

/**
 * @brief Retrieve value stored under specified key in Keychain.
 *
 * @note Synchronous operation will be performed on same queue where call has been done.
 *
 * @param key String which should be used for data access.
 * @param block GCD block / closure which will be called at the end of store operation.
 *     GCD block / closure pass only one argument - fetched data.
 */
+ (void)valueForKey:(NSString *)key
    withCompletionBlock:(nullable void(^)(id __nullable value))block;

/**
 * @brief  Remove any value from Keychain which is associated with specified \c key.
 *
 * @note Asynchronous operation if required will be performed on secondary queue.
 *
 * @param key String for which stored value should be removed from Keychain.
 * @param block GCD block / closure which will be called at the end of removal operation.
 *     GCD block / closure pass only one argument - whether error occurred or not.
 */
+ (void)removeValueForKey:(NSString *)key
      withCompletionBlock:(nullable void(^)(BOOL))block;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
