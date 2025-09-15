#import "PNSubscriber.h"
#import <PubNub/PNLock.h>
#import "PNSubscribeMessageEventData+Private.h"
#import "PNSubscribeFileEventData+Private.h"
#import "PNPresenceLeaveRequest+Private.h"
#import "PNSubscribeEventData+Private.h"
#import "PNSubscribeRequest+Private.h"
#import "PNOperationResult+Private.h"
#import "PNSubscribeStatus+Private.h"
#import "PubNub+SubscribePrivate.h"
#import "PNAcknowledgmentStatus.h"
#import "PNServiceData+Private.h"
#import "PNErrorStatus+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PNLoggerManager.h"
#import "PNFile+Private.h"
#import "PubNub+Files.h"
#import <objc/runtime.h>
#import "PNHelpers.h"


#pragma mark Structures

typedef NS_OPTIONS(NSUInteger, PNSubscriberState) {
    /// State set when subscriber has been just initialized.
    PNInitializedSubscriberState,

    /// State set at the moment when client received response on `leave` request and not subscribed to any remote data
    /// objects live feed.
    PNDisconnectedSubscriberState,

    /// State set at the moment when client lost connection or experienced other issues with communication established
    /// with **PubNub** service.
    PNDisconnectedUnexpectedlySubscriberState,

    /// State set at the moment when client received response with `200` status code for subscribe request with TT `0`.
    PNConnectedSubscriberState,

    /// State set at the moment when client received response with `403` status code for subscribe request.
    PNAccessRightsErrorSubscriberState,

    /// State set at the moment when client received response with `481` status code for subscribe request.
    PNMalformedFilterExpressionErrorSubscriberState,

    /// State set at the moment when client received response with `414` status code for subscribe / unsubscribe
    /// requests.
    PNPNRequestURITooLongErrorSubscriberState
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNSubscriber ()


#pragma mark - Information

/// Dictionary which is used in messages 'de-dupe' logic to prevent same messages or presence events delivering to
/// objects event listeners.
@property(strong, nonatomic) NSMutableDictionary<NSString *, NSMutableArray<NSDictionary *> *> *cachedObjects;

/// List of cached object identifiers.
///
/// Array used every time when maximum cached objects count has been reached to clean up cache from older entries.
@property(strong, nonatomic) NSMutableArray<NSString *> *cachedObjectIdentifiers;

/// Actual storage for list of presence channels on which client subscribed at this moment and listen for presence
/// updates.
@property(strong, nonatomic) NSMutableSet<NSString *> *presenceChannelsSet;

/// Actual storage for list of channel groups on which client subscribed at this moment and listen for updates from live
/// feeds.
@property(strong, nonatomic) NSMutableSet<NSString *> *channelGroupsSet;

/// **PubNub** server region identifier (which generated `currentTimeToken` value).
///
/// **0** for initial subscription loop and non-zero for long-poll requests.
@property(copy, nonatomic, readonly) NSNumber *currentTimeTokenRegion;

/// Actual storage for list of channels on which client subscribed at this moment and listen for updates from live feeds.
@property(strong, nonatomic) NSMutableSet<NSString *> *channelsSet;

/// Time token which should be used after initial subscription with **0** timetoken.
///
/// Override token used by subscribe API which allow to subscribe on arbitrarily time token and will be used in logic
/// which decide which time token should be used for next subscription cycle.
@property(strong, nullable, nonatomic) NSNumber *overrideTimeToken;

/// Time token region which has been used for previous subscribe loop iteration.
///
/// **0** for initial subscription loop and non-zero for long-poll requests.
@property(copy, nonatomic, readonly) NSNumber *lastTimeTokenRegion;

/// Whether subscriber potentially should expect for subscription restore call or not.
///
/// In case if client tried to connect and failed or disconnected because of network issues this flag should be set to
/// `YES`.
@property(assign, nonatomic) BOOL mayRequireSubscriptionRestore;

/// Whether subscriber recovers after network issues.
@property(assign, nonatomic) BOOL restoringAfterNetworkIssues;

/// Current subscriber state.
@property(assign, nonatomic) PNSubscriberState currentState;

/// Time token which is used for current subscribe loop iteration.
///
/// **0** for initial subscription loop and non-zero for long-poll requests.
@property(strong, nonatomic) NSNumber *currentTimeToken;

/// Time token which has been used for previous subscribe loop iteration.
///
/// **0** for initial subscription loop and non-zero for long-poll requests.
@property(strong, nonatomic) NSNumber *lastTimeToken;

/// Client for which subscribe manager manage subscribe loop.
@property(weak, nonatomic) PubNub *client;

/// Resources access lock.
@property(strong, nonatomic) PNLock *lock;


#pragma mark - Initialization and Configuration

/// Initialize subscribe loop manager for concrete **PubNub** client.
///
/// - Parameter client: Reference on client which will be weakly stored in subscriber.
/// - Returns: Initialized subscribe manager instance.
- (instancetype)initForClient:(PubNub *)client;


#pragma mark - Subscription information modification

/// Update current subscriber state.
///
/// If possible, state transition will be reported to the listeners.
///
/// - Parameters:
///   - state: New state from ``PNSubscriberState`` enum fields.
///   - status: Status object which should be passed along to listeners.
///   - block: Block which will be called at the end of subscriber's state update process. Block pass only one
///   argument - reference on one of `PNStatusCategory` enum fields which represent calculated status category (may
///   differ from the one, which is passed into method because of current and expected subscriber's state).
- (void)updateStateTo:(PNSubscriberState)state
           withStatus:(PNStatus *)status
           completion:(nullable void(^)(PNStatusCategory category))block;


#pragma mark - Subscription

/// Perform initial subscription with **0** timetoken.
///
/// Subscription with **0** timetoken "register" client in **PubNub** network and allow to receive live updates from
/// remote data objects live feed.
///
/// - Parameters:
///   - initialSubscribe: Whether client trying to subscriber using **0** time token and trigger all required presence
///   notifications or not.
///   - timeToken: Time from which client should try to catch up on messages.
///   - state: Client state which should be bound to channels on which client has been subscribed or will subscribe now.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Subscription completion block which is used to notify code.
- (void)subscribe:(BOOL)initialSubscribe
   usingTimeToken:(nullable NSNumber *)timeToken
        withState:(nullable NSDictionary<NSString *, id> *)state
  queryParameters:(nullable NSDictionary *)queryParameters
       completion:(nullable PNSubscriberCompletionBlock)block;


#pragma mark - Unsubscription

/// Perform unsubscription operation.
///
/// If suitable objects has been passed, then client will ask **PubNub** presence service to trigger `leave` presence
/// events on passed objects.
///
/// - Parameters:
///   - channels: List of channels from which client should unsubscribe.
///   - groups: List of channel groups from which client should unsubscribe.
///   - shouldInformListener: Whether listener should be informed at the end of operation or not.
///   - subscribeOnRestChannels: Whether client should try to subscribe on channels which may be left after
///   unsubscription.
///   - block: Unsubscription completion block which is used to notify code.
- (void)unsubscribeFromChannels:(nullable NSArray<NSString *> *)channels 
                         groups:(nullable NSArray<NSString *> *)groups
            withQueryParameters:(NSDictionary *)queryParameters
          listenersNotification:(BOOL)shouldInformListener
                subscribeOnRest:(BOOL)subscribeOnRestChannels
                     completion:(nullable PNSubscriberCompletionBlock)block;


#pragma mark - Handlers

/// Handle subscription status update.
///
/// Depending on passed status category and whether it is error it will be sent for processing to corresponding methods.
///
/// - Parameter status: Status object which has been received from **PubNub** network.
- (void)handleSubscriptionStatus:(PNSubscribeStatus *)status;

/// Process successful subscription status.
///
/// Success can be called as result of initial subscription successful ACK response as well as long-poll response with
/// events from remote data objects live feed.
///
/// - Parameter status: Status object which has been received from **PubNub** network.
- (void)handleSuccessSubscriptionStatus:(PNSubscribeStatus *)status;

/// Process failed subscription status.
///
/// Failure can be cause by Access Denied error, network issues or called when last subscribe request has been canceled
/// (to execute new subscription for example).
///
/// - Parameter status: Status object which has been received from **PubNub** network.
- (void)handleFailedSubscriptionStatus:(PNSubscribeStatus *)status;

/// Handle subscription time token received from **PubNub** network.
///
/// - Parameters:
///   - initialSubscription: Whether subscription is initial or received time token on long-poll request.
///   - timeToken: Time token which has been received from **PubNub** network.
///   - region: **PubNub** server region identifier (which generated `timeToken` value).
- (void)handleSubscription:(BOOL)initialSubscription
                 timeToken:(nullable NSNumber *)timeToken
                    region:(nullable NSNumber *)region;

/// Handle long-poll service response and deliver events to listeners if required.
///
/// - Parameters:
///   - status: Status object which has been received from **PubNub** network.
///   - initialSubscription: Whether message has been received in response on initial subscription request.
///   - overrideTimeToken: Timetoken which is used to override timetoken which has been received during initial
///   subscription.
- (void)handleLiveFeedEvents:(PNSubscribeStatus *)status
      forInitialSubscription:(BOOL)initialSubscription
           overrideTimeToken:(nullable NSNumber *)overrideTimeToken;

/// Process message which just has been received from **PubNub** service through live feed on which client subscribed at
/// this moment.
///
/// - Parameter message: Result data which hold information about request on which this response has been received and
/// message itself.
- (void)handleNewMessage:(PNMessageResult *)message;

/// Process `signal` which just has been received from **PubNub** service through live feed on which client subscribed
/// at this moment.
///
/// - Parameter signal: Result data which hold information about request on which this response has been received and
/// message itself.
- (void)handleNewSignal:(PNSignalResult *)signal;

/// Process `message action` which just has been received from **PubNub** service through live feed on which client 
/// subscribed at this moment.
///
/// - Parameter action: Result data which hold information about request on which this response has been received and
/// message itself.
- (void)handleNewMessageAction:(PNMessageActionResult *)action;

/// Process `objects` API event which just has been received from **PubNub** service through live feed on which client
/// subscribed at this moment.
///
/// - Parameter object: Result data which hold information about request on which this response has been received and
/// message itself.
- (void)handleNewObjectsEvent:(PNOperationResult *)object;

/// Process `files` API event which just has been received from **PubNub** service through live feed on which client
/// subscribed at this moment.
///
/// - Parameter file: Result data which hold information about request on which this response has been received and
/// message itself.
- (void)handleNewFileEvent:(PNFileEventResult *)file;

/// Process presence event which just has been received from **PubNub** service through presence live feeds on which
/// client subscribed at this moment.
///
/// - Parameter presence: Result data which hold information about request on which this response has been received and
/// presence event itself.
- (void)handleNewPresenceEvent:(PNPresenceEventResult *)presence;


#pragma mark - Misc

/// Compose request basing on current subscriber state.
///
/// - Parameter state: Merged client state which should be used in request.
/// - Returns: Ready to use subscribe request.
- (PNSubscribeRequest *)subscribeRequestWithState:(nullable NSDictionary<NSString *, id> *)state;

/// Clean up `events` list from messages which has been already received.
///
/// Use messages cache to identify message duplicates and remove them from input `events` list so listeners won't
/// receive them through callback methods again.
///
/// > Warning: Method should be called within resource access queue to prevent race of conditions.
///
/// - Parameter events: List of received events from real-time channels and should be clean up from message duplicates.
- (void)deDuplicateMessages:(NSMutableArray<PNSubscribeEventData *> *)events;

/// Remove from messages cache those who has date same or newer than passed `timetoken`.
///
/// Method used for subscriptions where user pass specific `timetoken` to which client should catch up. It expensive to
/// run, but subscriptions to specific `timetoken` pretty rare and shouldn't affect overall performance.
///
/// > Warning: Method should be called within resource access queue to prevent race of conditions.
///
/// - Parameter timetoken: High-precision **PubNub** timetoken which will be to filter out older messages.
- (void)clearCacheFromMessagesNewerThan:(NSNumber *)timetoken;

/// Store to cache passed `object`.
///
/// This method used by `de-dupe` logic to identify unique objects about which object listeners should be notified.
///
/// > Warning: Method should be called within resource access queue to prevent race of conditions.
///
/// - Parameters:
///   - object: Reference on object which client should try to store in cache.
///   - size: Maximum number of objects which can be stored in cache and used during messages de-duplication process.
/// - Returns: `YES` in case if object successfully stored in cache and object listeners should be notified about it.
- (BOOL)cacheObjectIfPossible:(PNSubscribeMessageEventData *)object withMaximumCacheSize:(NSUInteger)size;

/// Shrink messages cache size to specified size if required.
///
/// - Parameter maximumCacheSize: Messages cache maximum size.
- (void)cleanUpCachedObjectsIfRequired:(NSUInteger)maximumCacheSize;

/// Append subscriber information to status object.
///
/// - Parameter status: Reference on status object which should be updated with subscriber information.
- (void)appendSubscriberInformation:(PNStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscriber

@synthesize restoringAfterNetworkIssues = _restoringAfterNetworkIssues;
@synthesize currentTimeTokenRegion = _currentTimeTokenRegion;
@synthesize lastTimeTokenRegion = _lastTimeTokenRegion;
@synthesize overrideTimeToken = _overrideTimeToken;
@synthesize currentTimeToken = _currentTimeToken;
@synthesize lastTimeToken = _lastTimeToken;


#pragma mark - State Information and Manipulation

- (BOOL)restoringAfterNetworkIssues {
    __block BOOL restoring = NO;
    
    [self.lock readAccessWithBlock:^{
        restoring = self->_restoringAfterNetworkIssues;
    }];

    return restoring;
}

- (void)setRestoringAfterNetworkIssues:(BOOL)restoringAfterNetworkIssues {
    [self.lock writeAccessWithBlock:^{
        self->_restoringAfterNetworkIssues = restoringAfterNetworkIssues;
    }];
}

- (NSArray<NSString *> *)allObjects {
    return [[[self channels] arrayByAddingObjectsFromArray:[self presenceChannels]]
            arrayByAddingObjectsFromArray:[self channelGroups]];
}

- (NSArray<NSString *> *)channels {
    __block NSArray *channels = nil;
    
    [self.lock readAccessWithBlock:^{
        channels = self.channelsSet.allObjects;
    }];

    return channels;
}

- (void)addChannels:(NSArray<NSString *> *)channels {
    [self.lock writeAccessWithBlock:^{
        NSArray *channelsOnly = [PNChannel objectsWithOutPresenceFrom:channels];
        
        if ([channelsOnly count] != [channels count]) {
            NSMutableSet *channelsSet = [NSMutableSet setWithArray:channels];
            [channelsSet minusSet:[NSSet setWithArray:channelsOnly]];
            [self.presenceChannelsSet unionSet:channelsSet];
        }
        
        [self.channelsSet addObjectsFromArray:channelsOnly];
    }];
}

- (void)removeChannels:(NSArray<NSString *> *)channels {
    [self.lock writeAccessWithBlock:^{
        NSSet *channelsSet = [NSSet setWithArray:channels];
        [self.presenceChannelsSet minusSet:channelsSet];
        [self.channelsSet minusSet:channelsSet];
    }];
}

- (NSArray<NSString *> *)channelGroups {
    __block NSArray *channelGroups = nil;
    
    [self.lock readAccessWithBlock:^{
        channelGroups = self.channelGroupsSet.allObjects;
    }];

    return channelGroups;
}

- (void)addChannelGroups:(NSArray<NSString *> *)groups {
    [self.lock writeAccessWithBlock:^{
        [self.channelGroupsSet addObjectsFromArray:groups];
    }];
}

- (void)removeChannelGroups:(NSArray<NSString *> *)groups {
    [self.lock writeAccessWithBlock:^{
        [self.channelGroupsSet minusSet:[NSSet setWithArray:groups]];
    }];
}

- (NSArray<NSString *> *)presenceChannels {
    __block NSArray *presenceChannels = nil;
    
    [self.lock readAccessWithBlock:^{
        presenceChannels = self.presenceChannelsSet.allObjects;
    }];

    return presenceChannels;
}

- (void)addPresenceChannels:(NSArray<NSString *> *)presenceChannels {
    [self.lock writeAccessWithBlock:^{
        [self.presenceChannelsSet addObjectsFromArray:presenceChannels];
    }];
}

- (void)removePresenceChannels:(NSArray<NSString *> *)presenceChannels {
    [self.lock writeAccessWithBlock:^{
        [self.presenceChannelsSet minusSet:[NSSet setWithArray:presenceChannels]];
    }];
}

- (NSNumber *)currentTimeToken {
    __block NSNumber *currentTimeToken = nil;
    
    [self.lock readAccessWithBlock:^{
        currentTimeToken = self->_currentTimeToken;
    }];

    return currentTimeToken;
}

- (void)setCurrentTimeToken:(NSNumber *)currentTimeToken {
    [self.lock writeAccessWithBlock:^{
        self->_currentTimeToken = currentTimeToken;
    }];
}

- (NSNumber *)lastTimeToken {
    __block NSNumber *lastTimeToken = nil;

    [self.lock readAccessWithBlock:^{
        lastTimeToken = self->_lastTimeToken;
    }];

    return lastTimeToken;
}

- (void)setLastTimeToken:(NSNumber *)lastTimeToken {
    [self.lock writeAccessWithBlock:^{
        self->_lastTimeToken = lastTimeToken;
    }];
}

- (NSNumber *)overrideTimeToken {
    __block NSNumber *overrideTimeToken = nil;

    [self.lock readAccessWithBlock:^{
        overrideTimeToken = self->_overrideTimeToken;
    }];

    return overrideTimeToken;
}

- (void)setOverrideTimeToken:(NSNumber *)overrideTimeToken {
    [self.lock writeAccessWithBlock:^{
        self->_overrideTimeToken = [PNNumber timeTokenFromNumber:overrideTimeToken];
    }];
}

- (NSNumber *)currentTimeTokenRegion {
    __block NSNumber *currentTimeTokenRegion = nil;
    
    [self.lock readAccessWithBlock:^{
        currentTimeTokenRegion = self->_currentTimeTokenRegion;
    }];

    return currentTimeTokenRegion;
}

- (void)setCurrentTimeTokenRegion:(NSNumber *)currentTimeTokenRegion {
    [self.lock writeAccessWithBlock:^{
        self->_currentTimeTokenRegion = currentTimeTokenRegion;
    }];
}

- (NSNumber *)lastTimeTokenRegion {
    __block NSNumber *lastTimeTokenRegion = nil;
    
    [self.lock readAccessWithBlock:^{
        lastTimeTokenRegion = self->_lastTimeTokenRegion;
    }];

    return lastTimeTokenRegion;
}

- (void)setLastTimeTokenRegion:(NSNumber *)lastTimeTokenRegion {
    [self.lock writeAccessWithBlock:^{
        self->_lastTimeTokenRegion = lastTimeTokenRegion;
    }];
}

- (void)updateStateTo:(PNSubscriberState)state
           withStatus:(PNStatus *)status
           completion:(void(^)(PNStatusCategory category))block {
    [self.lock writeAccessWithBlock:^{
        // Compose status object to report state change to listeners.
        PNStatusCategory category = PNUnknownCategory;
        PNSubscriberState targetState = state;
        PNSubscriberState currentState = self->_currentState;
        BOOL shouldHandleTransition = NO;
        
        if (targetState == PNConnectedSubscriberState) {
            self.mayRequireSubscriptionRestore = YES;
            category = PNConnectedCategory;
            
            // Check whether client transit from 'disconnected' -> 'connected' state.
            shouldHandleTransition = (currentState == PNInitializedSubscriberState ||
                                      currentState == PNDisconnectedSubscriberState ||
                                      currentState == PNConnectedSubscriberState);
            
            // Check whether client transit from 'access denied' -> 'connected' state.
            if (!shouldHandleTransition) shouldHandleTransition = currentState == PNAccessRightsErrorSubscriberState;
            
            // Check whether client transit from 'unexpected disconnect' -> 'connected' state
            if (!shouldHandleTransition && currentState == PNDisconnectedUnexpectedlySubscriberState) {
                // Change state to 'reconnected'
                targetState = PNConnectedSubscriberState;
                category = PNReconnectedCategory;
                shouldHandleTransition = YES;
            }
        } else if (targetState == PNDisconnectedSubscriberState ||
                   targetState == PNDisconnectedUnexpectedlySubscriberState) {
            
            /**
             * Check whether client transit from 'connected' -> 'disconnected'/'unexpected disconnect' state.
             * Also 'unexpected disconnect' -> 'disconnected' transition should be allowed for cases
             * when used want to unsubscribe from channel(s) after network went down.
             */
            shouldHandleTransition = (currentState == PNInitializedSubscriberState ||
                                      currentState == PNConnectedSubscriberState ||
                                      currentState == PNDisconnectedUnexpectedlySubscriberState);
            
            /**
             * In case if subscription restore failed after precious unexpected disconnect we should handle it.
             */
            shouldHandleTransition = (shouldHandleTransition ||
                                      (targetState == PNDisconnectedUnexpectedlySubscriberState &&
                                       targetState == currentState));
            category = ((targetState == PNDisconnectedSubscriberState) ? PNDisconnectedCategory :
                        PNUnexpectedDisconnectCategory);
            self.mayRequireSubscriptionRestore = shouldHandleTransition;
        } else if (targetState == PNAccessRightsErrorSubscriberState) {
            self.mayRequireSubscriptionRestore = NO;
            shouldHandleTransition = YES;
            category = PNAccessDeniedCategory;
        } else if (targetState == PNMalformedFilterExpressionErrorSubscriberState) {
            // Change state to 'Unexpected disconnect'
            targetState = PNDisconnectedUnexpectedlySubscriberState;
            
            self.mayRequireSubscriptionRestore = NO;
            shouldHandleTransition = YES;
            category = PNMalformedFilterExpressionCategory;
        } else if (targetState == PNPNRequestURITooLongErrorSubscriberState) {
            // Change state to 'Unexpected disconnect'
            targetState = PNDisconnectedUnexpectedlySubscriberState;
            
            self.mayRequireSubscriptionRestore = NO;
            shouldHandleTransition = YES;
            category = PNRequestURITooLongCategory;
        }
        
        // Check whether allowed state transition has been issued or not.
        if (shouldHandleTransition) {
            self->_currentState = targetState;

            /**
             * Build status object in case if update has been called as transition between two different states.
             */
            PNStatus *targetStatus = [status copy];
            if (!targetStatus) {
                targetStatus = [PNStatus objectWithOperation:PNSubscribeOperation category:category response:nil];
            }
            
            [targetStatus updateCategory:category];
            [self appendSubscriberInformation:targetStatus];
            
            [self.client.listenersManager notifyWithBlock:^{
                [self.client.listenersManager notifyStatusChange:(PNSubscribeStatus *)targetStatus];
            }];
        } else category = status ? status.category : PNUnknownCategory;
        
        if (block) {
            pn_dispatch_async(self.client.callbackQueue, ^{
                block(category);
            });
        }
    }];
}


#pragma mark - Initialization and Configuration

+ (instancetype)subscriberForClient:(PubNub *)client {
    return [[self alloc] initForClient:client];
}

- (instancetype)initForClient:(PubNub *)client {
    if ((self = [super init])) {
        _client = client;
        _channelsSet = [NSMutableSet new];
        _channelGroupsSet = [NSMutableSet new];
        _presenceChannelsSet = [NSMutableSet new];
        _cachedObjectIdentifiers = [NSMutableArray new];
        _cachedObjects = [NSMutableDictionary new];
        _currentTimeToken = @0;
        _lastTimeToken = @0;
        _lock = [PNLock lockWithIsolationQueueName:@"subscriber" subsystemQueueIdentifier:@"com.pubnub.subscriber"];
    }
    
    return self;
}

- (void)inheritStateFromSubscriber:(PNSubscriber *)subscriber {
    _presenceChannelsSet = [subscriber.presenceChannelsSet mutableCopy];
    _channelGroupsSet = [subscriber.channelGroupsSet mutableCopy];
    _channelsSet = [subscriber.channelsSet mutableCopy];
    
    if (_channelsSet.count || _channelGroupsSet.count || _presenceChannelsSet.count) {
        _currentState = PNDisconnectedSubscriberState;
    }
    
    _cachedObjects = [subscriber.cachedObjects mutableCopy];
    _cachedObjectIdentifiers = [subscriber.cachedObjectIdentifiers mutableCopy];
    _currentTimeTokenRegion = subscriber.currentTimeTokenRegion;
    _lastTimeTokenRegion = subscriber.lastTimeTokenRegion;
    _currentTimeToken = subscriber.currentTimeToken;
    _lastTimeToken = subscriber.lastTimeToken;
}


#pragma mark - Subscription

- (void)subscribeWithRequest:(PNSubscribeRequest *)request {
    BOOL shouldObservePresence = request.shouldObservePresence;
    NSArray *groups = request.channelGroups;
    NSArray *channels = request.channels;

    if (request.presenceOnly) {
        [self addPresenceChannels:[PNChannel presenceChannelsFrom:channels]];
    } else {
        if (channels.count) {
            NSArray *presenceList = shouldObservePresence ? [PNChannel presenceChannelsFrom:channels] : nil;
            NSArray *channelsForAddition = [channels arrayByAddingObjectsFromArray:presenceList];
            [self addChannels:channelsForAddition];
        }

        if (groups.count) {
            NSArray *presenceList = shouldObservePresence ? [PNChannel presenceChannelsFrom:groups] : nil;
            NSArray *groupsForAddition = [groups arrayByAddingObjectsFromArray:presenceList];
            [self addChannelGroups:groupsForAddition];
        }
    }

    self.restoringAfterNetworkIssues = NO;
    [self subscribe:YES 
     usingTimeToken:request.timetoken
          withState:request.state 
    queryParameters:request.arbitraryQueryParameters
         completion:nil];

}

- (void)subscribe:(BOOL)initialSubscribe
   usingTimeToken:(NSNumber *)timeToken
        withState:(NSDictionary<NSString *, id> *)state
  queryParameters:(NSDictionary *)queryParameters
       completion:(PNSubscriberCompletionBlock)handlerBlock; {
    PNSubscriberCompletionBlock block = [handlerBlock copy];
    
    /**
     * Silence static analyzer warnings.
     * Code is aware about this case and at the end will simply call on 'nil' object method.
     * In most cases if referenced object become 'nil' it mean what there is no more need in
     * it and probably whole client instance has been deallocated.
     */
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    if ([self allObjects].count) {
        if (!self.restoringAfterNetworkIssues) self.overrideTimeToken = timeToken;

        if (initialSubscribe) {
            [self.lock writeAccessWithBlock:^{
                self.mayRequireSubscriptionRestore = NO;
                
                if (self->_currentTimeToken && [self->_currentTimeToken compare:@0] != NSOrderedSame) {
                    self->_lastTimeToken = self->_currentTimeToken;
                }
                
                if (self->_currentTimeTokenRegion &&
                    [self->_currentTimeTokenRegion compare:@0] != NSOrderedSame &&
                    [self->_currentTimeTokenRegion compare:@(-1)] == NSOrderedDescending) {
                    
                    self->_lastTimeTokenRegion = self->_currentTimeTokenRegion;
                }
                
                self->_currentTimeToken = @0;
                self->_currentTimeTokenRegion = @(-1);
            }];
        }
        
        PNSubscribeRequest *request = [self subscribeRequestWithState:state];
        request.arbitraryQueryParameters = queryParameters;

        if (!initialSubscribe && block) {
            PNSubscribeStatus *status = [PNSubscribeStatus objectWithOperation:PNSubscribeOperation
                                                                      category:PNConnectedCategory
                                                                      response:nil];

            block(status);
            block = nil;
        }
        
        PNWeakify(self);
        [self.client subscribeWithRequest:request completion:^(PNSubscribeStatus *status) {
            PNStrongify(self);
            [self handleSubscriptionStatus:(PNSubscribeStatus *)status];

            if (block) {
                pn_dispatch_async(self.client.callbackQueue, ^{
                    block((PNSubscribeStatus *)status);
                });
            }
        }];
    } else {
        PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                                category:PNDisconnectedCategory
                                                response:nil];
        
        [self.lock writeAccessWithBlock:^{
            self->_lastTimeToken = @0;
            self->_currentTimeToken = @0;
            self->_lastTimeTokenRegion = @(-1);
            self->_currentTimeTokenRegion = @(-1);
            self->_restoringAfterNetworkIssues = NO;
            self->_overrideTimeToken = nil;
        }];

        if (block) {
            pn_dispatch_async(self.client.callbackQueue, ^{
                block((PNSubscribeStatus *)status);
            });
        }
        
        [self updateStateTo:PNDisconnectedSubscriberState
                 withStatus:(PNSubscribeStatus *)status
                 completion:^(PNStatusCategory category) {
            [self.client cancelSubscribeOperations];
            [status updateCategory:category];
            
            [self.client callBlock:nil status:YES withResult:nil andStatus:status];
        }];
    }
    #pragma clang diagnostic pop
}

- (void)restoreSubscriptionCycleIfRequiredWithCompletion:(PNSubscriberCompletionBlock)block {
    __block BOOL shouldRestore;
    __block BOOL ableToRestore;

    [self.lock readAccessWithBlock:^{
        shouldRestore = ((self.currentState == PNDisconnectedUnexpectedlySubscriberState &&
                          self.mayRequireSubscriptionRestore));
        ableToRestore = [self.channelsSet count] || [self.channelGroupsSet count] ||
                         [self.presenceChannelsSet count];
    }];

    if (shouldRestore && ableToRestore) {
        self.restoringAfterNetworkIssues = YES;
        
        [self subscribe:YES usingTimeToken:nil withState:nil queryParameters:nil completion:block];
    } else if (block) block(nil);
}

- (void)continueSubscriptionCycleIfRequiredWithCompletion:(PNSubscriberCompletionBlock)block {
    [self subscribe:NO usingTimeToken:nil withState:nil queryParameters:nil completion:block];
}

- (void)unsubscribeWithRequest:(PNPresenceLeaveRequest *)request completion:(PNSubscriberCompletionBlock)block {
    BOOL shouldObservePresence = request.shouldObservePresence;
    NSArray<NSString *> *groups = request.channelGroups;
    NSArray<NSString *> *channels = request.channels;

    if (request.presenceOnly) {
        channels = [PNChannel presenceChannelsFrom:channels];
        [self removePresenceChannels:channels];
        groups = nil;
    } else {
        if (channels.count) {
            NSArray *presenceList = shouldObservePresence ? [PNChannel presenceChannelsFrom:channels] : nil;
            NSArray *channelsForRemoval = [channels arrayByAddingObjectsFromArray:presenceList];
            [self removeChannels:channelsForRemoval];
        }

        if (groups.count) {
            NSArray *presenceList = shouldObservePresence ? [PNChannel presenceChannelsFrom:groups] : nil;
            NSArray *groupsForRemoval = [groups arrayByAddingObjectsFromArray:presenceList];
            [self removeChannelGroups:groupsForRemoval];
        }
    }

    [self unsubscribeFromChannels:channels
                           groups:groups
              withQueryParameters:request.arbitraryQueryParameters
            listenersNotification:YES
                       completion:block];
}

- (void)unsubscribeFromAllWithQueryParameters:(NSDictionary *)queryParameters
                                   completion:(PNSubscriberCompletionBlock)block {
    NSArray *channelGroups = [self.channelGroups copy];
    NSArray *channels = [self.channels copy];
    
    if (channels.count || channelGroups.count) {
        [self removeChannels:channels];
        [self removePresenceChannels:self.presenceChannels];
        [self removeChannelGroups:channelGroups];
        [self unsubscribeFromChannels:channels
                               groups:channelGroups
                  withQueryParameters:queryParameters
                listenersNotification:YES
                      subscribeOnRest:NO
                           completion:block];
    }
}

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels
                         groups:(NSArray<NSString *> *)groups
            withQueryParameters:(NSDictionary *)queryParameters
          listenersNotification:(BOOL)shouldInformListener
                     completion:(PNSubscriberCompletionBlock)block {
    [self unsubscribeFromChannels:channels
                           groups:groups
              withQueryParameters:queryParameters
            listenersNotification:shouldInformListener
                  subscribeOnRest:YES
                       completion:block];
}

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels
                         groups:(NSArray<NSString *> *)groups
            withQueryParameters:(NSDictionary *)queryParameters
          listenersNotification:(BOOL)shouldInformListener
                subscribeOnRest:(BOOL)subscribeOnRestChannels
                     completion:(nullable PNSubscriberCompletionBlock)block {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    [self.client.clientStateManager removeStateForObjects:channels];
    [self.client.clientStateManager removeStateForObjects:groups];
    NSArray *channelsWithOutPresence = nil;
    NSArray *groupsWithOutPresence = nil;

    if (channels.count) channelsWithOutPresence = [PNChannel objectsWithOutPresenceFrom:channels];
    if (groups.count) groupsWithOutPresence = [PNChannel objectsWithOutPresenceFrom:groups];

    PNAcknowledgmentStatus *successStatus = [PNAcknowledgmentStatus objectWithOperation:PNUnsubscribeOperation
                                                                               category:PNAcknowledgmentCategory
                                                                               response:nil];

    NSSet *subscriptionObjects = [NSSet setWithArray:[self allObjects]];
    if (subscriptionObjects.count == 0) {
        [self.lock writeAccessWithBlock:^{
            self->_lastTimeToken = @0;
            self->_currentTimeToken = @0;
            self->_lastTimeTokenRegion = @(-1);
            self->_currentTimeTokenRegion = @(-1);
            self->_restoringAfterNetworkIssues = NO;
            self->_overrideTimeToken = nil;
        }];
    }
    
    if (channelsWithOutPresence.count || groupsWithOutPresence.count) {
        PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithChannels:channelsWithOutPresence
                                                                        channelGroups:groupsWithOutPresence];
        request.arbitraryQueryParameters = queryParameters;

        PNWeakify(self);
        void(^updateCompletion)(PNStatusCategory) = ^(PNStatusCategory category) {
            PNStrongify(self);

            [successStatus updateCategory:category];
            [self.client callBlock:nil status:YES withResult:nil andStatus:successStatus];

            BOOL listChanged = ![[NSSet setWithArray:[self allObjects]] isEqualToSet:subscriptionObjects];

            if (subscribeOnRestChannels && (subscriptionObjects.count > 0 && !listChanged)) {
                [self subscribe:NO usingTimeToken:nil withState:nil queryParameters:nil completion:nil];
            }

            if (block) {
                pn_dispatch_async(self.client.callbackQueue, ^{
                    block((PNSubscribeStatus *)successStatus);
                });
            }
        };

        PNSubscriberCompletionBlock unsubscribeCompletionBlock = ^(PNSubscribeStatus *status1) {
            PNStrongify(self);
            if (shouldInformListener) {
                PNSubscriberState state = PNDisconnectedSubscriberState;
                if (status1.category == PNAccessDeniedCategory) state = PNAccessRightsErrorSubscriberState;

                [self updateStateTo:state withStatus:successStatus completion:updateCompletion];
            } else updateCompletion(successStatus.category);
        };


        if (!self.client.configuration.shouldSuppressLeaveEvents) {
            [self.client unsubscribeWithRequest:request completion:unsubscribeCompletionBlock];
        } else unsubscribeCompletionBlock(nil);
    } else {
        PNWeakify(self);
        [self subscribe:YES usingTimeToken:nil withState:nil queryParameters:nil completion:^(__unused PNStatus *status) {
            PNStrongify(self);

            if (block) {
                pn_dispatch_async(self.client.callbackQueue, ^{
                    block((PNSubscribeStatus *)successStatus);
                });
            }
                 
            void(^updateCompletion)(PNStatusCategory) = ^(PNStatusCategory category) {
                [successStatus updateCategory:category];
                [self.client callBlock:nil status:YES withResult:nil andStatus:successStatus];
            };
                 
            if (shouldInformListener) {
                [self updateStateTo:PNDisconnectedSubscriberState
                         withStatus:(PNSubscribeStatus *)successStatus
                         completion:updateCompletion];
            } else updateCompletion(successStatus.category);
        }];
    }
    #pragma clang diagnostic pop
}


#pragma mark - Handlers

- (void)handleSubscriptionStatus:(PNSubscribeStatus *)status {
    if (!status.isError && status.category != PNCancelledCategory) [self handleSuccessSubscriptionStatus:status];
    else [self handleFailedSubscriptionStatus:status];
}

- (void)handleSuccessSubscriptionStatus:(PNSubscribeStatus *)status {
    NSNumber *overrideTimeToken = self.overrideTimeToken;
    BOOL initialSubscribe = status.isInitialSubscription;

    [self handleSubscription:initialSubscribe timeToken:status.data.cursor.timetoken region:status.data.cursor.region];
    [self handleLiveFeedEvents:status forInitialSubscription:initialSubscribe overrideTimeToken:overrideTimeToken];

    if (!self.client.configuration.shouldManagePresenceListManually) {
        [self.client.heartbeatManager startHeartbeatIfRequired];
    }

    if (initialSubscribe) {
        [self updateStateTo:PNConnectedSubscriberState withStatus:status completion:^(PNStatusCategory category) {
            [status updateCategory:category];
            [self.client callBlock:nil status:YES withResult:nil andStatus:(PNStatus *)status];
        }];
    }
}

- (void)handleFailedSubscriptionStatus:(PNSubscribeStatus *)status {
    PNStatusCategory statusCategory = status.category;

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    if (statusCategory == PNCancelledCategory) {
        if (!self.client.configuration.shouldManagePresenceListManually) {
            [self.client.heartbeatManager stopHeartbeatIfPossible];
        }
    } else {
        if (statusCategory == PNAccessDeniedCategory ||
            statusCategory == PNTimeoutCategory ||
            statusCategory == PNMalformedFilterExpressionCategory ||
            statusCategory == PNMalformedResponseCategory ||
            statusCategory == PNRequestURITooLongCategory ||
            statusCategory == PNTLSConnectionFailedCategory) {
            PNSubscriberState subscriberState = PNAccessRightsErrorSubscriberState;
            
            if (statusCategory != PNMalformedFilterExpressionCategory && statusCategory != PNRequestURITooLongCategory)
                ((PNStatus *)status).requireNetworkAvailabilityCheck = NO;

            if (statusCategory == PNMalformedFilterExpressionCategory) {
                subscriberState = PNMalformedFilterExpressionErrorSubscriberState;
            } else if(statusCategory == PNRequestURITooLongCategory) {
                subscriberState = PNPNRequestURITooLongErrorSubscriberState;
            }
            
            if (statusCategory != PNAccessDeniedCategory &&
                statusCategory != PNMalformedFilterExpressionCategory &&
                statusCategory != PNRequestURITooLongCategory) {
                
                subscriberState = PNDisconnectedUnexpectedlySubscriberState;
                [(PNStatus *)status updateCategory:PNUnexpectedDisconnectCategory];
            }
            
            [self updateStateTo:subscriberState withStatus:status completion:nil];
        } else {
            ((PNStatus *)status).requireNetworkAvailabilityCheck = YES;

            [self.lock writeAccessWithBlock:^{
                if (self.client.configuration.shouldTryCatchUpOnSubscriptionRestore) {
                    if (self->_currentTimeToken &&
                        [self->_currentTimeToken compare:@0] != NSOrderedSame) {
                        
                        self->_lastTimeToken = self->_currentTimeToken;
                        self->_currentTimeToken = @0;
                    }
                    
                    if (self->_currentTimeTokenRegion &&
                        [self->_currentTimeTokenRegion compare:@0] != NSOrderedSame &&
                        [self->_currentTimeTokenRegion compare:@(-1)] == NSOrderedDescending) {
                        
                        self->_lastTimeTokenRegion = self->_currentTimeTokenRegion;
                        self->_currentTimeTokenRegion = @(-1);
                    }
                } else {
                    self->_currentTimeToken = @0;
                    self->_lastTimeToken = @0;
                    self->_currentTimeTokenRegion = @(-1);
                    self->_lastTimeTokenRegion = @(-1);
                }
            }];

            [(PNStatus *)status updateCategory:PNUnexpectedDisconnectCategory];
            
            if (!self.client.configuration.shouldManagePresenceListManually) {
                [self.client.heartbeatManager stopHeartbeatIfPossible];
            }
            
            [self updateStateTo:PNDisconnectedUnexpectedlySubscriberState withStatus:status completion:nil];
        }
    }
    
    [self.client callBlock:nil status:YES withResult:nil andStatus:(PNStatus *)status];
    #pragma clang diagnostic pop
}

- (void)handleSubscription:(BOOL)initialSubscription timeToken:(NSNumber *)timeToken region:(NSNumber *)region {
    [self.lock writeAccessWithBlock:^{
        BOOL restoringAfterNetworkIssues = self->_restoringAfterNetworkIssues;
        self->_restoringAfterNetworkIssues = NO;
        BOOL shouldAcceptNewTimeToken = YES;
        
        // Whether time token should be overridden despite subscription behavior configuration.
        BOOL shouldOverrideTimeToken = (initialSubscription && self->_overrideTimeToken &&
                                        [self->_overrideTimeToken compare:@0] != NSOrderedSame);

        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
        if (initialSubscription) {
            // 'shouldKeepTimeTokenOnListChange' property should never allow to reset time tokens in
            // case if there is a few more subscribe requests is waiting for their turn to be sent.
            BOOL shouldUseLastTimeToken = self.client.configuration.shouldKeepTimeTokenOnListChange;
            
            if (!shouldUseLastTimeToken && restoringAfterNetworkIssues) {
                shouldUseLastTimeToken = self.client.configuration.shouldTryCatchUpOnSubscriptionRestore;
            }
            
            shouldUseLastTimeToken = (shouldUseLastTimeToken && !shouldOverrideTimeToken);
            
            // Ensure what we already don't use value from previous time token assigned during
            // previous sessions.
            if (shouldUseLastTimeToken && self->_lastTimeToken &&
                [self->_lastTimeToken compare:@0] != NSOrderedSame) {
                shouldAcceptNewTimeToken = NO;
                
                // Swap time tokens to catch up on events which happened while client changed
                // channels and groups list configuration.
                self->_currentTimeToken = self->_lastTimeToken;
                self->_lastTimeToken = @0;
                self->_currentTimeTokenRegion = self->_lastTimeTokenRegion;
                self->_lastTimeTokenRegion = @(-1);
            }
        }
        #pragma clang diagnostic pop
        // Ensure what client won't handle delayed requests. It is impossible to have non-initial
        // subscription while current time token report 0.
        if (!initialSubscription && self->_currentTimeToken && [self->_currentTimeToken compare:@0] == NSOrderedSame)
            shouldAcceptNewTimeToken = NO;
        
        if (shouldAcceptNewTimeToken) {
            if (self->_currentTimeToken && [self->_currentTimeToken compare:@0] != NSOrderedSame) {
                self->_lastTimeToken = self->_currentTimeToken;
            }

            if (self->_currentTimeTokenRegion && [self->_currentTimeTokenRegion compare:@0] != NSOrderedSame &&
                [self->_currentTimeTokenRegion compare:@(-1)] == NSOrderedDescending) {
                
                self->_lastTimeTokenRegion = self->_currentTimeTokenRegion;
            }
            self->_currentTimeToken = (shouldOverrideTimeToken ? self->_overrideTimeToken : timeToken);
            self->_currentTimeTokenRegion = region;
        }
        
        self->_overrideTimeToken = nil;
    }];
}

- (void)handleLiveFeedEvents:(PNSubscribeStatus *)status forInitialSubscription:(BOOL)initialSubscription overrideTimeToken:(NSNumber *)overrideTimeToken {
    NSUInteger messageCountThreshold = self.client.configuration.requestMessageCountThreshold;
    NSMutableArray<PNSubscribeEventData *> *events = [status.data.updates mutableCopy];
    NSUInteger eventsCount = events.count;
    
    if (!events.count) {
        [self continueSubscriptionCycleIfRequiredWithCompletion:nil];
        return;
    }

    [self.client.listenersManager notifyWithBlock:^{
        // Check whether after initial subscription client should use user-provided timetoken to catch up on messages 
        // since specified date.
        if (initialSubscription && overrideTimeToken && [overrideTimeToken compare:@0] != NSOrderedSame) {
            [self clearCacheFromMessagesNewerThan:overrideTimeToken];
        }

        // Remove message duplicates from received events list.
        [self deDuplicateMessages:events];
        [self continueSubscriptionCycleIfRequiredWithCompletion:nil];

        // Check whether number of messages exceed specified threshold or not.
        if (messageCountThreshold > 0 && eventsCount >= messageCountThreshold) {
            PNSubscribeStatus *exceedStatus = [status copy];
            exceedStatus.responseData = nil;

            [exceedStatus updateCategory:PNRequestMessageCountExceededCategory];
            [self.client.listenersManager notifyStatusChange:exceedStatus];
        }

        // Iterate through array with notifications and report back using callback blocks to the
        // user.
        for (PNSubscribeEventData *event in events) {
            NSInteger messageType = event.messageType.integerValue;
            id resultObject;

            if (messageType == PNPresenceMessageType) {
                resultObject = [PNPresenceEventResult objectWithOperation:PNSubscribeOperation response:event];
                [self handleNewPresenceEvent:((PNPresenceEventResult *)resultObject)];
            } else if (messageType == PNRegularMessageType) {
                resultObject = [PNMessageResult objectWithOperation:PNSubscribeOperation response:event];
                [self handleNewMessage:((PNMessageResult *)resultObject)];
            } else if (messageType == PNSignalMessageType) {
                resultObject = [PNSignalResult objectWithOperation:PNSubscribeOperation response:event];
                [self handleNewSignal:((PNSignalResult *)resultObject)];
            } else if (messageType == PNObjectMessageType) {
                resultObject = [PNObjectEventResult objectWithOperation:PNSubscribeOperation response:event];
                [self handleNewObjectsEvent:((PNObjectEventResult *)resultObject)];
            } else if (messageType == PNMessageActionType) {
                resultObject = [PNMessageActionResult objectWithOperation:PNSubscribeOperation response:event];
                [self handleNewMessageAction:((PNMessageActionResult *)resultObject)];
            } else if (messageType == PNFileMessageType) {
                resultObject = [PNFileEventResult objectWithOperation:PNSubscribeOperation response:event];
                [self handleNewFileEvent:((PNFileEventResult *)resultObject)];
            }
        }
    }];

}

- (void)handleNewMessage:(PNMessageResult *)message {
    if (!message) return;

    PNErrorStatus *status = nil;

    if (message.data.decryptionError) {
        status = [PNErrorStatus objectWithOperation:PNSubscribeOperation
                                           category:PNDecryptionErrorCategory
                                           response:nil];
        status.associatedObject = message.data;
    }

    if (status) {
        [self.client.logger errorWithLocation:@"PNSubscriber" andMessageFactory:^PNLogEntry * {
            NSError *error = message.data.decryptionError;
            if (!error) return nil;
            NSString *errorMessage = error.localizedFailureReason ?: error.localizedDescription;
            return [PNDictionaryLogEntry entryWithMessage:@{ @"error": errorMessage }
                                                  details:@"Message decryption error:"];
        }];
        
        [self.client.listenersManager notifyStatusChange:(id)status];
    }
    else if (message) [self.client.listenersManager notifyMessage:message];
}

- (void)handleNewSignal:(PNSignalResult *)signal {
    if (!signal) return;

    [self.client.listenersManager notifySignal:signal];
}

- (void)handleNewMessageAction:(PNMessageActionResult *)action {
    if (!action) return;

    [self.client.listenersManager notifyMessageAction:action];
}

- (void)handleNewObjectsEvent:(PNObjectEventResult *)object {
    if (!object) return;

    [self.client.listenersManager notifyObjectEvent:object];
}

- (void)handleNewFileEvent:(PNFileEventResult *)file {
    PNErrorStatus *status = nil;
    
    if (file) {
        if (file.data.decryptionError) {
            status = [PNErrorStatus objectWithOperation:PNSubscribeOperation
                                               category:PNDecryptionErrorCategory
                                               response:nil];
            status.associatedObject = file.data;
        } else {
            NSURL *url = [self.client downloadURLForFileWithName:file.data.file.name
                                                      identifier:file.data.file.identifier
                                                       inChannel:file.data.channel];
            file.data.file.downloadURL = url;
        }
    }

    if (status) {
        [self.client.logger errorWithLocation:@"PNSubscriber" andMessageFactory:^PNLogEntry * {
            NSError *error = file.data.decryptionError;
            if (!error) return nil;
            
            NSString *errorMessage = error.localizedFailureReason ?: error.localizedDescription;
            return [PNDictionaryLogEntry entryWithMessage:@{ @"error": errorMessage }
                                                  details:@"File message decryption error:"];
        }];
        
        [self.client.listenersManager notifyStatusChange:(id)status];
    }
    else if (file) [self.client.listenersManager notifyFileEvent:file];
}

- (void)handleNewPresenceEvent:(PNPresenceEventResult *)presence {
    [self.client.listenersManager notifyPresenceEvent:presence];
}


#pragma mark - Misc

- (PNSubscribeRequest *)subscribeRequestWithState:(NSDictionary<NSString *, id> *)state {
    // Compose full list of channels and groups stored in active subscription list.
    NSArray *channels = [[self channels] arrayByAddingObjectsFromArray:[self presenceChannels]];
    NSArray *groups = [self channelGroups];
    NSArray *fullObjectsList = [channels arrayByAddingObjectsFromArray:groups];

    NSDictionary *mergedState = [self.client.clientStateManager stateMergedWith:state forObjects:fullObjectsList];
    [self.client.clientStateManager mergeWithState:mergedState];
    
    // Extract state information only for channels and groups which is used in subscribe loop.
    if (self.client.configuration.shouldManagePresenceListManually) {
        NSMutableDictionary *filteredState = [NSMutableDictionary dictionaryWithDictionary:mergedState];
        NSMutableArray *mergedStateKeys = [NSMutableArray arrayWithArray:mergedState.allKeys];
        
        [mergedStateKeys removeObjectsInArray:fullObjectsList];
        [filteredState removeObjectsForKeys:mergedStateKeys];
        
        mergedState = filteredState;
    }

    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:channels channelGroups:groups];
    request.timetoken = self.currentTimeToken;
    request.state = mergedState;

    if ([self.currentTimeTokenRegion compare:@(-1)] == NSOrderedDescending) request.region = self.currentTimeTokenRegion;
    
    return request;
}

- (void)deDuplicateMessages:(NSMutableArray<PNSubscribeEventData *> *)events {
    NSUInteger cacheSize = self.client.configuration.maximumMessagesCacheSize;

    if (cacheSize > 0) {
        NSMutableIndexSet *duplicateMessagesIndices = [NSMutableIndexSet indexSet];
        [events enumerateObjectsUsingBlock:^(PNSubscribeEventData *event, NSUInteger eventIdx,
                                             BOOL *eventsEnumeratorStop) {
            PNMessageType messageType = event.messageType.integerValue;
            BOOL isMessageEvent = messageType == PNRegularMessageType || messageType == PNSignalMessageType;
            BOOL isPresenceEvent = messageType == PNPresenceMessageType;
            NSError *decryptionError;

            if (messageType == PNRegularMessageType || messageType == PNFileMessageType) {
                decryptionError = ((PNSubscribeMessageEventData *)event).decryptionError;
            }

            if (!isPresenceEvent && !decryptionError && isMessageEvent &&
                ![self cacheObjectIfPossible:(PNSubscribeMessageEventData *)event withMaximumCacheSize:cacheSize]) {

                [duplicateMessagesIndices addIndex:eventIdx];
            }
        }];
        
        if (duplicateMessagesIndices.count) [events removeObjectsAtIndexes:duplicateMessagesIndices];
        [self cleanUpCachedObjectsIfRequired:cacheSize];
    }
}

- (void)clearCacheFromMessagesNewerThan:(NSNumber *)timetoken {
    NSUInteger maximumMessagesCacheSize = self.client.configuration.maximumMessagesCacheSize;
    
    if (maximumMessagesCacheSize > 0) {
        SEL sortSelector = @selector(localizedCaseInsensitiveCompare:);
        NSArray<NSString *> *identifiers = [[_cachedObjects allKeys] sortedArrayUsingSelector:sortSelector];
        NSString *timetokenString = timetoken.stringValue;
        __block NSUInteger indexOfMessage = NSNotFound;
        [identifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger identifierIdx, 
                                                  BOOL *identifiersEnumeratorStop) {
            
            NSString *cachedTimetoken = [identifier componentsSeparatedByString:@"_"][0];
            NSComparisonResult result = [timetokenString compare:cachedTimetoken options:NSNumericSearch];
            
            if (result == NSOrderedSame || result == NSOrderedAscending) {
                indexOfMessage = identifierIdx;
            }
            
            *identifiersEnumeratorStop = (indexOfMessage != NSNotFound);
        }];
        
        if (indexOfMessage != NSNotFound) {
            NSRange messagesRange = NSMakeRange(indexOfMessage, identifiers.count - indexOfMessage);
            identifiers = [identifiers subarrayWithRange:messagesRange];
            [_cachedObjects removeObjectsForKeys:identifiers];
            [_cachedObjectIdentifiers removeObjectsInArray:identifiers];
        }
    }
}

- (BOOL)cacheObjectIfPossible:(PNSubscribeMessageEventData *)object withMaximumCacheSize:(NSUInteger)size {
    BOOL cached = NO;
    NSString *identifier = [@[object.timetoken.stringValue, object.channel] componentsJoinedByString:@"_"];
    NSMutableArray *objects = _cachedObjects[identifier]?: [NSMutableArray new];
    NSUInteger cachedMessagesCount = objects.count;
    
    // Cache objects if required.
    id data = object.message;

    if (data && (objects.count == 0 || [objects indexOfObject:data] == NSNotFound)) {
        cached = YES; 
        [objects addObject:data];
        [_cachedObjectIdentifiers addObject:identifier];
    }
    
    if (cachedMessagesCount == 0) _cachedObjects[identifier] = objects;
    
    return cached;
}

- (void)cleanUpCachedObjectsIfRequired:(NSUInteger)maximumCacheSize {
    while (_cachedObjectIdentifiers.count > maximumCacheSize) {
        NSString *identifier = [_cachedObjectIdentifiers objectAtIndex:0];
        NSMutableArray *objects = _cachedObjects[identifier];
        
        if (objects.count == 1) [_cachedObjects removeObjectForKey:identifier];
        else [objects removeObjectAtIndex:0];
        
        [_cachedObjectIdentifiers removeObjectAtIndex:0];
    }
}

- (void)appendSubscriberInformation:(PNStatus *)status {
    status.currentTimetoken = _currentTimeToken;
    status.lastTimeToken = _lastTimeToken;
    status.currentTimeTokenRegion = _currentTimeTokenRegion;
    status.lastTimeTokenRegion = _lastTimeTokenRegion;
    status.subscribedChannels = [_channelsSet setByAddingObjectsFromSet:_presenceChannelsSet].allObjects;
    status.subscribedChannelGroups = _channelGroupsSet.allObjects;
}

#pragma mark -


@end
