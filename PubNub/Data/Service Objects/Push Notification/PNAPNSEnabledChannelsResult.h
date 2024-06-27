#import <PubNub/PNOperationResult.h>
#import <PubNub/PNPushNotificationFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Fetch APNS enabled channels request processing result.
@interface PNAPNSEnabledChannelsResult : PNOperationResult


#pragma mark - Properties

/// APNS enabled channels request response from remote service.
@property (nonatomic, readonly, strong) PNPushNotificationFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
