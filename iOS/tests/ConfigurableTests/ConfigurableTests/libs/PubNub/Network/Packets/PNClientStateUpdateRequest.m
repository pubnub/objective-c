//
//  PNClientStateUpdateRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientStateUpdateRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "NSString+PNAddition.h"
#import "PNPrivateImports.h"
#import "PNConfiguration.h"
#import "PNMacro.h"


#pragma mark Public interface implementation

@implementation PNClientStateUpdateRequest


#pragma mark - Class methods

+ (PNClientStateUpdateRequest *)clientStateUpdateRequestWithIdentifier:(NSString *)clientIdentifier
                                                               channel:(PNChannel *)channel
                                                        andClientState:(NSDictionary *)clientState {

    return [[self alloc] initWithIdentifier:clientIdentifier channel:channel andClientState:clientState];
}


#pragma mark - Instance methods

- (id)initWithIdentifier:(NSString *)clientIdentifier channel:(PNChannel *)channel andClientState:(NSDictionary *)clientState {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.clientIdentifier = clientIdentifier;
        self.channel = channel;
        self.state = clientState;
    }


    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.stateUpdateCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/uuid/%@/data?callback=%@_%@&state=%@%@%@&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString],
            (!self.channel.isChannelGroup ? [self.channel escapedName] : @"."),
            [self.clientIdentifier pn_percentEscapedString], [self callbackMethodName], self.shortIdentifier,
            [[PNJSONSerialization stringFromJSONObject:self.state] pn_percentEscapedString],
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
