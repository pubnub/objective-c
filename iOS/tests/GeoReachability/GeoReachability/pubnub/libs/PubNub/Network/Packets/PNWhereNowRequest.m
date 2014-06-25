//
//  PNWhereNowRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNWhereNowRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"


#pragma mark Private interface declaration

@interface PNWhereNowRequest ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *clientIdentifier;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNWhereNowRequest


#pragma mark - Class methods

+ (PNWhereNowRequest *)whereNowRequestForIdentifier:(NSString *)clientIdentifier {

    return [[self alloc] initWithIdentifier:clientIdentifier];
}


#pragma mark - Instance methods

- (id)initWithIdentifier:(NSString *)clientIdentifier {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.clientIdentifier = clientIdentifier;
    }


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.participantChannelsCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/uuid/%@?callback=%@_%@%@&pnsdk=%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                                      [self.clientIdentifier percentEscapedString], [self callbackMethodName],
                                      self.shortIdentifier,
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
