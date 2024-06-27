#import <PubNub/PNErrorStatus.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Subscribe` request response processing status.
@interface PNSubscribeStatus : PNErrorStatus


#pragma mark - Properties

/// List of channel group names on which client currently subscribed.
@property(copy, nonatomic, readonly) NSArray<NSString *> *subscribedChannelGroups;

/// List of channels on which client currently subscribed.
@property(copy, nonatomic, readonly) NSArray<NSString *> *subscribedChannels;

/// Time token which has been used to establish current subscription cycle.
@property(strong, nonatomic, readonly) NSNumber *currentTimetoken;

///  Stores reference on previous key which has been used in subscription cycle to receive `currentTimetoken` along
///  with other events.
@property(strong, nonatomic, readonly) NSNumber *lastTimeToken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
