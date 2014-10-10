//
//  PNChannelGroupChange.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupChange+Protected.h"


#pragma mark Public interface implementation

@implementation PNChannelGroupChange


#pragma mark - Class methods

+ (PNChannelGroupChange *)changeForGroup:(PNChannelGroup *)group channels:(NSArray *)channels addingChannels:(BOOL)addingChannels {
    
    return [[self alloc] initWithGroup:group withChannels:channels addingChannels:addingChannels];
}


#pragma mark - Instance methods

- (id)initWithGroup:(PNChannelGroup *)group withChannels:(NSArray *)channels addingChannels:(BOOL)addingChannels {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.group = group;
        self.channels = [channels copy];
        self.addingChannels = addingChannels;
    }
    
    return self;
}

#pragma mark -


@end
