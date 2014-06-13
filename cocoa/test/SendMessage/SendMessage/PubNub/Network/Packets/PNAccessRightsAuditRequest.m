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
#import "NSString+PNAddition.h"
#import "PubNub+Protected.h"
#import "PNHelper.h"


#pragma mark Private interface declaration

@interface PNAccessRightsAuditRequest ()


#pragma mark - Properties

/**
 Stores reference on timestamp which should be used with request.
 */
@property (nonatomic, assign) NSUInteger requestTimestamp;

@property (nonatomic, strong) PNAccessRightOptions *accessRightOptions;


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
        self.accessRightOptions = [PNAccessRightOptions accessRightOptionsForApplication:[PubNub sharedInstance].configuration.subscriptionKey
                                                                              withRights:PNUnknownAccessRights
                                                                                channels:channels
                                                                                 clients:clientsAccessKeys
                                                                            accessPeriod:0];

    }


    return self;
}

- (NSString *)PAMSignature {

    NSMutableArray *parameters = [NSMutableArray array];
    NSMutableString *signature = [NSMutableString stringWithFormat:@"%@\n%@\naudit\n",
                                  [PubNub sharedInstance].configuration.subscriptionKey,
                                  [PubNub sharedInstance].configuration.publishKey];

    if ([self.accessRightOptions.clientsAuthorizationKeys count] > 0) {

        NSString *authorizationKey = [self.accessRightOptions.clientsAuthorizationKeys lastObject];
        if ([self.accessRightOptions.clientsAuthorizationKeys count] > 1) {

            authorizationKey = [self.accessRightOptions.clientsAuthorizationKeys componentsJoinedByString:@","];
        }

        [parameters addObject:[NSString stringWithFormat:@"auth=%@", [authorizationKey percentEscapedString]]];
    }
    [parameters addObject:[NSString stringWithFormat:@"callback=%@_%@", [self callbackMethodName], self.shortIdentifier]];

    if ([self.accessRightOptions.channels count] > 0) {

        NSString *channel = [[self.accessRightOptions.channels lastObject] name];
        if ([self.accessRightOptions.channels count] > 1) {

            channel = [[self.accessRightOptions.channels valueForKey:@"name"] componentsJoinedByString:@","];
        }
        [parameters addObject:[NSString stringWithFormat:@"channel=%@", [channel percentEscapedString]]];
    }
    
    [parameters addObject:[NSString stringWithFormat:@"pnsdk=%@", [self clientInformationField]]];
    [parameters addObject:[NSString stringWithFormat:@"timestamp=%lu", (unsigned long)[self requestTimestamp]]];

    [signature appendString:[parameters componentsJoinedByString:@"&"]];
    [signature setString:[PNEncryptionHelper HMACSHA256FromString:signature withKey:[PubNub sharedInstance].configuration.secretKey]];
    [signature replaceOccurrencesOfString:@"+" withString:@"-" options:(NSStringCompareOptions)0
                                    range:NSMakeRange(0, [signature length])];
    [signature replaceOccurrencesOfString:@"/" withString:@"_" options:(NSStringCompareOptions)0
                                    range:NSMakeRange(0, [signature length])];


    return [signature percentEscapedString];
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
    if ([self.accessRightOptions.channels count] > 1) {

        channel = [[self.accessRightOptions.channels valueForKey:@"name"] componentsJoinedByString:@","];
    }


    return [NSString stringWithFormat:@"/v1/auth/audit/sub-key/%@?%@callback=%@_%@%@&pnsdk=%@&timestamp=%lu&signature=%@",
                    [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                    (authorizationKey ? [NSString stringWithFormat:@"auth=%@&", [authorizationKey percentEscapedString]] : @""),
                    [self callbackMethodName], self.shortIdentifier,
                    (channel ? [NSString stringWithFormat:@"&channel=%@", [channel percentEscapedString]] : @""),
                    [self clientInformationField], (unsigned long)[self requestTimestamp], [self PAMSignature]];
}

- (NSString *)debugResourcePath {
    
    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];
    
    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
