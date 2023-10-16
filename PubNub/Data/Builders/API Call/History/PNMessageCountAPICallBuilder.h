#import <PubNub/PNAPICallBuilder.h>
#import <PubNub/PNStructures.h>


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
 * @discussion List of channel names for which persist messages count should be fetched.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNMessageCountAPICallBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief Single timetoken or per-channel starting point timetoken addition block / closure.
 *
 * @discussion List with single or multiple timetokens, where each timetoken position in
 *     correspond to target \c channel location in channel names list.
 *
 * @warning API call will fail in case if number of passed timetokens doesn't match number of
 * \c channels.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNMessageCountAPICallBuilder * (^timetokens)(NSArray<NSNumber *> *timetokens);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @discussion Messages count fetch completion block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNMessageCountCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @discussion List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) PNMessageCountAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -



@end

NS_ASSUME_NONNULL_END
