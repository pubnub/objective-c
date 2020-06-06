#import "PubNub+Core.h"
#import "PNSetUUIDMetadataRequest.h"
#import "PNRemoveUUIDMetadataRequest.h"
#import "PNFetchUUIDMetadataRequest.h"
#import "PNFetchAllUUIDMetadataRequest.h"
#import "PNSetChannelMetadataRequest.h"
#import "PNRemoveChannelMetadataRequest.h"
#import "PNFetchChannelMetadataRequest.h"
#import "PNFetchAllChannelsMetadataRequest.h"
#import "PNSetMembershipsRequest.h"
#import "PNRemoveMembershipsRequest.h"
#import "PNManageMembershipsRequest.h"
#import "PNFetchMembershipsRequest.h"
#import "PNSetChannelMembersRequest.h"
#import "PNRemoveChannelMembersRequest.h"
#import "PNManageChannelMembersRequest.h"
#import "PNFetchChannelMembersRequest.h"

#import "PNSetUUIDMetadataStatus.h"
#import "PNFetchUUIDMetadataResult.h"
#import "PNSetChannelMetadataStatus.h"
#import "PNFetchChannelsMetadataResult.h"
#import "PNManageMembershipsStatus.h"
#import "PNFetchMembershipsResult.h"
#import "PNManageChannelMembersStatus.h"
#import "PNFetchChannelMembersResult.h"


#import "PNObjectsAPICallBuilder.h"

#import "PNSetUUIDMetadataAPICallBuilder.h"
#import "PNRemoveUUIDMetadataAPICallBuilder.h"
#import "PNFetchUUIDMetadataAPICallBuilder.h"
#import "PNFetchAllUUIDMetadataAPICallBuilder.h"

#import "PNSetChannelMetadataAPICallBuilder.h"
#import "PNRemoveChannelMetadataAPICallBuilder.h"
#import "PNFetchChannelMetadataAPICallBuilder.h"
#import "PNFetchAllChannelsMetadataAPICallBuilder.h"

#import "PNSetMembershipsAPICallBuilder.h"
#import "PNRemoveMembershipsAPICallBuilder.h"
#import "PNManageMembershipsAPICallBuilder.h"
#import "PNFetchMembershipsAPICallBuilder.h"
#import "PNSetChannelMembersAPICallBuilder.h"
#import "PNRemoveChannelMembersAPICallBuilder.h"
#import "PNManageChannelMembersAPICallBuilder.h"
#import "PNFetchChannelMembersAPICallBuilder.h"

#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'Objects' API group.
 *
 * @discussion Set of API which allow to manage UUID / channels metadata and their relationships.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PubNub (Objects)


#pragma mark - API builder support

/**
 * @brief Objects API access builder.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNObjectsAPICallBuilder * (^objects)(void);


#pragma mark - UUID metadata object

/**
 * @brief \c Set \c metadata for \c UUID.
 *
 * @code
 * PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:@"uuid"];
 * // With this option on, returned metadata model will have value which has been set to 'custom'
 * // property.
 * request.includeFields = PNUUIDCustomField;
 * request.custom = @{ @"age": @(39), @"status": @"Checking some stuff..." };
 * request.email = @"support@pubnub.com";
 * request.name = @"David";
 *
 * [self.client setUUIDMetadataWithRequest:request completion:^(PNSetUUIDMetadataData *status) {
 *     if (!status.isError) {
 *         // UUID metadata successfully has been set.
 *         // UUID metadata information available here: status.data.metadata
 *     } else {
 *         // Handle UUID metadata set error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Set \c UUID \c metadata request with all information which should be associated
 *   with \c UUID.
 * @param block \c Set \c UUID \c metadata request completion block.
 */
- (void)setUUIDMetadataWithRequest:(PNSetUUIDMetadataRequest *)request
                        completion:(nullable PNSetUUIDMetadataCompletionBlock)block;

/**
 * @brief \c Remove \c UUID \c metadata.
 *
 * @code
 * PNRemoveUUIDMetadataRequest *request = [PNRemoveUUIDMetadataRequest requestWithUUID:@"uuid"];
 *
 * [self.client removeUUIDMetadataWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
 *     if (!status.isError) {
 *         // UUID metadata successfully removed.
 *     } else {
 *         // Handle UUID metadata remove error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Remove \c UUID \c metadata request with information about existing \c metadata.
 * @param block \c Remove \c UUID \c metadata request completion block.
 */
- (void)removeUUIDMetadataWithRequest:(PNRemoveUUIDMetadataRequest *)request
                           completion:(nullable PNRemoveUUIDMetadataCompletionBlock)block;

/**
 * @brief \c Fetch specific \c UUID \c metadata.
 *
 * @code
 * PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:@"uuid"];
 * // Add this request option, if returned metadata model should have value which has been set to
 * // 'custom' property.
 * request.includeFields = PNUUIDCustomField;
 *
 * [self.client uuidMetadataWithRequest:request
 *                           completion:^(PNFetchUUIDMetadataData *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // UUID metadata successfully fetched.
 *         // Fetched UUID metadata information available here: result.data.metadata
 *     } else {
 *         // Handle UUID metadata fetch error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c UUID \c metadata request with all information which should be used to
 *   fetch existing \c UUID \c metadata.
 * @param block \c Fetch \c UUID \c metadata request completion block.
 */
- (void)uuidMetadataWithRequest:(PNFetchUUIDMetadataRequest *)request
                     completion:(PNFetchUUIDMetadataCompletionBlock)block;

/**
 * @brief \c Fetch \c all \c UUID \c metadata.
 *
 * @code
 * PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
 * request.start = @"<next from previous request>";
 * // Add this request option, if returned metadata models should have value which has been set to
 * // 'custom' property.
 * request.includeFields = PNUUIDCustomField | PNUUIDTotalCountField;
 * request.limit = 40;
 *
 * [self.client allUUIDMetadataWithRequest:request
 *                          completion:^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // UUID metadata successfully fetched.
 *         // Result object has following information:
 *         //   result.data.metadata - list of fetched UUID metadata,
 *         //   result.data.next - cursor bookmark for fetching the next page,
 *         //   result.data.prev - cursor bookmark for fetching the previous page,
 *         //   result.data.totalCount - total number of created UUID metadata.
 *     } else {
 *         // Handle UUID metadata fetch error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c all \c UUID \c metadata request object with all information which
 *   should be used to fetch existing \c UUID \c metadata.
 * @param block \c Fetch \c all \c UUID \c metadata request completion block.
 */
- (void)allUUIDMetadataWithRequest:(PNFetchAllUUIDMetadataRequest *)request
                        completion:(PNFetchAllUUIDMetadataCompletionBlock)block;


#pragma mark - Channel metadata object

/**
 * @brief \c Set \c metadata for \c channel.
 *
 * @code
 * PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:@"channel"];
 * // Add this request option, if returned metadata model should have value which has been set to
 * // 'custom' property.
 * request.includeFields = PNChannelCustomField;
 * request.custom = @{ @"responsibilities": @"Manage tests", @"status": @"offline" };
 * request.name = @"Updated channel name";
 *
 * [self.client setChannelMetadataWithRequest:request completion:^(PNSetChannelMetadataStatus *status) {
 *     if (!status.isError) {
 *         // Channel metadata successfully has been set.
 *         // Channel metadata information available here: status.data.metadata
 *     } else {
 *         // Handle channel metadata update error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Set \c channel \c metadata request with all information which should be
 *   associated with \c channel.
 * @param block \c Set \c channel \c metadata request completion block.
 */
- (void)setChannelMetadataWithRequest:(PNSetChannelMetadataRequest *)request
                           completion:(nullable PNSetChannelMetadataCompletionBlock)block;

/**
 * @brief \c Remove \c channel \c metadata.
 *
 * @code
 * PNRemoveChannelMetadataRequest *request = [PNRemoveChannelMetadataRequest requestWithChannel:@"channel"];
 *
 * [self.client removeChannelMetadataWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
 *     if (!status.isError) {
 *         // Channel metadata successfully removed.
 *     } else {
 *         // Handle channel metadata remove error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Remove \c channel \c metadata request with information about existing
 *   \c metadata.
 * @param block \c Remove \c channel \c metadata request completion block.
 */
- (void)removeChannelMetadataWithRequest:(PNRemoveChannelMetadataRequest *)request
                              completion:(nullable PNRemoveChannelMetadataCompletionBlock)block;

/**
 * @brief \c Fetch specific \c channel \c metadata.
 *
 * @code
 * PNFetchChannelMetadataRequest *request = [PNFetchChannelMetadataRequest requestWithChannel:@"channel"];
 * // Add this request option, if returned metadata model should have value which has been set to
 * // 'custom' property.
 * request.includeFields = PNChannelCustomField;
 *
 * [self.client channelMetadataWithRequest:request
 *                              completion:^(PNFetchChannelsMetadataResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // Channel metadata successfully fetched.
 *         // Channel metadata information available here: result.data.metadata
 *     } else {
 *         // Handle channel metadata fetch error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c channel \c metadata request with all information which should be used
 *   to fetch existing \c channel \c metadata.
 * @param block \c Fetch \c channel \c metadata request completion block.
 */
- (void)channelMetadataWithRequest:(PNFetchChannelMetadataRequest *)request
                        completion:(PNFetchChannelMetadataCompletionBlock)block;

/**
 * @brief \c Fetch \c all \c channels metadata.
 *
 * @code
 * PNFetchAllChannelsMetadataRequest *request = [PNFetchAllChannelsMetadataRequest new];
 * request.start = @"<next from previous request>";
 * // Add this request option, if returned metadata models should have value which has been set to
 * // 'custom' property.
 * request.includeFields = PNChannelCustomField | PNChannelTotalCountField;
 * request.limit = 40;
 *
 * [self.client allChannelsMetadataWithRequest:request
 *                                  completion:^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // Channels metadata successfully fetched.
 *         // Result object has following information:
 *         //   result.data.metadata - list of fetched channels metadata,
 *         //   result.data.next - cursor bookmark for fetching the next page,
 *         //   result.data.prev - cursor bookmark for fetching the previous page,
 *         //   result.data.totalCount - total number of associated channel metadata.
 *     } else {
 *         // Handle channels metadata fetch error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c all \c channels \c metadata request with all information which should
 *   be used to fetch existing \c channels \c metadata.
 * @param block \c Fetch \c all \c channels \c metadata request completion block.
 */
- (void)allChannelsMetadataWithRequest:(PNFetchAllChannelsMetadataRequest *)request
                            completion:(PNFetchAllChannelsMetadataCompletionBlock)block;


#pragma mark - Membership objects

/**
 * @brief \c Set \c UUID's \c membership in target \c channels.
 *
 * @code
 * NSArray<NSDictionary *> *channels = @[
 *   @{ @"channel": @"channel1", @"custom": @{ @"role": @"moderator" } }
 * ];
 *
 * PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:@"uuid"
 *                                                                    channels:channels];
 * // Add this request option, if returned membership models should have value which has been set to
 * // 'custom' and 'channel' properties.
 * request.includeFields = PNMembershipCustomField | PNMembershipChannelField | PNMembershipsTotalCountField;
 * request.limit = 40;
 *
 * [self.client setMembershipsWithRequest:request completion:^(PNManageMembershipsStatus *status) {
 *     if (!status.isError) {
 *         // UUID's memberships successfully set.
 *         // Result object has following information:
 *         //   status.data.memberships - list of UUID's existing memberships,
 *         //   status.data.next - cursor bookmark for fetching the next page,
 *         //   status.data.prev - cursor bookmark for fetching the previous page,
 *         //   status.data.totalCount - total number of UUID's memberships.
 *     } else {
 *         // Handle UUID's memberships set error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Set \c UUID's \c memberships request with information which should be used
 *     to set \c channels membership.
 * @param block \c Set \c UUID's \c memberships request completion block.
 */
- (void)setMembershipsWithRequest:(PNSetMembershipsRequest *)request
                       completion:(nullable PNManageMembershipsCompletionBlock)block;

/**
 * @brief \c Remove \c UUID's \c membership in target \c channels.
 *
 * @code
 * NSArray<NSString *> *channels = @[@"channel1", @"channel2"];
 *
 * PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:@"uuid"
 *                                                                          channels:channels];
 * // Add this request option, if returned membership models should have value which has been set to
 * // 'custom' and 'channel' properties.
 * request.includeFields = PNMembershipCustomField | PNMembershipChannelField | PNMembershipsTotalCountField;
 * request.limit = 40;
 *
 * [self.client removeMembershipsWithRequest:request
 *                                completion:^(PNManageMembershipsStatus *status) {
 *
 *     if (!status.isError) {
 *         // UUID's memberships successfully removed.
 *         // Result object has following information:
 *         //   status.data.memberships - list of UUID's existing memberships,
 *         //   status.data.next - cursor bookmark for fetching the next page,
 *         //   status.data.prev - cursor bookmark for fetching the previous page,
 *         //   status.data.totalCount - total number of UUID's memberships.
 *     } else {
 *         // Handle UUID's memberships remove error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Remove \c UUID's \c memberships request with information which should be used
 *   to remove \c channels membership.
 * @param block \c Remove \c UUID's \c memberships request completion block.
 */
- (void)removeMembershipsWithRequest:(PNRemoveMembershipsRequest *)request
                          completion:(nullable PNManageMembershipsCompletionBlock)block;

/**
 * @brief \c Manage \c UUID's \c membership in target \c channels.
 *
 * @code
 * PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:@"uuid"];
 * request.setChannels = @[
 *     @{ @"channel": @"channel1", @"custom": @{ @"role": @"moderator" } }
 * ];
 * request.removeChannels = @[@"channel3", @"channel4"];
 * // Add this request option, if returned membership models should have value which has been set to
 * // 'custom' and 'channel' properties.
 * request.includeFields = PNMembershipCustomField | PNMembershipChannelField | PNMembershipsTotalCountField;
 * request.limit = 40;
 *
 * [self.client manageMembershipsWithRequest:request
 *                                completion:^(PNManageMembershipsStatus *status) {
 *
 *     if (!status.isError) {
 *         // UUID's memberships successfully set.
 *         // Result object has following information:
 *         //   status.data.memberships - list of UUID's existing memberships,
 *         //   status.data.next - cursor bookmark for fetching the next page,
 *         //   status.data.prev - cursor bookmark for fetching the previous page,
 *         //   status.data.totalCount - total number of UUID's memberships.
 *     } else {
 *         // Handle UUID's memberships set error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Manage \c UUID's \c memberships request with information what modifications to
 *     \c UUID's \c memberships should be done (\c set / \c remove \c channels).
 * @param block \c Manage \c UUID's \c memberships request completion block.
 */
- (void)manageMembershipsWithRequest:(PNManageMembershipsRequest *)request
                          completion:(nullable PNManageMembershipsCompletionBlock)block;

/**
 * @brief \c Fetch \c UUID's \c memberships.
 *
 * @code
 * PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:@"uuid"];
 * request.start = @"<next from previous request>";
 * // Add this request option, if returned membership models should have value which has been set to
 * // 'custom' and 'channel' properties.
 * request.includeFields = PNMembershipCustomField | PNMembershipChannelField | PNMembershipsTotalCountField;
 * request.limit = 40;
 *
 * [self.client membershipsWithRequest:request
 *                          completion:^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // UUID's memberships successfully fetched.
 *         // Result object has following information:
 *         //   result.data.memberships - list of UUID's memberships,
 *         //   result.data.next - cursor bookmark for fetching the next page,
 *         //   result.data.prev - cursor bookmark for fetching the previous page,
 *         //   result.data.totalCount - total number of UUID's memberships
 *     } else {
 *         // Handle UUID's memberships fetch error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c UUID's \c memberships request with all information which should be
 *   used to fetch existing \c UUID's \c memberships.
 * @param block \c Fetch \c UUID's \c memberships request completion block.
 */
- (void)membershipsWithRequest:(PNFetchMembershipsRequest *)request
                    completion:(PNFetchMembershipsCompletionBlock)block;

/**
 * @brief \c Set \c channel's \c members list.
 *
 * @code
 * NSArray<NSDictionary *> *uuids = @[
 *   @{ @"uuid": @"uuid2", @"custom": @{ @"role": @"moderator" } }
 * ];
 *
 * PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:@"channel"
 *                                                                                uuids:uuids];
 * // Add this request option, if returned member models should have value which has been set to
 * // 'custom' and 'uuid' properties.
 * request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField | PNChannelMembersTotalCountField;
 * request.limit = 40;
 *
 * [self.client setChannelMembersWithRequest:request completion:^(PNManageChannelMembersStatus *status) {
 *     if (!status.isError) {
 *         // Channel's members successfully set.
 *         // Result object has following information:
 *         //   result.data.members - list of existing channel's members,
 *         //   result.data.next - cursor bookmark for fetching the next page,
 *         //   result.data.prev - cursor bookmark for fetching the previous page,
 *         //   result.data.totalCount - total number of channel's members.
 *     } else {
 *         // Handle channel's members set error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Set \c channel's \c members list request with information which should be
 *   used to set \c UUID member.
 * @param block \c Set \c channel's \c members list request completion block.
 */
- (void)setChannelMembersWithRequest:(PNSetChannelMembersRequest *)request
                          completion:(nullable PNManageChannelMembersCompletionBlock)block;

/**
 * @brief \c Remove \c channel's \c members.
 *
 * @code
 * NSArray<NSString *> *uuids = @[@"uuid3", @"uuid4"];
 * PNRemoveChannelMembersRequest *request = [PNRemoveChannelMembersRequest requestWithChannel:@"channel"
 *                                                                                      uuids:uuids];
 * // Add this request option, if returned member models should have value which has been set to
 * // 'custom' and 'uuid' properties.
 * request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField | PNChannelMembersTotalCountField;
 * request.limit = 40;
 *
 * [self.client removeChannelMembersWithRequest:request completion:^(PNManageChannelMembersStatus *status) {
 *     if (!status.isError) {
 *         // Channel's members successfully removed.
 *         // Result object has following information:
 *         //   result.data.members - list of channel's existing members,
 *         //   result.data.next - cursor bookmark for fetching the next page,
 *         //   result.data.prev - cursor bookmark for fetching the previous page,
 *         //   result.data.totalCount - total number of channel's members.
 *     } else {
 *         // Handle channel's members remove error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Remove \c channel's \c members request with information which should be used
 *   to remove \c UUID members.
 * @param block \c Remove \c channel's \c members request completion block.
 */
- (void)removeChannelMembersWithRequest:(PNRemoveChannelMembersRequest *)request
                             completion:(nullable PNManageChannelMembersCompletionBlock)block;

/**
 * @brief \c Manage \c channel's members list.
 *
 * @code
 * PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:@"channel"];
 * request.setMembers = @[
 *     @{ @"uuid": @"uuid2", @"custom": @{ @"role": @"moderator" } }
 * ];
 * request.removeMembers = @[@"uuid3", @"uuid4"];
 * // Add this request option, if returned member models should have value which has been set to
 * // 'custom' and 'uuid' properties.
 * request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField | PNChannelMembersTotalCountField;
 * request.limit = 40;
 *
 * [self.client manageChannelMembersWithRequest:request completion:^(PNManageChannelMembersStatus *status) {
 *     if (!status.isError) {
 *         // Channel's members successfully changed.
 *         // Result object has following information:
 *         //   result.data.members - list of existing channel's members,
 *         //   result.data.next - cursor bookmark for fetching the next page,
 *         //   result.data.prev - cursor bookmark for fetching the previous page,
 *         //   result.data.totalCount - total number of channel's members.
 *     } else {
 *         // Handle channel's members manage error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Manage \c channel's \c members list request with information what modifications
 *   to \c channel's members list should be done (\c set / \c remove \c UUID).
 * @param block \c Manage \c channel's \c members list request completion block.
 */
- (void)manageChannelMembersWithRequest:(PNManageChannelMembersRequest *)request
                             completion:(nullable PNManageChannelMembersCompletionBlock)block;

/**
 * @brief \c Fetch \c channel's \c members.
 *
 * @code
 * PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:@"channel"];
 * request.start = @"<next from previous request>";
 * // Add this request option, if returned member models should have value which has been set to
 * // 'custom' and 'uuid' properties.
 * request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField | PNChannelMembersTotalCountField;
 * request.limit = 40;
 *
 * [self.client channelMembersWithRequest:request
 *                             completion:^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // Channel's members successfully fetched.
 *         // Result object has following information:
 *         //   result.data.members - list of channel's members,
 *         //   result.data.next - cursor bookmark for fetching the next page,
 *         //   result.data.prev - cursor bookmark for fetching the previous page,
 *         //   result.data.totalCount - total number of channel's members.
 *     } else {
 *         // Handle channel's members fetch error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c channel's \c members request with all information which should be used
 *     to fetch existing \c channel's \c members.
 * @param block \c Fetch \c channel's \c members request completion block.
 */
- (void)channelMembersWithRequest:(PNFetchChannelMembersRequest *)request
                       completion:(PNFetchChannelMembersCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
