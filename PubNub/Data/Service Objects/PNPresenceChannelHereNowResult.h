#import <PubNub/PNOperationResult.h>
#import <PubNub/PNServiceData.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class which allow to get access to channel presence processed result.
 *
 * @author Serhii Mamontov
 * @version 4.15.8
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNPresenceChannelHereNowData : PNServiceData


#pragma mark - Information

/**
 * @brief Active channel subscribers unique identifiers.
 *
 * @note This object can be empty in case if only occupancy has been requested.
 * @note This object can contain list of uuids or dictionary with uuids and client state information bound to them.
 */
@property (nonatomic, nullable, readonly, strong) id uuids;

/**
 * @brief Active channels list.
 *
 * @discussion Each dictionary key represent channel name and it's value is presence information for it.
 *
 * @since 4.15.8
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, NSDictionary *> *channels;

/**
 * @brief Total number of subscribers.
 *
 * @note Information available only when 'Here now' requested for list of channels and will be \b 0 in other case.
 *
 * @since 4.15.8
 */
@property (nonatomic, readonly, strong) NSNumber *totalOccupancy;

/**
 * @brief Active subscribers count.
 */
@property (nonatomic, readonly, strong) NSNumber *occupancy;

#pragma mark -


@end


/**
 * @brief Class which is used to provide access to request processing results.
 *
 * @author Serhii Mamontov
 * @version 4.15.8
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNPresenceChannelHereNowResult : PNOperationResult


#pragma mark - Information

/**
 * @brief Channel(s) presence request processing information.
 */
@property (nonatomic, readonly, strong) PNPresenceChannelHereNowData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
