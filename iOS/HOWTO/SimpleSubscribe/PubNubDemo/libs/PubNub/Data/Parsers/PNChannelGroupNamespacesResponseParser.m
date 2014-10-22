//
//  PNChannelGroupNamespacesResponseParser.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupNamespacesResponseParser+Protected.h"
#import "PNResponse+Protected.h"


#pragma mark Public interface implementation

@implementation PNChannelGroupNamespacesResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {
    
    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);
    
    
    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {
    
    BOOL conforms = [response.response isKindOfClass:[NSDictionary class]];
    if(conforms) {
        
        NSDictionary *channelGroupNamespacesData = response.response;
        conforms = ([channelGroupNamespacesData objectForKey:kPNResponseSubscriptionKey] &&
                    [channelGroupNamespacesData objectForKey:kPNResponseNamespacesKey]);
        conforms = (conforms ? [[channelGroupNamespacesData valueForKey:kPNResponseSubscriptionKey] isKindOfClass:[NSString class]] : conforms);
        conforms = (conforms ? [[channelGroupNamespacesData valueForKey:kPNResponseNamespacesKey] isKindOfClass:[NSArray class]] : conforms);
    }
    
    
    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {
    
    // Check whether initialization successful or not
    if ((self = [super init])) {
        
        self.namespaces = [response.response valueForKey:kPNResponseNamespacesKey];
    }
    
    
    return self;
}

- (id)parsedData {
    
    return self.namespaces;
}

#pragma mark -


@end
