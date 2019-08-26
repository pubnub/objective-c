#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Update \c user API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUpdateUserAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNUserFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateUserAPICallBuilder * (^includeFields)(PNUserFields includeFields);

/**
 * @brief \c User's external identifier.
 *
 * @param externalId User identifier from external service (database, auth service).
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateUserAPICallBuilder * (^externalId)(NSString *externalId);

/**
 * @brief \c User's profile URL.
 *
 * @param profileUrl URL at which user's profile available.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateUserAPICallBuilder * (^profileUrl)(NSString *profileUrl);

/**
 * @brief \c User's additional information.
 *
 * @param custom Additional / complex attributes which should be associated to \c user with
 * specified \c identifier.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateUserAPICallBuilder * (^custom)(NSDictionary *custom);

/**
 * @brief Target \c user identifier.
 *
 * @param userId Identifier of \c user for which data will be updated.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateUserAPICallBuilder * (^userId)(NSString *userId);

/**
 * @brief \c User's email address.
 *
 * @param email Email address which should be associated to \c user with specified \c identifier.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateUserAPICallBuilder * (^email)(NSString *email);

/**
 * @brief \c User's name.
 *
 * @param name Name which should be associated to \c user with specified \c identifier.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateUserAPICallBuilder * (^name)(NSString *name);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c User \c update completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNUpdateUserCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateUserAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
