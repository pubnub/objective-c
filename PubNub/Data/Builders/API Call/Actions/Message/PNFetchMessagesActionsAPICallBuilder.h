#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c messages \c actions API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchMessagesActionsAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Channel with \c messages for which \c actions should be fetched.
 *
 * @param channel Name of channel from which list of \c messages \c actions should be retrieved.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMessagesActionsAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief Maximum number of \c messages \c actions to return in response.
 *
 * @param limit Number of \c messages \c actions to return in response.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMessagesActionsAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief \c Messages \c actions timetoken denoting the start of the range requested.
 *
 * @note Return values will be less than start.
 *
 * @param start Previously-returned \c messages \c actions timetoken denoting the start of the range
 * requested.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMessagesActionsAPICallBuilder * (^start)(NSNumber *start);

/**
 * @brief \c Messages \c actions timetoken denoting the end of the range requested.
 *
 * @note Return values will be greater than or equal to end.
 *
 * @param end Previously-returned \c messages \c actions timetoken denoting the end of the range
 * requested.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMessagesActionsAPICallBuilder * (^end)(NSNumber *end);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Fetch \c messages \c actions completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNFetchMessageActionsCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMessagesActionsAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
