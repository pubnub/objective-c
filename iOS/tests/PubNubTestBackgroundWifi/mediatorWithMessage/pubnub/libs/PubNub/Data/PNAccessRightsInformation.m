//
//  PNAccessRightsInformation.m
//  pubnub
//
//  Created by Sergey Mamontov on 11/3/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNAccessRightsInformation+Protected.h"
#import "PNAccessRightOptions+Protected.h"
#import "PNHelper.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel access right information data object must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Public interface implementation

@implementation PNAccessRightsInformation


#pragma mark - Class methods

+ (PNAccessRightsInformation *)accessRightsInformationForLevel:(PNAccessRightsLevel)level rights:(PNAccessRights)rights
                                                applicationKey:(NSString *)subscriptionKey forChannel:(PNChannel *)channel
                                                        client:(NSString *)clientAuthorizationKey
                                                  accessPeriod:(NSUInteger)accessPeriodDuration {

    return [[self alloc] initWithAccessLevel:level rights:rights applicationKey:subscriptionKey channel:channel
                                      client:clientAuthorizationKey accessPeriod:accessPeriodDuration];
}

+ (NSArray *)accessRightsInformationForLevel:(PNAccessRightsLevel)accessRightsLevel fromList:(NSArray *)accessRightsInformation {

    return [accessRightsInformation filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.level = %d", accessRightsLevel]];
}


#pragma mark - Instance methods

- (id)initWithAccessLevel:(PNAccessRightsLevel)level rights:(PNAccessRights)rights
           applicationKey:(NSString *)subscriptionKey channel:(PNChannel *)channel
                   client:(NSString *)clientAuthorizationKey accessPeriod:(NSUInteger)accessPeriodDuration {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.level = level;
        self.rights = rights;
        self.subscriptionKey = subscriptionKey;
        self.channel = channel;
        self.authorizationKey = clientAuthorizationKey;
        self.accessPeriodDuration = accessPeriodDuration;
    }


    return self;
}

- (BOOL)hasReadRight {

    return [PNBitwiseHelper is:self.rights containsBit:PNReadAccessRight];
}

- (BOOL)hasWriteRight {
    
    return [PNBitwiseHelper is:self.rights containsBit:PNWriteAccessRight];
}

- (BOOL)hasAllRights {

    return [PNBitwiseHelper is:self.rights strictly:YES containsBits:PNReadAccessRight, PNWriteAccessRight, BITS_LIST_TERMINATOR];
}

- (BOOL)isAllRightsRevoked {

    return ![self hasAllRights];
}

- (NSString *)description {

    NSMutableString *description = [NSMutableString stringWithFormat:@"%@ (%p) <",
                                                    NSStringFromClass([self class]), self];

    NSString *level = @"application";
    if (self.level == PNChannelAccessRightsLevel) {

        level = @"channel";
    }
    else if (self.level == PNUserAccessRightsLevel) {

        level = @"user";
    }
    [description appendFormat:@"level: %@;", level];

    NSString *rights = @"none (revoked)";
    if ([self hasReadRight] || [self hasWriteRight]) {

        rights = [self hasReadRight] ? @"read" : @"";
        if ([self hasWriteRight]) {

            rights = ([rights length] > 0) ? [rights stringByAppendingString:@" / write"] : @"write";
        }
    }
    [description appendFormat:@" rights: %@;", rights];

    [description appendFormat:@" application: %@;", self.subscriptionKey];

    if (self.level == PNChannelAccessRightsLevel) {

        [description appendFormat:@" channel: %@;", self.channel];
    }
    else if (self.level == PNUserAccessRightsLevel) {

        [description appendFormat:@" user: %@;", self.authorizationKey];
        [description appendFormat:@" channel: %@;", self.channel];
    }

    [description appendFormat:@" access period duration: %lu>", (unsigned long)self.accessPeriodDuration];


    return description;
}

#pragma mark -


@end
