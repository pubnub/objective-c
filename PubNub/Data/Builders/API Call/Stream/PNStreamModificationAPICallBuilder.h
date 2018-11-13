#import "PNStreamAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stream modification API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNStreamModificationAPICallBuilder : PNStreamAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Channel group addition block.
 *
 * @param channelGroup Name of the group which should be used for manipulation.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamModificationAPICallBuilder * (^channelGroup)(NSString *channelGroup);

/**
 * @brief Channel names list addition block.
 *
 * @note It is possible to remove all channels from group by passing \c nil during \c remove.
 *
 * @param channels List of channels names which should be used for \c group modification.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamModificationAPICallBuilder * (^channels)(NSArray<NSString *> *channels);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Channel group manipulation completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNChannelGroupChangeCompletionBlock _Nullable block);


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
@property (nonatomic, readonly, strong) PNStreamModificationAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
