#import <PubNub/PNObjectsAPICallBuilder.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Manage \c memberships API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNManageMembershipsAPICallBuilder : PNObjectsAPICallBuilder


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
 * @brief Whether total count of objects should be included in response or not.
 *
 * @param shouldIncludeCount Whether total count of objects should be requested or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^includeCount)(BOOL shouldIncludeCount);

/**
 * @brief List of \c channels within which \c UUID should be \c member.
 *
 * @note Each entry is dictionary with \c channel and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 *
 * @param channels List with \c channel names and additional information which should be associated
 * for \c UUID in context of specified \c channel.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^set)(NSArray<NSDictionary *> *channels);

/**
 * @brief List of \c channels from which \c UUID should be removed as \c member.
 *
 * @param channels List of \c channel name.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^remove)(NSArray<NSString *> *channels);

/**
 * @brief Results sorting order.
 *
 * @param sort List of criteria (name of field) which should be used for sorting in ascending order.
 *     To change sorting order, append \c :asc (for ascending) or \c :desc (descending) to field
 *     name.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^sort)(NSArray<NSString *> *sort);

/**
 * @brief Expression to filter out results basing on specified criteria.
 *
 * @param filter Memberships filter expression.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^filter)(NSString *filter);

/**
 * @brief Maximum number of objects per response page.
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
 * @brief Identifier for which memberships should be managed.

 * @note Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @param uuid Unique identifier for membership.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^uuid)(NSString *uuid);

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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
