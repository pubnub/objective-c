#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

@interface PNFetchMembershipsAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNMembershipFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^includeFields)(PNMembershipFields includeFields);

/**
 * @brief Whether total count of \c memberships should be included in response or not.
 *
 * @param shouldIncludeCount Whether total count of \c memberships should be requested or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^includeCount)(BOOL shouldIncludeCount);

/**
 * @brief Target \c user identifier.
 *
 * @param userId Identifier of \c user for which memberships will be fetched.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^userId)(NSString *userId);

/**
 * @brief Maximum number of \c memberships per fetched page.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 *
 * @param limit Number of objects to return in response.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Cursor value to navigate to next fetched result page.
 *
 * @param start Previously-returned cursor bookmark for fetching the next page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^start)(NSString *start);

/**
 * @brief Cursor value to navigate to previous fetched result page.
 
 * @note Ignored if you also supply the \c start parameter.
 *
 * @param end Previously-returned cursor bookmark for fetching the previous page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^end)(NSString *end);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Memberships \c fetch completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNFetchMembershipsCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
