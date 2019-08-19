#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Create \c space API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNCreateSpaceAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNSpaceFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateSpaceAPICallBuilder * (^includeFields)(PNSpaceFields includeFields);

/**
 * @brief \c Space's description.
 *
 * @param externalId Space description information.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateSpaceAPICallBuilder * (^information)(NSString *information);

/**
 * @brief \c Space's additional information.
 *
 * @param custom Additional / complex attributes which should be associated to \c space with
 * specified \c identifier.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateSpaceAPICallBuilder * (^custom)(NSDictionary *custom);

/**
 * @brief \c Space's unique identifier.
 *
 * @param userId Unique identifier for new \c space entry.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateSpaceAPICallBuilder * (^spaceId)(NSString *spaceId);

/**
 * @brief \c Space's name.
 *
 * @param name Name which should be associated with new \c space entry.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateSpaceAPICallBuilder * (^name)(NSString *name);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Space \c create completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNCreateSpaceCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateSpaceAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
