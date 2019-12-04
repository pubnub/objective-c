#import "PNBasePushNotificationsRequest.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Remove \c notifications \c from \c channels request.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNRemovePushNotificationsRequest : PNBasePushNotificationsRequest


#pragma mark - Information

/**
 * @brief List of channel names for which push notifications should be disabled.
 */
@property (nonatomic, copy) NSArray<NSString *> *channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
