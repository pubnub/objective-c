//
//  PNPresenceObservationHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/1/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPresenceObservationHelper.h"


#pragma mark Provate interface declaration

@interface PNPresenceObservationHelper ()


#pragma mark - Properties

@property (nonatomic, strong) NSMutableArray *userProvidedChannels;
@property (nonatomic, strong) NSMutableArray *existingChannels;
@property (nonatomic, strong) NSMutableArray *channelsForPresenceManipulation;


#pragma mark - Instance methods

/**
 Prepare all required set of cached data.
 */
- (void)prepareData;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation PNPresenceObservationHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    [self prepareData];
}

- (void)prepareData {
    
    self.existingChannels = ([[PubNub subscribedObjectsList] count] ? [[PubNub subscribedObjectsList] mutableCopy] : [NSMutableArray array]);
    // Don't use this method (private PubNub API)
    NSArray *presenceEnabledChannels = [[PubNub sharedInstance] valueForKeyPath:@"presenceEnabledChannels"];
    
    if ([presenceEnabledChannels count]) {
        
        if (!self.isEnablingPresenceObservation) {
            
            self.existingChannels = [presenceEnabledChannels mutableCopy];
        }
        else {
            
            [presenceEnabledChannels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx,
                                                                  BOOL *channelEnumeratorStop) {
                
                [self.existingChannels removeObject:channel];
            }];
        }
    }
    else if (!self.isEnablingPresenceObservation) {
        
        self.existingChannels = [NSMutableArray array];
    }
    self.userProvidedChannels = [NSMutableArray array];
    self.channelsForPresenceManipulation = [NSMutableArray array];
}

- (void)setEnablingPresenceObservation:(BOOL)enablingPresenceObservation {
    
    BOOL isPresenceObservationChanged = _enablingPresenceObservation != enablingPresenceObservation;
    _enablingPresenceObservation = enablingPresenceObservation;
    
    if (isPresenceObservationChanged) {
        
        [self prepareData];
    }
}

- (void)addChannel:(PNChannel *)channel {
    
    if (![self willChangePresenceStateForChanne:channel]) {
        
        [self.channelsForPresenceManipulation addObject:channel];
    }
       
    if (![self.existingChannels containsObject:channel] && self.isEnablingPresenceObservation) {
        
        if (![self.userProvidedChannels containsObject:channel]) {
            
            [self.userProvidedChannels addObject:channel];
        }
        
        [self.existingChannels addObject:channel];
    }
}

- (void)removeChannel:(PNChannel *)channel {
    
    if ([self.userProvidedChannels containsObject:channel]) {
        
        [self.existingChannels removeObject:channel];
        [self.userProvidedChannels removeObject:channel];
    }
    [self.channelsForPresenceManipulation removeObject:channel];
}

- (BOOL)willChangePresenceStateForChanne:(PNChannel *)channel {
    
    return [self.channelsForPresenceManipulation containsObject:channel];
}

- (NSArray *)channels {
    
    return self.existingChannels;
}

- (BOOL)isAbleToChangePresenceState {
    
    return [self.channelsForPresenceManipulation count] > 0;
}

- (void)performRequestWithBlock:(void(^)(NSArray *, PNError *))handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    void(^completionHandler)(NSArray *, PNError *) = ^(NSArray *channels, PNError *presenceStateManipulationError){
        
        channels = [weakSelf.channelsForPresenceManipulation copy];
        if (!presenceStateManipulationError) {
            
            [weakSelf reset];
        }
        
        if (handlerBlock) {
            
            handlerBlock(channels, presenceStateManipulationError);
        }
    };
    if (self.isEnablingPresenceObservation) {
        
        [PubNub enablePresenceObservationFor:self.channelsForPresenceManipulation
                 withCompletionHandlingBlock:completionHandler];
    }
    else {
        
        [PubNub disablePresenceObservationFor:self.channelsForPresenceManipulation
                  withCompletionHandlingBlock:completionHandler];
    }
}

- (void)reset {
    
    [self prepareData];
}

#pragma mark -

@end
