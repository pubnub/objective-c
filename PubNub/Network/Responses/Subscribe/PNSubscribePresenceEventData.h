#import <PubNub/PNSubscribeMessageEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Presence event` details.
@interface PNSubscribePresenceEventDetails : NSObject


#pragma mark - Properties

/// Time when presence event has been triggered.
@property (nonatomic, readonly, strong) NSNumber *timetoken;

/// Unique user identifier for which event has been triggered.
@property (nonatomic, nullable, readonly, strong) NSString *uuid;

/// List of newly joined subscribers' UUID.
///
/// List of UUIDs for subscribers which joined channel since last interval or regular presence event has been received.
///
/// > Note: Value set (if data available) only for `interval` presence events.
@property (nonatomic, nullable, readonly, strong) NSArray<NSString *> *join;

/// List of recently leaved subscribers' UUID.
///
/// List of UUIDs for subscribers which leaved channel since last interval or regular presence event has been received.
///
/// > Note: Value set (if data available) only for `interval` presence events.
@property (nonatomic, nullable, readonly, strong) NSArray<NSString *> *leave;

/// List of recently UUID of subscribers which leaved by timeout.
///
/// List of UUIDs for subscribers which leaved channel by timeout since last interval or regular presence event has been
/// received.
///
/// > Note: Value set (if data available) only for `interval` presence events.
@property (nonatomic, nullable, readonly, strong) NSArray<NSString *> *timeout;

/// Channel presence information.
///
/// Number of subscribers which become after presence event has been triggered.
@property (nonatomic, readonly, strong) NSNumber *occupancy;

/// User changed client state.
///
/// In case of state change presence event will contain actual client state infotmation for ``uuid``.
@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, id> *state;

#pragma mark -


@end


#pragma mark - Interface implementation

/// `Presence event` data.
@interface PNSubscribePresenceEventData : PNSubscribeMessageEventData


#pragma mark - Properties

/// Additional presence information.
@property(strong, nonatomic, readonly) PNSubscribePresenceEventDetails *presence;

///Type of presence event.
@property(strong, nonatomic, readonly) NSString *presenceEvent;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
