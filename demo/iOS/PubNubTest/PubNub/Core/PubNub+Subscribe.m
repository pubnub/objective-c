/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+SubscribePrivate.h"
#import "PubNub+StatePrivate.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNResult+Private.h"
#import <objc/runtime.h>
#import "PNHelpers.h"
#import "PNResult.h"
#import "PNStatus.h"
#import "PNAES.h"


#pragma mark Static

/**
 @brief  Reference on suffix which is used to mark channel as presence channel.
 
 @since 4.0
 */
static NSString * const kPubNubPresenceChannelNameSuffix = @"-pnpres";

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
 @brief  Update current subscription time token information in cache.
 
 @param timeToken Reference on current time token which should replace the one stored in cache.
 
 @since 4.0
 */
- (void)setCurrentTimeToken:(NSNumber *)timeToken;

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
- (NSInteger)numberOfSubscribeCalls;

/**
 @brief  Update how many times request has been called.
 
 @param numberOfCalls Updates call counter.
 
 @since 4.0
 */
- (void)setNumberOfSubscribeCalls:(NSInteger)numberOfCalls;

/**
 @brief      Retrieve list of all data objects to which client subscribed at this moment.
 @discussion Retrieve list of channels, groups and presence channels which currently used for 
             subscription.
 
 @return Full data object names list.
 
 @since 4.0
 */
- (NSArray *)allObjects;

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


#pragma mark - Subscription

/**
 @brief  Final designated subscription method before issue subscribe request to \b PubNub service.
 
 @param channels List of channels which has been merged with cached (previously subscribed) to be 
                 used in subscription requests.
 @param groups   List of channel groups which has been merged with cached (previously subscribed) to
                 be used in subscription requests.
 @param presence List of presence channels which has been merged with cached (previously subscribed)
                 to be used in subscription requests.
 @param state    Reference on client state information which should be bound to the user on remote
                 data objects.
 @param block    Subscription process completion block which pass two arguments: \c result - in case
                 of successful request processing \c data field will contain results of subscription
                 operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)subscribeToChannels:(NSArray *)channels groups:(NSArray *)groups
                andPresence:(NSArray *)presence withClientState:(NSDictionary *)state
              andCompletion:(PNCompletionBlock)block;

/**
 @brief  Subscription results handling and pre-processing before notify to completion blocks (if 
         required at all).
 
 @param channels     List of channels which has been used during previous subscribe attempt.
 @param groups       List of channel groups which has been used during previous subscribe attempt.
 @param presence     List of presence channels which has been used during previous subscribe
                     attempt.
 @param state        Final client state information which has been used during subscription process.
 @param requestCount How many numbers subscribe API has been called at the moment when this handler
                     has been called.
 @param result       Reference on RAW result object which doesn't have complete information about
                     request itself yet.
 @param status       Reference on RAW status object which doesn't have complete information about
                     request itself yet.
 
 @since 4.0
 */
- (void)handleSubscribeOn:(NSArray *)channels groups:(NSArray *)groups presence:(NSArray *)presence
                withState:(NSDictionary *)state subscribeCount:(NSInteger)requestCount
                   result:(PNResult *)result andStatus:(PNStatus *)status;


#pragma mark - Processing

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'subscribe'
         API group.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handeled by 'subscribe' API group.
 
 @since 4.0
 */
- (NSDictionary *)processedSubscriberResponse:(id)response;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (Subscribe)


#pragma mark - Properties

- (dispatch_queue_t)subscriberAccessQueue {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        dispatch_queue_t queue = dispatch_queue_create("com.pubnub.subscription.channels",
                                                       DISPATCH_QUEUE_CONCURRENT);
        objc_setAssociatedObject(self, kPubNubSubscriberSynchronizationQueue, queue,
                                 OBJC_ASSOCIATION_RETAIN);
    });
    
    return objc_getAssociatedObject(self, kPubNubSubscriberSynchronizationQueue);
}


#pragma mark - Subscription state information

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
    
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        objc_setAssociatedObject(self, kPubNubSubscribeCurrentTimeToken, timeToken,
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
    
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        objc_setAssociatedObject(self, kPubNubSubscribePreviousTimeToken, timeToken,
                                 OBJC_ASSOCIATION_RETAIN);
    });
}

- (NSInteger)numberOfSubscribeCalls {
    
    __block NSNumber *numberOfCalls = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        numberOfCalls = objc_getAssociatedObject(self, kPubNubSubscribeCallCount);
    });
    if (!numberOfCalls) {
        
        numberOfCalls = @(0);
        [self setNumberOfSubscribeCalls:[numberOfCalls integerValue]];
    }
    
    return [numberOfCalls integerValue];
}

- (void)setNumberOfSubscribeCalls:(NSInteger)numberOfCalls {
    
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        objc_setAssociatedObject(self, kPubNubSubscribeCallCount, @(numberOfCalls),
                                 OBJC_ASSOCIATION_RETAIN);
    });
}

- (NSArray *)allObjects {
    
    return [[[self channels] arrayByAddingObjectsFromArray:[self channelGroups]]
            arrayByAddingObjectsFromArray:[self presenceChannels]];
}

- (NSArray *)channels {
    
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
    
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        [[self mutableChannels] addObjectsFromArray:channels];
    });
}

- (void)removeChannels:(NSArray *)channels {
    
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        [[self mutableChannels] minusSet:[NSSet setWithArray:channels]];
    });
}

- (NSArray *)channelGroups {
    
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
    
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        [[self mutableGroups] addObjectsFromArray:groups];
    });
}

- (void)removeGroups:(NSArray *)groups {
    
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        [[self mutableGroups] minusSet:[NSSet setWithArray:groups]];
    });
}

- (NSArray *)presenceChannels {
    
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
    
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        [[self mutablePresenceChannels] addObjectsFromArray:channels];
    });
}

- (void)removePresenceChannels:(NSArray *)channels {
    
    dispatch_barrier_async([self subscriberAccessQueue], ^{
        
        [[self mutablePresenceChannels] minusSet:[NSSet setWithArray:channels]];
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
    
    NSMutableArray *presenceNames = [[NSMutableArray alloc] initWithCapacity:[names count]];
    for (NSString *name in names) {
        
        [presenceNames addObject:[name stringByAppendingString:kPubNubPresenceChannelNameSuffix]];
    }
    
    return [presenceNames copy];
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


#pragma mark - Subscription

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
              andCompletion:(PNCompletionBlock)block {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence clientState:nil
                andCompletion:block];
}

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                clientState:(NSDictionary *)state andCompletion:(PNCompletionBlock)block {
    
    __block NSSet *channelsList = nil;
    __block NSSet *presenceList = [self mutablePresenceChannels];
    dispatch_sync([self subscriberAccessQueue], ^{
        
        channelsList = [[self mutableChannels] setByAddingObjectsFromArray:channels];
        if (shouldObservePresence) {
            
            NSArray *presenceNames = [self presenceChannelsFrom:channels];
            presenceList = [[self mutablePresenceChannels] setByAddingObjectsFromArray:presenceNames];
        }
    });
    
    [self setNumberOfSubscribeCalls:([self numberOfSubscribeCalls] + 1)];
    [self subscribeToChannels:[channelsList allObjects] groups:[self channelGroups]
                  andPresence:[presenceList allObjects] withClientState:state andCompletion:block];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                   andCompletion:(PNCompletionBlock)block {
    
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence clientState:nil
                     andCompletion:block];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                     clientState:(NSDictionary *)state andCompletion:(PNCompletionBlock)block {
    
    __block NSSet *groupsList = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        groupsList = [[self mutableGroups] setByAddingObjectsFromArray:groups];
        if (shouldObservePresence) {
            
            groupsList = [groupsList setByAddingObjectsFromArray:[self presenceChannelsFrom:groups]];
        }
    });
    
    [self setNumberOfSubscribeCalls:([self numberOfSubscribeCalls] + 1)];
    [self subscribeToChannels:[self channels] groups:[groupsList allObjects]
                  andPresence:[self presenceChannels] withClientState:state andCompletion:block];
}

- (void)subscribeToPresenceChannels:(NSArray *)channels withCompletion:(PNCompletionBlock)block {
    
    __block NSSet *presenceList = nil;
    dispatch_sync([self subscriberAccessQueue], ^{
        
        presenceList = [[self mutablePresenceChannels] setByAddingObjectsFromArray:channels];
    });
    
    [self setNumberOfSubscribeCalls:([self numberOfSubscribeCalls] + 1)];
    [self subscribeToChannels:[self channels] groups:[self channelGroups]
                  andPresence:[presenceList allObjects] withClientState:nil andCompletion:block];
}

- (void)subscribeToChannels:(NSArray *)channels groups:(NSArray *)groups
                andPresence:(NSArray *)presence withClientState:(NSDictionary *)state
              andCompletion:(PNCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    // Store reference on current number of subscribe request calls.
    NSInteger subscribeCallCount = [self numberOfSubscribeCalls];
    
    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    dispatch_async(self.subscribeQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        if ([[strongSelf currentTimeToken] integerValue] == 0) {
            
            dispatch_suspend(strongSelf.subscribeQueue);
        }
        
        // Compose full list of channels which should be placed into request path (consist from
        // regulat and presence channels)
        NSArray *fullChannelsList = [channels arrayByAddingObjectsFromArray:presence];
        NSString *channelsList = [PNChannel namesForRequest:fullChannelsList defaultString:@","];
        NSString *groupsList = [PNChannel namesForRequest:groups];
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        
        // Prepare client state information which should be bound to remote data objects.
        NSArray *fullObjectsList = [fullChannelsList arrayByAddingObjectsFromArray:groups];
        NSDictionary *mergedState = [strongSelf stateMergedWith:state forObjects:fullObjectsList];
        
        // Prepare uery parameters basing on available information.
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        if (strongSelf.presenceHeartbeatValue > 0) {
            
            parameters[@"heartbeat"] = @(strongSelf.presenceHeartbeatValue);
        }
        if ([groupsList length]) {
            
            parameters[@"channel-group"] = groupsList;
        }
        if ([mergedState count]) {
            
            NSString *mergedStateString = [PNJSON JSONStringFrom:mergedState withError:nil];
            if (mergedStateString) {
                
                parameters[@"state"] = mergedStateString;
            }
        }
        parameters = ([parameters count] ? parameters : nil);
        
        // Build resulting resource request path.
        NSString *path = [NSString stringWithFormat:@"/subscribe/%@/%@/0/%@", subscribeKey,
                          channelsList, [strongSelf currentTimeToken]];
        PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                           forOperation:PNSubscribeOperation
                                         withCompletion:^(PNResult *result, PNStatus *status){
                          
            __strong __typeof(self) strongSelfForResults = weakSelf;
            [strongSelfForResults handleSubscribeOn:channels groups:groups presence:presence
                                          withState:mergedState subscribeCount:subscribeCallCount
                                             result:result andStatus:status];
                                             
            // Check whether initial subscription or channels list update has been performed.
            if ([[(result ?:status).request.URL lastPathComponent] isEqualToString:@"0"]) {
                
                if (block) {
                    
                    block(result, status);
                }
            }
        }];
        request.parseBlock = ^id(id rawData){
            
            __strong __typeof(self) strongSelfForProcessing = weakSelf;
            return [strongSelfForProcessing processedSubscriberResponse:rawData];
        };
        
        [strongSelf processRequest:request];
    });
}

- (void)handleSubscribeOn:(NSArray *)channels groups:(NSArray *)groups presence:(NSArray *)presence
                withState:(NSDictionary *)state subscribeCount:(NSInteger)requestCount
                   result:(PNResult *)result andStatus:(PNStatus *)status {
    
    // Try fetch time token from passed result/status objects.
    NSNumber *timeToken = @(strtoull([[(result?:status).request.URL lastPathComponent] UTF8String],
                                     NULL, 0));
    BOOL isInitialSubscription = ([timeToken integerValue] == 0);
    BOOL continueSubscriptionCycle = YES;
    
    // Storing channels into local cache, so they can be re-used with subscription cycle.
    [self addChannels:channels];
    [self addGroups:groups];
    [self addPresenceChannels:presence];
    
    // Store client state information into cache.
    [self mergeWithState:state];
    
    //
    if (isInitialSubscription) {
        
        [self setNumberOfSubscribeCalls:MIN(([self numberOfSubscribeCalls] - 1), 0)];
    }
    
    // Handle successful w/o troubles subscription request processing.
    if (result) {
        
        if (isInitialSubscription) {
            
            if (self.shouldKeepTimeTokenOnListChange) {
                
                // Swap time tokens to catch up on events which happened while client changed
                // channels and groups lits configuration.
                [self setCurrentTimeToken:[self previousTimeToken]];
                [self setPreviousTimeToken:@(0)];
            }
            
            dispatch_resume(self.subscribeQueue);
        }
    }
    // Looks like some troubles happened hile subscription request has been processed.
    else {
        
        // Looks like subscription request has been cancelled.
        // Cancelling can happen because of: user changed subscriber sensitive configuration or
        // another subscribe/unsubscribe request has been issued.
        if (status.category == PNCancelledCategory) {
            
            continueSubscriptionCycle = NO;
        }
        // Looks like processing failed because of another error.
        else {
            
        }
    }
    
    PNResult *targetObject = (result ?: status);
    BOOL successfulOperation = targetObject.statusCode == 200;
    if (successfulOperation) {
    }
    
    // Check whether initial subscription or channels list update has been performed.
    if ([[targetObject.request.URL lastPathComponent] isEqualToString:@"0"]) {
        
        if ((!targetObject.data[@"channels"] || !targetObject.data[@"channel-groups"]) &&
            ([channels count] || [presence count] || [groups count])) {
            
            NSMutableDictionary *data = [((NSDictionary *)targetObject.data ?: @{}) mutableCopy];
            if ([channels count]) {
                
                [data setValue:channels forKey:@"channels"];
            }
            if ([presence count]) {
                
                NSArray *storedChannels = (NSArray *)([data valueForKey:@"channels"] ?: @[]);
                [data setValue:[storedChannels arrayByAddingObjectsFromArray:presence]
                        forKey:@"channels"];
            }
            if ([groups count]) {
                
                [data setValue:groups forKey:@"channel-groups"];
            }
            [data removeObjectForKey:@"events"];
            targetObject.data = [data copy];
        }
        
        if (successfulOperation) {
            
            [self setPreviousTimeToken:[self currentTimeToken]];
            [self setCurrentTimeToken:result.data[@"tt"]];
            [self subscribeToChannels:[self channels] groups:[self channelGroups]
                          andPresence:[self presenceChannels] withClientState:nil
                        andCompletion:NULL];
        }
    }
    else {
        
        if (successfulOperation) {
            
            // Check whether response has been triggered by events pushed to remote data objects
            // live feed or not.
            if ([result.data[@"events"] count]) {
                
                NSArray *events = result.data[@"events"];
                for (NSDictionary *event in events) {
                    
                    if ([event[@"channel_name"] hasSuffix:kPubNubPresenceChannelNameSuffix] ||
                        [event[@"channel_group_name"] hasSuffix:kPubNubPresenceChannelNameSuffix]) {
                        
                        if (self.presenceEventHandlingBlock) {
                            
                            dispatch_async(self.callbackQueue, ^{
                                
                                self.presenceEventHandlingBlock([result copyWithData:event]);
                            });
                        }
                    }
                    else {
                        
                        if (self.messageHandlingBlock) {
                            
                            dispatch_async(self.callbackQueue, ^{
                                
                                self.messageHandlingBlock([result copyWithData:event]);
                            });
                        }
                    }
                }
            }
            if (result.data[@"events"]) {
                
                result.data = [(NSDictionary *)result.data dictionaryWithValuesForKeys:@[@"tt"]];
            }
        }
        if (successfulOperation) {
            
            [self setPreviousTimeToken:[self currentTimeToken]];
            [self setCurrentTimeToken:result.data[@"tt"]];
            [self subscribeToChannels:[self channels] groups:[self channelGroups]
                          andPresence:[self presenceChannels] withClientState:nil
                        andCompletion:NULL];
        }
    }
}


#pragma mark - Unsubscription

- (void)unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                  andCompletion:(PNCompletionBlock)block {
    
}

- (void)unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                       andCompletion:(PNCompletionBlock)block {
    
}

- (void)unsubscribeFromPresenceChannels:(NSArray *)channels andCompletion:(PNCompletionBlock)block {
    
}


#pragma mark - Processing

- (NSDictionary *)processedSubscriberResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array will arrive in case of subscription event
    if ([response isKindOfClass:[NSArray class]]) {
        
        NSArray *events = response[kPNEventsListElementIndex];
        NSNumber *timeToken = @(strtoull([response[kPNEventTimeTokenElement] UTF8String], NULL, 0));
        NSArray *channels = nil;
        NSArray *groups = nil;
        if ([(NSArray *)response count] > kPNEventChannelsElementIndex) {
            
            channels = [response[kPNEventChannelsElementIndex] componentsSeparatedByString:@","];
        }
        else if ([[self allObjects] count]){
            
            channels = @[[self allObjects][0]];
        }
        if ([(NSArray *)response count] > kPNEventChannelsDetailsElementIndex) {
            
            groups = [response[kPNEventChannelsDetailsElementIndex] componentsSeparatedByString:@","];
        }
        
        if ([events count] && ([channels count] || [groups count])) {
            
            NSMutableArray *updatedEvents = [[NSMutableArray alloc] initWithCapacity:[events count]];
            for (NSUInteger eventIdx = 0; eventIdx < [events count]; eventIdx++) {
                
                // Fetching remote data object name on which event fired.
                NSString *objectName = channels[eventIdx];
                id eventBody = events[eventIdx];
                if ([self.cipherKey length] && [eventBody isKindOfClass:[NSString class]]) {
                    
                    NSError *decryptionError;
                    NSData *eventData = [PNAES decrypt:eventBody withKey:self.cipherKey
                                              andError:&decryptionError];
                    if (!decryptionError) {
                        
                        eventBody = [NSString stringWithUTF8String:[eventData bytes]];
                        if (![eventBody isEqualToString:events[eventIdx]]) {
                            
                            eventBody = [PNJSON JSONObjectFrom:eventBody withError:nil];
                        }
                    }
                }
                NSMutableDictionary *event = [NSMutableDictionary new];
                [event addEntriesFromDictionary:@{@"message":eventBody,
                                                  @"channel_name":objectName, @"tt":timeToken}];
                if ([groups count] > eventIdx) {
                    
                    NSString *groupName = groups[eventIdx];
                    [event setValue:groupName forKey:@"channel_group_name"];
                }
                
                [updatedEvents addObject:event];
            }
            events = [updatedEvents copy];
        }
        processedResponse = @{@"events":events,@"tt":timeToken};
        
    }
    // Dictinoary will arrive in case of leave event or subscription error
    else {
        
    }
    
    return processedResponse;
}

#pragma mark -


@end
