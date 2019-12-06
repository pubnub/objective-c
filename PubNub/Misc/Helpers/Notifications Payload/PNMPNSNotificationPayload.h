#import <Foundation/Foundation.h>
#import "PNBaseNotificationPayload.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief MPNS notification payload builder.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMPNSNotificationPayload : PNBaseNotificationPayload


#pragma mark - Information

/**
 * @brief Message which should be shown in notification body (text for back tile).
 *
 * @note 40 characters long to fit into tile.
 *
 * @note This value initially set from builder's \c body value.
 */
@property (nonatomic, nullable, copy) NSString *backContent;

/**
 * @brief Additional information which may explain reason why this notification has been delivered.
 *
 * @note Maximum 15 characters long.
 *
 * @note This value initially set from builder's \c subtitle value.
 */
@property (nonatomic, nullable, copy) NSString *backTitle;

/**
 * @brief Value between 1-99 which will be shown on the tile.
 *
 * @note This value initially set from builder's \c badge value.
 */
@property (nonatomic, nullable, strong) NSNumber *count;

/**
 * @brief Title of the tile.
 *
 * @note This value initially set from builder's \c title value.
 */
@property (nonatomic, nullable, copy) NSString *title;

/**
 * @brief Type of notification which should be presented to the user.
 */
@property (nonatomic, nullable, copy) NSString *type;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
