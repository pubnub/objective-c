#import <PubNub/PNObjectsAPICallBuilder.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Associated with \c UUID \c metadata remove API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNRemoveUUIDMetadataAPICallBuilder : PNObjectsAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Identifier for which associated \c metadata should be removed.
 *
 * @param uuid Unique identifier for metadata.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveUUIDMetadataAPICallBuilder * (^uuid)(NSString *uuid);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Associated \c metadata \c remove completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNRemoveUUIDMetadataCompletionBlock block);


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
@property (nonatomic, readonly, strong) PNRemoveUUIDMetadataAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
