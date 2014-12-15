/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNPrivateImports.h"
#import "PNChannelEventsResponseParser.h"
#import "PNChannelPresence+Protected.h"
#import "PNPresenceEvent+Protected.h"
#import "PNChannelEvents+Protected.h"
#import "PNResponse+Protected.h"
#import "PNDate.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel events response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

/**
 Stores reference on index under which events list is stored.
 */
static NSUInteger const kPNResponseEventsListElementIndex = 0;

/**
 Stores reference on index under which channels list is stored.
 */
static NSUInteger const kPNResponseChannelsListElementIndex = 2;

/**
 @brief Stores reference on index under which channels detalization is stored
 
 @discussion In case if under \c kPNResponseChannelsListElementIndex stored list of channel groups, under this index
 will be stored list of actual channels from channel group at which event fired.
 
 @since 3.7.0
 */
static NSUInteger const kPNResponseChannelsDetailsListElementIndex = 3;

/**
 Stores reference on time token element index in response for events.
 */
static NSUInteger const kPNResponseTimeTokenElementIndexForEvent = 1;


#pragma mark - Private interface methods

@interface PNChannelEventsResponseParser ()


#pragma mark - Properties

/**
 Stores reference on even data object which holds all information about events.
 */
@property (nonatomic, strong) PNChannelEvents *events;


#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNChannelEventsResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {

    // Checking base requirement about payload data type.
    BOOL conforms = [response.response isKindOfClass:[NSArray class]];

    // Checking base components
    if (conforms) {

        NSArray *responseData = response.response;
        conforms = ([responseData count] > kPNResponseEventsListElementIndex);
        if (conforms) {

            if ([responseData count] > kPNResponseTimeTokenElementIndexForEvent) {

                id timeToken = [responseData objectAtIndex:kPNResponseTimeTokenElementIndexForEvent];
                conforms = (timeToken && ([timeToken isKindOfClass:[NSNumber class]] || [timeToken isKindOfClass:[NSString class]]));
            }

            id events = [responseData objectAtIndex:kPNResponseEventsListElementIndex];
            conforms = ((conforms && events) ? [events isKindOfClass:[NSArray class]] : conforms);

            if ([responseData count] > kPNResponseChannelsListElementIndex) {

                id channelsList = [responseData objectAtIndex:kPNResponseChannelsListElementIndex];
                conforms = ((conforms && channelsList) ? [channelsList isKindOfClass:[NSString class]] : conforms);

            }
        }
    }


    return conforms;
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
        
        // Retrieve list of channel details
        NSArray *channelDetails = nil;
        if ([responseData count] > kPNResponseChannelsDetailsListElementIndex) {
            
            channelDetails = [[responseData objectAtIndex:kPNResponseChannelsDetailsListElementIndex]
                              componentsSeparatedByString:@","];
        }

        if ([events count] > 0) {

            NSMutableArray *eventObjects = [NSMutableArray arrayWithCapacity:[events count]];
            [events enumerateObjectsUsingBlock:^(id event, NSUInteger eventIdx, BOOL *eventEnumeratorStop) {

                PNChannel* (^channelExtractBlock)(NSString *) = ^(NSString *channelName) {
                    
                    // Retrieve reference on channel on which event is occurred
                    PNChannel *channel = [PNChannel channelWithName:channelName];
                    
                    // Checking whether event occurred on presence observing channel or no and retrieve reference on
                    // original channel
                    if ([channel isPresenceObserver]) {
                        
                        channel = [(PNChannelPresence *)channel observedChannel];
                    }
                    
                    return channel;
                };
                
                PNChannel *channel = ([channels count] ? channelExtractBlock([channels objectAtIndex:eventIdx]): nil);
                PNChannel *detailedChannel = ([channelDetails count] ? channelExtractBlock([channelDetails objectAtIndex:eventIdx]): nil);

                id eventObject = nil;
                PNChannelGroup *group = nil;
                PNChannel *targetChannel = (detailedChannel ? detailedChannel : channel);
                if (detailedChannel && channel) {
                    
                    if (channel.isChannelGroup) {
                        
                        group = (PNChannelGroup *)channel;
                    }
                }

                // Checking whether event presence event or not
                if ([event isKindOfClass:[NSDictionary class]] && [PNPresenceEvent isPresenceEventObject:event]) {
                    
                    eventObject = [PNPresenceEvent presenceEventForResponse:event
                                                                  onChannel:targetChannel
                                                               channelGroup:group];
                }
                else {

                    eventObject = [PNMessage messageFromServiceResponse:event onChannel:targetChannel
                                                           channelGroup:group atDate:eventDate];
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

    return [NSString stringWithFormat:@"%@ (%p) <time token: %@, events: %@>", NSStringFromClass([self class]), self,
                                      self.events.timeToken, self.events.events];
}

#pragma mark -


@end
