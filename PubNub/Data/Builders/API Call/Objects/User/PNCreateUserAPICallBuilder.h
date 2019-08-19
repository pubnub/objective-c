#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Create \c user API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNCreateUserAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNUserFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateUserAPICallBuilder * (^includeFields)(PNUserFields includeFields);

/**
 * @brief \c User's external identifier.
 *
 * @param externalId \c User identifier from external service (database, auth service).
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateUserAPICallBuilder * (^externalId)(NSString *externalId);

/**
 * @brief \c User's profile URL.
 *
 * @param profileUrl URL at which user's profile available.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateUserAPICallBuilder * (^profileUrl)(NSString *profileUrl);

/**
 * @brief \c User's additional information.
 *
 * @param custom Additional / complex attributes which should be associated to \c user with
 * specified \c identifier.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateUserAPICallBuilder * (^custom)(NSDictionary *custom);

/**
 * @brief \c User's unique identifier.
 *
 * @param userId Unique identifier for new \c user entry.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateUserAPICallBuilder * (^userId)(NSString *userId);

/**
 * @brief \c User's email address.
 *
 * @param email Email address which should be associated to \c user with specified \c identifier.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateUserAPICallBuilder * (^email)(NSString *email);

/**
 * @brief \c User's name.
 *
 * @param name Name which should be associated with new \c user entry.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateUserAPICallBuilder * (^name)(NSString *name);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c User \c create completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNCreateUserCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateUserAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
