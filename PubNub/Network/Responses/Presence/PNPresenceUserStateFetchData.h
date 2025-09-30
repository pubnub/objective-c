#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch user presence state` request response.
@interface PNPresenceUserStateFetchData : PNBaseOperationData


#pragma mark - Properties

/// Per-channel user presence state information.
///
/// > Note: Each key is the name of channel and value is `state` associated with user on channel.
/// > Important: Value will be set to `nil` in case if presence state requested for single channel.
@property(strong, nullable, nonatomic, readonly) NSDictionary<NSString *, id> *channels;

/// User presence state information for specific channel.
///
/// > Note: Each key is the name of channel and value is `state` associated with user on channel.
/// > Important: Value will be set to `nil` in case if presence state requested for multiple channels / channel groups.
@property(strong, nullable, nonatomic, readonly) NSDictionary<NSString *, id> *state;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
