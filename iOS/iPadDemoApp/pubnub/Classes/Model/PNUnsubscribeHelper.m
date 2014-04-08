//
//  PNUnsubscribeHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/27/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNUnsubscribeHelper.h"


#pragma mark Private interface declaration

@interface PNUnsubscribeHelper ()


#pragma mark - Instance methods

/**
 Stores reference on all channels on which client subscribed at this moment.
 */
@property (nonatomic, strong) NSArray *channels;

/**
 Stores reference on list of channels from which \b PubNub client should unsubscribe.
 */
@property (nonatomic, strong) NSMutableArray *markedChannels;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNUnsubscribeHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    self.channels = [PubNub subscribedChannels];
    self.markedChannels = [NSMutableArray array];
}

- (void)addChannelForUnsubscription:(PNChannel *)channel {
    
    if (![self.markedChannels containsObject:channel]) {
        
        [self.markedChannels addObject:channel];
    }
}

- (void)removeChannel:(PNChannel *)channel {
    
    [self.markedChannels removeObject:channel];
}

- (BOOL)willUnsubscribeFromChannel:(PNChannel *)channel {
    
    return [self.markedChannels containsObject:channel];
}

- (NSArray *)channelsForUnsubscription {
    
    return self.channels;
}

- (BOOL)canUnsubscribe {
    
    return [self.markedChannels count] > 0;
}

- (void)unsubscribeWithBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    
    if ([self.markedChannels count]) {
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        [PubNub unsubscribeFromChannels:self.markedChannels
            withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {
                
                weakSelf.channels = [PubNub subscribedChannels];
                
                if (handlerBlock) {
                    
                    handlerBlock(channels, unsubscribeError);
                }
            }];
    }
}

#pragma mark -


@end
