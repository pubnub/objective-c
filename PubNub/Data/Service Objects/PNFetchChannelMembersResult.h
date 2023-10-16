#import <PubNub/PNServiceData.h>
#import <PubNub/PNOperationResult.h>
#import <PubNub/PNChannelMember.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c fetch \c members request.
 *
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchChannelMembersData : PNServiceData


#pragma mark - Information

/**
 * @brief List of fetched \c members.
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
 * @brief Total number of \c members in \c channel's members list.
 *
 * @note Value will be \c 0 in case if \c includeCount of \b PNFetchChannelMembersRequest is set to
 * \c NO.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c fetch \c members request results.
 *
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchChannelMembersResult : PNOperationResult


#pragma mark - Information

/**
 * @brief \c Fetch \c members request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchChannelMembersData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
