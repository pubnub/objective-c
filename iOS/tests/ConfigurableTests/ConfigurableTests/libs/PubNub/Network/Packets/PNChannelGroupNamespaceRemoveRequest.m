//
//  PNChannelGroupNamespaceRemoveRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupNamespaceRemoveRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNConfiguration.h"
#import "PNMacro.h"


#pragma mark Public interface implementation

@implementation PNChannelGroupNamespaceRemoveRequest


#pragma mark - Class methods

+ (PNChannelGroupNamespaceRemoveRequest *)requestToRemoveNamespace:(NSString *)nspace {
    
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
    
    return PNServiceResponseCallbacks.channelGroupNamespaceRemoveCallback;
}

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"/v1/channel-registration/sub-key/%@/namespace/%@/remove?callback=%@_%@%@&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString], [self.namespaceName pn_percentEscapedString],
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
