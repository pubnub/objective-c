#import <PubNub/PNPresenceUserStateFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch user presence state` request response private extension.
@interface PNPresenceUserStateFetchData (Private)


#pragma mark - Properties

/// Name of the channel for which user's state has been requested.
///
/// > Note: This value will be `nil` if state requested for multiple channels / channel group.
@property(strong, nullable, nonatomic, readonly) NSString *channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
