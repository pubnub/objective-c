#import <PubNub/PNOperationResult.h>
#import <PubNub/PNServiceData.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class which allow to get access to global presence processed result.
 *
 * @author Sergey Mamontov
 * @version 4.15.8
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNPresenceGlobalHereNowData : PNServiceData


#pragma mark - Information

/**
 * @brief Active channels list.
 *
 * @discussion Each dictionary key represent channel name and it's value is presence information for it.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSDictionary *> *channels;

/**
 * @brief Total number of active channels.
 */
@property (nonatomic, readonly, strong) NSNumber *totalChannels;

/**
 * @brief Total number of subscribers.
 */
@property (nonatomic, readonly, strong) NSNumber *totalOccupancy;

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
@interface PNPresenceGlobalHereNowResult : PNOperationResult


#pragma mark - Information

/**
 * @brief Stores reference on global presence request processing information.
 */
@property (nonatomic, readonly, strong) PNPresenceGlobalHereNowData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
