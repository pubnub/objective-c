/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+SubscribePrivate.h"
#import "PubNub+PresencePrivate.h"
#import "PNObjectEventListener.h"
#import "PubNub+StatePrivate.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>
#import "PNErrorCodes.h"
#import "PNResponse.h"
#import "PNHelpers.h"
#import "PNResult.h"
#import "PNAES.h"
#import "PNLog.h"


#pragma mark Static

/**
 @brief  Reference on suffix which is used to mark channel as presence channel.
 
 @since 4.0
 */
static NSString * const kPubNubPresenceChannelNameSuffix = @"-pnpres";

/**
@brief  Reference on time which should be used by retry timer as interval between subscription
        retry attempts.

@since 4.0
*/
static NSTimeInterval const kPubNubSubscriptionRetryInterval = 1.0f;

/**
 @brief  Pointer keys which is used to store associated object data.
 
 @since 4.0
 */
static const void *kPubNubSubscriberSynchronizationQueue = &kPubNubSubscriberSynchronizationQueue;
static const void *kPubNubSubscribeChannelsList = &kPubNubSubscribeChannelsList;
static const void *kPubNubSubscribeChannelGroupsList = &kPubNubSubscribeChannelGroupsList;
static const void *kPubNubSubscribePresenceChannelsList = &kPubNubSubscribePresenceChannelsList;
static const void *kPubNubSubscribeCurrentTimeToken = &kPubNubSubscribeCurrentTimeToken;
static const void *kPubNubSubscribePreviousTimeToken = &kPubNubSubscribePreviousTimeToken;
static const void *kPubNubSubscribeCallCount = &kPubNubSubscribeCallCount;
static const void *kPubNubSubscribeRetryTimer = &kPubNubSubscribeRetryTimer;
static const void *kPubNubObjectEventListener = &kPubNubObjectEventListener;
static const void *kPubNubSubscriberState = &kPubNubSubscriberState;

/**
 Stores reference on index under which events list is stored.
 */
static NSUInteger const kPNEventsListElementIndex = 0;

/**
 Stores reference on time token element index in response for events.
 */
static NSUInteger const kPNEventTimeTokenElement = 1;

/**
 Stores reference on index under which channels list is stored.
 */
static NSUInteger const kPNEventChannelsElementIndex = 2;

/**
 @brief Stores reference on index under which channels detalization is stored
 
 @discussion In case if under \c kPNEventChannelsElementIndex stored list of channel groups, under 
             this index will be stored list of actual channels from channel group at which event
             fired.
 
 @since 3.7.0
 */
static NSUInteger const kPNEventChannelsDetailsElementIndex = 3;


#pragma mark - Structures

typedef NS_OPTIONS(NSUInteger, PNSubscriberState) {
    
    /**
     @brief  State set at the moment when client received response with 403 status code for subcribe
             request.
     
     @since 4.0
     */
    PNAccessRightsErrorSubscriberState,
    
    /**
     @brief  State set at the moment when client received response with 200 status code for subcribe
             request with TT 0.
     
     @since 4.0
     */
    PNConnectedSubscriberState,
    
    /**
     @brief  State set at the moment when client received response on 'leave' request and not 
             subscribed to any remote data objects live feed.
     
     @since 4.0
     */
    PNDisconnectedSubscriberState,
    
    /**
     @brief  State set at the moment when client lost connection or experienced other issues with
             communication etsablished with \b PubNub service.
     
     @since 4.0
     */
    PNDisconnectedUnexpectedlySubscriberState
};


#pragma mark - Protected interface declaration

@interface PubNub (SubscribeProtected)


#pragma mark - Properties

/**
 @brief  Queue which is used to synchronize access to list of channels, groups and presence channels
         to make sure what data won't be accessed from few threads/queues at the same time.
 
 @return Reference on queue which should be used to synchronize access to channel lists.
 
 @since 4.0
 */
- (dispatch_queue_t)subscriberAccessQueue;


#pragma mark - Subscription information modification

/**
 @brief      Retrieve current subscriber state.
 @discussion By default client not connected to any remote data objects live feed.
 
 @return One of \b PNSubscriberState enum field.
 
 @since 4.0
 */
- (PNSubscriberState)subscriberState;

/**
 @brief  Update current subscriber state.
 
 @param state New state from \b PNSubscriberState enum fields which describe current subscriber 
              state.
 
 @since 4.0
 */
- (void)setSubscriberState:(PNSubscriberState)state;

/**
 @brief  Retrieve stored current subscription time token information.

 @return Cached current time token information or \b 0 if requested for first time.

 @since 4.0
 */
- (NSNumber *)currentTimeToken;

/**
 @brief  Update current subscription time token information in cache.
 
 @param timeToken Reference on current time token which should replace the one stored in cache.
 
 @since 4.0
 */
- (void)setCurrentTimeToken:(NSNumber *)timeToken;

/**
 @brief  Retrieve stored previous subscription time token information.

 @return Cached previous time token information or \b 0 if requested for first time.

 @since 4.0
 */
- (NSNumber *)previousTimeToken;

/**
 @brief  Update previous subscription time token information in cache.
 
 @param timeToken Reference on previous time token which should replace the one stored in cache.
 
 @since 4.0
 */
- (void)setPreviousTimeToken:(NSNumber *)timeToken;

/**
 @brief      Retrieve how many times request has been called.
 @discussion It is possible what during single subscription request execution subscribe can be 
             called few times. At every successful processing value decreased.
             In case if number of attempts doesn't equal to numbers during method call, client won't
             try continue subscription cycle and just will pass pending requests.
 
 @return How many times subscribe API has been called.
 
 @since 4.0
 */
- (NSInteger)numberOfAPICalls;

/**
 @brief  Update how many times request has been called.
 
 @param numberOfCalls Updates call counter.
 
 @since 4.0
 */
- (void)setNumberOfAPICalls:(NSInteger)numberOfCalls;

/**
 @brief      Retrieve list of all data objects to which client subscribed at this moment.
 @discussion Retrieve list of channels, groups and presence channels which currently used for 
             subscription.
 
 @return Full data object names list.
 
 @since 4.0
 */
- (NSArray *)allObjects;

/**
 @brief  Fetch list of channels on which client subscribed now w/o aware of current client state (
         connected/disconnected).

 @return \a NSArray of channel names on which client subscribed at this moment.

 @since 4.0
 */
- (NSArray *)channelsInternal;

/**
 @brief      Mutable set of channel names on which client subscribed at this moment.
 @discussion In case if this is first time when channels list has been requested it will create
             associated with \b PubNub client storage where set will be stored.
 
 @return Mutable set of channel names.
 
 @since 4.0
 */
- (NSMutableSet *)mutableChannels;

/**
 @brief  Add new channel names on which client subscribed at this moment.
 
 @param channels List of channel names which should be added to complete channels list to which
                 client subscribed before.
 
 @since 4.0
 */
- (void)addChannels:(NSArray *)channels;

/**
 @brief  Remove channels from which client unsubscribed from this moment.
 
 @param channels List of channel names from which client shouldn't receive any updates anymore and
                 removed from complete list of channels.
 
 @since 4.0
 */
- (void)removeChannels:(NSArray *)channels;

/**
 @brief  Fetch list of channels group on which client subscribed now w/o aware of current client
         state (connected/disconnected).

 @return \a NSArray of channel group names on which client subscribed at this moment.

 @since 4.0
 */
- (NSArray *)groupsInternal;

/**
 @brief      Mutable set of channel group names on which client subscribed at this moment.
 @discussion In case if this is first time when channel groups list has been requested it will 
             create associated with \b PubNub client storage where set will be stored.
 
 @return Mutable set of channel group names.
 
 @since 4.0
 */
- (NSMutableSet *)mutableGroups;

/**
 @brief  Add new channel group names on which client subscribed at this moment.
 
 @param groups List of channel group names which should be added to complete groups list to which
               client subscribed before.
 
 @since 4.0
 */
- (void)addGroups:(NSArray *)groups;

/**
 @brief  Remove channel groups from which client unsubscribed from this moment.
 
 @param groups List of channel group names from which client shouldn't receive any updates anymore 
               and removed from groups list.
 
 @since 4.0
 */
- (void)removeGroups:(NSArray *)groups;

/**
 @brief  Fetch list of channels for which presence events observation has been enabled w/o aware of
         current client state (connected/disconnected).

 @return \a NSArray of presence channel names on which client subscribed at this moment.

 @since 4.0
 */
- (NSArray *)presenceChannelsInternal;

/**
 @brief      Mutable set of presence channel names on which client subscribed at this moment.
 @discussion In case if this is first time when presence channels list has been requested it will
             create associated with \b PubNub client storage where set will be stored.
 
 @return Mutable set of presence enabled channel names.
 
 @since 4.0
 */
- (NSMutableSet *)mutablePresenceChannels;

/**
 @brief  Add new presence channel names to which client subscribed at this moment.
 
 @param channels List of presence channel names which should be added to complete presence channels
                 list to which client subscribed before.
 
 @since 4.0
 */
- (void)addPresenceChannels:(NSArray *)channels;

/**
 @brief  Remove presence channels from which client unsubscribed from this moment.
 
 @param channels List of presence channel names from which client shouldn't receive any updates 
                 anymore and removed from complete list of channels.
 
 @since 4.0
 */
- (void)removePresenceChannels:(NSArray *)channels;

/**
 @brief  Associated storage manipulation helper to get access to mutable set version for: channes,
         groups and presence enabled channels.
 
 @param objectTypeKey Reference on key under which data should/ stored in associated storage.
 
 @return Reference on mutable set for required type of data.
 
 @since 4.0
 */
- (NSMutableSet *)mutableSetFor:(const void *)objectTypeKey;

/**
 @brief  Convert provided list of \c names to names which correspond to presence objects naming 
         conventions.
 
 @param names List of names which should be converted.
 
 @return List of names which correspond to requirements of presence \b PubNub service.
 
 @since 4.0
 */
- (NSArray *)presenceChannelsFrom:(NSArray *)names;

/**
 @brief  Filter provided mixed list of channels and presence channels to list w/o presence channels
         in it.
 
 @param names List of names which should be filtered.
 
 @return Filtered channels list.
 
 @since 4.0
 */
- (NSArray *)channelsWithOutPresenceFrom:(NSArray *)names;


#pragma mark - Listeners information

/**
 @brief  Stores list of listeners which would like to be notified when new message arrive from
         remote data feed objects on which client subscrubed at this moment.
 
 @return Hash table with list of new message listeners.
 
 @since 4.0
 */
- (NSHashTable *)messageListeners;

/**
 @brief  Stores list of listeners which would like to be notified when new presence event arrive 
         from remote data feed objects on which client subscrubed at this moment.
 
 @return Hash table with list of presence event listeners.
 
 @since 4.0
 */
- (NSHashTable *)presenceEventListeners;

/**
 @brief  Stores list of listeners which would like to be notified when on subscription state 
         changes (connection, access rights error, disconnection and unexpected disconnection).
 
 @return Hash table with list of state change listeners.
 
 @since 4.0
 */
- (NSHashTable *)stateListeners;

/**
 @brief  Store reference on event listeners which should be notified about new messages and 
         presence events along with subscription state change.
 
 @return Map table with list of listeners.
 
 @since 4.0
 */
- (NSMapTable *)listeners;


#pragma mark - Subscription

/**
 @brief  Continue subscription cycle using \c currentTimeToken value and channels, stored in cache.

 @since 4.0
 */
- (void)continueSubscriptionCycleIfRequired;

/**
 @brief  Final designated subscription method before issue subscribe request to \b PubNub service.

 @param shouldModifyObjectsList Whether request is part of channel list modification sequence (by
                                subscribe/unsubscribe API) or not.
 @param issuePresenceEvent      Whether presence events should be generated or not (whether
                                subscriber should reset current time token to \b 0 or not).
 @param channels                List of channels which has been merged with cached (previously
                                subscribed) to be used in subscription requests. Or list of channels
                                which should be added to the objects list.
 @param groups                  List of channel groups which has been merged with cached (previously
                                subscribed) to be used in subscription requests. Or list of channel
                                groups which should be added to the objects list.
 @param presence                List of presence channels which has been merged with cached
                                (previously subscribed) to be used in subscription requests. Or list
                                of presence channels which should be added to the objects list.
 @param state                   Reference on client state information which should be bound to the
                                user on remote data objects.
 @param block                   Subscription process completion block which pass only one
                                argument - request processing status to report about how data
                                pushing was successful or not.
 
 @since 4.0
 */
- (void)subscribeWithObjectsListModification:(BOOL)shouldModifyObjectsList
                                    presence:(BOOL)issuePresenceEvent toChannels:(NSArray *)channels
                                      groups:(NSArray *)groups andPresence:(NSArray *)presence
                             withClientState:(NSDictionary *)state
                               andCompletion:(PNStatusBlock)block;

/**
 @brief      Launch subscription retry timer.
 @discussion Launch timer with default 1 second interval after each subscribe attempt. In most of
             cases timer used to retry subscription after PubNub Access Manager denial because of
             client doesn't has enough rights.

 @since 4.0
 */
- (void)startRetryTimer;

/**
 @brief      Terminate previously launched subscription retry counter.
 @discussion In case if another subscribe request from user client better to stop retry timer to
             eliminate race of conditions.

 @since 4.0
 */
- (void)stopRetryTimer;


#pragma mark - Unsubscriptions

/**
 @brief      Send presence \c leave request for specified list of remote data objects.
 @discussion Presence request will trigger presence notification events sent to all other
             subscribers on remote data objects live feeds.

 @param channels List of channels which should be removed from cached list.
 @param groups   List of channel groups which should be removed from cached list.
 @param presence List of presence channels which should be removed from cached list.
 @param block    Leave process completion block which pass only one argument - request processing 
                 status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)leaveChannels:(NSArray *)channels groups:(NSArray *)groups andPresence:(NSArray *)presence
       withCompletion:(PNStatusBlock)block;


#pragma mark - Handlers

/**
 @brief  Subscription results handling and pre-processing before notify to completion blocks (if 
         required at all).
 
@param request   Reference on base request which is used for communication with \b PubNub service.
                 Object also contains request processing results.
 @param channels List of channels which has been used during previous subscribe attempt.
 @param groups   List of channel groups which has been used during previous subscribe attempt.
 @param presence List of presence channels which has been used during previous subscribe attempt.
 @param state    Final client state information which has been used during subscription process.
 @param block    Subscription process completion block which pass only one argument - request 
                 processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)handleSubscribeRequest:(PNRequest *)request onChannels:(NSArray *)channels
                        groups:(NSArray *)groups presence:(NSArray *)presence
                     withState:(NSDictionary *)state andCompletion:(PNStatusBlock)block;

/**
 @brief  Process message which just has been received from \b PubNub service through live feed on 
         which client subscribed at this moment.
 
 @param data      Reference on result data which hold information about request on which this 
                  response has been received and message itself.
 @param listeners List of objects which should be notified about new message on one of remote data
                  object live feeds.
 
 @since 4.0
 */
- (void)handleNewMessage:(PNResult *)data by:(NSArray *)listeners;

/**
 @brief  Process presence event which just has been receoved from \b PubNub service through presence
         live feeds on which client subscribed at this moment.
 
 @param data      Reference on result data which hold information about request on which this 
                  response has been received and presence event itself.
 @param listeners List of objects which should be notified about new message on one of remote data
                  object live feeds.
 
 @since 4.0
 */
- (void)handleNewPresenceEvent:(PNResult *)data by:(NSArray *)listeners;

/**
 @brief  Notify client state change listeners about new client subscriber state.
 
 @param status Reference on original status object which describe request processing state.
 @param state  One of \b PNSubscriberState enum fields which should be delivered to listeners.
 
 @since 4.0
 */
- (void)handleSubscriberStatus:(PNStatus *)status change:(PNSubscriberState)state;

/**
 @brief  Unsubscription results handling and pre-processing before notify to completion blocks (if
         required at all).
 
 @param request  Reference on base request which is used for communication with \b PubNub service.
                 Object also contains request processing results.
 @param channels List of channels which has been used during unsubscribe attempt.
 @param groups   List of channel groups which has been used during unsubscribe attempt.
 @param presence List of presence channels which has been used during unsubscribe attempt.
 @param block    Unsubscription process completion block which pass only one argument - request
                 processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)handleUnsubscribeRequest:(PNRequest *)request fromChannels:(NSArray *)channels
                          groups:(NSArray *)groups presence:(NSArray *)presence
                  withCompletion:(PNStatusBlock)block;


#pragma mark - Processing

/**
 @brief      Add additional information about current subscriber state to the status.
 @discussion Additional information can be used for further status information processing by user.

 @param status Reference on status object which should be populated with additional data.

 @since 4.0
 */
- (void)addSubscriberStateInformationTo:(PNStatus *)status;

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'subscribe'
         API group.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handeled by 'subscribe' API group.
 
 @since 4.0
 */
- (NSDictionary *)processedSubscribeResponse:(id)response;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (Subscribe)


#pragma mark - Properties

- (dispatch_queue_t)subscriberAccessQueue {
    
    static OSSpinLock _subscriberAccessQueueSpinLock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _subscriberAccessQueueSpinLock = OS_SPINLOCK_INIT;
    });
    OSSpinLockLock(&_subscriberAccessQueueSpinLock);
    dispatch_queue_t queue = objc_getAssociatedObject(self, kPubNubSubscriberSynchronizationQueue);
    if (!queue) {
        
        queue = dispatch_queue_create("com.pubnub.subscription.channels", DISPATCH_QUEUE_CONCURRENT);
        objc_setAssociatedObject(self, kPubNubSubscriberSynchronizationQueue, queue,
                                 OBJC_ASSOCIATION_RETAIN);
    }
    OSSpinLockUnlock(&_subscriberAccessQueueSpinLock);
    
    return queue;
}


#pragma mark - Subscription state information

- (PNSubscriberState)subscriberState {
    
    __block NSNumber *subscriberState = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        subscriberState = objc_getAssociatedObject(self, kPubNubSubscriberState);
    });
    if (!subscriberState) {
        
        subscriberState = @(PNDisconnectedSubscriberState);
        [self setSubscriberState:PNDisconnectedSubscriberState];
    }
    
    return (PNSubscriberState)[subscriberState integerValue];
}

- (void)setSubscriberState:(PNSubscriberState)state {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        objc_setAssociatedObject(strongSelf, kPubNubSubscriberState, @(state),
                                 OBJC_ASSOCIATION_RETAIN);
    });
}

- (NSNumber *)currentTimeToken {
    
    __block NSNumber *timeToken = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        timeToken = objc_getAssociatedObject(self, kPubNubSubscribeCurrentTimeToken);
    });
    if (!timeToken) {
        
        timeToken = @(0);
        [self setCurrentTimeToken:timeToken];
    }
    
    return timeToken;
}

- (void)setCurrentTimeToken:(NSNumber *)timeToken {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof(self) strongSelf = weakSelf;
        objc_setAssociatedObject(strongSelf, kPubNubSubscribeCurrentTimeToken, timeToken,
                                 OBJC_ASSOCIATION_RETAIN);
    });
}

- (NSNumber *)previousTimeToken {
    
    __block NSNumber *timeToken = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        timeToken = objc_getAssociatedObject(self, kPubNubSubscribePreviousTimeToken);
    });
    if (!timeToken) {
        
        timeToken = @(0);
        [self setPreviousTimeToken:timeToken];
    }
    
    return timeToken;
}

- (void)setPreviousTimeToken:(NSNumber *)timeToken {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof(self) strongSelf = weakSelf;
        objc_setAssociatedObject(strongSelf, kPubNubSubscribePreviousTimeToken, timeToken,
                                 OBJC_ASSOCIATION_RETAIN);
    });
}

- (NSInteger)numberOfAPICalls {

    __block NSNumber *numberOfCalls = nil;
    dispatch_sync([self subscriberAccessQueue], ^{

        numberOfCalls = objc_getAssociatedObject(self, kPubNubSubscribeCallCount);
    });
    if (!numberOfCalls) {
        
        numberOfCalls = @(0);
        [self setNumberOfAPICalls:[numberOfCalls integerValue]];
    }
    
    return [numberOfCalls integerValue];
}

- (void)setNumberOfAPICalls:(NSInteger)numberOfCalls {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof(self) strongSelf = weakSelf;
        objc_setAssociatedObject(strongSelf, kPubNubSubscribeCallCount, @(numberOfCalls),
                                 OBJC_ASSOCIATION_RETAIN);
    });
}

- (NSArray *)allObjects {

    return [[[self channelsInternal] arrayByAddingObjectsFromArray:[self groupsInternal]]
            arrayByAddingObjectsFromArray:[self presenceChannelsInternal]];
}

- (NSArray *)channels {
    
    __block NSArray *channels = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        if (self.recentClientStatus == PNConnectedCategory) {
            
            channels = [[[self mutableChannels] allObjects] copy];
        }
        else {
            
            channels = @[];
        }
    });
    
    return channels;
}

- (NSArray *)channelsInternal {

    __block NSArray *channels = nil;
    dispatch_sync([self subscriberAccessQueue], ^{

        channels = [[[self mutableChannels] allObjects] copy];
    });

    return channels;
}

- (NSMutableSet *)mutableChannels {
    
    return [self mutableSetFor:kPubNubSubscribeChannelsList];
}

- (void)addChannels:(NSArray *)channels {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        [[strongSelf mutableChannels] addObjectsFromArray:channels];
    });
}

- (void)removeChannels:(NSArray *)channels {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof(self) strongSelf = weakSelf;
        [[strongSelf mutableChannels] minusSet:[NSSet setWithArray:channels]];
    });
}

- (NSArray *)channelGroups {
    
    __block NSArray *groups = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        if (self.recentClientStatus == PNConnectedCategory) {
            
            groups = [[[self mutableGroups] allObjects] copy];
        }
        else {
            
            groups = @[];
        }
    });
    
    return groups;
}

- (NSArray *)groupsInternal {

    __block NSArray *groups = nil;
    dispatch_sync([self subscriberAccessQueue], ^{

        groups = [[[self mutableGroups] allObjects] copy];
    });

    return groups;
}

- (NSMutableSet *)mutableGroups {
    
    return [self mutableSetFor:kPubNubSubscribeChannelGroupsList];
}

- (void)addGroups:(NSArray *)groups {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof(self) strongSelf = weakSelf;
        [[strongSelf mutableGroups] addObjectsFromArray:groups];
    });
}

- (void)removeGroups:(NSArray *)groups {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof(self) strongSelf = weakSelf;
        [[strongSelf mutableGroups] minusSet:[NSSet setWithArray:groups]];
    });
}

- (NSArray *)presenceChannels {
    
    __block NSArray *channels = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        if (self.recentClientStatus == PNConnectedCategory) {
        
            channels = [[[self mutablePresenceChannels] allObjects] copy];
        }
        else {
            
            channels = @[];
        }
    });
    
    return channels;
}

- (NSArray *)presenceChannelsInternal {

    __block NSArray *channels = nil;
    dispatch_sync([self subscriberAccessQueue], ^{

        channels = [[[self mutablePresenceChannels] allObjects] copy];
    });

    return channels;
}

- (NSMutableSet *)mutablePresenceChannels {
    
    return [self mutableSetFor:kPubNubSubscribePresenceChannelsList];
}

- (void)addPresenceChannels:(NSArray *)channels {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof(self) strongSelf = weakSelf;
        [[strongSelf mutablePresenceChannels] addObjectsFromArray:channels];
    });
}

- (void)removePresenceChannels:(NSArray *)channels {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof(self) strongSelf = weakSelf;
        [[strongSelf mutablePresenceChannels] minusSet:[NSSet setWithArray:channels]];
    });
}

- (NSMutableSet *)mutableSetFor:(const void *)objectTypeKey {
    
    NSMutableSet *channels = objc_getAssociatedObject(self, objectTypeKey);
    if (!channels) {
        
        channels = [NSMutableSet new];
        objc_setAssociatedObject(self, objectTypeKey, channels, OBJC_ASSOCIATION_RETAIN);
    }
    
    return channels;
}

- (NSArray *)presenceChannelsFrom:(NSArray *)names {
    
    NSMutableSet *presenceNames = [[NSMutableSet alloc] initWithCapacity:[names count]];
    for (NSString *name in names) {
        
        NSString *targetName = name;
        if (![name hasPrefix:kPubNubPresenceChannelNameSuffix]) {
            
            targetName = [name stringByAppendingString:kPubNubPresenceChannelNameSuffix];
        }
        [presenceNames addObject:targetName];
    }
    
    return [[presenceNames allObjects] copy];
}

- (NSArray *)channelsWithOutPresenceFrom:(NSArray *)names {
    
    NSMutableSet *filteredNames = [[NSMutableSet alloc] initWithCapacity:[names count]];
    for (NSString *name in names) {
        
        if (![name hasPrefix:kPubNubPresenceChannelNameSuffix]) {
            
            [filteredNames addObject:name];
        }
    }
    
    return [[filteredNames allObjects] copy];
}

- (BOOL)isSubscribedOn:(NSString *)name {
    
    __block BOOL isSubscribedOn = NO;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        isSubscribedOn = ([[self mutableChannels] containsObject:name] ||
                          [[self mutablePresenceChannels] containsObject:name] ||
                          [[self mutableGroups] containsObject:name]);
    });
    
    return isSubscribedOn;
}

#pragma mark - Listeners information

- (NSHashTable *)messageListeners {
    
    __block NSHashTable *listeners = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        listeners = [[self listeners] objectForKey:@"message"];
        
    });
    
    return listeners;
}

- (NSHashTable *)presenceEventListeners {
    
    __block NSHashTable *listeners = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        listeners = [[self listeners] objectForKey:@"presence"];
        
    });
    
    return listeners;
}

- (NSHashTable *)stateListeners {
    
    __block NSHashTable *listeners = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        listeners = [[self listeners] objectForKey:@"state"];
        
    });
    
    return listeners;
}

- (NSMapTable *)listeners {
    
    NSMapTable *listeners = objc_getAssociatedObject(self, kPubNubObjectEventListener);
    if (!listeners) {
        
        listeners = [[NSMapTable strongToStrongObjectsMapTable] copy];
        [listeners setObject:[[NSHashTable weakObjectsHashTable] copy] forKey:@"message"];
        [listeners setObject:[[NSHashTable weakObjectsHashTable] copy] forKey:@"presence"];
        [listeners setObject:[[NSHashTable weakObjectsHashTable] copy] forKey:@"state"];
        objc_setAssociatedObject(self, kPubNubObjectEventListener, listeners,
                                 OBJC_ASSOCIATION_RETAIN);
    }
    
    return listeners;
}


#pragma mark - Listeners

- (void)addListeners:(NSArray *)listeners {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        for (id listener in listeners) {
            
            // Ensure what provided listener conforms to required protocol.
            if ([listener conformsToProtocol:@protocol(PNObjectEventListener)]) {
                
                if ([listener respondsToSelector:@selector(client:didReceiveMessage:withStatus:)]) {
                    
                    [(NSHashTable *)[[strongSelf listeners] objectForKey:@"message"] addObject:listener];
                }
                if ([listener respondsToSelector:@selector(client:didReceivePresenceEvent:)]) {
                    
                    [(NSHashTable *)[[strongSelf listeners] objectForKey:@"presence"] addObject:listener];
                }
                
                if ([listener respondsToSelector:@selector(client:didReceiveStatus:)]) {
                    
                    [(NSHashTable *)[[strongSelf listeners] objectForKey:@"state"] addObject:listener];
                }
            }
            else {
                
                DDLogWarn(@"<PubNub> %@ can't be used as object event listener because it "
                           "doesn't conform to PNObjectEventListener protocol", listener);
            }
        }
    });
}

- (void)removeListeners:(NSArray *)listeners {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        for (id listener in listeners) {
            
            [(NSHashTable *)[[strongSelf listeners] objectForKey:@"message"] removeObject:listener];
            [(NSHashTable *)[[strongSelf listeners] objectForKey:@"presence"] removeObject:listener];
            [(NSHashTable *)[[strongSelf listeners] objectForKey:@"state"] removeObject:listener];
        }
    });
}


#pragma mark - Subscription

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
              andCompletion:(PNStatusBlock)block {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence clientState:nil
                andCompletion:block];
}

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                clientState:(NSDictionary *)state andCompletion:(PNStatusBlock)block {

    [self setNumberOfAPICalls:([self numberOfAPICalls] + 1)];
    NSArray *presenceChannelsList = nil;
    if (shouldObservePresence) {

        presenceChannelsList = [self presenceChannelsFrom:channels];
    }

    // Send subscribe list modification request. This way client prepare data objects on which it
    // should subscribe and with called method it will be combined with previous objects for further
    // subscription.
    [self subscribeWithObjectsListModification:YES presence:YES
                                    toChannels:[NSArray arrayWithArray:channels] groups:nil
                                   andPresence:presenceChannelsList withClientState:state
                                 andCompletion:block];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                   andCompletion:(PNStatusBlock)block {
    
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence clientState:nil
                     andCompletion:block];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                     clientState:(NSDictionary *)state andCompletion:(PNStatusBlock)block {

    [self setNumberOfAPICalls:([self numberOfAPICalls] + 1)];
    NSArray *groupsList = [NSArray arrayWithArray:groups];
    if (shouldObservePresence) {

        groupsList = [groups arrayByAddingObjectsFromArray:[self presenceChannelsFrom:groups]];
    }

    // Send subscribe list modification request. This way client prepare data objects on which it
    // should subscribe and with called method it will be combined with previous objects for further
    // subscription.
    [self subscribeWithObjectsListModification:YES presence:YES toChannels:nil groups:groupsList
                                   andPresence:nil withClientState:state andCompletion:block];
}

- (void)subscribeToPresenceChannels:(NSArray *)channels withCompletion:(PNStatusBlock)block {

    [self setNumberOfAPICalls:([self numberOfAPICalls] + 1)];

    // Send subscribe list modification request. This way client prepare data objects on which it
    // should subscribe and with called method it will be combined with previous objects for further
    // subscription.
    [self subscribeWithObjectsListModification:YES presence:YES toChannels:nil groups:nil
                                   andPresence:[NSArray arrayWithArray:channels] withClientState:nil
                                 andCompletion:block];
}

- (void)subscribeWithObjectsListModification:(BOOL)shouldModifyObjectsList
                                    presence:(BOOL)issuePresenceEvent toChannels:(NSArray *)channels
                                      groups:(NSArray *)groups andPresence:(NSArray *)presence
                             withClientState:(NSDictionary *)state
                               andCompletion:(PNStatusBlock)block {

    // Dispatching async on private queue which is able to serialize access with client
    // configuration data. Also this queue allow to serialize subscribe requests and make sure
    // what order won't be changed during time.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.subscribeQueue, ^{

        __strong __typeof(self) strongSelf = weakSelf;
        BOOL isValidClientState = YES;
        NSArray *channelsForSubscription = [strongSelf channelsInternal];
        NSArray *groupsForSubscription = [strongSelf groupsInternal];
        NSArray *presenceForSubscription = [strongSelf presenceChannelsInternal];
        if (shouldModifyObjectsList) {

            channelsForSubscription = [channelsForSubscription arrayByAddingObjectsFromArray:channels];
            groupsForSubscription = [groupsForSubscription arrayByAddingObjectsFromArray:groups];
            presenceForSubscription = [presenceForSubscription arrayByAddingObjectsFromArray:presence];
            
            for (NSString *objectName in state) {
                
                isValidClientState = [PNDictionary hasFlattenedContent:state[objectName]];
                if (!isValidClientState) {
                    
                    break;
                }
            }
        }
        // Prepare full list of channels which passed to request as part of URI string.
        NSArray *fullChannelsList = [channelsForSubscription arrayByAddingObjectsFromArray:presenceForSubscription];

        // In case if presence event generation has been requested, current time token should be set
        // to 0.
        if (issuePresenceEvent) {

            if ([[strongSelf currentTimeToken] integerValue] > 0) {

                [strongSelf setPreviousTimeToken:[strongSelf currentTimeToken]];
            }
            [strongSelf setCurrentTimeToken:@(0)];
        }
        BOOL isInitialSubscription = ([[strongSelf currentTimeToken] integerValue] == 0);
        [strongSelf stopRetryTimer];

        // Check whether exclusive access to subscriber should be granted or not. Exclusive access
        // should be granted only in case of initial subscription or unsubscribe requests.
        if (isInitialSubscription) {

            dispatch_suspend(strongSelf.subscribeQueue);
        }

        // Compose full list of channels which should be placed into request path (consist from
        // regular and presence channels)
        NSString *channelsList = [PNChannel namesForRequest:fullChannelsList defaultString:@","];
        NSString *groupsList = [PNChannel namesForRequest:groupsForSubscription];
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];

        // Prepare client state information which should be bound to remote data objects.
        NSArray *fullObjectsList = [fullChannelsList arrayByAddingObjectsFromArray:groupsForSubscription];
        NSDictionary *mergedState = [strongSelf stateMergedWith:state forObjects:fullObjectsList];

        // Prepare query parameters basing on available information.
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        if (strongSelf.presenceHeartbeatValue > 0) {

            parameters[@"heartbeat"] = @(strongSelf.presenceHeartbeatValue);
        }
        if ([groupsList length]) {

            parameters[@"channel-group"] = groupsList;
        }
        if ([mergedState count]) {

            NSString *mergedStateString = [PNJSON JSONStringFrom:mergedState withError:nil];
            if ([mergedStateString length]) {

                parameters[@"state"] = mergedStateString;
            }
        }
        parameters = ([parameters count] ? parameters : nil);

        // Build resulting resource request path.
        NSString *path = [NSString stringWithFormat:@"/subscribe/%@/%@/0/%@", subscribeKey,
                          channelsList, [strongSelf currentTimeToken]];
        __block __weak PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                                          forOperation:PNSubscribeOperation
                                                        withCompletion:^{
                                             
            __strong __typeof(self) strongSelfForResults = weakSelf;
            [strongSelfForResults handleSubscribeRequest:request onChannels:channelsForSubscription
                                                  groups:groupsForSubscription
                                                presence:presenceForSubscription
                                               withState:mergedState andCompletion:[block copy]];
        }];
        request.parseBlock = ^id(id rawData){

            __strong __typeof(self) strongSelfForProcessing = weakSelf;
            return [strongSelfForProcessing processedSubscribeResponse:rawData];
        };

        // Ensure what all required fields passed before starting processing.
        if ([fullObjectsList count] && isValidClientState) {
            
            if (isInitialSubscription && [[strongSelf allObjects] count]) {
                
                // Construct corresponding data objects which should be delivered through to state
                // change listeners.
                PNStatus *status = [PNStatus statusForRequest:request withError:nil];
                status.category = PNAcknowledgmentCategory;
                [strongSelf handleSubscriberStatus:status change:PNDisconnectedSubscriberState];
            }
            [strongSelf processRequest:request];
        }
        // Notify about incomplete parameters set.
        else {

            NSString *description = @"Channels and channel groups is empty.";
            NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                 code:kPNAPIUnacceptableParameters
                                             userInfo:@{NSLocalizedDescriptionKey:description}];
            [strongSelf handleRequestFailure:request withError:error];
        }
    });
}

- (void)restoreSubscriptionCycleIfRequired {
    
    [self stopRetryTimer];
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        if ([[self mutableChannels] count] || [[self mutableGroups] count] ||
            [[self mutablePresenceChannels] count]) {
            
            [self subscribeWithObjectsListModification:NO presence:YES
                                            toChannels:[[self mutableChannels] allObjects]
                                                groups:[[self mutableGroups] allObjects]
                                           andPresence:[[self mutablePresenceChannels] allObjects]
                                       withClientState:nil andCompletion:NULL];
        }
    });
}

- (void)continueSubscriptionCycleIfRequired {

    [self stopRetryTimer];
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        if ([[self mutableChannels] count] || [[self mutableGroups] count] ||
            [[self mutablePresenceChannels] count]) {
            
            [self subscribeWithObjectsListModification:NO presence:NO
                                            toChannels:[[self mutableChannels] allObjects]
                                                groups:[[self mutableGroups] allObjects]
                                           andPresence:[[self mutablePresenceChannels] allObjects]
                                       withClientState:nil andCompletion:NULL];
        }
    });
}

- (void)startRetryTimer {

    [self stopRetryTimer];
    __weak __typeof__(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof__(self) strongSelf = weakSelf;
        dispatch_queue_t timerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
        dispatch_source_set_event_handler(timer, ^{

            __strong __typeof__(self) strongSelfForHandler = weakSelf;
            if([strongSelfForHandler numberOfAPICalls] == 0) {

                [strongSelfForHandler continueSubscriptionCycleIfRequired];
            }
        });
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPubNubSubscriptionRetryInterval * NSEC_PER_SEC));
        dispatch_source_set_timer(timer, start, (uint64_t)(kPubNubSubscriptionRetryInterval * NSEC_PER_SEC), NSEC_PER_SEC);
        objc_setAssociatedObject(strongSelf, kPubNubSubscribeRetryTimer, timer, OBJC_ASSOCIATION_RETAIN);
        dispatch_resume(timer);
    });
}

- (void)stopRetryTimer {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async([self subscriberAccessQueue], ^{

        __strong __typeof(self) strongSelf = weakSelf;
        dispatch_source_t timer = objc_getAssociatedObject(strongSelf, kPubNubSubscribeRetryTimer);
        if (timer != NULL && dispatch_source_testcancel(timer) == 0) {

            dispatch_source_cancel(timer);
        }
        objc_setAssociatedObject(strongSelf, kPubNubSubscribeRetryTimer, nil, OBJC_ASSOCIATION_RETAIN);
    });
}


#pragma mark - Unsubscription

- (void)unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                  andCompletion:(PNStatusBlock)block {

    [self setNumberOfAPICalls:([self numberOfAPICalls] + 1)];
    NSArray *presenceChannels = nil;
    if (shouldObservePresence) {

        presenceChannels = [self presenceChannelsFrom:channels];
    }

    // Send subscribe list modification request. This way client prepare data objects from which it
    // should unsubscribe rest of the objects can be used for further subscription.
    [self leaveChannels:channels groups:nil andPresence:presenceChannels withCompletion:block];
}

- (void)unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                       andCompletion:(PNStatusBlock)block {

    [self setNumberOfAPICalls:([self numberOfAPICalls] + 1)];
    NSArray *groupsList = [NSArray arrayWithArray:groups];
    if (shouldObservePresence) {

        groupsList = [groupsList arrayByAddingObjectsFromArray:[self presenceChannelsFrom:groups]];
    }

    // Send subscribe list modification request. This way client prepare data objects from which it
    // should unsubscribe rest of the objects can be used for further subscription.
    [self leaveChannels:nil groups:groupsList andPresence:nil withCompletion:block];
}

- (void)unsubscribeFromPresenceChannels:(NSArray *)channels andCompletion:(PNStatusBlock)block {

    [self setNumberOfAPICalls:([self numberOfAPICalls] + 1)];
    [self leaveChannels:nil groups:nil andPresence:channels withCompletion:block];
}

- (void)leaveChannels:(NSArray *)channels groups:(NSArray *)groups andPresence:(NSArray *)presence
       withCompletion:(PNStatusBlock)block {
    
    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.subscribeQueue, ^{

        __strong __typeof(self) strongSelf = weakSelf;

        // Clean up data objects list from requested objects.
        [strongSelf removeChannels:channels];
        [strongSelf removeGroups:groups];
        [strongSelf removePresenceChannels:presence];

        // Remove presence channels from list of regular channels.
        NSArray *filteredGroups = [strongSelf channelsWithOutPresenceFrom:groups];
        if ([channels count] || [filteredGroups count]) {

            dispatch_suspend(strongSelf.subscribeQueue);
        }

        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSString *channelsList = [PNChannel namesForRequest:([channels count] ? channels : nil)
                                              defaultString:@","];
        NSDictionary *parameters = nil;
        if ([filteredGroups count]){

            parameters = @{@"channel-group":[PNChannel namesForRequest:filteredGroups]};
        }
        NSString *path = [NSString stringWithFormat:@"/v2/presence/sub_key/%@/channel/%@/leave",
                          subscribeKey, channelsList];
        __block __weak PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                           forOperation:PNUnsubscribeOperation
                                         withCompletion:^{
                                             
            __strong __typeof(self) strongSelfForResults = weakSelf;
            [strongSelfForResults handleUnsubscribeRequest:request fromChannels:channels
                                                    groups:groups presence:presence
                                            withCompletion:[block copy]];
        }];
        request.parseBlock = ^id(id rawData) {

            return rawData;
        };

        // Ensure what all required fields passed before starting processing.
        if ([channels count] || [filteredGroups count]) {

            [strongSelf processRequest:request];

            // In case if there is some channels left after unsubscription client should pick them
            // up and subscribe back.
            if ([[strongSelf allObjects] count]) {

                // Check whether there is no other API calls done during this method call.
                // If there is no more then 1 API call (leave itself) we need to call subscription
                // restore on rest of the channels.
                if ([strongSelf numberOfAPICalls] <= 1) {
                    
                    [strongSelf setNumberOfAPICalls:([strongSelf numberOfAPICalls] + 1)];
                    [strongSelf subscribeWithObjectsListModification:NO presence:YES
                                                          toChannels:[strongSelf channelsInternal]
                                                              groups:[strongSelf groupsInternal]
                                                         andPresence:[strongSelf presenceChannelsInternal]
                                                     withClientState:nil andCompletion:nil];
                }
            }
            else {
                
                dispatch_async(self.subscribeQueue, ^{
                    
                    // Reset subscription time token data.
                    [self setCurrentTimeToken:@(0)];
                    [self setPreviousTimeToken:@(0)];
                    
                    // Cancel pending long-poll subscribe requests.
                    __strong __typeof(self) strongSelfForCancel = weakSelf;
                    [strongSelfForCancel cancelAllLongPollRequests];
                });
            }
        }
        // Notify about incomplete parameters set.
        else {

            NSString *description = @"Channels/channel groups list is empty.";
            NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                 code:kPNAPIUnacceptableParameters
                                             userInfo:@{NSLocalizedDescriptionKey:description}];
            [strongSelf handleRequestFailure:request withError:error];
        }
    });
}

#pragma mark - Handlers

- (void)handleSubscribeRequest:(PNRequest *)request onChannels:(NSArray *)channels
                        groups:(NSArray *)groups presence:(NSArray *)presence
                     withState:(NSDictionary *)state andCompletion:(PNStatusBlock)block {

    // Try fetch time token from passed result/status objects.
    NSNumber *timeToken = @([[request.response.clientRequest.URL lastPathComponent] longLongValue]);
    BOOL isInitialSubscription = ([timeToken integerValue] == 0);
    
    // Retrieve list of objects which would like to receive updates and state change events.
    NSArray *messageListeners = [[[self messageListeners] allObjects] copy];
    NSArray *presenceListeners = [[[self presenceEventListeners] allObjects] copy];
    
    // Prepare storage to calculate set of new remote data objects on which client has been
    // subscribed.
    NSMutableSet *channelsDifference = nil;
    NSMutableSet *channelGroupsDifference = nil;
    NSMutableSet *presenceChannelsDifference = nil;

    // In case if initial subscription has been performed (every subscription on new set of channels
    // will issue subscribe request with 0 time token) decrease active subscriptions API call and
    // determine whether further actions should be done to continue subscription or not.
    if (isInitialSubscription) {
        
        // Calculate difference between stored and passed data object names
        NSSet *channelsSet = [NSSet setWithArray:[self channelsInternal]];
        channelsDifference = [NSMutableSet setWithArray:channels];
        [channelsDifference minusSet:channelsSet];
        if (![channelsDifference count]) {
            
            [channelsDifference setSet:channelsSet];
        }
        NSSet *channelGroupsSet = [NSSet setWithArray:[self groupsInternal]];
        channelGroupsDifference = [NSMutableSet setWithArray:groups];
        [channelGroupsDifference minusSet:channelGroupsSet];
        if (![channelGroupsDifference count]) {
            
            [channelGroupsDifference setSet:channelGroupsSet];
        }
        NSSet *presenceChannels = [NSSet setWithArray:[self presenceChannelsInternal]];
        presenceChannelsDifference = [NSMutableSet setWithArray:presence];
        [presenceChannelsDifference minusSet:presenceChannels];
        if (![presenceChannelsDifference count]) {
            
            [presenceChannelsDifference setSet:presenceChannels];
        }

        // Storing channels into local cache, so they can be re-used with subscription cycle.
        [self addChannels:channels];
        [self addGroups:groups];
        [self addPresenceChannels:presence];
        
        [self setNumberOfAPICalls:MAX(([self numberOfAPICalls] - 1), 0)];
    }
    BOOL shouldContinueSubscriptionCycle = ([self numberOfAPICalls] == 0);

    // Store client state information into cache.
    [self mergeWithState:state];
    
    // Construct corresponding data objects which should be delivered through completion block.
    PNStatus *status = [PNStatus statusForRequest:request withError:request.response.error];

    // Handle successful w/o troubles subscription request processing.
    if (!status.isError) {
        
        // Whether new time token from response should be applied for next subscription cycle or
        // not.
        BOOL shouldAcceptNewTimeToken = shouldContinueSubscriptionCycle;

        // 'shouldKeepTimeTokenOnListChange' property should never allow to reset time tokens in
        // case if there is a few more subscribe requests is waiting for their turn to be sent.
        if (isInitialSubscription && shouldContinueSubscriptionCycle) {

            if (self.shouldKeepTimeTokenOnListChange) {

                // Ensure what we already don't use value from previous time token assigned during
                // previous sessions.
                if ([[self previousTimeToken] integerValue] > 0) {
                    shouldAcceptNewTimeToken = NO;

                    // Swap time tokens to catch up on events which happened while client changed
                    // channels and groups list configuration.
                    [self setCurrentTimeToken:[self previousTimeToken]];
                    [self setPreviousTimeToken:@(0)];
                }
            }
        }
        if (shouldAcceptNewTimeToken) {

            if ([[self currentTimeToken] integerValue] > 0) {

                [self setPreviousTimeToken:[self currentTimeToken]];
            }
            [self setCurrentTimeToken:status.data[@"tt"]];
        }
        
        if (isInitialSubscription) {
            
            status.category = PNConnectedCategory;
            [self handleSubscriberStatus:status change:PNConnectedSubscriberState];
        }
    }
    // Looks like some troubles happened while subscription request has been processed.
    else {

        // Looks like subscription request has been cancelled.
        // Cancelling can happen because of: user changed subscriber sensitive configuration or
        // another subscribe/unsubscribe request has been issued.
        if (status.category == PNCancelledCategory) {
            
            // Stop heartbeat for now and wait further actions.
            [self stopHeartbeatIfPossible];
            shouldContinueSubscriptionCycle = NO;
        }
        // Looks like processing failed because of another error.
        // If there is another subscription/unsubscription operations is waiting client shouldn't
        // handle this status yet.
        else if (shouldContinueSubscriptionCycle) {
            
            // Check whether status category declare subscription retry or not.
            if (status.category == PNAccessDeniedCategory || status.category == PNTimeoutCategory ||
                status.category == PNMalformedResponseCategory) {

                __weak __typeof(self) weakSelf = self;
                shouldContinueSubscriptionCycle = NO;
                status.automaticallyRetry = YES;
                status.retryCancelBlock = ^{

                    DDLogAPICall(@"<PubNub> Cancel retry");
                    __strong __typeof(self) strongSelf = weakSelf;
                    [strongSelf stopRetryTimer];
                };
                [self startRetryTimer];
                PNSubscriberState subscriberState = PNAccessRightsErrorSubscriberState;
                if (status.category != PNAccessDeniedCategory) {
                    
                    subscriberState = PNDisconnectedUnexpectedlySubscriberState;
                    status.category = PNUnexpectedDisconnectCategory;
                }
                [self handleSubscriberStatus:status change:subscriberState];
            }
            // Looks like client lost connection with internet or has any other connection
            // related issues.
            else {

                shouldContinueSubscriptionCycle = NO;

                // Check whether subscription should be restored on network connection restore or
                // not.
                if (self.shouldRestoreSubscription) {
                    
                    if (!self.shouldTryCatchUpOnSubscriptionRestore) {
                        
                        [self setCurrentTimeToken:@(0)];
                        [self setPreviousTimeToken:@(0)];
                    }
                }
                else {
                    
                    [self removeChannels:[self channelsInternal]];
                    [self removeGroups:[self groupsInternal]];
                    [self removePresenceChannels:[self presenceChannelsInternal]];
                }
                status.category = PNUnexpectedDisconnectCategory;
                
                [self stopHeartbeatIfPossible];
                [self handleSubscriberStatus:status
                                      change:PNDisconnectedUnexpectedlySubscriberState];
            }
        }
    }

    // Check whether client received updates from service or not.
    if (!isInitialSubscription && [status.data[@"events"] count]) {

        NSArray *events = [status.data[@"events"] copy];
        __weak __typeof(self) weakSelf = self;
        dispatch_async(self.callbackQueue, ^{

            // Iterate through array with notifications and report back using callback blocks to the
            // user.
            __strong __typeof(self) strongSelf = weakSelf;
            for (NSMutableDictionary *event in events) {
                
                // Check whether event has been triggered on presence channel or channel group.
                // In case if check will return YES this is presence event.
                BOOL isPresenceEvent = ([event[@"channel"] hasSuffix:kPubNubPresenceChannelNameSuffix] ||
                                        [event[@"channel-group"] hasSuffix:kPubNubPresenceChannelNameSuffix]);
                if (isPresenceEvent) {
                    
                    if (event[@"channel"]) {
                        
                        event[@"channel"] = [event[@"channel"] stringByReplacingOccurrencesOfString:kPubNubPresenceChannelNameSuffix
                                                                                                   withString:@""];
                    }
                    if (event[@"channel-group"]) {
                        
                        event[@"channel-group"] = [event[@"channel-group"] stringByReplacingOccurrencesOfString:kPubNubPresenceChannelNameSuffix
                                                                                                               withString:@""];
                    }
                }
                
                PNResult *eventResultObject = [PNResult resultFromStatus:status withData:event];
                if (isPresenceEvent) {
                    
                    [strongSelf handleNewPresenceEvent:eventResultObject by:presenceListeners];
                }
                else {

                    [strongSelf handleNewMessage:eventResultObject by:messageListeners];
                }
            }
        });

        status.data = [(NSDictionary *)status.data dictionaryWithValuesForKeys:@[@"tt"]];
    }
    else if (isInitialSubscription) {
        
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:status.data];
        [data removeObjectForKey:@"events"];
        status.data = [data copy];
    }

    if (shouldContinueSubscriptionCycle) {

        [self continueSubscriptionCycleIfRequired];
        
        // Because client received new event from service, it can restart reachability timer with
        // new interval.
        [self startHeartbeatIfRequired];
    }

    // Exclusive access to subscriber API granted only for initial subscriptions and when client
    // done with it exclusive access requirement should be removed.
    if (isInitialSubscription) {
        
        dispatch_resume(self.subscribeQueue);
    }
    
    // Check whether initial subscription or channels list update has been performed.
    if (isInitialSubscription || status.category == PNUnexpectedDisconnectCategory) {

        [self addSubscriberStateInformationTo:status];
        [self callBlock:block status:YES withResult:nil andStatus:status];
    }
}

- (void)handleNewMessage:(PNResult *)data by:(NSArray *)listeners{
    
    PNStatus *status = nil;
    if (data) {
        
        DDLogResult(@"<PubNub> %@", [data stringifiedRepresentation]);
        if (data.data[@"decryptError"]) {
            
            status = [PNStatus statusFromResult:data];
            status.category = PNDecryptionErrorCategory;
            NSMutableDictionary *updatedData = [data.data mutableCopy];
            [updatedData removeObjectForKey:@"decryptError"];
            status.data = updatedData;
        }
    }

    // Iterate over list of listeners and notify about new message.
    for (id<PNObjectEventListener> listener in listeners) {
        
        [listener client:self didReceiveMessage:data withStatus:status];
    }
}

- (void)handleNewPresenceEvent:(PNResult *)data  by:(NSArray *)listeners {

    // Check whether state modification event arrived or not.
    // In case of state modification event for current client it should be applied on local storage.
    if ([data.data[@"action"] isEqualToString:@"state-change"]) {

        // Check whether state has been changed for current client or not.
        if ([data.data[@"action"] isEqualToString:self.uuid]) {

            [self setState:data.data[@"data"] forObject:self.uuid];
        }
    }

    // Iterate over list of listeners and notify about new presence event.
    for (id <PNObjectEventListener> listener in listeners) {
        
        [listener client:self didReceivePresenceEvent:data];
    }
}

- (void)handleSubscriberStatus:(PNStatus *)status change:(PNSubscriberState)state {
    
    // Retrieve current subscruber state.
    PNSubscriberState currentState = [self subscriberState];
    
    // Compose status object to report state change to listeners.
    PNStatusCategory category = PNUnknownCategory;
    BOOL shouldHandleTransition = NO;
    
    // Check whether transit to 'connected' state.
    if (state == PNConnectedSubscriberState) {
        
        // Check whether client transit from 'disconnected' -> 'connected' state.
        shouldHandleTransition = ((currentState == PNDisconnectedSubscriberState)?:
                                  shouldHandleTransition);
        
        // Check whether client transit from 'access denied' -> 'connected' state.
        shouldHandleTransition = (shouldHandleTransition?:
                                  (currentState == PNAccessRightsErrorSubscriberState));
        category = PNConnectedCategory;
        
        // Check whether client transit from 'unexpected disconnect' -> 'connected' state
        if (!shouldHandleTransition && currentState == PNDisconnectedUnexpectedlySubscriberState) {
            
            // Change state to 'reconnected'
            state = PNConnectedSubscriberState;
            category = PNReconnectedCategory;
            shouldHandleTransition = YES;
        }
    }
    // Check whether transit to 'disconnected' or 'unexpected disconnect' state.
    else if (state == PNDisconnectedSubscriberState ||
             state == PNDisconnectedUnexpectedlySubscriberState) {
        
        // Check whether client transit from 'connected' -> 'disconnected'/'unexpected disconnect'
        // state.
        shouldHandleTransition = ((currentState == PNConnectedSubscriberState)?:
                                  shouldHandleTransition);
        category = ((state == PNDisconnectedSubscriberState) ? PNDisconnectedCategory :
                    PNUnexpectedDisconnectCategory);
    }
    // Check whether transit to 'access deined' state.
    else if (state == PNAccessRightsErrorSubscriberState) {
        
        // Check whether client transit from non-'access deined' -> 'access deined' state.
        shouldHandleTransition = ((currentState != PNAccessRightsErrorSubscriberState)?:
                                  shouldHandleTransition);
        category = PNDisconnectedCategory;
    }
    
    // Check whether allowed state transition has been issued or not.
    if (shouldHandleTransition) {
        
        if (state == PNDisconnectedSubscriberState ||
            state == PNDisconnectedUnexpectedlySubscriberState ||
            state == PNAccessRightsErrorSubscriberState) {
            
            NSLog(@"Disconnected from: %@", [self allObjects]);
        }
        
        // Store actual client subscriber state.
        [self setSubscriberState:state];
        
        // Compose status object to report state change to listeners.
        PNStatus *subscriberStatus = [status copy];
        subscriberStatus.category = category;
        [self completeStatusObject:subscriberStatus];
        [self addSubscriberStateInformationTo:subscriberStatus];
        
        dispatch_async(self.callbackQueue, ^{
            
            // Iterate over list of listeners and notify about new presence event.
            for (id <PNObjectEventListener> listener in [[[self stateListeners] allObjects] copy]) {
                
                [listener client:self didReceiveStatus:subscriberStatus];
            }
        });
    }
}

- (void)handleUnsubscribeRequest:(PNRequest *)request fromChannels:(NSArray *)channels
                          groups:(NSArray *)groups presence:(NSArray *)presence
                  withCompletion:(PNStatusBlock)block {
    
    // Create status information if required.
    PNStatus *status = [PNStatus statusForRequest:request withError:nil];
    [self setNumberOfAPICalls:MAX(([self numberOfAPICalls] - 1), 0)];
    
    if (![[self allObjects] count]) {
        
        [self handleSubscriberStatus:status change:PNDisconnectedSubscriberState];
    }

    [self addSubscriberStateInformationTo:status];
    [self callBlock:block status:YES withResult:nil andStatus:status];
    
    // In case if 'leave' presence event had target channels/groups it should release subscription
    // queue to allow further requests execution
    if ([channels count] || [groups count]) {
        
        dispatch_resume(self.subscribeQueue);
    }
}


#pragma mark - Processing

- (void)addSubscriberStateInformationTo:(PNStatus *)status {

    status.currentTimetoken = [self currentTimeToken];
    status.previousTimetoken = [self previousTimeToken];
    status.channels = [[[self mutableChannels] setByAddingObjectsFromSet:[self mutablePresenceChannels]] allObjects];
    status.channelGroups = [[self mutableGroups] allObjects];
}

- (NSDictionary *)processedSubscribeResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array will arrive in case of subscription event
    if ([response isKindOfClass:[NSArray class]]) {
        
        NSArray *feedEvents = response[kPNEventsListElementIndex];
        NSNumber *timeToken = @([response[kPNEventTimeTokenElement] longLongValue]);
        NSArray *channels = nil;
        NSArray *groups = nil;
        if ([(NSArray *)response count] > kPNEventChannelsElementIndex) {
            
            channels = [PNChannel namesFromRequest:response[kPNEventChannelsElementIndex]];
        }
        // Looks like multiplexing disabled and event arrived on the only one object at which client
        // subscribed at this moment.
        else if ([[self allObjects] count]){
            
            channels = @[[self allObjects][0]];
        }

        if ([(NSArray *)response count] > kPNEventChannelsDetailsElementIndex) {
            
            groups = [PNChannel namesFromRequest:response[kPNEventChannelsDetailsElementIndex]];
        }

        // Checking whether at least one event arrived or not.
        if ([feedEvents count] && ([channels count] || [groups count])) {
            
            NSMutableArray *events = [[NSMutableArray alloc] initWithCapacity:[feedEvents count]];
            for (NSUInteger eventIdx = 0; eventIdx < [feedEvents count]; eventIdx++) {
                
                // Fetching remote data object name on which event fired.
                NSString *objectName = (eventIdx < [channels count] ?
                                        channels[eventIdx] : (channels[0]?: @"empty"));
                id eventBody = feedEvents[eventIdx];
                NSMutableDictionary *event = [@{@"channel": objectName,
                                                @"tt":timeToken} mutableCopy];
                if ([groups count] > eventIdx) {

                    event[@"channel-group"] = groups[eventIdx];
                }

                // Check whether presence event will be processed or not.
                if ([objectName hasSuffix:kPubNubPresenceChannelNameSuffix]) {

                    // Processing common for all presence events data.
                    event[@"action"] = feedEvents[eventIdx][@"action"];
                    event[@"tt"] = feedEvents[eventIdx][@"timestamp"];
                    if (feedEvents[eventIdx][@"uuid"]) {

                        event[@"uuid"] = feedEvents[eventIdx][@"uuid"];
                    }

                    // Check whether this is not state modification event.
                    if (![event[@"action"] isEqualToString:@"state-change"]) {

                        event[@"occupancy"] = feedEvents[eventIdx][@"occupancy"];
                    }
                    else {

                        event[@"data"] = feedEvents[eventIdx][@"data"];
                    }
                }
                else {

                    // Try decrypt message body if possible.
                    if ([self.cipherKey length] && [eventBody isKindOfClass:[NSString class]]) {

                        NSError *decryptionError;
                        NSData *eventData = [PNAES decrypt:eventBody withKey:self.cipherKey
                                                  andError:&decryptionError];
                        NSString *encryptedEventData = nil;
                        if (eventData) {

                            encryptedEventData = [[NSString alloc] initWithData:eventData
                                                                       encoding:NSUTF8StringEncoding];
                        }

                        // In case if after encryption another object has been received client
                        // should try to de-serialize it again as JSON object.
                        if (encryptedEventData &&
                            ![encryptedEventData isEqualToString:feedEvents[eventIdx]]) {

                            eventBody = [PNJSON JSONObjectFrom:encryptedEventData withError:nil];
                        }

                        if (decryptionError) {
                            
                            DDLogAESError(@"<PubNub> Message decryption error: %@", decryptionError);
                            event[@"decryptError"] = @YES;
                        }
                    }
                    event[@"message"] = eventBody;
                }
                [events addObject:event];
            }
            feedEvents = [events copy];
        }
        processedResponse = @{@"events":feedEvents,@"tt":timeToken};
    }
    
    return [processedResponse copy];
}

#pragma mark -


@end
