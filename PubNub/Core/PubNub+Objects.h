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
#import "PNManageMembershipsRequest.h"
#import "PNFetchMembershipsRequest.h"
#import "PNManageMembersRequest.h"
#import "PNFetchMembersRequest.h"

#import "PNUpdateUserStatus.h"
#import "PNCreateUserStatus.h"
#import "PNFetchUsersResult.h"
#import "PNUpdateSpaceStatus.h"
#import "PNCreateSpaceStatus.h"
#import "PNFetchSpacesResult.h"
#import "PNManageMembershipsStatus.h"
#import "PNFetchMembershipsResult.h"
#import "PNManageMembersStatus.h"
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

#import "PNManageMembershipsAPICallBuilder.h"
#import "PNFetchMembershipsAPICallBuilder.h"
#import "PNManageMembersAPICallBuilder.h"
#import "PNFetchMembersAPICallBuilder.h"

#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'Objects' API group.
 *
 * @discussion Set of API which allow to manage space / user objects and their relationships.
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
 * @brief \c Manage \c memberships API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsAPICallBuilder * (^manageMemberships)(void);

/**
 * @brief \c Fetch \c memberships API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsAPICallBuilder * (^fetchMemberships)(void);

/**
 * @brief \c Manage \c members API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNManageMembersAPICallBuilder * (^manageMembers)(void);

/**
 * @brief \c Fetch \c members API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMembersAPICallBuilder * (^fetchMembers)(void);


#pragma mark - User object

/**
 * @brief \c Create new \c user with user-defined data.
 *
 * @code
 * PNCreateUserRequest *request = [PNCreateUserRequest requestWithUserID:@"user-uuid"
 *                                                                  name:@"Serhii"];
 * request.externalId = @"93FVfHUAf4RLu79J7Q3ejLVu";
 * request.profileUrl = @"https://pubnub.com";
 * request.custom = @{ @"age": @(36) };
 * request.email = @"support@pubnub.com";
 *
 * [self.client createUserWithRequest:request completion:^(PNCreateUserStatus *status) {
 *     if (!status.isError) {
 *         // User successfully created.
 *         // Created user information available here: status.data.user
 *     } else {
 *         // Handle user create error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Create \c user request with all information about new \c user which will be
 *     passed to \b PubNub service.
 * @param block \c Create \c user request completion block.
 */
- (void)createUserWithRequest:(PNCreateUserRequest *)request
                   completion:(nullable PNCreateUserCompletionBlock)block;

/**
 * @brief \c Update existing \c user with user-defined data.
 *
 * @code
 * PNUpdateUserRequest *request = [PNUpdateUserRequest requestWithUserID:@"user-uuid"];
 * // With this option on, returned user model will have value set to 'custom' property.
 * request.includeFields = PNUserCustomField;
 * request.custom = @{ @"age": @(39), @"status": @"Checking some stuff..." };
 * request.email = @"support@pubnub.com";
 * request.name = @"David";
 *
 * [self.client updateUserWithRequest:request completion:^(PNUpdateUserStatus *status) {
 *     if (!status.isError) {
 *         // User successfully updated.
 *         // Updated user information available here: status.data.user
 *     } else {
 *         // Handle user update error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Update \c user request with all information which should be updated for
 *     existing \c user.
 * @param block \c Update \c user request completion block.
 */
- (void)updateUserWithRequest:(PNUpdateUserRequest *)request
                   completion:(nullable PNUpdateUserCompletionBlock)block;

/**
 * @brief \c Delete existing \c user.
 *
 * @code
 * PNDeleteUserRequest *request = [PNDeleteUserRequest requestWithUserID:@"user-uuid"];
 *
 * [self.client deleteUserWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
 *     if (!status.isError) {
 *         // User successfully deleted.
 *     } else {
 *         // Handle user delete error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Delete \c user request with information about existing \c user.
 * @param block \c Delete \c user request completion block.
 */
- (void)deleteUserWithRequest:(PNDeleteUserRequest *)request
                   completion:(nullable PNDeleteUserCompletionBlock)block;

/**
 * @brief \c Fetch specific \c user.
 *
 * @code
 * PNFetchUserRequest *request = [PNFetchUserRequest requestWithUserID:@"space-uuid"];
 * // Add this request option, if returned user model should have value set to 'custom' property.
 * request.includeFields = PNUserCustomField;
 *
 * [self.client fetchUserWithRequest:request
 *                        completion:^(PNFetchUserResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // User successfully fetched.
 *         // Fetched user information available here: result.data.user
 *     } else {
 *         // Handle user fetch error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c user request with all information which should be used to fetch
 *     existing \c user.
 * @param block \c Fetch \c user request completion block.
 */
- (void)fetchUserWithRequest:(PNFetchUserRequest *)request
                  completion:(PNFetchUserCompletionBlock)block;

/**
 * @brief \c Fetch \c all \c users.
 *
 * @code
 * PNFetchUsersRequest *request = [PNFetchUsersRequest new];
 * request.start = @"<next from previous request>";
 * // Add this request option, if returned user models should have value set to 'custom' property.
 * request.includeFields = PNUserCustomField;
 * request.includeCount = YES;
 * request.limit = 40;
 *
 * [self.client fetchUsersWithRequest:request
 *                         completion:^(PNFetchUsersResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // Users successfully fetched.
 *         // Result object has following information:
 *         //   result.data.users - list of fetched users
 *         //   result.data.next - cursor bookmark for fetching the next page.
 *         //   result.data.prev - cursor bookmark for fetching the previous page
 *         //   result.data.totalCount - total number of created users
 *     } else {
 *         // Handle users fetch error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c all \c users request object with all information which should be used
 *     to fetch existing \c users.
 * @param block \c Fetch \c all \c users request completion block.
 */
- (void)fetchUsersWithRequest:(PNFetchUsersRequest *)request
                   completion:(PNFetchUsersCompletionBlock)block;


#pragma mark - Space object

/**
 * @brief \c Create new \c space with user-defined data.
 *
 * @code
 * PNCreateSpaceRequest *request = [PNCreateSpaceRequest requestWithSpaceID:@"space-uuid"
 *                                                                     name:@"Admin"];
 * request.information = @"Administrative space";
 * request.custom = @{ @"responsibilities": @"Manage access to protected resources" };
 *
 * [self.client createSpaceWithRequest:request completion:^(PNCreateSpaceStatus *status) {
 *     if (!status.isError) {
 *         // Space successfully created.
 *         // Created space information available here: status.data.space
 *     } else {
 *         // Handle space create error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Create \c space request with all information about new \c space which will be
 *     passed to \b PubNub service.
 * @param block \c Create \c space request completion block.
 */
- (void)createSpaceWithRequest:(PNCreateSpaceRequest *)request
                    completion:(nullable PNCreateSpaceCompletionBlock)block;

/**
 * @brief \c Update existing \c space with user-defined data.
 *
 * @code
 * PNUpdateSpaceRequest *request = [PNUpdateSpaceRequest requestWithSpaceID:@"space-uuid"];
 * // Add this request option, if returned space model should have value set to 'custom' property.
 * request.includeFields = PNSpaceCustomField;
 * request.custom = @{ @"responsibilities": @"Manage tests", @"status": @"offline" };
 * request.name = @"Updated space name";
 *
 * [self.client updateSpaceWithRequest:request completion:^(PNUpdateSpaceStatus *status) {
 *     if (!status.isError) {
 *         // Space successfully updated.
 *         // Updated space information available here: status.data.space
 *     } else {
 *         // Handle space update error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Update \c space request with all information which should be updated for
 *     existing \c space.
 * @param block \c Update \c space request completion block.
 */
- (void)updateSpaceWithRequest:(PNUpdateSpaceRequest *)request
                    completion:(nullable PNUpdateSpaceCompletionBlock)block;

/**
 * @brief \c Delete existing \c space.
 *
 * @code
 * PNDeleteSpaceRequest *request = [PNDeleteSpaceRequest requestWithSpaceID:@"space-uuid"];
 *
 * [self.client deleteSpaceWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
 *     if (!status.isError) {
 *         // Space successfully deleted.
 *     } else {
 *         // Handle space delete error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Delete \c space request with information about existing \c space.
 * @param block \c Delete \c space request completion block.
 */
- (void)deleteSpaceWithRequest:(PNDeleteSpaceRequest *)request
                    completion:(nullable PNDeleteSpaceCompletionBlock)block;

/**
 * @brief \c Fetch specific \c space.
 *
 * @code
 * PNFetchSpaceRequest *request = [PNFetchSpaceRequest requestWithSpaceID:@"space-uuid"];
 * // Add this request option, if returned space model should have value set to 'custom' property.
 * request.includeFields = PNSpaceCustomField;
 *
 * [self.client fetchSpaceWithRequest:request
 *                         completion:^(PNFetchSpaceResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // Space successfully fetched.
 *         // Fetched space information available here: result.data.space
 *     } else {
 *         // Handle user fetch error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c space request with all information which should be used to fetch
 *     existing \c space.
 * @param block \c Fetch \c space request completion block.
 */
- (void)fetchSpaceWithRequest:(PNFetchSpaceRequest *)request
                   completion:(PNFetchSpaceCompletionBlock)block;

/**
 * @brief \c Fetch \c all \c spaces.
 *
 * @code
 * PNFetchSpacesRequest *request = [PNFetchSpacesRequest new];
 * request.start = @"<next from previous request>";
 * // Add this request option, if returned space models should have value set to 'custom' property.
 * request.includeFields = PNUserCustomField;
 * request.includeCount = YES;
 * request.limit = 40;
 *
 * [self.client fetchSpacesWithRequest:request
 *                          completion:^(PNFetchSpacesResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // Spaces successfully fetched.
 *         // Result object has following information:
 *         //   result.data.spaces - list of fetched spaces
 *         //   result.data.next - cursor bookmark for fetching the next page.
 *         //   result.data.prev - cursor bookmark for fetching the previous page
 *         //   result.data.totalCount - total number of created spaces
 *     } else {
 *         // Handle spaces fetch error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c all \c spaces request with all information which should be used to
 *     fetch existing \c spaces.
 * @param block \c Fetch \c all \c spaces request completion block.
 */
- (void)fetchSpacesWithRequest:(PNFetchSpacesRequest *)request
                    completion:(PNFetchSpacesCompletionBlock)block;


#pragma mark - Membership objects

/**
 * @brief \c Manage \c user's membership in target \c spaces.
 *
 * @code
 * PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUserID:@"used-uuid"];
 * request.updateSpaces = @[
 *     @{ @"spaceId": @"space2-uuid", @"custom": @{ @"role": @"moderator" } }
 * ];
 * request.leaveSpaces = @[@"space3-uuid", @"space4-uuid"];
 * request.joinSpaces = @[
 *     @{ @"spaceId": @"space1-uuid", @"custom": @{ @"role": @"owner" } }
 * ];
 * // Add this request option, if returned membership models should have value set to 'custom'
 * // and 'space' properties.
 * request.includeFields = PNMembershipCustomField|PNMembershipSpaceField;
 * request.includeCount = YES;
 * request.limit = 40;
 *
 * [self.client manageMembershipsWithRequest:request
 *                                completion:^(PNManageMembershipsStatus *status) {
 *
 *     if (!status.isError) {
 *         // User's memberships successfully updated.
 *         // Result object has following information:
 *         //   status.data.memberships - list of user's created / updated memberships
 *         //   status.data.next - cursor bookmark for fetching the next page
 *         //   status.data.prev - cursor bookmark for fetching the previous page
 *         //   status.data.totalCount - total number of user's memberships
 *     } else {
 *         // Handle user's memberships update error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Manage \c user's \c memberships request with information what modifications to
 *     \c user's \c memberships should be done (\c join / \c update / \c leave \c spaces).
 * @param block \c Manage \c user's \c memberships request completion block.
 */
- (void)manageMembershipsWithRequest:(PNManageMembershipsRequest *)request
                          completion:(nullable PNManageMembershipsCompletionBlock)block;

/**
 * @brief \c Fetch \c user's memberships.
 *
 * @code
 * PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUserID:@"used-uuid"];
 * request.start = @"<next from previous request>";
 * // Add this request option, if returned membership models should have value set to 'custom'
 * // and 'space' properties.
 * request.includeFields = PNMembershipCustomField|PNMembershipSpaceField;
 * request.includeCount = YES;
 * request.limit = 40;
 *
 * [self.client fetchMembershipsWithRequest:request
 *                           completion:^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // User's memberships successfully fetched.
 *         // Result object has following information:
 *         //   result.data.memberships - list of user's memberships
 *         //   result.data.next - cursor bookmark for fetching the next page
 *         //   result.data.prev - cursor bookmark for fetching the previous page
 *         //   result.data.totalCount - total number of user's memberships
 *     } else {
 *         // Handle user's memberships fetch error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c user's memberships request with all information which should be used
 *     to fetch existing \c user's memberships.
 * @param block \c Fetch \c user's memberships request completion block.
 */
- (void)fetchMembershipsWithRequest:(PNFetchMembershipsRequest *)request
                         completion:(PNFetchMembershipsCompletionBlock)block;

/**
 * @brief \c Manage \c space's members list.
 *
 * @code
 * PNManageMembersRequest *request = [PNManageMembersRequest requestWithSpaceID:@"space-uuid"];
 * request.updateMembers = @[
 *     @{ @"userId": @"user2-uuid", @"custom": @{ @"role": @"moderator" } }
 * ];
 * request.removeMembers = @[@"user3-uuid", @"user4-uuid"];
 * request.addMembers = @[
 *     @{ @"userId": @"user1-uuid", @"custom": @{ @"role": @"owner" } }
 * ];
 * // Add this request option, if returned member models should have value set to 'custom' and
 * // 'user' properties.
 * request.includeFields = PNMemberCustomField|PNMemberUserField;
 * request.includeCount = YES;
 * request.limit = 40;
 *
 * [self.client manageMembersWithRequest:request completion:^(PNManageMembersStatus *status) {
 *     if (!status.isError) {
 *         // Space's members successfully updated.
 *         // Result object has following information:
 *         //   result.data.members - list of added / updated space's members
 *         //   result.data.next - cursor bookmark for fetching the next page
 *         //   result.data.prev - cursor bookmark for fetching the previous page
 *         //   result.data.totalCount - total number of space's memebers
 *     } else {
 *         // Handle space's members update error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Manage \c space's members list request with information what modifications to
 *     \c space's members list should be done (\c add / \c update / \c remove \c users).
 * @param block \c Manage \c space's members list request completion block.
 */
- (void)manageMembersWithRequest:(PNManageMembersRequest *)request
                      completion:(nullable PNManageMembersCompletionBlock)block;

/**
 * @brief \c Fetch \c space's members.
 *
 * @code
 * PNFetchMembersRequest *request = [PNFetchMembersRequest requestWithSpaceID:@"space-uuid"];
 * request.start = @"<next from previous request>";
 * // Add this request option, if returned member models should have value set to 'custom' and
 * // 'user' properties.
 * request.includeFields = PNMemberCustomField|PNMemberUserField;
 * request.includeCount = YES;
 * request.limit = 40;
 *
 * [self.client fetchMembersWithRequest:request
 *                               completion:^(PNFetchMembersResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // Space's members successfully fetched.
 *         // Result object has following information:
 *         //   result.data.members - list of space's members
 *         //   result.data.next - cursor bookmark for fetching the next page
 *         //   result.data.prev - cursor bookmark for fetching the previous page
 *         //   result.data.totalCount - total number of space's members
 *     } else {
 *         // Handle space's members fetch error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c space's members request with all information which should be used
 *     to fetch existing \c space's members.
 * @param block \c Fetch \c space's members request completion block.
 */
- (void)fetchMembersWithRequest:(PNFetchMembersRequest *)request
                     completion:(PNFetchMembersCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
