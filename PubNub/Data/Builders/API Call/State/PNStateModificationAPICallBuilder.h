#import <PubNub/PNStateAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Presence state modification API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNStateModificationAPICallBuilder : PNStateAPICallBuilder


#pragma mark Configuration

/**
 * @brief Unique user identifier addition block.
 *
 * @discussion Unique user identifier for which state should be bound. Current \b {PubNub} user id
 *     will be used by default if not set or set to \c nil.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder * (^uuid)(NSString *uuid);

/**
 * @brief User's presence state addition block.
 *
 * @discussion \a NSDictionary with data which should be bound to \c uuid on
 *     channel / channel group.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder * (^state)(NSDictionary * _Nullable state);

/**
 * @brief Channel name addition block.
 *
 * @discussion Name of the channel which will store provided state information for \c uuid.
 *
 * @deprecated 4.8.3
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder * (^channel)(NSString *channel)
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 4.8.3. Please use 'channels' "
                             "method instead.");

/**
 * @brief Channel names addition block.
 *
 * @discussion List of the channel names which will store provided state information for \c uuid.
 *
 * @since 4.8.3
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief Channel group name addition block.
 *
 * @discussion Name of channel group which will store provided state information for
 *     \c uuid.
 *
 * @deprecated 4.8.3
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder * (^channelGroup)(NSString *channelGroup)
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 4.8.3. Please use 'channelGroups' "
                             "method instead.");

/**
 * @brief Channel group names addition block.
 *
 * @discussion List of channel group names which will store provided state information for
 *     \c uuid.
 *
 * @since 4.8.3
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder * (^channelGroups)(NSArray<NSString *> *channelGroups);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @discussion State modification for user on channel completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNSetStateCompletionBlock _Nullable block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @discussion List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.2
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
