#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// List channel group channels request response.
@interface PNChannelGroupFetchData : PNBaseOperationData


#pragma mark - Properties

/// Registered channels within channel group.
///
/// > Note: In case if status object represent error, this property may contain list of channels to which client
/// doesn't have access.
/// > Note: Value will be `nil` if list of channel groups has been requested.
@property(strong, nullable, nonatomic, readonly) NSArray<NSString *> *channels;

/// Channel groups for subscription key.
///
/// > Note: Value will be `nil` if channel group channels has been requested.
@property(strong, nullable, nonatomic, readonly) NSArray<NSString *> *groups;

/// Name of the channel group for which request has been made.
///
/// > Note: Value will be `nil` if list of channel groups has been requested.
@property(strong, nullable, nonatomic, readonly) NSString *channelGroup;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
