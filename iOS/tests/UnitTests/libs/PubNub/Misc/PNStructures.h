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


typedef void (^PNClientConnectionSuccessBlock)(NSString *);
typedef void (^PNClientConnectionFailureBlock)(PNError *);
typedef void (^PNClientConnectionStateChangeBlock)(NSString *, BOOL, PNError *);
typedef void (^PNClientStateRetrieveHandlingBlock)(PNClient *, PNError *);
typedef void (^PNClientStateUpdateHandlingBlock)(PNClient *, PNError *);
typedef void (^PNClientChannelGroupsRequestHandlingBlock)(NSString *, NSArray *, PNError *);
typedef void (^PNClientChannelGroupNamespacesRequestHandlingBlock)(NSArray *, PNError *);
typedef void (^PNClientChannelGroupNamespaceRemoveHandlingBlock)(NSString *, PNError *);
typedef void (^PNClientChannelGroupRemoveHandlingBlock)(PNChannelGroup *, PNError *);
typedef void (^PNClientChannelsForGroupRequestHandlingBlock)(PNChannelGroup *, PNError *);
typedef void (^PNClientChannelsAdditionToGroupHandlingBlock)(PNChannelGroup *, NSArray *, PNError *);
typedef void (^PNClientChannelsRemovalFromGroupHandlingBlock)(PNChannelGroup *, NSArray *, PNError *);
typedef void (^PNClientChannelSubscriptionHandlerBlock)(PNSubscriptionProcessState state, NSArray *, PNError *);
typedef void (^PNClientChannelUnsubscriptionHandlerBlock)(NSArray *, PNError *);
typedef void (^PNClientTimeTokenReceivingCompleteBlock)(NSNumber *, PNError *);
typedef void (^PNClientMessageProcessingBlock)(PNMessageState, id);
typedef void (^PNClientMessageHandlingBlock)(PNMessage *);
typedef void (^PNClientHistoryLoadHandlingBlock)(NSArray *, PNChannel *, PNDate *, PNDate *, PNError *);
typedef void (^PNClientParticipantsHandlingBlock)(PNHereNow *, NSArray *, PNError *);
typedef void (^PNClientParticipantChannelsHandlingBlock)(NSString *, NSArray *, PNError *);
typedef void (^PNClientChannelAccessRightsChangeBlock)(PNAccessRightsCollection *, PNError *);
typedef void (^PNClientChannelAccessRightsAuditBlock)(PNAccessRightsCollection *, PNError *);
typedef void (^PNClientPresenceEventHandlingBlock)(PNPresenceEvent *);
typedef void (^PNClientPresenceEnableHandlingBlock)(NSArray *, PNError *);
typedef void (^PNClientPresenceDisableHandlingBlock)(NSArray *, PNError *);
typedef void (^PNClientPushNotificationsRemoveHandlingBlock)(PNError *);
typedef void (^PNClientPushNotificationsEnableHandlingBlock)(NSArray *, PNError *);
typedef void (^PNClientPushNotificationsDisableHandlingBlock)(NSArray *, PNError *);
typedef void (^PNClientPushNotificationsEnabledChannelsHandlingBlock)(NSArray *, PNError *);

#endif // PNStructures_h
