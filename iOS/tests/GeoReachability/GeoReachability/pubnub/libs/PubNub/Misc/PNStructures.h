//
//  PNStructures.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/6/12.
//
//


#pragma mark Class forward

@class PNPresenceEvent, PNMessage, PNChannel, PNError, PNDate;


#ifndef PNStructures_h
#define PNStructures_h

// This enum represents possible message processing states
typedef enum _PNMessageState {

    // Message was scheduled for processing. "processingData" field will contain message instance which was scheduled
    // for processing
    PNMessageSending,

    // Message was successfully sent to the PubNub service. "processingData" field will contain message instance
    // which was sent for processing
    PNMessageSent,

    // PubNub client failed to send message because of some reasons. "processingData" field will contain error instance
    // which will describe error which occurred during message processing
    PNMessageSendingError
} PNMessageState;


// This enum represents list of possible presence event types
typedef enum _PNPresenceEventType {
    
    // Number of persons changed in observed channel
    PNPresenceEventChanged,

    // New person joined to the channel
    PNPresenceEventJoin,
    
    // Person leaved channel by its own
    PNPresenceEventLeave,
    
    // Person leaved channel because of timeout
    PNPresenceEventTimeout
} PNPresenceEventType;

// This enum represent list of possible events which can occur during requests execution
typedef enum _PNOperationResultEvent {

    // Stores unknown event
    PNOperationResultUnknown,
    PNOperationResultLeave = PNPresenceEventLeave
} PNOperationResultEvent;


// This enum represents list of possible subscription states which can occur while client subscribing/restoring
typedef enum _PNSubscriptionProcessState {

    // Not subscribed state (maybe some error occurred while tried to subscribe)
    PNSubscriptionProcessNotSubscribedState,

    // Subscribed state
    PNSubscriptionProcessSubscribedState,

    // Will restore subscription (called right after connection restored)
    PNSubscriptionProcessWillRestoreState,

    // Restored subscription after connection restored
    PNSubscriptionProcessRestoredState
} PNSubscriptionProcessState;


typedef void (^PNClientConnectionSuccessBlock)(NSString *);
typedef void (^PNClientConnectionFailureBlock)(PNError *);
typedef void (^PNClientConnectionStateChangeBlock)(NSString *, BOOL, PNError *);
typedef void (^PNClientChannelSubscriptionHandlerBlock)(PNSubscriptionProcessState state, NSArray *, PNError *);
typedef void (^PNClientChannelUnsubscriptionHandlerBlock)(NSArray *, PNError *);
typedef void (^PNClientTimeTokenReceivingCompleteBlock)(NSNumber *, PNError *);
typedef void (^PNClientMessageProcessingBlock)(PNMessageState, id);
typedef void (^PNClientMessageHandlingBlock)(PNMessage *);
typedef void (^PNClientHistoryLoadHandlingBlock)(NSArray *, PNChannel *, PNDate *, PNDate *, PNError *);
typedef void (^PNClientParticipantsHandlingBlock)(NSArray *, PNChannel *, PNError *);
typedef void (^PNClientPresenceEventHandlingBlock)(PNPresenceEvent *);
typedef void (^PNClientPresenceEnableHandlingBlock)(NSArray *, PNError *);
typedef void (^PNClientPresenceDisableHandlingBlock)(NSArray *, PNError *);
typedef void (^PNClientPushNotificationsRemoveHandlingBlock)(PNError *);
typedef void (^PNClientPushNotificationsEnableHandlingBlock)(NSArray *, PNError *);
typedef void (^PNClientPushNotificationsDisableHandlingBlock)(NSArray *, PNError *);
typedef void (^PNClientPushNotificationsEnabledChannelsHandlingBlock)(NSArray *, PNError *);

#endif // PNStructures_h
