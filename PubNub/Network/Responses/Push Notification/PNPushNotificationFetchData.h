#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Fetch time request response data.
@interface PNPushNotificationFetchData : PNBaseOperationData


#pragma mark - Properties

/// Channels with active push notifications.
@property(strong, nonatomic, readonly) NSArray<NSString *> *channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
