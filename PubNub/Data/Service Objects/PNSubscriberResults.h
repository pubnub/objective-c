#import "PNSubscribeStatus.h"
#import "PNServiceData.h"
#import "PNResult.h"


#pragma mark Class forward

@class PNMessageAction;



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
 * @brief Class which allow to get access to \c action body received from remote object live feed.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMessageActionData : PNSubscriberData


#pragma mark - Information

/**
 * @brief \c Action for which event has been received.
 */
@property (nonatomic, readonly, strong) PNMessageAction *action;

/**
 * @brief Name of action for which \c message \c action event has been sent.
 */
@property (nonatomic, readonly, copy) NSString *event;


#pragma mark -


@end


/**
 * @brief Class which allow to get access to \c membership event body received from remote object
 * live feed.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMembershipEventData : PNSubscriberData


#pragma mark - Information

/**
 * @brief Additional information which has been associated with \c user during \c space
 * \c membership \c create / \c update requests.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary *custom;

/**
 * @brief \c Membership creation date.
 */
@property (nonatomic, nullable, readonly, strong) NSDate *created;

/**
 * @brief \c Membership modification date or \c nil if removed.
 */
@property (nonatomic, nullable, readonly, strong) NSDate *updated;

/**
 * @brief Time when \c membership event has been triggered.
 *
 * @return Number with unsugned long long timestamp.
 */
@property (nonatomic, readonly, strong) NSNumber *timestamp;

/**
 * @brief Identifier of \c space wihthin which \c user has membership.
 */
@property (nonatomic, readonly, strong) NSString *spaceId;

/**
 * @brief Identifier of \c user for which \c membership has been \c created / \c updated /
 * \c deleted.
 */
@property (nonatomic, readonly, strong) NSString *userId;

/**
 * @brief Name of action for which \c membership event has been sent.
 */
@property (nonatomic, readonly, assign) NSString *event;

/**
 * @brief \c Membership object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end


/**
 * @brief Class which allow to get access to \c space event body received from remote object live
 * feed.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNSpaceEventData : PNSubscriberData


#pragma mark - Information

/**
 * @brief List of \c space model properties which has been changed.
 *
 * @note Event notify only about changed fields (rest remain the same as it was during \c space
 * \c create or previous \c update requests).
 */
@property (nonatomic, readonly, strong) NSArray<NSString *> *modifiedFields;

/**
 * @brief Additional / complex attributes which has been associated with \c space during \c space
 * \c create / \c update requests.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary *custom;

/**
 * @brief Additional information about \c space.
 */
@property (nonatomic, nullable, readonly, copy) NSString *information;

/**
 * @brief \c Space data modification date or \c nil if removed.
 */
@property (nonatomic, nullable, readonly, strong) NSDate *updated;

/**
 * @brief Name which has been associated with \c user.
 */
@property (nonatomic, nullable, readonly, copy) NSString *name;

/**
 * @brief \c Space identifier.
 */
@property (nonatomic, readonly, strong) NSString *identifier;

/**
 * @brief Time when \c space event has been triggered.
 *
 * @return Number with unsugned long long timestamp.
 */
@property (nonatomic, readonly, strong) NSNumber *timestamp;

/**
 * @brief Name of action for which \c user event has been sent.
 */
@property (nonatomic, readonly, assign) NSString *event;

/**
 * @brief \c User object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end


/**
 * @brief Class which allow to get access to \c user event body received from remote object live
 * feed.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUserEventData : PNSubscriberData


#pragma mark - Information

/**
 * @brief List of \c user model properties which has been changed.
 *
 * @note Event notify only about changed fields (rest remain the same as it was during \c user
 * \c create or previous \c update requests).
 */
@property (nonatomic, readonly, strong) NSArray<NSString *> *modifiedFields;

/**
 * @brief Additional / complex attributes which has been associated with \c user during \c user
 * \c create / \c update requests.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary *custom;

/**
 * @brief \c User identifier from external service (database, auth service).
 */
@property (nonatomic, nullable, readonly, copy) NSString *externalId;

/**
 * @brief URL at which \c user's profile available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *profileUrl;

/**
 * @brief Email address which has been associated with \c user.
 */
@property (nonatomic, nullable, readonly, copy) NSString *email;

/**
 * @brief Name which has been associated with \c user.
 */
@property (nonatomic, nullable, readonly, copy) NSString *name;

/**
 * @brief \c User identifier.
 */
@property (nonatomic, readonly, strong) NSString *identifier;

/**
 * @brief Time when \c user event has been triggered.
 */
@property (nonatomic, readonly, strong) NSNumber *timestamp;

/**
 * @brief Name of action for which \c user event has been sent.
 */
@property (nonatomic, readonly, assign) NSString *event;

/**
 * @brief \c User data modification date.
 */
@property (nonatomic, readonly, strong) NSDate *updated;

/**
 * @brief \c User object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

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
 * @brief Signal object from live feed.
 */
@property (nonatomic, readonly, strong) PNSignalData *data;

#pragma mark -


@end


/**
 * @brief Class which is used to provide access to subscribe request processing results.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMessageActionResult : PNResult


#pragma mark - Information

/**
 * @brief \c Message \c action object from live feed.
 */
@property (nonatomic, readonly, strong) PNMessageActionData *data;

#pragma mark -


@end


/**
 * @brief Class which is used to provide access to request processing results.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUserEventResult : PNResult


#pragma mark - Information

/**
 * @brief \c User event object from live feed.
 */
@property (nonatomic, readonly, strong) PNUserEventData *data;

#pragma mark -


@end


/**
 * @brief Class which is used to provide access to request processing results.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNSpaceEventResult : PNResult


#pragma mark - Information

/**
 * @brief \c Space event object from live feed.
 */
@property (nonatomic, readonly, strong) PNSpaceEventData *data;

#pragma mark -


@end


/**
 * @brief Class which is used to provide access to request processing results.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMembershipEventResult : PNResult


#pragma mark - Information

/**
 * @brief \c Membership event object from live feed.
 */
@property (nonatomic, readonly, strong) PNMembershipEventData *data;

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
