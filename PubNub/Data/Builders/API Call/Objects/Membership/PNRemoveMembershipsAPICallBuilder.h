#import "PNObjectsAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Remove \c memberships API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNRemoveMembershipsAPICallBuilder : PNObjectsAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNMembershipFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^includeFields)(PNMembershipFields includeFields);

/**
 * @brief List of \c channels from which \c UUID should be removed as \c member.
 *
 * @param channels List of \c channel name.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief Whether total count of objects should be included in response or not.
 *
 * @param shouldIncludeCount Whether total count of objects should be requested or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^includeCount)(BOOL shouldIncludeCount);

/**
 * @brief Results sorting order.
 *
 * @param sort List of criteria (name of field) which should be used for sorting in ascending order.
 *     To change sorting order, append \c :asc (for ascending) or \c :desc (descending) to field
 *     name.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^sort)(NSArray<NSString *> *sort);

/**
 * @brief Expression to filter out results basing on specified criteria.
 *
 * @param filter Memberships filter expression.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^filter)(NSString *filter);

/**
 * @brief Maximum number of objects per response page.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 *
 * @param limit Number of objects to return in response.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Cursor value to navigate to next fetched result page.
 *
 * @param start Previously-returned cursor bookmark for fetching the next page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^start)(NSString *start);

/**
 * @brief Identifier for which memberships should be removed.

 * @note Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @param uuid Unique identifier for membership.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^uuid)(NSString *uuid);

/**
 * @brief Cursor value to navigate to previous fetched result page.

 * @note Ignored if you also supply the \c start parameter.
 *
 * @param end Previously-returned cursor bookmark for fetching the previous page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^end)(NSString *end);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Memberships \c remove completion handler block.
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
@property (nonatomic, readonly, strong) PNRemoveMembershipsAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
