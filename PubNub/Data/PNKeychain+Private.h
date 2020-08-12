#import "PNKeychain.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Keychain private extension which provides maintenance methods.
 *
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNKeychain (Private)


#pragma mark - Information

/**
 * @brief Shared \a Keychain resources access serialisation queue.
 *
 * @note Queue used only by \c defaultKeychain.
 */
@property (nonatomic, nullable, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief Default keychain which use previous interface with storage detection and used with class methods.
 *
 * @since 4.15.3
 */
@property (class, nonatomic, readonly, strong) PNKeychain *defaultKeychain;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \a Keychain access helper.
 *
 * @param identifier Unique identifier which will be used to scope data in different "keychains" (used as service identifier).
 *
 * @return Configured and ready to use \c Keychain access helper.
 *
 * @since 4.15.3
 */
+ (instancetype)keychainWithIdentifier:(NSString *)identifier;


#pragma mark - Storage manipulation

/**
 * @brief Place passed \c value in Keychain under specified \c key.
 *
 * @note Asynchronous operation if required will be performed on secondary queue.
 *
 * @param value Object which should be placed into Keychain.
 * @param key String which should be used for data storing and access.
 *
 * @return \c YES in case if value has been stored.
 *
 * @since 4.15.3
 */
- (BOOL)storeValue:(id)value forKey:(NSString *)key;

/**
 * @brief Retrieve value stored under specified key in Keychain.
 *
 * @note Synchronous operation will be performed on same queue where call has been done.
 *
 * @param key String which should be used for data access.
 *
 * @return Data which has been stored before under specified \c key.
 *
 * @since 4.15.3
 */
- (nullable id)valueForKey:(NSString *)key;

/**
 * @brief  Remove any value from Keychain which is associated with specified \c key.
 *
 * @note Asynchronous operation if required will be performed on secondary queue.
 *
 * @param key String for which stored value should be removed from Keychain.
 *
 * @return \c YES in case if value under specified \c key has been removed.
 *
 * @since 4.15.3
 */
- (BOOL)removeValueForKey:(NSString *)key;

/**
 * @brief Update accessibility for entries specified by list of keys.
 *
 * @param entryNames List of entry names for which current accessibility should be changed.
 * @param accessibility Target entries accessibility mode.
 */
- (void)updateEntries:(NSArray<NSString *> *)entryNames accessibilityTo:(CFStringRef)accessibility;


#pragma mark - Misc

/**
 * @brief Check whether system is able to provide access to Keychain (even locked) or not.
 *
 * @return \c NO in case if client is used in milti-user macOS environment and user not authorised yet.
 *
 * @since 4.15.3
 */
+ (BOOL)isKeychainAvailable;

/**
 * @brief Update accessibility for entries specified by list of keys.
 *
 * @param entryNames List of entry names for which current accessibility should be changed.
 * @param accessibility Target entries accessibility mode.
 */
+ (void)updateEntries:(NSArray<NSString *> *)entryNames accessibilityTo:(CFStringRef)accessibility;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
