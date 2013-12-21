//
//  PNChannelHistoryParser.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import "PNChannelHistoryParser.h"
#import "PNMessagesHistory+Protected.h"
#import "PNMessage+Protected.h"
#import "PNResponse.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel history response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

// Stores reference on index under which messages
// list is stored
static NSUInteger const kPNResponseMessagesListElementIndex = 0;

// Stores reference on index under which start date is stored
static NSUInteger const kPNResponseStartDateElementIndex = 1;

// Stores reference on index under element end date is stores
static NSUInteger const kPNResponseEndDateElementIndexForEvent = 2;


#pragma mark - Private interface methods

@interface PNChannelHistoryParser ()


#pragma mark - Properties

// Stores reference on history data object
@property (nonatomic, strong) PNMessagesHistory *history;


@end


#pragma mark - Public interface methods

@implementation PNChannelHistoryParser


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
        NSNumber *startTimeToken = [responseData objectAtIndex:kPNResponseStartDateElementIndex];
        NSNumber *endTimeToken = [responseData objectAtIndex:kPNResponseEndDateElementIndexForEvent];
        self.history = [PNMessagesHistory historyBetween:[PNDate dateWithToken:startTimeToken]
                                              andEndDate:[PNDate dateWithToken:endTimeToken]];

        NSArray *messages = [responseData objectAtIndex:kPNResponseMessagesListElementIndex];
        NSMutableArray *historyMessages = [NSMutableArray arrayWithCapacity:[messages count]];
        [messages enumerateObjectsUsingBlock:^(id message, NSUInteger messageIdx, BOOL *messageEnumerator) {

            PNMessage *messageObject = [PNMessage messageFromServiceResponse:message onChannel:nil atDate:nil];
            [historyMessages addObject:messageObject];
        }];

        self.history.messages = historyMessages;
    }


    return self;
}

- (id)parsedData {

    return self.history;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p) <channel: %@, from: %@, to: %@, messages: %@>",
                                      NSStringFromClass([self class]), self,
                                      self.history.channel,
                                      self.history.startDate,
                                      self.history.endDate,
                                      self.history.messages];
}

#pragma mark -


@end
