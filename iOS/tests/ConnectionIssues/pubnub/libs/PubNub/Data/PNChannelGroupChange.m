//
//  PNChannelGroupChange.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupChange+Protected.h"
#import "PNChannelGroup.h"


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

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [NSString stringWithFormat:@"<%@|%@|%@>",
            (self.group ? [self.group performSelector:@selector(logDescription)] : [NSNull null]),
            (self.channels ? [self.channels performSelector:@selector(logDescription)] : [NSNull null]),
            @(self.addingChannels)];
    #pragma clang diagnostic pop
}

#pragma mark -


@end
