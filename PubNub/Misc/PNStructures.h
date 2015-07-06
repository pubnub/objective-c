/**
 @brief Set of types and structures which is used as part of API calls in \b PubNub client.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNResult, PNStatus;


#ifndef PNStructures_h
#define PNStructures_h

/**
 @brief  \b PubNub client logging levels available for manipulations.
 
 @since 4.0
 */
typedef NS_OPTIONS(NSUInteger, PNLogLevel){
    
    /**
     @brief       \b PNLog level which allow to disable all active logging levels.
     @discussion This log level can be set with \b PNLog class method +setLogLevel:
     
     @since 4.0
     */
    PNSilentLogLevel = (NSUIntegerMax ^ (NSUIntegerMax >> 1)),
    
    /**
     @brief      \b PNLog level which allow to print out client information data.
     @discussion Log events like: transition between foreground/background, configuration 
                 modification
     
     @since 4.0
     */
    PNInfoLogLevel = (NSUIntegerMax ^ (NSUIntegerMax >> 2 | PNSilentLogLevel)),
    
    /**
     @brief  \b PNLog level which allow to print out all reachability events.
     
     @since 4.0
     */
    PNReachabilityLogLevel = (NSUIntegerMax ^ (NSUIntegerMax >> 3 | (NSUIntegerMax ^ (NSUIntegerMax >> 2)))),
    
    /**
     @brief  \b PNLog level which allow to print out all API call request URI which has been passed
             to communicate with \b PubNub service.
     
     @since 4.0
     */
    PNRequestLogLevel = (NSUIntegerMax ^ (NSUIntegerMax >> 4 | (NSUIntegerMax ^ (NSUIntegerMax >> 3)))),
    
    /**
     @brief  \b PNLog level which allow to print out API execution results.
     
     @since 4.0
     */
    PNResultLogLevel = (NSUIntegerMax ^ (NSUIntegerMax >> 5 | (NSUIntegerMax ^ (NSUIntegerMax >> 4)))),
    
    /**
     @brief  \b PNLog level which allow to print out client state change status information and 
             API request processing errors.
     
     @since 4.0
     */
    PNStatusLogLevel = (NSUIntegerMax ^ (NSUIntegerMax >> 6 | (NSUIntegerMax ^ (NSUIntegerMax >> 5)))),
    
    /**
     @brief      \b PNLog level which allow to print out every failure status information.
     @discussion Every API call may fail and this option allow to print out information about 
                 processing status and current client state.
     
     @since 4.0
     */
    PNFailureStatusLogLevel = (NSUIntegerMax ^ (NSUIntegerMax >> 7 | (NSUIntegerMax ^ (NSUIntegerMax >> 6)))),
    
    /**
     @brief      \b PNLog level which allow to print out all API calls with passed parameters.
     @discussion This log level allo with debug to find out when API has been called and what
                 parameters should be passed.
     
     @since 4.0
     */
    PNAPICallLogLevel = (NSUIntegerMax ^ (NSUIntegerMax >> 8 | (NSUIntegerMax ^ (NSUIntegerMax >> 7)))),
    
    /**
     @brief  \b PNLog level which allow to print out all AES errors.
     
     @since 4.0
     */
    PNAESErrorLogLevel = (NSUIntegerMax ^ (NSUIntegerMax >> 9 | (NSUIntegerMax ^ (NSUIntegerMax >> 8)))),
    
    /**
     @brief  Log every message from \b PubNub client.
     
     @since 4.0
     */
    PNVerboseLogLevel = (PNInfoLogLevel|PNReachabilityLogLevel|PNRequestLogLevel|PNResultLogLevel|
                         PNStatusLogLevel|PNFailureStatusLogLevel|PNAPICallLogLevel|
                         PNAESErrorLogLevel)
};

/**
 @brief      Type which specify possible operations for \b PNResult/ \b PNStatus event objects.
 @discussion This fields allow to identify for what kind of API this object arrived.
 
 @since 4.0
 */
typedef NS_ENUM(NSInteger, PNOperationType){
    PNSubscribeOperation,
    PNUnsubscribeOperation,
    PNPublishOperation,
    PNHistoryOperation,
    PNWhereNowOperation,
    PNHereNowGlobalOperation,
    PNHereNowForChannelOperation,
    PNHereNowForChannelGroupOperation,
    PNHeartbeatOperation,
    PNSetStateOperation,
    PNStateForChannelOperation,
    PNStateForChannelGroupOperation,
    PNAddChannelsToGroupOperation,
    PNRemoveChannelsFromGroupOperation,
    PNChannelGroupsOperation,
    PNRemoveGroupOperation,
    PNChannelsForGroupOperation,
    PNPushNotificationEnabledChannelsOperation,
    PNAddPushNotificationsOnChannelsOperation,
    PNRemovePushNotificationsFromChannelsOperation,
    PNRemoveAllPushNotificationsOperation,
    PNTimeOperation
};

/**
 @brief  Describe set of \b status categories which will be used to deliver any client state change
         using handlers.

 @since 4.0
 */
typedef NS_ENUM(NSInteger, PNStatusCategory) {
    
    PNUnknownCategory,
    
    /**
     @brief      \b PubNub request acknowledgment status.
     @discussion Some API endpoints respond with request processing status w/o useful data.

     @since 4.0
     */
    PNAcknowledgmentCategory,

    /**
     @brief      \b PubNub Access Manager forbidden access to particular API.
     @discussion It is possible what at the moment when API has been used access rights hasn't been
                 applied to the client.

     @since 4.0
     */
    PNAccessDeniedCategory,

    /**
     @brief      API processing failed because of request time out.
     @discussion This type of status is possible in case of very slow connection when request
                 doesn't have enough time to complete processing (send request body and receive
                 server response).

     @since 4.0
     */
    PNTimeoutCategory,

    /**
     @brief      API request is impossible because there is no connection.
     @discussion At the moment when API has been used there was no active connection to the
                 Internet.

     @since 4.0
     */
    PNNetworkIssuesCategory,

    /**
     @brief      Status sent when client successfully subscribed to remote data objects live feed.
     @discussion Connected mean what client will receive live updates from \b PubNub service at
                 specified set of data objects.

     @since 4.0
     */
    PNConnectedCategory,

    /**
     @brief      Status sent when client successfully restored subscription to remote data objects
                 live feed after unexpected disconnection.

     @since 4.0
     */
    PNReconnectedCategory,

    /**
     @brief      Status sent when client successfully unsubscribed from one of remote data objects
                 live feeds.
     @discussion Disconnected mean what client won't receive live updates from \b PubNub service
                 from set of channels used in unsubscribe API.

     @since 4.0
     */
    PNDisconnectedCategory,

    /**
     @brief  Status sent when client unexpectedly lost ability to receive live updates from
             \b PubNub service.
     @discussion This state is sent in case of issues which doesn't allow it anymore receive live
                 updates from \b PubNub service. After issue resolve connection can be restored.
                 In case if issue appeared because of network connection client will restore
                 connection only if configured to restore subscription.

     @since 4.0
     */
    PNUnexpectedDisconnectCategory,

    /**
     @brief      Status which is used to notify about API call cancellation.
     @discussion Mostly cancellation possible only for connection based operations
                 (subscribe/leave).

     @since 4.0
     */
    PNCancelledCategory,

    /**
     @brief      Status is used to notify what API request from client is malformed.
     @discussion In case if this status arrive, it is better to print out status object debug
                 description and contact support@pubnub.com

     @since 4.0
     */
    PNBadRequestCategory,

    /**
     @brief      \b PubNub because of some issues sent malformed response.
     @discussion In case if this status arrive, it is better to print out status object debug
                 description and contact support@pubnub.com

     @since 4.0
     */
    PNMalformedResponseCategory,

    /**
     @brief      Looks like \b PubNub client can't use provided \c cipherKey to decrypt received
                 message.
     @discussion In case if this status arrive, make sure what all clients use same \c cipherKey to
                 encrypt published messages.

     @since 4.0
     */
    PNDecryptionErrorCategory,

    /**
     @brief      Status is sent in case if client was unable to use API using secured connection.
     @discussion In case if this issue happens, client can be re-configured to use insecure
                 connection. If insecure connection is impossible then it is better to print out
                 status object debug description and contact support@pubnub.com

     @since 4.0
     */
    PNTLSConnectionFailedCategory,

    /**
     @brief      Status is sent in case if client unable to check certificates trust chain.
     @discussion If this state arrive it is possible what proxy or VPN has been used to connect to
                 internet. In another case it is better to get output of
                 "nslookup pubsub.pubnub.com" status object debug description and mail to
                 support@pubnub.com
    */
    PNTLSUntrustedCertificateCategory
};

/**
 @brief  Definition for set of data which can be pulled out using presence API.

 @since 4.0
 */
typedef NS_ENUM(NSInteger, PNHereNowVerbosityLevel) {

    /**
     @brief  Request presence service return only number of participants at specified remote data
             objects live feeds.

     @since 4.0
     */
    PNHereNowOccupancy,

    /**
     @brief  Request presence service return participants identifier names at specified remote data
             objects live feeds.

     @since 4.0
     */
    PNHereNowUUID,

    /**
     @brief  Request presence service return participants identifier names along with state
             information at specified remote data objects live feeds.

     @since 4.0
     */
    PNHereNowState
};

/**
 @brief  Base block structure used by client for all API endpoints to handle request processing
         completion.

 @param result Provide \b PubNub service response information.
 @param status Provide information about request to \b PubNub service failed or received error.

 @since 4.0
 */
typedef void(^PNCompletionBlock)(PNResult *result, PNStatus *status);


/**
 @brief      Block type which is used as completion block for som API endpoint where only server
             response can be delivered.
 @discussion Used by API which as \b PubNub service to generate usable data (not request processing
             status).

 @param result Reference on results generated from passed request.

 @since 4.0
 */
typedef void(^PNResultBlock)(PNResult *result);

/**
 @brief  Block type which is used as completion block for som API endpoint where only request
         processing status can be delivered in response.

 @param status Reference on status which represent service request processing state.

 @since 4.0
 */
typedef void(^PNStatusBlock)(PNStatus *status);

#endif // PNStructures_h
