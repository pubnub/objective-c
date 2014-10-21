/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNHereNowResponseParser.h"
#import "PNHereNowResponseParser+Protected.h"
#import "PNHereNow+Protected.h"
#import "PNChannel+Protected.h"
#import "PNClient+Protected.h"
#import "PNResponse.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub here now response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Public interface methods

@implementation PNHereNowResponseParser


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

        NSDictionary *responseData = response.response;
        id channels = [responseData objectForKey:kPNResponseChannelsKey];
        conforms = (channels ? [channels isKindOfClass:[NSDictionary class]] : conforms);
        if (!channels) {

            id identifiers = [responseData objectForKey:kPNResponseUUIDKey];
            id occupancyCount = [responseData objectForKey:kPNResponseOccupancyKey];
            conforms = ((conforms && identifiers) ? [identifiers isKindOfClass:[NSArray class]] : conforms);
            conforms = ((conforms && occupancyCount) ? [occupancyCount isKindOfClass:[NSNumber class]] : conforms);
        }
        else {

            [channels enumerateKeysAndObjectsUsingBlock:^(id channelName, id channelParticipantsInformation,
                                                          BOOL *channelNamesEnumeratorStop) {

                conforms = (conforms ? [channelName isKindOfClass:[NSString class]] : conforms);
                conforms = (conforms ? [channelParticipantsInformation isKindOfClass:[NSDictionary class]] : conforms);
                if (conforms) {

                    id identifiers = [channelParticipantsInformation objectForKey:kPNResponseUUIDKey];
                    id occupancyCount = [channelParticipantsInformation objectForKey:kPNResponseOccupancyKey];
                    conforms = ((conforms && identifiers) ? [identifiers isKindOfClass:[NSArray class]] : conforms);
                    conforms = ((conforms && occupancyCount) ? [occupancyCount isKindOfClass:[NSNumber class]] : conforms);

                    [identifiers enumerateObjectsUsingBlock:^(id clientInformation, NSUInteger clientInformationIdx,
                                                              BOOL *clientInformationEnumerator) {

                        id clientIdentifier = nil;

                        // Looks like we received detailed information about client.
                        if ([clientInformation respondsToSelector:@selector(allKeys)]) {

                            clientIdentifier = [clientInformation valueForKey:kPNResponseClientUUIDKey];
                        }
                        // Plain client identifier is received.
                        else {

                            clientIdentifier = clientInformation;
                        }
                        conforms = ((conforms && clientIdentifier) ? [clientIdentifier isKindOfClass:[NSString class]] : conforms);
                    }];
                }

                *channelNamesEnumeratorStop = !conforms;
            }];
        }
    }


    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSDictionary *responseData = response.response;

        self.hereNow = [PNHereNow new];
        NSDictionary *channels = [responseData objectForKey:kPNResponseChannelsKey];
        
        // If there is no "channels" node in response, then probably this is response for single channel requested
        // by user (we must ensure that there is only one channel in request)
        if (!channels && [(NSArray *)response.additionalData count] == 1) {

            // Retrieve reference on channel for which request has been made
            PNChannel *channel = [(NSArray *)response.additionalData lastObject];
            
            // Ensure that channel doesn't represent list channels via channel group feature
            if (channel && !channel.isChannelGroup) {
                
                NSArray *participantsList = [responseData objectForKey:kPNResponseUUIDKey];
                NSUInteger participantsCount = 0;
                if ([responseData objectForKey:kPNResponseOccupancyKey]) {
                    
                    participantsCount = [[responseData objectForKey:kPNResponseOccupancyKey] unsignedIntegerValue];
                }
                
                channels = @{channel.name:@{kPNResponseUUIDKey:(participantsList ? participantsList : @[]),
                                            kPNResponseOccupancyKey: @(participantsCount)}};
            }
        }
        [channels enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelParticipantsInformation,
                                                      BOOL *channelNamesEnumeratorStop) {

            @autoreleasepool {
                
                PNChannel *targetChannel = [PNChannel channelWithName:channelName];
                NSUInteger participantsCount = [[channelParticipantsInformation objectForKey:kPNResponseOccupancyKey] unsignedIntValue];
                NSArray *participantsInChannel = [self clientsFromData:[channelParticipantsInformation objectForKey:kPNResponseUUIDKey]
                                                            forChannel:targetChannel];
                [participantsInChannel enumerateObjectsUsingBlock:^(PNClient *client, NSUInteger clientIdx, BOOL *clientEnumeratorStop) {
                    
                    [self.hereNow addParticipant:client forChannel:targetChannel];
                }];
                
                [self.hereNow setParticipantsCount:MAX([participantsInChannel count], participantsCount) forChannel:targetChannel];
            }
        }];
    }


    return self;
}

- (id)parsedData {

    return self.hereNow;
}

#pragma mark - Misc methods

- (NSArray *)clientsFromData:(NSArray *)clientsInformation forChannel:(PNChannel *)channel {

    NSMutableArray *clients = [NSMutableArray array];
    [clientsInformation enumerateObjectsUsingBlock:^(id clientInformation, NSUInteger clientInformationIdx,
                                                     BOOL *clientInformationEnumerator) {

        [clients addObject:[self clientFromData:clientInformation forChannel:channel]];
    }];


    return clients;
}

- (PNClient *)clientFromData:(id)clientInformation forChannel:(PNChannel *)channel {

    NSString *clientIdentifier = nil;
    NSDictionary *state = nil;

    // Looks like we received detailed information about client.
    if ([clientInformation respondsToSelector:@selector(allKeys)]) {

        clientIdentifier = [clientInformation valueForKey:kPNResponseClientUUIDKey];
        state = [clientInformation valueForKey:kPNResponseClientStateKey];
    }
    // Plain client identifier is received.
    else {

        clientIdentifier = clientInformation;
    }
    

    return [PNClient clientForIdentifier:clientIdentifier channel:channel andData:state];
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <presence information: %@>", NSStringFromClass([self class]), self,
            self.hereNow];
}

#pragma mark -


@end
