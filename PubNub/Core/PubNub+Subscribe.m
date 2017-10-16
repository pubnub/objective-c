/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PubNub+Subscribe.h"
#import "PNAPICallBuilder+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNSubscriber.h"
#import "PNNetwork.h"
#import "PNHelpers.h"


#pragma mark - Constants

/**
 @brief      Stored reference on subscribe REST API path prefix. 
 @discussion Prefix used for faster request identification (w/o performing search of range with options).
 
 @since 4.6.2
 */
static NSString * const kPNSubscribeAPIPrefix = @"/v2/subscribe/";


#pragma mark - Interface implementation

@implementation PubNub (Subscribe)


#pragma mark - Subscription state information

- (NSArray<NSString *> *)channels {
    
    return [self.subscriberManager channels];
}

- (NSArray<NSString *> *)channelGroups {
    
    return [self.subscriberManager channelGroups];
}

- (NSArray<NSString *> *)presenceChannels {
    
    return [self.subscriberManager presenceChannels];
}

- (BOOL)isSubscribedOn:(NSString *)name {
    
    return ([[self channels] containsObject:name] || [[self channelGroups] containsObject:name] ||
            [[self presenceChannels] containsObject:name]);
}


#pragma mark - Listeners

- (void)addListener:(id <PNObjectEventListener>)listener {
    
    // Forwarding calls to listener manager.
    [self.listenersManager addListener:listener];
}

- (void)removeListener:(id <PNObjectEventListener>)listener {
    
    // Forwarding calls to listener manager.
    [self.listenersManager removeListener:listener];
}


#pragma mark - Filtering

- (NSString *)filterExpression {
    
    return self.subscriberManager.filterExpression;
}

- (void)setFilterExpression:(NSString *)filterExpression {
    
    self.subscriberManager.filterExpression = filterExpression;
    if ([self.subscriberManager allObjects].count) { [self subscribeToChannels:@[] withPresence:NO]; }
}


#pragma mark - API Builder support

- (PNSubscribeAPIBuilder *(^)(void))subscribe {
    
    PNSubscribeAPIBuilder *builder = nil;
    builder = [PNSubscribeAPIBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                 NSDictionary *parameters) {
                            
        NSDictionary *state = parameters[NSStringFromSelector(@selector(state))];
        NSNumber *withPresence = parameters[NSStringFromSelector(@selector(withPresence))];
        NSNumber *timetoken = parameters[NSStringFromSelector(@selector(withTimetoken))];
        NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSArray<NSString *> *groups = parameters[NSStringFromSelector(@selector(channelGroups))];
        
        if (channels.count || groups.count) {
         
            [self subscribeToChannels:channels groups:groups withPresence:withPresence.boolValue 
                       usingTimeToken:timetoken clientState:state];
        }
        else if ((channels = parameters[NSStringFromSelector(@selector(presenceChannels))]).count) {
            
            [self subscribeToPresenceChannels:channels];
        }
    }];
    
    return ^PNSubscribeAPIBuilder *{ return builder; };
}

- (PNUnsubscribeAPICallBuilder *(^)(void))unsubscribe {
    
    PNUnsubscribeAPICallBuilder *builder = nil;
    builder = [PNUnsubscribeAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                       NSDictionary *parameters) {

        NSNumber *withPresence = parameters[NSStringFromSelector(@selector(withPresence))];
        NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSArray<NSString *> *groups = parameters[NSStringFromSelector(@selector(channelGroups))];
        if (channels.count || groups.count) {
         
            [self unsubscribeFromChannels:channels groups:groups withPresence:withPresence.boolValue 
                               completion:nil];
        }
        else if ((channels = parameters[NSStringFromSelector(@selector(presenceChannels))]).count) {
            
            [self unsubscribeFromPresenceChannels:channels];
        }
        else { [self unsubscribeFromAll]; }
    }];
    
    return ^PNUnsubscribeAPICallBuilder *{ return builder; };
}


#pragma mark - Subscription

- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(NSNumber *)timeToken {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:timeToken
                  clientState:nil];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
                clientState:(NSDictionary<NSString *, id> *)state {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil
                  clientState:state];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(NSNumber *)timeToken clientState:(NSDictionary<NSString *, id> *)state {
    
    [self subscribeToChannels:channels groups:nil withPresence:shouldObservePresence
               usingTimeToken:timeToken clientState:state];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence {
    
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(NSNumber *)timeToken {
    
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:timeToken
                       clientState:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                     clientState:(NSDictionary<NSString *, id> *)state {

    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:nil
                       clientState:state];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(NSNumber *)timeToken clientState:(NSDictionary<NSString *, id> *)state {
    
    [self subscribeToChannels:nil groups:groups withPresence:shouldObservePresence
               usingTimeToken:timeToken clientState:state];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels groups:(NSArray<NSString *> *)groups 
               withPresence:(BOOL)shouldObservePresence usingTimeToken:(NSNumber *)timeToken 
                clientState:(NSDictionary<NSString *, id> *)state {
    
    channels = (channels?: @[]);
    groups = (groups?: @[]);
    
    if (channels.count) {
        
        NSArray *presenceChannelsList = nil;
        if (shouldObservePresence) { presenceChannelsList = [PNChannel presenceChannelsFrom:channels]; }
        [self.subscriberManager addChannels:[channels arrayByAddingObjectsFromArray:presenceChannelsList]];
    }
    
    if (groups.count) {
        
        NSArray *presenceGroupsList = nil;
        if (shouldObservePresence) { presenceGroupsList = [PNChannel presenceChannelsFrom:groups]; }
        [self.subscriberManager addChannelGroups:[groups arrayByAddingObjectsFromArray:presenceGroupsList]];
    }
    [self cancelSubscribeOperations];
    [self.subscriberManager subscribeUsingTimeToken:timeToken withState:state completion:nil];
}

- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels {
    
    channels = [PNChannel presenceChannelsFrom:channels];
    [self.subscriberManager addPresenceChannels:channels];
    [self cancelSubscribeOperations];
    [self.subscriberManager subscribeUsingTimeToken:nil withState:nil completion:nil];
}


#pragma mark - Unsubscription

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence {
    
    [self unsubscribeFromChannels:channels groups:nil withPresence:shouldObservePresence completion:nil];
}

- (void)unsubscribeFromChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence {

    [self unsubscribeFromChannels:nil groups:groups withPresence:shouldObservePresence completion:nil];
}

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels groups:(NSArray<NSString *> *)groups
                   withPresence:(BOOL)shouldObservePresence completion:(PNSubscriberCompletionBlock)block {
    
    channels = (channels?: @[]);
    groups = (groups?: @[]);
    
    if (channels.count) {
        
        NSArray *presenceChannelsList = nil;
        if (shouldObservePresence) { presenceChannelsList = [PNChannel presenceChannelsFrom:channels]; }
        [self.subscriberManager removeChannels:[channels arrayByAddingObjectsFromArray:presenceChannelsList]];
    }
    
    if (groups.count) {
        
        NSArray *presenceGroupsList = nil;
        if (shouldObservePresence) { presenceGroupsList = [PNChannel presenceChannelsFrom:groups]; }
        [self.subscriberManager removeChannelGroups:[groups arrayByAddingObjectsFromArray:presenceGroupsList]];
    }
    
    if (channels.count || groups.count) {

        [self cancelSubscribeOperations];
        [self.subscriberManager unsubscribeFromChannels:channels groups:groups completion:block];
    }
    else if (block) { pn_dispatch_async(self.callbackQueue, ^{ block(nil); }); }
}

- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels {
    
    channels = [PNChannel presenceChannelsFrom:channels];
    [self.subscriberManager removePresenceChannels:channels];
    [self cancelSubscribeOperations];
    [self.subscriberManager unsubscribeFromChannels:channels groups:nil completion:nil];
}

- (void)unsubscribeFromAll {

    [self unsubscribeFromAllWithCompletion:nil];
}

- (void)unsubscribeFromAllWithCompletion:(void(^)(PNStatus *status))block {
    
    [self cancelSubscribeOperations];
    [self.subscriberManager unsubscribeFromAllWithCompletion:block];
}


#pragma mark - Misc

- (void)cancelSubscribeOperations {
    
    [self.subscriptionNetwork cancelAllOperationsWithURLPrefix:kPNSubscribeAPIPrefix];
}

#pragma mark -


@end
