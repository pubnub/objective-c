//
//  PNChannelGroupsRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupsRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNConfiguration.h"
#import "PNMacro.h"


#pragma mark Public interface implementation

@implementation PNChannelGroupsRequest


#pragma mark - Class methods

+ (PNChannelGroupsRequest *)channelGroupsRequestForNamespace:(NSString *)nspace {
    
    return [[self alloc] initWithNamespace:nspace];
}


#pragma mark - Instance methods

- (id)initWithNamespace:(NSString *)nspace {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.namespaceName = nspace;
    }
    
    
    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {
    
    return PNServiceResponseCallbacks.channelGroupsRequestCallback;
}

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"/v1/channel-registration/sub-key/%@/%@channel-group?callback=%@_%@%@&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString],
            (self.namespaceName ? [NSString stringWithFormat:@"namespace/%@/", [self.namespaceName pn_percentEscapedString]] : @""),
            [self callbackMethodName], self.shortIdentifier,
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
