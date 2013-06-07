//
//  PNMessagingChannel.m
//  pubnub
//
//  This channel instance is required for
//  messages exchange between client and
//  PubNub service:
//      - channels messages (subscribe)
//      - channels presence events
//      - leave
//
//  Notice: don't try to create more than
//          one messaging channel on MacOS
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNMessagingChannel.h"
#import "PNConnectionChannel+Protected.h"
#import "PNChannelEventsResponseParser.h"
#import "PNChannelPresence+Protected.h"
#import "PNMessagesHistory.h"
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


#pragma mark - Private interface methods

@interface PNMessagingChannel ()


#pragma mark - Properties

// Stores list of channels (including presence)
// on which this client is subscribed now
@property (nonatomic, strong) NSMutableSet *subscribedChannelsSet;

// Stores list of channels (including presence)
// from which client should unsubscribe w/o presence
@property (nonatomic, strong) NSSet *presenceDisablingChannelsSet;

// Stores list of channels (including presence)
// on which client should enable presence
@property (nonatomic, strong) NSSet *presenceEnablingChannelsSet;

// Stores flag on whether messaging channel is restoring
// subscription on previous channels or not
@property (nonatomic, assign, getter = isRestoringSubscription) BOOL restoringSubscription;

@property (nonatomic, assign, getter = isDisablingPresence) BOOL disablingPresence;

@property (nonatomic, assign, getter = isEnablingPresence) BOOL enablingPresence;

@property (nonatomic, strong) NSTimer *idleTimer;

@property (nonatomic, assign, getter = isReconnecting) BOOL reconnecting;


#pragma mark - Instance methods

/**
 * Check whether response should be processed on
 * this communication channel or not
 */
- (BOOL)shouldHandleResponse:(PNResponse *)response;

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request;


#pragma mark - Presence observation management

- (void)disablePresenceObservationForChannels:(NSArray *)channels sendRequest:(BOOL)shouldSendRequest;


#pragma mark - Connection management

/**
 * Allow to reconnect message channel and in case if 'shouldHandleReconnectEvent'
 * is set to 'YES' it will notify delegate about successful reconnection
 */
- (void)reconnect:(BOOL)shouldHandleReconnectEvent;


#pragma mark - Channels management

/**
 * Same function as -unsubscribeFromChannelsWithPresenceEvent:
 * but also allow to specify whether leave was triggered by user
 * or not
 */
- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent
                                        byUserRequest:(BOOL)isLeavingByUserRequest;

/**
 * Same function as -unsubscribeFromChannels:withPresenceEvent:
 * but also allow to specify whether leave was triggered by user
 * or not
 */
- (void)unsubscribeFromChannels:(NSArray *)channels
              withPresenceEvent:(BOOL)withPresenceEvent
                  byUserRequest:(BOOL)isLeavingByUserRequest;

/**
 * Same as -updateSubscription but allow to specify on which
 * channels subscription should be updated
 */
- (void)updateSubscriptionForChannels:(NSArray *)channels;


#pragma mark - Presence management

/**
 * Send leave event to all channels to which
 * client subscribed at this moment
 *
 * As soon as client will receive leave request
 * confirmation all messages from unsubscribed
 * channels will be ignored
 */
- (void)leaveSubscribedChannelsByUserRequest:(BOOL)isLeavingByUserRequest;

- (void)leaveChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest;


#pragma mark - Handler methods

/**
 * Called every time when client complete
 * leave request processing
 */
- (void)handleLeaveRequestCompletionForChannels:(NSArray *)channels
                                   withResponse:(PNResponse *)response
                                  byUserRequest:(BOOL)isLeavingByUserRequest;

/**
 * Called every time when one of events occur on
 * channels:
 *     - initial subscribe
 *     - message
 *     - presence event
 */
- (void)handleEventOnChannelsForRequest:(PNSubscribeRequest *)request withResponse:(PNResponse *)response;

/**
 * Called every time when subscribe/unsubscribe
 * request processing is completed
 */
- (void)handleSubscribeUnsubscribeRequestCompletion:(PNBaseRequest *)request;

/**
 * Called every time when subscribe request fails
 */
- (void)handleSubscribeDidFailForChannels:(NSArray *)channels withError:(PNError *)error;

/**
 * Called every time when subscribe request fails
 */
- (void)handleUnsubscribeDidFailForChannels:(NSArray *)channels withError:(PNError *)error;

/**
 * Called every time when presence observation is disabled
 */
- (void)handleDisabledPresenceObservationForChannels:(NSArray *)channels;

/**
 * Handle Idle timer trigger and reconnect channel if it is possible
 */
- (void)handleIdleTimer:(NSTimer *)timer;


#pragma mark - Misc methods

/**
 * Start/stop channel idle handler timer.
 * This timer allow to detect situation when client is in idle state
 * longer than this is allowed.
 */
- (void)startChannelIdleTimer;
- (void)stopChannelIdleTimer;

/**
 * Retrieve full list of channels on which channel should subscribe
 * including presence observing channels
 */
- (NSSet *)channelsWithPresenceFromList:(NSArray *)channelsList forSubscribe:(BOOL)listForSubscribe;

/**
 * Retrieve list of channels which is cleared from presence observing
 * instances
 */
- (NSArray *)channelsWithOutPresenceFromList:(NSArray *)channelsList;


@end


#pragma mark Public interface methods

@implementation PNMessagingChannel


#pragma mark - Class methods

+ (PNMessagingChannel *)messageChannelWithDelegate:(id<PNConnectionChannelDelegate>)delegate {

    return [super connectionChannelWithType:PNConnectionChannelMessaging andDelegate:delegate];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType
       andDelegate:(id<PNConnectionChannelDelegate>)delegate {

    // Check whether initialization was successful or not
    if ((self = [super initWithType:PNConnectionChannelMessaging andDelegate:delegate])) {

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

        // Remove request from queue to unblock it (subscribe events and message post
        // requests was blocked)
        [self destroyRequest:request];
    }
    // Check whether 'Subscription'/'Presence'/'Events' request has been processed or not
    else if (request == nil || [request isKindOfClass:[PNSubscribeRequest class]]) {

        // Process subscription on channels
        [self handleEventOnChannelsForRequest:(PNSubscribeRequest *)request withResponse:response];
    }
}

- (BOOL)shouldStoreRequest:(PNBaseRequest *)request {

    return [request isKindOfClass:[PNSubscribeRequest class]];
}

- (void)terminate {
    
    [self stopChannelIdleTimer];
    [super terminate];
}


#pragma mark - Connection management

- (void)reconnect {
    
    [self reconnect:YES];
}

- (void)reconnect:(BOOL)shouldHandleReconnectEvent {
    
    self.reconnecting = shouldHandleReconnectEvent;
    
    // Forward to ther super class
    [super reconnect];
}

- (void)disconnectWithReset:(BOOL)shouldResetCommunicationChannel {

    // Forward to the super class
    [super disconnect];

    self.restoringSubscription = NO;


    // Check whether communication channel should reset state or not
    if (shouldResetCommunicationChannel) {

        // Clean up channels stack
        [self.subscribedChannelsSet removeAllObjects];
        self.presenceDisablingChannelsSet = nil;
        [self purgeObservedRequestsPool];
        [self purgeStoredRequestsPool];
        [self clearScheduledRequestsQueue];
    }
}


#pragma mark - Presence management

- (void)leaveSubscribedChannelsByUserRequest:(BOOL)isLeavingByUserRequest {

    // Check whether there some channels which
    // user can leave
    if ([self.subscribedChannelsSet count] > 0) {

        // Reset last update time token for channels in list
        [self.subscribedChannelsSet makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];

        // Schedule request to be processed as soon as
        // queue will be processed
        [self scheduleRequest:[PNLeaveRequest leaveRequestForChannels:[self.subscribedChannelsSet allObjects]
                                                        byUserRequest:isLeavingByUserRequest]
      shouldObserveProcessing:YES];
    }
}

- (void)leaveChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest {

    // Check whether specified channels set contains channels
    // on which client not subscribed
    NSSet *channelsSet = [NSSet setWithArray:channels];
    if (![self.subscribedChannelsSet intersectsSet:channelsSet]) {

        NSMutableSet *filteredChannels = [self.subscribedChannelsSet mutableCopy];
        [filteredChannels intersectSet:channelsSet];
        channelsSet = filteredChannels;
    }

    // Retrieve set of channels (including presence observers) from
    // which client should unsubscribe
    NSArray *channelsForUnsubscribe = [[self channelsWithPresenceFromList:[channelsSet allObjects] forSubscribe:NO] allObjects];
    if ([channelsForUnsubscribe count] > 0) {

        // Reset last update time token for channels in list
        [channels makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];


        // Schedule request to be processed as soon as
        // queue will be processed
        [self scheduleRequest:[PNLeaveRequest leaveRequestForChannels:channelsForUnsubscribe
                                                        byUserRequest:isLeavingByUserRequest]
      shouldObserveProcessing:YES];

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

- (void)resubscribe {

    self.restoringSubscription = NO;

    // Ensure that client connected to at least one channel
    if ([self.subscribedChannelsSet count] > 0) {

        // Unsubscribe from all channels with 'leave' presence
        // event generation
        NSArray *oldChannels = [self unsubscribeFromChannelsWithPresenceEvent:YES byUserRequest:YES];

        [self scheduleRequest:[PNSubscribeRequest subscribeRequestForChannels:oldChannels byUserRequest:YES]
      shouldObserveProcessing:YES];
    }
}

- (BOOL)canResubscribe {

    return [self.subscribedChannelsSet count] > 0;
}

- (void)restoreSubscription:(BOOL)shouldRestoreResubscriptionFromLastTimeToken {

    if ([self.subscribedChannelsSet count]) {

        if (!shouldRestoreResubscriptionFromLastTimeToken) {

            // Reset last update time token for channels in list
            [self.subscribedChannelsSet makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
        }

        self.restoringSubscription = YES;


        PNSubscribeRequest *resubscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:[self.subscribedChannelsSet allObjects]
                                                                        byUserRequest:YES];

        // Check whether messaging channel is connected or not
        if ([self isConnected]) {

            // Mark that we should close connection to terminate long-poll request on
            // server side before subscribe on new channels
            resubscribeRequest.closeConnection = YES;
        }
        [self scheduleRequest:resubscribeRequest shouldObserveProcessing:shouldRestoreResubscriptionFromLastTimeToken];

    }
}

- (void)updateSubscription {

    [self updateSubscriptionForChannels:[self.subscribedChannelsSet allObjects]];
}

- (void)updateSubscriptionForChannels:(NSArray *)channels {

    self.restoringSubscription = NO;

    // Ensure that client connected to at least one channel
    if ([channels count] > 0) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" UPDATE CHANNELS SUBSCRIPTION");

        [self scheduleRequest:[PNSubscribeRequest subscribeRequestForChannels:channels byUserRequest:YES]
      shouldObserveProcessing:NO];
    }

}

- (void)subscribeOnChannels:(NSArray *)channels {

    [self subscribeOnChannels:channels withPresenceEvent:YES];
}

- (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    self.restoringSubscription = NO;

    // Checking whether client already subscribed on one of
    // channels from set or not
    NSMutableSet *channelsSet = [[self channelsWithPresenceFromList:channels forSubscribe:YES] mutableCopy];
    if ([self.subscribedChannelsSet intersectsSet:channelsSet]) {

        NSMutableSet *filteredChannels = [self.subscribedChannelsSet mutableCopy];
        [filteredChannels intersectSet:channelsSet];
        [channelsSet minusSet:filteredChannels];


        // Checking whether there still channels on which client not subscribed yet
        if ([channelsSet count] > 0 && !withPresenceEvent) {

            // Reset last update time token for channels in list
            [channelsSet makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
        }
    }

    // Check whether client already was subscribed on channels before
    BOOL shouldReconnect = [self.subscribedChannelsSet count] > 0 && !self.isRestoringSubscription;
    if (([self.subscribedChannelsSet count] > 0 && withPresenceEvent) || !withPresenceEvent) {

        shouldReconnect = NO;
    }

    // In case if client currently connected to
    // PubNub services, we should send leave event
    NSMutableArray *subscriptionChannels = [[self unsubscribeFromChannelsWithPresenceEvent:withPresenceEvent
                                                                             byUserRequest:NO] mutableCopy];

    // Append channels on which client should subscribe
    [subscriptionChannels addObjectsFromArray:[channelsSet allObjects]];

    // Checking whether presence event should fire on subscription or not
    if (withPresenceEvent) {

        // Reset last update time token for channels in list
        [subscriptionChannels makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
    }

    PNSubscribeRequest *subscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:subscriptionChannels byUserRequest:YES];
    subscribeRequest.closeConnection = shouldReconnect;
    [self scheduleRequest:subscribeRequest shouldObserveProcessing:YES];
}

- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent {

    return [self unsubscribeFromChannelsWithPresenceEvent:withPresenceEvent byUserRequest:YES];
}

- (NSArray *)unsubscribeFromChannelsWithPresenceEvent:(BOOL)withPresenceEvent
                                        byUserRequest:(BOOL)isLeavingByUserRequest {

    self.restoringSubscription = NO;
    NSArray *subscribedChannels = [self.subscribedChannelsSet allObjects];

    // Check whether should generate 'leave' presence event
    // or not
    if (withPresenceEvent) {

        [self leaveSubscribedChannelsByUserRequest:isLeavingByUserRequest];
    }
    else {

        [self handleLeaveRequestCompletionForChannels:subscribedChannels
                                         withResponse:nil
                                        byUserRequest:isLeavingByUserRequest];


        // Reconnect messaging channel to free up long-poll on server
        [self reconnect:NO];
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
    [currentlySubscribedChannels minusSet:channelsWithPresence];

    if (withPresenceEvent) {

        if (self.isDisablingPresence) {

            [self disablePresenceObservationForChannels:[self.presenceDisablingChannelsSet allObjects]
                                            sendRequest:NO];
        }

        [self leaveChannels:[channelsWithPresence allObjects] byUserRequest:isLeavingByUserRequest];
    }
    else {

        if ([currentlySubscribedChannels count] == 0) {

            [self handleLeaveRequestCompletionForChannels:[channelsWithPresence allObjects]
                                             withResponse:nil
                                            byUserRequest:isLeavingByUserRequest];
        }
        else if (self.presenceDisablingChannelsSet == nil) {

            self.presenceDisablingChannelsSet = channelsWithPresence;
        }

    }


    if ([currentlySubscribedChannels count] > 0) {

        PNSubscribeRequest *subscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:[currentlySubscribedChannels allObjects]
                                                                                 byUserRequest:isLeavingByUserRequest];
        subscribeRequest.closeConnection = !withPresenceEvent;

        // Resubscribe on rest of channels which is left after unsubscribe
        [self scheduleRequest:subscribeRequest shouldObserveProcessing:NO];
    }
    else if(!withPresenceEvent) {

        if (self.isDisablingPresence) {

            [self handleDisabledPresenceObservationForChannels:[self.presenceDisablingChannelsSet allObjects]];
        }

        [self reconnect:NO];
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

    self.enablingPresence = YES;
    self.presenceEnablingChannelsSet = [NSSet setWithArray:presenceObservers];

    [self subscribeOnChannels:presenceObservers withPresenceEvent:NO];
}

- (void)disablePresenceObservationForChannels:(NSArray *)channels {

    [self disablePresenceObservationForChannels:channels sendRequest:YES];
}

- (void)disablePresenceObservationForChannels:(NSArray *)channels sendRequest:(BOOL)shouldSendRequest {

    if (shouldSendRequest) {

        self.disablingPresence = YES;

        NSSet *channelsWithPresence = [self channelsWithPresenceFromList:channels forSubscribe:NO];
        self.presenceDisablingChannelsSet = channelsWithPresence;


        NSMutableArray *presenceObservers = [[channels valueForKey:@"presenceObserver"] mutableCopy];
        [presenceObservers removeObject:[NSNull null]];

        [self unsubscribeFromChannels:presenceObservers withPresenceEvent:NO];
    }
    else {

        self.disablingPresence = NO;

        self.presenceDisablingChannelsSet = nil;

        // Enumerate over the list of channels and mark that it should observe for presence
        [channels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx, BOOL *channelEnumeratorStop) {

            channel.observePresence = NO;
            channel.userDefinedPresenceObservation = YES;
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
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" LEAVE REQUEST RESULT: %@", parser);

        // Ensure that parsed data has numeric data, which will
        // mean that this is status code or event enum value
        if ([[parser parsedData] isKindOfClass:[NSNumber class]]) {

            PNOperationResultEvent result = [[parser parsedData] intValue];

            shouldRemoveChannels = result == PNOperationResultLeave;
        }
    }

    if (shouldRemoveChannels) {

        [self.subscribedChannelsSet minusSet:[self channelsWithPresenceFromList:channels forSubscribe:NO]];
    }

    if (isLeavingByUserRequest) {

        // Check whether removed observation from set of channels or not
        if ([[[channels valueForKey:@"isPresenceObserver"] valueForKeyPath:@"@sum.intValue"] intValue] == [channels count]) {

            [self.messagingDelegate messagingChannel:self
             didDisablePresenceObservationOnChannels:[channels valueForKey:@"observedChannel"]];
        }
        else {

            [self.messagingDelegate messagingChannel:self
                          didUnsubscribeFromChannels:[self channelsWithOutPresenceFromList:channels]];
        }
    }
}

- (void)handleEventOnChannelsForRequest:(PNSubscribeRequest *)request withResponse:(PNResponse *)response {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" SUBSCRIBE REQUEST RESPONSE: %@\nCHANNELS: %@\nREQUEST: %@",
          response,
          request.channels,
          request);

    PNResponseParser *parser = [PNResponseParser parserForResponse:response];
    id parsedData = [parser parsedData];
    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" PARSED DATA: %@", parser);

    if ([parsedData isKindOfClass:[PNError class]] ||
        ([parsedData isKindOfClass:[PNOperationStatus class]] &&
         ((PNOperationStatus *)parsedData).error != nil)) {

        if ([parsedData isKindOfClass:[PNOperationStatus class]]) {

            parsedData = ((PNOperationStatus *)parsedData).error;
        }

        [self handleSubscribeDidFailForChannels:request.channels withError:parsedData];
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


        // Check whether events arrived from PubNub service
        // (messages, presence)
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

                    // Check whether channel was assigned to presence event or not
                    // (channel may not arrive with server response if client
                    // subscribed only for single channel)
                    if (((PNPresenceEvent *)event).channel == nil) {

                        ((PNPresenceEvent *)event).channel = channel;
                    }

                    [self.messagingDelegate messagingChannel:self didReceiveEvent:event];
                }
                else {

                    // Check whether channel was assigned to message or not
                    // (channel may not arrive with server response if client
                    // subscribed only for single channel)
                    if (((PNMessage *)event).channel == nil) {

                        ((PNMessage *)event).channel = channel;
                    }

                    [self.messagingDelegate messagingChannel:self didReceiveMessage:event];
                }
            }];
        }

        // Subscribe to the channels with new update time token
        [self updateSubscriptionForChannels:(request != nil ? request.channels : [self.subscribedChannelsSet allObjects])];
    }
}

- (void)handleSubscribeUnsubscribeRequestCompletion:(PNBaseRequest *)request {

    // Check whether channel is restoring subscription on previously
    // subscribed channels or not
    if (self.isRestoringSubscription) {

        self.restoringSubscription = NO;

        [self.messagingDelegate performSelector:@selector(messagingChannel:didRestoreSubscriptionOnChannels:)
                                     withObject:self
                                     withObject:[self subscribedChannels]];
    }

    // Store presence enabling state
    BOOL isEnablingPresence = self.isEnablingPresence;
    NSArray *presenceEnablingChannels = [self.presenceEnablingChannelsSet allObjects];
    self.enablingPresence = NO;
    self.presenceEnablingChannelsSet = nil;


    // Prepare selectors which will be pulled on delegate and
    // list of subscribed channels
    SEL delegateSelector = @selector(messagingChannel:didSubscribeOnChannels:);
    SEL dataUpdateSelector = @selector(unionSet:);

    if (isEnablingPresence) {

        delegateSelector = @selector(messagingChannel:didEnablePresenceObservationOnChannels:);
    }

    if ([request isKindOfClass:[PNLeaveRequest class]]) {

        delegateSelector = @selector(messagingChannel:didUnsubscribeFromChannels:);
        dataUpdateSelector = @selector(minusSet:);
    }

    // Store number of subscribed channels before updating it
    NSArray *subscribedChannels = nil;//[self.presenceEnablingChannelsSet allObjects];
    NSUInteger oldChannelsCount = [[self.subscribedChannelsSet allObjects] count];
    if (!isEnablingPresence) {

        subscribedChannels = [self channelsWithOutPresenceFromList:[self.subscribedChannelsSet allObjects]];
        oldChannelsCount = [subscribedChannels count];
    }

    // Add channels on which client subscribed to the set
    if ([[request valueForKey:@"channels"] count] > 0) {

        // Turn off error warning on performSelector, because ARC
        // can't understand what is going on there
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // Updating list of subscribed channels
        [self.subscribedChannelsSet performSelector:dataUpdateSelector
                                         withObject:[NSSet setWithArray:[request valueForKey:@"channels"]]];
        #pragma clang diagnostic pop
    }

    subscribedChannels = [self.subscribedChannelsSet allObjects];
    if (!isEnablingPresence) {

        subscribedChannels = [self channelsWithOutPresenceFromList:[self.subscribedChannelsSet allObjects]];
    }
    NSUInteger newChannelsCount = [subscribedChannels count];
    if (newChannelsCount != oldChannelsCount) {

        // Retrieve list of channels w/o presence channels to notify
        // user that client subscribed on new channels
        NSArray *channels = nil;
        if (isEnablingPresence) {

            NSMutableArray *presenceEnabledChannels = [[presenceEnablingChannels valueForKey:@"observedChannel"] mutableCopy];
            [presenceEnabledChannels removeObject:[NSNull null]];
            channels = presenceEnabledChannels;
        }
        else {

            channels = [self channelsWithOutPresenceFromList:[request valueForKey:@"channels"]];
        }


        // Check whether leave was generated by user request or not
        if ([channels count] > 0 && [request isSendingByUserRequest]) {

            // Turn off error warning on performSelector, because ARC
            // can't understand what is going on there
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.messagingDelegate performSelector:delegateSelector withObject:self withObject:channels];
            #pragma clang diagnostic pop
        }
    }
}

- (void)handleSubscribeDidFailForChannels:(NSArray *)channels withError:(PNError *)error {

    if (self.isEnablingPresence) {

        self.enablingPresence = NO;
        self.presenceDisablingChannelsSet = nil;

        NSMutableArray *enablingPresenceChannels = [[channels valueForKey:@"observedChannel"] mutableCopy];
        [enablingPresenceChannels removeObject:[NSNull null]];
        [self.messagingDelegate messagingChannel:self didFailPresenceEnablingOnChannels:enablingPresenceChannels withError:error];
    }
    else {

        [self.messagingDelegate messagingChannel:self didFailSubscribeOnChannels:channels withError:error];
    }
}

- (void)handleUnsubscribeDidFailForChannels:(NSArray *)channels withError:(PNError *)error {

    if (self.isDisablingPresence) {

        self.disablingPresence = NO;
        self.presenceDisablingChannelsSet = nil;

        [self.messagingDelegate messagingChannel:self didFailPresenceDisablingOnChannels:channels withError:error];
    }
    else {

        [self.messagingDelegate messagingChannel:self didFailUnsubscribeOnChannels:channels withError:error];
    }
}

- (void)handleDisabledPresenceObservationForChannels:(NSArray *)channels {

    self.disablingPresence = NO;

    // Retrieve list of presence channels which was removed from
    // subscription
    NSMutableArray *disabledPresenceChannels = [[channels valueForKey:@"presenceObserver"] mutableCopy];
    [disabledPresenceChannels removeObject:[NSNull null]];

    [self disablePresenceObservationForChannels:channels sendRequest:NO];

    if ([disabledPresenceChannels count] > 0) {

        [self handleLeaveRequestCompletionForChannels:disabledPresenceChannels
                                         withResponse:nil
                                        byUserRequest:YES];
    }
}

- (void)handleTimeoutTimer:(NSTimer *)timer {

    PNBaseRequest *request = (PNBaseRequest *)timer.userInfo;
    NSInteger errorCode = kPNRequestExecutionFailedByTimeoutError;
    NSString *errorMessage = @"Subscription failed by timeout";
    if ([request isKindOfClass:[PNLeaveRequest class]]) {

        errorMessage = @"Unsubscription failed by timeout";
    }
    PNError *error = [PNError errorWithMessage:errorMessage code:errorCode];

    if ([request isKindOfClass:[PNLeaveRequest class]]) {

        [self handleUnsubscribeDidFailForChannels:((PNSubscribeRequest *)request).channels withError:error];
    }
    else {

        [self handleSubscribeDidFailForChannels:((PNSubscribeRequest *) request).channels withError:error];
    }


    [self destroyRequest:request];


    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        // Asking to schedule next request
        [self scheduleNextRequest];
    }
}

- (void)handleIdleTimer:(NSTimer *)timer {

    [self.messagingDelegate messagingChannelIdleTimeout:self];
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

- (NSSet *)channelsWithPresenceFromList:(NSArray *)channelsList forSubscribe:(BOOL)listForSubscribe {

    NSMutableSet *fullChannelsList = [NSMutableSet setWithCapacity:[channelsList count]];
    [channelsList enumerateObjectsUsingBlock:^(PNChannel *channel,
                                               NSUInteger channelIdx,
                                               BOOL *channelEnumeratorStop) {

        [fullChannelsList addObject:channel];

        if ((channel.isUserDefinedPresenceObservation && !listForSubscribe) || listForSubscribe) {

            PNChannelPresence *presenceObserver = [channel presenceObserver];
            if (presenceObserver) {

                [fullChannelsList addObject:presenceObserver];
            }
        }
    }];


    return fullChannelsList;
}

- (NSArray *)channelsWithOutPresenceFromList:(NSArray *)channelsList {

    // Compose filtering predicate to retrieve list of channels
    // which are not presence observing channels
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"isPresenceObserver = NO"];


    return [channelsList filteredArrayUsingPredicate:filterPredicate];
}


#pragma mark - Connection delegate methods

- (void)connection:(PNConnection *)connection didConnectToHost:(NSString *)hostName {

    [self startChannelIdleTimer];
    
    // Forward to the super class
    [super connection:connection didConnectToHost:hostName];


    // Check whether message channel is reconnecting by request or not
    if (self.isReconnecting) {

        self.reconnecting = NO;

        [self.messagingDelegate messagingChannelDidReconnect:self];
    }
    else if (self.isDisablingPresence) {

        if ([self.subscribedChannelsSet isEqualToSet:self.presenceDisablingChannelsSet]) {

            [self handleDisabledPresenceObservationForChannels:[self.presenceDisablingChannelsSet allObjects]];
        }
    }
}

- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response {

    if ([self shouldHandleResponse:response]) {

        [super connection:connection didReceiveResponse:response];

        
        BOOL shouldResendRequest = response.error.code == kPNResponseMalformedJSONError;

        // Retrieve reference on observer request
        PNBaseRequest *request = [self observedRequestWithIdentifier:response.requestIdentifier];
        BOOL shouldObserveExecution = request != nil;


        // Check whether response is valid or not
        if (shouldResendRequest) {

            PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" RECEIVED MALFORMED RESPONSE: %@", response);

            if (request == nil) {

                request = [super storedRequestWithIdentifier:response.requestIdentifier];
            }
            [request reset];

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" RESCHEDULING REQUEST: %@", request);
        }
        // Looks like response is valid (continue)
        else {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" RECIEVED RESPONSE: %@", response);

            [self destroyRequest:request];
            [self processResponse:response forRequest:request];
        }


        // Check whether connection available or not
        if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {
            
            if (shouldResendRequest) {
                
                [self scheduleRequest:request shouldObserveProcessing:shouldObserveExecution];
            }
            else {
                
                // Asking to schedule next request
                [self scheduleNextRequest];
            }
        }

        [self startChannelIdleTimer];
    }
}

- (void)connection:(PNConnection *)connection didDisconnectFromHost:(NSString *)hostName {
    
    [self stopChannelIdleTimer];

    // Forward to the super class
    [super connection:connection didDisconnectFromHost:hostName];
}


#pragma mark - Requests queue delegate methods

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue willSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" WILL START REQUEST PROCESSING: %@ [BODY: %@]",
          request,
          request.resourcePath);


    // Check whether connection should be closed for resubscribe
    // or not
    if (request.shouldCloseConnection) {

        // Mark that we don't need to close connection after next time
        // this request will be scheduled for processing
        // (this will happen right after connection will be restored)
        request.closeConnection = NO;

        // Reconnect communication channel
        [self reconnect:NO];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue didSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" DID SEND REQUEST: %@ [BODY: %@]",
          request,
          request.resourcePath);


    // If we are not waiting for request completion, inform delegate
    // immediately
    if (![self isWaitingRequestCompletion:request.shortIdentifier]) {

        // Check whether this is 'Subscribe' or 'Leave' request or not
        // (there probably no situation when this situation will take place)
        if ([request isKindOfClass:[PNSubscribeRequest class]] ||
            [request isKindOfClass:[PNLeaveRequest class]]) {

            if (self.isDisablingPresence) {

                [self handleDisabledPresenceObservationForChannels:[self.presenceDisablingChannelsSet allObjects]];
            }

            [self handleSubscribeUnsubscribeRequestCompletion:request];
        }
    }


    [self scheduleNextRequest];
}

- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request withError:(PNError *)error {

    // Forward to the super class
    [super requestsQueue:queue didFailRequestSend:request withError:error];


    PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" DID FAIL TO SEND REQUEST: %@ [BODY: %@]",
          request,
          request.resourcePath);


    // Check whether request can be rescheduled or not
    if (![request canRetry]) {

        // Removing failed request from queue
        [self destroyRequest:request];


        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" REQUEST PROCESSING FAILED (REMOVED): %@",
              request);

        // Check whether this is 'Subscribe' or 'Leave' request or not
        if ([request isKindOfClass:[PNSubscribeRequest class]] ||
            [request isKindOfClass:[PNLeaveRequest class]]) {

            // Retrieve list of channels w/o presence channels to notify
            // user that client subscribed on new channels
            NSArray *channels = [self channelsWithOutPresenceFromList:[request valueForKey:@"channels"]];
            if (self.isDisablingPresence || self.isEnablingPresence) {

                NSSet *channelsSet = self.isDisablingPresence?self.presenceDisablingChannelsSet:self.presenceEnablingChannelsSet;

                channels = [channelsSet allObjects];
            }

            if ([channels count] > 0 && [request isSendingByUserRequest]) {

                if ([request isKindOfClass:[PNSubscribeRequest class]]) {

                    // Notify delegate about that client failed to subscribe on channels
                    [self handleSubscribeDidFailForChannels:channels withError:error];
                }
                else {

                    // Notify delegate about that client failed to leave set of channels
                    [self handleUnsubscribeDidFailForChannels:channels withError:error];
                }
            }
        }
    }


    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        [self scheduleNextRequest];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue
     didCancelRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue didCancelRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" DID CANCEL REQUEST: %@ [BODY: %@]",
          request,
          request.resourcePath);
}


#pragma mark Memory management

- (void)dealloc {

    [self stopChannelIdleTimer];
}

#pragma mark -


@end
