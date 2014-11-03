//
//  PNStructures.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/6/12.
//
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNAccessRightsCollection, PNPresenceEvent, PNChannelGroup, PNHereNow, PNMessage, PNChannel, PNClient, PNError, PNDate;


#ifndef PNStructures_h
#define PNStructures_h

// This enum represents possible message processing states
typedef NS_OPTIONS(NSUInteger, PNMessageState) {

    // Message was scheduled for processing. "processingData" field will contain message instance which was scheduled
    // for processing
    PNMessageSending,

    // Message was successfully sent to the PubNub service. "processingData" field will contain message instance
    // which was sent for processing
    PNMessageSent,

    // PubNub client failed to send message because of some reasons. "processingData" field will contain error instance
    // which will describe error which occurred during message processing
    PNMessageSendingError
};


// This enum represents list of possible presence event types
typedef NS_OPTIONS(NSUInteger, PNPresenceEventType) {
    
    // Number of persons changed in observed channel
    PNPresenceEventChanged,

    // Client's state changed on one of channels
    PNPresenceEventStateChanged,

    // New person joined to the channel
    PNPresenceEventJoin,
    
    // Person leaved channel by its own
    PNPresenceEventLeave,
    
    // Person leaved channel because of timeout
    PNPresenceEventTimeout
};


// This enum represent list of possible events which can occur during requests execution
typedef NS_OPTIONS(NSUInteger, PNOperationResultEvent) {

    // Stores unknown event
    PNOperationResultUnknown,
    PNOperationResultLeave = PNPresenceEventLeave
};


// This enum represents list of possible subscription states which can occur while client subscribing/restoring
typedef NS_OPTIONS(NSUInteger, PNSubscriptionProcessState) {

    // Not subscribed state (maybe some error occurred while tried to subscribe)
    PNSubscriptionProcessNotSubscribedState,

    // Subscribed state
    PNSubscriptionProcessSubscribedState,

    // Will restore subscription (called right after connection restored)
    PNSubscriptionProcessWillRestoreState,

    // Restored subscription after connection restored
    PNSubscriptionProcessRestoredState
};


// This enum represents list of available channel access rights
typedef NS_OPTIONS(unsigned long, PNAccessRights)  {

    // Access rights is unknown because of error or any other reasons.
    PNUnknownAccessRights = 0,

    // \a 'read' access rights is granted.
    PNReadAccessRight = 1 << 0,
    
    // \a 'write' access rights is granted.
    PNWriteAccessRight = 1 << 1,
    
    // All access rights is granted.
    PNAllAccessRights = (PNReadAccessRight | PNWriteAccessRight),
    
    // Additional management right for user level on namespaces/channel groups
    PNManagementRight = 1 << 2,

    // There is no access rights (maybe they has been revoked or expired).
    PNNoAccessRights = 1 << 3
};

// this enum represents access right levels
typedef NS_OPTIONS(NSInteger , PNAccessRightsLevel) {

    /**
     Access rights granted application wide (for \a 'subscribe' key).
     */
    PNApplicationAccessRightsLevel,
    
    /**
     Access rights granted for channel group or namespace.
     */
    PNChannelGroupAccessRightsLevel,
    
    /**
     Access rights granted for particular channel.
     */
    PNChannelAccessRightsLevel,

    /**
     Access rights granted for concrete user (users identified by \a 'authorization' key).
     */
    PNUserAccessRightsLevel,
};


typedef void (^PNClientConnectionSuccessBlock)(NSString *origin);
typedef void (^PNClientConnectionFailureBlock)(PNError *error);
typedef void (^PNClientConnectionStateChangeBlock)(NSString *origin, BOOL isConnected, PNError *error);
typedef void (^PNClientStateRetrieveHandlingBlock)(PNClient *client, PNError *error);
typedef void (^PNClientStateUpdateHandlingBlock)(PNClient *client, PNError *error);
typedef void (^PNClientChannelGroupsRequestHandlingBlock)(NSString *namespaceName, NSArray *channelGroups, PNError *error);
typedef void (^PNClientChannelGroupNamespacesRequestHandlingBlock)(NSArray *namespaces, PNError *error);
typedef void (^PNClientChannelGroupNamespaceRemoveHandlingBlock)(NSString *namespaceName, PNError *error);
typedef void (^PNClientChannelGroupRemoveHandlingBlock)(PNChannelGroup *channelGroup, PNError *error);
typedef void (^PNClientChannelsForGroupRequestHandlingBlock)(PNChannelGroup *channelGroup, PNError *error);
typedef void (^PNClientChannelsAdditionToGroupHandlingBlock)(PNChannelGroup *channelGroup, NSArray *channels,
                                                             PNError *error);
typedef void (^PNClientChannelsRemovalFromGroupHandlingBlock)(PNChannelGroup *channelGroup, NSArray *channels,
                                                              PNError *error);
typedef void (^PNClientChannelSubscriptionHandlerBlock)(PNSubscriptionProcessState state, NSArray *channels, PNError *error);
typedef void (^PNClientChannelUnsubscriptionHandlerBlock)(NSArray *channels, PNError *error);
typedef void (^PNClientTimeTokenReceivingCompleteBlock)(NSNumber *timeToken, PNError *error);
typedef void (^PNClientMessageProcessingBlock)(PNMessageState state, id data);
typedef void (^PNClientMessageHandlingBlock)(PNMessage *message);
typedef void (^PNClientHistoryLoadHandlingBlock)(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate,
                                                 PNError *error);
typedef void (^PNClientParticipantsHandlingBlock)(PNHereNow *presenceInformation, NSArray *channels, PNError *error);
typedef void (^PNClientParticipantChannelsHandlingBlock)(NSString *clientIdentifier, NSArray *channels, PNError *error);
typedef void (^PNClientChannelAccessRightsChangeBlock)(PNAccessRightsCollection *accessRightsCollection, PNError *error);
typedef void (^PNClientChannelAccessRightsAuditBlock)(PNAccessRightsCollection *accessRightsCollection, PNError *error);
typedef void (^PNClientPresenceEventHandlingBlock)(PNPresenceEvent *event);
typedef void (^PNClientPresenceEnableHandlingBlock)(NSArray *channels, PNError *error);
typedef void (^PNClientPresenceDisableHandlingBlock)(NSArray *channels, PNError *error);
typedef void (^PNClientPushNotificationsRemoveHandlingBlock)(PNError *error);
typedef void (^PNClientPushNotificationsEnableHandlingBlock)(NSArray *channels, PNError *error);
typedef void (^PNClientPushNotificationsDisableHandlingBlock)(NSArray *channels, PNError *error);
typedef void (^PNClientPushNotificationsEnabledChannelsHandlingBlock)(NSArray *channels, PNError *error);

#endif // PNStructures_h
