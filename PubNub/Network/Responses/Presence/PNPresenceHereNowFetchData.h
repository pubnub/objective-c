#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// User presence information.
@interface PNPresenceUUIDData : NSObject


#pragma mark - Properties

/// State which has been associated with user while he is active in specific channel.
@property(strong, nonatomic, nullable, readonly) id state;

/// Unique user identifier.
@property(strong, nonatomic, readonly) NSString *uuid;

#pragma mark -


@end


#pragma mark - Interface declaration

/// Channel presence information.
@interface PNPresenceChannelData : NSObject


#pragma mark - Properties

/// List of active users.
@property(strong, nonatomic, nullable, readonly) NSArray<PNPresenceUUIDData *> *uuids;

/// Number of active users in channel.
@property(strong, nonatomic, readonly) NSNumber *occupancy;

#pragma mark -


@end


#pragma mark - Interface declaration

/// Here now presence request response.
@interface PNPresenceHereNowFetchData : PNBaseOperationData


#pragma mark - Properties

/// Active channels list.
///
/// Each dictionary key represent channel name and it's value is presence information for it.
@property(strong, nonatomic, readonly) NSDictionary<NSString *, PNPresenceChannelData *> *channels;

/// Total number of subscribers.
@property(strong, nonatomic, readonly) NSNumber *totalOccupancy;

/// Total number of active channels.
@property(strong, nonatomic, readonly) NSNumber *totalChannels;

/// Index of next page which can be used for ``offset``.
///
/// > Note: `-1` will be returned if there is are more pages.
@property(strong, nonatomic, readonly) NSNumber *next;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
