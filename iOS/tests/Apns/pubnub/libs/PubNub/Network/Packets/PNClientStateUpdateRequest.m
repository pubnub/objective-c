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

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.stateUpdateCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/uuid/%@/data?callback=%@_%@&state=%@%@&pnsdk=%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                                      [self.channel escapedName], [self.clientIdentifier percentEscapedString],
                                      [self callbackMethodName], self.shortIdentifier,
                                      [[PNJSONSerialization stringFromJSONObject:self.state] percentEscapedString],
                                      ([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@""),
                                      [self clientInformationField]];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
