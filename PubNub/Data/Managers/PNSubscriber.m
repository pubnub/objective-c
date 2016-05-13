/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNSubscriber.h"
#import "PNSubscribeStatus+Private.h"
#import "PNEnvelopeInformation.h"
#import "PNServiceData+Private.h"
#import "PNErrorStatus+Private.h"
#import "PNSubscriberResults.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNResult+Private.h"
#import "PNConfiguration.h"
#import <objc/runtime.h>
#import "PNLogMacro.h"
#import "PNHelpers.h"


#pragma mark Static

/**
 @brief  Cocoa Lumberjack logging level configuration for subscriber.
 
 @since 4.0
 */
static DDLogLevel ddLogLevel = (DDLogLevel)PNAPICallLogLevel;

/**
 @brief  Reference on time which should be used by retry timer as interval between subscription
 retry attempts.
 
 @since 4.0
 */
static NSTimeInterval const kPubNubSubscriptionRetryInterval = 1.0f;


#pragma mark - Structures

typedef NS_OPTIONS(NSUInteger, PNSubscriberState) {
    
    /**
     @brief  State set when subscriber has been just initialized.
     
     @since 4.0
     */
    PNInitializedSubscriberState,
    
    /**
     @brief  State set at the moment when client received response on 'leave' request and not subscribed to 
             any remote data objects live feed.
     
     @since 4.0
     */
    PNDisconnectedSubscriberState,
    
    /**
     @brief  State set at the moment when client lost connection or experienced other issues with
             communication established with \b PubNub service.
     
     @since 4.0
     */
    PNDisconnectedUnexpectedlySubscriberState,
    
    /**
     @brief  State set at the moment when client received response with 200 status code for subscribe request
             with TT 0.
     
     @since 4.0
     */
    PNConnectedSubscriberState,
    
    /**
     @brief  State set at the moment when client received response with 403 status code for subscribe request.
     
     @since 4.0
     */
    PNAccessRightsErrorSubscriberState,
    
    /**
     @brief  State set at the moment when client received response with 481 status code for subscribe request.
     
     @since 4.0
     */
    PNMalformedFilterExpressionErrorSubscriberState
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNSubscriber ()


#pragma mark - Information

/**
 @brief  Weak reference on client for which subscribe manager manage subscribe loop.
 
 @since 4.0
 */
@property (nonatomic, weak) PubNub *client; 

/**
 @brief  Stores reference on current subscriber state.
 
 @since 4.0
 */
@property (nonatomic, assign) PNSubscriberState currentState;

/**
 @brief  Stores whether subscriber potentially should expect for subscription restore call or not.
 @discussion In case if client tried to connect and failed or disconnected because of network issues
             this flag should be set to \c YES
 
 @since 4.0
 */
@property (nonatomic, assign) BOOL mayRequireSubscriptionRestore;

/**
 @brief  Actual storage for list of channels on which client subscribed at this moment and listen 
         for updates from live feeds.
 
 @since 4.0
 */
@property (nonatomic, strong) NSMutableSet<NSString *> *channelsSet;

/**
 @brief  Actual storage for list of channel groups on which client subscribed at this moment and 
         listen for updates from live feeds.
 
 @since 4.0
 */
@property (nonatomic, strong) NSMutableSet<NSString *> *channelGroupsSet;

/**
 @brief  Actual storage for list of presence channels on which client subscribed at this moment and
         listen for presence updates.
 
 @since 4.0
 */
@property (nonatomic, strong) NSMutableSet<NSString *> *presenceChannelsSet;

/**
 @brief  Stores reference on percent-escaped message filtering expression.
 
 @since 4.3.0
 */
@property (nonatomic, nullable, copy) NSString *escapedFilterExpression;

/**
 @brief      Reference on time token which is used for current subscribe loop iteration.
 @discussion \b 0 for initial subscription loop and non-zero for long-poll requests.
 
 @since 4.0
 */
@property (nonatomic, strong) NSNumber *currentTimeToken;

/**
 @brief      Reference on time token which should be used after initial subscription with \b 0
             timetoken.
 @discussion Override token used by subscribe API which allow to subscribe on arbitrarily time token
             and will be used in logic which decide which time token should be used for next 
             subscription cycle.
 
 @since 4.2.0
 */
@property (nonatomic, nullable, strong) NSNumber *overrideTimeToken;

/**
 @brief      Reference on time token which has been used for previous subscribe loop iteration.
 @discussion \b 0 for initial subscription loop and non-zero for long-poll requests.
 
 @since 4.0
 */
@property (nonatomic, strong) NSNumber *lastTimeToken;

/**
 @brief      Stores reference on \b PubNub server region identifier (which generated \c currentTimeToken value).
 @discussion \b 0 for initial subscription loop and non-zero for long-poll requests.
 
 @since 4.3.0
 */
@property (nonatomic, readonly, copy) NSNumber *currentTimeTokenRegion;

/**
 @brief      Reference on time token region which has been used for previous subscribe loop iteration.
 @discussion \b 0 for initial subscription loop and non-zero for long-poll requests.
 
 @since 4.3.0
 */
@property (nonatomic, readonly, copy) NSNumber *lastTimeTokenRegion;

/**
 @brief  Stores reference on queue which is used to serialize access to shared subscriber 
         information.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 @brief      Stores reference on GCD timer used to re-issue subscribe request.
 @discussion Timer activated in cases if previous subscribe loop failed with category type which
             can be temporary.
 
 @since 4.0
 */
@property (nonatomic, nullable, strong) dispatch_source_t retryTimer;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize subscribe loop manager for concrete \b PubNub client.
 
 @param client Reference on client which will be weakly stored in subscriber.
 
 @return Initialized and ready to use subscribe manager instance.
 
 @since 4.0
 */
- (instancetype)initForClient:(PubNub *)client;


#pragma mark - Subscription information modification

/**
 @brief      Update current subscriber state.
 @discussion If possible, state transition will be reported to the listeners.
 
 @param state  New state from \b PNSubscriberState enum fields.
 @param status Reference on status object which should be passed along to listeners.
 
 @since 4.0
 */
- (void)updateStateTo:(PNSubscriberState)state withStatus:(PNSubscribeStatus *)status;


#pragma mark - Subscription

/**
 @brief      Perform initial subscription with \b 0 timetoken.
 @discussion Subscription with \b 0 timetoken "register" client in \b PubNub network and allow to receive live
             updates from remote data objects live feed.
 
 @param initialSubscribe Stores whether client trying to subscriber using \b 0 time token and trigger all
                         required presence notifications or not.
 @param timeToken        Time from which client should try to catch up on messages.
 @param state            Reference on client state which should be bound to channels on which client has been
                         subscribed or will subscribe now.
 @param block            Reference on subscription completion block which is used to notify code.
 
 @since 4.3.0
 */
- (void)subscribe:(BOOL)initialSubscribe usingTimeToken:(nullable NSNumber *)timeToken 
        withState:(nullable NSDictionary<NSString *, id> *)state 
       completion:(nullable PNSubscriberCompletionBlock)block;

/**
 @brief      Launch subscription retry timer.
 @discussion Launch timer with default 1 second interval after each subscribe attempt. In most of cases timer
             used to retry subscription after PubNub Access Manager denial because of client doesn't has 
             enough rights.

 @since 4.0
 */
- (void)startRetryTimer;

/**
 @brief      Terminate previously launched subscription retry counter.
 @discussion In case if another subscribe request from user client better to stop retry timer to eliminate 
             race of conditions.

 @since 4.0
 */
- (void)stopRetryTimer;


#pragma mark - Unsubscription

/**
 @brief      Perform unsubscription operation.
 @discussion If suitable objects has been passed, then client will ask \b PubNub presence service to trigger 
             \c 'leave' presence events on passed objects.
 
 @param channels                Whether unsubscribing from list of channels or channel groups.
 @param objects                 List of objects from which client should unsubscribe.
 @param shouldInformListener    Whether listener should be informed at the end of operation or not.
 @param subscribeOnRestChannels Whether client should try to subscribe on channels which may be left after 
                                unsubscription.
 @param block                   Reference on unsubscription completion block which is used to notify code.
 
 @since 4.2.0
 */
- (void)unsubscribeFrom:(BOOL)channels objects:(NSArray<NSString *> *)objects
      informingListener:(BOOL)shouldInformListener subscribeOnRest:(BOOL)subscribeOnRestChannels
             completion:(nullable PNSubscriberCompletionBlock)block;


#pragma mark - Handlers

/**
 @brief      Handle subscription status update.
 @discussion Depending on passed status category and whether it is error it will be sent for processing to
             corresponding methods.
 
 @param status Reference on status object which has been received from \b PubNub network.
 
 @since 4.0
 */
- (void)handleSubscriptionStatus:(PNSubscribeStatus *)status;

/**
 @brief      Process successful subscription status.
 @discussion Success can be called as result of initial subscription successful ACK response as well as 
             long-poll response with events from remote data objects live feed.
 
 @param status Reference on status object which has been received from \b PubNub network.
 
 @since 4.0
 */
- (void)handleSuccessSubscriptionStatus:(PNSubscribeStatus *)status;

/**
 @brief      Process failed subscription status.
 @discussion Failure can be cause by Access Denied error, network issues or called when last subscribe request
             has been canceled (to execute new subscription for example).
 
 @param status Reference on status object which has been received from \b PubNub network.
 
 @since 4.0
 */
- (void)handleFailedSubscriptionStatus:(PNSubscribeStatus *)status;

/**
 @brief  Handle subscription time token received from \b PubNub network.
 
 @param initialSubscription Whether subscription is initial or received time token on long-poll request.
 @param timeToken           Reference on time token which has been received from \b PubNub network.
 @param region              Reference on \b PubNub server region identifier (which generated \c timeToken 
                            value).
 
 @since 4.0
 */
- (void)handleSubscription:(BOOL)initialSubscription timeToken:(nullable NSNumber *)timeToken 
                    region:(nullable NSNumber *)region;

/**
 @brief  Handle long-poll service response and deliver events to listeners if required.
 
 @param status Reference on status object which has been received from \b PubNub network.
 
 @since 4.0
 */
- (void)handleLiveFeedEvents:(PNSubscribeStatus *)status;

/**
 @brief  Process message which just has been received from \b PubNub service through live feed on which client
         subscribed at this moment.
 
 @param data Reference on result data which hold information about request on which this response has been 
             received and message itself.
 
 @since 4.0
 */
- (void)handleNewMessage:(PNMessageResult *)data;

/**
 @brief  Process presence event which just has been received from \b PubNub service through presence live
         feeds on which client subscribed at this moment.
 
 @param data Reference on result data which hold information about request on which this response has been 
             received and presence event itself.
 
 @since 4.0
 */
- (void)handleNewPresenceEvent:(PNPresenceEventResult *)data;


#pragma mark - Misc

/**
 @brief  Compose request parameters instance basing on current subscriber state.
 
 @param state Reference on merged client state which should be used in request.
 
 @return Configured and ready to use parameters instance.
 
 @since 4.0
 */
- (PNRequestParameters *)subscribeRequestParametersWithState:(nullable NSDictionary<NSString *, id> *)state;

/**
 @brief  Append subscriber information to status object.
 
 @param status Reference on status object which should be updated with subscriber information.
 
 @since 4.0
 */
- (void)appendSubscriberInformation:(PNStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscriber

@synthesize retryTimer = _retryTimer;
@synthesize overrideTimeToken = _overrideTimeToken;
@synthesize currentTimeToken = _currentTimeToken;
@synthesize lastTimeToken = _lastTimeToken;
@synthesize currentTimeTokenRegion = _currentTimeTokenRegion;
@synthesize lastTimeTokenRegion = _lastTimeTokenRegion;
@synthesize filterExpression = _filterExpression;


#pragma mark - Logger

+ (DDLogLevel)ddLogLevel {
    
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(DDLogLevel)logLevel {
    
    ddLogLevel = logLevel;
}


#pragma mark - Information

- (dispatch_source_t)retryTimer {
    
    __block dispatch_source_t retryTimer = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ retryTimer = self->_retryTimer; });
    
    return retryTimer;
}

- (void)setRetryTimer:(dispatch_source_t)retryTimer {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{ self->_retryTimer = retryTimer; });
}


#pragma mark - State Information and Manipulation

- (NSArray<NSString *> *)allObjects {
    
    return [[[self channels] arrayByAddingObjectsFromArray:[self presenceChannels]]
            arrayByAddingObjectsFromArray:[self channelGroups]];
}

- (NSArray<NSString *> *)channels {
    
    __block NSArray *channels = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ channels = self.channelsSet.allObjects; });
    
    return channels;
}

- (void)addChannels:(NSArray<NSString *> *)channels {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{
        
        NSArray *channelsOnly = [PNChannel objectsWithOutPresenceFrom:channels];
        if ([channelsOnly count] != [channels count]) {
            
            // Add presence channels to corresponding storage.
            NSMutableSet *channelsSet = [NSMutableSet setWithArray:channels];
            [channelsSet minusSet:[NSSet setWithArray:channelsOnly]];
            [self.presenceChannelsSet unionSet:channelsSet];
        }
        [self.channelsSet addObjectsFromArray:channelsOnly];
    });
}

- (void)removeChannels:(NSArray<NSString *> *)channels {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{
        
        NSSet *channelsSet = [NSSet setWithArray:channels];
        [self.presenceChannelsSet minusSet:channelsSet];
        [self.channelsSet minusSet:channelsSet];
    });
}

- (NSArray<NSString *> *)channelGroups {
    
    __block NSArray *channelGroups = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ channelGroups = self.channelGroupsSet.allObjects; });
    
    return channelGroups;
}

- (void)addChannelGroups:(NSArray<NSString *> *)groups {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{ 
        
        [self.channelGroupsSet addObjectsFromArray:groups];
    });
}

- (void)removeChannelGroups:(NSArray<NSString *> *)groups {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{
        
        [self.channelGroupsSet minusSet:[NSSet setWithArray:groups]];
    });
}

- (NSArray<NSString *> *)presenceChannels {
    
    __block NSArray *presenceChannels = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{
        
        presenceChannels = self.presenceChannelsSet.allObjects;
    });
    
    return presenceChannels;
}

- (void)addPresenceChannels:(NSArray<NSString *> *)presenceChannels {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{
        
        [self.presenceChannelsSet addObjectsFromArray:presenceChannels];
    });
}

- (void)removePresenceChannels:(NSArray<NSString *> *)presenceChannels {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{
        
        [self.presenceChannelsSet minusSet:[NSSet setWithArray:presenceChannels]];
    });
}

- (NSNumber *)currentTimeToken {
    
    __block NSNumber *currentTimeToken = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ currentTimeToken = self->_currentTimeToken; });
    
    return currentTimeToken;
}

- (void)setCurrentTimeToken:(NSNumber *)currentTimeToken {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{ self->_currentTimeToken = currentTimeToken; });
}

- (NSNumber *)lastTimeToken {
    
    __block NSNumber *lastTimeToken = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ lastTimeToken = self->_lastTimeToken; });
    
    return lastTimeToken;
}

- (void)setLastTimeToken:(NSNumber *)lastTimeToken {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{ self->_lastTimeToken = lastTimeToken; });
}

- (nullable NSNumber *)overrideTimeToken {
    
    __block NSNumber *overrideTimeToken = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ overrideTimeToken = self->_overrideTimeToken; });
    
    return overrideTimeToken;
}

- (void)setOverrideTimeToken:(nullable NSNumber *)overrideTimeToken {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{
        
        self->_overrideTimeToken = [PNNumber timeTokenFromNumber:overrideTimeToken];
    });
}

- (NSNumber *)currentTimeTokenRegion {
    
    __block NSNumber *currentTimeTokenRegion = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ currentTimeTokenRegion = self->_currentTimeTokenRegion; });
    
    return currentTimeTokenRegion;
}

- (void)setCurrentTimeTokenRegion:(NSNumber *)currentTimeTokenRegion {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{ self->_currentTimeTokenRegion = currentTimeTokenRegion; });
}

- (NSNumber *)lastTimeTokenRegion {
    
    __block NSNumber *lastTimeTokenRegion = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ lastTimeTokenRegion = self->_lastTimeTokenRegion; });
    
    return lastTimeTokenRegion;
}

- (void)setLastTimeTokenRegion:(NSNumber *)lastTimeTokenRegion {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{ self->_lastTimeTokenRegion = lastTimeTokenRegion; });
}

- (void)updateStateTo:(PNSubscriberState)state withStatus:(PNSubscribeStatus *)status {

    pn_safe_property_write(self.resourceAccessQueue, ^{
        
        // Compose status object to report state change to listeners.
        PNStatusCategory category = PNUnknownCategory;
        PNSubscriberState targetState = state;
        PNSubscriberState currentState = self->_currentState;
        BOOL shouldHandleTransition = NO;
        
        // Check whether transit to 'connected' state.
        if (targetState == PNConnectedSubscriberState) {
            
            self.mayRequireSubscriptionRestore = YES;
            
            // Check whether client transit from 'disconnected' -> 'connected' state.
            shouldHandleTransition = (currentState == PNInitializedSubscriberState ||
                                      currentState == PNDisconnectedSubscriberState ||
                                      currentState == PNConnectedSubscriberState);
            
            // Check whether client transit from 'access denied' -> 'connected' state.
            if (!shouldHandleTransition) {
                
                shouldHandleTransition = (currentState == PNAccessRightsErrorSubscriberState);
            }
            category = PNConnectedCategory;
            
            // Check whether client transit from 'unexpected disconnect' -> 'connected' state
            if (!shouldHandleTransition && currentState == PNDisconnectedUnexpectedlySubscriberState) {
                
                // Change state to 'reconnected'
                targetState = PNConnectedSubscriberState;
                category = PNReconnectedCategory;
                shouldHandleTransition = YES;
            }
        }
        // Check whether transit to 'disconnected' or 'unexpected disconnect' state.
        else if (targetState == PNDisconnectedSubscriberState ||
                 targetState == PNDisconnectedUnexpectedlySubscriberState) {
            
            // Check whether client transit from 'connected' -> 'disconnected'/'unexpected disconnect'
            // state.
            // Also 'unexpected disconnect' -> 'disconnected' transition should be allowed for cases
            // when used want to unsubscribe from channel(s) after network went down.
            shouldHandleTransition = (currentState == PNInitializedSubscriberState ||
                                      currentState == PNConnectedSubscriberState ||
                                      currentState == PNDisconnectedUnexpectedlySubscriberState);
            
            // In case if subscription restore failed after precious unexpected disconnect we should
            // handle it.
            shouldHandleTransition = (shouldHandleTransition ||
                                      (targetState == PNDisconnectedUnexpectedlySubscriberState &&
                                       targetState == currentState));
            category = ((targetState == PNDisconnectedSubscriberState) ? PNDisconnectedCategory :
                        PNUnexpectedDisconnectCategory);
            self.mayRequireSubscriptionRestore = shouldHandleTransition;
        }
        // Check whether transit to 'access denied' state.
        else if (targetState == PNAccessRightsErrorSubscriberState) {
            
            self.mayRequireSubscriptionRestore = NO;
            shouldHandleTransition = YES;
            category = PNAccessDeniedCategory;
        }
        // Check whether transit to 'malformed filter expression' state.
        else if (targetState == PNMalformedFilterExpressionErrorSubscriberState) {
            
            // Change state to 'Unexpected disconnect'
            targetState = PNDisconnectedUnexpectedlySubscriberState;
            
            self.mayRequireSubscriptionRestore = NO;
            shouldHandleTransition = YES;
            category = PNMalformedFilterExpressionCategory;
        }
        
        // Check whether allowed state transition has been issued or not.
        if (shouldHandleTransition) {

            self->_currentState = targetState;
            
            // Build status object in case if update has been called as transition between two
            // different states.
            PNStatus *targetStatus = (PNStatus *)status;
            if (!targetStatus) {
                
                targetStatus = [PNStatus statusForOperation:PNSubscribeOperation
                                                   category:category withProcessingError:nil];
            }
            [targetStatus updateCategory:category];
            [self appendSubscriberInformation:targetStatus];
            // Silence static analyzer warnings.
            // Code is aware about this case and at the end will simply call on 'nil' object
            // method. In most cases if referenced object become 'nil' it mean what there is no
            // more need in it and probably whole client instance has been deallocated.
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wreceiver-is-weak"
            #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
            [self.client.listenersManager notifyWithBlock:^{
                
                [self.client.listenersManager notifyStatusChange:(PNSubscribeStatus *)targetStatus];
            }];
            #pragma clang diagnostic pop
        }
    });
}


#pragma mark - Initialization and Configuration

+ (instancetype)subscriberForClient:(PubNub *)client {
    
    return [[self alloc] initForClient:client];
}

- (instancetype)initForClient:(PubNub *)client {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _client = client;
        _channelsSet = [NSMutableSet new];
        _channelGroupsSet = [NSMutableSet new];
        _presenceChannelsSet = [NSMutableSet new];
        _currentTimeToken = @0;
        _lastTimeToken = @0;
        _resourceAccessQueue = dispatch_queue_create("com.pubnub.subscriber",
                                                     DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void)inheritStateFromSubscriber:(PNSubscriber *)subscriber {
    
    _channelsSet = [subscriber.channelsSet mutableCopy];
    _channelGroupsSet = [subscriber.channelGroupsSet mutableCopy];
    _presenceChannelsSet = [subscriber.presenceChannelsSet mutableCopy];
    if (_channelsSet.count || _channelGroupsSet.count || _presenceChannelsSet.count) {
        
        _currentState = PNDisconnectedSubscriberState;
    }
    _currentTimeToken = subscriber.currentTimeToken;
    _lastTimeToken = subscriber.lastTimeToken;
    _currentTimeTokenRegion = subscriber.currentTimeTokenRegion;
    _lastTimeTokenRegion = subscriber.lastTimeTokenRegion;
    _escapedFilterExpression = subscriber.escapedFilterExpression;
}


#pragma mark - Filtering

- (NSString *)filterExpression {
    
    __block NSString *expression = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ expression = _filterExpression; });

    return expression;
}

- (void)setFilterExpression:(nullable NSString *)filterExpression {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{
        
        _filterExpression = [filterExpression copy];
        _escapedFilterExpression = (filterExpression? [PNString percentEscapedString:filterExpression] : nil);
    });
}

- (NSString *)escapedFilterExpression {
    
    __block NSString *expression = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ expression = _escapedFilterExpression; });
    
    return expression;
}


#pragma mark - Subscription

- (void)subscribeUsingTimeToken:(nullable NSNumber *)timeToken
                      withState:(nullable NSDictionary<NSString *, id> *)state 
                     completion:(nullable PNSubscriberCompletionBlock)block {
    
    [self subscribe:YES usingTimeToken:timeToken withState:state completion:block];
}

- (void)subscribe:(BOOL)initialSubscribe usingTimeToken:(nullable NSNumber *)timeToken 
        withState:(nullable NSDictionary<NSString *, id> *)state 
       completion:(nullable PNSubscriberCompletionBlock)block {
    
    [self stopRetryTimer];

    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    if ([self allObjects].count) {

        // Storing time token override
        self.overrideTimeToken = timeToken;
        
        // In case if block is passed, it mean what subscription has been requested by user or
        // internal logic (like unsubscribe and re-subscribe on the rest of the channels/groups).
        if (initialSubscribe) {
            
            self.mayRequireSubscriptionRestore = NO;
            pn_safe_property_write(self.resourceAccessQueue, ^{
                
                if (self->_currentTimeToken && [self->_currentTimeToken compare:@0] != NSOrderedSame) {
                    
                    self->_lastTimeToken = self->_currentTimeToken;
                }
                if (self->_currentTimeTokenRegion && [self->_currentTimeTokenRegion compare:@0] != NSOrderedSame &&
                    [self->_currentTimeTokenRegion compare:@(-1)] == NSOrderedDescending) {
                    
                    self->_lastTimeTokenRegion = self->_currentTimeTokenRegion;
                }
                self->_currentTimeToken = @0;
                self->_currentTimeTokenRegion = @(-1);
            });
        }
        
        PNRequestParameters *parameters = [self subscribeRequestParametersWithState:state];
        
        if (initialSubscribe) {
            
            DDLogAPICall([[self class] ddLogLevel], @"<PubNub::API> Subscribe (channels: %@; groups: %@)%@",
                         parameters.pathComponents[@"{channels}"], parameters.query[@"channel-group"],
                         (timeToken ? [NSString stringWithFormat:@" with catch up from %@.", timeToken] : @"."));
        }
        
        __weak __typeof(self) weakSelf = self;
        [self.client processOperation:PNSubscribeOperation withParameters:parameters
                      completionBlock:^(PNStatus *status){
                          
              __strong __typeof(self) strongSelf = weakSelf;
              [strongSelf handleSubscriptionStatus:(PNSubscribeStatus *)status];
              if (block) {
                  
                  pn_dispatch_async(weakSelf.client.callbackQueue, ^{ block((PNSubscribeStatus *)status); });
              }
          }];
    }
    else {
        
        PNStatus *status = [PNStatus statusForOperation:PNSubscribeOperation category:PNDisconnectedCategory
                                    withProcessingError:nil];
        [self.client appendClientInformation:status];
        pn_safe_property_write(self.resourceAccessQueue, ^{
            
            self->_lastTimeToken = @0;
            self->_currentTimeToken = @0;
            self->_lastTimeTokenRegion = @(-1);
            self->_currentTimeTokenRegion = @(-1);
        });
        if (block) {
            
            pn_dispatch_async(self.client.callbackQueue, ^{ block((PNSubscribeStatus *)status); });
        }
        [self updateStateTo:PNDisconnectedSubscriberState withStatus:(PNSubscribeStatus *)status];
        [self.client cancelAllLongPollingOperations];
        [self.client callBlock:nil status:YES withResult:nil andStatus:status];
    }
    #pragma clang diagnostic pop
}

- (void)restoreSubscriptionCycleIfRequiredWithCompletion:(nullable PNSubscriberCompletionBlock)block {
    
    __block BOOL shouldRestore;
    __block BOOL ableToRestore;
    pn_safe_property_read(self.resourceAccessQueue, ^{
        
        shouldRestore = (self.currentState == PNDisconnectedUnexpectedlySubscriberState &&
                         self.mayRequireSubscriptionRestore);
        ableToRestore = ([self.channelsSet count] || [self.channelGroupsSet count] ||
                         [self.presenceChannelsSet count]);
    });
    if (shouldRestore && ableToRestore) {
        
        [self subscribeUsingTimeToken:nil withState:nil completion:block];
    }
    else if (block) { block(nil); }
}

- (void)continueSubscriptionCycleIfRequiredWithCompletion:(nullable PNSubscriberCompletionBlock)block {

    [self subscribe:NO usingTimeToken:nil withState:nil completion:block];
}

- (void)unsubscribeFromAll {
    
    __weak __typeof(self) weakSelf = self;
    NSArray *channelGroups = [self.channelGroups copy];
    PNSubscriberCompletionBlock channelUnsubscribeBlock = ^(__unused PNSubscribeStatus * _Nullable status) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf removeChannelGroups:channelGroups];
        [strongSelf unsubscribeFrom:NO objects:channelGroups informingListener:YES subscribeOnRest:NO 
                         completion:nil];
    };
    
    if (self.channels.count > 0) {
        
        BOOL hasChannelGroups = (channelGroups.count > 0);
        NSArray *objects = [self.channels copy];
        [self removeChannels:objects];
        [self removePresenceChannels:self.presenceChannels];
        [self unsubscribeFrom:YES objects:objects informingListener:!hasChannelGroups
              subscribeOnRest:NO completion:(hasChannelGroups ? channelUnsubscribeBlock : nil)];
    }
    else if (channelGroups.count > 0) { channelUnsubscribeBlock(nil); }
}

- (void)unsubscribeFrom:(BOOL)channels objects:(NSArray<NSString *> *)objects
             completion:(nullable PNSubscriberCompletionBlock)block {
    
    [self unsubscribeFrom:channels objects:objects informingListener:YES subscribeOnRest:YES
               completion:block];
}

- (void)unsubscribeFrom:(BOOL)channels objects:(NSArray<NSString *> *)objects
      informingListener:(BOOL)shouldInformListener subscribeOnRest:(BOOL)subscribeOnRestChannels
             completion:(nullable PNSubscriberCompletionBlock)block {
    
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    [self.client.clientStateManager removeStateForObjects:objects];
    NSArray *objectWithOutPresence = [PNChannel objectsWithOutPresenceFrom:objects];
    PNStatus *successStatus = [PNStatus statusForOperation:PNUnsubscribeOperation
                                                  category:PNAcknowledgmentCategory withProcessingError:nil];
    [self.client appendClientInformation:successStatus];
    __weak __typeof(self) weakSelf = self;
    
    DDLogAPICall([[self class] ddLogLevel], @"<PubNub::API> Unsubscribe (channels: %@; groups: %@)",
                 (channels ? objectWithOutPresence : nil), (!channels ? objectWithOutPresence : nil));
    
    NSSet *subscriptionObjects = [NSSet setWithArray:[self allObjects]];
    if (subscriptionObjects.count == 0) {
        
        pn_safe_property_write(self.resourceAccessQueue, ^{
            
            self->_lastTimeToken = @0;
            self->_currentTimeToken = @0;
            self->_lastTimeTokenRegion = @(-1);
            self->_currentTimeTokenRegion = @(-1);
        });
    }
    
    if (objectWithOutPresence.count) {
        
        NSString *objectsList = [PNChannel namesForRequest:objectWithOutPresence defaultString:@","];
        PNRequestParameters *parameters = [PNRequestParameters new];
        [parameters addPathComponent:objectsList forPlaceholder:@"{channels}"];
        if (!channels) { [parameters addQueryParameter:objectsList forFieldName:@"channel-group"]; }
        [self.client processOperation:PNUnsubscribeOperation withParameters:parameters
                      completionBlock:^(__unused PNStatus *status1){
                          
            if (shouldInformListener) {
                
                [weakSelf updateStateTo:PNDisconnectedSubscriberState
                             withStatus:(PNSubscribeStatus *)successStatus];
            }
            [weakSelf.client callBlock:nil status:YES withResult:nil andStatus:successStatus];
            BOOL listChanged = ![[NSSet setWithArray:[weakSelf allObjects]] isEqualToSet:subscriptionObjects];
            if (subscribeOnRestChannels && (subscriptionObjects.count > 0 && !listChanged)) {
                
                [weakSelf subscribe:YES usingTimeToken:nil withState:nil completion:nil];
            }
            else if (block) {
                    
                pn_dispatch_async(weakSelf.client.callbackQueue, ^{
                    
                    block((PNSubscribeStatus *)successStatus);
                });
            }
        }];
    }
    else {
        
        [self subscribe:YES usingTimeToken:nil withState:nil
             completion:^(__unused PNSubscribeStatus *status) {
            
            if (block) {
                
                pn_dispatch_async(weakSelf.client.callbackQueue, ^{
                
                    block((PNSubscribeStatus *)successStatus);
                });
            }
            if (shouldInformListener) {
                
                [weakSelf updateStateTo:PNDisconnectedSubscriberState
                             withStatus:(PNSubscribeStatus *)successStatus];
            }
            [weakSelf.client callBlock:nil status:YES withResult:nil andStatus:successStatus];
        }];
    }
    #pragma clang diagnostic pop
}

- (void)startRetryTimer {
    
    [self stopRetryTimer];
    
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t timerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
    dispatch_source_set_event_handler(timer, ^{
        
        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object method.
        // In most cases if referenced object become 'nil' it mean what there is no more need in
        // it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        [weakSelf continueSubscriptionCycleIfRequiredWithCompletion:nil];
        #pragma clang diagnostic pop
    });
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPubNubSubscriptionRetryInterval * NSEC_PER_SEC));
    dispatch_source_set_timer(timer, start, (uint64_t)(kPubNubSubscriptionRetryInterval * NSEC_PER_SEC), NSEC_PER_SEC);
    self.retryTimer = timer;
    dispatch_resume(timer);
}

- (void)stopRetryTimer {
    
    dispatch_source_t timer = [self retryTimer];
    if (timer != NULL && dispatch_source_testcancel(timer) == 0) { dispatch_source_cancel(timer); }
    self.retryTimer = nil;
}


#pragma mark - Handlers

- (void)handleSubscriptionStatus:(PNSubscribeStatus *)status {

    [self stopRetryTimer];
    if (!status.isError && status.category != PNCancelledCategory) {
        
        [self handleSuccessSubscriptionStatus:status];
    }
    else { [self handleFailedSubscriptionStatus:status]; }
}

- (void)handleSuccessSubscriptionStatus:(PNSubscribeStatus *)status {
    
    // Try fetch time token from passed result/status objects.
    BOOL isInitialSubscription = ([status.clientRequest.URL.query rangeOfString:@"tt=0"].location != NSNotFound);
    
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    if (status.data.timetoken != nil && status.clientRequest.URL != nil) {
        
        [self handleSubscription:isInitialSubscription timeToken:status.data.timetoken
                          region:status.data.region];
    }
    
    [self handleLiveFeedEvents:status];
    [self continueSubscriptionCycleIfRequiredWithCompletion:nil];
    
    // Because client received new event from service, it can restart reachability timer with
    // new interval.
    [self.client.heartbeatManager startHeartbeatIfRequired];
    
    if (status.clientRequest.URL != nil && isInitialSubscription) {
        
        [self updateStateTo:PNConnectedSubscriberState withStatus:status];
        [self.client callBlock:nil status:YES withResult:nil andStatus:(PNStatus *)status];
    }
    #pragma clang diagnostic pop
}

- (void)handleFailedSubscriptionStatus:(PNSubscribeStatus *)status {
    
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    // Looks like subscription request has been cancelled.
    // Cancelling can happen because of: user changed subscriber sensitive configuration or
    // another subscribe/unsubscribe request has been issued.
    if (status.category == PNCancelledCategory) {
        
        // Stop heartbeat for now and wait further actions.
        [self.client.heartbeatManager stopHeartbeatIfPossible];
    }
    // Looks like processing failed because of another error.
    // If there is another subscription/unsubscription operations is waiting client shouldn't
    // handle this status yet.
    else {
        
        // Check whether status category declare subscription retry or not.
        if (status.category == PNAccessDeniedCategory || status.category == PNTimeoutCategory ||
            status.category == PNMalformedFilterExpressionCategory ||
            status.category == PNMalformedResponseCategory ||
            status.category == PNTLSConnectionFailedCategory) {
            
            __weak __typeof(self) weakSelf = self;
            ((PNStatus *)status).automaticallyRetry = (status.category != PNMalformedFilterExpressionCategory);
            ((PNStatus *)status).retryCancelBlock = ^{
                
                DDLogAPICall([[weakSelf class] ddLogLevel], @"<PubNub::API> Cancel retry");
                [weakSelf stopRetryTimer];
            };
            if (((PNStatus *)status).willAutomaticallyRetry) { [self startRetryTimer]; }
            
            PNSubscriberState subscriberState = PNAccessRightsErrorSubscriberState;
            if (status.category == PNMalformedFilterExpressionCategory) {
                
                subscriberState = PNMalformedFilterExpressionErrorSubscriberState;
            }
            if (status.category != PNAccessDeniedCategory &&
                status.category != PNMalformedFilterExpressionCategory) {
                
                subscriberState = PNDisconnectedUnexpectedlySubscriberState;
                [(PNStatus *)status updateCategory:PNUnexpectedDisconnectCategory];
            }
            [self updateStateTo:subscriberState withStatus:status];
        }
        // Looks like client lost connection with internet or has any other connection
        // related issues.
        else {
            
            // Check whether subscription should be restored on network connection restore or
            // not.
            if (self.client.configuration.shouldRestoreSubscription) {
                
                ((PNStatus *)status).automaticallyRetry = YES;
                ((PNStatus *)status).retryCancelBlock = ^{
                /* Do nothing, because we can't stop auto-retry in case of network issues.
                 It handled by client configuration. */ };
                
                pn_safe_property_write(self.resourceAccessQueue, ^{
                    
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
                    }
                    else {
                        
                        self->_currentTimeToken = @0;
                        self->_lastTimeToken = @0;
                        self->_currentTimeTokenRegion = @(-1);
                        self->_lastTimeTokenRegion = @(-1);
                    }
                });
            }
            else {
                
                // Ask to clean up cache associated with objects
                [self.client.clientStateManager removeStateForObjects:self.channelsSet.allObjects];
                [self.client.clientStateManager removeStateForObjects:self.channelGroupsSet.allObjects];
                pn_safe_property_write(self.resourceAccessQueue, ^{
                    
                    self.channelsSet = [NSMutableSet new];
                    self.channelGroupsSet = [NSMutableSet new];
                    self.presenceChannelsSet = [NSMutableSet new];
                    self->_currentTimeToken = @0;
                    self->_lastTimeToken = @0;
                    self->_currentTimeTokenRegion = @(-1);
                    self->_lastTimeTokenRegion = @(-1);
                });
            }
            [(PNStatus *)status updateCategory:PNUnexpectedDisconnectCategory];
            
            [self.client.heartbeatManager stopHeartbeatIfPossible];
            [self updateStateTo:PNDisconnectedUnexpectedlySubscriberState withStatus:status];
        }
    }
    [self.client callBlock:nil status:YES withResult:nil andStatus:(PNStatus *)status];
    #pragma clang diagnostic pop
}

- (void)handleSubscription:(BOOL)initialSubscription timeToken:(nullable NSNumber *)timeToken 
                    region:(nullable NSNumber *)region {

    pn_safe_property_write(self.resourceAccessQueue, ^{
        
        // Whether new time token from response should be applied for next subscription cycle or
        // not.
        BOOL shouldAcceptNewTimeToken = YES;
        
        // Whether time token should be overridden despite subscription behaviour configuration.
        BOOL shouldOverrideTimeToken = (initialSubscription && self->_overrideTimeToken &&
                                        [self->_overrideTimeToken compare:@0] != NSOrderedSame);
        
        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object method.
        // In most cases if referenced object become 'nil' it mean what there is no more need in
        // it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
        if (initialSubscription) {
            
            // 'shouldKeepTimeTokenOnListChange' property should never allow to reset time tokens in
            // case if there is a few more subscribe requests is waiting for their turn to be sent.
            BOOL shouldUseLastTimeToken = self.client.configuration.shouldKeepTimeTokenOnListChange;
            if (!shouldUseLastTimeToken) {
                
                shouldUseLastTimeToken = (self.client.configuration.shouldRestoreSubscription &&
                                          self.client.configuration.shouldTryCatchUpOnSubscriptionRestore);
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
        if (!initialSubscription && self->_currentTimeToken &&
            [self->_currentTimeToken compare:@0] == NSOrderedSame) {
            
            shouldAcceptNewTimeToken = NO;
        }
        
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
    });
}

- (void)handleLiveFeedEvents:(PNSubscribeStatus *)status {
    
    NSArray *events = [(NSArray *)(status.serviceData)[@"events"] copy];
    if (events.count) {
        
        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object method.
        // In most cases if referenced object become 'nil' it mean what there is no more need in
        // it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        [self.client.listenersManager notifyWithBlock:^{
            
            // Iterate through array with notifications and report back using callback blocks to the
            // user.
            for (NSMutableDictionary<NSString *, id> *event in events) {
                
                // Check whether event has been triggered on presence channel or channel group.
                // In case if check will return YES this is presence event.
                BOOL isPresenceEvent = (event[@"presenceEvent"] ? YES : NO);
                if (isPresenceEvent) {
                    
                    if (event[@"subscribedChannel"]) {
                        
                        event[@"subscribedChannel"] = [PNChannel channelForPresence:event[@"subscribedChannel"]];
                    }
                    if (event[@"actualChannel"]) {
                        
                        event[@"actualChannel"] = [PNChannel channelForPresence:event[@"actualChannel"]];
                    }
                }
                
                id eventResultObject = [status copyWithMutatedData:event];
                if (isPresenceEvent) {
                    
                    object_setClass(eventResultObject, [PNPresenceEventResult class]);
                    [self handleNewPresenceEvent:((PNPresenceEventResult *)eventResultObject)];
                }
                else {
                    
                    object_setClass(eventResultObject, [PNMessageResult class]);
                    [self handleNewMessage:(PNMessageResult *)eventResultObject];
                }
            }
        }];
        #pragma clang diagnostic pop
    }
    [status updateData:[status.serviceData dictionaryWithValuesForKeys:@[@"timetoken", @"region"]]];
}

- (void)handleNewMessage:(PNMessageResult *)data {
    
    PNErrorStatus *status = nil;
    if (data) {
        
        DDLogResult([[self class] ddLogLevel], @"<PubNub> %@", [(PNResult *)data stringifiedRepresentation]);
        if ([data.serviceData[@"decryptError"] boolValue]) {
            
            status = [PNErrorStatus statusForOperation:PNSubscribeOperation category:PNDecryptionErrorCategory
                                   withProcessingError:nil];

            NSMutableDictionary *updatedData = [data.serviceData mutableCopy];
            [updatedData removeObjectsForKeys:@[@"decryptError", @"envelope"]];
            status.associatedObject = [PNMessageData dataWithServiceResponse:updatedData];
            [status updateData:updatedData];
        }
    }
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    if (status) { [self.client.listenersManager notifyStatusChange:(id)status]; }
    else if (data) { [self.client.listenersManager notifyMessage:data]; }
    #pragma clang diagnostic pop
}

- (void)handleNewPresenceEvent:(PNPresenceEventResult *)data {
    
    if (data) {
        
        DDLogResult([[self class] ddLogLevel], @"<PubNub> %@", [(PNResult *)data stringifiedRepresentation]);
    }
    
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    // Check whether state modification event arrived or not.
    // In case of state modification event for current client it should be applied on local storage.
    if ([data.data.presenceEvent isEqualToString:@"state-change"]) {
        
        // Check whether state has been changed for current client or not.
        if ([data.data.presence.uuid isEqualToString:self.client.configuration.uuid]) {
            
            NSString *object = (data.data.actualChannel?: data.data.subscribedChannel);
            [self.client.clientStateManager setState:data.data.presence.state forObject:object];
        }
    }
    [self.client.listenersManager notifyPresenceEvent:data];
    #pragma clang diagnostic pop
}


#pragma mark - Misc

- (PNRequestParameters *)subscribeRequestParametersWithState:(nullable NSDictionary<NSString *, id> *)state {
    
    // Compose full list of channels and groups stored in active subscription list.
    NSArray *channels = [[self channels] arrayByAddingObjectsFromArray:[self presenceChannels]];
    NSString *channelsList = [PNChannel namesForRequest:channels defaultString:@","];
    NSString *groupsList = [PNChannel namesForRequest:[self channelGroups]];
    NSArray *fullObjectsList = [channels arrayByAddingObjectsFromArray:[self channelGroups]];
    
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    NSDictionary *mergedState = [self.client.clientStateManager stateMergedWith:state
                                                                     forObjects:fullObjectsList];
    [self.client.clientStateManager mergeWithState:mergedState];
    
    PNRequestParameters *parameters = [PNRequestParameters new];
    [parameters addPathComponent:channelsList forPlaceholder:@"{channels}"];
    [parameters addQueryParameter:self.currentTimeToken.stringValue forFieldName:@"tt"];
    if ([self.currentTimeTokenRegion compare:@(-1)] == NSOrderedDescending) {
        
        [parameters addQueryParameter:self.currentTimeTokenRegion.stringValue forFieldName:@"tr"];
    }
    
    if (self.client.configuration.presenceHeartbeatValue > 0 ) {
        
        [parameters addQueryParameter:@(self.client.configuration.presenceHeartbeatValue).stringValue
                         forFieldName:@"heartbeat"];
    }
    if (groupsList.length) { [parameters addQueryParameter:groupsList forFieldName:@"channel-group"]; }
    if (mergedState.count) {
        
        NSString *mergedStateString = [PNJSON JSONStringFrom:mergedState withError:nil];
        if (mergedStateString.length) {
            
            [parameters addQueryParameter:[PNString percentEscapedString:mergedStateString]
                             forFieldName:@"state"];
        }
    }
    if (self.escapedFilterExpression) {
        
        [parameters addQueryParameter:self.escapedFilterExpression forFieldName:@"filter-expr"];
    }
    #pragma clang diagnostic pop
    
    return parameters;
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
