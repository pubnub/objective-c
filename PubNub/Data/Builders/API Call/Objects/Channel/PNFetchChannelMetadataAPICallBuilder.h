#import <PubNub/PNObjectsAPICallBuilder.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c metadata associated with \c channel API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchChannelMetadataAPICallBuilder : PNObjectsAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNChannelFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchChannelMetadataAPICallBuilder * (^includeFields)(PNChannelFields includeFields);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Associated \c metadata \c fetch completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNFetchChannelMetadataCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) PNFetchChannelMetadataAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
