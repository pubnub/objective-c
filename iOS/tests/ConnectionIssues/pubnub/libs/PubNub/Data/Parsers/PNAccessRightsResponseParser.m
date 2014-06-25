//
//  PNAccessRightsResponseParser.m
//  pubnub
//
//  Created by Sergey Mamontov on 10/28/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNAccessRightsResponseParser+Protected.h"
#import "PNAccessRightsInformation+Protected.h"
#import "PNAccessRightsCollection+Protected.h"
#import "PNResponse.h"
#import "PNChannel.h"
#import "PNHelper.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel access right change response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Structures

// Structure describes list of available access levels
struct PNAccessLevelsStruct {

    // Used to identify application wide access level.
    __unsafe_unretained NSString *application;

    // Used to identify channel wide access level.
    __unsafe_unretained NSString *channel;

    // Used to identify concrete user access level.
    __unsafe_unretained NSString *user;
};

struct PNAccessLevelsStruct PNAccessLevels = {

    .application = @"subkey",
    .channel = @"channel",
    .user = @"user"
};

#pragma mark - Private interface declaration

@interface PNAccessRightsResponseParser ()


#pragma mark - Properties

/**
 Stores reference on prepared and parsed access rights information instance
 */
@property (nonatomic, strong) PNAccessRightsCollection *information;


#pragma mark - Instance methods

/**
 * Returns reference on initialized parser for concrete response
 */
- (id)initWithResponse:(PNResponse *)response;

/**
 Parse \a 'channel' access rights information from provided dictionary.

 @param channelInformationDictionary
 \a NSDictionary instance which hold information from server about access rights configuration for channel(s).
 */
- (void)parseChannelAccessInformationFromDictionary:(NSDictionary *)channelInformationDictionary;

/**
 Parse \a 'user' access rights information from provided dictionary.

 @param channelInformationDictionary
 \a NSDictionary instance which hold information from server about access rights configuration for user(s).
 */
- (void)parseClientAccessInformationFromDictionary:(NSDictionary *)clientsInformationDictionary;


#pragma mark - Misc methods

- (PNAccessRightsLevel)accessRightsLevelFromString:(NSString *)stringifiedAccessLevel;
- (PNAccessRights)accessRightsFromDictionary:(NSDictionary *)accessRightsInformation;

@end


#pragma mark - Public interface implementation

@implementation PNAccessRightsResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {
    
    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);
    
    
    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {

    // Checking base requirement about payload data type.
    __block BOOL conforms = [response.response isKindOfClass:[NSDictionary class]];

    // Checking base components
    if (conforms) {

        NSDictionary *accessInformation = response.response;
        id accessLevel = [accessInformation valueForKeyPath:kPNAccessLevelKey];
        id accessPeriod = [accessInformation valueForKeyPath:kPNAccessRightsPeriodKey];
        id readRights = [accessInformation valueForKeyPath:kPNReadAccessRightStateKey];
        id writeRights = [accessInformation valueForKeyPath:kPNWriteAccessRightStateKey];
        id subscribeKey = [accessInformation valueForKeyPath:kPNApplicationIdentifierKey];

        conforms = ((conforms && accessLevel) ? [accessLevel isKindOfClass:[NSString class]] : conforms);
        conforms = ((conforms && accessPeriod) ? [accessPeriod isKindOfClass:[NSNumber class]] : conforms);
        conforms = ((conforms && readRights) ? [readRights isKindOfClass:[NSNumber class]] : conforms);
        conforms = ((conforms && writeRights) ? [writeRights isKindOfClass:[NSNumber class]] : conforms);
        conforms = ((conforms && subscribeKey) ? [subscribeKey isKindOfClass:[NSString class]] : conforms);
    }

    if (conforms) {

        NSDictionary *accessInformation = response.response;

        id channels = [accessInformation valueForKeyPath:kPNAccessChannelsKey];
        id clients = [accessInformation valueForKeyPath:kPNAccessChannelsAuthorizationKey];
        conforms = ((conforms && channels) ? [channels isKindOfClass:[NSDictionary class]] : conforms);
        conforms = ((conforms && clients) ? [clients isKindOfClass:[NSDictionary class]] : conforms);

        void(^checkClients)(NSDictionary *) = ^(NSDictionary *clientsData) {

            if (clientsData && conforms) {

                conforms = ([clientsData isKindOfClass:[NSDictionary class]]);
                if (conforms) {

                    NSString *channelName = [clientsData valueForKeyPath:kPNAccessChannelKey];
                    __block id accessPeriod = [clientsData valueForKeyPath:kPNAccessRightsPeriodKey];
                    conforms = ((conforms && channelName) ? [channelName isKindOfClass:[NSString class]] : conforms);
                    conforms = ((conforms && accessPeriod) ? [accessPeriod isKindOfClass:[NSNumber class]] : conforms);

                    [clients enumerateKeysAndObjectsUsingBlock:^(id clientAuthorizationKey, id clientInformation,
                                                                 BOOL *clientInformationEnumeratorStop) {

                        conforms = (conforms ? (clientAuthorizationKey && [clientAuthorizationKey isKindOfClass:[NSString class]]) : conforms);
                        conforms = (conforms ? [clientInformation isKindOfClass:[NSDictionary class]] : conforms);
                        if (conforms){

                            accessPeriod = [clientInformation valueForKeyPath:kPNAccessRightsPeriodKey];
                            conforms = ((conforms && accessPeriod) ? [accessPeriod isKindOfClass:[NSNumber class]] : conforms);

                            id readRights = [clientInformation valueForKeyPath:kPNReadAccessRightStateKey];
                            id writeRights = [clientInformation valueForKeyPath:kPNWriteAccessRightStateKey];
                            conforms = ((conforms && readRights) ? [readRights isKindOfClass:[NSNumber class]] : conforms);
                            conforms = ((conforms && writeRights) ? [writeRights isKindOfClass:[NSNumber class]] : conforms);
                        }

                        *clientInformationEnumeratorStop = !conforms;
                    }];
                }
            }
        };

        // Checking whether found information for channel access rights or not.
        if (conforms && channels) {

            [(NSDictionary *)channels enumerateKeysAndObjectsUsingBlock:^(id channelName, id channelInformation,
                                                                         BOOL *channelInformationEnumeratorStop) {

                conforms = (conforms ? (channelName && [channelName isKindOfClass:[NSString class]]) : conforms);
                conforms = (conforms ? [channelInformation isKindOfClass:[NSDictionary class]] : conforms);
                if (conforms){

                    id accessLevel = [channelInformation valueForKeyPath:kPNAccessLevelKey];
                    id accessPeriod = [channelInformation valueForKeyPath:kPNAccessRightsPeriodKey];
                    conforms = ((conforms && accessLevel) ? [accessLevel isKindOfClass:[NSString class]] : conforms);
                    conforms = ((conforms && accessPeriod) ? [accessPeriod isKindOfClass:[NSNumber class]] : conforms);
                    checkClients([channelInformation valueForKeyPath:kPNAccessChannelsAuthorizationKey]);
                }
                *channelInformationEnumeratorStop = !conforms;
            }];
        }
        else if (conforms && clients) {

            checkClients(clients);
        }
    }


    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {
    
    // Check whether initialization was successful or not
    if ((self = [super init])) {
        
        NSDictionary *accessInformation = response.response;

        // Fetch access level to which changes has been applied / received
        PNAccessRightsLevel accessLevel = [self accessRightsLevelFromString:[accessInformation valueForKeyPath:kPNAccessLevelKey]];

        // Fetch access rights period (time during which they will be valid)
        NSUInteger accessPeriod = [[accessInformation valueForKeyPath:kPNAccessRightsPeriodKey] unsignedIntegerValue];

        // Fetch granted access rights.
        __block PNAccessRights accessRights = [self accessRightsFromDictionary:accessInformation];

        // Fetch application identifier (\a 'subscribe' key).
        NSString *application = [accessInformation valueForKeyPath:kPNApplicationIdentifierKey];

        self.information = [PNAccessRightsCollection accessRightsCollectionForApplication:application
                                                                     andAccessRightsLevel:accessLevel];

        if (accessLevel == PNApplicationAccessRightsLevel) {

            // Construct \a root of the access rights tree.
            PNAccessRightsInformation *applicationInformation = [PNAccessRightsInformation accessRightsInformationForLevel:accessLevel
                                                                          rights:accessRights applicationKey:application
                                                                      forChannel:nil client:nil accessPeriod:accessPeriod];
            [self.information storeApplicationAccessRightsInformation:applicationInformation];


            // Checking whether \a 'channel' level access rights has been changes as well or not.
            if ([accessInformation valueForKeyPath:kPNAccessChannelsKey] != nil &&
                [(NSArray *)[accessInformation valueForKeyPath:kPNAccessChannelsKey] count]) {

                [self parseChannelAccessInformationFromDictionary:accessInformation];
            }
        }
        else if (accessLevel == PNChannelAccessRightsLevel) {

            [self parseChannelAccessInformationFromDictionary:accessInformation];
        }
        else {

            [self parseClientAccessInformationFromDictionary:accessInformation];
        }
    }
    
    
    return self;
}

- (void)parseChannelAccessInformationFromDictionary:(NSDictionary *)channelInformationDictionary {

    // Fetch access rights period (time during which they will be valid)
    __block NSUInteger accessPeriod = [[channelInformationDictionary valueForKeyPath:kPNAccessRightsPeriodKey] unsignedIntegerValue];

    // Fetch granted access rights.
    __block PNAccessRights accessRights = PNUnknownAccessRights;

    NSDictionary *channelsInformation = [channelInformationDictionary valueForKeyPath:kPNAccessChannelsKey];
    [channelsInformation enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelInformation,
                                                             BOOL *channelInformationEnumeratorStop) {

        PNChannel *channel = [PNChannel channelWithName:[channelName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // Fetch access period.
        if ([channelInformation valueForKey:kPNAccessRightsPeriodKey]) {
            
            accessPeriod = [[channelInformation valueForKey:kPNAccessRightsPeriodKey] unsignedIntegerValue];
        }

        // Fetch granted access rights.
        accessRights = [self accessRightsFromDictionary:channelInformation];


        [self.information storeChannelAccessRightsInformation:[PNAccessRightsInformation accessRightsInformationForLevel:PNChannelAccessRightsLevel
                                                                        rights:accessRights applicationKey:self.information.applicationKey
                                                                    forChannel:channel client:nil accessPeriod:accessPeriod]];

        // Checking whether \a 'channel' level access rights has been changes as well or not.
        if ([channelInformation valueForKeyPath:kPNAccessChannelsAuthorizationKey] != nil &&
            [(NSDictionary *)[channelInformation valueForKeyPath:kPNAccessChannelsAuthorizationKey] count]) {

            NSDictionary *clients = (NSDictionary *)[channelInformation valueForKeyPath:kPNAccessChannelsAuthorizationKey];
            [clients enumerateKeysAndObjectsUsingBlock:^(NSString *clientAuthorizationKey,
                                                         NSDictionary *clientAccessInformation,
                                                         BOOL *clientsAuthorizationKeysEnumeratorStop) {
                
                // Fetch access period.
                accessPeriod = [[clientAccessInformation valueForKey:kPNAccessRightsPeriodKey] unsignedIntegerValue];

                // Fetch granted access rights.
                accessRights = [self accessRightsFromDictionary:clientAccessInformation];

                [self.information storeClientAccessRightsInformation:[PNAccessRightsInformation accessRightsInformationForLevel:PNUserAccessRightsLevel
                                                                                                rights:accessRights applicationKey:self.information.applicationKey
                                                                                            forChannel:channel client:clientAuthorizationKey
                                                                                          accessPeriod:accessPeriod]
                                                          forChannel:channel];
            }];
        }
    }];
}

- (void)parseClientAccessInformationFromDictionary:(NSDictionary *)clientsInformationDictionary {

    // Fetch access rights period (time during which they will be valid)
    __block NSUInteger accessPeriod = [[clientsInformationDictionary valueForKeyPath:kPNAccessRightsPeriodKey] unsignedIntegerValue];

    // Fetch granted access rights.
    __block PNAccessRights accessRights = PNUnknownAccessRights;

    NSString *channelName = [clientsInformationDictionary valueForKeyPath:kPNAccessChannelKey];
    PNChannel *channel = [PNChannel channelWithName:[channelName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSDictionary *clients = [clientsInformationDictionary valueForKeyPath:kPNAccessClientAuthorizationKey];
    
    [clients enumerateKeysAndObjectsUsingBlock:^(NSString *clientAuthorizationKey, NSDictionary *clientInformation, BOOL *clientInformationEnumeratorStop) {
        
        // Fetch access period.
        if ([clientInformation valueForKey:kPNAccessRightsPeriodKey]) {
            
            accessPeriod = [[clientInformation valueForKey:kPNAccessRightsPeriodKey] unsignedIntegerValue];
        }

        // Fetch granted access rights.
        accessRights = [self accessRightsFromDictionary:clientInformation];

        [self.information storeClientAccessRightsInformation:[PNAccessRightsInformation accessRightsInformationForLevel:PNUserAccessRightsLevel
                                                                                        rights:accessRights applicationKey:self.information.applicationKey
                                                                                    forChannel:channel client:clientAuthorizationKey
                                                                                  accessPeriod:accessPeriod]
                                                  forChannel:channel];
    }];
}

- (id)parsedData {
    
    return self.information;
}


#pragma mark - Misc methods

- (PNAccessRightsLevel)accessRightsLevelFromString:(NSString *)stringifiedAccessLevel {

    PNAccessRightsLevel level = PNApplicationAccessRightsLevel;

    if ([stringifiedAccessLevel isEqualToString:PNAccessLevels.channel]) {

        level = PNChannelAccessRightsLevel;
    }
    else if ([stringifiedAccessLevel isEqualToString:PNAccessLevels.user]) {

        level = PNUserAccessRightsLevel;
    }


    return level;
}

- (PNAccessRights)accessRightsFromDictionary:(NSDictionary *)accessRightsInformation {

    unsigned long accessRights = PNNoAccessRights;

    NSNumber *readRightState = [accessRightsInformation objectForKey:kPNReadAccessRightStateKey];
    NSNumber *writeRightState = [accessRightsInformation objectForKey:kPNWriteAccessRightStateKey];

    if (readRightState != nil && [readRightState intValue] != 0) {
        
        [PNBitwiseHelper addTo:&accessRights bit:PNReadAccessRight];
    }

    if (writeRightState != nil && [writeRightState intValue] != 0) {
        
        [PNBitwiseHelper addTo:&accessRights bit:PNWriteAccessRight];
    }

    if ([PNBitwiseHelper is:accessRights containsBits:PNReadAccessRight, PNWriteAccessRight, BITS_LIST_TERMINATOR]) {

        [PNBitwiseHelper removeFrom:&accessRights bit:PNNoAccessRights];
    }


    return (PNAccessRights)accessRights;
}

#pragma mark -


@end
