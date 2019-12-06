#import <Foundation/Foundation.h>
#import "PNBaseNotificationPayload.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief FCM notification payload builder.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFCMNotificationPayload : PNBaseNotificationPayload


#pragma mark - Information

/**
 * @brief Object with parameters which specify user-visible key-value pairs.
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *notification;

/**
 * @brief Custom key-value object with additional information which will be passed to device along
 * with displayable notification information.
 *
 * @note All object and scalar type value should be converted to strings before passing to this
 *     object.
 * @note \c notification object will be added to this object in case if \c isSilent set to \c YES.
 *
 * @warning Keys shouldn't match: \c from, \c message_type or start with \c google or \c gcm.
 * Also as key can't be used any word defined in this table: https://firebase.google.com/docs/cloud-messaging/http-server-ref#notification-payload-support
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *data;

/**
 * @brief Whether operation system should handle notification layout by default or not.
 *
 * @note \c notification key with it's content will be moved from root level under \c data key.
 */
@property (nonatomic, assign, getter=isSilent) BOOL silent;

/**
 * @brief Icon which should be shown on the left from notification title instead of application
 * icon.
 */
@property (nonatomic, nullable, copy) NSString *icon;

/**
 * @brief Unique notification identifier which can be used to publish update notifications (they
 * will previous notification with same \c tag).
 */
@property (nonatomic, nullable, copy) NSString *tag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
