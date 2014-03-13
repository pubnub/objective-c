//
//  PNTimeTokenResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/31/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNTimeTokenResponseParser.h"
#import "PNResponse.h"

@interface PNResponse (test)

@property (nonatomic, strong) id response;
@property (nonatomic, assign) NSInteger statusCode;

@end

@interface PNTimeTokenResponseParser (test)
@property (nonatomic, strong) NSNumber *timeToken;
- (id)initWithResponse:(PNResponse *)response;
@end



@interface PNTimeTokenResponseParserTest : SenTestCase

@end

@implementation PNTimeTokenResponseParserTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	response.response = @[@"status", @"123"];

	PNTimeTokenResponseParser *parser = [[PNTimeTokenResponseParser alloc] initWithResponse: response];
	STAssertTrue( parser != nil, @"");
	STAssertTrue( [parser parsedData] == parser.timeToken, @"");
	STAssertTrue( [[parser parsedData] intValue] == 123, @"");
}

@end
