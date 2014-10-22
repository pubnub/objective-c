#import "PubNub.h"

/**
 Base class extension which provide methods for presence information fetching.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (Presence)


#pragma mark - Class (singleton) methods

/**
 Request list of participants for all channels.

 @since 3.6.0
 */
+ (void)requestParticipantsList;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a +requestParticipantsList: and allow to specify
 participants retrieval process block.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - will be empty for this type of request; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @since 3.6.0
 */
+ (void)requestParticipantsListWithCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a +requestParticipantsList: and allow to specify whether server should return client
 identifiers or not.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @since 3.6.0
 */
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a +requestParticipantsListWithClientIdentifiers: and allow to specify participants retrieval
 process block.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - will be empty for this type of request; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @since 3.6.0
 */
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for all channels.
 
 @code
 @endcode
 This method extends \a +requestParticipantsListWithClientIdentifiers: and allow to specify
 whether server should return state which is set to the client or not.
 
 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.
 
 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.
 
 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.
 
 @since 3.6.0
 */
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a +requestParticipantsListWithClientIdentifiers:clientState: and allow to specify
 participants retrieval process block.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - will be empty for this type of request; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.

 @since 3.6.0
 */
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for specified channel.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @note This method by default won't request client's state.
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '+requestParticipantsListFor:' or "
                           "'-requestParticipantsListFor:' instead. Class method will be removed in "
                           "future.");

/**
 Request list of participants for specified channel.
 
 @code
 @endcode
 This method extends \a +requestParticipantsListForChannel: and allow to specify
 participants retrieval process block.
 
 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.
 
 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @note This method by default won't request client's state.
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+requestParticipantsListFor:withCompletionBlock:' or "
                           "'-requestParticipantsListFor:withCompletionBlock:' instead. Class method "
                           "will be removed in future.");

/**
 @brief Request list of participants for specified set of channels.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                       \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve information about
                       participants.
 
 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the
 group, but for channels which is registered under it.

 @since 3.7.0
 */
+ (void)requestParticipantsListFor:(NSArray *)channelObjects;

/**
 @brief Request list of participants for specified set of channels.
 
 @code
 @endcode
 This method extends \a +requestParticipantsListFor: and allow to specify participants retrieval process block.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                       like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve information
                       about participants.
 @param handleBlock    The block which will be called by \b PubNub client as soon as participants list request
                       operation will be completed. The block takes three arguments: \c clients - array of
                       \b PNClient instances which represent client which is subscribed on target channel (if
                       \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have
                       \c kPNAnonymousParticipantIdentifier value); \c channel - is \b PNChannel instance for which
                       \b PubNub client received participants list; \c error - describes what exactly went wrong (check
                       error code and compare it with \b PNErrorCodes ).
 
 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the group, but for
 channels which is registered under it.
 
 @since 3.7.0
 */
+ (void)requestParticipantsListFor:(NSArray *)channelObjects
               withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @note This method by default won't request client's state.

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then result array will contain list of \b PNClient
 instances with names set to \a 'unknown'.

 @since 3.6.0
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
  DEPRECATED_MSG_ATTRIBUTE(" Use '+requestParticipantsListFor:clientIdentifiersRequired:' or "
                           "'-requestParticipantsListFor:clientIdentifiersRequired:' instead. Class "
                           "method will be removed in future.");

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @code
 @endcode
 This method extends \a +requestParticipantsListForChannel:clientIdentifiersRequired: and allow to specify
 participants retrieval process block.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then result array will contain list of \b PNClient
 instances with names set to \a 'unknown'.

 @since 3.6.0
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+requestParticipantsListFor:clientIdentifiersRequired:withCompletionBlock:'"
                           " or '-requestParticipantsListFor:clientIdentifiersRequired:withCompletionBlock:'"
                           " instead. Class method will be removed in future.");

/**
 @brief Request list of participants for specified set of channels.

 @discussion Depending on whether \a 'isIdentifiersListRequired' is set to \c YES or not, \b PubNub client will receive
 from server list of client identifiers or just number of subscribers in specified channel.
 
 @param channelObjects              List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                                    like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve
                                    information about participants.
 @param isClientIdentifiersRequired Whether or not \b PubNub client should fetch list of client identifiers or only
                                    number of them will be returned by server.
 
 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the
 group, but for channels which is registered under it.

 @since 3.7.0
 */
+ (void)requestParticipantsListFor:(NSArray *)channelObjects clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired;

/**
 @brief Request list of participants for specified set of channels.

 @discussion Depending on whether \a 'isIdentifiersListRequired' is set to \c YES or not, \b PubNub client will receive
 from server list of client identifiers or just number of subscribers in specified channel.
 
 @code
 @endcode
 This method extends \a +requestParticipantsListFor:clientIdentifiersRequired: and allow to specify participants
 retrieval process block.

 @param channelObjects              List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                                    like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve
                                    information about participants.
 @param isClientIdentifiersRequired Whether or not \b PubNub client should fetch list of client identifiers or only
                                    number of them will be returned by server.
 @param handleBlock                 The block which will be called by \b PubNub client as soon as participants list
                                    request operation will be completed. The block takes three arguments:
                                    \c clients - array of \b PNClient instances which represent client which is
                                    subscribed on target channel (if \a 'isClientIdentifiersRequired' is set to \c NO
                                    than all objects will have \c kPNAnonymousParticipantIdentifier value);
                                    \c channel - is \b PNChannel instance for which \b PubNub client received
                                    participants list; \c error - describes what exactly went wrong (check error code
                                    and compare it with \b PNErrorCodes ).
 
 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the
 group, but for channels which is registered under it.

 @since 3.7.0
 */
+ (void)requestParticipantsListFor:(NSArray *)channelObjects clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
               withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @code
 @endcode
 This method extends \a +requestParticipantsListForChannel:clientIdentifiersRequired: and allow to specify
 whether server should return state which is set to the client or not.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.

 @since 3.6.0
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState
  DEPRECATED_MSG_ATTRIBUTE(" Use '+requestParticipantsListFor:clientIdentifiersRequired:clientState:' "
                           "or '-requestParticipantsListFor:clientIdentifiersRequired:clientState:' "
                           "instead. Class method will be removed in future.");

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @code
 @endcode
 This method extends \a +requestParticipantsListForChannel:clientIdentifiersRequired:clientState: and allow to
 specify participants retrieval process block.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.

 @since 3.6.0
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+requestParticipantsListFor:clientIdentifiersRequired:clientState:withCompletionBlock:' or "
                           "'-requestParticipantsListFor:clientIdentifiersRequired:clientState:withCompletionBlock:'"
                           " instead. Class method will be removed in future.");

/**
 @brief Request list of participants for specified set of channels.

 @discussion Depending on whether \a 'isIdentifiersListRequired' is set to \c YES or not, \b PubNub client will receive
 from server list of client identifiers or just number of subscribers in specified channel.
 
 @code
 @endcode
 This method extends \a +requestParticipantsListFor:clientIdentifiersRequired: and allow to specify
 whether server should return state which is set to the client or not.

 @param channelObjects              List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                                    like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve
                                    information about participants.
 @param isClientIdentifiersRequired Whether or not \b PubNub client should fetch list of client identifiers or only
                                    number of them will be returned by server.
 @param shouldFetchClientState      Whether or not \b PubNub client should fetch additional information which has been
                                    added to the client during subscription or specific API endpoints.
 
 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the
 group, but for channels which is registered under it.

 @since 3.7.0
 */
+ (void)requestParticipantsListFor:(NSArray *)channelObjects clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                       clientState:(BOOL)shouldFetchClientState;

/**
 @brief Request list of participants for specified set of channels.

 @discussion Depending on whether \a 'isIdentifiersListRequired' is set to \c YES or not, \b PubNub client will receive
 from server list of client identifiers or just number of subscribers in specified channel.
 
 @code
 @endcode
 This method extends \a +requestParticipantsListFor:clientIdentifiersRequired:clientState: and allow to specify
 participants retrieval process block.

 @param channelObjects              List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                                    like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve
                                    information about participants.
 @param isClientIdentifiersRequired Whether or not \b PubNub client should fetch list of client identifiers or only
                                    number of them will be returned by server.
 @param shouldFetchClientState      Whether or not \b PubNub client should fetch additional information which has been
                                    added to the client during subscription or specific API endpoints.
 @param handleBlock                 The block which will be called by \b PubNub client as soon as participants list
                                    request operation will be completed. The block takes three arguments:
                                    \c clients - array of \b PNClient instances which represent client which is
                                    subscribed on target channel (if \a 'isClientIdentifiersRequired' is set to \c NO
                                    than all objects will have \c kPNAnonymousParticipantIdentifier value);
                                    \c channel - is \b PNChannel instance for which \b PubNub client received
                                    participants list; \c error - describes what exactly went wrong (check error code
                                    and compare it with \b PNErrorCodes ).

 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the group, but for
 channels which is registered under it.

 @since 3.7.0
 */
+ (void)requestParticipantsListFor:(NSArray *)channelObjects clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                       clientState:(BOOL)shouldFetchClientState
               withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of channels in which current client identifier reside at this moment.

 @param clientIdentifier
 Client identifier for which \b PubNub client should get list of channels in which it reside.

 @since 3.6.0
 */
+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier;

/**
 Request list of channels in which current client identifier reside at this moment.

 @code
 @endcode
 This method extends \a +requestParticipantChannelsList: and allow to specify participant channels retrieval process
 block.

 @param clientIdentifier
 Client identifier for which \b PubNub client should get list of channels in which it reside.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participant channels list request operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been found as subscriber; \c error -
 describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @since 3.6.0
 */
+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock;


#pragma mark - Instance methods

/**
 Request list of participants for all channels.

 @since 3.7.0
 */
- (void)requestParticipantsList;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a -requestParticipantsList: and allow to specify
 participants retrieval process block.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - will be empty for this type of request; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @since 3.7.0
 */
- (void)requestParticipantsListWithCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a -requestParticipantsList: and allow to specify whether server should return client
 identifiers or not.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @since 3.7.0
 */
- (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a -requestParticipantsListWithClientIdentifiers: and allow to specify participants retrieval
 process block.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - will be empty for this type of request; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @since 3.7.0
 */
- (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for all channels.
 
 @code
 @endcode
 This method extends \a -requestParticipantsListWithClientIdentifiers: and allow to specify
 whether server should return state which is set to the client or not.
 
 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.
 
 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.
 
 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.
 
 @since 3.7.0
 */
- (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a -requestParticipantsListWithClientIdentifiers:clientState: and allow to specify
 participants retrieval process block.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - will be empty for this type of request; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.

 @since 3.7.0
 */
- (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for specified channel.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @note This method by default won't request client's state.
 */
- (void)requestParticipantsListForChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '-requestParticipantsListFor:' instead.");

/**
 Request list of participants for specified channel.

 @code
 @endcode
 This method extends \a -requestParticipantsListForChannel: and allow to specify
 participants retrieval process block.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.
 */
- (void)requestParticipantsListForChannel:(PNChannel *)channel
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-requestParticipantsListFor:withCompletionBlock:' instead.");

/**
 @brief Request list of participants for specified set of channels.

 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                       \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve information about
                       participants.

 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the
 group, but for channels which is registered under it.

 @since 3.7.0
 */
- (void)requestParticipantsListFor:(NSArray *)channelObjects;

/**
 @brief Request list of participants for specified set of channels.

 @code
 @endcode
 This method extends \a -requestParticipantsListFor: and allow to specify participants retrieval process block.

 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                       like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve information
                       about participants.
 @param handleBlock    The block which will be called by \b PubNub client as soon as participants list request
                       operation will be completed. The block takes three arguments: \c clients - array of
                       \b PNClient instances which represent client which is subscribed on target channel (if
                       \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have
                       \c kPNAnonymousParticipantIdentifier value); \c channel - is \b PNChannel instance for which
                       \b PubNub client received participants list; \c error - describes what exactly went wrong (check
                       error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the group, but for
 channels which is registered under it.
 
 @since 3.7.0
 */
- (void)requestParticipantsListFor:(NSArray *)channelObjects
               withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @note This method by default won't request client's state.

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then result array will contain list of \b PNClient
 instances with names set to \a 'unknown'.

 @since 3.7.0
 */
- (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
  DEPRECATED_MSG_ATTRIBUTE(" Use '-requestParticipantsListFor:clientIdentifiersRequired:' instead.");

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @code
 @endcode
 This method extends \a -requestParticipantsListForChannel:clientIdentifiersRequired: and allow to specify
 participants retrieval process block.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then result array will contain list of \b PNClient
 instances with names set to \a 'unknown'.

 @since 3.7.0
 */
- (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-requestParticipantsListFor:clientIdentifiersRequired:withCompletionBlock:' instead.");

/**
 @brief Request list of participants for specified set of channels.

 @discussion Depending on whether \a 'isIdentifiersListRequired' is set to \c YES or not, \b PubNub client will receive
 from server list of client identifiers or just number of subscribers in specified channel.

 @code
 @endcode
 This method extends \a +requestParticipantsListFor:clientIdentifiersRequired: and allow to specify participants
 retrieval process block.

 @param channelObjects              List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                                    like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve
                                    information about participants.
 @param isClientIdentifiersRequired Whether or not \b PubNub client should fetch list of client identifiers or only
                                    number of them will be returned by server.

 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the
 group, but for channels which is registered under it.

 @since 3.7.0
 */
- (void)requestParticipantsListFor:(NSArray *)channelObjects clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired;

/**
 @brief Request list of participants for specified set of channels.

 @discussion Depending on whether \a 'isIdentifiersListRequired' is set to \c YES or not, \b PubNub client will receive
 from server list of client identifiers or just number of subscribers in specified channel.

 @code
 @endcode
 This method extends \a -requestParticipantsListFor:clientIdentifiersRequired: and allow to specify participants
 retrieval process block.

 @param channelObjects              List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                                    like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve
                                    information about participants.
 @param isClientIdentifiersRequired Whether or not \b PubNub client should fetch list of client identifiers or only
                                    number of them will be returned by server.
 @param handleBlock                 The block which will be called by \b PubNub client as soon as participants list
                                    request operation will be completed. The block takes three arguments:
                                    \c clients - array of \b PNClient instances which represent client which is
                                    subscribed on target channel (if \a 'isClientIdentifiersRequired' is set to \c NO
                                    than all objects will have \c kPNAnonymousParticipantIdentifier value);
                                    \c channel - is \b PNChannel instance for which \b PubNub client received
                                    participants list; \c error - describes what exactly went wrong (check error code
                                    and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the
 group, but for channels which is registered under it.

 @since 3.7.0
 */
- (void)requestParticipantsListFor:(NSArray *)channelObjects clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
               withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @code
 @endcode
 This method extends \a -requestParticipantsListForChannel:clientIdentifiersRequired: and allow to specify
 whether server should return state which is set to the client or not.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.

 @since 3.7.0
 */
- (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState
  DEPRECATED_MSG_ATTRIBUTE(" Use '-requestParticipantsListFor:clientIdentifiersRequired:clientState:' instead.");

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @code
 @endcode
 This method extends \a -requestParticipantsListForChannel:clientIdentifiersRequired:clientState: and allow to
 specify participants retrieval process block.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.

 @since 3.7.0
 */
- (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-requestParticipantsListFor:clientIdentifiersRequired:clientState:withCompletionBlock:'"
                           " instead.");

/**
 @brief Request list of participants for specified set of channels.

 @discussion Depending on whether \a 'isIdentifiersListRequired' is set to \c YES or not, \b PubNub client will receive
 from server list of client identifiers or just number of subscribers in specified channel.

 @code
 @endcode
 This method extends \a +requestParticipantsListFor:clientIdentifiersRequired: and allow to specify
 whether server should return state which is set to the client or not.

 @param channelObjects              List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                                    like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve
                                    information about participants.
 @param isClientIdentifiersRequired Whether or not \b PubNub client should fetch list of client identifiers or only
                                    number of them will be returned by server.
 @param shouldFetchClientState      Whether or not \b PubNub client should fetch additional information which has been
                                    added to the client during subscription or specific API endpoints.

 @note This method by default won't request client's state.
 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the
 group, but for channels which is registered under it.

 @since 3.7.0
 */
- (void)requestParticipantsList:(NSArray *)channelObjects clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                    clientState:(BOOL)shouldFetchClientState;

/**
 @brief Request list of participants for specified set of channels.

 @discussion Depending on whether \a 'isIdentifiersListRequired' is set to \c YES or not, \b PubNub client will receive
 from server list of client identifiers or just number of subscribers in specified channel.

 @code
 @endcode
 This method extends \a -requestParticipantsListFor:clientIdentifiersRequired:clientState: and allow to specify
 participants retrieval process block.

 @param channelObjects              List of objects (which conforms to \b PNChannelProtocol data feed object protocol)
                                    like \b PNChannel and \b PNChannelGroup for which \b PubNub client should retrieve
                                    information about participants.
 @param isClientIdentifiersRequired Whether or not \b PubNub client should fetch list of client identifiers or only
                                    number of them will be returned by server.
 @param shouldFetchClientState      Whether or not \b PubNub client should fetch additional information which has been
                                    added to the client during subscription or specific API endpoints.
 @param handleBlock                 The block which will be called by \b PubNub client as soon as participants list
                                    request operation will be completed. The block takes three arguments:
                                    \c clients - array of \b PNClient instances which represent client which is
                                    subscribed on target channel (if \a 'isClientIdentifiersRequired' is set to \c NO
                                    than all objects will have \c kPNAnonymousParticipantIdentifier value);
                                    \c channel - is \b PNChannel instance for which \b PubNub client received
                                    participants list; \c error - describes what exactly went wrong (check error code
                                    and compare it with \b PNErrorCodes ).

 @note \b PNChannelGroup instances will be expanded on server and information will be returned not for name of the group, but for
 channels which is registered under it.

 @since 3.7.0
 */
- (void)requestParticipantsListFor:(NSArray *)channelObjects clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                       clientState:(BOOL)shouldFetchClientState
               withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of channels in which current client identifier reside at this moment.

 @param clientIdentifier
 Client identifier for which \b PubNub client should get list of channels in which it reside.

 @since 3.7.0
 */
- (void)requestParticipantChannelsList:(NSString *)clientIdentifier;

/**
 Request list of channels in which current client identifier reside at this moment.

 @code
 @endcode
 This method extends \a -requestParticipantChannelsList: and allow to specify participant channels retrieval process
 block.

 @param clientIdentifier
 Client identifier for which \b PubNub client should get list of channels in which it reside.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participant channels list request operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been found as subscriber; \c error -
 describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @since 3.7.0
 */
- (void)requestParticipantChannelsList:(NSString *)clientIdentifier
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock;

#pragma mark -


@end
