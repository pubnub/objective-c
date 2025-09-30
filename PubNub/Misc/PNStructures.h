/**
 * @brief Set of types and structures which is used as part of API calls in \b PubNub client.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <Foundation/Foundation.h>
#import <PubNub/PNDefines.h>


#pragma mark Class forward


@class PNChannelGroupChannelsData, PNPresenceHereNowResult, PNPresenceStateFetchResult;

@class PNPresenceChannelGroupHereNowResult, PNChannelGroupClientStateResult;
@class PNPresenceChannelHereNowResult, PNPresenceGlobalHereNowResult, PNAPNSEnabledChannelsResult;
@class PNChannelGroupChannelsResult, PNPresenceWhereNowResult, PNChannelClientStateResult;
@class PNClientStateGetResult, PNClientStateUpdateStatus, PNAcknowledgmentStatus;
@class PNMessageCountResult, PNHistoryResult, PNAPICallBuilder;
@class PNPublishStatus, PNSignalStatus, PNErrorStatus, PNStatus, PNTimeResult, PNOperationResult;
@class PNSetUUIDMetadataStatus, PNFetchUUIDMetadataResult, PNFetchAllUUIDMetadataResult;
@class PNSetChannelMetadataStatus, PNFetchChannelMetadataResult, PNFetchAllChannelsMetadataResult;
@class PNManageMembershipsStatus, PNFetchMembershipsResult, PNManageChannelMembersStatus, PNFetchChannelMembersResult;
@class PNAddMessageActionStatus, PNFetchMessageActionsResult;
@class PNDownloadFileResult, PNSendFileStatus, PNListFilesResult;

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
typedef void(^PNCompletionBlock)(PNOperationResult * _Nullable result, PNStatus * _Nullable status);


/**
 * @brief Completion block for some API endpoint where only server response can be delivered.
 *
 * @discussion Used by API which as \b PubNub service to generate usable data (not request
 * processing status).
 *
 * @param result Results generated from passed request.
 */
typedef void(^PNResultBlock)(PNOperationResult *result);

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
 * @brief \c Set \c UUID \c metadata completion handler block.
 *
 * @param status Object with information about \c UUID \c metadata \c set request results and service
 * response.
 *
 * @since 4.14.0
 */
typedef void(^PNSetUUIDMetadataCompletionBlock)(PNSetUUIDMetadataStatus *status);

/**
 * @brief \c Remove \c UUID \c metadata completion handler block.
 *
 * @param status Object with information about \c UUID \c metadata \c delete request results.
 *
 * @since 4.14.0
 */
typedef void(^PNRemoveUUIDMetadataCompletionBlock)(PNAcknowledgmentStatus *status);

/**
 * @brief \c Fetch \c UUID \c metadata completion handler block.
 *
 * @param result Object with information about \c UUID \c metadata \c fetch request results.
 * @param status Object with information about \c UUID \c metadata \c fetch request error.
 *
 * @since 4.14.0
 */
typedef void(^PNFetchUUIDMetadataCompletionBlock)(PNFetchUUIDMetadataResult * _Nullable result,
                                                  PNErrorStatus * _Nullable status);

/**
 * @brief \c Fetch \c all \c UUIDs \c metadata completion handler block.
 *
 * @param result Object with information about \c fetch \c all \c UUIDs \c metadata request results.
 * @param status Object with information about \c fetch \c all \c UUIDs \c metadata request error.
 *
 * @since 4.14.0
 */
typedef void(^PNFetchAllUUIDMetadataCompletionBlock)(PNFetchAllUUIDMetadataResult * _Nullable result,
                                                     PNErrorStatus * _Nullable status);

/**
 * @brief \c Set \c channel \c metadata completion handler block.
 *
 * @param status Object with information about \c channel \c metadata \c set request results and service
 * response.
 *
 * @since 4.14.0
 */
typedef void(^PNSetChannelMetadataCompletionBlock)(PNSetChannelMetadataStatus *status);

/**
 * @brief \c Remove \c channel \c metadata completion handler block.
 *
 * @param status Object with information about \c channel \c metadata \c delete request results.
 *
 * @since 4.14.0
 */
typedef void(^PNRemoveChannelMetadataCompletionBlock)(PNAcknowledgmentStatus *status);

/**
 * @brief \c Fetch \c channel \c metadata completion handler block.
 *
 * @param result Object with information about \c fetch \c channel \c metadata request results.
 * @param status Object with information about \c fetch \c channel \c metadata request error.
 *
 * @since 4.14.0
 */
typedef void(^PNFetchChannelMetadataCompletionBlock)(PNFetchChannelMetadataResult * _Nullable result,
                                                     PNErrorStatus * _Nullable status);

/**
 * @brief \c Fetch \c all \c channels \c metadata completion handler block.
 *
 * @param result Object with information about \c fetch \c all \c channels \c metadata request results.
 * @param status Object with information about \c fetch \c all \c channels \c metadata request error.
 *
 * @since 4.14.0
 */
typedef void(^PNFetchAllChannelsMetadataCompletionBlock)(PNFetchAllChannelsMetadataResult * _Nullable result,
                                                         PNErrorStatus * _Nullable status);

/**
 * @brief \c Manage \c memberships completion handler block.
 *
 * @param status Object with information about \c manage \c memberships request results and service
 * response.
 *
 * @since 4.14.0
 */
typedef void(^PNManageMembershipsCompletionBlock)(PNManageMembershipsStatus *status);

/**
 * @brief \c Fetch \c memberships completion handler block.
 *
 * @param result Object with information about \c fetch \c memberships request results.
 * @param status Object with information about \c fetch \c memberships request error.
 *
 * @since 4.14.0
 */
typedef void(^PNFetchMembershipsCompletionBlock)(PNFetchMembershipsResult * _Nullable result,
                                                 PNErrorStatus * _Nullable status);

/**
 * @brief \c Manage \c members completion handler block.
 *
 * @param status Object with information about \c manage \c members request results and service
 * response.
 *
 * @since 4.14.0
 */
typedef void(^PNManageChannelMembersCompletionBlock)(PNManageChannelMembersStatus *status);

/**
 * @brief \c Fetch \c members completion handler block.
 *
 * @param result Object with information about \c fetch \c members request results.
 * @param status Object with information about \c fetch \c members request error.
 *
 * @since 4.14.0
 */
typedef void(^PNFetchChannelMembersCompletionBlock)(PNFetchChannelMembersResult * _Nullable result,
                                                    PNErrorStatus * _Nullable status);


#pragma mark - Completion blocks :: Files

/**
 * @brief \c Send \c file completion handler block.
 *
 * @param status Object with information about \c send \c file request results.
 *
 * @since 4.15.0
 */
typedef void(^PNSendFileCompletionBlock)(PNSendFileStatus *status);

/**
 * @brief \c List \c files completion handler block.
 *
 * @param result Object with information about \c list \c files request results.
 * @param status Object with information about \c list \c files request error.
 *
 * @since 4.15.0
 */
typedef void(^PNListFilesCompletionBlock)(PNListFilesResult * _Nullable result,
                                          PNErrorStatus * _Nullable status);

/**
 * @brief \c File \c download \c URL completion handler block.
 *
 * @param url URL which can be used to download file or \c nil in case if URL can't be composed.
 *
 * @since 4.15.0
 */
typedef void(^PNFileDownloadURLCompletionBlock)(NSURL * _Nullable url);

/**
 * @brief \c Download \c file completion handler block.
 *
 * @param result Object with information about \c download \c file request results.
 * @param status Object with information about \c download \c file request error.
 *
 * @since 4.15.0
 */
typedef void(^PNDownloadFileCompletionBlock)(PNDownloadFileResult * _Nullable result,
                                             PNErrorStatus * _Nullable status);

/**
 * @brief \c Delete \c file completion handler block.
 *
 * @param status Object with information about \c delete \c file request results.
 *
 * @since 4.15.0
 */
typedef void(^PNDeleteFileCompletionBlock)(PNAcknowledgmentStatus *status);


#pragma mark - Completion blocks :: Presence

/// Here now completion block.
///
/// - Parameters:
///   - result: Result object which describe service response on here now request.
///   - status: Status instance which hold information about processing results.
typedef void(^PNHereNowCompletionBlock)(PNPresenceHereNowResult * _Nullable result,
                                        PNErrorStatus * _Nullable status);

/**
 * @brief Here now completion block.
 *
 * @param result Result object which describe service response on here now request.
 * @param status Status instance which hold information about processing results.
 */
typedef void(^PNChannelHereNowCompletionBlock)(PNPresenceChannelHereNowResult * _Nullable result,
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

/// Associated state fetch completion block.
///
/// - Parameters:
///   - result: Fetch associated presence state request processing result.
///   - status: Fetch associated presence state request error.
typedef void(^PNPresenceStateFetchCompletionBlock)(PNPresenceStateFetchResult * _Nullable result,
                                                   PNErrorStatus * _Nullable status);

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



#pragma mark - Push Notifications options and enums

/**
 * @brief Enum which specify possible push notification delivery services.
 *
 * @since 4.12.0
 */
typedef NS_OPTIONS(NSUInteger, PNPushType) {
    /**
     * @brief Apple Push Notification Service used to deliver notifications to specified device.
     */
    PNAPNSPush = 1 << 0,
    /**
     * @brief Apple Push Notification Service used over HTTP/2 to deliver notifications to specified
     * device.
     */
    PNAPNS2Push = 1 << 1,
    /**
     * @brief Firebase Cloud Messaging (Google Cloud Messaging) used to deliver notifications to
     * specified device.
     */
    PNFCMPush = 1 << 2,
    /**
     * @brief Microsoft Push Notification Service used to deliver notifications to specified device.
     */
    PNMPNSPush = 1 << 3
};

/**
 * @brief Options with possible APNS environments.
 *
 * @note Available only for APNS2.
 *
 * @since 4.12.0
 */
typedef NS_ENUM(NSUInteger, PNAPNSEnvironment) {
    /**
     * @brief Environment which allow to use APNS sandbox gateway for remote notifications.
     */
    PNAPNSDevelopment,
    /**
     * @brief Environment which allow to use APNS gateway for remote notifications.
     */
    PNAPNSProduction
};


#pragma mark - Objects API options and enums

/// Options with possible additional `channel` / `membership` fields which can be included to response.
typedef NS_OPTIONS(NSUInteger, PNMembershipFields) {
    /// Include how many memberships `UUID` has.
    PNMembershipsTotalCountField = 1 << 0,

    /// Include field with additional information from `metadata` which has been associated with `UUID` during
    /// `membership set` requests.
    PNMembershipCustomField = 1 << 1,

    /// Include field with `metadata` status which has been associated with `UUID` during `membership set` requests.
    PNMembershipStatusField = 1 << 2,

    /// Include field with `metadata` type which has been associated with `UUID` during `membership set` requests.
    PNMembershipTypeField = 1 << 3,

    /// Include `channel`'s  `metadata` into response (not only name).
    PNMembershipChannelField = 1 << 4,

    /// Include `channel`'s additional information which has been used during `channel` `metadata set` requests.
    PNMembershipChannelCustomField = 1 << 5,

    /// Include `channel`'s `status` which has been used during `channel` `metadata set` requests.
    PNMembershipChannelStatusField = 1 << 6,

    /// Include `channel`'s `type` which has been used during `channel` `metadata set` requests.
    PNMembershipChannelTypeField = 1 << 7
};

/// Options with possible additional `UUID` / `member` fields which can be included to response.
typedef NS_OPTIONS(NSUInteger, PNChannelMemberFields) {
    /// Include how many members `channel` has.
    PNChannelMembersTotalCountField = 1 << 8,

    /// Include field with additional information from `metadata` which has been associated with `UUID` during `channel
    /// member set` requests.
    PNChannelMemberCustomField = 1 << 9,

    /// Include field with `metadata` status which has been associated with `UUID` during `channel member set` requests.
    PNChannelMemberStatusField = 1 << 10,

    /// Include field with `metadata` type which has been associated with `UUID` during `channel member set` requests.
    PNChannelMemberTypeField = 1 << 11,

    /// Include `UUID`'s `metadata` into response (not only identifier).
    PNChannelMemberUUIDField = 1 << 12,

    /// Include `UUID`'s additional information which has been used during `UUID metadata set` requests.
    PNChannelMemberUUIDCustomField = 1 << 13,

    /// Include `UUID`'s `status` which has been used during `UUID metadata set` requests.
    PNChannelMemberUUIDStatusField = 1 << 14,

    /// Include `UUID`'s `type` which has been used during `UUID metadata set` requests.
    PNChannelMemberUUIDTypeField = 1 << 15
};

/// Options with possible additional `channel` fields which can be included to response.
typedef NS_OPTIONS(NSUInteger, PNChannelFields) {
    /// Include how many `channels` has been associated with `metadata`.
    ///
    /// > Note: Available only when fetching list of channels metadata.
    PNChannelTotalCountField = 1 << 16,

    /// Include field with additional information from `metadata` which has been used during `channel metadata set`
    /// requests.
    PNChannelCustomField = 1 << 17,

    /// Include field with `metadata` status which has been used during `channel metadata set` requests.
    PNChannelStatusField = 1 << 18,

    /// Include field with `metadata` type which has been used during `channel metadata set` requests.
    PNChannelTypeField = 1 << 19
};

/// Options with possible additional `UUID` fields which can be included to response.
typedef NS_OPTIONS(NSUInteger, PNUUIDFields) {
    /// Include how many `UUID` has been associated with `metadata`.
    ///
    /// > Note: Available only when fetching list of UUIDs metadatas.
    PNUUIDTotalCountField = 1 << 20,

    /// Include field with additional information from `metadata` which has been used during `UUID metadata set`
    /// requests.
    PNUUIDCustomField = 1 << 21,

    /// Include field with `metadata` status which has been used during `UUID metadata set` requests.
    PNUUIDStatusField = 1 << 22,

    /// Include field with `metadata` type which has been used during `UUID metadata set` requests.
    PNUUIDTypeField = 1 << 23
};

/// Options describe possible heartbeat states on which delegate can be notified.
typedef NS_OPTIONS(NSUInteger, PNHeartbeatNotificationOptions) {
    /// Delegate will be notified every time when heartbeat request will be successfully processed.
    PNHeartbeatNotifySuccess = (1 << 0),
    
    /// Delegate will be notified every time when heartbeat request processing will fail.
    PNHeartbeatNotifyFailure = (1 << 1),
    
    /// Delegate will be notified every time when heartbeat request processing will be successful or fail.
    PNHeartbeatNotifyAll = (PNHeartbeatNotifySuccess | PNHeartbeatNotifyFailure),
    
    /// Delegate won't be notified about ant heartbeat request processing results.
    PNHeartbeatNotifyNone = (1 << 2)
};

/// Enum which specify possible actions on objects.
///
/// These fields allow to identify what kind of action has been performed on target object.
typedef NS_ENUM(NSUInteger, PNObjectActionType) {
    /// New object entity has been created.
    PNCreateObjectAction,
    
    /// Object base or additional (custom field / membership) information has been modified.
    PNUpdateObjectAction,
    
    /// Object entity has been deleted.
    PNDeleteObjectAction,
};

/// List of known endpoint groups (by context).
///
/// - Since: 5.3.0
typedef NS_ENUM(NSUInteger, PNEndpoint) {
    /// Unknown endpoint.
    PNUnknownEndpoint,

    /// The endpoints to send messages.
    PNMessageSendEndpoint,

    /// The endpoint for real-time update retrieval.
    PNSubscribeEndpoint,

    /// The endpoint to access and manage `user_id` presence and fetch channel presence information.
    PNPresenceEndpoint,

    /// The endpoint to access and manage files in channel-specific storage.
    PNFilesEndpoint,

    /// The endpoint to access and manage messages for a specific channel(s) in the persistent storage.
    PNMessageStorageEndpoint,

    /// The endpoint to access and manage channel groups.
    PNChannelGroupsEndpoint,

    /// The endpoint to access and manage device registration for channel push notifications.
    PNDevicePushNotificationsEndpoint,

    /// The endpoint to access and manage App Context objects.
    PNAppContextEndpoint,

    /// The endpoint to access and manage reactions for a specific message.
    PNMessageReactionsEndpoint
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
    PNPushNotificationEnabledChannelsV2Operation,
    PNAddPushNotificationsOnChannelsV2Operation,
    PNRemovePushNotificationsFromChannelsV2Operation,
    PNRemoveAllPushNotificationsV2Operation,
    PNSetUUIDMetadataOperation,
    PNRemoveUUIDMetadataOperation,
    PNFetchUUIDMetadataOperation,
    PNFetchAllUUIDMetadataOperation,
    PNSetChannelMetadataOperation,
    PNRemoveChannelMetadataOperation,
    PNFetchChannelMetadataOperation,
    PNFetchAllChannelsMetadataOperation,
    PNSetMembershipsOperation,
    PNRemoveMembershipsOperation,
    PNManageMembershipsOperation,
    PNFetchMembershipsOperation,
    PNSetChannelMembersOperation,
    PNRemoveChannelMembersOperation,
    PNManageChannelMembersOperation,
    PNFetchChannelMembersOperation,
    PNGenerateFileUploadURLOperation,
    PNPublishFileMessageOperation,
    PNSendFileOperation,
    PNListFilesOperation,
    PNDownloadFileOperation,
    PNDeleteFileOperation,
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
     * @brief \b PubNub resource not found.
     *
     * @discussion Requested resource / endpoint doesn't exists.
     */
    PNResourceNotFoundCategory,

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
    PNTLSUntrustedCertificateCategory,

    /**
     * @brief Looks like \b PubNub client wasn't able to upload requested file.
     */
    PNSendFileErrorCategory,

    /**
     * @brief Looks like \b PubNub client wasn't able to upload requested file.
     */
    PNPublishFileMessageErrorCategory,

    /**
     * @brief Looks like \b PubNub client wasn't able to download requested file.
     */
    PNDownloadErrorCategory,
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
