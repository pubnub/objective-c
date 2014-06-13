//
//  PNChangeAccessRightsRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 10/23/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNChangeAccessRightsRequest.h"
#import "PNAccessRightOptions+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "NSString+PNAddition.h"
#import "PNChannel+Protected.h"
#import "PubNub+Protected.h"
#import "PNHelper.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel access right change request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Private interface declaration

@interface PNChangeAccessRightsRequest ()


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

@implementation PNChangeAccessRightsRequest


#pragma mark - Class methods

+ (PNChangeAccessRightsRequest *)changeAccessRightsRequestForChannels:(NSArray *)channels
                                                         accessRights:(PNAccessRights)accessRights
                                                              clients:(NSArray *)clientsAuthorizationKey
                                                            forPeriod:(NSInteger)accessPeriod {

    return [[self alloc] initWithChannels:channels accessRights:accessRights clients:clientsAuthorizationKey
                                   period:accessPeriod];
}


#pragma mark - Instance methods

- (id)initWithChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                                                clients:(NSArray *)clientsAuthorizationKey period:(NSInteger)accessPeriod {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.accessRightOptions = [PNAccessRightOptions accessRightOptionsForApplication:[PubNub sharedInstance].configuration.subscriptionKey
                                                                              withRights:accessRights
                                                                                channels:channels
                                                                                 clients:clientsAuthorizationKey
                                                                            accessPeriod:accessPeriod];

    }


    return self;
}

- (NSString *)PAMSignature {

    NSMutableArray *parameters = [NSMutableArray array];
    NSMutableString *signature = [NSMutableString stringWithFormat:@"%@\n%@\ngrant\n",
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
    [parameters addObject:[NSString stringWithFormat:@"r=%@",
                           [PNBitwiseHelper is:self.accessRightOptions.rights containsBit:PNReadAccessRight] ? @"1" : @"0"]];
    [parameters addObject:[NSString stringWithFormat:@"timestamp=%lu", (unsigned long)[self requestTimestamp]]];
    [parameters addObject:[NSString stringWithFormat:@"ttl=%lu", (unsigned long)self.accessRightOptions.accessPeriodDuration]];
    [parameters addObject:[NSString stringWithFormat:@"w=%@",
                           [PNBitwiseHelper is:self.accessRightOptions.rights containsBit:PNWriteAccessRight] ? @"1" : @"0"]];

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

    return PNServiceResponseCallbacks.channelAccessRightsChangeCallback;
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


    return [NSString stringWithFormat:@"/v1/auth/grant/sub-key/%@?%@callback=%@_%@%@&pnsdk=%@&%@&timestamp=%lu&ttl=%lu&signature"
                                       "=%@&%@", [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                    (authorizationKey ? [NSString stringWithFormat:@"auth=%@&", [authorizationKey percentEscapedString]] : @""),
                    [self callbackMethodName], self.shortIdentifier,
                    (channel ? [NSString stringWithFormat:@"&channel=%@", [channel percentEscapedString]] : @""),
                    [self clientInformationField], [NSString stringWithFormat:@"r=%@", [PNBitwiseHelper is:self.accessRightOptions.rights
                                                                                               containsBit:PNReadAccessRight] ? @"1" : @"0"],
                    (unsigned long)[self requestTimestamp], (unsigned long)self.accessRightOptions.accessPeriodDuration,
                    [self PAMSignature], [NSString stringWithFormat:@"w=%@",
                    [PNBitwiseHelper is:self.accessRightOptions.rights containsBit:PNWriteAccessRight] ? @"1" : @"0"]];
}

- (NSString *)debugResourcePath {
    
    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];
    
    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
