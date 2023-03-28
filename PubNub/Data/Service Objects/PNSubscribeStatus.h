#import "PNErrorStatus.h"
#import "PNServiceData.h"


#pragma mark Class forward

@class PNMessageType, PNSpaceId;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/**
 * @brief Base class which allow to get access to general information about subscribe loop.
 *
 * @author Serhii Mamontov
 * @version 5.2.0
 * @since 4.0.0
 * @copyright © 2010-2022 PubNub, Inc.
 */
@interface PNSubscriberData : PNServiceData


#pragma mark - Information

/**
 * @brief  Name of channel for which subscriber received data.
 *
 * @since 4.5.2
 */
@property (nonatomic, readonly, strong) NSString *channel;

/**
 * @brief Identifier to which message originally has been published.
 *
 * @since 5.2.0
 */
@property (nonatomic, nullable, readonly, strong) PNSpaceId *spaceId;

/**
 * @brief  Name of \c channel or channel \c group (in case if not equal to \c channel).
 *
 * @since 4.5.2
 */
@property (nonatomic, nullable, readonly, strong) NSString *subscription;

/**
 * @brief Time at which event arrived.
 */
@property (nonatomic, readonly, strong) NSNumber *timetoken;

/**
 * @brief User-provided type of message which has been published.
 *
 * @since 5.2.0
 */
@property (nonatomic, nullable, readonly, strong) NSString *type;

/**
 * @brief Stores reference on metadata information which has been passed along with received event.
 *
 * @since 4.3.0
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, id> *userMetadata;

#pragma mark -


@end


/**
 * @brief Class which is used to provide access to request processing results.
 *
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNSubscribeStatus : PNErrorStatus


#pragma mark - Information

/**
 * @brief Time token which has been used to establish current subscription cycle.
 */
@property (nonatomic, readonly, strong) NSNumber *currentTimetoken;

/**
 * @brief Stores reference on previous key which has been used in subscription cycle to receive
 * \c currentTimetoken along with other events.
 */
@property (nonatomic, readonly, strong) NSNumber *lastTimeToken;

/**
 * @brief List of channels on which client currently subscribed.
 */
@property (nonatomic, readonly, copy) NSArray<NSString *> *subscribedChannels;

/**
 * @brief List of channel group names on which client currently subscribed.
 */
@property (nonatomic, readonly, copy) NSArray<NSString *> *subscribedChannelGroups;

/**
 * @brief Structured \b PNResult \c data field information.
 */
@property (nonatomic, readonly, strong) PNSubscriberData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
