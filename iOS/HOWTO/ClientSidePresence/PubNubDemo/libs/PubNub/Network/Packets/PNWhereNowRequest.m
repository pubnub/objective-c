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
#import "PNConfiguration.h"
#import "PNMacro.h"


#pragma mark Private interface declaration

@interface PNWhereNowRequest ()


#pragma mark - Properties

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

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

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.participantChannelsCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/uuid/%@?callback=%@_%@%@&pnsdk=%@",
                                      [self.subscriptionKey pn_percentEscapedString],
                                      [self.clientIdentifier pn_percentEscapedString], [self callbackMethodName],
                                      self.shortIdentifier,
                                      ([self authorizationField] ? [NSString stringWithFormat:@"&%@",
                                                                                              [self authorizationField]] : @""),
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
