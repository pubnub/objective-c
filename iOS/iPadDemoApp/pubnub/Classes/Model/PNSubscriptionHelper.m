//
//  PNSubscriptionHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNSubscriptionHelper.h"


#pragma mark Private interface declaration

@interface PNSubscriptionHelper ()


#pragma mark - Properties

/**
 Stores reference on list of channels on which client should subscribe.
 */
@property (nonatomic, strong) NSMutableArray *channels;

/**
 Stores reference on dictionary which stores state for all channels for which it has been created.
 */
@property (nonatomic, strong) NSMutableDictionary *states;

/**
 Stores reference on dictionary which stores whether presence observation for channel should be used.
 */
@property (nonatomic, strong) NSMutableDictionary *presenceObservation;

#pragma mark -


@end


#pragma mark - Public interface implentation

@implementation PNSubscriptionHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    
    self.channels = [NSMutableArray array];
    self.states = [NSMutableDictionary dictionary];
    self.presenceObservation = [NSMutableDictionary dictionary];
}

- (void)addChannel:(PNChannel *)channel withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObservePresence {
    
    if (channel && ![PubNub isSubscribedOn:channel]) {
        
        if (![self.channels containsObject:channel]) {
            
            [self.channels addObject:channel];
            if (channelState) {
                
                [self.states setValue:channelState forKey:channel.name];
            }
            else {
                
                [self.states removeObjectForKey:channel.name];
            }
        }
        else if (channelState) {
            
            [self.states setValue:channelState forKey:channel.name];
        }
        
        [self.presenceObservation setValue:@(shouldObservePresence) forKey:channel.name];
    }
}

- (void)removeChannel:(PNChannel *)channel {
    
    [self.channels removeObject:channel];
    [self.states removeObjectForKey:channel.name];
}

- (NSArray *)channelsForSubscription {
    
    return self.channels;
}

- (NSDictionary *)channelsState {
    
    return ([self.states count] ? self.states : nil);
}

- (NSDictionary *)stateForChannel:(PNChannel *)channel {
    
    return [self.states valueForKey:channel.name];
}

- (BOOL)shouldObserverPresenceForChannel:(PNChannel *)channel {
    
    return [[self.presenceObservation valueForKey:channel.name] boolValue];
}

- (void)reset {
    
    [self.channels removeAllObjects];
    [self.channels removeAllObjects];
}

#pragma mark -


@end
