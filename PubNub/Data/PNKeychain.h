#import <Foundation/Foundation.h>


/**
 @brief  Class provide simplified access to values manipulation inside of Keychain.
 
 @author Sergey Mamontov
 @since 4.x.1
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNKeychain : NSObject


///------------------------------------------------
/// @name Storage manipulation
///------------------------------------------------

/**
 @brief  Place passed \c value in Keychain under specified \c key.
 
 @param value Referebce on object which should be placed into Keychain.
 @param key   Referebce on string which should be used for data storing and access.
 @param block Reference on block which will be called at the end of store operation. Block pass only
              one argument - whether error occurred or not.
 */
+ (void)storeValue:(id)value forKey:(NSString *)key withCompletionBlock:(void(^)(BOOL stored))block;

/**
 @brief  Retrieve value stored under specified key in Keychain.
 
 @param key   Referebce on string which should be used for data access.
 @param block Reference on block which will be called at the end of store operation. Block pass only
              one argument - fetched data.
 */
+ (void)valueForKey:(NSString *)key withCompletionBlock:(void(^)(id value))block;

/**
 @brief  Remove any value from Keychain which is associated with specified \c key.
 
 @param key   Referebce on string for which stored value should be removed from Keychain.
 @param block Reference on block which will be called at the end of removal operation. Block pass 
              only one argument - whether error occurred or not.
 */
+ (void)removeValueForKey:(NSString *)key withCompletionBlock:(void(^)(BOOL))block;

#pragma mark - 


@end
