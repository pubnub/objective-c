#import <PubNub/PNObjectsAPICallBuilder.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \c Manage \c members API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNManageChannelMembersAPICallBuilder : PNObjectsAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNChannelMemberFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^includeFields)(PNChannelMemberFields includeFields);

/**
 * @brief Whether total count of objects should be included in response or not.
 *
 * @param shouldIncludeCount Whether total count of objects should be requested or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^includeCount)(BOOL shouldIncludeCount);

/**
 * @brief List of \c UUIDs which should be added to \c channel's members list.
 *
 * @note Each entry is dictionary with \c UUID and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 *
 * @param uuids List with identifiers and additional information which should be associated for each
 * of them in context of specified \c channel.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^set)(NSArray<NSDictionary *> *uuids);

/**
 * @brief List of \c UUIDs which should be removed from \c channel's list.
 *
 * @param uuids List of identifiers.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^remove)(NSArray<NSString *> *uuids);

/**
 * @brief Results sorting order.
 *
 * @param sort List of criteria (name of field) which should be used for sorting in ascending order.
 *     To change sorting order, append \c :asc (for ascending) or \c :desc (descending) to field
 *     name.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^sort)(NSArray<NSString *> *sort);

/**
 * @brief Expression to filter out results basing on specified criteria.
 *
 * @param filter Members filter expression.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^filter)(NSString *filter);

/**
 * @brief Maximum number of objects per fetched page.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 *
 * @param limit Number of objects to return in response.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Cursor value to navigate to next fetched result page.
 *
 * @param start Previously-returned cursor bookmark for fetching the next page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^start)(NSString *start);

/**
 * @brief Cursor value to navigate to previous fetched result page.

 * @note Ignored if you also supply the \c start parameter.
 *
 * @param end Previously-returned cursor bookmark for fetching the previous page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^end)(NSString *end);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Members \c manage completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNManageChannelMembersCompletionBlock block);


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
@property (nonatomic, readonly, strong) PNManageChannelMembersAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
