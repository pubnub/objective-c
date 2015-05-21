/**
 @brief Set of types and structures which is used as part of private API in \b PubNub client.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStructures.h"


#ifndef PNPrivateStructures_h
#define PNPrivateStructures_h

/**
 @brief  Helper to stringify operation type in result and status objects.

 @since 4.0
 */
static NSString * const PNOperationTypeStrings[19] = {
    [PNSubscribeOperation] = @"Subscribe",
    [PNUnsubscribeOperation] = @"Unsubscribe",
    [PNPublishOperation] = @"Publish",
    [PNHistoryOperation] = @"History",
    [PNWhereNowOperation] = @"Where Now",
    [PNHereNowOperation] = @"Here Now",
    [PNHeartbeatOperation] = @"Heartbeat",
    [PNSetStateOperation] = @"Set State",
    [PNStateOperation] = @"Get State",
    [PNAddChannelsToGroupOperation] = @"Add Channels To Group",
    [PNRemoveChannelFromGroupOperation] = @"Remove Channels From Group",
    [PNChannelGroupsOperation] = @"Get Groups",
    [PNChannelsForGroupOperation] = @"Get Channels For Group",
    [PNPushNotificationEnabledChannelsOperation] = @"Get Push Notification Enabled Channels",
    [PNAddPushNotificationsOnChannelsOperation] = @"Enable Push Notifications On Channels",
    [PNRemovePushNotificationsFromChannelsOperation] = @"Remove Push Notifications From Channels",
    [PNRemoveAllPushNotificationsOperation] = @"Remove All Push Notifications",
    [PNTimeOperation] = @"Time",
};

/**
 @brief  Helper to stringify status category.

 @since 4.0
 */
static NSString * const PNStatusCategoryStrings[15] = {
    [PNUnknownCategory] = @"Unknown",
    [PNAcknowledgmentCategory] = @"Acknowledgment",
    [PNAccessDeniedCategory] = @"Access Denied",
    [PNTimeoutCategory] = @"Timeout",
    [PNNetworkIssuesCategory] = @"Network Issues",
    [PNConnectedCategory] = @"Connected",
    [PNReconnectedCategory] = @"Reconnected",
    [PNDisconnectedCategory] = @"Expected Disconnect",
    [PNUnexpectedDisconnectCategory] = @"Unexpected Disconnect",
    [PNCancelledCategory] = @"Cancelled",
    [PNBadRequestCategory] = @"Bad Request",
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
