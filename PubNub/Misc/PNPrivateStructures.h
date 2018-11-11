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
 @brief  Stores reference on key under which unique user identifier will be stored persistently.
 */
extern NSString * const kPNConfigurationUUIDKey;

/**
 @brief  Helper to stringify operation type in result and status objects.

 @since 4.0
 */
static NSString * const PNOperationTypeStrings[25] = {
    [PNSubscribeOperation] = @"Subscribe",
    [PNUnsubscribeOperation] = @"Unsubscribe",
    [PNPublishOperation] = @"Publish",
    [PNHistoryOperation] = @"History",
    [PNHistoryForChannelsOperation] = @"History for Channels",
    [PNDeleteMessageOperation] = @"Delete message from History",
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
    [PNTimeOperation] = @"Time",
};

static NSString * const PNOperationResultClasses[25] = {
    [PNHistoryOperation] = @"PNHistoryResult",
    [PNHistoryForChannelsOperation] = @"PNHistoryResult",
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
    [PNTimeOperation] = @"PNTimeResult",
};

static NSString * const PNOperationStatusClasses[25] = {
    [PNSubscribeOperation] = @"PNSubscribeStatus",
    [PNUnsubscribeOperation] = @"PNAcknowledgmentStatus",
    [PNPublishOperation] = @"PNPublishStatus",
    [PNHistoryOperation] = @"PNErrorStatus",
    [PNHistoryForChannelsOperation] = @"PNErrorStatus",
    [PNDeleteMessageOperation] = @"PNAcknowledgmentStatus",
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
