/**
 * @brief Set of types and structures which is used as part of API calls in \b PubNub client.
 *
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <Foundation/Foundation.h>
#import "PNDefines.h"


#pragma mark Class forward

@class PNPresenceChannelGroupHereNowResult, PNChannelGroupClientStateResult;
@class PNPresenceChannelHereNowResult, PNPresenceGlobalHereNowResult, PNAPNSEnabledChannelsResult;
@class PNChannelGroupChannelsResult, PNPresenceWhereNowResult, PNChannelClientStateResult;
@class PNClientStateGetResult, PNClientStateUpdateStatus, PNAcknowledgmentStatus;
@class PNChannelGroupsResult, PNMessageCountResult, PNHistoryResult, PNAPICallBuilder;
@class PNPublishStatus, PNSignalStatus, PNErrorStatus, PNTimeResult, PNResult, PNStatus;
@class PNCreateUserStatus, PNUpdateUserStatus, PNFetchUserResult, PNFetchUsersResult;
@class PNCreateSpaceStatus, PNUpdateSpaceStatus, PNFetchSpaceResult, PNFetchSpacesResult;
@class PNManageMembershipsStatus, PNFetchMembershipsResult, PNManageMembersStatus, PNFetchMembersResult;
@class PNAddMessageActionStatus, PNFetchMessageActionsResult;

#ifndef PNStructures_h
#define PNStructures_h


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Completion blocks

#pragma mark - Completion blocks :: General

/**
 * @brief Base block structure used by client for all API endpoints to handle request processing
 * completion.
 *
 * @param result \b PubNub service response information.
 * @param status Information about request to \b PubNub service failed or received error.
 */
typedef void(^PNCompletionBlock)(PNResult * _Nullable result, PNStatus * _Nullable status);


/**
 * @brief Completion block for some API endpoint where only server response can be delivered.
 *
 * @discussion Used by API which as \b PubNub service to generate usable data (not request
 * processing status).
 *
 * @param result Results generated from passed request.
 */
typedef void(^PNResultBlock)(PNResult *result);

/**
 * @brief Completion block for som API endpoint where only request processing status can be
 * delivered in response.
 *
 * @param status Status which represent service request processing state.
 */
typedef void(^PNStatusBlock)(PNStatus *status);


#pragma mark - Completion blocks :: APNS

/**
 * @brief Push notifications state modification completion block.
 *
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNPushNotificationsStateModificationCompletionBlock)(PNAcknowledgmentStatus *status);

/**
 * @brief Push notifications state audit completion block.
 *
 * @param result Result object which describe service response on audition request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNPushNotificationsStateAuditCompletionBlock)(PNAPNSEnabledChannelsResult * _Nullable result,
                                                            PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Stream

/**
 * @brief Channel groups list audition completion block.
 *
 * @param result Result object which describe service response on audition request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNGroupAuditCompletionBlock)(PNChannelGroupsResult * _Nullable result, 
                                           PNErrorStatus * _Nullable status);

/**
 * @brief Channel group channels list audition completion block.
 *
 * @param result Result object which describe service response on audition request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNGroupChannelsAuditCompletionBlock)(PNChannelGroupChannelsResult * _Nullable result,
                                                   PNErrorStatus * _Nullable status);

/**
 * @brief Channel group content modification completion block.
 *
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNChannelGroupChangeCompletionBlock)(PNAcknowledgmentStatus *status);


#pragma mark - Completion blocks :: History

/**
 * @brief Channel history fetch completion block.
 *
 * @param result Result object which describe service response on history request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNHistoryCompletionBlock)(PNHistoryResult * _Nullable result,
                                        PNErrorStatus * _Nullable status);

/**
 * @brief Messages removal completion block.
 *
 * @param status Status instance which hold information about processing results.
 *
 * @since 4.7.0
 */
typedef void(^PNMessageDeleteCompletionBlock)(PNAcknowledgmentStatus *status);

/**
 * @brief Messages count fetch completion block.
 *
 * @param result Result object which describe service response on messages count request.
 * @param status Status instance which hold information about processing results.
 *
 * @since 4.8.4
 */
typedef void(^PNMessageCountCompletionBlock)(PNMessageCountResult * _Nullable result,
                                             PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Objects

/**
 * @brief \c Create \c user completion handler block.
 *
 * @param status Object with information about \c create \c user request results and service
 * response.
 *
 * @since 4.10.0
 */
typedef void(^PNCreateUserCompletionBlock)(PNCreateUserStatus *status);

/**
 * @brief \c Update \c user completion handler block.
 *
 * @param status Object with information about \c update \c user request results and service
 * response.
 *
 * @since 4.10.0
 */
typedef void(^PNUpdateUserCompletionBlock)(PNUpdateUserStatus *status);

/**
 * @brief \c Delete \c user completion handler block.
 *
 * @param status Object with information about \c delete \c user request results.
 *
 * @since 4.10.0
 */
typedef void(^PNDeleteUserCompletionBlock)(PNAcknowledgmentStatus *status);

/**
 * @brief \c Fetch \c user completion handler block.
 *
 * @param result Object with information about \c fetch \c user request results.
 * @param status Object with information about \c fetch \c user request error.
 *
 * @since 4.10.0
 */
typedef void(^PNFetchUserCompletionBlock)(PNFetchUserResult * _Nullable result,
                                          PNErrorStatus * _Nullable status);

/**
 * @brief \c Fetch \c all \c users completion handler block.
 *
 * @param result Object with information about \c fetch \c all \c users request results.
 * @param status Object with information about \c fetch \c all \c users request error.
 *
 * @since 4.10.0
 */
typedef void(^PNFetchUsersCompletionBlock)(PNFetchUsersResult * _Nullable result,
                                           PNErrorStatus * _Nullable status);

/**
 * @brief \c Create \c space completion handler block.
 *
 * @param status Object with information about \c create \c space request results and service
 * response.
 *
 * @since 4.10.0
 */
typedef void(^PNCreateSpaceCompletionBlock)(PNCreateSpaceStatus *status);

/**
 * @brief \c Update \c space completion handler block.
 *
 * @param status Object with information about \c update \c space request results and service
 * response.
 *
 * @since 4.10.0
 */
typedef void(^PNUpdateSpaceCompletionBlock)(PNUpdateSpaceStatus *status);

/**
 * @brief \c Delete \c space completion handler block.
 *
 * @param status Object with information about \c delete \c space request results.
 *
 * @since 4.10.0
 */
typedef void(^PNDeleteSpaceCompletionBlock)(PNAcknowledgmentStatus *status);

/**
 * @brief \c Fetch \c space completion handler block.
 *
 * @param result Object with information about \c fetch \c space request results.
 * @param status Object with information about \c fetch \c user request error.
 *
 * @since 4.10.0
 */
typedef void(^PNFetchSpaceCompletionBlock)(PNFetchSpaceResult * _Nullable result,
                                           PNErrorStatus * _Nullable status);

/**
 * @brief \c Fetch \c all \c spaces completion handler block.
 *
 * @param result Object with information about \c fetch \c all \c spaces request results.
 * @param status Object with information about \c fetch \c all \c spaces request error.
 *
 * @since 4.10.0
 */
typedef void(^PNFetchSpacesCompletionBlock)(PNFetchSpacesResult * _Nullable result,
                                            PNErrorStatus * _Nullable status);

/**
 * @brief \c Manage \c memberships completion handler block.
 *
 * @param status Object with information about \c manage \c memberships request results and service
 * response.
 *
 * @since 4.10.0
 */
typedef void(^PNManageMembershipsCompletionBlock)(PNManageMembershipsStatus *status);

/**
 * @brief \c Fetch \c memberships completion handler block.
 *
 * @param result Object with information about \c fetch \c memberships request results.
 * @param status Object with information about \c fetch \c memberships request error.
 *
 * @since 4.10.0
 */
typedef void(^PNFetchMembershipsCompletionBlock)(PNFetchMembershipsResult * _Nullable result,
                                                 PNErrorStatus * _Nullable status);

/**
 * @brief \c Manage \c members completion handler block.
 *
 * @param status Object with information about \c manage \c members request results and service
 * response.
 *
 * @since 4.10.0
 */
typedef void(^PNManageMembersCompletionBlock)(PNManageMembersStatus *status);

/**
 * @brief \c Fetch \c members completion handler block.
 *
 * @param result Object with information about \c fetch \c members request results.
 * @param status Object with information about \c fetch \c members request error.
 *
 * @since 4.10.0
 */
typedef void(^PNFetchMembersCompletionBlock)(PNFetchMembersResult * _Nullable result,
                                             PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Presence

/**
 * @brief Here now completion block.
 *
 * @param result Result object which describe service response on here now request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNHereNowCompletionBlock)(PNPresenceChannelHereNowResult * _Nullable result,
                                        PNErrorStatus * _Nullable status);

/**
 * @brief Global here now completion block.
 *
 * @param result Result object which describe service response on here now request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNGlobalHereNowCompletionBlock)(PNPresenceGlobalHereNowResult * _Nullable result,
                                              PNErrorStatus * _Nullable status);

/**
 * @brief Channel group here now completion block.
 *
 * @param result Result object which describe service response on here now request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNChannelGroupHereNowCompletionBlock)(PNPresenceChannelGroupHereNowResult * _Nullable result,
                                                    PNErrorStatus * _Nullable status);

/**
 * @brief UUID where now completion block.
 *
 * @param result Result object which describe service response on where now request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNWhereNowCompletionBlock)(PNPresenceWhereNowResult * _Nullable result, 
                                         PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Messaging

/**
 * @brief Signal sending completion block.
 *
 * @param status Status instance which hold information about processing results.
 *
 * @since 4.9.0
 */
typedef void(^PNSignalCompletionBlock)(PNSignalStatus *status);

/**
 * @brief Message publish completion block.
 *
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNPublishCompletionBlock)(PNPublishStatus *status);

/**
 * @brief Message size calculation completion block.
 *
 * @param size Calculated size of the packet which will be used to send message.
 */
typedef void(^PNMessageSizeCalculationCompletionBlock)(NSInteger size);


#pragma mark - Completion blocks :: State

/**
 * @brief State modification completion block.
 *
 * @param status Status instance which hold information about processing results.
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
 * @brief Channel state audition completion block.
 *
 * @param result Result object which describe service response on channel state audit request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNChannelStateCompletionBlock)(PNChannelClientStateResult * _Nullable result,
                                             PNErrorStatus * _Nullable status);

/**
 * @brief Channel group state audition completion block.
 *
 * @param result Result object which describe service response on channel group state audit request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNChannelGroupStateCompletionBlock)(PNChannelGroupClientStateResult * _Nullable result,
                                                  PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Message action

/**
 * @brief \c Add \c message \c action completion handler block.
 *
 * @param status Object with information about \c add \c message \c action request results and
 * service response.
 *
 * @since 4.11.0
 */
typedef void(^PNAddMessageActionCompletionBlock)(PNAddMessageActionStatus *status);

/**
 * @brief \c Remove \c message \c action completion handler block.
 *
 * @param status Object with information about \c remove \c message \c action request results.
 *
 * @since 4.11.0
 */
typedef void(^PNRemoveMessageActionCompletionBlock)(PNAcknowledgmentStatus *status);

/**
 * @brief \c Fetch \c messages \c actions completion handler block.
 *
 * @param result Object with information about \c fetch \c messages \c actions request results.
 * @param status Object with information about \c fetch \c messages \c actions request error.
 *
 * @since 4.11.0
 */
typedef void(^PNFetchMessageActionsCompletionBlock)(PNFetchMessageActionsResult * _Nullable result,
                                             PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Time

/**
 * @brief Time request completion block.
 *
 * @param result Result object which describe service response on time request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNTimeCompletionBlock)(PNTimeResult * _Nullable result,
                                     PNErrorStatus * _Nullable status);

NS_ASSUME_NONNULL_END


/**
 * @brief Options with possible additional \c space / \c membership fields which can be included to
 * response.
 *
 * @since 4.10.0
 */
typedef NS_OPTIONS(NSUInteger, PNMembershipFields) {
    /**
     * @brief Field with additional information which has been associated with \c user during
     * \c membership \c create / \c update requests.
     */
    PNMembershipCustomField = 1 << 2,
    /**
     * @brief Include \c space's information into response (not only \c spaceId).
     */
    PNMembershipSpaceField = 1 << 3,
    /**
     * @brief Include \c space's additional information which has been used during \c space
     * \c create / \c update requests.
     */
    PNMembershipSpaceCustomField = 1 << 4
};

/**
 * @brief Options with possible additional \c user / \c member fields which can be included to
 * response.
 *
 * @since 4.10.0
 */
typedef NS_OPTIONS(NSUInteger, PNMemberFields) {
    /**
     * @brief Field with additional information which has been associated with \c user during
     * \a add / \c update of \c space's users list requests.
     */
    PNMemberCustomField = 1 << 5,
    /**
     * @brief Include \c user's information into response (not only \c userId).
     */
    PNMemberUserField = 1 << 6,
    /**
     * @brief Include \c user's additional information which has been used during \c user
     * \c create / \c update requests.
     */
    PNMemberUserCustomField = 1 << 7
};

/**
 * @brief Options with possible additional \c space fields which can be included to response.
 *
 * @since 4.10.0
 */
typedef NS_OPTIONS(NSUInteger, PNSpaceFields) {
    /**
     * @brief Field with additional information which has been used during \c space
     * \c create / \c update requests.
     */
    PNSpaceCustomField = 1 << 1
};

/**
 * @brief Options with possible additional \c user fields which can be included to response.
 *
 * @since 4.10.0
 */
typedef NS_OPTIONS(NSUInteger, PNUserFields) {
    /**
     * @brief Field with additional information which has been used during \c user
     * \c create / \c update requests.
     */
    PNUserCustomField = 1
};

/**
 * @brief Options describe possible heartbeat states on which delegate can be notified.
 *
 * @since 4.2.7
 */
typedef NS_OPTIONS(NSUInteger, PNHeartbeatNotificationOptions) {
    
    /**
     * @brief Delegate will be notified every time when heartbeat request will be successfully
     * processed.
     */
    PNHeartbeatNotifySuccess = (1 << 0),
    
    /**
     * @brief Delegate will be notified every time when heartbeat request processing will fail.
     */
    PNHeartbeatNotifyFailure = (1 << 1),
    
    /**
     * @brief Delegate will be notified every time when heartbeat request processing will be
     * successful or fail.
     */
    PNHeartbeatNotifyAll = (PNHeartbeatNotifySuccess | PNHeartbeatNotifyFailure),
    
    /**
     * @brief Delegate won't be notified about ant heartbeat request processing results.
     */
    PNHeartbeatNotifyNone = (1 << 2)
};

/**
 * @brief Enum which specify possible actions on objects.
 *
 * @discussion These fields allow to identify what kind of action has been performed on target
 * object.
 *
 * @since 4.10.0
 */
typedef NS_ENUM(NSUInteger, PNObjectActionType) {
    /**
     * @brief New object entity has been created.
     */
    PNCreateObjectAction,
    
    /**
     * @brief Object base or additional (custom field / membership) information has been modified.
     */
    PNUpdateObjectAction,
    
    /**
     * @brief Object entity has been deleted.
     */
    PNDeleteObjectAction,
};

/**
 * @brief \b PubNub client logging levels available for manipulations.
 */
typedef NS_OPTIONS(NSUInteger, PNLogLevel){
    
    /**
     * @brief \b PNLog level which allow to disable all active logging levels.
     *
     * @discussion This log level can be set with \b PNLLogger instance method \c -setLogLevel:
     */
    PNSilentLogLevel = 0,
    
    /**
     * @brief \b PNLog level which allow to print out client information data.
     *
     * @discussion Log events like: transition between foreground / background, configuration
     * modification
     */
    PNInfoLogLevel = (1 << 1),
    
    /**
     * @brief \b PNLog level which allow to print out all reachability events.
     */
    PNReachabilityLogLevel = (1 << 2),
    
    /**
     * @brief \b PNLog level which allow to print out all API call request URI which has been passed
     * to communicate with \b PubNub service.
     */
    PNRequestLogLevel = (1 << 3),
    
#if PN_URLSESSION_TRANSACTION_METRICS_AVAILABLE
    /**
     * @brief \b PNLog level which allow to print out all API call requests' metrics.
     *
     * @discussion Starting from macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0) it is possible
     * to gather metrics information about each request processed.
     *
     * @since 4.5.13
     */
    PNRequestMetricsLogLevel = (1 << 4),
#endif
    
    /**
     * @brief \b PNLog level which allow to print out API execution results.
     */
    PNResultLogLevel = (1 << 5),
    
    /**
     * @brief \b PNLog level which allow to print out client state change status information and
     * API request processing errors.
     */
    PNStatusLogLevel = (1 << 6),
    
    /**
     * @brief \b PNLog level which allow to print out every failure status information.
     *
     * @discussion Every API call may fail and this option allow to print out information about
     * processing status and current client state.
     */
    PNFailureStatusLogLevel = (1 << 7),
    
    /**
     * @brief \b PNLog level which allow to print out all API calls with passed parameters.
     *
     * @discussion This log level allow with debug to find out when API has been called and what
     * parameters should be passed.
     */
    PNAPICallLogLevel = (1 << 8),
    
    /**
     * @brief \b PNLog level which allow to print out all AES errors.
     */
    PNAESErrorLogLevel = (1 << 9),
    
    /**
     * @brief Log every message from \b PubNub client.
     */
    PNVerboseLogLevel = (PNInfoLogLevel|PNReachabilityLogLevel|PNRequestLogLevel|
#if PN_URLSESSION_TRANSACTION_METRICS_AVAILABLE
                         PNRequestMetricsLogLevel|
#endif
                         PNResultLogLevel|PNStatusLogLevel|PNFailureStatusLogLevel|PNAPICallLogLevel|
                         PNAESErrorLogLevel)
};

/**
 * @brief Type which specify possible operations for \b PNResult/ \b PNStatus event objects.
 *
 * @discussion This fields allow to identify for what kind of API this object arrived.
 */
typedef NS_ENUM(NSInteger, PNOperationType){
    PNSubscribeOperation,
    PNUnsubscribeOperation,
    PNPublishOperation,
    PNSignalOperation,
    PNAddMessageActionOperation,
    PNRemoveMessageActionOperation,
    PNFetchMessagesActionsOperation,
    PNHistoryOperation,
    PNHistoryForChannelsOperation,
    PNHistoryWithActionsOperation,
    PNDeleteMessageOperation,
    PNMessageCountOperation,
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
    PNCreateUserOperation,
    PNUpdateUserOperation,
    PNDeleteUserOperation,
    PNFetchUserOperation,
    PNFetchUsersOperation,
    PNCreateSpaceOperation,
    PNUpdateSpaceOperation,
    PNDeleteSpaceOperation,
    PNFetchSpaceOperation,
    PNFetchSpacesOperation,
    PNManageMembershipsOperation,
    PNFetchMembershipsOperation,
    PNManageMembersOperation,
    PNFetchMembersOperation,
    PNTimeOperation
};

/**
 * @brief Describe set of \b status categories which will be used to deliver any client state change
 * using handlers.
 */
typedef NS_ENUM(NSInteger, PNStatusCategory) {
    PNUnknownCategory,
    
    /**
     * @brief \b PubNub request acknowledgment status.
     *
     * @discussion Some API endpoints respond with request processing status w/o useful data.
     */
    PNAcknowledgmentCategory,

    /**
     * @brief \b PubNub Access Manager forbidden access to particular API.
     *
     * @discussion It is possible what at the moment when API has been used access rights hasn't
     * been applied to the client.
     */
    PNAccessDeniedCategory,

    /**
     * @brief API processing failed because of request time out.
     *
     * @discussion This type of status is possible in case of very slow connection when request
     * doesn't have enough time to complete processing (send request body and receive server
     * response).
     */
    PNTimeoutCategory,

    /**
     * @brief API request is impossible because there is no connection.
     *
     * @discussion At the moment when API has been used there was no active connection to the
     * Internet.
     */
    PNNetworkIssuesCategory,

    /**
     * @brief Subscribe returned more than specified number of messages / events.
     *
     * @discussion At the moment when client recover after network issues there is a chance what a
     * lot of messages queued to return in subscribe response. If number of received objects will be
     * larger than specified threshold this status will be sent (maybe history request required).
     *
     * @since 4.5.4
     */
    PNRequestMessageCountExceededCategory,

    /**
     * @brief Status sent when client successfully subscribed to remote data objects live feed.
     *
     * @discussion Connected mean what client will receive live updates from \b PubNub service at
     * specified set of data objects.
     */
    PNConnectedCategory,

    /**
     * @brief Status sent when client successfully restored subscription to remote data objects live
     * feed after unexpected disconnection.
     */
    PNReconnectedCategory,

    /**
     * @brief Status sent when client successfully unsubscribed from one of remote data objects live
     * feeds.
     *
     * @discussion Disconnected mean what client won't receive live updates from \b PubNub service
     * from set of channels used in unsubscribe API.
     */
    PNDisconnectedCategory,

    /**
     * @brief Status sent when client unexpectedly lost ability to receive live updates from
     * \b PubNub service.
     *
     * @discussion This state is sent in case of issues which doesn't allow it anymore receive live
     * updates from \b PubNub service. After issue resolve connection can be restored.
     * In case if issue appeared because of network connection client will restore connection only
     * if configured to restore subscription.
     */
    PNUnexpectedDisconnectCategory,

    /**
     * @brief Status which is used to notify about API call cancellation.
     *
     * @discussion Mostly cancellation possible only for connection based operations
     * (subscribe/leave).
     */
    PNCancelledCategory,
    
    /**
     * @brief Status is used to notify what API request from client is malformed.
     *
     * @discussion In case if this status arrive, it is better to print out status object debug
     * description and contact support@pubnub.com.
     */
    PNBadRequestCategory,
    
    /**
     * @brief Status is used to notify what composed API request has too many data in it.
     *
     * @discussion In case if this status arrive, depending from used API it mean what too many data
     * has been passed to it. For example for publish it may mean what too big message has been
     * sent. For subscription/unsubscription API it may mean what too many channels has been passed
     * to API.
     *
     * @since 4.6.2
     */
    PNRequestURITooLongCategory,

    /**
     * @brief Status is used to notify what client has been configured with malformed filtering
     * expression.
     *
     * @discussion In case if this status arrive, check syntax used for \c -setFilterExpression:
     * method.
     */
    PNMalformedFilterExpressionCategory,

    /**
     * @brief \b PubNub because of some issues sent malformed response.
     *
     * @discussion In case if this status arrive, it is better to print out status object debug
     * description and contact support@pubnub.com.
     */
    PNMalformedResponseCategory,

    /**
     * @brief Looks like \b PubNub client can't use provided \c cipherKey to decrypt received
     * message.
     *
     * @discussion In case if this status arrive, make sure what all clients use same \c cipherKey
     * to encrypt published messages.
     */
    PNDecryptionErrorCategory,

    /**
     * @brief Status is sent in case if client was unable to use API using secured connection.
     *
     * @discussion In case if this issue happens, client can be re-configured to use insecure
     * connection. If insecure connection is impossible then it is better to print out status object
     * debug description and contact support@pubnub.com.
     */
    PNTLSConnectionFailedCategory,

    /**
     * @brief Status is sent in case if client unable to check certificates trust chain.
     *
     * @discussion If this state arrive it is possible what proxy or VPN has been used to connect to
     * internet. In another case it is better to get output of "nslookup pubsub.pubnub.com" status
     * object debug description and mail to support@pubnub.com.
    */
    PNTLSUntrustedCertificateCategory
};

/**
 * @brief Definition for set of data which can be pulled out using presence API.
 */
typedef NS_ENUM(NSInteger, PNHereNowVerbosityLevel) {

    /**
     * @brief Request presence service return only number of participants at specified remote data
     * objects live feeds.
     */
    PNHereNowOccupancy,

    /**
     * @brief Request presence service return participants identifier names at specified remote data
     * objects live feeds.
     */
    PNHereNowUUID,

    /**
     * @brief Request presence service return participants identifier names along with state
     * information at specified remote data objects live feeds.
     */
    PNHereNowState
};

#endif // PNStructures_h
