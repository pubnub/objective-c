<<<<<<< HEAD
/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */
=======
//
//  PNHereNowResponseParser.h
// 
//
//  Created by moonlight on 1/15/13.
//
//

>>>>>>> fix-pt65153600

#import "PNHereNowResponseParser.h"
#import "PNHereNowResponseParser+Protected.h"
#import "PNHereNow+Protected.h"
<<<<<<< HEAD
#import "PNClient+Protected.h"
=======
>>>>>>> fix-pt65153600
#import "PNResponse.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub here now response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


<<<<<<< HEAD
#pragma mark Public interface methods
=======
#pragma mark Private interface methods

@interface PNHereNowResponseParser ()


#pragma mark - Properties

// Stores reference on object which stores information
// about who is in the channel and how many of them
@property (nonatomic, strong) PNHereNow *hereNow;


@end


#pragma mark - Public interface methods
>>>>>>> fix-pt65153600

@implementation PNHereNowResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSDictionary *responseData = response.response;

        self.hereNow = [PNHereNow new];
<<<<<<< HEAD
        NSDictionary *channels = [responseData objectForKey:kPNResponseChannelsKey];
        if (!channels) {

            PNChannel *channel = (PNChannel *)response.additionalData;
            channels = @{channel.name: @{kPNResponseUUIDKey: [responseData objectForKey:kPNResponseUUIDKey],
                                    kPNResponseOccupancyKey: [responseData objectForKey:kPNResponseOccupancyKey]
            }};
        }
        NSMutableArray *participants = [NSMutableArray array];
        [channels enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelParticipantsInformation,
                                                      BOOL *channelNamesEnumeratorStop) {

            NSMutableArray *participantsInChannel = [[self clientsFromData:[channelParticipantsInformation objectForKey:kPNResponseUUIDKey]
                                                                forChannel:[PNChannel channelWithName:channelName]] mutableCopy];

            NSUInteger participantsCount = [[channelParticipantsInformation objectForKey:kPNResponseOccupancyKey] unsignedIntValue];
            NSUInteger differenceInParticipantsCount = participantsCount - [participantsInChannel count];
            if (differenceInParticipantsCount > 0) {

                for (int i = 0; i < differenceInParticipantsCount; i++) {

                    [participantsInChannel addObject:[PNClient anonymousClientForChannel:[PNChannel channelWithName:channelName]]];
                }
            }
            [participants addObjectsFromArray:participantsInChannel];
        }];
        self.hereNow.participants = [NSArray arrayWithArray:participants];
        self.hereNow.participantsCount = [participants count];
=======
        self.hereNow.participants = [responseData objectForKey:kPNResponseUUIDKey];
        self.hereNow.participantsCount = [[responseData objectForKey:kPNResponseOccupancyKey] unsignedIntValue];
>>>>>>> fix-pt65153600
    }


    return self;
}

- (id)parsedData {

    return self.hereNow;
}

<<<<<<< HEAD
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

=======
>>>>>>> fix-pt65153600
- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <participants: %@, participants count: %i, channel: %@>",
                    NSStringFromClass([self class]),
                    self,
                    self.hereNow.participants,
                    self.hereNow.participantsCount,
                    self.hereNow.channel];
}

#pragma mark -


@end
