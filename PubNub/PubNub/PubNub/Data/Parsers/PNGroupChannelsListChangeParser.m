//
//  PNGroupChannelsListChangeParser.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNGroupChannelsListChangeParser.h"
#import "PNResponse+Protected.h"
#import "PNChannelGroupChange.h"


#pragma mark Private interface declaration

@interface PNGroupChannelsListChangeParser ()


#pragma mark - Properties

@property (nonatomic, strong) PNChannelGroupChange *change;

#pragma mark -


@end



#pragma mark - Public interface implementation

@implementation PNGroupChannelsListChangeParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {
    
    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);
    
    
    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {

    return YES;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {
    
    // Check whether initialization successful or not
    if ((self = [super init])) {
        
        self.change = response.additionalData;
    }
    
    
    return self;
}

- (id)parsedData {
    
    return self.change;
}

#pragma mark -


@end
