//
//  PNAccessRightsAuditRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 11/9/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNAccessRightsAuditRequest.h"
#import "PNAccessRightOptions+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "PNChannel+Protected.h"
#import "NSString+PNAddition.h"
#import "PNConfiguration.h"
#import "PNHelper.h"
#import "PNMacro.h"


#pragma mark Private interface declaration

@interface PNAccessRightsAuditRequest ()


#pragma mark - Properties

/**
 Stores reference on timestamp which should be used with request.
 */
@property (nonatomic, assign) NSUInteger requestTimestamp;

@property (nonatomic, strong) PNAccessRightOptions *accessRightOptions;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, copy) NSString *publishKey;
@property (nonatomic, copy) NSString *secretKey;


#pragma mark - Instance methods

/**
 Generate signature which allow server to ensure that PAM command arrived from trusted and authorized client.
 Signature composed from specified set of parameters ordered by parameter names in alphanumeric order before
 signature generation.

 @return SHA-HMAC256 signature for PAM request.
 */
- (NSString *)PAMSignature;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNAccessRightsAuditRequest


#pragma mark - Class methods

+ (PNAccessRightsAuditRequest *)accessRightsAuditRequestForChannels:(NSArray *)channels
                                                         andClients:(NSArray *)clientsAccessKeys {

    return [[self alloc] initWithChannels:channels andClients:clientsAccessKeys];
}


#pragma mark - Instance methods

- (id)initWithChannels:(NSArray *)channels andClients:(NSArray *)clientsAccessKeys {

    // Check whether initialization was successful or not.
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.accessRightOptions = [PNAccessRightOptions accessRightOptionsForApplication:nil withRights:PNUnknownAccessRights
                                                                                channels:channels clients:clientsAccessKeys
                                                                            accessPeriod:0];

    }


    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.accessRightOptions.applicationKey = configuration.subscriptionKey;
    self.subscriptionKey = configuration.subscriptionKey;
    self.publishKey = configuration.publishKey;
    self.secretKey = configuration.secretKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)PAMSignature {

    NSMutableArray *parameters = [NSMutableArray array];
    NSMutableString *signature = [NSMutableString stringWithFormat:@"%@\n%@\naudit\n", self.subscriptionKey, self.publishKey];

    if ([self.accessRightOptions.clientsAuthorizationKeys count] > 0) {

        NSString *authorizationKey = [self.accessRightOptions.clientsAuthorizationKeys lastObject];
        if ([self.accessRightOptions.clientsAuthorizationKeys count] > 1) {

            authorizationKey = [self.accessRightOptions.clientsAuthorizationKeys componentsJoinedByString:@","];
        }

        [parameters addObject:[NSString stringWithFormat:@"auth=%@", [authorizationKey pn_percentEscapedString]]];
    }
    [parameters addObject:[NSString stringWithFormat:@"callback=%@_%@", [self callbackMethodName], self.shortIdentifier]];

    if ([self.accessRightOptions.channels count] > 0) {

        NSString *channel = [[self.accessRightOptions.channels lastObject] name];
        BOOL isChannelGroupProvided = ((PNChannel *)[self.accessRightOptions.channels lastObject]).isChannelGroup;
        if ([self.accessRightOptions.channels count] > 1) {

            channel = [[self.accessRightOptions.channels valueForKey:@"name"] componentsJoinedByString:@","];
        }
        [parameters addObject:[NSString stringWithFormat:@"%@=%@", (!isChannelGroupProvided ? @"channel" : @"channel-group"),
                               [channel pn_percentEscapedString]]];
    }
    
    [parameters addObject:[NSString stringWithFormat:@"pnsdk=%@", [self clientInformationField]]];
    [parameters addObject:[NSString stringWithFormat:@"timestamp=%lu", (unsigned long)[self requestTimestamp]]];

    [signature appendString:[parameters componentsJoinedByString:@"&"]];
    [signature setString:[PNEncryptionHelper HMACSHA256FromString:signature withKey:self.secretKey]];
    [signature replaceOccurrencesOfString:@"+" withString:@"-" options:(NSStringCompareOptions)0
                                    range:NSMakeRange(0, [signature length])];
    [signature replaceOccurrencesOfString:@"/" withString:@"_" options:(NSStringCompareOptions)0
                                    range:NSMakeRange(0, [signature length])];


    return [signature pn_percentEscapedString];
}

- (NSUInteger)requestTimestamp {

    if (_requestTimestamp == 0) {

        _requestTimestamp = (NSUInteger)[[NSDate date] timeIntervalSince1970];
    }


    return _requestTimestamp;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.channelAccessRightsAuditCallback;
}

- (NSString *)resourcePath {

    NSString *authorizationKey = [self.accessRightOptions.clientsAuthorizationKeys lastObject];
    if ([self.accessRightOptions.clientsAuthorizationKeys count] > 1) {

        authorizationKey = [self.accessRightOptions.clientsAuthorizationKeys componentsJoinedByString:@","];
    }

    NSString *channel = [[self.accessRightOptions.channels lastObject] name];
    BOOL isChannelGroupProvided = ((PNChannel *)[self.accessRightOptions.channels lastObject]).isChannelGroup;
    if ([self.accessRightOptions.channels count] > 1) {

        channel = [[self.accessRightOptions.channels valueForKey:@"name"] componentsJoinedByString:@","];
    }


    return [NSString stringWithFormat:@"/v1/auth/audit/sub-key/%@?%@callback=%@_%@%@&pnsdk=%@&timestamp=%lu&signature=%@",
            [self.subscriptionKey pn_percentEscapedString],
            (authorizationKey ? [NSString stringWithFormat:@"auth=%@&", [authorizationKey pn_percentEscapedString]] : @""),
            [self callbackMethodName], self.shortIdentifier,
            (channel ? [NSString stringWithFormat:@"&%@=%@", (!isChannelGroupProvided ? @"channel" : @"channel-group"),
                       [channel pn_percentEscapedString]] : @""),
            [self clientInformationField], (unsigned long)[self requestTimestamp], [self PAMSignature]];
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
