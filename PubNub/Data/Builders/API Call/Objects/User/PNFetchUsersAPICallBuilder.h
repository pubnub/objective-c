#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c all \c users API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchUsersAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNUserFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUsersAPICallBuilder * (^includeFields)(PNUserFields includeFields);

/**
 * @brief Whether total count of \c users should be included in response or not.
 *
 * @param shouldIncludeCount Whether total count of \c users should be requested or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUsersAPICallBuilder * (^includeCount)(BOOL shouldIncludeCount);

/**
 * @brief Maximum number of \c users per fetched page.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 *
 * @param limit Number of objects to return in response.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUsersAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Cursor value to navigate to next fetched result page.
 *
 * @param start Previously-returned cursor bookmark for fetching the next page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUsersAPICallBuilder * (^start)(NSString *start);

/**
 * @brief Cursor value to navigate to previous fetched result page.
 
 * @note Ignored if you also supply the \c start parameter.
 *
 * @param end Previously-returned cursor bookmark for fetching the previous page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUsersAPICallBuilder * (^end)(NSString *end);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c All \c users \c fetch completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNFetchUsersCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUsersAPICallBuilder * (^queryParam)(NSDictionary *params);


#pragma mark -


@end

NS_ASSUME_NONNULL_END
