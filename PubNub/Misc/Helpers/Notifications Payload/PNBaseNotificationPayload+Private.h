#import "PNBaseNotificationPayload.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNBaseNotificationPayload (Private)


#pragma mark - Information

/**
 * @brief Additional information which may explain reason why this notification has been delivered.
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
 * @brief Short text which should be shown at the top of notification instead of application name.
 */
@property (nonatomic, nullable, copy) NSString *title;

/**
 * @brief Message which should be shown in notification body (under title line).
 */
@property (nonatomic, nullable, copy) NSString *body;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure platform specific notification payload builder.
 *
 * @param payloadStorage Mutable dictionary which can be used to store user-provided information.
 * @param title Short text which should be shown at the top of notification instead of application
 *     name.
 * @param body Message which should be shown in notification body (under title line).
 *
 * @return Configured and ready to use platform specific notification payload builder.
 */
+ (instancetype)payloadWithStorage:(NSMutableDictionary *)payloadStorage
                 notificationTitle:(nullable NSString *)title
                              body:(nullable NSString *)body;

/**
 * @brief Complete payload structure setup specific for target platform.
 */
- (void)setDefaultPayloadStructure;


#pragma mark - Misc

/**
 * @brief Translate user-provided information into payload which can be consumed by \b PubNub mobile
 * notification service and delivered to target devices.
 */
- (nullable NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
