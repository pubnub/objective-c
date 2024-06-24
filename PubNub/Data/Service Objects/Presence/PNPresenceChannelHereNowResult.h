#import <PubNub/PNOperationResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Channel presence response.
@interface PNPresenceChannelHereNowData : NSObject


#pragma mark - Properties

/// Active channels list.
///
/// Each dictionary key represent channel name and it's value is presence information for it.
@property(strong, nonatomic, nullable, readonly) NSDictionary<NSString *, NSDictionary *> *channels;

/// Active channel subscribers unique identifiers.
@property(strong, nonatomic, nullable, readonly) id uuids;


/// Total number of subscribers.
///
/// Information available only when 'Here now' requested for list of channels and will be **0** in other case.
@property (nonatomic, readonly, strong) NSNumber *totalOccupancy;

/// Active subscribers count.
@property (nonatomic, readonly, strong) NSNumber *occupancy;

#pragma mark -


@end


#pragma mark - Interface declaration

/// Channel presence request result.
@interface PNPresenceChannelHereNowResult : PNOperationResult


#pragma mark - Properties

/// Channel presence request processing information.
@property (nonatomic, readonly, strong) PNPresenceChannelHereNowData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
