#import "PNStreamAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stream audit API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNStreamAuditAPICallBuilder : PNStreamAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Channel group addition block.
 *
 * @param channelGroup Name of the group from which channels should be fetched.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamAuditAPICallBuilder * (^channelGroup)(NSString *channelGroup);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Channels audition completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNGroupChannelsAuditCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.2
 */
@property (nonatomic, readonly, strong) PNStreamAuditAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
