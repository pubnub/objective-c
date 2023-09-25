#import <PubNub/PNStateAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Presence state audit API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNStateAuditAPICallBuilder : PNStateAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Unique user identifier addition block.
 *
 * @discussion Unique user identifier for which state should be retrieved. Current \b {PubNub} user
 *     id will be used by default if not set or set to \c nil.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder * (^uuid)(NSString *uuid);

/**
 * @brief Channel name addition block.
 *
 * @discussion Name of channel from which state information for \c uuid will be pulled out.
 *
 * @return API call configuration builder.
 *
 * @deprecated 4.8.3
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder * (^channel)(NSString *channel)
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 4.8.3. Please use 'channels' "
                             "method instead.");

/**
 * @brief Channel names addition block.
 *
 * @discussion List of the channel names from which state information for \c uuid will be
 *     pulled out.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.3
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief Channel group name addition block.
 *
 * @discussion Name of channel group from which state information for \c uuid will be
 *     pulled out.
 *
 * @return API call configuration builder.
 *
 * @deprecated 4.8.3
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder * (^channelGroup)(NSString *channelGroup)
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 4.8.3. Please use 'channelGroups' "
                             "method instead.");

/**
 * @brief Channel group names addition block.
 *
 * @discussion List of channel group names from which state information for \c uuid will be
 *     pulled out.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.3
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder * (^channelGroups)(NSArray<NSString *> *channelGroups);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @discussion State audition for user on channel / channel group completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNGetStateCompletionBlock block);


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
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
