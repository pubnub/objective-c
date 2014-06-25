//
//  PNChannelHistoryParser.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import "PNChannelHistoryParser+Protected.h"
#import "PNMessagesHistory+Protected.h"
#import "PNMessage+Protected.h"
#import "PNResponse.h"
#import "PNDate.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel history response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Public interface methods

@implementation PNChannelHistoryParser


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
        conforms = ([responseData count] > PNChannelHistoryResponseEndDate);
        if (conforms) {

            id startTimeToken = [responseData objectAtIndex:PNChannelHistoryResponseStartDate];
            id endTimeToken = [responseData objectAtIndex:PNChannelHistoryResponseEndDate];
            conforms = (conforms ? (startTimeToken && [startTimeToken isKindOfClass:[NSNumber class]]) : conforms);
            conforms = (conforms ? (endTimeToken && [endTimeToken isKindOfClass:[NSNumber class]]) : conforms);
        }

        if (conforms && [responseData count] > PNChannelHistoryResponseMessagesList) {

            id messages = [responseData objectAtIndex:PNChannelHistoryResponseMessagesList];
            conforms = ((conforms && messages) ? [messages isKindOfClass:[NSArray class]] : conforms);
        }
    }


    return conforms;
}

+ (BOOL)isErrorResponse:(PNResponse *)response {
    
    NSArray *data = (NSArray *)response.response;
    
    return (([data count] - 1) == PNChannelHistoryResponseEndDate &&
            [[data objectAtIndex:PNChannelHistoryResponseStartDate] intValue] == 0 &&
            [[data objectAtIndex:PNChannelHistoryResponseEndDate] intValue] == 0);
}

+ (NSString *)errorMessage:(PNResponse *)response {
    
    NSString *errorMessage = nil;
    if ([self isErrorResponse:response]) {
        
        NSArray *data = (NSArray *)response.response;
        errorMessage = [(NSArray *)[data objectAtIndex:PNChannelHistoryResponseMessagesList] lastObject];
    }
    
    
    return errorMessage;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSArray *responseData = response.response;
        NSNumber *startTimeToken = [responseData objectAtIndex:PNChannelHistoryResponseStartDate];
        NSNumber *endTimeToken = [responseData objectAtIndex:PNChannelHistoryResponseEndDate];
        self.history = [PNMessagesHistory historyBetween:[PNDate dateWithToken:startTimeToken]
                                              andEndDate:[PNDate dateWithToken:endTimeToken]];

        NSArray *messages = [responseData objectAtIndex:PNChannelHistoryResponseMessagesList];
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
