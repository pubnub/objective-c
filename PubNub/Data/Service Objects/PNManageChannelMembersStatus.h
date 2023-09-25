#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNChannelMember.h>
#import <PubNub/PNServiceData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c members \c set  /
 * \c remove / \c manage request.
 *
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNManageChannelMembersData : PNServiceData


#pragma mark - Information

/**
 * @brief List of existing \c members.
 */
@property (nonatomic, readonly, strong) NSArray<PNChannelMember *> *members;

/**
 * @brief Cursor bookmark for fetching the next page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *next;

/**
 * @brief Cursor bookmark for fetching the previous page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *prev;

/**
 * @brief Total number of existing objects.
 *
 * @note Value will be \c 0 in case if \b PNChannelMembersTotalCountField not added to
 * \c includeFields of \b PNSetChannelMembersRequest / \b PNRemoveChannelMembersRequest /
 * \b PNManageChannelMembersRequest or \b PNFetchChannelMembersRequest.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c members \c set /
 * \c remove / \c manage request results.
 *
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNManageChannelMembersStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Members \c set / \c remove / \c manage request processed information.
 */
@property (nonatomic, readonly, strong) PNManageChannelMembersData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
