/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PubNub+Subscribe.h"
#import "PubNub+CorePrivate.h"
#import "PNSubscriber.h"
#import "PNHelpers.h"


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

- (void)setFilterExpression:(nullable NSString *)filterExpression {
    
    self.subscriberManager.filterExpression = filterExpression;
    if ([self.subscriberManager allObjects].count) { [self subscribeToChannels:@[] withPresence:NO]; }
}


#pragma mark - Subscription

- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(nullable NSNumber *)timeToken {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:timeToken
                  clientState:nil];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
                clientState:(nullable NSDictionary<NSString *, id> *)state {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil
                  clientState:state];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(nullable NSNumber *)timeToken 
                clientState:(nullable NSDictionary<NSString *, id> *)state {
    
    NSArray *presenceChannelsList = nil;
    if (shouldObservePresence) { presenceChannelsList = [PNChannel presenceChannelsFrom:channels]; }
    
    [self.subscriberManager addChannels:[channels arrayByAddingObjectsFromArray:presenceChannelsList]];
    [self.subscriberManager subscribeUsingTimeToken:timeToken withState:state completion:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence {
    
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(nullable NSNumber *)timeToken {
    
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:timeToken
                       clientState:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                     clientState:(nullable NSDictionary<NSString *, id> *)state {

    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:nil
                       clientState:state];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(nullable NSNumber *)timeToken
                     clientState:(nullable NSDictionary<NSString *, id> *)state {
    
    NSArray *groupsList = [NSArray arrayWithArray:groups];
    if (shouldObservePresence) {
        
        groupsList = [groups arrayByAddingObjectsFromArray:[PNChannel presenceChannelsFrom:groups]];
    }
    [self.subscriberManager addChannelGroups:groupsList];
    [self.subscriberManager subscribeUsingTimeToken:timeToken withState:state completion:nil];
}

- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels {
    
    channels = [PNChannel presenceChannelsFrom:channels];
    [self.subscriberManager addPresenceChannels:channels];
    [self.subscriberManager subscribeUsingTimeToken:nil withState:nil completion:nil];
}


#pragma mark - Unsubscription

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence {

    [self unsubscribeFromChannels:channels withPresence:shouldObservePresence completion:nil];
}

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
                     completion:(nullable PNSubscriberCompletionBlock)block {

    NSArray *presenceChannels = nil;
    if (shouldObservePresence) { presenceChannels = [PNChannel presenceChannelsFrom:channels]; }
    NSArray *fullChannelsList = [channels arrayByAddingObjectsFromArray:presenceChannels];
    [self.subscriberManager removeChannels:fullChannelsList];
    [self.subscriberManager unsubscribeFrom:YES objects:fullChannelsList completion:block];
}

- (void)unsubscribeFromChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence {

    [self unsubscribeFromChannelGroups:groups withPresence:shouldObservePresence completion:nil];
}

- (void)unsubscribeFromChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                          completion:(nullable PNSubscriberCompletionBlock)block {

    NSArray *groupsList = [NSArray arrayWithArray:groups];
    if (shouldObservePresence) {

        groupsList = [groupsList arrayByAddingObjectsFromArray:[PNChannel presenceChannelsFrom:groups]];
    }
    [self.subscriberManager removeChannelGroups:groupsList];
    [self.subscriberManager unsubscribeFrom:NO objects:groupsList completion:block];
}

- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels {
    
    channels = [PNChannel presenceChannelsFrom:channels];
    [self.subscriberManager removePresenceChannels:channels];
    [self.subscriberManager unsubscribeFrom:YES objects:channels completion:nil];
}

- (void)unsubscribeFromAll {
    
    [self.subscriberManager unsubscribeFromAll];
}

#pragma mark -


@end
