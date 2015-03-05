//
//  PNMessageChannelDelegate.h
//  pubnub
//
//  Describes interface which is used to organize
//  communication between service communication
//  channel and PubNub client
//
//
//  Created by Sergey Mamontov on 12/29/12.
//
//


#pragma mark Class forward

@class PNAccessRightsCollection, PNChannelGroupChange, PNServiceChannel, PNMessagesHistory,
       PNChannelGroup, PNBaseRequest, PNWhereNow, PNResponse, PNHereNow, PNClient;


@protocol PNServiceChannelDelegate<NSObject>


@optional // @required in corresponding categories for PubNub main class.

/**
 @brief Sent to the delegate when \b PubNub client successfully retrieved state for client.

 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param client  \b PNClient instance which hold information on for who this response and state for
                him on concrete channel.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.

 @since 3.6.2
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceiveClientState:(PNClient *)client
             onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client did fail to retrieve state for client.

 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param error   \b PNError instance which holds information about what went wrong and why request
                failed. \a 'error.associatedObject' contains reference on \b PNClient instance which
                will allow to review for whom request has been made.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.6.2
 */
- (void)serviceChannel:(PNServiceChannel *)channel clientStateReceiveDidFailWithError:(PNError *)error
            forRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client successfully updated state for client.

 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param client  \b PNClient instance which hold information on for who this response and updated
                state on concrete channel.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.

 @since 3.6.2
 */
- (void)serviceChannel:(PNServiceChannel *)channel didUpdateClientState:(PNClient *)client
             onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client did fail to update state for client.

 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param error   \b PNError instance which holds information about what went wrong and why request
                failed. \a 'error.associatedObject' contains reference on \b PNClient instance which
                will allow to review for whom request has been made.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.6.2
 */
- (void)serviceChannel:(PNServiceChannel *)channel clientStateUpdateDidFailWithError:(PNError *)error
            forRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client successfully retrieved channel groups.
 
 @param channel       Communication channel over which request has been sent and processed response
                      from \b PubNub services.
 @param channelGroups List of \b PNChannelGroup instances
 @param nspace        Reference on namespace from which \b PubNub fetched channel groups.
 @param request       Reference on \b PNBaseRequest instance which initiated this operation.

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceiveChannelGroups:(NSArray *)channelGroups
          forNamespace:(NSString *)nspace onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client did fail to fetch channel groups.
 
 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param nspace  Reference on namespace from which \b PubNub fetched channel groups.
 @param error   \b PNError instance which holds information about what went wrong and why request
                failed.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel channelGroupsRequestForNamespace:(NSString *)nspace
      didFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client successfully retrieved channels list for group.
 
 @param channel  Communication channel over which request has been sent and processed response from
                 \b PubNub services.
 @param channels List of \b PNChannel instance
 @param group    Reference on \b PNChannelGroup instance which describe end point from this channels
                 should be pulled out.
 @param request  Reference on \b PNBaseRequest instance which initiated this operation.

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceiveChannels:(NSArray *)channels
              forGroup:(PNChannelGroup *)group onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client did fail to fetch channels list for group.
 
 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param group   Reference on \b PNChannelGroup instance which describe end point from this channels
                should be pulled out.
 @param error   \b PNError instance which holds information about what went wrong and why request
                failed.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel channelsForGroupRequest:(PNChannelGroup *)group
      didFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client successfully changed channels list for group.
 
 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param change  Reference on \b PNChannelGroupChange instance which describe options for group
                channels list change.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel didChangeGroupChannels:(PNChannelGroupChange *)change
             onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client did fail to change channels list to group.
 
 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param change  Reference on \b PNChannelGroupChange instance which describe options for group
                channels list change.
 @param error   \b PNError instance which holds information about what went wrong and why request
                failed.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel groupChannelsChange:(PNChannelGroupChange *)change
      didFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client successfully received channel group namespaces.
 
 @param channel    Communication channel over which request has been sent and processed response
                   from \b PubNub services.
 @param namespaces List of \a NSString instances with names of namespaces which has been registered
                   with subscription current key.
 @param request    Reference on \b PNBaseRequest instance which initiated this operation.

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceiveChannelGroupNamespaces:(NSArray *)namespaces
             onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client did fail to retrieve list of namespaces for
        channel groups.
 
 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param error   \b PNError instance which holds information about what went wrong and why request
                failed.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel channelGroupNamespacesRequestDidFailWithError:(PNError *)error
            forRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client successfully removed namespace along with channel
        groups and channels registered in it.
 
 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param nspace  Namespace name which has been removed from channels registry.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel didRemoveNamespace:(NSString *)nspace
             onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client did fail to remove channel group namespace
        removal.
 
 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param nspace  Reference on namespace which should be removed along with all channel group and
                channels registered in it.
 @param error   \b PNError instance which holds information about what went wrong and why request
                failed.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.7.0
 */
- (void)   serviceChannel:(PNServiceChannel *)channel namespace:(NSString *)nspace
  removalDidFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client successfully removed channel groups along with
        channels registered in it.
 
 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param group   \b PNChannelGroup instance which describes target channel group which has been
                removed.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.

 @since 3.7.0
 */
- (void)serviceChannel:(PNServiceChannel *)channel didRemoveChannelGroup:(PNChannelGroup *)group
             onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client did fail to remove channel group along with channels registered in it.
 
 @param channel Communication channel over which request has been sent and processed response from
                \b PubNub services.
 @param group   Reference on \b PNChannelGroup which should be removed along with channels
                registered in it.
 @param error   \b PNError instance which holds information about what went wrong and why request
                failed.\c associatedObject contains reference on \b PNChannelGroup which describe
                group which client tried to remove.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.7.0
 */
- (void)   serviceChannel:(PNServiceChannel *)channel channelGroup:(PNChannelGroup *)group
  removalDidFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client successfully changed access rights.

 @param channel                 Communication channel over which request has been sent and processed
                                response from \b PubNub services.
 @param accessRightsInformation Instance of \b PNAccessRightsCollection which aggregate in itself
                                \b PNAccessRightsInformation instances to describe access rights at
                                different levels (there is a three levels: application, channel and
                                user).
 @param request                 Reference on \b PNBaseRequest instance which initiated this
                                operation.

 @since 3.5.3
 */
- (void) serviceChannel:(PNServiceChannel *)channel
  didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection
              onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client failed to change access rights.

 @param client  \b PubNub client which failed request processing (this is singleton).

 @param error   \b PNError instance which holds information about what went wrong and why request
                failed. \a 'error.associatedObject' contains reference on \b PNAccessRightOptions
                instance which will allow to review and identify what options \b PubNub client tried
                to apply.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.5.3
 */
- (void)serviceChannel:(PNServiceChannel *)channel accessRightsChangeDidFailWithError:(PNError *)error
            forRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client successfully retrieved access rights information
        for specified object.

 @param channel                 Communication channel over which request has been sent and processed
                                response from \b PubNub services.
 @param accessRightsInformation Instance of \b PNAccessRightsCollection which aggregate in itself
                                \b PNAccessRightsInformation instances to describe access rights at
                                different levels (there is a three levels: application, channel and
                                user).
 @param request                 Reference on \b PNBaseRequest instance which initiated this
                                operation.

 @since 3.5.3
 */
- (void)serviceChannel:(PNServiceChannel *)channel
  didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection
             onRequest:(PNBaseRequest *)request;

/**
 @brief Sent to the delegate when \b PubNub client failed to audit access rights.

 @param client  \b PubNub client which failed request processing (this is singleton).
 @param error   \b PNError instance which holds information about what went wrong and why request
                failed. \a 'error.associatedObject' contains reference on \b PNAccessRightOptions
                instance which will allow to review and identify what options \b PubNub client used
                for audition.
 @param request Reference on \b PNBaseRequest instance which initiated this operation.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).

 @since 3.5.3
 */
- (void)serviceChannel:(PNServiceChannel *)channel accessRightsAuditDidFailWithError:(PNError *)error
            forRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when time token arrived
 * from backend by request
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceiveTimeToken:(NSNumber *)timeToken
             onRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when some error occurred
 * while tried to process time token retrieve request
 */
- (void)serviceChannel:(PNServiceChannel *)channel receiveTimeTokenDidFailWithError:(PNError *)error
            forRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when push notification successfully
 * enabled on specified channels
 */
- (void)serviceChannel:(PNServiceChannel *)channel didEnablePushNotificationsOnChannels:(NSArray *)channels
             onRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when push notification enabling failed
 * because of error
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationEnableForChannels:(NSArray *)channels
             withError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when push notification successfully
 * disabled on specified channels
 */
- (void)serviceChannel:(PNServiceChannel *)channel didDisablePushNotificationsOnChannels:(NSArray *)channels
             onRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when push notification disabling failed
 * because of error
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationDisableForChannels:(NSArray *)channels
             withError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when push notifications succeffully removed
 * from all channels
 */
- (void)serviceChannelDidRemovePushNotifications:(PNServiceChannel *)channel
                                       onRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when push notification removal failed because of error
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationsRemoveWithError:(PNError *)error
            forRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when push notifications enabled channels
 * successfully received
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceivePushNotificationsEnabledChannels:(NSArray *)channels
             onRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when push notification enabled channels
 * retrieval failed
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationEnabledChannelsReceiveWithError:(PNError *)error
            forRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when latency meter information
 * arrived from backend
 */
- (void)  serviceChannel:(PNServiceChannel *)channel
didReceiveNetworkLatency:(double)latency
     andNetworkBandwidth:(double)bandwidth;


/**
 * Sent to the delegate right before message post
 * request will be sent to the PubNub service
 */
- (void)serviceChannel:(PNServiceChannel *)channel willSendMessage:(PNMessage *)message
             onRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when PubNub service responded
 * that message has been processed
 */
- (void)serviceChannel:(PNServiceChannel *)channel didSendMessage:(PNMessage *)message
             onRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate if PubNub reported with processing error or message was unable to send because of some other
 * issues.
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFailMessageSend:(PNMessage *)message
             withError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when PubNub service responded on history download request.
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveMessagesHistory:(PNMessagesHistory *)history
             onRequest:(PNBaseRequest *)request;

/**
 * Sent to the delegate when PubNub service refused to return history for specified channel.
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailHisoryDownloadForChannel:(PNChannel *)channel
             withError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 Sent to the delegate when PubNub service responded on participants information request.
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantsList:(PNHereNow *)participants
             onRequest:(PNBaseRequest *)request;

/**
 Sent to the delegate when PubNub service failed to retrieve participants information for specified channels list
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailParticipantsListLoadForChannels:(NSArray *)channels
             withError:(PNError *)error forRequest:(PNBaseRequest *)request;

/**
 Sent to the delegate when PubNub service responded on participant channels list request.

 @param serviceChannel
 \b PNServiceChannel instance which triggered event.

 @param participantChannels
 \b PNWhereNow instance which hold information about channels and client identifier for which they has been requested.

 @since 3.6.0
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantChannelsList:(PNWhereNow *)participantChannels
             onRequest:(PNBaseRequest *)request;

/**
 Sent to the delegate when PubNub service failed to retrieve participants list for specified channel.

 @param serviceChannel
 \b PNServiceChannel instance which triggered event.

 @param clientIdentifier
 Identifier for which channels list has been requested,

 @param error
 \b PNError instance which allow to understand why request failed.

 @since 3.6.0
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailParticipantChannelsListLoadForIdentifier:(NSString *)clientIdentifier
             withError:(PNError *)error forRequest:(PNBaseRequest *)request;

@end
