#import "PNAPNSNotificationPayload.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNAPNSNotificationPayload (Private)


#pragma mark - Information

/**
 * @brief APNS or APNS over HTTP/2 push type.
 */
@property (nonatomic, assign) PNPushType apnsPushType;


#pragma mark -


@end

NS_ASSUME_NONNULL_END
