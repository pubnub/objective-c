#import "PNServiceData.h"
#import "PNResult.h"
#import "PNUser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c fetch \c user request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchUserData : PNServiceData


#pragma mark - Information

/**
 * @brief Requested user object.
 */
@property (nonatomic, nullable, readonly, strong) PNUser *user;

#pragma mark -


@end

/**
 * @brief Object which is used to represent Objects API response for \c fetch \c all \c users
 * request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchUsersData : PNServiceData


#pragma mark - Information

/**
 * @brief List of user objects created for current subscribe key.
 */
@property (nonatomic, readonly, strong) NSArray<PNUser *> *users;

/**
 * @brief Cursor bookmark for fetching the next page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *next;

/**
 * @brief Cursor bookmark for fetching the previous page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *prev;

/**
 * @brief Total number of users created for current subscribe key.
 *
 * @note Value will be \c 0 in case if \c includeCount of \b PNFetchUsersRequest is set to \c NO.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to \c fetch \c user request response.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchUserResult : PNResult


#pragma mark - Information

/**
 * @brief \c Fetch \c user request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchUserData *data;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to \c fetch \c all \c users request response.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchUsersResult : PNResult


#pragma mark - Information

/**
 * @brief \c Fetch \c all \c users request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchUsersData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
