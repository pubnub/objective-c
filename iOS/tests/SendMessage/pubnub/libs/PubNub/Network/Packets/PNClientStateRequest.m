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
#import "PubNub+Protected.h"


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

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.stateRetrieveCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/uuid/%@?callback=%@_%@%@&pnsdk=%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                                      [self.channel escapedName], [self.clientIdentifier percentEscapedString],
                                      [self callbackMethodName], self.shortIdentifier,
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
