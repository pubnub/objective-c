#import "PNObjectsAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Metadata association with \c UUID API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSetUUIDMetadataAPICallBuilder : PNObjectsAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNUUIDFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataAPICallBuilder * (^includeFields)(PNUUIDFields includeFields);

/**
 * @brief External identifier (database, auth service) associated with specified \c UUID.
 *
 * @param externalId External identifier.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataAPICallBuilder * (^externalId)(NSString *externalId);

/**
 * @brief External URL with information for specified \c UUID representation.
 *
 * @param profileUrl External URL (not managed by PubNub).
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataAPICallBuilder * (^profileUrl)(NSString *profileUrl);

/**
 * @brief Additional information which should be stored in \c metadata associated with
 * specified \c UUID.
 *
 * @param custom Dictionary with simple scalar values (\a NSString, \a NSNumber).
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataAPICallBuilder * (^custom)(NSDictionary *custom);

/**
 * @brief Email address which should be stored in \c metadata associated with specified \c UUID.
 *
 * @param email Valid email address.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataAPICallBuilder * (^email)(NSString *email);

/**
 * @brief Identifier with which new \c metadata should be associated.
 *
 * @param uuid Unique identifier for metadata.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataAPICallBuilder * (^uuid)(NSString *uuid);

/**
 * @brief Name which should stored in \c metadata associated with specified \c UUID.
 *
 * @param name Entity name.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataAPICallBuilder * (^name)(NSString *name);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Metadata association completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNSetUUIDMetadataCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSetUUIDMetadataAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
