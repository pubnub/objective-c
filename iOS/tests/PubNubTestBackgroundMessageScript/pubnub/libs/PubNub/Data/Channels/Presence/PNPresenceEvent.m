//
//  PNPresenceEvent.m
//  pubnub
//
//  Object which is used to describe concrete
//  presence event which arrived from PubNub
//  services.
//
//
//  Created by Sergey Mamontov.
//
//


#import "PNPresenceEvent+Protected.h"
<<<<<<< HEAD
#import "PNClient+Protected.h"
#import "PNClient.h"
=======
>>>>>>> fix-pt65153600


// ARC check
#if !__has_feature(objc_arc)
#error PubNub presence event must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


<<<<<<< HEAD
#pragma mark Class forward

@class PNClient;


=======
>>>>>>> fix-pt65153600
#pragma mark Structures

struct PNPresenceEventDataKeysStruct PNPresenceEventDataKeys = {
    .action = @"action",
    .timestamp = @"timestamp",
    .uuid = @"uuid",
<<<<<<< HEAD
    .data = @"data",
=======
>>>>>>> fix-pt65153600
    .occupancy = @"occupancy"
};


#pragma mark - Private interface methods

@interface PNPresenceEvent ()


#pragma mark Properties

<<<<<<< HEAD
@property (nonatomic, assign) PNPresenceEventType type;
@property (nonatomic, strong) PNClient *client;
@property (nonatomic, strong) PNDate *date;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) NSUInteger occupancy;
=======
// Stores reference on presence event type
@property (nonatomic, assign) PNPresenceEventType type;

// Stores reference on presence occurrence
// date
@property (nonatomic, strong) PNDate *date;

// Stores reference on user identifier which
// is triggered presence event
@property (nonatomic, copy) NSString *uuid;

// Stores reference on number of persons in channel
// on which this event is occurred
@property (nonatomic, assign) NSUInteger occupancy;

// Stores reference on channel on which this event
// is fired
>>>>>>> fix-pt65153600
@property (nonatomic, assign) PNChannel *channel;


@end


#pragma mark - Public interface methods

@implementation PNPresenceEvent


#pragma mark Class methods

+ (id)presenceEventForResponse:(id)presenceResponse {
    
    return [[[self class] alloc] initWithResponse:presenceResponse];
}

+ (BOOL)isPresenceEventObject:(NSDictionary *)event {

    return [event objectForKey:PNPresenceEventDataKeys.timestamp] != nil &&
           [event objectForKey:PNPresenceEventDataKeys.occupancy] != nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(id)presenceResponse {
    
    // Check whether initialization successful or not
    if((self = [super init])) {

        // Extracting event type from response
        self.type = PNPresenceEventJoin;
        NSString *type = [presenceResponse valueForKey:PNPresenceEventDataKeys.action];
        if ([type isEqualToString:@"leave"]) {

            self.type = PNPresenceEventLeave;
        }
        else if ([type isEqualToString:@"timeout"]) {

            self.type = PNPresenceEventTimeout;
        }
        else if (type == nil){

            self.type = PNPresenceEventChanged;
        }

        // Extracting event date from response
        NSNumber *timestamp = [presenceResponse valueForKey:PNPresenceEventDataKeys.timestamp];
        self.date = [PNDate dateWithToken:timestamp];

<<<<<<< HEAD
        // Extracting channel occupancy from response
        self.occupancy = [[presenceResponse valueForKey:PNPresenceEventDataKeys.occupancy] unsignedIntegerValue];
        
        // Extracting client specific state
        self.client = [PNClient clientForIdentifier:[presenceResponse valueForKey:PNPresenceEventDataKeys.uuid]
                                            channel:nil
                                            andData:[presenceResponse valueForKey:PNPresenceEventDataKeys.data]];
        
        /**
         DEPRECATED. WILL BE COMPLETELY REMOVED IN PubNub 3.5.5
         */
        // Extracting user identifier from response
        _uuid = [presenceResponse valueForKey:PNPresenceEventDataKeys.uuid];
=======
        // Extracting user identifier from response
        self.uuid = [presenceResponse valueForKey:PNPresenceEventDataKeys.uuid];

        // Extracting channel occupancy from response
        self.occupancy = [[presenceResponse valueForKey:PNPresenceEventDataKeys.occupancy] unsignedIntegerValue];
>>>>>>> fix-pt65153600
    }
    
    
    return self;
}

<<<<<<< HEAD

#pragma mark - Misc methods

- (void)setChannel:(PNChannel *)channel {

    _channel = channel;
    self.client.channel = channel;
}

=======
>>>>>>> fix-pt65153600
- (NSString *)description {

    NSString *action = @"join";
    if (self.type == PNPresenceEventLeave) {

        action = @"leave";
    }
    else if (self.type == PNPresenceEventTimeout) {

        action = @"timeout";
    }
    else if (self.type == PNPresenceEventChanged) {

        action = @"changed";
    }


<<<<<<< HEAD
    return [NSString stringWithFormat:@"%@\nEVENT: %@%@\nDATE: %@\nOCCUPANCY: %ld\nCHANNEL: %@",
                    NSStringFromClass([self class]), action, [NSString stringWithFormat:@"\nCLIENT: %@", self.client],
                    self.date, (unsigned long)self.occupancy, self.channel];
=======
    return [NSString stringWithFormat:@"%@ \nEVENT: %@%@\nDATE: %@\nOCCUPANCY: %ld\nCHANNEL: %@",
                    NSStringFromClass([self class]),
                    action,
                    self.uuid ? [NSString stringWithFormat:@"\nUSER IDENTIFIER: %@", self.uuid] : @"",
                    self.date,
                    (unsigned long)self.occupancy,
                    self.channel];
>>>>>>> fix-pt65153600
}

#pragma mark -


@end
