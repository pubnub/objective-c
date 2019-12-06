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


#pragma mark - Misc

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
