#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Useful NSNumber additions collection.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.2.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNNumber : NSObject


#pragma mark - Conversion

/**
 * @brief Create higher precision timetoken which can be used inside of \b PubNub service during
 * requests.
 *
 * @param number Reference on original number which should be normalized and returned with new
 * object.
 *
 * @return Normalized to \b PunNub service time token.
 */
+ (NSNumber *)timeTokenFromNumber:(NSNumber *)number;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
