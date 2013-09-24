//
//  PNMessagingChannel.m
//  pubnub
//
//  This channel instance is required for messages exchange between client and
//  PubNub service:
//      - channels messages (subscribe)
//      - channels presence events
//      - leave
//
//  Notice: don't try to create more than one messaging channel on MacOS
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNMessagingChannel.h"
#import "PNConnectionChannel+Protected.h"
#import "PNChannelEventsResponseParser.h"
#import "PNChannelPresence+Protected.h"
#import "PNPresenceEvent+Protected.h"
#import "PNChannelEvents+Protected.h"
#import "PNDefaultConfiguration.h"
#import "PNMessage+Protected.h"
#import "PNChannel+Protected.h"
#import "PNOperationStatus.h"
#import "PubNub+Protected.h"
#import "PNRequestsImport.h"
#import "PNRequestsQueue.h"
#import "PNResponse.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub messaging connection channel must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Statics

typedef NS_OPTIONS(NSUInteger, PNMessagingConnectionStateFlag)  {

    // Channel currently tries to restore subscription on channels which he was subscribed before or which
    // didn't get response from server (stored have more value when selecting re-subscription route)
    PNMessagingChannelRestoringSubscription = 1 << 0,

    // Channel currently tries to update subscription on channels (send request with updated time tokens)
    PNMessagingChannelUpdateSubscription = 1 << 1,

    // Channel currently tries to retrieve next subscription token which should be used for long-poll
    // subscription request
    PNMessagingChannelSubscriptionTimeTokenRetrieve = 1 << 2,

    // Channel scheduled long-poll request and waiting for new events from channel on which it is subscribed
    PNMessagingChannelSubscriptionWaitingForEvents = 1 << 3,

    // Channel restoring connection after server terminated it
    PNMessagingChannelRestoringConnectionTerminatedByServer = 1 << 4,

    // Channel trying to enable presence on particular channels
    PNMessagingChannelEnablingPresence = 1 << 5,

    // Channel trying to enable presence on particular channels
    PNMessagingChannelDisablingPresence = 1 << 6,
};


#pragma mark - Private interface methods

@interface PNMessagingChannel ()


#pragma mark - Properties

// Stores list of channels (including presence) on which this client is subscribed now
@property (nonatomic, strong) NSMutableSet *subscribedChannelsSet;
@property (nonatomic, strong) NSSet *oldSubscribedChannelsSet;

// Stores whether on subscription request should be reset when rescheduling requests or not
@property (nonatomic, assign, getter = isRestoringSubscriptionOnResume) BOOL restoringSubscriptionOnResume;

// Stores current messaging channel state
@property (nonatomic, assign) unsigned long messagingState;

@property (nonatomic, strong) NSTimer *idleTimer;
@property (nonatomic, strong) NSDate *idleTimerFireDate;
@property (nonatomic, strong) NSDate *channelSuspensionDate;


#pragma mark - Instance methods

#pragma mark - Presence observation management

- (void)disablePresenceObservationForChannels:(NSArray *)channels sendRequest:(BOOL)shouldSendRequest;


#pragma mark - Channels management

/**
 * Returns whether messaging channel can resubscribe on channels or not. Will return YES if there is some channels
 * on which it can resubscribe, NO in other case.
 */
- (BOOL)canResubscribe;

/**
 * Will restore channels subscription if doesn't set that it should resubscribe
 */
- (void)restoreSubscription:(BOOL)shouldRestoreSubscriptionFromLastTimeToken;

/**
 * Will try to resubscribe on channels to which it was subscribed before (mostly this method will be used to restore
 * subscription because of new request failure)
 */
- (void)restoreSubscriptionOnPreviousChannels;

/**
 * Same function as -subscribeOnChannels:withPresenceEvent: but also allow to specify whether should perform
 * any changes in specified channels list as for presence enabling/disabling
 */
- (void)subscribeOnChannels:(NSArray *)channels
          withPresenceEvent:(BOOL)withPresenceEvent
                   presence:(NSUInteger)channelsPresence;

/**
 * Same function as -unsubscribeFromChannelsWithPresenceEvent: but also allow to specify whether leave was
 * triggered by user or not
 */
- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent
                                        byUserRequest:(BOOL)isLeavingByUserRequest;

/**
 * Same function as -unsubscribeFromChannels:withPresenceEvent: but also allow to specify whether leave was
 * triggered by user or not
 */
- (void)unsubscribeFromChannels:(NSArray *)channels
              withPresenceEvent:(BOOL)withPresenceEvent
                  byUserRequest:(BOOL)isLeavingByUserRequest;

/**
 * Same as -updateSubscription but allow to specify on which channels subscription should be updated
 */
- (void)updateSubscriptionForChannels:(NSArray *)channels;


#pragma mark - Presence management

/**
 * Send leave event to all channels to which client subscribed at this moment
 *
 * As soon as client will receive leave request confirmation all messages from unsubscribed channels will be ignored
 */
- (void)leaveSubscribedChannelsByUserRequest:(BOOL)isLeavingByUserRequest;

- (void)leaveChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest;


#pragma mark - Handler methods

/**
 * Called every time when client complete leave request processing
 */
- (void)handleLeaveRequestCompletionForChannels:(NSArray *)channels
                                   withResponse:(PNResponse *)response
                                  byUserRequest:(BOOL)isLeavingByUserRequest;

/**
 * Called every time when one of events occur on channels:
 *     - initial subscribe
 *     - message
 *     - presence event
 */
- (void)handleEventOnChannelsForRequest:(PNSubscribeRequest *)request withResponse:(PNResponse *)response;

/**
 * Called every time when subscribe request fails
 */
- (void)handleSubscribeDidFail:(PNBaseRequest *)request withError:(PNError *)error;

/**
 * Called every time when subscribe request fails
 */
- (void)handleUnsubscribeDidFail:(PNBaseRequest *)request withError:(PNError *)error;

/**
 * Handle Idle timer trigger and reconnect channel if it is possible
 */
- (void)handleIdleTimer:(NSTimer *)timer;


#pragma mark - Misc methods

/**
 * Start/stop channel idle handler timer. This timer allow to detect situation when client is in idle state
 * longer than this is allowed.
 */
- (void)startChannelIdleTimer;
- (void)stopChannelIdleTimer;
- (void)pauseChannelIdleTimer;
- (void)resumeChannelIdleTimer;

/**
 * Retrieve full list of channels on which channel should subscribe including presence observing channels
 */
- (NSSet *)channelsWithPresenceFromList:(NSArray *)channelsList forSubscribe:(BOOL)listForSubscribe;
- (NSSet *)channelsWithPresenceFromList:(NSArray *)channelsList forSubscribe:(BOOL)listForSubscribe
                           onlyPresence:(BOOL)fetchPresenceChannelsOnly;

/**
 * Retrieve list of channels which is cleared from presence observing instances
 */
- (NSArray *)channelsWithOutPresenceFromList:(NSArray *)channelsList;
- (NSArray *)channelsWithPresenceFromList:(NSArray *)channelsList;

/**
 * Print out current connection channel state
 */
- (NSString *)stateDescription;


@end


#pragma mark Public interface methods

@implementation PNMessagingChannel


#pragma mark - Class methods

+ (PNMessagingChannel *)messageChannelWithDelegate:(id<PNConnectionChannelDelegate>)delegate {

    return (PNMessagingChannel *)[super connectionChannelWithType:PNConnectionChannelMessaging andDelegate:delegate];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType andDelegate:(id<PNConnectionChannelDelegate>)delegate {

    // Check whether initialization was successful or not
    if ((self = [super initWithType:PNConnectionChannelMessaging andDelegate:delegate])) {

        PNBitClear(&_messagingState);
        self.subscribedChannelsSet = [NSMutableSet set];
    }


    return self;
}

- (BOOL)shouldHandleResponse:(PNResponse *)response {

    return ([response.callbackMethod hasPrefix:PNServiceResponseCallbacks.subscriptionCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.leaveChannelCallback]);
}

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request {

    // Check whether 'Leave' request has been processed or not
    if ([request isKindOfClass:[PNLeaveRequest class]] ||
        [response.callbackMethod isEqualToString:PNServiceResponseCallbacks.leaveChannelCallback]) {

        // Process leave request process completion
        [self handleLeaveRequestCompletionForChannels:((PNLeaveRequest *)request).channels
                                         withResponse:response
                                        byUserRequest:[request isSendingByUserRequest]];

        // Remove request from queue to unblock it (subscribe events and message post requests was blocked)
        [self destroyRequest:request];
    }
    // Check whether 'Subscription'/'Presence'/'Events' request has been processed or not
    else if (request == nil || [request isKindOfClass:[PNSubscribeRequest class]]) {

        // Remove request from queue to unblock it (subscribe events and message post requests was blocked)
        [self destroyRequest:request];

        // Process subscription on channels
        [self handleEventOnChannelsForRequest:(PNSubscribeRequest *)request withResponse:response];
    }
}

- (void)rescheduleStoredRequests:(NSArray *)requestsList {

    requestsList = [requestsList copy];
    if ([requestsList count] > 0) {

        BOOL useLastTimeToken = [self.messagingDelegate shouldMessagingChannelRestoreWithLastTimeToken:self];
        [requestsList enumerateObjectsWithOptions:NSEnumerationReverse
                                       usingBlock:^(id requestIdentifier, NSUInteger requestIdentifierIdx,
                                                    BOOL *requestIdentifierEnumeratorStop) {

               PNBaseRequest *request = [self storedRequestWithIdentifier:requestIdentifier];

               [request reset];
               request.closeConnection = NO;

               BOOL isSubscribeRequest = [request isKindOfClass:[PNSubscribeRequest class]];
               if ([request isKindOfClass:[PNSubscribeRequest class]] && self.isRestoringSubscriptionOnResume) {

                   if (!useLastTimeToken) {

                       [(PNSubscribeRequest *)request resetTimeToken];
                   }
               }

               // Check whether client is waiting for request completion
               BOOL isWaitingForCompletion = [self isWaitingRequestCompletion:request.shortIdentifier];
               if (isSubscribeRequest) {

                   NSString *timeToken = [PNChannel largestTimetokenFromChannels:((PNSubscribeRequest *)request).channels];
                   isWaitingForCompletion = [timeToken isEqualToString:@"0"];
               }

               // Clean up query (if request has been stored in it)
               [self destroyRequest:request];

               // Send request back into queue with higher priority among other requests
               [self scheduleRequest:request
             shouldObserveProcessing:isWaitingForCompletion
                          outOfOrder:YES
                    launchProcessing:NO];
           }];

        [self scheduleNextRequest];
    }
}

- (BOOL)shouldStoreRequest:(PNBaseRequest *)request {

    BOOL shouldStoreRequest = [request isKindOfClass:[PNSubscribeRequest class]] ||
                              [request isKindOfClass:[PNLeaveRequest class]];
    if (!shouldStoreRequest && [request isKindOfClass:[PNTimeTokenRequest class]]) {

        shouldStoreRequest = request.isSendingByUserRequest;
    }


    return shouldStoreRequest;
}

- (void)terminate {

    PNBitClear(&_messagingState);

    [self stopChannelIdleTimer];
    [super terminate];
}


#pragma mark - Connection management

- (void)reconnect {

    PNBitClear(&_messagingState);

    // Forward to the super class
    [super reconnect];
}

- (void)disconnectWithReset:(BOOL)shouldResetCommunicationChannel {

    PNBitClear(&_messagingState);
    self.oldSubscribedChannelsSet = nil;

    // Forward to the super class
    [super disconnect];


    // Check whether communication channel should reset state or not
    if (shouldResetCommunicationChannel) {

        // Clean up channels stack
        [self.subscribedChannelsSet removeAllObjects];
        [self purgeObservedRequestsPool];
        [self purgeStoredRequestsPool];
        [self clearScheduledRequestsQueue];
    }
}

- (void)disconnectWithEvent:(BOOL)shouldNotifyOnDisconnection {

    PNBitClear(&_messagingState);

    [self stopChannelIdleTimer];


    // Forward to the super class
    [super disconnectWithEvent:shouldNotifyOnDisconnection];
}

- (void)suspend {

    PNBitClear(&_messagingState);

    if (![super isSuspended]) {

        [super suspend];
    }

    [self pauseChannelIdleTimer];
}

- (void)resume {

    PNBitClear(&_messagingState);

    if ([super isSuspended]) {

        [super resume];
    }

    [self resumeChannelIdleTimer];
}


#pragma mark - Presence management

- (void)leaveSubscribedChannelsByUserRequest:(BOOL)isLeavingByUserRequest {

    // Check whether there some channels which user can leave
    if ([self.subscribedChannelsSet count] > 0) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] LEAVING ALL CHANNELS... (STATE: %d)",
              self, self.messagingState);

        [self leaveChannels:[self.subscribedChannelsSet allObjects] byUserRequest:isLeavingByUserRequest];
    }
}

- (void)leaveChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest {

    // Check whether specified channels set contains channels on which client not subscribed
    NSSet *channelsSet = [NSSet setWithArray:channels];
    if (![self.subscribedChannelsSet intersectsSet:channelsSet]) {

        // Extracting channels on which client is not subscribed at this moment
        // (set will contain only those channels, on which client subscribed at this moment)
        NSMutableSet *filteredChannels = [self.subscribedChannelsSet mutableCopy];
        [filteredChannels intersectSet:channelsSet];

        // Retrieve list of channel on which client really subscribed (other channels ignored)
        channelsSet = filteredChannels;
    }

    // Retrieve set of channels (including presence observers) from which client should unsubscribe
    NSArray *channelsForUnsubscribe = [[self channelsWithPresenceFromList:[channelsSet allObjects] forSubscribe:NO] allObjects];
    if ([channelsForUnsubscribe count] > 0) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] LEAVING SPECIFIC SET OF CHANNELS... (STATE: %d)",
              self, self.messagingState);

        // Reset last update time token for channels in list
        [channels makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];

        // Schedule request to be processed as soon as queue will be processed
        PNLeaveRequest *request = [PNLeaveRequest leaveRequestForChannels:channelsForUnsubscribe
                                                            byUserRequest:isLeavingByUserRequest];

        request.closeConnection = isLeavingByUserRequest;
        if (!isLeavingByUserRequest) {

            // Check whether connection channel is waiting for response via long-poll connection or not
            request.closeConnection = PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
        }
        if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {

            request.closeConnection = NO;
        }

        PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
                                    BITS_LIST_TERMINATOR);

        if (isLeavingByUserRequest) {

            [self.messagingDelegate messagingChannel:self willUnsubscribeFromChannels:request.channels];
        }
        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self scheduleRequest:request shouldObserveProcessing:YES];

    }
}


#pragma mark - Channels management

- (NSArray *)subscribedChannels {

    return [self channelsWithOutPresenceFromList:[self.subscribedChannelsSet allObjects]];
}

- (NSArray *)fullSubscribedChannelsList {

    return [self.subscribedChannelsSet allObjects];
}

- (BOOL)isSubscribedForChannel:(PNChannel *)channel {

    return [self.subscribedChannelsSet containsObject:channel];
}

- (BOOL)canResubscribe {

    return [self.subscribedChannelsSet count] > 0;
}

- (void)restoreSubscription:(BOOL)shouldRestoreSubscriptionFromLastTimeToken {

    // Check whether client has been subscribed on channels before or not
    if ([self.subscribedChannelsSet count]) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RESTORING SUBSCRIPTION... (USE LAST TIME"
              " TOKEN? %@)(STATE: %d)", self, shouldRestoreSubscriptionFromLastTimeToken ? @"YES" : @"NO",
              self.messagingState);

        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self destroyByRequestClass:[PNSubscribeRequest class]];

        if (!shouldRestoreSubscriptionFromLastTimeToken) {

            // Reset last update time token for channels in list
            [self.subscribedChannelsSet makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
        }

        PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
                                    BITS_LIST_TERMINATOR);
        PNBitOn(&_messagingState, PNMessagingChannelRestoringSubscription);

        PNSubscribeRequest *resubscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:[self.subscribedChannelsSet allObjects]
                                                                                   byUserRequest:YES];

        // Check whether connection channel is waiting for response via long-poll connection or not
        resubscribeRequest.closeConnection = PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
        if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {

            resubscribeRequest.closeConnection = NO;
        }

        // Notify delegate that messaging channel is about to restore subscription on previous channels
        [self.messagingDelegate messagingChannel:self willRestoreSubscriptionOnChannels:resubscribeRequest.channels];


        [self scheduleRequest:resubscribeRequest
      shouldObserveProcessing:PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve)
                   outOfOrder:YES
             launchProcessing:YES];

    }
}

- (void)updateSubscriptionForChannels:(NSArray *)channels {

    // Ensure that client connected to at least one channel
    if ([channels count] > 0) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] UPDATING SUBSCRIPTIONS... (STATE: %d)",
              self, self.messagingState);

        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self destroyByRequestClass:[PNSubscribeRequest class]];

        PNSubscribeRequest *subscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:channels byUserRequest:YES];

        PNBitOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
        PNBitOn(&_messagingState, PNMessagingChannelUpdateSubscription);
        subscribeRequest.closeConnection = PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
        if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {

            subscribeRequest.closeConnection = NO;
        }

        // In case if we are restoring subscription and user decided to discard old time token client should
        // send channel long-poll request (with updated time token) before other requests
        [self scheduleRequest:subscribeRequest
      shouldObserveProcessing:[subscribeRequest isInitialSubscription]
                   outOfOrder:PNBitIsOn(self.messagingState, PNMessagingChannelRestoringSubscription)
             launchProcessing:YES];
    }

}

- (void)subscribeOnChannels:(NSArray *)channels {

    [self subscribeOnChannels:channels withPresenceEvent:YES];
}

- (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    [self subscribeOnChannels:channels withPresenceEvent:withPresenceEvent presence:0];
}

- (void)subscribeOnChannels:(NSArray *)channels
          withPresenceEvent:(BOOL)withPresenceEvent
                   presence:(NSUInteger)channelsPresence {

    BOOL isPresenceModification = PNBitsIsOn(channelsPresence, NO, PNMessagingChannelEnablingPresence,
                                                                   PNMessagingChannelDisablingPresence,
                                                                   BITS_LIST_TERMINATOR);
    if (isPresenceModification) {

        NSString *action = @"ENABLING";
        if (PNBitIsOn(channelsPresence, PNMessagingChannelDisablingPresence)) {

            action = @"DISABLING";
        }
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] %@ PRESENCE ON SPECIFIC SET OF CHANNELS... (STATE: %d)",
              self, action, self.messagingState);
    }
    else {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUBSCRIBING ON SPECIFIC SET OF CHANNELS... (STATE: %d)",
              self, self.messagingState);
    }

    NSMutableSet *channelsSet = nil;
    if (isPresenceModification) {

        channelsSet = [NSMutableSet setWithArray:channels];
        [channelsSet removeObject:[NSNull null]];
        NSMutableSet *presenceObservers = [NSMutableSet setWithArray:[self channelsWithPresenceFromList:[self.subscribedChannelsSet allObjects]]];
        [presenceObservers removeObject:[NSNull null]];

        // Extracting presence enabled channels on which client is not subscribed at this moment
        // (set will contain only those channels, on which client subscribed at this moment)
        [presenceObservers intersectSet:[NSSet setWithArray:channels]];

        if (PNBitIsOn(channelsPresence, PNMessagingChannelEnablingPresence)) {

            [channelsSet minusSet:presenceObservers];
        }
        else {

            [channelsSet setSet:presenceObservers];
        }

        if (withPresenceEvent) {

            // Reset last update time token for channels in list
            [channelsSet makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
        }
        self.oldSubscribedChannelsSet = [NSSet setWithSet:self.subscribedChannelsSet];
    }
    // Checking whether client already subscribed on one of channels from set or not
    else {

        channelsSet = [[self channelsWithPresenceFromList:channels forSubscribe:YES] mutableCopy];

        if ([self.subscribedChannelsSet intersectsSet:channelsSet]) {

            // Extracting channels on which client is not subscribed at this moment
            // (set will contain only those channels, on which client subscribed at this moment)
            NSMutableSet *filteredChannels = [self.subscribedChannelsSet mutableCopy];
            [filteredChannels intersectSet:channelsSet];

            // Remove from target channels set those channels on which client already subscribed
            [channelsSet minusSet:filteredChannels];


            // Checking whether there still channels on which client not subscribed yet
            if ([channelsSet count] > 0 && !withPresenceEvent) {

                // Reset last update time token for channels in list
                [channelsSet makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
            }
        }

        self.oldSubscribedChannelsSet = [NSSet setWithSet:self.subscribedChannelsSet];
    }

    // Check whether there is at leas one channel at which client didn't subscribed yet
    BOOL isAbleToSendRequest = [channelsSet count] > 0;


    NSMutableArray *subscriptionChannels = [[self.subscribedChannelsSet allObjects] mutableCopy];
    if (isAbleToSendRequest) {

        [self destroyByRequestClass:[PNSubscribeRequest class]];

        // In case if client currently connected to PubNub services, we should send leave event
        subscriptionChannels = [[self unsubscribeFromChannelsWithPresenceEvent:withPresenceEvent byUserRequest:NO] mutableCopy];
    }


    if (!isPresenceModification) {

        // Append channels on which client should subscribe
        [subscriptionChannels addObjectsFromArray:[channelsSet allObjects]];
    }


    if (isAbleToSendRequest) {

        // Checking whether presence event should fire on subscription or not
        if (withPresenceEvent) {

            PNBitOn(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);

            // Reset last update time token for channels in list
            [subscriptionChannels makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
        }
        else {

            [self destroyByRequestClass:[PNSubscribeRequest class]];
        }
    }

    PNSubscribeRequest *subscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:subscriptionChannels byUserRequest:YES];
    if (isPresenceModification) {

        NSArray *channelsForPresenceManipulation = [channelsSet allObjects];
        NSMutableArray *observedChannels = nil;
        if (PNBitIsOn(channelsPresence, PNMessagingChannelEnablingPresence)) {

            observedChannels = [[channelsForPresenceManipulation valueForKey:@"observedChannel"] mutableCopy];
            [observedChannels removeObject:[NSNull null]];
        }
        else {

            observedChannels = [channelsForPresenceManipulation mutableCopy];
        }

        if ([observedChannels count] > 0) {

            if (PNBitIsOn(channelsPresence, PNMessagingChannelEnablingPresence)) {

                subscribeRequest.channelsForPresenceEnabling = channelsForPresenceManipulation;
                [self.messagingDelegate messagingChannel:self willEnablePresenceObservationOnChannels:observedChannels];
            }
            else {

                subscribeRequest.channelsForPresenceDisabling = channelsForPresenceManipulation;
                [self.messagingDelegate messagingChannel:self willDisablePresenceObservationOnChannels:observedChannels];
            }
        }
        else {

            isAbleToSendRequest = NO;

            subscribeRequest.channelsForPresenceEnabling = nil;
            subscribeRequest.channelsForPresenceDisabling = nil;
            if (PNBitIsOn(channelsPresence, PNMessagingChannelEnablingPresence)) {

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] ENABLED PRESENCE ON SPECIFIC SET "
                      "OF CHANNELS (ALREADY ENABLED)(STATE: %d)", self, self.messagingState);

                [self.messagingDelegate messagingChannel:self didEnablePresenceObservationOnChannels:channels];
            }
            else {

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] DISABLED PRESENCE ON SPECIFIC "
                      "SET OF CHANNELS (PRESENCE NOT ENABLED ON PROVIDED CHANNELS)(STATE: %d)", self,
                      self.messagingState);

                [self.messagingDelegate messagingChannel:self didDisablePresenceObservationOnChannels:channels];
            }
        }
    }
    else {

        if (isAbleToSendRequest) {

            [self.messagingDelegate messagingChannel:self
                             willSubscribeOnChannels:[self channelsWithOutPresenceFromList:[channelsSet allObjects]]];
        }
        else {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUBSCRIBED ON SPECIFIC SET OF "
                  "CHANNELS (ALREADY SUBSCRIBED)(STATE: %d)", self, self.messagingState);

            [self.messagingDelegate messagingChannel:self didSubscribeOnChannels:channels];
        }
    }

    if (isAbleToSendRequest) {

        subscribeRequest.closeConnection = isPresenceModification || PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
        if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {

            subscribeRequest.closeConnection = NO;
        }

        [self scheduleRequest:subscribeRequest
      shouldObserveProcessing:PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve)];
    }
}

- (void)restoreSubscriptionOnPreviousChannels {

    NSArray *channelsList = [self.subscribedChannelsSet allObjects];
    if ([channelsList count] > 0) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUBSCRIBING ON PREVIOUS CHANNELS... (STATE: %d)",
              self, self.messagingState);

        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self destroyByRequestClass:[PNSubscribeRequest class]];

        PNBitOn(&_messagingState, PNMessagingChannelRestoringSubscription);

        PNSubscribeRequest *resubscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:channelsList byUserRequest:NO];
        resubscribeRequest.closeConnection = PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
        if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {

            resubscribeRequest.closeConnection = NO;
        }

        [self scheduleRequest:resubscribeRequest
      shouldObserveProcessing:!PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents)
                   outOfOrder:YES
             launchProcessing:YES];
    }
}

- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent {

    return [self unsubscribeFromChannelsWithPresenceEvent:withPresenceEvent byUserRequest:YES];
}

- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent
                                        byUserRequest:(BOOL)isLeavingByUserRequest {

    // In case if unsubscribe has been triggered by user, there is no possibility that client can be in
    // 'subscription restore' state
    if (isLeavingByUserRequest) {

        PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
                                    BITS_LIST_TERMINATOR);
    }


    NSArray *subscribedChannels = [self.subscribedChannelsSet allObjects];

    // Check whether should generate 'leave' presence event or not
    if (withPresenceEvent) {

        [self leaveSubscribedChannelsByUserRequest:isLeavingByUserRequest];
    }
    else {

        [self handleLeaveRequestCompletionForChannels:subscribedChannels withResponse:nil
                                        byUserRequest:isLeavingByUserRequest];

        [self destroyByRequestClass:[PNLeaveRequest class]];

        if (PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents)) {

            // Reconnect messaging channel to free up long-poll on server
            [self reconnect];
        }
    }


    return subscribedChannels;
}

- (void)unsubscribeFromChannels:(NSArray *)channels {

    [self unsubscribeFromChannels:channels withPresenceEvent:YES];
}

- (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    [self unsubscribeFromChannels:channels withPresenceEvent:withPresenceEvent byUserRequest:YES];
}

- (void)unsubscribeFromChannels:(NSArray *)channels
              withPresenceEvent:(BOOL)withPresenceEvent
                  byUserRequest:(BOOL)isLeavingByUserRequest {

    // Retrieve list of channels which will left after unsubscription
    NSMutableSet *currentlySubscribedChannels = [self.subscribedChannelsSet mutableCopy];
    NSSet *channelsWithPresence = [self channelsWithPresenceFromList:channels forSubscribe:NO];

    // Check whether there is at least one of channels from which client should unsubscribe is in the list
    // of subscribed or not
    if ([currentlySubscribedChannels intersectsSet:channelsWithPresence]) {

        [currentlySubscribedChannels minusSet:channelsWithPresence];

        if (withPresenceEvent) {

            [self destroyByRequestClass:[PNSubscribeRequest class]];

            [self leaveChannels:[channelsWithPresence allObjects] byUserRequest:isLeavingByUserRequest];
        }
        else {

            [self destroyByRequestClass:[PNLeaveRequest class]];

            if ([currentlySubscribedChannels count] == 0) {

                [self handleLeaveRequestCompletionForChannels:[channelsWithPresence allObjects]
                                                 withResponse:nil
                                                byUserRequest:isLeavingByUserRequest];
            }
        }


        if (isLeavingByUserRequest && [currentlySubscribedChannels count] > 0) {

            PNSubscribeRequest *subscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:[currentlySubscribedChannels allObjects]
                                                                                     byUserRequest:isLeavingByUserRequest];
            subscribeRequest.closeConnection = PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
            if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {

                subscribeRequest.closeConnection = NO;
            }

            [self destroyByRequestClass:[PNSubscribeRequest class]];

            // Resubscribe on rest of channels which is left after unsubscribe
            [self scheduleRequest:subscribeRequest
          shouldObserveProcessing:!PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents)];
        }
    }
    else {

        // Schedule immediately that client unsubscribed from suggested channels
        [self.messagingDelegate messagingChannel:self didUnsubscribeFromChannels:channels];
    }
}


#pragma mark - Presence observation management

- (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel {

    PNChannelPresence *presenceObserver = [channel presenceObserver];


    return presenceObserver != nil && [self.subscribedChannelsSet containsObject:presenceObserver];
}

- (void)enablePresenceObservationForChannels:(NSArray *)channels {

    NSMutableArray *presenceObservers = [[channels valueForKey:@"presenceObserver"] mutableCopy];
    [presenceObservers removeObject:[NSNull null]];

    [self subscribeOnChannels:presenceObservers withPresenceEvent:NO presence:PNMessagingChannelEnablingPresence];
}

- (void)disablePresenceObservationForChannels:(NSArray *)channels {

    [self disablePresenceObservationForChannels:channels sendRequest:YES];
}

- (void)disablePresenceObservationForChannels:(NSArray *)channels sendRequest:(BOOL)shouldSendRequest {

    if (shouldSendRequest) {

        NSMutableArray *presenceObservers = [[channels valueForKey:@"presenceObserver"] mutableCopy];
        [presenceObservers removeObject:[NSNull null]];


        [self subscribeOnChannels:presenceObservers withPresenceEvent:NO presence:PNMessagingChannelDisablingPresence];
    }
    else {

        // Enumerate over the list of channels and mark that it should observe for presence
        [channels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx, BOOL *channelEnumeratorStop) {

            channel.observePresence = NO;
            channel.linkedWithPresenceObservationChannel = NO;
        }];
    }
}


#pragma mark - Handler methods

- (void)handleLeaveRequestCompletionForChannels:(NSArray *)channels
                                   withResponse:(PNResponse *)response
                                  byUserRequest:(BOOL)isLeavingByUserRequest {

    BOOL shouldRemoveChannels = [channels count] > 0;

    if (response != nil) {

        PNResponseParser *parser = [PNResponseParser parserForResponse:response];

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] LEAVE REQUEST RESULT: %@ (STATE: %d)",
              self, parser, self.messagingState);

        // Ensure that parsed data has numeric data, which will mean that this is status code or event enum value
        if ([[parser parsedData] isKindOfClass:[NSNumber class]]) {

            PNOperationResultEvent result = (PNOperationResultEvent)[[parser parsedData] intValue];
            shouldRemoveChannels = result == PNOperationResultLeave;
        }
    }

    if (shouldRemoveChannels) {

        [self.subscribedChannelsSet minusSet:[self channelsWithPresenceFromList:channels forSubscribe:NO]];
    }


    if (isLeavingByUserRequest) {

        [self.messagingDelegate messagingChannel:self
                      didUnsubscribeFromChannels:[self channelsWithOutPresenceFromList:channels]];
    }
}

- (void)handleEventOnChannelsForRequest:(PNSubscribeRequest *)request withResponse:(PNResponse *)response {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] HANDLE EVENT IN RESPONSE ON: %@\nCHANNELS: %@\nRESPONSE: %@\n(STATE: %d)",
          self, request, request.channels, response, self.messagingState);

    PNResponseParser *parser = [PNResponseParser parserForResponse:response];
    id parsedData = [parser parsedData];

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] PARSED DATA: %@\n(STATE: %d)",
          self, parser, self.messagingState);

    if ([parsedData isKindOfClass:[PNError class]] ||
        ([parsedData isKindOfClass:[PNOperationStatus class]] && ((PNOperationStatus *)parsedData).error != nil)) {

        if ([parsedData isKindOfClass:[PNOperationStatus class]]) {

            parsedData = ((PNOperationStatus *)parsedData).error;
        }

        [self handleSubscribeDidFail:request withError:parsedData];
    }
    else {

        PNChannelEvents *events = [parser parsedData];

        // Retrieve event time token
        NSString *timeToken = @"0";
        if (events.timeToken) {

            timeToken = PNStringFromUnsignedLongLongNumber(events.timeToken);
        }


        // Update channels state update time token
        [self.subscribedChannelsSet makeObjectsPerformSelector:@selector(setUpdateTimeToken:) withObject:timeToken];
        [request.channels makeObjectsPerformSelector:@selector(setUpdateTimeToken:) withObject:timeToken];


        // Check whether events arrived from PubNub service (messages, presence)
        if ([events.events count] > 0) {

            NSArray *channels = [self channelsWithOutPresenceFromList:[self.subscribedChannelsSet allObjects]];
            PNChannel *channel = nil;
            if ([channels count] == 0) {

                channels = [self.subscribedChannelsSet allObjects];
                channel = [(PNChannelPresence *)[channels lastObject] observedChannel];
            }
            else if ([channels count] == 1) {

                channel = (PNChannel *)[channels lastObject];
            }

            [events.events enumerateObjectsUsingBlock:^(id event, NSUInteger eventIdx, BOOL *eventsEnumeratorStop) {

                if ([event isKindOfClass:[PNPresenceEvent class]]) {

                    // Check whether channel was assigned to presence event or not (channel may not arrive with
                    // server response if client subscribed only for single channel)
                    if (((PNPresenceEvent *)event).channel == nil) {

                        ((PNPresenceEvent *)event).channel = channel;
                    }

                    [self.messagingDelegate messagingChannel:self didReceiveEvent:event];
                }
                else {

                    // Check whether channel was assigned to message or not (channel may not arrive with server
                    // response if client subscribed only for single channel)
                    if (((PNMessage *)event).channel == nil) {

                        ((PNMessage *)event).channel = channel;
                    }

                    [self.messagingDelegate messagingChannel:self didReceiveMessage:event];
                }
            }];
        }

        // Subscribe to the channels with new update time token
        NSArray *targetChannels = [self.subscribedChannelsSet count] ? [self.subscribedChannelsSet allObjects] : nil;
        targetChannels = targetChannels ? targetChannels : (request != nil ? request.channels : nil);
        if (targetChannels) {

            [self updateSubscriptionForChannels:targetChannels];
        }
    }
}

- (void)handleSubscribeDidFail:(PNBaseRequest *)request withError:(PNError *)error {

    PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
                                PNMessagingChannelSubscriptionTimeTokenRetrieve, BITS_LIST_TERMINATOR);

    PNSubscribeRequest *subscriptionRequest = (PNSubscribeRequest *)request;

    // Check whether request was for presence state change or not
    if (subscriptionRequest.channelsForPresenceEnabling || subscriptionRequest.channelsForPresenceDisabling) {

        if (subscriptionRequest.channelsForPresenceEnabling) {

            PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] PRESENCE ENABLING FAILED WITH "
                    "ERROR: %@\nCHANNELS: %@\n(STATE: %d)",
                  self, error, subscriptionRequest.channelsForPresenceEnabling, self.messagingState);

            // Checking whether user generated request or not
            if (request.isSendingByUserRequest) {

                NSArray *channels = [self channelsWithOutPresenceFromList:subscriptionRequest.channelsForPresenceEnabling];
                [self.messagingDelegate messagingChannel:self didFailPresenceEnablingOnChannels:channels withError:error];
            }
        }
        else {

            PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] PRESENCE DISABLING FAILED WITH "
                    "ERROR: %@\nCHANNELS: %@\n(STATE: %d)",
                  self, error, subscriptionRequest.channelsForPresenceDisabling, self.messagingState);

            // Checking whether user generated request or not
            if (request.isSendingByUserRequest) {

                NSArray *channels = [self channelsWithOutPresenceFromList:subscriptionRequest.channelsForPresenceDisabling];
                [self.messagingDelegate messagingChannel:self didFailPresenceDisablingOnChannels:channels withError:error];
            }
        }
    }
    // Looks like it was simple subscription request
    else {

        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] SUBSCRIPTION FAILED WITH ERROR: "
                "%@\nCHANNELS: %@\n(STATE: %d)",
              self, error, subscriptionRequest.channels, self.messagingState);

        // Checking whether user generated request or not
        if (request.isSendingByUserRequest) {

            NSArray *channels = [self channelsWithOutPresenceFromList:subscriptionRequest.channels];
            [self.messagingDelegate messagingChannel:self didFailSubscribeOnChannels:channels withError:error];
        }
    }

    [self restoreSubscriptionOnPreviousChannels];
}

- (void)handleUnsubscribeDidFail:(PNBaseRequest *)request withError:(PNError *)error {

    PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
                                PNMessagingChannelSubscriptionTimeTokenRetrieve, BITS_LIST_TERMINATOR);

    PNLeaveRequest *leaveRequest = (PNLeaveRequest *)request;

    PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] UNSUBSCRIPTION FAILED WITH ERROR: %@\nCHANNELS: %@\n(STATE: %d)",
          self, error, leaveRequest.channels, self.messagingState);

    // Checking whether user generated request or not
    if (request.isSendingByUserRequest) {

        [self.messagingDelegate messagingChannel:self didFailUnsubscribeOnChannels:leaveRequest.channels withError:error];
    }

    [self restoreSubscriptionOnPreviousChannels];
}

- (void)handleTimeoutTimer:(NSTimer *)timer {

    PNBaseRequest *request = (PNBaseRequest *)timer.userInfo;
    NSInteger errorCode = kPNRequestExecutionFailedByTimeoutError;
    NSString *errorMessage = @"Subscription failed by timeout";
    if ([request isKindOfClass:[PNLeaveRequest class]]) {

        errorMessage = @"Unsubscription failed by timeout";
    }
    PNError *error = [PNError errorWithMessage:errorMessage code:errorCode];

    if (request) {

        if ([request isKindOfClass:[PNLeaveRequest class]]) {

            [self handleUnsubscribeDidFail:request withError:error];
        }
        else {

            [self handleSubscribeDidFail:request withError:error];
        }
    }


    [self destroyRequest:request];


    // Check whether connection available or not
    [[PubNub sharedInstance].reachability refreshReachabilityState];
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        // Asking to schedule next request
        [self scheduleNextRequest];
    }
}

- (void)handleIdleTimer:(NSTimer *)timer {

    PNBitsOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve,
                                PNMessagingChannelSubscriptionWaitingForEvents, BITS_LIST_TERMINATOR);

    if ([self canResubscribe]) {

        // Destroy all subscription/leave requests from queue and stored sources
        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self destroyByRequestClass:[PNSubscribeRequest class]];

        if ([self.messagingDelegate shouldMessagingChannelRestoreSubscription:self]) {

            [self restoreSubscription:[self.messagingDelegate shouldMessagingChannelRestoreWithLastTimeToken:self]];
        }
        else {

            [self unsubscribeFromChannelsWithPresenceEvent:NO byUserRequest:NO];

            // Notify delegate that messaging channel will reset and there is nothing for it to process
            [self.messagingDelegate messagingChannelDidReset:self];
        }
    }
    else {

        [self reconnect];
    }
}


#pragma mark - Misc methods

- (void)startChannelIdleTimer {

    [self stopChannelIdleTimer];

    self.idleTimer = [NSTimer timerWithTimeInterval:kPNConnectionIdleTimeout
                                             target:self
                                           selector:@selector(handleIdleTimer:)
                                           userInfo:nil
                                            repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.idleTimer forMode:NSRunLoopCommonModes];
}

- (void)stopChannelIdleTimer {

    if ([self.idleTimer isValid]) {

        [self.idleTimer invalidate];
        self.idleTimer = nil;
    }
}

- (void)pauseChannelIdleTimer {

    if ([self.idleTimer isValid]) {

        self.idleTimerFireDate = self.idleTimer.fireDate;
        self.channelSuspensionDate = [NSDate date];
        [self.idleTimer invalidate];
        self.idleTimer = nil;
    }
    else {

        self.idleTimerFireDate = nil;
        self.channelSuspensionDate = nil;
    }
}

- (void)resumeChannelIdleTimer {

    if (self.idleTimerFireDate) {

        NSTimeInterval timeLeftBeforeSuspension = ABS([self.channelSuspensionDate timeIntervalSinceDate:self.idleTimerFireDate]);

        // Adding some time to let connection channel awake from suspension
        timeLeftBeforeSuspension += 10.0f;

        self.idleTimer = [NSTimer timerWithTimeInterval:timeLeftBeforeSuspension
                                                 target:self
                                               selector:@selector(handleIdleTimer:)
                                               userInfo:nil
                                                repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.idleTimer forMode:NSRunLoopCommonModes];

        self.idleTimerFireDate = nil;
        self.channelSuspensionDate = nil;
    }
}

- (NSSet *)channelsWithPresenceFromList:(NSArray *)channelsList forSubscribe:(BOOL)listForSubscribe {

    return [self channelsWithPresenceFromList:channelsList forSubscribe:listForSubscribe onlyPresence:NO];
}

- (NSSet *)channelsWithPresenceFromList:(NSArray *)channelsList forSubscribe:(BOOL)listForSubscribe
                           onlyPresence:(BOOL)fetchPresenceChannelsOnly {

    NSMutableSet *fullChannelsList = [NSMutableSet setWithCapacity:[channelsList count]];
    [channelsList enumerateObjectsUsingBlock:^(PNChannel *channel,
                                               NSUInteger channelIdx,
                                               BOOL *channelEnumeratorStop) {

        if (!fetchPresenceChannelsOnly) {

            [fullChannelsList addObject:channel];
        }

        if ((channel.linkedWithPresenceObservationChannel && !listForSubscribe) || listForSubscribe) {

            PNChannelPresence *presenceObserver = [channel presenceObserver];
            if (presenceObserver) {

                [fullChannelsList addObject:presenceObserver];
            }
        }
    }];


    return fullChannelsList;
}

- (NSArray *)channelsWithOutPresenceFromList:(NSArray *)channelsList {

    // Compose filtering predicate to retrieve list of channels which are not presence observing channels
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"isPresenceObserver = NO"];


    return [channelsList filteredArrayUsingPredicate:filterPredicate];
}

- (NSArray *)channelsWithPresenceFromList:(NSArray *)channelsList {

    // Compose filtering predicate to retrieve list of channels which are not presence observing channels
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"isPresenceObserver = YES"];


    return [channelsList filteredArrayUsingPredicate:filterPredicate];
}

- (NSString *)stateDescription {

    NSMutableString *connectionState = [NSMutableString stringWithFormat:@"\n[CHANNEL::%@ STATE DESCRIPTION", self];
    if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringSubscription)) {

        [connectionState appendFormat:@"\n- RESTORING SUBSCRIPTION..."];
    }
    if (PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve)) {

        [connectionState appendFormat:@"\n- FETCHING INITIAL SUBSCRIPTION TIME TOKEN"];
    }
    if (PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents)) {

        [connectionState appendFormat:@"\n- WAITING FOR EVENTS (LONG-POLL CONNECTION)..."];
    }
    if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {

        [connectionState appendFormat:@"\n- CONNECTION TERMINATED BY SERVER REUEST"];
    }


    return connectionState;
}


#pragma mark - Connection delegate methods

- (void)connectionDidReset:(PNConnection *)connection {

    PNBitClear(&_messagingState);

    [self startChannelIdleTimer];


    // Forward to the super class
    [super connectionDidReset:connection];
}

- (void)connection:(PNConnection *)connection didConnectToHost:(NSString *)hostName {

    BOOL shouldRestoreActivity = ![self isSuspended] && ![self isResuming];

    if (shouldRestoreActivity) {

        PNBitsOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve,
                                    PNMessagingChannelSubscriptionWaitingForEvents,
                                    PNMessagingChannelRestoringConnectionTerminatedByServer, BITS_LIST_TERMINATOR);

        void(^storedRequestsDestroy)(void) = ^{

            [self destroyByRequestClass:[PNLeaveRequest class]];
            [self destroyByRequestClass:[PNSubscribeRequest class]];
        };

        // Check whether connection tried to update subscription before it was interrupted and reconnected back
        if (PNBitIsOn(self.messagingState, PNMessagingChannelUpdateSubscription)) {

            PNBitClear(&_messagingState);

            // Check whether there is some channels which can be used to perform subscription update or not
            if ([self canResubscribe]) {

                storedRequestsDestroy();

                [self updateSubscriptionForChannels:[self.subscribedChannelsSet allObjects]];
            }
            // Check whether subscription request already scheduled or not
            else if (![self hasRequestsWithClass:[PNSubscribeRequest class]]) {

                // Check whether there is no 'leave' requests, which will mean that we are leaving from all channels
                if (![self hasRequestsWithClass:[PNLeaveRequest class]]) {

                    [self restoreSubscriptionOnPreviousChannels];
                }
            }
        }
        else {

            PNBitClear(&_messagingState);

            // Check whether client is able to restore subscription on channel on which it was subscribed before
            // (new time token will be used if required
            if ([self canResubscribe]) {

                storedRequestsDestroy();

                if ([self.messagingDelegate shouldMessagingChannelRestoreSubscription:self]) {

                    [self restoreSubscription:[self.messagingDelegate shouldMessagingChannelRestoreWithLastTimeToken:self]];
                }
                else {

                    [self unsubscribeFromChannelsWithPresenceEvent:NO byUserRequest:NO];

                    // Notify delegate that messaging channel will reset and there is nothing for it to process
                    [self.messagingDelegate messagingChannelDidReset:self];
                }
            }
        }


        [self startChannelIdleTimer];
    }
    
    // Forward to the super class
    [super connection:connection didConnectToHost:hostName];
}

- (void)connectionDidResume:(PNConnection *)connection {

    PNBitClear(&_messagingState);

    // Check whether subscription request already scheduled or not
    if (![self hasRequestsWithClass:[PNSubscribeRequest class]]) {

        [self restoreSubscriptionOnPreviousChannels];
    }
    else {

        self.restoringSubscriptionOnResume = YES;

        if ([self.messagingDelegate shouldMessagingChannelRestoreWithLastTimeToken:self]) {

            PNBitOff(&_messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
            PNBitOn(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
        }
    }

    [self startChannelIdleTimer];


    // Forward to the super class
    [super connectionDidResume:connection];

    self.restoringSubscriptionOnResume = NO;
}

- (void)connection:(PNConnection *)connection willReconnectToHost:(NSString *)hostName {

    [self stopChannelIdleTimer];


    // Forward to the super class
    [super connection:connection willReconnectToHost:hostName];
}

- (void)connection:(PNConnection *)connection didReconnectToHost:(NSString *)hostName {

    PNBitsOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve, PNMessagingChannelSubscriptionWaitingForEvents,
                                PNMessagingChannelRestoringConnectionTerminatedByServer, PNMessagingChannelRestoringSubscription,
                                BITS_LIST_TERMINATOR);

    // Check whether client updated subscription or not
    if (PNBitIsOn(self.messagingState, PNMessagingChannelUpdateSubscription)) {

        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self destroyByRequestClass:[PNSubscribeRequest class]];

        PNBitOff(&_messagingState, PNMessagingChannelUpdateSubscription);

        [self updateSubscriptionForChannels:[self.subscribedChannelsSet allObjects]];
    }
    // Check whether reconnection was because of 'unsubscribe' request or not
    else if ([self hasRequestsWithClass:[PNLeaveRequest class]]) {

        PNBitOff(&_messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
        PNBitOn(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
    }
    // Check whether subscription request already scheduled or not
    else if (![self hasRequestsWithClass:[PNSubscribeRequest class]]) {

        [self restoreSubscriptionOnPreviousChannels];
    }
    [self startChannelIdleTimer];


    // Forward to the super class
    [super connection:connection didReconnectToHost:hostName];
}

- (void)connection:(PNConnection *)connection willReconnectToHostAfterError:(NSString *)hostName {

    [self stopChannelIdleTimer];


    // Forward to the super class
    [super connection:connection willReconnectToHostAfterError:hostName];
}

- (void)connection:(PNConnection *)connection didReconnectToHostAfterError:(NSString *)hostName {

    PNBitClear(&_messagingState);

    // Check whether subscription request already scheduled or not
    if (![self hasRequestsWithClass:[PNSubscribeRequest class]]) {

        [self restoreSubscriptionOnPreviousChannels];
    }
    [self startChannelIdleTimer];


    // Forward to the super class
    [super connection:connection didReconnectToHostAfterError:hostName];
}

- (void)connection:(PNConnection *)connection willDisconnectFromHost:(NSString *)host withError:(PNError *)error {

    [self stopChannelIdleTimer];


    // Forward to the super class
    [super connection:connection willDisconnectFromHost:host withError:error];
}

- (void)connection:(PNConnection *)connection didDisconnectFromHost:(NSString *)hostName {

    PNBitClear(&_messagingState);

    [self stopChannelIdleTimer];


    // Forward to the super class
    [super connection:connection didDisconnectFromHost:hostName];
}

- (void)connection:(PNConnection *)connection didRestoreAfterServerCloseConnectionToHost:(NSString *)hostName {

    PNBitsOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve, PNMessagingChannelSubscriptionWaitingForEvents,
                                PNMessagingChannelRestoringConnectionTerminatedByServer, PNMessagingChannelRestoringSubscription,
                                BITS_LIST_TERMINATOR);

    // Check whether connection tried to update subscription before it was interrupted and reconnected back
    if (PNBitIsOn(self.messagingState, PNMessagingChannelUpdateSubscription)) {

        PNBitClear(&_messagingState);

        // Check whether there is some channels which can be used to perform subscription update or not
        if ([self.subscribedChannelsSet count]) {

            [self destroyByRequestClass:[PNLeaveRequest class]];
            [self destroyByRequestClass:[PNSubscribeRequest class]];

            [self updateSubscriptionForChannels:[self.subscribedChannelsSet allObjects]];
        }

    }
    // Check whether subscription request already scheduled or not
    else if (![self hasRequestsWithClass:[PNSubscribeRequest class]]) {

        PNBitClear(&_messagingState);

        [self restoreSubscriptionOnPreviousChannels];
    }
    else {

        PNBitClear(&_messagingState);
    }

    [self startChannelIdleTimer];


    // Forward to the super class
    [super connection:connection didRestoreAfterServerCloseConnectionToHost:hostName];
}

- (void)connection:(PNConnection *)connection willDisconnectByServerRequestFromHost:(NSString *)hostName {

    PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
                                BITS_LIST_TERMINATOR);
    PNBitOn(&_messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer);

    [self stopChannelIdleTimer];


    // Forward to the super class
    [super connection:connection willDisconnectByServerRequestFromHost:hostName];

}

- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response {

    PNBitOff(&_messagingState, PNMessagingChannelSubscriptionWaitingForEvents);

    [self startChannelIdleTimer];

    [super connection:connection didReceiveResponse:response];
}


#pragma mark - Requests queue delegate methods

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue willSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] WILL START REQUEST PROCESSING: %@ [BODY: %@](STATE: %d)",
          self, request, request.resourcePath, self.messagingState);


    // Check whether connection should be closed for resubscribe
    // or not
    if (request.shouldCloseConnection) {

        // Mark that we don't need to close connection after next time
        // this request will be scheduled for processing
        // (this will happen right after connection will be restored)
        request.closeConnection = NO;


        // Reconnect communication channel
        [self reconnect];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] DID SEND REQUEST: %@ [BODY: %@][WAITING FOR COMPLETION? %@](STATE: %d)",
          self, request, request.resourcePath, [self isWaitingRequestCompletion:request.shortIdentifier] ? @"YES" : @"NO", self.messagingState);

    // Check whether non-initial subscription request has been sent
    if ([request isKindOfClass:[PNSubscribeRequest class]]) {

        PNBitsOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve,
                                    PNMessagingChannelSubscriptionWaitingForEvents, BITS_LIST_TERMINATOR);
        if ([((PNSubscribeRequest *)request) isInitialSubscription]) {

            PNBitOn(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
        }
        else {

            PNBitOn(&_messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
        }
    }
    else {

        PNBitOff(&_messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
    }


    // Forward to the super class
    [super requestsQueue:queue didSendRequest:request];


    // If we are not waiting for request completion, inform delegate immediately
    if (![self isWaitingRequestCompletion:request.shortIdentifier]) {

        // Check whether this is 'Subscribe' or 'Leave' request or not
        // (there probably no situation when this situation will take place)
        if ([request isKindOfClass:[PNSubscribeRequest class]] ||
            [request isKindOfClass:[PNLeaveRequest class]]) {

            if ([request isKindOfClass:[PNSubscribeRequest class]]) {

                PNSubscribeRequest *subscribeRequest = (PNSubscribeRequest *)request;

                NSArray *oldChannels = [self.oldSubscribedChannelsSet allObjects];
                BOOL(^subscribedChannelsUpdateBlock)(void) = ^{

                    // In case if request bring more channels when it was stored in connection channel state, update internal state
                    NSArray *requestsChannels = subscribeRequest.channels;
                    BOOL changed = [requestsChannels count] > 0 &&[requestsChannels count] != [oldChannels count];
                    if (!changed) {

                        changed = ![[NSSet setWithArray:requestsChannels] isEqualToSet:self.oldSubscribedChannelsSet];
                    }
                    if (changed) {

                        if (subscribeRequest.channelsForPresenceDisabling) {

                            NSMutableSet *updatedChannels = [NSMutableSet setWithArray:requestsChannels];
                            NSSet *removedChannels = [NSSet setWithArray:subscribeRequest.channelsForPresenceDisabling];
                            [updatedChannels minusSet:removedChannels];
                            [self.subscribedChannelsSet minusSet:removedChannels];
                            [self.subscribedChannelsSet unionSet:updatedChannels];
                        }
                        else {

                            [self.subscribedChannelsSet unionSet:[NSSet setWithArray:requestsChannels]];
                        }

                    }

                    return changed;
                };

                // Check whether request was for presence state change or not
                if (subscribeRequest.channelsForPresenceEnabling || subscribeRequest.channelsForPresenceDisabling) {

                    // In case if request bring more channels when it was stored in connection channel state, update internal state
                    BOOL changed = subscribedChannelsUpdateBlock();

                    if (changed) {

                        NSMutableSet *channelsSet = nil;
                        if (subscribeRequest.channelsForPresenceEnabling) {

                            channelsSet = [NSMutableSet setWithArray:subscribeRequest.channelsForPresenceEnabling];
                        }
                        else {

                            channelsSet = [NSMutableSet setWithArray:subscribeRequest.channelsForPresenceDisabling];
                        }

                        NSArray *oldChannelsList = [self channelsWithPresenceFromList:[self.oldSubscribedChannelsSet allObjects]];
                        NSMutableSet *oldChannelsSet = [NSMutableSet setWithArray:oldChannelsList];
                        if ([oldChannelsSet intersectsSet:channelsSet]) {

                            // Extracting channels presence on which client is not subscribed at this moment
                            // (set will contain only those channels, on which client subscribed at this moment)
                            [oldChannelsSet intersectSet:channelsSet];

                            // Remove from target channels set those channels on which client already subscribed
                            [channelsSet minusSet:oldChannelsSet];
                        }
                        self.oldSubscribedChannelsSet = [NSSet setWithSet:self.subscribedChannelsSet];
                        NSMutableArray *channels = [[channelsSet valueForKey:@"observedChannel"] mutableCopy];
                        [channels removeObject:[NSNull null]];

                        if (subscribeRequest.channelsForPresenceEnabling) {

                            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] PRESENCE ENABLED ON CHANNELS: %@\n(STATE: %d)",
                                    self, channels, self.messagingState);

                            subscribeRequest.channelsForPresenceEnabling = nil;
                            [self.messagingDelegate messagingChannel:self didEnablePresenceObservationOnChannels:channels];
                        }
                        else {

                            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] PRESENCE DISABLED ON CHANNELS: %@\n(STATE: %d)",
                                    self, subscribeRequest.channelsForPresenceDisabling, self.messagingState);

                            subscribeRequest.channelsForPresenceDisabling = nil;

                            // Remove 'presence enabled' state from list of specified channels
                            [self disablePresenceObservationForChannels:channels sendRequest:NO];

                            [self.messagingDelegate messagingChannel:self didDisablePresenceObservationOnChannels:channels];
                        }
                    }
                }
                else {

                    if (!PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {

                        NSArray *channels = [self channelsWithOutPresenceFromList:subscribeRequest.channels];

                        // In case if request bring more channels when it was stored in connection channel state, update internal state
                        BOOL changed = subscribedChannelsUpdateBlock();

                        if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringSubscription)) {

                            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RESTORES SUBSCRIPTION ON CHANNELS: %@\n(STATE: %d)",
                                    self, channels, self.messagingState);

                            PNBitOff(&_messagingState, PNMessagingChannelRestoringSubscription);

                            [self.messagingDelegate messagingChannel:self didRestoreSubscriptionOnChannels:channels];
                        }
                        else if (changed) {

                            NSMutableSet *channelsSet = [NSMutableSet setWithArray:channels];
                            NSArray *oldChannelsList = [self channelsWithOutPresenceFromList:[self.oldSubscribedChannelsSet allObjects]];
                            NSMutableSet *oldChannelsSet = [NSMutableSet setWithArray:oldChannelsList];
                            NSMutableSet *unsubscribedChannelsSet = nil;

                            if ([channels count] < [oldChannels count]) {

                                unsubscribedChannelsSet = [oldChannelsSet mutableCopy];
                                [unsubscribedChannelsSet minusSet:channelsSet];
                                PNLog(PNLogCommunicationChannelLayerInfoLevel, self,
                                      @"[CHANNEL::%@] UNSUBSCRIBED ON CHANNELS: %@\n (STATE: %d)", self, unsubscribedChannelsSet,
                                      self.messagingState);

                                [self.subscribedChannelsSet minusSet:unsubscribedChannelsSet];
                            }
                            else {

                                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUBSCRIBED ON CHANNELS: %@\n"
                                      "(STATE: %d)", self, channels, self.messagingState);
                            }


                            if ([oldChannelsSet intersectsSet:channelsSet]) {

                                // Extracting channels on which client is not subscribed at this moment
                                // (set will contain only those channels, on which client subscribed at this moment)
                                [oldChannelsSet intersectSet:channelsSet];

                                // Remove from target channels set those channels on which client already subscribed
                                [channelsSet minusSet:oldChannelsSet];
                            }
                            self.oldSubscribedChannelsSet = [NSSet setWithSet:self.subscribedChannelsSet];

                            if ([unsubscribedChannelsSet count]) {

                                [self.messagingDelegate messagingChannel:self
                                              didUnsubscribeFromChannels:[unsubscribedChannelsSet allObjects]];
                            }
                            else if ([channelsSet count]) {

                                [self.messagingDelegate messagingChannel:self didSubscribeOnChannels:[channelsSet allObjects]];
                            }
                        }
                    }
                }
            }
            else {

                PNLeaveRequest *leaveRequest = (PNLeaveRequest *)request;
                NSArray *channels = [self channelsWithOutPresenceFromList:leaveRequest.channels];

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] LEAVED ON CHANNELS: %@\n(STATE: %d)",
                        self, channels, self.messagingState);

                NSSet *leavedChannels = [self channelsWithPresenceFromList:channels forSubscribe:NO];
                [self.subscribedChannelsSet minusSet:leavedChannels];

                if ([leaveRequest isSendingByUserRequest]) {

                    [self.messagingDelegate messagingChannel:self didUnsubscribeFromChannels:channels];
                }
            }
        }
    }


    [self scheduleNextRequest];
}

- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request withError:(PNError *)error {

    // Check whether failed to send subscription request or not
    if ([request isKindOfClass:[PNSubscribeRequest class]]) {

        PNBitOff(&_messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
    }

    // Forward to the super class
    [super requestsQueue:queue didFailRequestSend:request withError:error];


    // Check whether request can be rescheduled or not
    if (![request canRetry]) {

        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] DID FAIL TO SEND REQUEST: %@ [BODY: %@](STATE: %d)",
              self, request, request.resourcePath, self.messagingState);

        // Removing failed request from queue
        [self destroyRequest:request];

        // Check whether this is 'Subscribe' or 'Leave' request or not
        if ([request isKindOfClass:[PNSubscribeRequest class]] ||
            [request isKindOfClass:[PNLeaveRequest class]]) {

            // Retrieve list of channels w/o presence channels to notify user that client was unable to subscribe on
            // specified list of channels
            NSArray *channels = [self channelsWithOutPresenceFromList:[request valueForKey:@"channels"]];

            if ([channels count] > 0 && [request isSendingByUserRequest]) {

                if ([request isKindOfClass:[PNSubscribeRequest class]]) {

                    // Notify delegate about that client failed to subscribe on channels
                    [self handleSubscribeDidFail:request withError:error];
                }
                else {

                    // Notify delegate about that client failed to leave set of channels
                    [self handleUnsubscribeDidFail:request withError:error];
                }
            }
        }
    }


    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        [self scheduleNextRequest];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] DID CANCEL REQUEST: %@ [BODY: %@](STATE: %d)",
          self, request, request.resourcePath, self.messagingState);


    if ([request isKindOfClass:[PNSubscribeRequest class]]) {

        PNBitsOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve,
                                    PNMessagingChannelSubscriptionWaitingForEvents, BITS_LIST_TERMINATOR);
    }
    else if ([request isKindOfClass:[PNLeaveRequest class]]) {

        [[PubNub sharedInstance].reachability refreshReachabilityState];
        if ([[PubNub sharedInstance].reachability isServiceAvailable]) {

            request.processing = YES;
        }
    }


    // Forward to the super class
    [super requestsQueue:queue didCancelRequest:request];
}

- (BOOL)shouldRequestsQueue:(PNRequestsQueue *)queue removeCompletedRequest:(PNBaseRequest *)request {

    BOOL shouldRemove = YES;

    if ([self isWaitingRequestCompletion:request.shortIdentifier] || [request isKindOfClass:[PNLeaveRequest class]]) {

        shouldRemove = NO;
    }

    return shouldRemove;
}


#pragma mark Memory management

- (void)dealloc {

    [self stopChannelIdleTimer];
}

#pragma mark -


@end