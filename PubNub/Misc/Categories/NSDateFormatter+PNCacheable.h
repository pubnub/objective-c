#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c NSDateFormatter extension to provide cached formats support.
 *
 * @author Serhii Mamontov
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface NSDateFormatter (PNCacheable)


#pragma mark - Simple formatter

/**
 * @brief Create and configure simple date formatter basing on provided \c format.
 *
 * @note Cached instance will be returned in case, if formatter for \c has been requested before.
 *
 * @param dateFormat Format string which should be used to parse \a NSString to \a NSDate and vice
 * versa.
 *
 * @return Configured and ready to use formatter instance.
 */
+ (NSDateFormatter *)pn_formatterWithString:(NSString *)dateFormat;


#pragma mark - Service based formatter

/**
 * @brief Create and configure date formatter to handle dates from Objecta API.
 *
 * @return Date formatter which will use \c yyyy-MM-dd'T'HH:mm:ss.SSSZ as \c dateFormat.
 */
+ (NSDateFormatter *)pn_objectsDateFormatter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
