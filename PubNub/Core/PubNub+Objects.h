#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNManageChannelMembersRequest.h>
#import <PubNub/PNRemoveChannelMembersRequest.h>
#import <PubNub/PNFetchChannelMembersRequest.h>
#import <PubNub/PNManageMembershipsRequest.h>
#import <PubNub/PNRemoveMembershipsRequest.h>
#import <PubNub/PNSetChannelMembersRequest.h>
#import <PubNub/PNFetchMembershipsRequest.h>
#import <PubNub/PNSetMembershipsRequest.h>

#import <PubNub/PNFetchAllChannelsMetadataRequest.h>
#import <PubNub/PNRemoveChannelMetadataRequest.h>
#import <PubNub/PNFetchChannelMetadataRequest.h>
#import <PubNub/PNSetChannelMetadataRequest.h>

#import <PubNub/PNFetchAllUUIDMetadataRequest.h>
#import <PubNub/PNRemoveUUIDMetadataRequest.h>
#import <PubNub/PNFetchUUIDMetadataRequest.h>
#import <PubNub/PNSetUUIDMetadataRequest.h>

// Response
#import <PubNub/PNFetchAllChannelsMetadataResult.h>
#import <PubNub/PNFetchChannelMetadataResult.h>
#import <PubNub/PNManageChannelMembersStatus.h>
#import <PubNub/PNFetchAllUUIDMetadataResult.h>
#import <PubNub/PNFetchChannelMembersResult.h>
#import <PubNub/PNSetChannelMetadataStatus.h>
#import <PubNub/PNFetchUUIDMetadataResult.h>
#import <PubNub/PNManageMembershipsStatus.h>
#import <PubNub/PNFetchMembershipsResult.h>
#import <PubNub/PNSetUUIDMetadataStatus.h>

// Deprecated
#import <PubNub/PNFetchAllChannelsMetadataAPICallBuilder.h>
#import <PubNub/PNRemoveChannelMetadataAPICallBuilder.h>
#import <PubNub/PNFetchChannelMetadataAPICallBuilder.h>
#import <PubNub/PNRemoveChannelMembersAPICallBuilder.h>
#import <PubNub/PNManageChannelMembersAPICallBuilder.h>
#import <PubNub/PNFetchAllUUIDMetadataAPICallBuilder.h>
#import <PubNub/PNFetchChannelMembersAPICallBuilder.h>
#import <PubNub/PNSetChannelMetadataAPICallBuilder.h>
#import <PubNub/PNRemoveUUIDMetadataAPICallBuilder.h>
#import <PubNub/PNFetchUUIDMetadataAPICallBuilder.h>
#import <PubNub/PNSetChannelMembersAPICallBuilder.h>
#import <PubNub/PNManageMembershipsAPICallBuilder.h>
#import <PubNub/PNRemoveMembershipsAPICallBuilder.h>
#import <PubNub/PNFetchMembershipsAPICallBuilder.h>
#import <PubNub/PNSetUUIDMetadataAPICallBuilder.h>
#import <PubNub/PNSetMembershipsAPICallBuilder.h>
#import <PubNub/PNObjectsAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** `App Context` APIs.
///
/// Set of API which allow managing `UUID` / `channels` metadata and their `relationships`.
@interface PubNub (Objects)


#pragma mark - App Context API builder interdace (deprecated)

/// Objects API access builder.
@property (nonatomic, readonly, strong) PNObjectsAPICallBuilder * (^objects)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - UUID metadata object

/// `Set UUID metadata`.
///
/// #### Example:
/// ```objc
/// PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:@"uuid"];
/// // With this option on, returned metadata model will have value which has been set to 'custom'
/// // property.
/// request.includeFields = PNUUIDCustomField;
/// request.custom = @{ @"age": @(39), @"status": @"Checking some stuff..." };
/// request.email = @"support@pubnub.com";
/// request.name = @"David";
///
/// [self.client setUUIDMetadataWithRequest:request completion:^(PNSetUUIDMetadataData *status) {
///     if (!status.isError) {
///         // UUID metadata successfully has been set.
///         // UUID metadata information available here: `status.data.metadata`.
///     } else {
///         // Handle UUID metadata set error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Set UUID metadata` request with all information which should be associated with `UUID`.
///   - block: `Set UUID metadata` request completion block.
- (void)setUUIDMetadataWithRequest:(PNSetUUIDMetadataRequest *)request
                        completion:(nullable PNSetUUIDMetadataCompletionBlock)block;

/// `Remove UUID metadata`.
///
/// #### Example:
/// ```objc
/// PNRemoveUUIDMetadataRequest *request = [PNRemoveUUIDMetadataRequest requestWithUUID:@"uuid"];
///
/// [self.client removeUUIDMetadataWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // UUID metadata successfully removed.
///     } else {
///         // Handle UUID metadata remove error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Remove UUID metadata` request with information about existing `metadata`.
///   - block: `Remove UUID metadata` request completion block.
- (void)removeUUIDMetadataWithRequest:(PNRemoveUUIDMetadataRequest *)request
                           completion:(nullable PNRemoveUUIDMetadataCompletionBlock)block;

/// `Fetch UUID metadata`.
///
/// #### Example:
/// ```objc
/// PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:@"uuid"];
/// // Add this request option, if returned metadata model should have value which has been set to
/// // 'custom' property.
/// request.includeFields = PNUUIDCustomField;
///
/// [self.client uuidMetadataWithRequest:request completion:^(PNFetchUUIDMetadataData *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // UUID metadata successfully fetched.
///         // Fetched UUID metadata information available here: result.data.metadata
///     } else {
///         // Handle UUID metadata fetch error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Fetch UUID metadata` request with all information which should be used to fetch existing 
///   `UUID metadata`.
///   - block: `Fetch UUID metadata` request completion block.
- (void)uuidMetadataWithRequest:(PNFetchUUIDMetadataRequest *)request
                     completion:(PNFetchUUIDMetadataCompletionBlock)block;

/// `Fetch all UUID metadata`.
///
/// #### Example:
/// ```objc
/// PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
/// request.start = @"<next from previous request>";
/// // Add this request option, if returned metadata models should have value which has been set to
/// // 'custom' property.
/// request.includeFields = PNUUIDCustomField | PNUUIDTotalCountField;
/// request.limit = 40;
///
/// [self.client allUUIDMetadataWithRequest:request
///                              completion:^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // UUID metadata successfully fetched.
///         // Result object has following information:
///         //   result.data.metadata - list of fetched UUID metadata,
///         //   result.data.next - cursor bookmark for fetching the next page,
///         //   result.data.prev - cursor bookmark for fetching the previous page,
///         //   result.data.totalCount - total number of created UUID metadata.
///     } else {
///         // Handle UUID metadata fetch error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Fetch all UUID metadata` request object with all information which should be used to fetch existing
///   `UUID metadata`.
///   - block: `Fetch all UUID metadata` request completion block.
- (void)allUUIDMetadataWithRequest:(PNFetchAllUUIDMetadataRequest *)request
                        completion:(PNFetchAllUUIDMetadataCompletionBlock)block;


#pragma mark - Channel metadata object

/// `Set channel metadata`.
///
/// #### Example:
/// ```objc
/// PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:@"channel"];
/// // Add this request option, if returned metadata model should have value which has been set to
/// // 'custom' property.
/// request.includeFields = PNChannelCustomField;
/// request.custom = @{ @"responsibilities": @"Manage tests", @"status": @"offline" };
/// request.name = @"Updated channel name";
///
/// [self.client setChannelMetadataWithRequest:request completion:^(PNSetChannelMetadataStatus *status) {
///     if (!status.isError) {
///         // Channel metadata successfully has been set.
///         // Channel metadata information available here: status.data.metadata
///     } else {
///         // Handle channel metadata update error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Set channel metadata` request with all information which should be associated with `channel`.
///   - block: `Set channel metadata` request completion block.
- (void)setChannelMetadataWithRequest:(PNSetChannelMetadataRequest *)request
                           completion:(nullable PNSetChannelMetadataCompletionBlock)block;

/// `Remove channel metadata`.
///
/// #### Exaple:
/// ```objc
/// PNRemoveChannelMetadataRequest *request = [PNRemoveChannelMetadataRequest requestWithChannel:@"channel"];
///
/// [self.client removeChannelMetadataWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Channel metadata successfully removed.
///     } else {
///         // Handle channel metadata remove error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Remove channel metadata` request with information about existing `metadata`.
///   - block: `Remove channel metadata` request completion block.
- (void)removeChannelMetadataWithRequest:(PNRemoveChannelMetadataRequest *)request
                              completion:(nullable PNRemoveChannelMetadataCompletionBlock)block;

/// `Fetch channel metadata`.
///
/// #### Example:
/// ```objc
/// PNFetchChannelMetadataRequest *request = [PNFetchChannelMetadataRequest requestWithChannel:@"channel"];
/// // Add this request option, if returned metadata model should have value which has been set to
/// // 'custom' property.
/// request.includeFields = PNChannelCustomField;
///
/// [self.client channelMetadataWithRequest:request
///                              completion:^(PNFetchChannelsMetadataResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Channel metadata successfully fetched.
///         // Channel metadata information available here: result.data.metadata
///     } else {
///         // Handle channel metadata fetch error. Check `category` property to find out possible
///         // issue because of which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Fetch channel metadata` request with all information which should be used to fetch existing
///   `channel metadata`.
///   - block: `Fetch channel metadata` request completion block.
- (void)channelMetadataWithRequest:(PNFetchChannelMetadataRequest *)request
                        completion:(PNFetchChannelMetadataCompletionBlock)block;

/// `Fetch all channels metadata`.
///
/// #### Example:
/// ```objc
/// PNFetchAllChannelsMetadataRequest *request = [PNFetchAllChannelsMetadataRequest new];
/// request.start = @"<next from previous request>";
/// // Add this request option, if returned metadata models should have value which has been set to
/// // 'custom' property.
/// request.includeFields = PNChannelCustomField | PNChannelTotalCountField;
/// request.limit = 40;
///
/// [self.client allChannelsMetadataWithRequest:request
///                                  completion:^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Channels metadata successfully fetched.
///         // Result object has following information:
///         //   result.data.metadata - list of fetched channels metadata,
///         //   result.data.next - cursor bookmark for fetching the next page,
///         //   result.data.prev - cursor bookmark for fetching the previous page,
///         //   result.data.totalCount - total number of associated channel metadata.
///     } else {
///         // Handle channels metadata fetch error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Fetch all channels metadata` request with all information which should be used to fetch existing
///   `channels metadata`.
///   - block: `Fetch all channels metadata` request completion block.
- (void)allChannelsMetadataWithRequest:(PNFetchAllChannelsMetadataRequest *)request
                            completion:(PNFetchAllChannelsMetadataCompletionBlock)block;


#pragma mark - Membership objects

/// `Set UUID's membership` in target `channels`.
///
/// #### Example:
/// ```objc
/// NSArray<NSDictionary *> *channels = @[
///   @{ @"channel": @"channel1", @"custom": @{ @"role": @"moderator" } }
/// ];
///
/// PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:@"uuid" channels:channels];
/// // Add this request option, if returned membership models should have value which has been set to
/// // 'custom' and 'channel' properties.
/// request.includeFields = PNMembershipCustomField | PNMembershipChannelField | PNMembershipsTotalCountField;
/// request.limit = 40;
///
/// [self.client setMembershipsWithRequest:request completion:^(PNManageMembershipsStatus *status) {
///     if (!status.isError) {
///         // UUID's memberships successfully set.
///         // Result object has following information:
///         //   status.data.memberships - list of UUID's existing memberships,
///         //   status.data.next - cursor bookmark for fetching the next page,
///         //   status.data.prev - cursor bookmark for fetching the previous page,
///         //   status.data.totalCount - total number of UUID's memberships.
///     } else {
///         // Handle UUID's memberships set error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Set UUID's memberships` request with information which should be used to set `channels` membership.
///   - block: `Set UUID's memberships` request completion block.
- (void)setMembershipsWithRequest:(PNSetMembershipsRequest *)request
                       completion:(nullable PNManageMembershipsCompletionBlock)block;

/// `Remove UUID's membership` in target `channels`.
///
/// #### Example:
/// ```objc
/// NSArray<NSString *> *channels = @[@"channel1", @"channel2"];
///
/// PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:@"uuid" channels:channels];
/// // Add this request option, if returned membership models should have value which has been set to
/// // 'custom' and 'channel' properties.
/// request.includeFields = PNMembershipCustomField | PNMembershipChannelField | PNMembershipsTotalCountField;
/// request.limit = 40;
///
/// [self.client removeMembershipsWithRequest:request completion:^(PNManageMembershipsStatus *status) {
///     if (!status.isError) {
///         // UUID's memberships successfully removed.
///         // Result object has following information:
///         //   status.data.memberships - list of UUID's existing memberships,
///         //   status.data.next - cursor bookmark for fetching the next page,
///         //   status.data.prev - cursor bookmark for fetching the previous page,
///         //   status.data.totalCount - total number of UUID's memberships.
///     } else {
///         // Handle UUID's memberships remove error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Remove UUID's memberships` request with information which should be used to remove `channels`
///   membership.
///   - block: `Remove UUID's memberships` request completion block.
- (void)removeMembershipsWithRequest:(PNRemoveMembershipsRequest *)request
                          completion:(nullable PNManageMembershipsCompletionBlock)block;

/// `Manage UUID's membership` in target `channels`.
///
/// #### Example:
/// ```objc
/// PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:@"uuid"];
/// request.setChannels = @[
///     @{ @"channel": @"channel1", @"custom": @{ @"role": @"moderator" } }
/// ];
/// request.removeChannels = @[@"channel3", @"channel4"];
/// // Add this request option, if returned membership models should have value which has been set to
/// // 'custom' and 'channel' properties.
/// request.includeFields = PNMembershipCustomField | PNMembershipChannelField | PNMembershipsTotalCountField;
/// request.limit = 40;
///
/// [self.client manageMembershipsWithRequest:request completion:^(PNManageMembershipsStatus *status) {
///     if (!status.isError) {
///         // UUID's memberships successfully set.
///         // Result object has following information:
///         //   status.data.memberships - list of UUID's existing memberships,
///         //   status.data.next - cursor bookmark for fetching the next page,
///         //   status.data.prev - cursor bookmark for fetching the previous page,
///         //   status.data.totalCount - total number of UUID's memberships.
///     } else {
///         // Handle UUID's memberships set error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Manage UUID's memberships` request with information what modifications to `UUID's memberships` should
///   be done (`set` / `remove `channels`).
///   - block: `Manage UUID's memberships` request completion block.
- (void)manageMembershipsWithRequest:(PNManageMembershipsRequest *)request
                          completion:(nullable PNManageMembershipsCompletionBlock)block;

/// `Fetch UUID's memberships`.
///
/// #### Example:
/// ```objc
/// PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:@"uuid"];
/// request.start = @"<next from previous request>";
/// // Add this request option, if returned membership models should have value which has been set to
/// // 'custom' and 'channel' properties.
/// request.includeFields = PNMembershipCustomField | PNMembershipChannelField | PNMembershipsTotalCountField;
/// request.limit = 40;
///
/// [self.client membershipsWithRequest:request completion:^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // UUID's memberships successfully fetched.
///         // Result object has following information:
///         //   result.data.memberships - list of UUID's memberships,
///         //   result.data.next - cursor bookmark for fetching the next page,
///         //   result.data.prev - cursor bookmark for fetching the previous page,
///         //   result.data.totalCount - total number of UUID's memberships
///     } else {
///         // Handle UUID's memberships fetch error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Fetch UUID's memberships` request with all information which should be used to fetch existing
///   `UUID's memberships`.
///   - block: `Fetch UUID's memberships` request completion block.
- (void)membershipsWithRequest:(PNFetchMembershipsRequest *)request completion:(PNFetchMembershipsCompletionBlock)block;

/// `Set channel's members` list.
///
/// #### Example:
/// ```objc
/// NSArray<NSDictionary *> *uuids = @[
///   @{ @"uuid": @"uuid2", @"custom": @{ @"role": @"moderator" } }
/// ];
///
/// PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:@"channel" uuids:uuids];
/// // Add this request option, if returned member models should have value which has been set to
/// // 'custom' and 'uuid' properties.
/// request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField | PNChannelMembersTotalCountField;
/// request.limit = 40;
///
/// [self.client setChannelMembersWithRequest:request completion:^(PNManageChannelMembersStatus *status) {
///     if (!status.isError) {
///         // Channel's members successfully set.
///         // Result object has following information:
///         //   result.data.members - list of existing channel's members,
///         //   result.data.next - cursor bookmark for fetching the next page,
///         //   result.data.prev - cursor bookmark for fetching the previous page,
///         //   result.data.totalCount - total number of channel's members.
///     } else {
///         // Handle channel's members set error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Set channel's members` list request with information which should be used to set `UUID` member.
///   - block: `Set channel's members` list request completion block.
- (void)setChannelMembersWithRequest:(PNSetChannelMembersRequest *)request
                          completion:(nullable PNManageChannelMembersCompletionBlock)block;

/// `Remove channel's members`.
///
/// #### Example:
/// ```objc
/// NSArray<NSString *> *uuids = @[@"uuid3", @"uuid4"];
/// PNRemoveChannelMembersRequest *request = [PNRemoveChannelMembersRequest requestWithChannel:@"channel" uuids:uuids];
/// // Add this request option, if returned member models should have value which has been set to
/// // 'custom' and 'uuid' properties.
/// request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField | PNChannelMembersTotalCountField;
/// request.limit = 40;
///
/// [self.client removeChannelMembersWithRequest:request completion:^(PNManageChannelMembersStatus *status) {
///     if (!status.isError) {
///         // Channel's members successfully removed.
///         // Result object has following information:
///         //   result.data.members - list of channel's existing members,
///         //   result.data.next - cursor bookmark for fetching the next page,
///         //   result.data.prev - cursor bookmark for fetching the previous page,
///         //   result.data.totalCount - total number of channel's members.
///     } else {
///         // Handle channel's members remove error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Remove channel's members` request with information which should be used to remove `UUID` members.
///   - block: `Remove channel's members` request completion block.
- (void)removeChannelMembersWithRequest:(PNRemoveChannelMembersRequest *)request
                             completion:(nullable PNManageChannelMembersCompletionBlock)block;

/// `Manage channel's members` list.
///
/// #### Example:
/// ```objc
/// PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:@"channel"];
/// request.setMembers = @[
///     @{ @"uuid": @"uuid2", @"custom": @{ @"role": @"moderator" } }
/// ];
/// request.removeMembers = @[@"uuid3", @"uuid4"];
/// // Add this request option, if returned member models should have value which has been set to
/// // 'custom' and 'uuid' properties.
/// request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField | PNChannelMembersTotalCountField;
/// request.limit = 40;
///
/// [self.client manageChannelMembersWithRequest:request completion:^(PNManageChannelMembersStatus *status) {
///     if (!status.isError) {
///         // Channel's members successfully changed.
///         // Result object has following information:
///         //   result.data.members - list of existing channel's members,
///         //   result.data.next - cursor bookmark for fetching the next page,
///         //   result.data.prev - cursor bookmark for fetching the previous page,
///         //   result.data.totalCount - total number of channel's members.
///     } else {
///         // Handle channel's members manage error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Manage channel's members` list request with information what modifications to `channel's members` list
///   should be done (`set` / `remove` `UUID`).
///   - block: `Manage channel's members` list request completion block.
- (void)manageChannelMembersWithRequest:(PNManageChannelMembersRequest *)request
                             completion:(nullable PNManageChannelMembersCompletionBlock)block;

/// `Fetch channel's members`.
///
/// #### Example:
/// ```objc
/// PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:@"channel"];
/// request.start = @"<next from previous request>";
/// // Add this request option, if returned member models should have value which has been set to
/// // 'custom' and 'uuid' properties.
/// request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField | PNChannelMembersTotalCountField;
/// request.limit = 40;
///
/// [self.client channelMembersWithRequest:request
///                             completion:^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Channel's members successfully fetched.
///         // Result object has following information:
///         //   result.data.members - list of channel's members,
///         //   result.data.next - cursor bookmark for fetching the next page,
///         //   result.data.prev - cursor bookmark for fetching the previous page,
///         //   result.data.totalCount - total number of channel's members.
///     } else {
///         // Handle channel's members fetch error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Fetch channel's members` request with all information which should be used to fetch existing
///   `channel's members`.
///   - block: `Fetch channel's members` request completion block.
- (void)channelMembersWithRequest:(PNFetchChannelMembersRequest *)request
                       completion:(PNFetchChannelMembersCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
