#import <Foundation/Foundation.h>
#import "PNAPNSNotificationConfiguration.h"
#import "PNBaseNotificationPayload.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief APNS notification payload builder.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNAPNSNotificationPayload : PNBaseNotificationPayload


#pragma mark - Information

/**
 * @brief List of APNS over HTTP/2 delivery configurations.
 *
 * @note If list is empty when payload for \b PNAPNS2Push has been requested, it will create default
 * configuration for In case if payload will be requested for \b PNAPNSDevelopment environment and
 * \b NSBundle.mainBundle.bundleIdentifier as topic name.
 */
@property (nonatomic, strong) NSArray<PNAPNSNotificationConfiguration *> *configurations;

/**
 * @brief Object with parameters which specify user-visible key-value pairs.
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *notification;

/**
 * @brief Whether operation system should handle notification layout by default or not.
 *
 * @note \c alert, \c sound and \c badge will be removed from resulting payload if set to \c YES.
 */
@property (nonatomic, assign, getter=isSilent) BOOL silent;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
