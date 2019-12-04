#import "PNBasePushNotificationsRequest.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Add \c notifications \c for \c channels request.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNAddPushNotificationsRequest : PNBasePushNotificationsRequest


#pragma mark - Information

/**
 * @brief List of channel names for which push notifications should be enabled.
 */
@property (nonatomic, copy) NSArray<NSString *> *channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
