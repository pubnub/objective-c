#import <Foundation/Foundation.h>
#import "PNAPNSNotificationTarget.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief APNS over HTTP/2 delivery configuration.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNAPNSNotificationConfiguration : NSObject


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure default APNS over HTTP/2 notification configuration.
 *
 * @discussion Default configuration will be created for single target in \b PNAPNSDevelopment
 * environment and \b NSBundle.mainBundle.bundleIdentifier as topic name.
 *
 * @return Configured and ready to use APNS over HTTP/2 notification configuration.
 */
+ (instancetype)defaultConfiguration;

/**
 * @brief Create and configure APNS over HTTP/2 notification configuration.
 *
 * @param targets List of topics which should receive this notification.
 *     Default target with \b NSBundle.mainBundle.bundleIdentifier topic and \b PNAPNSDevelopment
 *     environment will be used if list is empty.
 *
 * @return Configured and ready to use APNS over HTTP/2 notification configuration.
 */
+ (instancetype)configurationWithTargets:(NSArray<PNAPNSNotificationTarget *> *)targets;

/**
 * @brief Create and configure APNS over HTTP/2 notification configuration.
 *
 * @param collapseId Notification group / collapse identifier.
 *     Value will be used in APNs POST request as \a apns-collapse-id header value.
 * @param date Date till which APNS will try to deliver notification to target device.
 *     Value will be used in APNs POST request as \a apns-expiration header value.
 * @param targets List of topics which should receive this notification.
 *     Default target with \b NSBundle.mainBundle.bundleIdentifier topic and \b PNAPNSDevelopment
 *     environment will be used if list is empty.
 *
 * @return Configured and ready to use APNS over HTTP/2 notification configuration.
 */
+ (instancetype)configurationWithCollapseID:(nullable NSString *)collapseId
                             expirationDate:(nullable NSDate *)date
                                    targets:(NSArray<PNAPNSNotificationTarget *> *)targets;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
