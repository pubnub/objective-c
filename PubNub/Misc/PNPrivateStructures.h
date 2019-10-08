/**
 @brief Set of types and structures which is used as part of private API in \b PubNub client.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNStructures.h"


#ifndef PNPrivateStructures_h
#define PNPrivateStructures_h

/**
 * @brief Stores reference on key under which unique user identifier will be stored persistently.
 */
extern NSString * const kPNConfigurationUUIDKey;

/**
 * @brief Options describe object's message type.
 *
 * @since 4.9.0
 */
typedef NS_OPTIONS(NSUInteger, PNMessageType) {
    /**
     @brief Type which represent regular message object.
     */
    PNRegularMessageType = 0,
    
    /**
     @brief Type which represent signal object.
     */
    PNSignalMessageType = 1,
    
    /**
     @brief Type which represent \c user / \c space / \c membership object.
     */
    PNObjectMessageType = 2,
    
    /**
     @brief Type which represent \c message \c action object.
     */
    PNMessageActionType = 3
};

/**
 @brief Helper to stringify operation type in result and status objects.

 @since 4.0
 */
static NSString * const PNOperationTypeStrings[45] = {
    [PNSubscribeOperation] = @"Subscribe",
    [PNUnsubscribeOperation] = @"Unsubscribe",
    [PNPublishOperation] = @"Publish",
    [PNSignalOperation] = @"Signal",
    [PNAddMessageActionOperation] = @"Add Message Action",
    [PNRemoveMessageActionOperation] = @"Remove Message Action",
    [PNFetchMessagesActionsOperation] = @"Fetch Messages Actions",
    [PNHistoryOperation] = @"History",
    [PNHistoryForChannelsOperation] = @"History for Channels",
    [PNHistoryWithActionsOperation] = @"History with Actions",
    [PNDeleteMessageOperation] = @"Delete message from History",
    [PNMessageCountOperation] = @"Message count for Channels",
    [PNWhereNowOperation] = @"Where Now",
    [PNHereNowGlobalOperation] = @"Global Here Now",
    [PNHereNowForChannelOperation] = @"Here Now for Channel",
    [PNHereNowForChannelGroupOperation] = @"Here Now for Channel Group",
    [PNHeartbeatOperation] = @"Heartbeat",
    [PNSetStateOperation] = @"Set State",
    [PNGetStateOperation] = @"Get State for Channels and / or Channel Groups",
    [PNStateForChannelOperation] = @"Get State for Channel",
    [PNStateForChannelGroupOperation] = @"Get State for Channel Group",
    [PNAddChannelsToGroupOperation] = @"Add Channels To Group",
    [PNRemoveChannelsFromGroupOperation] = @"Remove Channels From Group",
    [PNChannelGroupsOperation] = @"Get Groups",
    [PNRemoveGroupOperation] = @"Remove Channel Group",
    [PNChannelsForGroupOperation] = @"Get Channels For Group",
    [PNPushNotificationEnabledChannelsOperation] = @"Get Push Notification Enabled Channels",
    [PNAddPushNotificationsOnChannelsOperation] = @"Enable Push Notifications On Channels",
    [PNRemovePushNotificationsFromChannelsOperation] = @"Remove Push Notifications From Channels",
    [PNRemoveAllPushNotificationsOperation] = @"Remove All Push Notifications",
    [PNCreateUserOperation] = @"Create User",
    [PNUpdateUserOperation] = @"Update User",
    [PNDeleteUserOperation] = @"Delete User",
    [PNFetchUserOperation] = @"Fetch User",
    [PNFetchUsersOperation] = @"Fetch All Users",
    [PNCreateSpaceOperation] = @"Create Space",
    [PNUpdateSpaceOperation] = @"Update Space",
    [PNDeleteSpaceOperation] = @"Delete Space",
    [PNFetchSpaceOperation] = @"Fetch Space",
    [PNFetchSpacesOperation] = @"Fetch All Spaces",
    [PNManageMembershipsOperation] = @"Manage Memberships",
    [PNFetchMembershipsOperation] = @"Fetch Memberships",
    [PNManageMembersOperation] = @"Manage Members",
    [PNFetchMembersOperation] = @"Fetch Members",
    [PNTimeOperation] = @"Time",
};

static NSString * const PNOperationResultClasses[45] = {
    [PNHistoryOperation] = @"PNHistoryResult",
    [PNHistoryForChannelsOperation] = @"PNHistoryResult",
    [PNHistoryWithActionsOperation] = @"PNHistoryResult",
    [PNMessageCountOperation] = @"PNMessageCountResult",
    [PNWhereNowOperation] = @"PNPresenceWhereNowResult",
    [PNHereNowGlobalOperation] = @"PNPresenceGlobalHereNowResult",
    [PNHereNowForChannelOperation] = @"PNPresenceChannelHereNowResult",
    [PNHereNowForChannelGroupOperation] = @"PNPresenceChannelGroupHereNowResult",
    [PNGetStateOperation] = @"PNClientStateGetResult",
    [PNStateForChannelOperation] = @"PNChannelClientStateResult",
    [PNStateForChannelGroupOperation] = @"PNChannelGroupClientStateResult",
    [PNChannelGroupsOperation] = @"PNChannelGroupsResult",
    [PNChannelsForGroupOperation] = @"PNChannelGroupChannelsResult",
    [PNPushNotificationEnabledChannelsOperation] = @"PNAPNSEnabledChannelsResult",
    [PNFetchMessagesActionsOperation] = @"PNFetchMessageActionsResult",
    [PNFetchUserOperation] = @"PNFetchUserResult",
    [PNFetchUsersOperation] = @"PNFetchUsersResult",
    [PNFetchSpaceOperation] = @"PNFetchSpaceResult",
    [PNFetchSpacesOperation] = @"PNFetchSpacesResult",
    [PNFetchMembershipsOperation] = @"PNFetchMembershipsResult",
    [PNFetchMembersOperation] = @"PNFetchMembersResult",
    [PNTimeOperation] = @"PNTimeResult",
};

static NSString * const PNOperationStatusClasses[45] = {
    [PNSubscribeOperation] = @"PNSubscribeStatus",
    [PNUnsubscribeOperation] = @"PNAcknowledgmentStatus",
    [PNPublishOperation] = @"PNPublishStatus",
    [PNSignalOperation] = @"PNSignalStatus",
    [PNAddMessageActionOperation] = @"PNAddMessageActionStatus",
    [PNRemoveMessageActionOperation] = @"PNAcknowledgmentStatus",
    [PNFetchMessagesActionsOperation] = @"PNErrorStatus",
    [PNHistoryOperation] = @"PNErrorStatus",
    [PNHistoryForChannelsOperation] = @"PNErrorStatus",
    [PNHistoryWithActionsOperation] = @"PNErrorStatus",
    [PNDeleteMessageOperation] = @"PNAcknowledgmentStatus",
    [PNMessageCountOperation] = @"PNErrorStatus",
    [PNWhereNowOperation] = @"PNErrorStatus",
    [PNHereNowGlobalOperation] = @"PNErrorStatus",
    [PNHereNowForChannelOperation] = @"PNErrorStatus",
    [PNHereNowForChannelGroupOperation] = @"PNErrorStatus",
    [PNHeartbeatOperation] = @"PNAcknowledgmentStatus",
    [PNSetStateOperation] = @"PNClientStateUpdateStatus",
    [PNGetStateOperation] = @"PNErrorStatus",
    [PNStateForChannelOperation] = @"PNErrorStatus",
    [PNStateForChannelGroupOperation] = @"PNErrorStatus",
    [PNAddChannelsToGroupOperation] = @"PNAcknowledgmentStatus",
    [PNRemoveChannelsFromGroupOperation] = @"PNAcknowledgmentStatus",
    [PNChannelGroupsOperation] = @"PNErrorStatus",
    [PNRemoveGroupOperation] = @"PNAcknowledgmentStatus",
    [PNChannelsForGroupOperation] = @"PNErrorStatus",
    [PNPushNotificationEnabledChannelsOperation] = @"PNErrorStatus",
    [PNAddPushNotificationsOnChannelsOperation] = @"PNAcknowledgmentStatus",
    [PNRemovePushNotificationsFromChannelsOperation] = @"PNAcknowledgmentStatus",
    [PNRemoveAllPushNotificationsOperation] = @"PNAcknowledgmentStatus",
    [PNCreateUserOperation] = @"PNCreateUserStatus",
    [PNUpdateUserOperation] = @"PNUpdateUserStatus",
    [PNDeleteUserOperation] = @"PNAcknowledgmentStatus",
    [PNFetchUserOperation] = @"PNErrorStatus",
    [PNFetchUsersOperation] = @"PNErrorStatus",
    [PNCreateSpaceOperation] = @"PNCreateSpaceStatus",
    [PNUpdateSpaceOperation] = @"PNUpdateSpaceStatus",
    [PNDeleteSpaceOperation] = @"PNAcknowledgmentStatus",
    [PNFetchSpaceOperation] = @"PNErrorStatus",
    [PNFetchSpacesOperation] = @"PNErrorStatus",
    [PNManageMembershipsOperation] = @"PNManageMembershipsStatus",
    [PNFetchMembershipsOperation] = @"PNErrorStatus",
    [PNManageMembersOperation] = @"PNManageMembersStatus",
    [PNFetchMembersOperation] = @"PNErrorStatus",
    [PNTimeOperation] = @"PNErrorStatus",
};

/**
 @brief  Helper to stringify status category.

 @since 4.0
 */
static NSString * const PNStatusCategoryStrings[18] = {
    [PNUnknownCategory] = @"Unknown",
    [PNAcknowledgmentCategory] = @"Acknowledgment",
    [PNAccessDeniedCategory] = @"Access Denied",
    [PNTimeoutCategory] = @"Timeout",
    [PNNetworkIssuesCategory] = @"Network Issues",
    [PNRequestMessageCountExceededCategory] = @"Message Count Exceeded",
    [PNConnectedCategory] = @"Connected",
    [PNReconnectedCategory] = @"Reconnected",
    [PNDisconnectedCategory] = @"Expected Disconnect",
    [PNUnexpectedDisconnectCategory] = @"Unexpected Disconnect",
    [PNCancelledCategory] = @"Cancelled",
    [PNBadRequestCategory] = @"Bad Request",
    [PNRequestURITooLongCategory] = @"Request-URI Too Long",
    [PNMalformedFilterExpressionCategory] = @"Malformed Filter Expression",
    [PNMalformedResponseCategory] = @"Malformed Response",
    [PNDecryptionErrorCategory] = @"Decryption Error",
    [PNTLSConnectionFailedCategory] = @"TLS Connection Failed",
    [PNTLSUntrustedCertificateCategory] = @"Untrusted TLS Certificate"
};

/**
 @brief  Helper to stringify here now data set information.

 @since 4.0
 */
static NSString * const PNHereNowDataStrings[3] = {
    [PNHereNowOccupancy] = @"occupancy only",
    [PNHereNowUUID] = @"UUID list and occupancy",
    [PNHereNowState] = @"occupancy, UUID and state"
};

#endif // PNPrivateStructures_h
