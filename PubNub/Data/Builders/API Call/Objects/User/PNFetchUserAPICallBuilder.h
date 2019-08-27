#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c user API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchUserAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNUserFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUserAPICallBuilder * (^includeFields)(PNUserFields includeFields);

/**
 * @brief Target \c user identifier.
 *
 * @param userId Identifier of \c user which should be fetched.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUserAPICallBuilder * (^userId)(NSString *userId);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c User \c fetch completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNFetchUserCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUserAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
