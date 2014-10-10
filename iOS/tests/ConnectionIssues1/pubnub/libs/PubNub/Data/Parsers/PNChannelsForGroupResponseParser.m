//
//  PNChannelsForGroupResponseParser.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/17/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelsForGroupResponseParser.h"
#import "PNChannelGroup+Protected.h"
#import "PNResponse+Protected.h"


#pragma mark Private interface declaration

@interface PNChannelsForGroupResponseParser ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *channels;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNChannelsForGroupResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {
    
    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);
    
    
    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {
    
    // Checking base requirement about payload data type.
    BOOL conforms = [response.response isKindOfClass:[NSArray class]];
    
    
    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {
    
    // Check whether initialization successful or not
    if ((self = [super init])) {
        
        self.channels = ([response.response count] ? [PNChannel channelsWithNames:response.response] : @[]);
    }
    
    
    return self;
}

- (id)parsedData {
    
    return self.channels;
}

#pragma mark -


@end
