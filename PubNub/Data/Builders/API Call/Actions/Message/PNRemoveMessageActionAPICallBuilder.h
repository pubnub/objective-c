#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Remove \c message \c action API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNRemoveMessageActionAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief \c Message publish timetoken.
 *
 * @param messageTimetoken Timetoken (\b PubNub's high precision timestamp) of message for which
 * \c action should be removed.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMessageActionAPICallBuilder * (^messageTimetoken)(NSNumber *messageTimetoken);

/**
 * @brief Target \c action publish timetoken.
 *
 * @param actionTimetoken \c Action addition timetoken (\b PubNub's high precision timestamp).
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMessageActionAPICallBuilder * (^actionTimetoken)(NSNumber *actionTimetoken);

/**
 * @brief Channel with target \c message.
 *
 * @param channel Name of channel which store message for which \c action should be removed.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMessageActionAPICallBuilder * (^channel)(NSString *channel);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Remove \c message \c action completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNRemoveMessageActionCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMessageActionAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
