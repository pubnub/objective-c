#import <PubNub/PNAPICallBuilder.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Signal API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.9.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNSignalAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Channel name addition block.
 *
 * @param channel Name of the channel to which signal should be sent.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSignalAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief Signal payload addition block.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub
 * service. If client has been configured with cipher key message will be encrypted as well.
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be
 *     sent.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSignalAPICallBuilder * (^message)(id message);

/**
 * @brief User-specified message type.
 *
 * \b Important: string limited by \b 3 - \b 50 case-sensitive alphanumeric characters with only \c - and \c _ special
 * characters allowed.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSignalAPICallBuilder * (^customMessageType)(NSString *customMessageType);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Signal sending completion block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNSignalCompletionBlock _Nullable block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) PNSignalAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
