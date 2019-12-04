#import <Foundation/Foundation.h>
#import "PNAPNSNotificationPayload.h"
#import "PNMPNSNotificationPayload.h"
#import "PNFCMNotificationPayload.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Notifications payload builder.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNNotificationsPayload : NSObject


#pragma mark - Information

/**
 * @brief Access to APNS specific notification builder.
 *
 * @discussion Allows to set specific general keys and provides access to mutable payload which
 * allow to make advanced configuration.
 */
@property (nonatomic, readonly, strong) PNAPNSNotificationPayload *apns;

/**
 * @brief Access to MPNS specific notification builder.
 *
 * @discussion Allows to set specific general keys and provides access to mutable payload which
 * allow to make advanced configuration.
 */
@property (nonatomic, readonly, strong) PNMPNSNotificationPayload *mpns;

/**
 * @brief Access to FCM specific notification builder.
 *
 * @discussion Allows to set specific general keys and provides access to mutable payload which
 * allow to make advanced configuration.
 */
@property (nonatomic, readonly, strong) PNFCMNotificationPayload *fcm;

/**
 * @brief Additional information which may explain reason why this notification has been delivered.
 *
 * @note May not be supported by some platforms or has different layout in UI.
 */
@property (nonatomic, nullable, copy) NSString *subtitle;

/**
 * @brief Number which should be shown in space designated by platform (for example atop of
 * application icon).
 */
@property (nonatomic, nullable, strong) NSNumber *badge;

/**
 * @brief Path to file with sound or name of system sound which should be played upon notification
 * receive.
 */
@property (nonatomic, nullable, copy) NSString *sound;

/**
 * @brief Whether \b PubNub service should provide debug information about devices which received
 * created notifications payload.
 *
 * @note Make sure to subscribe from https://www.pubnub.com/docs/console using same
 * \c publish / \c subscribe keys on channel to which message has been sent. Full channel name
 * consist from target channel name and suffix: \c -pndebug.
 * Each time, when message will be sent, \b PubNub should provide debug information into debug
 * channel.
 */
@property (nonatomic, assign) BOOL debugging;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure notifications payload builder.
 *
 * @param title Short text which should be shown at the top of notification instead of application
 *     name.
 * @param body Message which should be shown in notification body (under title line).
 *
 * @return Configured and ready to use notifications payload builder.
 */
+ (instancetype)payloadsWithNotificationTitle:(nullable NSString *)title
                                         body:(nullable NSString *)body;

/**
 * @brief Forbids payload builder initialization.
 *
 * @throws Interface not available exception and requirement to use provided constructor method.
 *
 * @return Initialized builder.
 */
- (instancetype)init NS_UNAVAILABLE;


#pragma mark - Misc

/**
 * @brief Build notifications platform for requested platforms (\c pushTypes).
 *
 * @param pushTypes Bitfield with fields from \b PNPushType which specify platforms for which
 * payload should be added to final dictionary.
 *
 * @return Dictionary with keys (platform names) and values (notification payload) which will be
 * consumed by \b PubNub service and used to trigger remote notifications for devices on specified
 * platforms.
 */
- (NSDictionary *)dictionaryRepresentationFor:(PNPushType)pushTypes;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
