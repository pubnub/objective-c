#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Storage messages count audition API call builder.
 *
 * @since 4.8.4
 *
 * @author Serhii Mamontov
 * @since 4.8.3
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMessageCountAPICallBuilder : PNAPICallBuilder


#pragma mark Configuration

/**
 * @brief Channel names addition block / closure.
 *
 * @param channels List of channel names for which persist messages count should be fetched.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNMessageCountAPICallBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief Single timetoken or per-channel starting point timetoken addition block / closure.
 *
 * @warning API call will fail in case if number of passed timetokens doesn't match number of
 * \c channels.
 *
 * @param timetoken List with single or multiple timetokens, where each timetoken position in
 *     correspond to target \c channel location in channel names list.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNMessageCountAPICallBuilder * (^timetokens)(NSArray<NSNumber *> *timetokens);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Messages count fetch completion block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNMessageCountCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNMessageCountAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -



@end

NS_ASSUME_NONNULL_END
