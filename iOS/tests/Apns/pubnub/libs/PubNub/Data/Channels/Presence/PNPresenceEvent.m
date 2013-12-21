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


// ARC check
#if !__has_feature(objc_arc)
#error PubNub presence event must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Structures

struct PNPresenceEventDataKeysStruct PNPresenceEventDataKeys = {
    .action = @"action",
    .timestamp = @"timestamp",
    .uuid = @"uuid",
    .occupancy = @"occupancy"
};


#pragma mark - Private interface methods

@interface PNPresenceEvent ()


#pragma mark Properties

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

        // Extracting user identifier from response
        self.uuid = [presenceResponse valueForKey:PNPresenceEventDataKeys.uuid];

        // Extracting channel occupancy from response
        self.occupancy = [[presenceResponse valueForKey:PNPresenceEventDataKeys.occupancy] unsignedIntegerValue];
    }
    
    
    return self;
}

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


    return [NSString stringWithFormat:@"%@ \nEVENT: %@%@\nDATE: %@\nOCCUPANCY: %ld\nCHANNEL: %@",
                    NSStringFromClass([self class]),
                    action,
                    self.uuid ? [NSString stringWithFormat:@"\nUSER IDENTIFIER: %@", self.uuid] : @"",
                    self.date,
                    (unsigned long)self.occupancy,
                    self.channel];
}

#pragma mark -


@end
