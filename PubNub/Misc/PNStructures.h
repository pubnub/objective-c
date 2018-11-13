/**
 @brief Set of types and structures which is used as part of API calls in \b PubNub client.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import <Foundation/Foundation.h>
#import "PNDefines.h"


#pragma mark Class forward

@class PNPresenceChannelGroupHereNowResult, PNChannelGroupClientStateResult;
@class PNPresenceChannelHereNowResult, PNPresenceGlobalHereNowResult, PNAPNSEnabledChannelsResult;
@class PNChannelGroupChannelsResult, PNPresenceWhereNowResult, PNChannelClientStateResult;
@class PNClientStateGetResult, PNClientStateUpdateStatus, PNAcknowledgmentStatus;
@class PNChannelGroupsResult, PNHistoryResult, PNAPICallBuilder, PNPublishStatus, PNErrorStatus;
@class PNTimeResult, PNResult, PNStatus;

#ifndef PNStructures_h
#define PNStructures_h


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Completion blocks

#pragma mark - Completion blocks :: General

/**
 @brief  Base block structure used by client for all API endpoints to handle request processing
         completion.

 @param result Provide \b PubNub service response information.
 @param status Provide information about request to \b PubNub service failed or received error.

 @since 4.0
 */
typedef void(^PNCompletionBlock)(PNResult * _Nullable result, PNStatus * _Nullable status);


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


#pragma mark - Completion blocks :: APNS

/**
 @brief  Push notifications state modification completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNPushNotificationsStateModificationCompletionBlock)(PNAcknowledgmentStatus *status);

/**
 @brief  Push notifications state audit completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNPushNotificationsStateAuditCompletionBlock)(PNAPNSEnabledChannelsResult * _Nullable result,
                                                            PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Stream

/**
 @brief  Channel groups list audition completion block.
 
 @param result Reference on result object which describe service response on audition request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNGroupAuditCompletionBlock)(PNChannelGroupsResult * _Nullable result, 
                                           PNErrorStatus * _Nullable status);

/**
 @brief  Channel group channels list audition completion block.
 
 @param result Reference on result object which describe service response on audition request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNGroupChannelsAuditCompletionBlock)(PNChannelGroupChannelsResult * _Nullable result,
                                                   PNErrorStatus * _Nullable status);

/**
 @brief  Channel group content modification completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNChannelGroupChangeCompletionBlock)(PNAcknowledgmentStatus *status);


#pragma mark - Completion blocks :: History

/**
 @brief  Channel history fetch completion block.
 
 @param result Reference on result object which describe service response on history request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNHistoryCompletionBlock)(PNHistoryResult * _Nullable result, PNErrorStatus * _Nullable status);

/**
 @brief  Messages removal completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.7.0
 */
typedef void(^PNMessageDeleteCompletionBlock)(PNAcknowledgmentStatus *status);


#pragma mark - Completion blocks :: Presence

/**
 @brief  Here now completion block.
 
 @param result Reference on result object which describe service response on here now request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNHereNowCompletionBlock)(PNPresenceChannelHereNowResult * _Nullable result,
                                        PNErrorStatus * _Nullable status);

/**
 @brief  Global here now completion block.
 
 @param result Reference on result object which describe service response on here now request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNGlobalHereNowCompletionBlock)(PNPresenceGlobalHereNowResult * _Nullable result,
                                              PNErrorStatus * _Nullable status);

/**
 @brief  Channel group here now completion block.
 
 @param result Reference on result object which describe service response on here now request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNChannelGroupHereNowCompletionBlock)(PNPresenceChannelGroupHereNowResult * _Nullable result,
                                                    PNErrorStatus * _Nullable status);

/**
 @brief  UUID where now completion block.
 
 @param result Reference on result object which describe service response on where now request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNWhereNowCompletionBlock)(PNPresenceWhereNowResult * _Nullable result, 
                                         PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Messaging

/**
 @brief  Message publish completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNPublishCompletionBlock)(PNPublishStatus *status);

/**
 @brief  Message size calculation completion block.
 
 @param size Calculated size of the packet which will be used to send message.
 
 @since 4.0
 */
typedef void(^PNMessageSizeCalculationCompletionBlock)(NSInteger size);


#pragma mark - Completion blocks :: State

/**
 @brief State modification completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNSetStateCompletionBlock)(PNClientStateUpdateStatus *status);

/**
 * @brief Channels / channel groups channels state audition completion block.
 *
 * @param result Result object state audit request results.
 * @param status Status instance which hold information about processing error.
 *
 * @since 4.8.3
 */
typedef void(^PNGetStateCompletionBlock)(PNClientStateGetResult * _Nullable result,
                                         PNErrorStatus * _Nullable status);

/**
 @brief  Channel state audition completion block.
 
 @param result Reference on result object which describe service response on channel state audit request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNChannelStateCompletionBlock)(PNChannelClientStateResult * _Nullable result,
                                             PNErrorStatus * _Nullable status);

/**
 @brief  Channel group state audition completion block.
 
 @param result Reference on result object which describe service response on channel group state audit request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNChannelGroupStateCompletionBlock)(PNChannelGroupClientStateResult * _Nullable result,
                                                  PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Time

/**
 @brief  Time request completion block.
 
 @param result Reference on result object which describe service response on time request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNTimeCompletionBlock)(PNTimeResult * _Nullable result, PNErrorStatus * _Nullable status);

NS_ASSUME_NONNULL_END


/**
 @brief  Options describe possible heartbeat states on which delegate can be notified.
 
 @since 4.2.7
 */
typedef NS_OPTIONS(NSUInteger, PNHeartbeatNotificationOptions) {
    
    /**
     @brief  Delegate will be notified every time when heartbeat request will be successfully processed.
     */
    PNHeartbeatNotifySuccess = (1 << 0),
    
    /**
     @brief  Delegate will be notified every time when heartbeat request processing will fail.
     */
    PNHeartbeatNotifyFailure = (1 << 1),
    
    /**
     @brief  Delegate will be notified every time when heartbeat request processing will be successful or
             fail.
     */
    PNHeartbeatNotifyAll = (PNHeartbeatNotifySuccess | PNHeartbeatNotifyFailure),
    
    /**
     @brief  Delegate won't be notified about ant heartbeat request processing results.
     */
    PNHeartbeatNotifyNone = (1 << 2)
};


/**
 @brief  \b PubNub client logging levels available for manipulations.
 
 @since 4.0
 */
typedef NS_OPTIONS(NSUInteger, PNLogLevel){
    
    /**
     @brief      \b PNLog level which allow to disable all active logging levels.
     @discussion This log level can be set with \b PNLLogger instance method \c -setLogLevel:
     
     @since 4.0
     */
    PNSilentLogLevel = 0,
    
    /**
     @brief      \b PNLog level which allow to print out client information data.
     @discussion Log events like: transition between foreground/background, configuration 
                 modification
     
     @since 4.0
     */
    PNInfoLogLevel = (1 << 1),
    
    /**
     @brief  \b PNLog level which allow to print out all reachability events.
     
     @since 4.0
     */
    PNReachabilityLogLevel = (1 << 2),
    
    /**
     @brief  \b PNLog level which allow to print out all API call request URI which has been passed
             to communicate with \b PubNub service.
     
     @since 4.0
     */
    PNRequestLogLevel = (1 << 3),
    
#if PN_URLSESSION_TRANSACTION_METRICS_AVAILABLE
    /**
     @brief      \b PNLog level which allow to print out all API call requests' metrics.
     @discussion Starting from macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0) it is possible to gather 
                 metrics information about each request processed.
     
     @since 4.5.13
     */
    PNRequestMetricsLogLevel = (1 << 4),
#endif
    
    /**
     @brief  \b PNLog level which allow to print out API execution results.
     
     @since 4.0
     */
    PNResultLogLevel = (1 << 5),
    
    /**
     @brief  \b PNLog level which allow to print out client state change status information and 
             API request processing errors.
     
     @since 4.0
     */
    PNStatusLogLevel = (1 << 6),
    
    /**
     @brief      \b PNLog level which allow to print out every failure status information.
     @discussion Every API call may fail and this option allow to print out information about 
                 processing status and current client state.
     
     @since 4.0
     */
    PNFailureStatusLogLevel = (1 << 7),
    
    /**
     @brief      \b PNLog level which allow to print out all API calls with passed parameters.
     @discussion This log level allo with debug to find out when API has been called and what
                 parameters should be passed.
     
     @since 4.0
     */
    PNAPICallLogLevel = (1 << 8),
    
    /**
     @brief  \b PNLog level which allow to print out all AES errors.
     
     @since 4.0
     */
    PNAESErrorLogLevel = (1 << 9),
    
    /**
     @brief  Log every message from \b PubNub client.
     
     @since 4.0
     */
    PNVerboseLogLevel = (PNInfoLogLevel|PNReachabilityLogLevel|PNRequestLogLevel|
#if PN_URLSESSION_TRANSACTION_METRICS_AVAILABLE
                         PNRequestMetricsLogLevel|
#endif
                         PNResultLogLevel|PNStatusLogLevel|PNFailureStatusLogLevel|PNAPICallLogLevel|
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
    PNHistoryForChannelsOperation,
    PNDeleteMessageOperation,
    PNWhereNowOperation,
    PNHereNowGlobalOperation,
    PNHereNowForChannelOperation,
    PNHereNowForChannelGroupOperation,
    PNHeartbeatOperation,
    PNSetStateOperation,
    PNGetStateOperation,
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
     @brief      Subscribe returned more than specified number of messages / events.
     @discussion At the moment when client recover after network issues there is a chance what a lot of 
                 messages queued to return in subscribe response. If number of received objects will be larger
                 than specified threshold this status will be sent (maybe history request required).

     @since 4.5.4
     */
    PNRequestMessageCountExceededCategory,

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
     @brief      Status is used to notify what composed API request has too many data in it.
     @discussion In case if this status arrive, depending from used API it mean what too many data has been 
                 passed to it. For example for publish it may mean what too big message has been sent. For
                 subscription/unsubscription API it may mean what too many channels has been passed to API.
     
     @since 4.6.2
     */
    PNRequestURITooLongCategory,

    /**
     @brief      Status is used to notify what client has been configured with malformed filtering expression.
     @discussion In case if this status arrive, check syntax used for \c -setFilterExpression: method.

     @since 4.0
     */
    PNMalformedFilterExpressionCategory,

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

#endif // PNStructures_h
