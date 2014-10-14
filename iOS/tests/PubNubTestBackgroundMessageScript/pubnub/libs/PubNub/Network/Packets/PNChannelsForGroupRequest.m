//
//  PNChannelsForGroupRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/17/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelsForGroupRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNConfiguration.h"
#import "PNChannelGroup.h"
#import "PNMacro.h"


#pragma mark Public interface implementation

@implementation PNChannelsForGroupRequest


#pragma mark - Class methods

+ (PNChannelsForGroupRequest *)channelsRequestForGroup:(PNChannelGroup *)group {
    
    return [[self alloc] initWithGroup:group];
}


#pragma mark - Instance methods

- (id)initWithGroup:(PNChannelGroup *)group {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.group = group;
    }
    
    
    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {
    
    return PNServiceResponseCallbacks.channelsForGroupRequestCallback;
}

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"/v1/channel-registration/sub-key/%@/%@channel-group/%@?callback=%@_%@%@&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString],
            (self.group.nspace ? [NSString stringWithFormat:@"namespace/%@/", [self.group.nspace pn_percentEscapedString]] : @""),
            [self.group.groupName pn_percentEscapedString], [self callbackMethodName], self.shortIdentifier,
            ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
            [self clientInformationField]];
}

- (NSString *)debugResourcePath {
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    return [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
