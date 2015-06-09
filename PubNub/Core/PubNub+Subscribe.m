/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Subscribe.h"
#import "PubNub+CorePrivate.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PNStateListener.h"
#import "PNSubscriber.h"
#import "PNHelpers.h"


#pragma mark Interface implementation

@implementation PubNub (Subscribe)


#pragma mark - Subscription state information

- (NSArray *)channels {
    
    return [self.subscriberManager channels];
}

- (NSArray *)channelGroups {
    
    return [self.subscriberManager channelGroups];
}

- (NSArray *)presenceChannels {
    
    return [self.subscriberManager presenceChannels];
}

- (BOOL)isSubscribedOn:(NSString *)name {
    
    return ([[self channels] containsObject:name] || [[self channelGroups] containsObject:name] ||
            [[self presenceChannels] containsObject:name]);
}


#pragma mark - Listeners

- (void)addListeners:(NSArray *)listeners {
    
    // Forwarding calls to listener manager.
    [self.listenersManager addListeners:listeners];
}

- (void)removeListeners:(NSArray *)listeners {
    
    // Forwarding calls to listener manager.
    [self.listenersManager removeListeners:listeners];
}


#pragma mark - Subscription

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence clientState:nil];
}

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                clientState:(NSDictionary *)state {

    NSArray *presenceChannelsList = nil;
    if (shouldObservePresence) {

        presenceChannelsList = [PNChannel presenceChannelsFrom:channels];
    }
    [self.subscriberManager addChannels:[channels arrayByAddingObjectsFromArray:presenceChannelsList]];
    [self.subscriberManager subscribe:YES withState:state];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence {
    
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence clientState:nil];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                     clientState:(NSDictionary *)state {

    NSArray *groupsList = [NSArray arrayWithArray:groups];
    if (shouldObservePresence) {

        groupsList = [groups arrayByAddingObjectsFromArray:[PNChannel presenceChannelsFrom:groups]];
    }
    [self.subscriberManager addChannelGroups:groupsList];
    [self.subscriberManager subscribe:YES withState:state];
}

- (void)subscribeToPresenceChannels:(NSArray *)channels {
    
    channels = [PNChannel presenceChannelsFrom:channels];
    [self.subscriberManager addPresenceChannels:channels];
    [self.subscriberManager subscribe:YES withState:nil];
}


#pragma mark - Unsubscription

- (void)unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {

    NSArray *presenceChannels = nil;
    if (shouldObservePresence) {

        presenceChannels = [PNChannel presenceChannelsFrom:channels];
    }
    NSArray *fullChannelsList = [channels arrayByAddingObjectsFromArray:presenceChannels];
    [self.subscriberManager removeChannels:fullChannelsList];
    [self.subscriberManager unsubscribeFrom:YES objects:fullChannelsList];
}

- (void)unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence {

    NSArray *groupsList = [NSArray arrayWithArray:groups];
    if (shouldObservePresence) {

        groupsList = [groupsList arrayByAddingObjectsFromArray:[PNChannel presenceChannelsFrom:groups]];
    }
    [self.subscriberManager removeChannelGroups:groupsList];
    [self.subscriberManager unsubscribeFrom:NO objects:groupsList];
}

- (void)unsubscribeFromPresenceChannels:(NSArray *)channels {
    
    channels = [PNChannel presenceChannelsFrom:channels];
    [self.subscriberManager removePresenceChannels:channels];
    [self.subscriberManager unsubscribeFrom:YES objects:channels];
}

#pragma mark -


@end
