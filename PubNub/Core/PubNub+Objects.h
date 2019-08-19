#import "PubNub+Core.h"
#import "PNCreateUserRequest.h"
#import "PNUpdateUserRequest.h"
#import "PNDeleteUserRequest.h"
#import "PNFetchUserRequest.h"
#import "PNFetchUsersRequest.h"
#import "PNCreateSpaceRequest.h"
#import "PNUpdateSpaceRequest.h"
#import "PNDeleteSpaceRequest.h"
#import "PNFetchSpaceRequest.h"
#import "PNFetchSpacesRequest.h"
#import "PNUpdateMembershipsRequest.h"
#import "PNFetchMembershipsRequest.h"
#import "PNUpdateMembersRequest.h"
#import "PNFetchMembersRequest.h"

#import "PNUpdateUserStatus.h"
#import "PNCreateUserStatus.h"
#import "PNFetchUsersResult.h"
#import "PNUpdateSpaceStatus.h"
#import "PNCreateSpaceStatus.h"
#import "PNFetchSpacesResult.h"
#import "PNUpdateMembershipsStatus.h"
#import "PNFetchMembershipsResult.h"
#import "PNUpdateMembersStatus.h"
#import "PNFetchMembersResult.h"

#import "PNCreateUserAPICallBuilder.h"
#import "PNUpdateUserAPICallBuilder.h"
#import "PNDeleteUserAPICallBuilder.h"
#import "PNFetchUserAPICallBuilder.h"
#import "PNFetchUsersAPICallBuilder.h"

#import "PNCreateSpaceAPICallBuilder.h"
#import "PNUpdateSpaceAPICallBuilder.h"
#import "PNDeleteSpaceAPICallBuilder.h"
#import "PNFetchSpaceAPICallBuilder.h"
#import "PNFetchSpacesAPICallBuilder.h"

#import "PNUpdateMembershipsAPICallBuilder.h"
#import "PNFetchMembershipsAPICallBuilder.h"
#import "PNUpdateMembersAPICallBuilder.h"
#import "PNFetchMembersAPICallBuilder.h"

#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark - API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'Objects' API group.
 *
 * @discussion Set of API which allow to fetch events which has been moved from remote data object
 * live feed to persistent storage.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PubNub (Objects)


#pragma mark - User Objects API builder support

/**
 * @brief \c Create \c user API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateUserAPICallBuilder * (^createUser)(void);

/**
 * @brief \c Update \c user API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateUserAPICallBuilder * (^updateUser)(void);

/**
 * @brief \c Delete \c user API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNDeleteUserAPICallBuilder * (^deleteUser)(void);

/**
 * @brief \c Fetch \c user API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUserAPICallBuilder * (^fetchUser)(void);

/**
 * @brief \c Fetch \c all \c users API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchUsersAPICallBuilder * (^fetchUsers)(void);


#pragma mark - Space Objects API builder support

/**
 * @brief \c Create \c space API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNCreateSpaceAPICallBuilder * (^createSpace)(void);

/**
 * @brief \c Update \c space API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateSpaceAPICallBuilder * (^updateSpace)(void);

/**
 * @brief \c Delete \c space API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNDeleteSpaceAPICallBuilder * (^deleteSpace)(void);

/**
 * @brief \c Fetch \c space API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchSpaceAPICallBuilder * (^fetchSpace)(void);

/**
 * @brief \c Fetch \c all \c spaces API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchSpacesAPICallBuilder * (^fetchSpaces)(void);


#pragma mark - Memberships / Members Objects API builder support

/**
 * @brief \c Update \c memberships API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateMembershipsAPICallBuilder * (^memberships)(void);

/**
 * @brief \c Fetch \c memberships API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^fetchMemberships)(void);

/**
 * @brief \c Update \c members API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNUpdateMembersAPICallBuilder * (^members)(void);

/**
 * @brief \c Fetch \c members API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembersAPICallBuilder * (^fetchMembers)(void);


#pragma mark - User object

/**
 * @brief Create new user object with user-defined data.
 *
 * @param request User create request object with all information about new user which will be
 *     passed to \b PubNub service.
 * @param block User create request completion block.
 */
- (void)createUserWithRequest:(PNCreateUserRequest *)request
                   completion:(nullable PNCreateUserCompletionBlock)block;

/**
 * @brief Update existing user object with user-defined data.
 *
 * @param request User update request object with all information which should be updated for
 *     existing user.
 * @param block Existing user update request completion block.
 */
- (void)updateUserWithRequest:(PNUpdateUserRequest *)request
                   completion:(nullable PNUpdateUserCompletionBlock)block;

/**
 * @brief Delete existing user object.
 *
 * @param request User delete request object with information about existing user.
 * @param block Existing user delete request completion block.
 */
- (void)deleteUserWithRequest:(PNDeleteUserRequest *)request
                   completion:(nullable PNDeleteUserCompletionBlock)block;

/**
 * @brief Fetch specific user object.
 *
 * @param request User fetch request object with all information which should be used to fetch
 *     existing user.
 * @param block Existing user fetch request completion block.
 */
- (void)fetchUserWithRequest:(PNFetchUserRequest *)request
                  completion:(PNFetchUserCompletionBlock)block;

/**
 * @brief Fetch all user objects.
 *
 * @param request Users fetch request object with all information which should be used to fetch
 *     existing users.
 * @param block Existing users fetch request completion block.
 */
- (void)fetchUsersWithRequest:(PNFetchUsersRequest *)request
                   completion:(PNFetchUsersCompletionBlock)block;


#pragma mark - Space object

/**
 * @brief Create new user object with user-defined data.
 *
 * @param request User create request object with all information about new user which will be
 *     passed to \b PubNub service.
 * @param block User create request completion block.
 */
- (void)createSpaceWithRequest:(PNCreateSpaceRequest *)request
                    completion:(nullable PNCreateSpaceCompletionBlock)block;

/**
 * @brief Update existing user object with user-defined data.
 *
 * @param request User update request object with all information which should be updated for
 *     existing user.
 * @param block Existing user update request completion block.
 */
- (void)updateSpaceWithRequest:(PNUpdateSpaceRequest *)request
                    completion:(nullable PNUpdateSpaceCompletionBlock)block;

/**
 * @brief Delete existing user object.
 *
 * @param request User delete request object with information about existing user.
 * @param block Existing user delete request completion block.
 */
- (void)deleteSpaceWithRequest:(PNDeleteSpaceRequest *)request
                    completion:(nullable PNDeleteSpaceCompletionBlock)block;

/**
 * @brief Fetch specific user object.
 *
 * @param request User fetch request object with all information which should be used to fetch
 *     existing user.
 * @param block Existing user fetch request completion block.
 */
- (void)fetchSpaceWithRequest:(PNFetchSpaceRequest *)request
                   completion:(PNFetchSpaceCompletionBlock)block;

/**
 * @brief Fetch all user objects.
 *
 * @param request Users fetch request object with all information which should be used to fetch
 *     existing users.
 * @param block Existing users fetch request completion block.
 */
- (void)fetchSpacesWithRequest:(PNFetchSpacesRequest *)request
                    completion:(PNFetchSpacesCompletionBlock)block;


#pragma mark - Membership objects

- (void)updateMembershipsWithRequest:(PNUpdateMembershipsRequest *)request
                          completion:(PNUpdateMembershipsCompletionBlock)block;
- (void)fetchMembershipsWithRequest:(PNFetchMembershipsRequest *)request
                         completion:(PNFetchMembershipsCompletionBlock)block;

- (void)updateMembersWithRequest:(PNUpdateMembersRequest *)request
                      completion:(PNUpdateMembersCompletionBlock)block;
- (void)fetchMembersWithRequest:(PNFetchMembersRequest *)request
                     completion:(PNFetchMembersCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
