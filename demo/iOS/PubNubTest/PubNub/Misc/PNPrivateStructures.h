/**
 @brief Set of types and structures which is used as part of private API in \b PubNub client.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStructures.h"

#ifndef PNPrivateStructures_h
#define PNPrivateStructures_h

static NSString * const PNOperationTypeStrings[] = {
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

static NSString * const PNStatusCategoryStrings[] = {
    [PNUnknownCategory] = @"Unknown",
    [PNAccessDeniedCategory] = @"Access Denied",
    [PNTimeoutCategory] = @"Timeout",
    [PNCancelledCategory] = @"Cancelled",
    [PNMalformedResponseCategory] = @"Malformed Response",
};

#endif // PNPrivateStructures_h
