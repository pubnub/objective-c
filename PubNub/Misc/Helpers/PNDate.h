#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Useful NSDate additions collection.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNDate : NSObject


#pragma mark - Conversion

/**
 * @brief Convert \a NSDate instance to string formatted according to \c RFC3339.
 *
 * @param date \a NSDate instance which should be converted to \a NSString.
 *
 * @return RFC3339 formatted date string.
 */
+ (NSString *)RFC3339StringFromDate:(NSDate *)date;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
