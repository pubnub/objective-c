<<<<<<< HEAD
/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */
=======
//
//  PNChannelEventsResponseParser.h
// 
//
//  Created by moonlight on 1/15/13.
//
//

>>>>>>> fix-pt65153600

#import "PNPrivateImports.h"
#import "PNChannelEventsResponseParser.h"
#import "PNChannelPresence+Protected.h"
#import "PNPresenceEvent+Protected.h"
#import "PNChannelEvents+Protected.h"
<<<<<<< HEAD
#import "PNResponse+Protected.h"
=======
#import "PNResponse.h"
>>>>>>> fix-pt65153600


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel events response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

<<<<<<< HEAD
/**
 Stores reference on index under which events list is stored.
 */
static NSUInteger const kPNResponseEventsListElementIndex = 0;

/**
 Stores reference on index under which channels list is stored.
 */
static NSUInteger const kPNResponseChannelsListElementIndex = 2;

/**
 Stores reference on time token element index in response for events.
 */
=======
// Stores reference on index under which events list is stored
static NSUInteger const kPNResponseEventsListElementIndex = 0;

// Stores reference on index under which channels list is stored
static NSUInteger const kPNResponseChannelsListElementIndex = 2;

// Stores reference on time token element index in response for events
>>>>>>> fix-pt65153600
static NSUInteger const kPNResponseTimeTokenElementIndexForEvent = 1;


#pragma mark - Private interface methods

@interface PNChannelEventsResponseParser ()


#pragma mark - Properties

<<<<<<< HEAD
/**
 Stores reference on even data object which holds all information about events.
 */
@property (nonatomic, strong) PNChannelEvents *events;


#pragma mark -


=======
// Stores reference on even data object which holds all information about events
@property (nonatomic, strong) PNChannelEvents *events;


>>>>>>> fix-pt65153600
@end


#pragma mark - Public interface methods

@implementation PNChannelEventsResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSArray *responseData = response.response;
        self.events = [PNChannelEvents new];
        PNDate *eventDate = nil;

        // Check whether time token is available or not
        if ([responseData count] > kPNResponseTimeTokenElementIndexForEvent) {

            id timeToken = [responseData objectAtIndex:kPNResponseTimeTokenElementIndexForEvent];
            self.events.timeToken = PNNumberFromUnsignedLongLongString(timeToken);
            eventDate = [PNDate dateWithToken:self.events.timeToken];
        }

        // Retrieving list of events
        NSArray *events = [responseData objectAtIndex:kPNResponseEventsListElementIndex];

        // Retrieving list of channels on which events fired
        NSArray *channels = nil;
        if ([responseData count] > kPNResponseChannelsListElementIndex) {

            channels = [[responseData objectAtIndex:kPNResponseChannelsListElementIndex]
                    componentsSeparatedByString:@","];
        }

        if ([events count] > 0) {

            NSMutableArray *eventObjects = [NSMutableArray arrayWithCapacity:[events count]];
<<<<<<< HEAD
            [events enumerateObjectsUsingBlock:^(id event, NSUInteger eventIdx, BOOL *eventEnumeratorStop) {
=======
            [events enumerateObjectsUsingBlock:^(id event,
                                                 NSUInteger eventIdx,
                                                 BOOL *eventEnumeratorStop) {
>>>>>>> fix-pt65153600

                PNChannel *channel = nil;
                if ([channels count] > 0) {

                    // Retrieve reference on channel on which event is occurred
                    channel = [PNChannel channelWithName:[channels objectAtIndex:eventIdx]];

                    // Checking whether event occurred on presence observing channel
                    // or no and retrieve reference on original channel
                    if ([channel isPresenceObserver]) {

                        channel = [(PNChannelPresence *)channel observedChannel];
                    }
                }

                id eventObject = nil;

                // Checking whether event presence event or not
                if ([event isKindOfClass:[NSDictionary class]] && [PNPresenceEvent isPresenceEventObject:event]) {

                    eventObject = [PNPresenceEvent presenceEventForResponse:event];
                    ((PNPresenceEvent *)eventObject).channel = channel;
                }
                else {

                    eventObject = [PNMessage messageFromServiceResponse:event onChannel:channel atDate:eventDate];
                }

                [eventObjects addObject:eventObject];
            }];

            self.events.events = eventObjects;
        }
    }


    return self;
}

- (id)parsedData {

    return self.events;
}

- (NSString *)description {

<<<<<<< HEAD
    return [NSString stringWithFormat:@"%@ (%p) <time token: %@, events: %@>", NSStringFromClass([self class]), self,
                                      self.events.timeToken, self.events.events];
=======
    return [NSString stringWithFormat:@"%@ (%p) <time token: %@, events: %@>",
                                      NSStringFromClass([self class]), self,
                                      self.events.timeToken,
                                      self.events.events];
>>>>>>> fix-pt65153600
}

#pragma mark -


@end
