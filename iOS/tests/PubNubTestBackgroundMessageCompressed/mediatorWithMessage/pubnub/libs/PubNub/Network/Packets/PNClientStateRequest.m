//
//  PNClientStateRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientStateRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNChannel+Protected.h"
#import "PNConfiguration.h"
#import "PNMacro.h"


#pragma mark Public interface implementation

@implementation PNClientStateRequest


#pragma mark - Class methods

+ (PNClientStateRequest *)clientStateRequestForIdentifier:(NSString *)clientIdentifier andChannel:(PNChannel *)channel {

    return [[self alloc] initWithIdentifier:clientIdentifier andChannel:channel];
}

#pragma mark - Instance methods

- (id)initWithIdentifier:(NSString *)clientIdentifier andChannel:(PNChannel *)channel {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.clientIdentifier = clientIdentifier;
        self.channel = channel;
    }


    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.stateRetrieveCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/uuid/%@?callback=%@_%@%@%@&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString],
            (!self.channel.isChannelGroup ? [self.channel escapedName] : @"."),
            [self.clientIdentifier pn_percentEscapedString], [self callbackMethodName], self.shortIdentifier,
            (self.channel.isChannelGroup ? [NSString stringWithFormat:@"&channel-group=%@", [self.channel escapedName]] : @""),
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
