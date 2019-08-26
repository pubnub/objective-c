#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Manage \c memberships API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNManageMembershipsAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNMembershipFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^includeFields)(PNMembershipFields includeFields);

/**
 * @brief List of \c spaces for which additional information associated with \c user should be
 * updated.
 *
 * @param spaces List with \c spaces and additional information which should be changed for \c user
 * in context of specified \c space.
 *
 * @note Each entry is dictionary with \c spaceId and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^update)(NSArray<NSDictionary *> *spaces);

/**
 * @brief Whether total count of \c memberships should be included in response or not.
 *
 * @param shouldIncludeCount Whether total count of \c memberships should be requested or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^includeCount)(BOOL shouldIncludeCount);

/**
 * @brief List of \c spaces which should be added to \c user's memberships.
 *
 * @param spaces List of \c spaces and additional information which should be associated with
 * \c user in context of specified \c space (if \c custom field is set).
 *
 * @note Each entry is dictionary with \c spaceId and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^add)(NSArray<NSDictionary *> *spaces);

/**
 * @brief List of \c spaces (their identifiers) which should be removed from \c user's memberships.
 *
 * @param spaces List of \c space identifiers.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^remove)(NSArray<NSString *> *spaces);

/**
 * @brief Target \c user identifier.
 *
 * @param userId Identifier of \c user for which memberships will be updated.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^userId)(NSString *userId);

/**
 * @brief Maximum number of \c memberships per response page.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 *
 * @param limit Number of objects to return in response.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Cursor value to navigate to next fetched result page.
 *
 * @param start Previously-returned cursor bookmark for fetching the next page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^start)(NSString *start);

/**
 * @brief Cursor value to navigate to previous fetched result page.

 * @note Ignored if you also supply the \c start parameter.
 *
 * @param end Previously-returned cursor bookmark for fetching the previous page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^end)(NSString *end);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Memberships \c update completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNManageMembershipsCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
