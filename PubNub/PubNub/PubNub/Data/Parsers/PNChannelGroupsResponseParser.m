//
//  PNChannelGroupsResponseParser.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupsResponseParser+Protected.h"
#import "PNResponse+Protected.h"
#import "PNChannelGroup.h"


#pragma mark Public interface implementation

@implementation PNChannelGroupsResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {
    
    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);
    
    
    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {
    
    // Checking base requirement about payload data type.
    BOOL conforms = [response.response isKindOfClass:[NSDictionary class]];
    if(conforms) {
        
        NSDictionary *channelGroupsData = response.response;
        conforms = ([channelGroupsData objectForKey:kPNResponseNamespaceKey] &&
                    [channelGroupsData objectForKey:kPNResponseChannelGroupsKey]);
        conforms = (conforms ? [[channelGroupsData valueForKey:kPNResponseNamespaceKey] isKindOfClass:[NSString class]] : conforms);
        conforms = (conforms ? [[channelGroupsData valueForKey:kPNResponseChannelGroupsKey] isKindOfClass:[NSArray class]] : conforms);
    }
    
    
    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {
    
    // Check whether initialization successful or not
    if ((self = [super init])) {
        
        NSString *nspace = (response.additionalData ? response.additionalData : [response.response valueForKey:kPNResponseNamespaceKey]);
        NSArray *channelGroupNames = [response.response valueForKey:kPNResponseChannelGroupsKey];
        NSMutableArray *channelGroups = [NSMutableArray arrayWithCapacity:[channelGroupNames count]];
        [channelGroupNames enumerateObjectsUsingBlock:^(NSString *channelGroupName, NSUInteger channelGroupNameIdx,
                                                        BOOL *channelGroupNamesEnumeratorStop) {
            
            [channelGroups addObject:[PNChannelGroup channelGroupWithName:channelGroupName inNamespace:nspace]];
        }];
        self.channelGroups = [channelGroups copy];
    }
    
    
    return self;
}

- (id)parsedData {
    
    return self.channelGroups;
}

#pragma mark -


@end
