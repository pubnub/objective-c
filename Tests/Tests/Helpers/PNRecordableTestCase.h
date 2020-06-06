#import <YAHTTPVCR/YAHTTPVCR.h>
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types and structures

/**
 * @brief Type used to describe block for \c message handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param message Object with information about received message.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveMessageHandler)(PubNub *client, PNMessageResult *message, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for \c signal handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param signal Object with information about received signal.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveSignalHandler)(PubNub *client, PNSignalResult *signal, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for \c action handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param action Object with information about received \c action.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveMessageActionHandler)(PubNub *client, PNMessageActionResult *action, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for \c presence event handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param event Object with information about received presence event.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceivePresenceEventHandler)(PubNub *client, PNPresenceEventResult *event, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for \c object event handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param event Object with information about received \c object event.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveObjectEventHandler)(PubNub *client, PNObjectEventResult *event, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for status change handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param status Object with information about last client status change.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveStatusHandler)(PubNub *client, PNSubscribeStatus *status, BOOL *shouldRemove);


#pragma mark Public interface declaration

/**
 * @brief Test classes base class with requests recording ability.
 *
 * @discussion Class also handle switching between mocked and real server responses basing on
 * target which is running these tests.
 */
@interface PNRecordableTestCase : YHVTestCase


#pragma mark - Information

/**
 * @brief For how long negative test should wait till async operation completion.
 */
@property (nonatomic, readonly, assign) NSTimeInterval falseTestCompletionDelay;

/**
 * @brief For how long positive test should wait till async operation completion.
 */
@property (nonatomic, readonly, assign) NSTimeInterval testCompletionDelay;

/**
 * @brief Currently used \b PubNub client instance.
 *
 * @discussion Instance created lazily and take into account whether mocking enabled at this moment
 * or not.
 * As configuration instance will use \c defaultConfiguration and options provided by available
 * configuration callbacks.
 *
 * @note This client should be used only for unit tests, because they don't need to use multi-user
 * environment.
 */
@property (nonatomic, readonly, nullable, strong) PubNub *client;

/**
 * @brief Whether current test case uses mocked objects or not.
 *
 * @discussion Value of this property affects \b PubNub client instance on-demand creation by
 * storing original instance or mocked object.
 */
@property (nonatomic, assign) BOOL usesMockedObjects;


#pragma mark - Test configuration

/**
 * @brief Whether PAM-enabled account keys should be used to run test case or not.
 *
 * @param name Name of current test case.
 *
 * @return Whether PAM-enabled keys should be used or not.
 *     \b Default: \c NO
 */
- (BOOL)usePAMEnabledKeysForTestCaseWithName:(NSString *)name;

/**
 * @brief Unique user identifier which should be used to configure new \b PubNub instance.
 *
 * @param name Name of current test case.
 *
 * @return \c uuid which will be used with \b PNConfiguration.
 *     \b Default: \c serhii
 */
- (NSString *)pubNubUUIDForTestCaseWithName:(NSString *)name;

/**
 * @brief User authentication token which should be used to configure new \b PubNub instance.
 *
 * @param name Name of current test case.
 *
 * @return \c auth which will be used with \b PNConfiguration.
 */
- (nullable NSString *)pubNubAuthForTestCaseWithName:(NSString *)name;

/**
 * @brief Whether running test case has any \b PubNub objects or not.
 *
 * @return Whether test case stub / mock any data or not.
 *     \b Default: \c NO
 */
- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name;

/**
 * @brief \b PubNub client instance configuration for specific test case.
 *
 * @param name Name of current test case.
 *
 * @return \b PubNub client configuration instance or default configuration if \c nil returned.
 */
- (nullable PNConfiguration *)configurationForTestCaseWithName:(NSString *)name;


#pragma mark - Client configuration

/**
 * @brief Default \b PubNub client configuration which applied by helper to all created instances.
 */
- (PNConfiguration *)defaultConfiguration;

/**
 * @brief Configure \b PubNub client instance for specific user using default configuration.
 *
 * @param user Unique user identifier for which \b PubNub client instance should be created.
 *
 * @return Configured and ready to use \b PubNub client instance.
 */
- (PubNub *)createPubNubForUser:(NSString *)user;

/**
 * @brief Configure \b PubNub client instance with data required for test case.
 *
 * @param user Unique user identifier for which \b PubNub client instance should be created.
 * @param configuration \b PubNub client configuration object.
 *
 * @return Configured and ready to use \b PubNub client instance.
 */
- (PubNub *)createPubNubForUser:(NSString *)user withConfiguration:(PNConfiguration *)configuration;

/**
 * @brief Configure set of \b PubNub client instances with default configuration.
 *
 * @param clientsCount How many \b PubNub client instances should be created with random \c uuids.
 *
 * @return List of configured and ready to use \b PubNub client instances.
 */
- (NSArray<PubNub *> *)createPubNubClients:(NSUInteger)clientsCount;

/**
 * @brief Ensure what \b PubNub client instance is ready for test case run.
 *
 * @param client \b PubNub client instance for which setup process should be finalyzed.
 */
- (void)completePubNubConfiguration:(PubNub *)client;

/**
 * @brief Retrieve \b PubNub client instance which has been created on \c -setUp step for specified
 * \c user.
 *
 * @param user Unique identifier for which separate \b PubNub client instance has been created
 * before.
 *
 * @return Previously configured \b PubNub client instance.
 */
- (nullable PubNub *)pubNubForUser:(NSString *)user;

/**
 * @brief Retrieve \b PubNub client duplicate which has been created on \c -setUp step for specified
 * \c user for which one instance already exists.
 *
 * @param user Unique identifier for which separate \b PubNub client instance has been created
 * before.
 *
 * @return Clone of previously configured \b PubNub client instance.
 */
- (nullable PubNub *)pubNubCloneForUser:(NSString *)user;


#pragma mark - Subscription

/**
 * @brief Subscribe specified \c client to list of \c channels.
 *
 * @note Method will postpone test execution and wait till \b PubNub client will report connected
 * state for all channels.
 *
 * @param client \b PubNub client which should be used to subscribe to \c channels.
 * @param channels List of channel names to which \c client should subscribe.
 * @param usePresence Whether \c client should handle presence events or not.
 */
- (void)subscribeClient:(PubNub *)client toChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)usePresence;

/**
 * @brief Subscribe specified \c client to list of \c channel \c groups.
 *
 * @note Method will postpone test execution and wait till \b PubNub client will report connected
 * state for all channel groups.
 *
 * @param client \b PubNub client which should be used to subscribe to \c channel \c groups.
 * @param channelGroups List of channel group names to which \c client should subscribe.
 * @param usePresence Whether \c client should handle presence events or not.
 */
- (void)subscribeClient:(PubNub *)client toChannelGroups:(NSArray<NSString *> *)channelGroups withPresence:(BOOL)usePresence;

/**
 * @brief Unsubscribe specified \c client from list of \c channels.
 *
 * @note Method will postpone test execution and wait till \b PubNub client will report disconnected
 * state for all channels.
 *
 * @param client \b PubNub client which should be used to unsubscribe from \c channels.
 * @param channels List of channel names from which \c client should unsubscribe.
 * @param usePresence Whether \c client should stop presence events handling or not.
 */
- (void)unsubscribeClient:(PubNub *)client fromChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)usePresence;

/**
 * @brief Unsubscribe specified \c client from list of \c channel \c groups.
 *
 * @note Method will postpone test execution and wait till \b PubNub client will report disconnected
 * state for all channel groups.
 *
 * @param client \b PubNub client which should be used to unsubscribe from \c channel \c groups.
 * @param channelGroups List of channel group names from which \c client should unsubscribe.
 * @param usePresence Whether \c client should stop presence events handling or not.
 */
- (void)unsubscribeClient:(PubNub *)client fromChannelGroups:(NSArray<NSString *> *)channelGroups withPresence:(BOOL)usePresence;


#pragma mark - Publish

/**
 * @brief Publish test messages to specified \c channel.
 *
 * @param messagesCount How many messages should be published to specified \c channel.
 * @param channel Name of channel which will be used in test with pre-published messages.
 * @param client \b PubNub client which should be used to publish messages. Will use \c self.client
 *     if passed \c nil.
 *
 * @return List of published messages (each entry includes: message, timetoken and some include
 * metadata).
 */
- (NSArray<NSDictionary *> *)publishMessages:(NSUInteger)messagesCount
                                   toChannel:(NSString *)channel
                                 usingClient:(nullable PubNub *)client;

/**
 * @brief Publish test messages to set of specified \c channels.
 *
 * @param messagesCount How many messages should be published to each of specified \c channels.
 * @param channels List of channel names which will be used in test with pre-published messages.
 * @param client \b PubNub client which should be used to publish messages. Will use \c self.client
 *     if passed \c nil.
 *
 * @return List of published message and timetokens mapped to channel names.
 */
- (NSDictionary<NSString *, NSArray<NSDictionary *> *> *)publishMessages:(NSUInteger)messagesCount
                                                              toChannels:(NSArray<NSString *> *)channels
                                                             usingClient:(nullable PubNub *)client;

/**
 * @brief Add actions to set of messages (using their timetokens).
 *
 * @param actionsCount How many actions should be added for each message.
 * @param messages List of publish timetokens for messages to which \c actions will be added.
 * @param channel Name of channel which contains references messages.
 * @param client \b PubNub client which should be used to add message actions. Will use
 *     \c self.client if passed \c nil.
 *
 * @return List of message actions.
 */
- (NSArray<PNMessageAction *> *)addActions:(NSUInteger)actionsCount
                                toMessages:(NSArray<NSNumber *> *)messages
                                 inChannel:(NSString *)channel
                               usingClient:(nullable PubNub *)client;

/**
 * @brief Ensure, that specified \c channel contain specified number of actions added for messages.
 *
 * @param channel Channel which should be checked.
 * @param count Expected number of message actions added to messages in \ channel.
 * @param client \b PubNub client which should be used to audit message actions. Will use
 *     \c self.client if passed \c nil.
 */
- (void)verifyMessageActionsCountInChannel:(NSString *)channel
                             shouldEqualTo:(NSUInteger)count
                               usingClient:(nullable PubNub *)client;


#pragma mark - History

/**
 * @brief Clean up after test case has been completed.
 *
 * @param channel Name of channel for which history should be removed.
 * @param client \b PubNub client which should be used to clear messages. Will use \c self.client
 *     if passed \c nil.
 */
- (void)deleteHistoryForChannel:(NSString *)channel usingClient:(nullable PubNub *)client;

/**
 * @brief Clean up after test case has been completed.
 *
 * @param channels Name of channels for which history should be removed.
 * @param client \b PubNub client which should be used to clear messages. Will use \c self.client
 *     if passed \c nil.
 */
- (void)deleteHistoryForChannels:(NSArray<NSString *> *)channels usingClient:(nullable PubNub *)client;


#pragma mark - Channel groups

/**
 * @brief Add list of \c channels to \c channelGroup.
 *
 * @param channels List of channels which should be added to channel group.
 * @param channelGroup Channel group to which new channels should be added.
 * @param client \b PubNub client which should be used to manage channel groups. Will use
 *     \c self.client if passed \c nil.
 */
- (void)addChannels:(NSArray<NSString *> *)channels
     toChannelGroup:(NSString *)channelGroup
        usingClient:(nullable PubNub *)client;

/**
 * @brief Ensure, that specified \c channels list added to target \c channel \c group.
 *
 * @param channels List of channels which should be checked.
 * @param channelGroup Channel group inside of which specified \c channels should be checked.
 * @param shouldEqual Whether fetched channel group channels should equal to passed \c channels
 *     (not just subset).
 * @param client \b PubNub client which should be used to audit channel groups. Will use
 *     \c self.client if passed \c nil.
 */
- (void)verifyChannels:(NSArray<NSString *> *)channels
        inChannelGroup:(NSString *)channelGroup
           shouldEqual:(BOOL)shouldEqual
           usingClient:(nullable PubNub *)client;

/**
 * @brief Clean up after test case has been completed.
 *
 * @param channelGroup Channel group from which all channels should be removed.
 * @param client \b PubNub client which should be used to manage channel groups. Will use
 *     \c self.client if passed \c nil.
 */
- (void)removeChannelGroup:(NSString *)channelGroup usingClient:(nullable PubNub *)client;


#pragma mark - Presence

/**
 * @brief Update state on specified channel.
 *
 * @param state Dictionary with state which should be set for \c client's user on \c channel.
 * @param channel Name of channel for which \c state should be set.
 * @param client \b PubNub client which should be used to manage presence state. Will use
 *     \c self.client if passed \c nil.
 */
- (void)setState:(NSDictionary *)state onChannel:(NSString *)channel usingClient:(nullable PubNub *)client;


#pragma mark - Objects

/**
 * @brief Try to perform complete Objects scope clean up.
 */
- (void)removeAllObjects;

/**
 * @brief Set random \c metadata for random \c UUIDs.
 *
 * @param objectsCount For how many \c UUID \c metadata should be set.
 * @param client \b PubNub client which should be used to manage \c UUID \c metadata. Will use
 *     \c self.client if passed \c nil.
 *
 * @return List of \c UUIDs \c metadata objects.
 */
- (NSArray<PNUUIDMetadata *> *)setUUIDMetadata:(NSUInteger)objectsCount
                                   usingClient:(nullable PubNub *)client;

/**
 * @brief Set \c metadata for specified \c UUID.
 *
 * @param uuid Identifier which should be used to associate \c metadata with it.
 * @param client \b PubNub client which should be used to manage \c UUID \c metadata. Will use
 *     \c self.client if passed \c nil.
 *
 * @return \c UUID \c metadata object.
 */
- (PNUUIDMetadata *)setMetadataForUUID:(NSString *)uuid usingClient:(nullable PubNub *)client;

/**
 * @brief Set \c metadata using provided \c UUIDs to create identifier and custom data.
 *
 * @param uuids Identifiers which should be used to associate \c metadata with.
 * @param client \b PubNub client which should be used to manage \c UUID \c metadata. Will use
 *     \c self.client if passed \c nil.
 *
 * @return List of \c UUIDs \c metadata objects.
 */
- (NSArray<PNUUIDMetadata *> *)setMetadataForUUIDs:(NSArray<NSString *> *)uuids
                                       usingClient:(nullable PubNub *)client;

/**
 * @brief Ensure that specified number of \c UUIDs has been associated with \c metadata for current
 * publish / subscribe keys.
 *
 * @param count Expected number of \c UUID which has associated \c metadata.
 * @param client \b PubNub client which should be used to audit \c UUID \c metadata. Will use
 *     \c self.client if passed \c nil.
 */
- (void)verifyUUIDMetadataCountShouldEqualTo:(NSUInteger)count usingClient:(nullable PubNub *)client;

/**
 * @brief Create \c membership for each \c UUID entry with every passed \c channel.
 *
 * @param uuids List of identifiers for which \c membership with target channel should be created.
 * @param channels List of channel names to which new members will be added.
 * @param customs List of custom data which should be bound to created \c membership.
 * @param client \b PubNub client which should be used to manage \c memberships. Will use
 *     \c self.client if passed \c nil.
 *
 * @return List of created \c memberships.
 */
- (NSArray<PNMembership *> *)createUUIDsMembership:(NSArray<NSString *> *)uuids
                                        inChannels:(NSArray<NSString *> *)channels
                                       withCustoms:(nullable NSArray<NSDictionary *> *)customs
                                       usingClient:(nullable PubNub *)client;

/**
 * @brief Create \c membership for each \c UUID entry with every passed \c channel.
 *
 * @param uuids List of identifiers for which \c membership with target channel should be created.
 * @param channels List of channel names to which new members will be added.
 * @param customs List of custom data which should be bound to created \c membership.
 * @param shouldIncludeChannelMetadata Whether channel information should be added to
 *     response.
 * @param client \b PubNub client which should be used to manage \c memberships. Will use
 *     \c self.client if passed \c nil.
 *
 * @return List of created \c memberships.
 */
- (NSArray<PNMembership *> *)createUUIDsMembership:(NSArray<NSString *> *)uuids
                                        inChannels:(NSArray<NSString *> *)channels
                                       withCustoms:(nullable NSArray<NSDictionary *> *)customs
                                   channelMetadata:(BOOL)shouldIncludeChannelMetadata
                                       usingClient:(nullable PubNub *)client;

/**
 * @brief Ensure that specified \c UUID has exact number of \c memberships.
 *
 * @param uuid Identifier which should be used with Objects API to audit \c memberships.
 * @param count Expected number of \c UUID's \c memberships.
 * @param client \b PubNub client which should be used to audit \c UUID \c memberships. Will use
 *     \c self.client if passed \c nil.
 */
- (void)verifyUUIDMembershipsCount:(NSString *)uuid
                     shouldEqualTo:(NSUInteger)count
                       usingClient:(nullable PubNub *)client;

/**
 * @brief Remove local cache of \c UUID \c membership objects which has been created during test
 * case run.
 *
 * @param uuid Identifier for which \c membership objects should be removed from local cache.
 * @param channel Name of channel with which \c UUID's \c membership should be removed.
 */
- (void)removeUUID:(NSString *)uuid cachedMembershipForChannel:(NSString *)channel;

/**
 * @brief Remove list of \c UUID's \c memberships which has been created during test case run.
 *
 * @param uuid Identifier for which \c membership objects should be removed.
 * @param memberships List of \c membership objects which should be removed for \c UUID.
 * @param client \b PubNub client which should be used to manage \c UUID \c memberships. Will use
 *     \c self.client if passed \c nil.
 */
- (void)removeUUID:(NSString *)uuid
 membershipObjects:(NSArray<PNMembership *> *)memberships
       usingClient:(nullable PubNub *)client;

/**
 * @brief Remove all \c UUIDs \c membership which has been created during test case run.
 *
 * @param uuids List of identifiers for which \c memberships should be removed.
 * @param client \b PubNub client which should be used to manage \c UUID \c membership. Will use
 *     \c self.client if passed \c nil.
 */
- (void)removeUUIDs:(NSArray<NSString *> *)uuids membershipObjectsUsingClient:(nullable PubNub *)client;

/**
 * @brief Remove all \c UUID \c memberships which has been created during test case run.
 *
 * @param uuid Identifier for which \c memberships should be removed.
 * @param client \b PubNub client which should be used to manage \c UUID \c membership. Will use
 *     \c self.client if passed \c nil.
 */
- (void)removeUUID:(NSString *)uuid membershipObjectsUsingClient:(nullable PubNub *)client;

/**
 * @brief Remove local cache of \c UUID \c metadata which has been created during test case run.
 *
 * @param uuid Identifier which \c metadata should be removed from local cache.
 */
- (void)removeCachedUUIDMetadata:(NSString *)uuid;

/**
 * @brief Delete \c UUID \c metadata objects associated with passed list of identifiers.
 *
 * @param uuids List of identifiers for which associated \c metadata should be removed.
 * @param client \b PubNub client which should be used to manage user objects. Will use
 *     \c self.client if passed \c nil.
 */
- (void)removeUUIDsMetadata:(NSArray<NSString *> *)uuids usingClient:(nullable PubNub *)client;

/**
 * @brief Delete all \c UUIDs \c metadata objects which has been created during test case run.
 *
 * @param client \b PubNub client which should be used to manage \c UUID \c metadata. Will use
 *     \c self.client if passed \c nil.
 */
- (void)removeAllUUIDMetadataUsingClient:(nullable PubNub *)client;

/**
 * @brief Set random \c metadata for random \c channels.
 *
 * @param objectsCount For how many \c channel \c metadata should be set.
 * @param client \b PubNub client which should be used to audit \c channel \c metadata. Will use
 *     \c self.client if passed \c nil.
 *
 * @return List of \c channels \c metadata objects.
 */
- (NSArray<PNChannelMetadata *> *)setChannelsMetadata:(NSUInteger)objectsCount
                                          usingClient:(nullable PubNub *)client;

/**
 * @brief Set \c metadata for specified \c channel.
 *
 * @param channel Name of channel which should be used to associate \c metadata with.
 * @param client \b PubNub client which should be used to audit \c channel \c metadata. Will use
 *     \c self.client if passed \c nil.
 *
 * @return \c Channel \c metadata object.
 */
- (PNChannelMetadata *)setMetadataForChannel:(NSString *)channel usingClient:(nullable PubNub *)client;

/**
 * @brief Set \c metadata using provided \c channels to create identifier and custom data.
 *
 * @param channels Name of channels which should be used to associate \c metadata with.
 * @param client \b PubNub client which should be used to audit \c channel \c metadata. Will use
 *     \c self.client if passed \c nil.
 *
 * @return List of \c channels \c metadata objects.
 */
- (NSArray<PNChannelMetadata *> *)setMetadataForChannels:(NSArray<NSString *> *)channels
                                             usingClient:(nullable PubNub *)client;

/**
 * @brief Ensure that specified number of \c channels has been associated with \c metadata for
 * current publish / subscribe keys.
 *
 * @param count Expected number of \c channels which has associated \c metadata.
 * @param client \b PubNub client which should be used to audit \c channel \c metadata. Will use
 *     \c self.client if passed \c nil.
 */
- (void)verifyChannelsMetadataCountShouldEqualTo:(NSUInteger)count usingClient:(nullable PubNub *)client;

/**
 * @brief Add set of \c UUIDs as members to each of passed \c channel.
 *
 * @param uuids List of identifiers which should be added to each \c channel entry.
 * @param channels List of channel names to which set of \c uuids should be added.
 * @param customs Custom data which should be associated with created membership.
 * @param client \b PubNub client which should be used to manage \c members. Will use \c self.client
 *     if passed \c nil.
 *
 * @return List of created \c member objects.
 */
- (NSArray<PNChannelMember *> *)addMembers:(NSArray<NSString *> *)uuids
                                toChannels:(NSArray<NSString *> *)channels
                               withCustoms:(nullable NSArray<NSDictionary *> *)customs
                               usingClient:(nullable PubNub *)client;

/**
 * @brief Add set of \c UUIDs as members to each of passed \c channel.
 *
 * @param uuids List of identifiers which should be added to each \c channel entry.
 * @param channels List of channel names to which set of \c uuids should be added.
 * @param customs Custom data which should be associated with created membership.
 * @param shouldIncludeUUIDMetadata Whether \c channel \c metadata information should be added to
 *     response.
 * @param client \b PubNub client which should be used to manage \c members. Will use \c self.client
 *     if passed \c nil.
 *
 * @return List of created \c member objects.
 */
- (NSArray<PNChannelMember *> *)addMembers:(NSArray<NSString *> *)uuids
                                toChannels:(NSArray<NSString *> *)channels
                               withCustoms:(nullable NSArray<NSDictionary *> *)customs
                              uuidMetadata:(BOOL)shouldIncludeUUIDMetadata
                               usingClient:(nullable PubNub *)client;

/**
 * @brief Ensure that specified \c channel has exact number of \c members.
 *
 * @param channel Name of channel which should be used with Objects API to audit \c members.
 * @param count Expected number of \c channel \c members.
 * @param client \b PubNub client which should be used to audit \c channel \c members. Will use
 *     \c self.client if passed \c nil.
 */
- (void)verifyChannelMembersCount:(NSString *)channel
                    shouldEqualTo:(NSUInteger)count
                      usingClient:(nullable PubNub *)client;

/**
 * @brief Remove local cache of \c channel \c members which has been created during test case run.
 *
 * @param channel Name of channel for which \c member objects should be removed from local cache.
 * @param uuid Identifier which should be removed from \c channel \c members list.
 */
- (void)removeChannel:(NSString *)channel cachedMemberForUUID:(NSString *)uuid;

/**
 * @brief Remove all \c channels \c members which has been created during test case run.
 *
 * @param channels List of channel names for which \c member objects should be removed.
 * @param client \b PubNub client which should be used to manage \c members. Will use \c self.client
 *     if passed \c nil.
 */
- (void)removeChannels:(NSArray<NSString *> *)channels membersObjectsUsingClient:(nullable PubNub *)client;

/**
 * @brief Remove list of \c channel \c member objects which has been created during test case run.
 *
 * @param channel Name of channel for which \c member objects should be removed.
 * @param members List of member objects which should be removed from \c channel.
 * @param client \b PubNub client which should be used to manage \c members. Will use \c self.client
 *     if passed \c nil.
 */
- (void)removeChannel:(NSString *)channel
        memberObjects:(NSArray<PNChannelMember *> *)members
          usingClient:(nullable PubNub *)client;

/**
 * @brief Remove all \c channel \c members which has been created during test case run.
 *
 * @param channel Name of channel for which \c members should be removed.
 * @param client \b PubNub client which should be used to manage \c members. Will use \c self.client
 *     if passed \c nil.
 */
- (void)removeChannel:(NSString *)channel membersObjectsUsingClient:(nullable PubNub *)client;

/**
 * @brief Remove local cache of \c channel \c metadata which has been created during test case run.
 *
 * @param channels Name of channel which \c metadata should be removed from local cache.
 */
- (void)removeCachedChannelsMetadata:(NSString *)channels;

/**
 * @brief Delete \c metadata objects associated with passed \c channels.
 *
 * @param channels List of channel names for which associated \c metadata should be removed.
 * @param client \b PubNub client which should be used to manage \c channel \c metadata. Will use
 *     \c self.client if passed \c nil.
 */
- (void)removeChannelsMetadata:(NSArray<NSString *> *)channels usingClient:(nullable PubNub *)client;

/**
 * @brief Delete all \c channel \c metadata objects which has been created during test case run.
 *
 * @param client \b PubNub client which should be used to manage \c channel \c metadata. Will use
 *     \c self.client if passed \c nil.
 */
- (void)removeChannelsMetadataUsingClient:(nullable PubNub *)client;


#pragma mark - Mocking

/**
 * @brief Check whether passed \c object has been mocked before or not.
 *
 * @param object Object which should be checked on whether it has been mocked or not.
 *
 * @return Whether mocked \c object passed or not.
 */
- (BOOL)isObjectMocked:(id)object;

/**
 * @brief Create mock object for class.
 *
 * @param object Reference on object for which mock should be created (class or it's instance).
 *
 * @return Object mock.
 */
- (id)mockForObject:(id)object;


#pragma mark - Listeners

/**
 * @brief Add block which will be called for each client status change.
 *
 * @param client \b PubNub client for which state should be tracked.
 * @param handler Block which should be called each client's status change.
 */
- (void)addStatusHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveStatusHandler)handler;

/**
 * @brief Add block which will be called for each received message.
 *
 * @param client \b PubNub client for which messages should be tracked.
 * @param handler Block which should be called each received message.
 */
- (void)addMessageHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveMessageHandler)handler;

/**
 * @brief Add block which will be called for each received signal.
 *
 * @param client \b PubNub client for which signal should be tracked.
 * @param handler Block which should be called each received signal.
 */
- (void)addSignalHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveSignalHandler)handler;

/**
 * @brief Add block which will be called for each received presence change.
 *
 * @param client \b PubNub client for which presence change should be tracked.
 * @param handler Block which should be called each presence change.
 */
- (void)addPresenceHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceivePresenceEventHandler)handler;

/**
 * @brief Add block which will be called for each received \c object event.
 *
 * @param client \b PubNub client for which \c object events should be tracked.
 * @param handler Block which should be called each \c user event.
 */
- (void)addObjectHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveObjectEventHandler)handler;

/**
 * @brief Add block which will be called for each received \c action event.
 *
 * @param client \b PubNub client for which \c action events should be tracked.
 * @param handler Block which should be called each \c action event.
 */
- (void)addActionHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveMessageActionHandler)handler;

/**
 * @brief Remove all handler for specified \c client.
 *
 * @param client \b PubNub client for which listeners should be removed.
 */
- (void)removeAllHandlersForClient:(PubNub *)client;


#pragma mark - Handlers

/**
 * @brief Wait for recorded (OCMExpect) stub to be called within specified interval. Default
 * interval for success test operation will be used.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
                afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for recorded (OCMExpect) stub to be called within specified interval.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
            withinInterval:(NSTimeInterval)interval
                afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c codeBlock.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Expect recorded (OCMExpect) stub not to be called within specified interval. Default
 * interval for failed test operation will be used.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
                   afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Expect recorded (OCMExpect) stub not to be called within specified interval.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
               withinInterval:(NSTimeInterval)interval
                   afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for code from \c codeBlock to not call completion handler in specified amount of
 * time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 */
- (void)waitToNotCompleteIn:(NSTimeInterval)interval
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock;

/**
 * @brief Wait for code from \c codeBlock to not call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c codeBlock.
 */
- (void)waitToNotCompleteIn:(NSTimeInterval)interval
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock
                 afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Pause test execution to wait for asynchronous task to complete.
 *
 * @discussion Useful in case of asynchronous block execution and timer based events. This method
 * allow to pause test and wait for specified number of \c seconds.
 *
 * @param taskName Name of task for which we are waiting to complete.
 * @param seconds Number of seconds for which test execution will be postponed to give tested code
 *   time to perform asynchronous actions.
 *
 * @return Reference on expectation object which can be used for fulfilment.
 */
- (XCTestExpectation *)waitTask:(NSString *)taskName completionFor:(NSTimeInterval)seconds;


#pragma mark - Helpers

/**
 * @brief If tests has modified cassette it can't be used during cron test tasks which use real
 * service response and should pass w/o actual code run.
 *
 * @return \c YES in case if test should be skipped.
 */
- (BOOL)shouldSkipTestWithManuallyModifiedMockedResponse;

/**
 * @brief Generate randomized versions of provided values which will persist during test case.
 *
 * @param values List of 'normal' values which should be randomized.
 *
 * @return List of values with randomized portions.
 */
- (NSArray<NSString *> *)randomizedValuesWithValues:(NSArray<NSString *> *)values;

/**
 * @brief Generate randomized versions of provided channel group names which will persist during
 * test case.
 *
 * @param channelGroups List of 'normal' channel group names which should be randomized.
 *
 * @return List of channel groups with randomized portions.
 */
- (NSArray<NSString *> *)channelGroupsWithNames:(NSArray<NSString *> *)channelGroups;

/**
 * @brief Generate randomized version of provided channel group name which will persist during test
 * case.
 *
 * @param channelGroup 'Normal' channel group name which should be randomized.
 *
 * @return Channel group with randomized portion.
 */
- (NSString *)channelGroupWithName:(NSString *)channelGroup;

/**
 * @brief Generate randomized versions of provided channel names which will persist during test
 * case.
 *
 * @param channels List of 'normal' channel names which should be randomized.
 *
 * @return List of channels with randomized portions.
 */
- (NSArray<NSString *> *)channelsWithNames:(NSArray<NSString *> *)channels;

/**
 * @brief Generate randomized version of provided channel name which will persist during test case.
 *
 * @param channel 'Normal' channel name which should be randomized.
 *
 * @return Channel with randomized portion.
 */
- (NSString *)channelWithName:(NSString *)channel;

/**
 * @brief Generate randomized version of provided user identifier which will persist during test
 * case.
 *
 * @param user 'Normal' user identifier which should be randomized.
 *
 * @return User identifier with randomized portion.
 */
- (NSString *)uuidForUser:(NSString *)user;

/**
 * @brief Generate randomized version of provided user authentication token which will persist
 * during test case.
 *
 * @param auth 'Normal' user authentication which should be randomized.
 *
 * @return User authentication with randomized portion.
 */
- (NSString *)authForUser:(NSString *)auth;

/**
 * @brief Retrieve object from invocation at specified index and store it till test case completion.
 *
 * @param invocation Invocation which passed by OCMock from which object should be retrieved.
 * @param index Index of parameter in method signature from which value should be retrieved (offset
 *     for self and selector applied internally).
 *
 * @return Object instance passed to method under specified index.
 */
- (id)objectForInvocation:(NSInvocation *)invocation argumentAtIndex:(NSUInteger)index;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
