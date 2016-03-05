#import "PNResult.h"
#import "PNServiceData.h"
#import "PNSubscribeStatus.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which allow to get access to detailed presence information which has been received on remote
         data object's live feed.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNPresenceDetailsData : PNSubscriberData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Time when presence event has been triggered.
 
 @return Number with unsugned long long timestamp.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *timetoken;

/**
 @brief  Reference on unique user identifier for which event has been triggered.
 
 @return UUID string.
 
 @since 4.0
 */
@property (nonatomic, nullable, readonly, strong) NSString *uuid;

/**
 @brief  Channel presence information.
 
 @return Number of subscribers which become after presence event has been triggered.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *occupancy;

/**
 @brief  User changed client state.
 
 @return In case of state change presence event will contain actual client state infotmation for \c -uuid.
 
 @since 4.0
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, id> *state;

#pragma mark -


@end


/**
 @brief  Class which allow to get access to general presence information which has been received
         on remote data object's live feed.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNPresenceEventData : PNSubscriberData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Type of presence event.
 
 @return One of available presence event types.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSString *presenceEvent;

/**
 @brief  Additional presence information.
 
 @return Object which has additional information about arrived presence event.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNPresenceDetailsData *presence;

#pragma mark -


@end


/**
 @brief  Class which allow to get access to message body received from remote object live feed.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNMessageData : PNSubscriberData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Message which has been delivered through data object live feed.
 
 @return De-serialized message object.
 
 @since 4.0
 */
@property (nonatomic, nullable, readonly, strong) id message;

#pragma mark - 


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNMessageResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on message object from live feed.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNMessageData *data;

#pragma mark - 


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNPresenceEventResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on presence event object from live feed.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNPresenceEventData *data;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
