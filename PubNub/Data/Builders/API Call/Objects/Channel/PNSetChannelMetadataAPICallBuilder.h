#import "PNObjectsAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Metadata association with \c channel API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSetChannelMetadataAPICallBuilder : PNObjectsAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNChannelFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetChannelMetadataAPICallBuilder * (^includeFields)(PNChannelFields includeFields);

/**
 * @brief Description which should be stored in \c metadata associated with specified \c channel.
 *
 * @param information Entity description.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetChannelMetadataAPICallBuilder * (^information)(NSString *information);

/**
 * @brief Additional information which should be stored in \c metadata associated with
 * specified \c channel.
 *
 * @param custom Dictionary with simple scalar values (\a NSString, \a NSNumber).
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetChannelMetadataAPICallBuilder * (^custom)(NSDictionary *custom);

/**
 * @brief Name which should stored in \c metadata associated with specified \c channel.
 *
 * @param name Entity name.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetChannelMetadataAPICallBuilder * (^name)(NSString *name);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Metadata association completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNSetChannelMetadataCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetChannelMetadataAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
