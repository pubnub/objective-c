#import "PNSubscribeStatus.h"
#import "PNServiceData.h"
#import "PNResult.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class which allow to get access to detailed presence information which has been received
 * on remote data object's live feed.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNPresenceDetailsData : PNSubscriberData


#pragma mark - Information

/**
 * @brief Time when presence event has been triggered.
 *
 * @return Number with unsugned long long timestamp.
 */
@property (nonatomic, readonly, strong) NSNumber *timetoken;

/**
 * @brief Unique user identifier for which event has been triggered.
 *
 * @return UUID string.
 */
@property (nonatomic, nullable, readonly, strong) NSString *uuid;

/**
 * @brief List of newly joined subscribers' UUID.
 *
 * @note Value set (if data available) only for \c interval presence events.
 *
 * @return List of UUIDs for subscribers which joined channel since last interval or regular
 * presence event has been received.
 *
 * @since 4.5.16
 */
@property (nonatomic, nullable, readonly, strong) NSArray<NSString *> *join;

/**
 * @brief List of recently leaved subscribers' UUID.
 *
 * @note Value set (if data available) only for \c interval presence events.
 *
 * @return List of UUIDs for subscribers which leaved channel since last interval or regular
 * presence event has been received.
 *
 * @since 4.5.16
 */
@property (nonatomic, nullable, readonly, strong) NSArray<NSString *> *leave;

/**
 * @brief List of recently UUID of subscribers which leaved by timeout.
 *
 * @note Value set (if data available) only for \c interval presence events.
 *
 * @return List of UUIDs for subscribers which leaved channel by timeout since last interval or
 * regular presence event has been received.
 *
 * @since 4.5.16
 */
@property (nonatomic, nullable, readonly, strong) NSArray<NSString *> *timeout;

/**
 * @brief Channel presence information.
 *
 * @return Number of subscribers which become after presence event has been triggered.
 */
@property (nonatomic, readonly, strong) NSNumber *occupancy;

/**
 * @brief  User changed client state.
 *
 * @return In case of state change presence event will contain actual client state infotmation for
 * \c -uuid.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, id> *state;

#pragma mark -


@end


/**
 * @brief Class which allow to get access to general presence information which has been received
 * on remote data object's live feed.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNPresenceEventData : PNSubscriberData


#pragma mark - Information

/**
 * @brief Type of presence event.
 *
 * @return One of available presence event types.
 */
@property (nonatomic, readonly, strong) NSString *presenceEvent;

/**
 * @brief Additional presence information.
 *
 * @return Object which has additional information about arrived presence event.
 */
@property (nonatomic, readonly, strong) PNPresenceDetailsData *presence;

#pragma mark -


@end


/**
 * @brief Class which allow to get access to message body received from remote object live feed.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMessageData : PNSubscriberData


#pragma mark - Information

/**
 * @brief Message sender identifier.
 *
 * @discussion Unique identifier of configured remote client which sent this \c message.
 *
 * @since 4.5.6
*/
@property (nonatomic, readonly, strong) NSString *publisher;

/**
 * @brief Message which has been delivered through data object live feed.
 *
 * @return De-serialized message object.
 */
@property (nonatomic, nullable, readonly, strong) id message;

#pragma mark - 


@end


/**
 * @brief Class which is used to provide access to request processing results.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMessageResult : PNResult


#pragma mark - Information

/**
 * @brief Stores reference on message object from live feed.
 */
@property (nonatomic, readonly, strong) PNMessageData *data;

#pragma mark - 


@end


/**
 * @brief Class which allow to get access to signal body received from remote object live feed.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.9.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNSignalData : PNMessageData


#pragma mark -


@end


/**
 * @brief Class which is used to provide access to subscribe request processing results.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.9.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNSignalResult : PNResult


#pragma mark - Information

/**
 * @brief Stores reference on message object from live feed.
 */
@property (nonatomic, readonly, strong) PNSignalData *data;

#pragma mark -


@end


/**
 * @brief Class which is used to provide access to request processing results.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNPresenceEventResult : PNResult


#pragma mark - Information

/**
 * @brief Stores reference on presence event object from live feed.
 */
@property (nonatomic, readonly, strong) PNPresenceEventData *data;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
