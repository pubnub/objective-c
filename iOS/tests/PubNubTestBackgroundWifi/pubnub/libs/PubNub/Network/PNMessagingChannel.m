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
#import "PNCache.h"


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
    
    /**
     Channel re-subscribe after server didn't respond with ping (new time token) message.
     */
    PNMessagingChannelResubscribeOnTimeOut = 1 << 7
};


#pragma mark - Private interface methods

@interface PNMessagingChannel ()


#pragma mark - Properties

// Stores list of channels (including presence) on which this client is subscribed now
@property (nonatomic, strong) NSMutableSet *subscribedChannelsSet;
@property (nonatomic, strong) NSMutableSet *oldSubscribedChannelsSet;

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
 Method will initiate subscription on specified set of channels. This request will add provided channels set to the
 list of channels on which client already subscribed.
 
 @code
 @endcode
 This method extends \a -subscribeOnChannels:withPresenceEvent: and allow to specify whether any changes should be
 performed in specified channels list as for presence enabling / disabling.
 
 @param channels
 List of \b PNChannel instances on which it should subscribe.
 
 @param channelsPresence
 Bit mask from \b PNMessagingConnectionStateFlag enumerator: PNMessagingChannelEnablingPresence or
 PNMessagingChannelDisablingPresence to identify what kind of changes should be performed.
 */
- (void)subscribeOnChannels:(NSArray *)channels withPresence:(NSUInteger)channelsPresence;

/**
 Method will initiate subscription on specified set of channels. This request will add provided channels set to the
 list of channels on which client already subscribed.
 
 @code
 @endcode
 This method extends \a -subscribeOnChannels:withPresence: and allow to specify state which should
 be sent along with subscription request.
 
 @param channels
 List of \b PNChannel instances on which it should subscribe.
 
 @param channelsPresence
 Bit mask from \b PNMessagingConnectionStateFlag enumerator: PNMessagingChannelEnablingPresence or
 PNMessagingChannelDisablingPresence to identify what kind of changes should be performed.
 
 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 */
- (void)subscribeOnChannels:(NSArray *)channels
               withPresence:(NSUInteger)channelsPresence
                    catchUp:(BOOL)shouldCatchUp
             andClientState:(NSDictionary *)clientState;

/**
 Unsubscribe from all channels and allow to specify whether request has been done by user or not.
 */
- (void)unsubscribeFromChannelsByUserRequest:(BOOL)isLeavingByUserRequest;

/**
 * Same as -updateSubscription but allow to specify on which channels subscription should be updated
 */
- (void)updateSubscriptionForChannels:(NSArray *)channels withPresence:(NSUInteger)presenceType
                           forRequest:(PNSubscribeRequest *)request forcibly:(BOOL)isUpdateForced;


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
 Retrieve filtered state dictionary based on list of channels for which it is set.
 
 @param state
 Source dictionary which should be filtered with list of channels from \c channels
 
 @param channels
 List of \b PNChannel instances which should be used for state filtering.
 
 @return Filtered client state \b NSDictionary instance.
 */
- (NSDictionary *)stateFromClientState:(NSDictionary *)state forChannels:(NSArray *)channels;

/**
 Retrieve merged state for client based on newly submitted and already processed client state.
 
 @param state
 Newly submitted client state information.
 
 @return Merged client state information.
 */
- (NSDictionary *)mergedClientStateWithState:(NSDictionary *)state;

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
        self.oldSubscribedChannelsSet = [NSMutableSet set];
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

- (BOOL)shouldScheduleRequest:(PNBaseRequest *)request {
    
    BOOL shouldScheduleRequest = YES;
    
    if ([request isKindOfClass:[PNTimeTokenRequest class]]) {
        
        shouldScheduleRequest = !PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents) &&
        !PNBitIsOn(self.messagingState, PNMessagingChannelRestoringSubscription) &&
        !PNBitIsOn(self.messagingState, PNMessagingChannelResubscribeOnTimeOut);
    }
    
    
    return shouldScheduleRequest;
}

- (void)handleRequestProcessingDidFail:(PNBaseRequest *)request withError:(PNError *)error {
    
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

- (void)makeScheduledRequestsFail:(NSArray *)requestsList withError:(PNError *)processingError {
    
    PNError *error = processingError;
    if (error == nil) {
        
        error = [PNError errorWithCode:kPNRequestExecutionFailedOnInternetFailureError];
    }
    
    [requestsList enumerateObjectsUsingBlock:^(NSString *requestIdentifier, NSUInteger requestIdentifierIdx,
                                               BOOL *requestIdentifierEnumeratorStop) {
        
        PNBaseRequest *request = [self requestWithIdentifier:requestIdentifier];
        
        if (![request isKindOfClass:[PNSubscribeRequest class]] ||
            ([request isKindOfClass:[PNSubscribeRequest class]] && ![(PNSubscribeRequest *)request isInitialSubscription])) {
            
            // Removing failed request from queue
            [self destroyRequest:request];
            [self handleRequestProcessingDidFail:request withError:error];
        }
        
    }];
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
                                           if (isSubscribeRequest && self.isRestoringSubscriptionOnResume) {
                                               
                                               if (!useLastTimeToken) {
                                                   
                                                   [(PNSubscribeRequest *)request resetTimeToken];
                                               }
                                               
                                               PNBitsOff(&_messagingState, PNMessagingChannelUpdateSubscription, PNMessagingChannelResubscribeOnTimeOut,
                                                         PNMessagingChannelSubscriptionWaitingForEvents, BITS_LIST_TERMINATOR);
                                               PNBitsOn(&_messagingState, PNMessagingChannelRestoringSubscription,
                                                        PNMessagingChannelSubscriptionTimeTokenRetrieve, BITS_LIST_TERMINATOR);
                                               
                                               [(PNSubscribeRequest *)request resetSubscriptionTimeToken];
                                               
                                               // Notify delegate that messaging channel is about to restore subscription on previous channels
                                               [self.messagingDelegate messagingChannel:self willRestoreSubscriptionOnChannels:((PNSubscribeRequest *)request).channels
                                                                              sequenced:NO];
                                           }
                                           
                                           // Check whether client is waiting for request completion
                                           BOOL isWaitingForCompletion = [self isWaitingRequestCompletion:request.shortIdentifier];
                                           if (isSubscribeRequest) {
                                               
                                               isWaitingForCompletion = [(PNSubscribeRequest *)request isInitialSubscription];
                                           }
                                           
                                           // Clean up query (if request has been stored in it)
                                           [self destroyRequest:request];
                                           
                                           // Send request back into queue with higher priority among other requests
                                           [self scheduleRequest:request shouldObserveProcessing:isWaitingForCompletion outOfOrder:YES
                                                launchProcessing:NO];
                                       }];
        
        // Try to check whether there is leave request or not in stack
        if ([self hasRequestsWithClass:[PNLeaveRequest class]]) {
            
            PNBaseRequest *request = [[self requestsWithClass:[PNLeaveRequest class]] lastObject];
            if (request) {
                
                // Check whether client is waiting for request completion
                BOOL isWaitingForCompletion = [self isWaitingRequestCompletion:request.shortIdentifier];
                
                // Clean up query (if request has been stored in it)
                [self destroyRequest:request];
                
                // Send request back into queue with higher priority among other requests
                [self scheduleRequest:request shouldObserveProcessing:isWaitingForCompletion outOfOrder:YES
                     launchProcessing:NO];
            }
            
        }
        
        
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
    
    // Forward to the super class
    [super disconnect];
    
    
    // Check whether communication channel should reset state or not
    if (shouldResetCommunicationChannel) {
        
        // Clean up channels stack
        [self.subscribedChannelsSet removeAllObjects];
        [self.oldSubscribedChannelsSet removeAllObjects];
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
        
        if (![self hasRequestsWithClass:[PNSubscribeRequest class]]) {
            
            PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
                      PNMessagingChannelResubscribeOnTimeOut, BITS_LIST_TERMINATOR);
        }
        
        if (isLeavingByUserRequest) {
            
            [self.messagingDelegate messagingChannel:self willUnsubscribeFromChannels:request.channels sequenced:NO];
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
        
        NSString *action = @"RESTORING SUBSCRIPTION";
        if (PNBitIsOn(self.messagingState, PNMessagingChannelResubscribeOnTimeOut)) {
            
            action = @"RE-SUBSCRIBE ON CONNECTION IDLE TIMER";
        }
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] %@... (USE LAST TIME"
              " TOKEN? %@)(STATE: %d)", self, action, shouldRestoreSubscriptionFromLastTimeToken ? @"YES" : @"NO",
              self.messagingState);
        
        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self destroyByRequestClass:[PNSubscribeRequest class]];
        
        if (!shouldRestoreSubscriptionFromLastTimeToken) {
            
            // Reset last update time token for channels in list
            [self.subscribedChannelsSet makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
        }
        
        PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
                  PNMessagingChannelSubscriptionWaitingForEvents, BITS_LIST_TERMINATOR);
        PNBitOn(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
        
        if (!PNBitIsOn(self.messagingState, PNMessagingChannelResubscribeOnTimeOut)) {
            
            PNBitOn(&_messagingState, PNMessagingChannelRestoringSubscription);
        }
        PNBitOff(&_messagingState, PNMessagingChannelResubscribeOnTimeOut);
        
        PNSubscribeRequest *resubscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:[self.subscribedChannelsSet allObjects]
                                                                                   byUserRequest:YES
                                                                                 withClientState:nil];
        [resubscribeRequest resetSubscriptionTimeToken];
        
        // Check whether connection channel is waiting for response via long-poll connection or not
        resubscribeRequest.closeConnection = YES;
        if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {
            
            resubscribeRequest.closeConnection = NO;
        }
        
        if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringSubscription)) {
            
            // Notify delegate that messaging channel is about to restore subscription on previous channels
            [self.messagingDelegate messagingChannel:self willRestoreSubscriptionOnChannels:resubscribeRequest.channels
                                           sequenced:NO];
        }
        
        
        [self scheduleRequest:resubscribeRequest
      shouldObserveProcessing:PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve)
                   outOfOrder:YES launchProcessing:YES];
        
    }
}

- (void)updateSubscriptionForChannels:(NSArray *)channels withPresence:(NSUInteger)presenceType
                           forRequest:(PNSubscribeRequest *)request forcibly:(BOOL)isUpdateForced {
    
    // Ensure that client connected to at least one channel
    if ([channels count] > 0 || request) {
        
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] UPDATING SUBSCRIPTIONS... (STATE: %d)",
              self, self.messagingState);
        
        
        BOOL shouldSendUpdateSubscriptionRequest = YES;
        
        if (!isUpdateForced) {
            
            // Check whether user want to subscribe on particular channel (w/ or w/o presence event) or unsubscribe from all channels
            if ([self hasRequestsWithClass:[PNSubscribeRequest class]] || [self hasRequestsWithClass:[PNLeaveRequest class]]) {
                
                shouldSendUpdateSubscriptionRequest = NO;
                
                // Check whether user want to unsubscribe from all channels or not
                __block BOOL isLeavingAllChannels = NO;
                NSArray *leaveRequests  = [self requestsWithClass:[PNLeaveRequest class]];
                [leaveRequests enumerateObjectsUsingBlock:^(PNLeaveRequest *leaveRequest, NSUInteger leaveRequestIdx,
                                                            BOOL *leaveRequestEnumeratorStop) {
                    
                    if (!isLeavingAllChannels) {
                        
                        // Check whether we already found request which will unsubscribe from all channels or not
                        NSSet *leaveChannelsSet = [NSSet setWithArray:leaveRequest.channels];
                        if ([leaveChannelsSet isEqualToSet:self.subscribedChannelsSet]) {
                            
                            isLeavingAllChannels = YES;
                        }
                    }
                    else {
                        
                        [self destroyRequest:leaveRequest];
                    }
                }];
                
                // Check whether is leaving only partial channels and there is no subscribe request for rest of the channels
                if ([leaveRequests count] > 0 && !isLeavingAllChannels && ![self hasRequestsWithClass:[PNSubscribeRequest class]]) {
                    
                    [self destroyByRequestClass:[PNLeaveRequest class]];
                    shouldSendUpdateSubscriptionRequest = YES;
                }
                
                if ([self hasRequestsWithClass:[PNSubscribeRequest class]]) {
                    
                    shouldSendUpdateSubscriptionRequest = NO;
                }
            }
        }
        
        if (!shouldSendUpdateSubscriptionRequest) {
            
            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUBSCRIPTION UPDATE CANCELED. WE ALREADY SENT"
                  " REQUEST (STATE: %d)", self, self.messagingState);
        }
        
        BOOL shouldModifyPresence = PNBitsIsOn(presenceType, NO, PNMessagingChannelEnablingPresence, PNMessagingChannelDisablingPresence,
                                               BITS_LIST_TERMINATOR);
        
        
        // Depending on whether clint already try to subscribe on another set of channels or leave all channels, there maybe no
        // reason to send request to subscribe on channels with updated time token
        if (shouldSendUpdateSubscriptionRequest) {
            
            [self destroyByRequestClass:[PNLeaveRequest class]];
            [self destroyByRequestClass:[PNSubscribeRequest class]];
            
            NSMutableSet *channelsForSubscription = [NSMutableSet setWithArray:channels];
            if (request) {
                
                [channelsForSubscription addObjectsFromArray:[request channelsForSubscription]];
            }
            if ([[channels lastObject] isTimeTokenChangeLocked]) {
                
                [channelsForSubscription makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];
            }
            
            PNSubscribeRequest *subscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:[channelsForSubscription allObjects]
                                                                                     byUserRequest:YES
                                                                                   withClientState:request.state];
            if (shouldModifyPresence) {
                
                subscribeRequest.channelsForPresenceEnabling = request.channelsForPresenceEnabling;
                subscribeRequest.channelsForPresenceDisabling = request.channelsForPresenceDisabling;
                [subscribeRequest resetTimeTokenTo:[PNChannel largestTimetokenFromChannels:subscribeRequest.channels]];
            }
            
            BOOL isWaitingForTimeToken = PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
            PNBitOn(&_messagingState, PNMessagingChannelUpdateSubscription);
            subscribeRequest.closeConnection = PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
            if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {
                
                subscribeRequest.closeConnection = NO;
            }
            
            if (!isWaitingForTimeToken) {
                
                subscribeRequest.state = [[PubNub sharedInstance].cache stateForChannels:[channelsForSubscription allObjects]];
            }
            
            // In case if we are restoring subscription and user decided to discard old time token client should
            // send channel long-poll request (with updated time token) before other requests
            [self scheduleRequest:subscribeRequest
          shouldObserveProcessing:[subscribeRequest isInitialSubscription]
                       outOfOrder:PNBitIsOn(self.messagingState, PNMessagingChannelRestoringSubscription)
                 launchProcessing:YES];
        }
    }
    
}

- (void)subscribeOnChannels:(NSArray *)channels {
    
    [self subscribeOnChannels:channels withCatchUp:NO andClientState:nil];
}

- (void)subscribeOnChannels:(NSArray *)channels withCatchUp:(BOOL)shouldCatchUp
             andClientState:(NSDictionary *)clientState {
    
    clientState = [[self stateFromClientState:clientState
                                  forChannels:[[self subscribedChannels] arrayByAddingObjectsFromArray:channels]] mutableCopy];
    
    [self subscribeOnChannels:channels withPresence:0 catchUp:shouldCatchUp
               andClientState:[self mergedClientStateWithState:clientState]];
}

- (NSSet *)channelsForPresenceEnablingFromArray:(NSArray *)channels {
    
    NSMutableSet *presenceChannelsSet = [NSMutableSet setWithSet:[self channelsWithPresenceFromList:channels forSubscribe:YES onlyPresence:YES]];
    NSMutableSet *existingPresenceChannelsSet = [NSMutableSet setWithArray:[self channelsWithPresenceFromList:[self.subscribedChannelsSet allObjects]]];
    [presenceChannelsSet removeObject:[NSNull null]];
    [existingPresenceChannelsSet removeObject:[NSNull null]];
    
    // Remove all presence enabled channels on which client already subscribed. It will allow to find set of channels which has been enabled for presence
    // observation.
    [presenceChannelsSet minusSet:existingPresenceChannelsSet];
    
    
    return [presenceChannelsSet count] ? presenceChannelsSet : nil;
}

- (NSSet *)channelsForPresenceDisablingFromArray:(NSArray *)channels {
    
    NSMutableSet *channelsSet = [NSMutableSet set];
    NSMutableSet *presenceChannelsSet = [NSMutableSet setWithSet:[self channelsWithPresenceFromList:channels forSubscribe:YES onlyPresence:YES]];
    [presenceChannelsSet removeObject:[NSNull null]];
    NSMutableSet *observedChannelsSet = [NSMutableSet setWithSet:[presenceChannelsSet valueForKey:@"observedChannel"]];
    [observedChannelsSet removeObject:[NSNull null]];
    NSMutableSet *existingPresenceChannelsSet = [NSMutableSet setWithArray:[self channelsWithPresenceFromList:[self.subscribedChannelsSet allObjects]]];
    [existingPresenceChannelsSet removeObject:[NSNull null]];
    NSMutableSet *existingObservedChannelsSet = [NSMutableSet setWithSet:[existingPresenceChannelsSet valueForKey:@"observedChannel"]];
    [existingObservedChannelsSet removeObject:[NSNull null]];
    
    [existingObservedChannelsSet enumerateObjectsUsingBlock:^(PNChannel *channel, BOOL *channelEnumeratorStop) {
        
        // Checking on whether channel from which presence observation already enabled (subscribed on this channel) exist in list of channels for subscription
        // and in same time still has observation instance.
        if ([channels containsObject:channel] && ![observedChannelsSet containsObject:channel]) {
            
            [channelsSet addObject:([channel presenceObserver] ? [channel presenceObserver] : [PNChannelPresence presenceForChannel:channel] )];
        }
    }];
    
    
    return [channelsSet count] ? channelsSet : nil;
}

- (void)subscribeOnChannels:(NSArray *)channels withPresence:(NSUInteger)channelsPresence {
    
    [self subscribeOnChannels:channels withPresence:channelsPresence catchUp:NO andClientState:nil];
}

- (void)subscribeOnChannels:(NSArray *)channels withPresence:(NSUInteger)channelsPresence catchUp:(BOOL)shouldCatchUp
             andClientState:(NSDictionary *)clientState {
    
    NSMutableSet *channelsSet = nil;
    BOOL isChangingPresenceOnSubscribedChannels = NO;
    BOOL indirectionalPresenceModification = NO;
    NSSet *channelsForPresenceEnabling = nil;
    NSSet *channelsForPresenceDisabling = nil;
    BOOL isPresenceModification = PNBitsIsOn(channelsPresence, NO, PNMessagingChannelEnablingPresence, PNMessagingChannelDisablingPresence,
                                             BITS_LIST_TERMINATOR);
    
    if (!isPresenceModification) {
        
        unsigned long updatedChannelsPresence = channelsPresence;
        channelsForPresenceEnabling  = [self channelsForPresenceEnablingFromArray:channels];
        channelsForPresenceDisabling  = [self channelsForPresenceDisablingFromArray:channels];
        
        if ([channelsForPresenceEnabling count]) {
            
            PNBitOn(&updatedChannelsPresence, PNMessagingChannelEnablingPresence);
        }
        if ([channelsForPresenceDisabling count]) {
            
            PNBitOn(&updatedChannelsPresence, PNMessagingChannelDisablingPresence);
        }
        channelsPresence = updatedChannelsPresence;
        isPresenceModification = PNBitsIsOn(channelsPresence, NO, PNMessagingChannelEnablingPresence, PNMessagingChannelDisablingPresence,
                                            BITS_LIST_TERMINATOR);
        
        indirectionalPresenceModification = isPresenceModification;
    }
    
    if (isPresenceModification) {
        
        NSString *action = @"ENABLING";
        NSString *additionalAction = @"";
        if (PNBitsIsOn(channelsPresence, YES, PNMessagingChannelEnablingPresence, PNMessagingChannelDisablingPresence, BITS_LIST_TERMINATOR)) {
            
            action = @"ENABLING / DISABLING";
        }
        else if (PNBitIsOn(channelsPresence, PNMessagingChannelDisablingPresence)) {
            
            action = @"DISABLING";
        }
        
        if (indirectionalPresenceModification) {
            
            additionalAction = @" AND SUBSCRIBING";
        }
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] %@ PRESENCE%@ ON SPECIFIC SET OF CHANNELS... (STATE: %d)",
              self, action, additionalAction, self.messagingState);
    }
    else {
        
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUBSCRIBING ON SPECIFIC SET OF CHANNELS... (STATE: %d)",
              self, self.messagingState);
    }
    
    if (isPresenceModification) {
        
        if (!indirectionalPresenceModification) {
            
            NSMutableSet *targetPresenceObservers = [NSMutableSet setWithArray:channels];
            NSMutableSet *presenceObservers = [NSMutableSet setWithArray:[self channelsWithPresenceFromList:[self.subscribedChannelsSet allObjects]]];
            [presenceObservers removeObject:[NSNull null]];
            
            if (PNBitIsOn(channelsPresence, PNMessagingChannelEnablingPresence)) {
                
                // Remove presence observers for which client already subscribed
                [targetPresenceObservers minusSet:presenceObservers];
                
                channelsForPresenceEnabling = targetPresenceObservers;
            }
            else {
                
                // Extract channels for which PubNub client really enabled presence observation
                [targetPresenceObservers intersectSet:presenceObservers];
                
                channelsForPresenceDisabling = targetPresenceObservers;
            }
        }
    }
    
    // Check whether subscribe request or whether this is subscribe request with indirectional presence observation state change
    if (!isPresenceModification || indirectionalPresenceModification) {
        
        channelsSet = [NSMutableSet setWithArray:[self channelsWithOutPresenceFromList:channels]];
        NSUInteger channelsSetCount = [channelsSet count];
        [channelsSet minusSet:self.subscribedChannelsSet];
        
        // Set to \c YES in case if user tried to update presence observation with PNChannel constructor on channel for
        // which client already subscribed.
        isChangingPresenceOnSubscribedChannels = indirectionalPresenceModification && channelsSetCount > 0 && [channelsSet count] == 0;
    }
    
    // Check whether there is at leas one channel at which client didn't subscribed yet
    BOOL isAbleToSendRequest = [channelsSet count] || [channelsForPresenceEnabling count] || [channelsForPresenceDisabling count];
    
    if (isAbleToSendRequest) {
        
        BOOL hasValidSetOfChannels = YES;
        [self destroyByRequestClass:[PNSubscribeRequest class]];
        
        NSMutableSet *subscriptionChannelsSet = [NSMutableSet setWithSet:self.subscribedChannelsSet];
        [self.oldSubscribedChannelsSet setSet:subscriptionChannelsSet];
        [subscriptionChannelsSet unionSet:channelsSet];
        
        // In case if user defined that subscription request should keep previous time token or request new one
        // client will update channels time token value.
        if (!shouldCatchUp && ![self.messagingDelegate shouldKeepTimeTokenOnChannelsListChange:self]) {
            
            [subscriptionChannelsSet makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
            [channelsForPresenceEnabling makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
            [channelsForPresenceDisabling makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
        }
        
        PNSubscribeRequest *subscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:[subscriptionChannelsSet allObjects]
                                                                                 byUserRequest:YES
                                                                               withClientState:clientState];
        [subscribeRequest resetSubscriptionTimeToken];
        
        if ((!isPresenceModification || indirectionalPresenceModification) && [channelsSet count]) {
            
            [self.messagingDelegate messagingChannel:self
                             willSubscribeOnChannels:[self channelsWithOutPresenceFromList:[channelsSet allObjects]]
                                           sequenced:([channelsForPresenceEnabling count] || [channelsForPresenceDisabling count])];
        }
        
        if ([channelsForPresenceEnabling count]) {
            
            subscribeRequest.channelsForPresenceEnabling = [channelsForPresenceEnabling allObjects];
            [self.messagingDelegate messagingChannel:self
             willEnablePresenceObservationOnChannels:[[channelsForPresenceEnabling valueForKey:@"observedChannel"] allObjects]
                                           sequenced:([channelsForPresenceDisabling count] > 0)];
        }
        
        if ([channelsForPresenceDisabling count]) {
            
            if ([subscribeRequest.channels count] == [channelsForPresenceDisabling count] &&
                [[NSSet setWithArray:subscribeRequest.channels] isEqualToSet:channelsForPresenceDisabling]) {
                
                hasValidSetOfChannels = NO;
                
                [self.messagingDelegate messagingChannel:self
                 didDisablePresenceObservationOnChannels:[[channelsForPresenceDisabling valueForKey:@"observedChannel"] allObjects]
                                               sequenced:NO];
            }
            else {
                
                subscribeRequest.channelsForPresenceDisabling = [channelsForPresenceDisabling allObjects];
                [self.messagingDelegate messagingChannel:self
                willDisablePresenceObservationOnChannels:[[channelsForPresenceDisabling valueForKey:@"observedChannel"] allObjects]
                                               sequenced:NO];
            }
        }
        
        if (hasValidSetOfChannels) {
            
            if (([channelsSet count] && PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents)) ||
                ((isPresenceModification && !indirectionalPresenceModification) || indirectionalPresenceModification)) {
                
                subscribeRequest.closeConnection = YES;
            }
            
            PNBitsOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve, PNMessagingChannelSubscriptionWaitingForEvents,
                      BITS_LIST_TERMINATOR);
            PNBitOn(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
            
            
            if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {
                
                subscribeRequest.closeConnection = NO;
            }
            
            if ([[subscribeRequest.channelsForSubscription lastObject] isTimeTokenChangeLocked] && ![subscribeRequest isInitialSubscription]) {
                
                PNBitOn(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
                PNBitOff(&_messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
                
                [subscribeRequest resetTimeToken];
            }
            
            [self scheduleRequest:subscribeRequest shouldObserveProcessing:PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve)];
        }
        else {
            
            isAbleToSendRequest = NO;
            [self reconnect];
        }
    }
    if ([channelsSet count] == 0 && (!(isPresenceModification && indirectionalPresenceModification) || isChangingPresenceOnSubscribedChannels)) {
        
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUBSCRIBED ON SPECIFIC SET OF "
              "CHANNELS (ALREADY SUBSCRIBED)(STATE: %d)", self, self.messagingState);
        
        // Checking whether provided client state changed or not.
        if ([clientState count] && ![clientState isEqualToDictionary:[[PubNub sharedInstance].cache state]]) {
            
            // Looks like client try to subscribed on channels on which it already subscribed, and mean time changed
            // client state values, so we should force state storage and client re-subscription.
            [[PubNub sharedInstance].cache storeClientState:clientState forChannels:[self.subscribedChannelsSet allObjects]];
            
            [self updateSubscriptionForChannels:[self.subscribedChannelsSet allObjects] withPresence:0
                                     forRequest:nil forcibly:YES];
        }
        
        [self.messagingDelegate messagingChannel:self didSubscribeOnChannels:channels sequenced:isPresenceModification
                                 withClientState:clientState];
    }
    
    
    if (isPresenceModification && !isAbleToSendRequest) {
        
        if (PNBitIsOn(channelsPresence, PNMessagingChannelEnablingPresence)) {
            
            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] ENABLED PRESENCE ON SPECIFIC SET "
                  "OF CHANNELS (ALREADY ENABLED)(STATE: %d)", self, self.messagingState);
            
            NSArray *presenceEnabledChannelsList = [[channelsForPresenceEnabling valueForKey:@"observedChannel"] allObjects];
            if (![presenceEnabledChannelsList count]) {
                
                presenceEnabledChannelsList = [[self channelsWithPresenceFromList:channels] valueForKey:@"observedChannel"];
            }
            
            [self.messagingDelegate messagingChannel:self
              didEnablePresenceObservationOnChannels:presenceEnabledChannelsList
                                           sequenced:PNBitIsOn(channelsPresence, PNMessagingChannelDisablingPresence)];
        }
        
        if (PNBitIsOn(channelsPresence, PNMessagingChannelDisablingPresence)) {
            
            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] DISABLED PRESENCE ON SPECIFIC "
                  "SET OF CHANNELS (PRESENCE OBSERVATION NOT ENABLED ON SPECIFIED SET OF CHANNELS)(STATE: %d)", self, self.messagingState);
            
            // Remove 'presence enabled' state from list of specified channels
            [self disablePresenceObservationForChannels:[channelsForPresenceDisabling valueForKey:@"observedChannel"]
                                            sendRequest:NO];
            
            [self.messagingDelegate messagingChannel:self
             didDisablePresenceObservationOnChannels:[[channelsForPresenceDisabling valueForKey:@"observedChannel"] allObjects]
                                           sequenced:NO];
        }
    }
}

- (void)restoreSubscriptionOnPreviousChannels {
    
    NSArray *channelsList = [self.subscribedChannelsSet allObjects];
    if ([channelsList count] > 0) {
        
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUBSCRIBING ON PREVIOUS CHANNELS... (STATE: %d)",
              self, self.messagingState);
        
        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self destroyByRequestClass:[PNSubscribeRequest class]];
        
        PNBitOff(&_messagingState, PNMessagingChannelResubscribeOnTimeOut);
        PNBitOn(&_messagingState, PNMessagingChannelRestoringSubscription);
        
        PNSubscribeRequest *resubscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:channelsList
                                                                                   byUserRequest:NO withClientState:nil];
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

- (void)unsubscribeFromChannelsByUserRequest:(BOOL)isLeavingByUserRequest {
    
    // In case if unsubscribe has been triggered by user, there is no possibility that client can be in
    // 'subscription restore' state
    if (isLeavingByUserRequest) {
        
        PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
                  PNMessagingChannelResubscribeOnTimeOut, BITS_LIST_TERMINATOR);
    }
    
    // Check whether should generate 'leave' presence event or not
    [self leaveSubscribedChannelsByUserRequest:isLeavingByUserRequest];
}

- (void)unsubscribeFromChannels:(NSArray *)channels {
    
    [self unsubscribeFromChannels:channels byUserRequest:YES ];
}

- (void)unsubscribeFromChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest {
    
    // Retrieve list of channels which will left after unsubscription
    NSMutableSet *currentlySubscribedChannels = [self.subscribedChannelsSet mutableCopy];
    NSSet *channelsWithPresence = [self channelsWithPresenceFromList:channels forSubscribe:NO];
    
    // Check whether there is at least one of channels from which client should unsubscribe is in the list
    // of subscribed or not
    if ([currentlySubscribedChannels intersectsSet:channelsWithPresence]) {
        
        [currentlySubscribedChannels minusSet:channelsWithPresence];
        [self destroyByRequestClass:[PNSubscribeRequest class]];
        [self leaveChannels:[channelsWithPresence allObjects] byUserRequest:isLeavingByUserRequest];
        
        
        if (isLeavingByUserRequest && [currentlySubscribedChannels count] > 0) {
            
            // In case if user defined that subscription request should keep previous time token or request new one
            // client will update channels time token value.
            if (![self.messagingDelegate shouldKeepTimeTokenOnChannelsListChange:self]) {
                
                [currentlySubscribedChannels makeObjectsPerformSelector:@selector(resetUpdateTimeToken)];
            }
            
            PNSubscribeRequest *subscribeRequest = [PNSubscribeRequest subscribeRequestForChannels:[currentlySubscribedChannels allObjects]
                                                                                     byUserRequest:isLeavingByUserRequest
                                                                                   withClientState:nil];
            [subscribeRequest resetSubscriptionTimeToken];
            
            subscribeRequest.closeConnection = PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
            
            PNBitsOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve, PNMessagingChannelSubscriptionWaitingForEvents,
                      BITS_LIST_TERMINATOR);
            PNBitOn(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
            if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringConnectionTerminatedByServer)) {
                
                subscribeRequest.closeConnection = NO;
            }
            
            [self destroyByRequestClass:[PNSubscribeRequest class]];
            
            // Resubscribe on rest of channels which is left after unsubscribe
            [self scheduleRequest:subscribeRequest
          shouldObserveProcessing:!PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents)];
        }
        else if (PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents)) {
            
            // Reconnect messaging channel to free up long-poll on server
            [self reconnect];
        }
    }
    else {
        
        // Schedule immediately that client unsubscribed from suggested channels
        [self.messagingDelegate messagingChannel:self didUnsubscribeFromChannels:channels sequenced:NO ];
        
        if (PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionWaitingForEvents)) {
            
            // Reconnect messaging channel to free up long-poll on server
            [self reconnect];
        }
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
    
    [self subscribeOnChannels:presenceObservers withPresence:PNMessagingChannelEnablingPresence];
}

- (void)disablePresenceObservationForChannels:(NSArray *)channels {
    
    [self disablePresenceObservationForChannels:channels sendRequest:YES];
}

- (void)disablePresenceObservationForChannels:(NSArray *)channels sendRequest:(BOOL)shouldSendRequest {
    
    if (shouldSendRequest) {
        
        NSMutableArray *presenceObservers = [[channels valueForKey:@"presenceObserver"] mutableCopy];
        [presenceObservers removeObject:[NSNull null]];
        
        
        if ([presenceObservers count]) {
            
            [self subscribeOnChannels:presenceObservers withPresence:PNMessagingChannelDisablingPresence];
        }
        else {
            
            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] DISABLED PRESENCE ON SPECIFIC "
                  "SET OF CHANNELS (PRESENCE OBSERVATION NOT ENABLED ON SPECIFIED SET OF CHANNELS)(STATE: %d)", self, self.messagingState);
            
            // Remove 'presence enabled' state from list of specified channels
            [self disablePresenceObservationForChannels:channels sendRequest:NO];
            
            [self.messagingDelegate messagingChannel:self didDisablePresenceObservationOnChannels:channels sequenced:NO];
        }
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

- (void)handleLeaveRequestCompletionForChannels:(NSArray *)channels withResponse:(PNResponse *)response
                                  byUserRequest:(BOOL)isLeavingByUserRequest {
    
    BOOL shouldRemoveChannels = [channels count] > 0;
    
    if (response != nil) {
        
        PNResponseParser *parser = [PNResponseParser parserForResponse:response];
        
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] LEAVE REQUEST RESULT: %@ (STATE: %d)",
              self, parser, self.messagingState);
        
        PNOperationResultEvent result = PNOperationResultLeave;
        shouldRemoveChannels = YES;
        
        // Ensure that parsed data has numeric data, which will mean that this is status code or event enum value
        if ([[parser parsedData] isKindOfClass:[NSNumber class]]) {
            
            result = (PNOperationResultEvent)[[parser parsedData] intValue];
            shouldRemoveChannels = result == PNOperationResultLeave;
        }
    }
    
    if (shouldRemoveChannels) {
        
        [self.oldSubscribedChannelsSet setSet:self.subscribedChannelsSet];
        [self.subscribedChannelsSet minusSet:[self channelsWithPresenceFromList:channels forSubscribe:NO]];
    }
    
    
    if (isLeavingByUserRequest && ![self hasRequestsWithClass:[PNSubscribeRequest class]]) {
        
        [self.messagingDelegate messagingChannel:self
                      didUnsubscribeFromChannels:[self channelsWithOutPresenceFromList:channels]
                                       sequenced:NO ];
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
        NSMutableSet *channelsForTokenUpdate = [self.subscribedChannelsSet mutableCopy];
        [channelsForTokenUpdate addObjectsFromArray:request.channels];
        
        NSString *largestTimeToken = [PNChannel largestTimetokenFromChannels:[channelsForTokenUpdate allObjects]];
        if (PNBitIsOn(self.messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve) &&
            ![largestTimeToken isEqualToString:@"0"]) {
            
            timeToken = largestTimeToken;
        }
        [channelsForTokenUpdate makeObjectsPerformSelector:@selector(setUpdateTimeToken:) withObject:timeToken];
        
        NSUInteger presenceModificationType = 0;
        if ([request.channelsForPresenceEnabling count] || [request.channelsForPresenceDisabling count]) {
            
            unsigned long modificationType = 0;
            if ([request.channelsForPresenceEnabling count]) {
                
                PNBitOn(&modificationType, PNMessagingChannelEnablingPresence);
            }
            if ([request.channelsForPresenceDisabling count]) {
                
                PNBitOn(&modificationType, PNMessagingChannelDisablingPresence);
            }
            presenceModificationType = modificationType;
        }
        
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
        targetChannels = targetChannels ? targetChannels : (request != nil ? request.channelsForSubscription : nil);
        if ([targetChannels count] || request) {
            
            [self updateSubscriptionForChannels:targetChannels withPresence:presenceModificationType forRequest:request
                                       forcibly:NO];
        }
    }
}

- (void)handleSubscribeDidFail:(PNBaseRequest *)request withError:(PNError *)error {
    
    BOOL shouldRestoreSubscriptionOnPreviousChannels = error.code != kPNAPIAccessForbiddenError;
    PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
              PNMessagingChannelSubscriptionTimeTokenRetrieve, PNMessagingChannelResubscribeOnTimeOut,
              BITS_LIST_TERMINATOR);
    
    PNSubscribeRequest *subscriptionRequest = (PNSubscribeRequest *)request;
    
    // Check whether failed to subscribe on set of channels or not
    NSMutableSet *channelsForSubscription = [NSMutableSet setWithArray:[self channelsWithOutPresenceFromList:subscriptionRequest.channelsForSubscription]];
    [channelsForSubscription minusSet:[NSSet setWithArray:[self channelsWithOutPresenceFromList:[self.subscribedChannelsSet allObjects]]]];
    if ([channelsForSubscription count]) {
        
        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] SUBSCRIPTION FAILED WITH ERROR: "
              "%@\nCHANNELS: %@\n(STATE: %d)",
              self, error, subscriptionRequest.channels, self.messagingState);
        
        // Checking whether user generated request or not
        if (request.isSendingByUserRequest || error.code == kPNAPIAccessForbiddenError) {
            
            if (error.code == kPNAPIAccessForbiddenError) {
                
                NSSet *channelsFromFailedRequest = [self channelsWithPresenceFromList:subscriptionRequest.channels forSubscribe:NO];
                [self.subscribedChannelsSet minusSet:channelsFromFailedRequest];
                [self.oldSubscribedChannelsSet setSet:self.subscribedChannelsSet];
            }
            
            NSArray *channels = [self channelsWithOutPresenceFromList:subscriptionRequest.channels];
            [self.messagingDelegate messagingChannel:self didFailSubscribeOnChannels:channels withError:error
                                           sequenced:([subscriptionRequest.channelsForPresenceEnabling count] ||
                                                      [subscriptionRequest.channelsForPresenceDisabling count])];
        }
    }
    
    // Check whether tried to enable presence or not
    if ([subscriptionRequest.channelsForPresenceEnabling count]) {
        
        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] PRESENCE ENABLING FAILED WITH "
              "ERROR: %@\nCHANNELS: %@\n(STATE: %d)",
              self, error, subscriptionRequest.channelsForPresenceEnabling, self.messagingState);
        
        // Checking whether user generated request or not
        if (request.isSendingByUserRequest) {
            
            NSArray *channels = [self channelsWithOutPresenceFromList:subscriptionRequest.channelsForPresenceEnabling];
            [self.messagingDelegate messagingChannel:self didFailPresenceEnablingOnChannels:channels withError:error
                                           sequenced:([subscriptionRequest.channelsForPresenceDisabling count] > 0)];
        }
    }
    
    // Check whether tried to disable presence or not
    if ([subscriptionRequest.channelsForPresenceDisabling count]) {
        
        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] PRESENCE DISABLING FAILED WITH "
              "ERROR: %@\nCHANNELS: %@\n(STATE: %d)",
              self, error, subscriptionRequest.channelsForPresenceDisabling, self.messagingState);
        
        // Checking whether user generated request or not
        if (request.isSendingByUserRequest) {
            
            NSArray *channels = [self channelsWithOutPresenceFromList:subscriptionRequest.channelsForPresenceDisabling];
            [self.messagingDelegate messagingChannel:self didFailPresenceDisablingOnChannels:channels withError:error
                                           sequenced:NO];
        }
    }
    
    if (shouldRestoreSubscriptionOnPreviousChannels) {
        
        [self restoreSubscriptionOnPreviousChannels];
    }
}

- (void)handleUnsubscribeDidFail:(PNBaseRequest *)request withError:(PNError *)error {
    
    PNBitsOff(&_messagingState, PNMessagingChannelRestoringSubscription, PNMessagingChannelUpdateSubscription,
              PNMessagingChannelResubscribeOnTimeOut, PNMessagingChannelSubscriptionTimeTokenRetrieve,
              BITS_LIST_TERMINATOR);
    
    PNLeaveRequest *leaveRequest = (PNLeaveRequest *)request;
    
    PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] UNSUBSCRIPTION FAILED WITH ERROR: %@\nCHANNELS: %@\n(STATE: %d)",
          self, error, leaveRequest.channels, self.messagingState);
    
    // Checking whether user generated request or not
    if (request.isSendingByUserRequest) {
        
        [self.messagingDelegate messagingChannel:self didFailUnsubscribeOnChannels:leaveRequest.channels withError:error
                                       sequenced:NO];
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
    
    if ([self canResubscribe]) {
        
        // Destroy all subscription/leave requests from queue and stored sources
        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self destroyByRequestClass:[PNSubscribeRequest class]];
        
        if ([self.messagingDelegate shouldMessagingChannelRestoreSubscription:self]) {
            
            PNBitOn(&_messagingState, PNMessagingChannelResubscribeOnTimeOut);
            [self restoreSubscription:[self.messagingDelegate shouldMessagingChannelRestoreWithLastTimeToken:self]];
        }
        else {
            
            [self unsubscribeFromChannelsByUserRequest:NO];
            
            // Notify delegate that messaging channel will reset and there is nothing for it to process
            [self.messagingDelegate messagingChannelDidReset:self];
        }
    }
    else {
        
        PNBitsOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve,
                  PNMessagingChannelSubscriptionWaitingForEvents, BITS_LIST_TERMINATOR);
        
        [self reconnect];
    }
}


#pragma mark - Misc methods

- (void)startChannelIdleTimer {
    
    [self stopChannelIdleTimer];
    
    self.idleTimer = [NSTimer timerWithTimeInterval:kPNConnectionIdleTimeout target:self
                                           selector:@selector(handleIdleTimer:) userInfo:nil repeats:NO];
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
        
        self.idleTimer = [NSTimer timerWithTimeInterval:timeLeftBeforeSuspension target:self
                                               selector:@selector(handleIdleTimer:) userInfo:nil repeats:NO];
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
    [channelsList enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx, BOOL *channelEnumeratorStop) {
        
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

- (NSDictionary *)stateFromClientState:(NSDictionary *)state forChannels:(NSArray *)channels {
    
    // Fetch list of names against which client should filter provided state.
    NSSet *channelNames = [NSSet setWithArray:[channels valueForKey:@"name"]];
    
    // Fetch list of names for which state has been provided.
    NSMutableSet *stateKeys = [NSMutableSet setWithArray:[state allKeys]];
    
    // Extract channels on which client wouldn't subscribed and they should be removed from provided state.
    [stateKeys intersectSet:channelNames];
    if ([stateKeys count]) {
        
        state = [state dictionaryWithValuesForKeys:[stateKeys allObjects]];
    }
    // Looks like provided state doesn't applicable to any channels on which client subscribed or will subscribe.
    else {
        
        state = nil;
    }
    
    return state;
}

- (NSDictionary *)mergedClientStateWithState:(NSDictionary *)state {
    
    return [[PubNub sharedInstance].cache stateMergedWithState:state];
}

- (NSString *)stateDescription {
    
    NSMutableString *connectionState = [NSMutableString stringWithFormat:@"\n[CHANNEL::%@ STATE DESCRIPTION", self];
    if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringSubscription)) {
        
        [connectionState appendFormat:@"\n- RESTORING SUBSCRIPTION..."];
    }
    if (PNBitIsOn(self.messagingState, PNMessagingChannelResubscribeOnTimeOut)) {
        
        [connectionState appendFormat:@"\n- RE-SUBSCRIBE ON CHANNEL CONNECTION IDLE EVENT..."];
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
                
                [self updateSubscriptionForChannels:[self.subscribedChannelsSet allObjects] withPresence:0
                                         forRequest:nil forcibly:NO];
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
                    
                    [self unsubscribeFromChannelsByUserRequest:NO ];
                    
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
            
            PNBitOff(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
            PNBitOn(&_messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
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
              PNMessagingChannelResubscribeOnTimeOut, BITS_LIST_TERMINATOR);
    
    // Check whether client updated subscription or not
    if (PNBitIsOn(self.messagingState, PNMessagingChannelUpdateSubscription)) {
        
        [self destroyByRequestClass:[PNLeaveRequest class]];
        [self destroyByRequestClass:[PNSubscribeRequest class]];
        
        PNBitOff(&_messagingState, PNMessagingChannelUpdateSubscription);
        
        [self updateSubscriptionForChannels:[self.subscribedChannelsSet allObjects] withPresence:0 forRequest:nil
                                   forcibly:NO];
    }
    // Check whether reconnection was because of 'unsubscribe' request or not
    else if ([self hasRequestsWithClass:[PNLeaveRequest class]]) {
        
        PNBitOff(&_messagingState, PNMessagingChannelSubscriptionWaitingForEvents);
        PNBitOn(&_messagingState, PNMessagingChannelSubscriptionTimeTokenRetrieve);
    }
    // Check whether subscription request already scheduled or not
    else if (![self hasRequestsWithClass:[PNSubscribeRequest class]] && [self canResubscribe]) {
        
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
              PNMessagingChannelResubscribeOnTimeOut, BITS_LIST_TERMINATOR);
    
    // Check whether connection tried to update subscription before it was interrupted and reconnected back
    if (PNBitIsOn(self.messagingState, PNMessagingChannelUpdateSubscription)) {
        
        PNBitClear(&_messagingState);
        
        // Check whether there is some channels which can be used to perform subscription update or not
        if ([self.subscribedChannelsSet count]) {
            
            [self destroyByRequestClass:[PNLeaveRequest class]];
            [self destroyByRequestClass:[PNSubscribeRequest class]];
            
            [self updateSubscriptionForChannels:[self.subscribedChannelsSet allObjects] withPresence:0 forRequest:nil
                                       forcibly:NO];
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
              PNMessagingChannelResubscribeOnTimeOut, BITS_LIST_TERMINATOR);
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
          self, request, request.debugResourcePath, self.messagingState);
    
    
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
          self, request, request.debugResourcePath, [self isWaitingRequestCompletion:request.shortIdentifier] ? @"YES" : @"NO", self.messagingState);
    
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
                
                NSMutableSet *channelsForSubscription = [NSMutableSet setWithArray:[self channelsWithOutPresenceFromList:subscribeRequest.channelsForSubscription]];
                [channelsForSubscription minusSet:[NSSet setWithArray:[self channelsWithOutPresenceFromList:[self.oldSubscribedChannelsSet allObjects]]]];
                NSMutableSet *existingChannelsSet = [NSMutableSet setWithArray:[self channelsWithOutPresenceFromList:[self.oldSubscribedChannelsSet allObjects]]];
                [existingChannelsSet minusSet:[NSSet setWithArray:[self channelsWithOutPresenceFromList:subscribeRequest.channelsForSubscription]]];
                [self.subscribedChannelsSet unionSet:[NSSet setWithArray:subscribeRequest.channels]];
                [self.subscribedChannelsSet minusSet:[NSSet setWithArray:subscribeRequest.channelsForPresenceDisabling]];
                if ([existingChannelsSet count]) {
                    
                    [self.subscribedChannelsSet minusSet:existingChannelsSet];
                }
                [self.oldSubscribedChannelsSet setSet:self.subscribedChannelsSet];
                
                // Check whether failed to subscribe on set of channels or not
                if ([channelsForSubscription count] || PNBitIsOn(self.messagingState, PNMessagingChannelRestoringSubscription)) {
                    
                    BOOL isInSequence = ([existingChannelsSet count] || [subscribeRequest.channelsForPresenceEnabling count] ||
                                         [subscribeRequest.channelsForPresenceDisabling count]);
                    
                    if (PNBitIsOn(self.messagingState, PNMessagingChannelRestoringSubscription)) {
                        
                        if (![channelsForSubscription count]) {
                            
                            channelsForSubscription = [NSMutableSet setWithArray:[self channelsWithOutPresenceFromList:[self.oldSubscribedChannelsSet allObjects]]];
                        }
                        
                        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RESTORED SUBSCRIPTION ON CHANNELS: %@\n(STATE: %d)",
                              self, channelsForSubscription, self.messagingState);
                        
                        PNBitOff(&_messagingState, PNMessagingChannelRestoringSubscription);
                        
                        [self.messagingDelegate messagingChannel:self didRestoreSubscriptionOnChannels:[channelsForSubscription allObjects]
                                                       sequenced:isInSequence];
                    }
                    else {
                        
                        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUBSCRIBED ON CHANNELS: %@\n(STATE: %d)",
                              self, channelsForSubscription, self.messagingState);
                        
                        [self.messagingDelegate messagingChannel:self
                                          didSubscribeOnChannels:[channelsForSubscription allObjects]
                                                       sequenced:isInSequence
                                                 withClientState:((PNSubscribeRequest *)request).state];
                    }
                }
                
                // Check whether request doesn't include one of the channels at which client has been subscribed before (it mean that request
                // unsubscribed from some channels).
                if ([existingChannelsSet count]) {
                    
                    [self.subscribedChannelsSet minusSet:existingChannelsSet];
                    [self.oldSubscribedChannelsSet setSet:self.subscribedChannelsSet];
                    
                    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] UNSUBSCRIBED FROM CHANNELS: %@\n(STATE: %d)",
                          self, existingChannelsSet, self.messagingState);
                    
                    [self.messagingDelegate messagingChannel:self
                                  didUnsubscribeFromChannels:[existingChannelsSet allObjects]
                                                   sequenced:([subscribeRequest.channelsForPresenceEnabling count] ||
                                                              [subscribeRequest.channelsForPresenceDisabling count])];
                }
                
                // Check whether request enabled presence on some channels or not
                if ([subscribeRequest.channelsForPresenceEnabling count]) {
                    
                    NSArray *presenceEnabledChannels = [subscribeRequest.channelsForPresenceEnabling valueForKey:@"observedChannel"];
                    subscribeRequest.channelsForPresenceEnabling = nil;
                    
                    
                    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] PRESENCE ENABLED ON CHANNELS: %@\n(STATE: %d)",
                          self, presenceEnabledChannels, self.messagingState);
                    
                    [self.messagingDelegate messagingChannel:self didEnablePresenceObservationOnChannels:presenceEnabledChannels
                                                   sequenced:([subscribeRequest.channelsForPresenceDisabling count] > 0)];
                }
                
                // Check whether request disabled presence on some channels or not
                if ([subscribeRequest.channelsForPresenceDisabling count]) {
                    
                    NSArray *presenceDisabledChannels = [subscribeRequest.channelsForPresenceDisabling valueForKey:@"observedChannel"];
                    subscribeRequest.channelsForPresenceDisabling = nil;
                    
                    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] PRESENCE DISABLED ON CHANNELS: %@\n(STATE: %d)",
                          self, presenceDisabledChannels, self.messagingState);
                    
                    // Remove 'presence enabled' state from list of specified channels
                    [self disablePresenceObservationForChannels:presenceDisabledChannels sendRequest:NO];
                    
                    [self.messagingDelegate messagingChannel:self didDisablePresenceObservationOnChannels:presenceDisabledChannels
                                                   sequenced:NO];
                }
            }
            else {
                
                PNLeaveRequest *leaveRequest = (PNLeaveRequest *)request;
                NSArray *channels = [self channelsWithOutPresenceFromList:leaveRequest.channels];
                
                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] LEAVED ON CHANNELS: %@\n(STATE: %d)",
                      self, channels, self.messagingState);
                
                NSSet *leavedChannels = [self channelsWithPresenceFromList:channels forSubscribe:NO];
                [self.subscribedChannelsSet minusSet:leavedChannels];
                [self.oldSubscribedChannelsSet setSet:self.subscribedChannelsSet];
                
                if ([leaveRequest isSendingByUserRequest]) {
                    
                    [self.messagingDelegate messagingChannel:self didUnsubscribeFromChannels:channels sequenced:NO];
                }
            }
        }
        // In case if this is any other request for whichwe don't expect completion, we should clean it up from stored
        // requests list.
        else {
            
            [self removeStoredRequest:request];
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
              self, request, request.debugResourcePath, self.messagingState);
        
        // Removing failed request from queue
        [self destroyRequest:request];
        
        [self handleRequestProcessingDidFail:request withError:error];
    }
    
    
    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {
        
        [self scheduleNextRequest];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request {
    
    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] DID CANCEL REQUEST: %@ [BODY: %@](STATE: %d)",
          self, request, request.debugResourcePath, self.messagingState);
    
    
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
