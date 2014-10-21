//
//  PNServiceResponseCallbacks.h
//  pubnub
//
//  This header file stores keys which are
//  used to callback function names in service
//  response
//  
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#ifndef PNServiceResponseCallbacks_h
#define PNServiceResponseCallbacks_h


struct PNServiceResponseCallbacksStruct {
    
    // Name of the function which is used to retrieve message which is used by network profiler for latency calculation.
    __unsafe_unretained NSString *latencyMeasureMessageCallback;

    // Name of the function which is used for state retrieval request.
    __unsafe_unretained NSString *stateRetrieveCallback;
    
    // Name of the function which is used for state update request.
    __unsafe_unretained NSString *stateUpdateCallback;
    
    // Name of the function which is used for channel groups request.
    __unsafe_unretained NSString *channelGroupsRequestCallback;
    
    // Name of the function which is used for channel group namespaces request.
    __unsafe_unretained NSString *channelGroupNamespacesRequestCallback;
    
    // Name of the function which is used for channel group namespace removal.
    __unsafe_unretained NSString *channelGroupNamespaceRemoveCallback;
    
    // Name of the function which is used for channel group removal.
    __unsafe_unretained NSString *channelGroupRemoveCallback;
    
    // Name of the function which is used for channels list for group request.
    __unsafe_unretained NSString *channelsForGroupRequestCallback;
    
    // Name of the function which is used for channels addition into channel group.
    __unsafe_unretained NSString *channelGroupChannelsAddCallback;
    
    // Name of the function which is used for channels addition into channel group.
    __unsafe_unretained NSString *channelGroupChannelsRemoveCallback;

    // Name of the function which is used for subscription and presence events for set/single channel(s).
    __unsafe_unretained NSString *subscriptionCallback;
    
    // Name of the function which is used to leave specified channel(s)
    __unsafe_unretained NSString *leaveChannelCallback;

    // Name of the function which is used for push notification enabling request for channel(s).
    __unsafe_unretained NSString *channelPushNotificationsEnableCallback;

    // Name of the function which is used for push notification disabling request for channel(s).
    __unsafe_unretained NSString *channelPushNotificationsDisableCallback;

    // Name of the function which is used for push notification enabled channels retrieval request.
    __unsafe_unretained NSString *pushNotificationEnabledChannelsCallback;

    // Name of the function which is used for push notification removal from all channels request.
    __unsafe_unretained NSString *pushNotificationRemoveCallback;
    
    // Name of the function which is used to mark response which tells client about sent message processing result.
    __unsafe_unretained NSString *sendMessageCallback;
    
    // Name of the function which is used to retrieve current time token from PubNub service.
    __unsafe_unretained NSString *timeTokenCallback;

    // Name of the function which is used to retrieve channel history.
    __unsafe_unretained NSString *messageHistoryCallback;

    // Name of the function which is used to retrieve channel participants.
    __unsafe_unretained NSString *channelParticipantsCallback;

    // Name of the function which is used to retrieve participant channels.
    __unsafe_unretained NSString *participantChannelsCallback;

    // Name of the function which is used to change channel access rights
    __unsafe_unretained NSString *channelAccessRightsChangeCallback;

    // Name of the function which is used to request channel access rights
    __unsafe_unretained NSString *channelAccessRightsAuditCallback;
};

extern struct PNServiceResponseCallbacksStruct PNServiceResponseCallbacks;

#endif // PNServiceResponseCallbacks_h
