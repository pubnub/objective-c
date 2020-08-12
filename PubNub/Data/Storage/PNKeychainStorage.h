#import <Foundation/Foundation.h>
#import "PNKeyValueStorage.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Keychain \c key/value storage.
 *
 * @author Serhii Mamontov
 * @version 4.15.3
 * @since 4.15.3
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNKeychainStorage : NSObject <PNKeyValueStorage>


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c key/value Keychain storage.
 *
 * @param identifier Unique identifier with which managed values should be \c "linked".
 * @param queue Resources access serialisation queue.
 *
 * @return Configured and ready to use \c key/value Keychain storage.
 */
+ (instancetype)storageWithIdentifier:(NSString *)identifier queue:(dispatch_queue_t)queue;


#pragma mark - Data storage

/**
 * @brief Update accessibility for entries specified by list of keys.
 *
 * @param entryNames List of entry names for which current accessibility should be changed.
 * @param accessibility Target entries accessibility mode.
 */
- (void)updateEntries:(NSArray<NSString *> *)entryNames accessibilityTo:(CFStringRef)accessibility;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
