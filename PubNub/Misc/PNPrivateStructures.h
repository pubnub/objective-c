/**
 * @brief Set of types and structures which is used as part of private API in \b PubNub client.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.0.0 
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNStructures.h"


#ifndef PNPrivateStructures_h
#define PNPrivateStructures_h

/**
 * @brief Key under which device ID will be stored persistently.
 */
extern NSString * const kPNConfigurationDeviceIDKey;

/**
 * @brief Key under which in Keychain stored information about previously used sequence number for
 * message publish.
 */
extern NSString * const kPNPublishSequenceDataKey;

/**
 * @brief Key under which unique user identifier will be stored persistently.
 */
extern NSString * const kPNConfigurationUserIdKey;

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
     @brief Type which represent \c uuid / \c channel  \c metadata or \c membership object.
     */
    PNObjectMessageType = 2,
    
    /**
     @brief Type which represent \c message \c action object.
     */
    PNMessageActionType = 3,
    
    /**
     @brief Type which represent \c file \c message object.
     */
    PNFileMessageType = 4
};

/**
 * @brief Helper to stringify operation type in result and status objects.
 *
 * @since 4.0.0
 */
static NSString * const PNOperationTypeStrings[57] = {
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
    [PNPushNotificationEnabledChannelsV2Operation] = @"Get Push Notification Enabled Channels (v2)",
    [PNAddPushNotificationsOnChannelsV2Operation] = @"Enable Push Notifications On Channels (v2)",
    [PNRemovePushNotificationsFromChannelsV2Operation] = @"Remove Push Notifications From Channels (v2)",
    [PNRemoveAllPushNotificationsV2Operation] = @"Remove All Push Notifications (v2)",
    [PNSetUUIDMetadataOperation] = @"Set UUID Metadata",
    [PNRemoveUUIDMetadataOperation] = @"Remove UUID Metadata",
    [PNFetchUUIDMetadataOperation] = @"Fetch UUID Metadata",
    [PNFetchAllUUIDMetadataOperation] = @"Fetch All UUIDs Metadata",
    [PNSetChannelMetadataOperation] = @"Update Channel Metadata",
    [PNRemoveChannelMetadataOperation] = @"Remove Channel Metadata",
    [PNFetchChannelMetadataOperation] = @"Fetch Channel Metadata",
    [PNFetchAllChannelsMetadataOperation] = @"Fetch All Channels Metadata",
    [PNSetMembershipsOperation] = @"Update Memberships",
    [PNRemoveMembershipsOperation] = @"Remove Memberships",
    [PNManageMembershipsOperation] = @"Manage Memberships",
    [PNFetchMembershipsOperation] = @"Fetch Memberships",
    [PNSetChannelMembersOperation] = @"Set Channel Members",
    [PNRemoveChannelMembersOperation] = @"Remove Channel Members",
    [PNManageChannelMembersOperation] = @"Manage Channel Members",
    [PNFetchChannelMembersOperation] = @"Fetch Channel Members",
    [PNGenerateFileUploadURLOperation] = @"Generate File Upload URL",
    [PNPublishFileMessageOperation] = @"Publish File Message",
    [PNSendFileOperation] = @"Send File",
    [PNListFilesOperation] = @"List Files",
    [PNDownloadFileOperation] = @"Download File",
    [PNDeleteFileOperation] = @"Delete file",
    [PNTimeOperation] = @"Time",
};

static NSString * const PNOperationResultClasses[57] = {
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
    [PNPushNotificationEnabledChannelsV2Operation] = @"PNAPNSEnabledChannelsResult",
    [PNFetchMessagesActionsOperation] = @"PNFetchMessageActionsResult",
    [PNFetchUUIDMetadataOperation] = @"PNFetchUUIDMetadataResult",
    [PNFetchAllUUIDMetadataOperation] = @"PNFetchAllUUIDMetadataResult",
    [PNFetchChannelMetadataOperation] = @"PNFetchChannelMetadataResult",
    [PNFetchAllChannelsMetadataOperation] = @"PNFetchAllChannelsMetadataResult",
    [PNFetchMembershipsOperation] = @"PNFetchMembershipsResult",
    [PNFetchChannelMembersOperation] = @"PNFetchChannelMembersResult",
    [PNListFilesOperation] = @"PNListFilesResult",
    [PNDownloadFileOperation] = @"PNDownloadFileResult",
    [PNTimeOperation] = @"PNTimeResult",
};

static NSString * const PNOperationStatusClasses[57] = {
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
    [PNPushNotificationEnabledChannelsV2Operation] = @"PNErrorStatus",
    [PNAddPushNotificationsOnChannelsV2Operation] = @"PNAcknowledgmentStatus",
    [PNRemovePushNotificationsFromChannelsV2Operation] = @"PNAcknowledgmentStatus",
    [PNRemoveAllPushNotificationsV2Operation] = @"PNAcknowledgmentStatus",
    [PNSetUUIDMetadataOperation] = @"PNSetUUIDMetadataStatus",
    [PNRemoveUUIDMetadataOperation] = @"PNAcknowledgmentStatus",
    [PNFetchUUIDMetadataOperation] = @"PNErrorStatus",
    [PNFetchAllUUIDMetadataOperation] = @"PNErrorStatus",
    [PNSetChannelMetadataOperation] = @"PNSetChannelMetadataStatus",
    [PNRemoveChannelMetadataOperation] = @"PNAcknowledgmentStatus",
    [PNFetchChannelMetadataOperation] = @"PNErrorStatus",
    [PNFetchAllChannelsMetadataOperation] = @"PNErrorStatus",
    [PNSetMembershipsOperation] = @"PNManageMembershipsStatus",
    [PNRemoveMembershipsOperation] = @"PNManageMembershipsStatus",
    [PNManageMembershipsOperation] = @"PNManageMembershipsStatus",
    [PNFetchMembershipsOperation] = @"PNErrorStatus",
    [PNSetChannelMembersOperation] = @"PNManageChannelMembersStatus",
    [PNRemoveChannelMembersOperation] = @"PNManageChannelMembersStatus",
    [PNManageChannelMembersOperation] = @"PNManageChannelMembersStatus",
    [PNFetchChannelMembersOperation] = @"PNErrorStatus",
    [PNGenerateFileUploadURLOperation] = @"PNGenerateFileUploadURLStatus",
    [PNPublishFileMessageOperation] = @"PNPublishStatus",
    [PNSendFileOperation] = @"PNSendFileStatus",
    [PNListFilesOperation] = @"PNErrorStatus",
    [PNDownloadFileOperation] = @"PNErrorStatus",
    [PNDeleteFileOperation] = @"PNAcknowledgmentStatus",
    [PNTimeOperation] = @"PNErrorStatus",
};

/**
 * @brief Helper to stringify status category.
 *
 * @since 4.0.0
 */
static NSString * const PNStatusCategoryStrings[21] = {
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
    [PNTLSUntrustedCertificateCategory] = @"Untrusted TLS Certificate",
    [PNSendFileErrorCategory] = @"File Upload Failed",
    [PNPublishFileMessageErrorCategory] = @"File Message Publish Failed",
    [PNDownloadErrorCategory] = @"File Download Failed"
};

/**
 * @brief Helper to stringify here now data set information.
 *
 * @since 4.0.0
 */
static NSString * const PNHereNowDataStrings[3] = {
    [PNHereNowOccupancy] = @"occupancy only",
    [PNHereNowUUID] = @"UUID list and occupancy",
    [PNHereNowState] = @"occupancy, UUID and state"
};

#endif // PNPrivateStructures_h
