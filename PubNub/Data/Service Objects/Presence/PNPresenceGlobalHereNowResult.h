#import <PubNub/PNOperationResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Global presence response.
@interface PNPresenceGlobalHereNowData : NSObject


#pragma mark - Properties

/// Active channels list.
///
/// Each dictionary key represent channel name and it's value is presence information for it.
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSDictionary *> *channels;

/// Total number of active channels.
@property (nonatomic, readonly, strong) NSNumber *totalChannels;

/// Total number of subscribers.
@property (nonatomic, readonly, strong) NSNumber *totalOccupancy;

#pragma mark -


@end


#pragma mark - Interface declaration

/// Global channels presence request result.
@interface PNPresenceGlobalHereNowResult : PNOperationResult


#pragma mark - Properties

/// Global presence request processing information.
@property (nonatomic, readonly, strong) PNPresenceGlobalHereNowData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
