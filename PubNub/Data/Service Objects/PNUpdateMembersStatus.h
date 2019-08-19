#import "PNAcknowledgmentStatus.h"
#import "PNServiceData.h"
#import "PNMember.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c update \c members request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUpdateMembersData : PNServiceData


#pragma mark - Information

/**
 * @brief List of updated \c members.
 */
@property (nonatomic, readonly, strong) NSArray<PNMember *> *members;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c update \c members request results.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUpdateMembersStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Update \c members request processed information.
 */
@property (nonatomic, readonly, strong) PNUpdateMembersData *data;

/**
 * @brief Cursor bookmark for fetching the next page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *next;

/**
 * @brief Cursor bookmark for fetching the previous page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *prev;

/**
 * @brief Total number of \c updated \c members.
 *
 * @note Value will be \c 0 in case if \c includeCount of \b PNUpdateMembersRequest is set to
 * \c NO.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
