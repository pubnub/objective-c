#import "PNErrorStatus.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Base class which allow to get access to general information about subscribe loop.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNSubscriberData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Name of channel for which subscriber received data.
 
 @since 4.5.2
 */
@property (nonatomic, readonly, strong) NSString *channel;

/**
 @brief  Name of \c channel or channel \c group (in case if not equal to \c channel).
 
 @since 4.5.2
 */
@property (nonatomic, nullable, readonly, strong) NSString *subscription;

/**
 @brief  Time at which event arrived.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *timetoken;

/**
 @brief  Stores reference on metadata information which has been passed along with received event.
 
 @since 4.3.0
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, id> *userMetadata;

#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNSubscribeStatus : PNErrorStatus


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Time token which has been used to establish current subscription cycle.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *currentTimetoken;

/**
 @brief  Stores reference on previous key which has been used in subscription cycle to receive
         \c currentTimetoken along with other events.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *lastTimeToken;

/**
 @brief  List of channels on which client currently subscribed.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSArray<NSString *> *subscribedChannels;

/**
 @brief  List of channel group names on which client currently subscribed.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSArray<NSString *> *subscribedChannelGroups;

/**
 @brief  Structured \b PNResult \c data field information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNSubscriberData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
