//
//  PNChannelHistoryParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNChannelHistoryParser.h"
#import "PNResponse.h"
#import "PNMessagesHistory.h"
#import "PNMessagesHistory+Protected.h"
#import "PNDate.h"

@interface PNChannelHistoryParser (test)

@property (nonatomic, strong) PNMessagesHistory *history;
- (id)initWithResponse:(PNResponse *)response;

@end

@interface PNResponse (test)

@property (nonatomic, strong) id response;

@end

@interface PNChannelHistoryParserTest : SenTestCase

@end

@implementation PNChannelHistoryParserTest

-(void)setUp {
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:0.1];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	response.response = @[ @[@"message"], [NSNumber numberWithInt: 123], [NSNumber numberWithInt: 124] ];
	PNChannelHistoryParser *parser = [[PNChannelHistoryParser alloc] initWithResponse: response];

	STAssertTrue( parser != nil, @"");
	STAssertTrue( [parser.history isKindOfClass: [PNMessagesHistory class]] == YES, @"");
	STAssertTrue( [parser.history.messages count] == 1, @"");
	STAssertTrue( [[parser.history.messages[0] message] isEqualToString: @"message"], @"");
	STAssertTrue( [parser.history.startDate.timeToken intValue] == 123, @"");
	STAssertTrue( [parser.history.endDate.timeToken intValue] == 124, @"");

	STAssertTrue( [parser parsedData] == parser.history, @"");
}

@end
