#import <PubNub/PNObjectsAPICallBuilder.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c metadata associated with all \c UUIDs API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchAllUUIDMetadataAPICallBuilder : PNObjectsAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNUUIDFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataAPICallBuilder * (^includeFields)(PNUUIDFields includeFields);

/**
 * @brief Whether total count of objects should be included in response or not.
 *
 * @param shouldIncludeCount Whether total count of objects should be requested or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataAPICallBuilder * (^includeCount)(BOOL shouldIncludeCount);

/**
 * @brief Results sorting order.
 *
 * @param sort List of criteria (name of field) which should be used for sorting in ascending order.
 *     To change sorting order, append \c :asc (for ascending) or \c :desc (descending) to field
 *     name.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataAPICallBuilder * (^sort)(NSArray<NSString*> *sort);

/**
 * @brief Expression to filter out results basing on specified criteria.
 *
 * @param filter Objects filter expression.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataAPICallBuilder * (^filter)(NSString *filter);

/**
 * @brief Maximum number of objects per fetched page.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 *
 * @param limit Number of objects to return in response.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Cursor value to navigate to next fetched result page.
 *
 * @param start Previously-returned cursor bookmark for fetching the next page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataAPICallBuilder * (^start)(NSString *start);

/**
 * @brief Cursor value to navigate to previous fetched result page.
 
 * @note Ignored if you also supply the \c start parameter.
 *
 * @param end Previously-returned cursor bookmark for fetching the previous page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataAPICallBuilder * (^end)(NSString *end);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Associated \c metadata \c fetch completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNFetchAllUUIDMetadataCompletionBlock block);


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
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
