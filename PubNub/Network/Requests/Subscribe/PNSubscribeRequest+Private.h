#import <PubNub/PNSubscribeRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private extension declaration

/// `Subscribe` request private extension.
@interface PNSubscribeRequest (Private)


#pragma mark - Properties

/// String representation of filtering expression which should be applied to decide which updates should reach client.
@property(strong, nullable, nonatomic) NSString *filterExpression;

/// Number of seconds which is used by server to track whether client still subscribed on remote data objects live feed
/// or not.
@property(assign, nonatomic) NSInteger presenceHeartbeatValue;

/// Whether real-time updates should be received for both regular and presence events or only for presence.
@property(assign, nonatomic, readonly) BOOL presenceOnly;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
