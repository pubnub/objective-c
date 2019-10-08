#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Add \c message \c action API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNAddMessageActionAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief \c Message publish timetoken.
 *
 * @param messageTimetoken Timetoken (\b PubNub's high precision timestamp) of message for which
 * \c action should be added.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNAddMessageActionAPICallBuilder * (^messageTimetoken)(NSNumber *messageTimetoken);

/**
 * @brief Channel with target \c message.
 *
 * @param channel Name of channel which store message for which \c action should be added.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNAddMessageActionAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief \c Message \c action value.
 *
 * @param value \c Value which should be stored along with \c message \c action.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNAddMessageActionAPICallBuilder * (^value)(NSString *value);

/**
 * @brief What feature this \c message \c action represents.
 *
 * @note Maximum \b 15 characters.
 *
 * @param type \c Message \c action type.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNAddMessageActionAPICallBuilder * (^type)(NSString *type);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Add \c message \c action completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNAddMessageActionCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNAddMessageActionAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
