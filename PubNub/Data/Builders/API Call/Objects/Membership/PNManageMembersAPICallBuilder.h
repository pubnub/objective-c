#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

@interface PNManageMembersAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @param includeFields List with fields, specified in \b PNMemberFields enum.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^includeFields)(PNMemberFields includeFields);

/**
 * @brief List of \c users for which additional information associated with each of them in context
 * of \c space should be updated.
 *
 * @param users List with \c users and additional information which should be changed for each of
 * them in context of specified \c space.
 *
 * @note Each entry is dictionary with \c userId and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^update)(NSArray<NSDictionary *> *users);

/**
 * @brief Whether total count of \c members should be included in response or not.
 *
 * @param shouldIncludeCount Whether total count of \c members should be requested or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^includeCount)(BOOL shouldIncludeCount);

/**
 * @brief List of \c users which should be added to \c space's members list.
 *
 * @param users List of \c users and additional information which should be associated with each of
 * them in context of specified \c space (if \c custom field is set).
 *
 * @note Each entry is dictionary with \c userId and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^add)(NSArray<NSDictionary *> *users);

/**
 * @brief List of \c users which should be removed from \c members list.
 *
 * @param spaces List of \c user identifiers.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^remove)(NSArray<NSString *> *users);

/**
 * @brief Target \c space identifier.
 *
 * @param spaceId Identifier of \c space for which list of members will be updated.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^spaceId)(NSString *spaceId);

/**
 * @brief Maximum number of \c members per fetched page.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 *
 * @param limit Number of objects to return in response.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Cursor value to navigate to next fetched result page.
 *
 * @param start Previously-returned cursor bookmark for fetching the next page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^start)(NSString *start);

/**
 * @brief Cursor value to navigate to previous fetched result page.

 * @note Ignored if you also supply the \c start parameter.
 *
 * @param end Previously-returned cursor bookmark for fetching the previous page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^end)(NSString *end);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Members \c manage completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNManageMembersCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^queryParam)(NSDictionary *params);

@end

NS_ASSUME_NONNULL_END
