//
//  PNActionResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNActionResponseParser.h"
#import "PNResponse.h"
#import "PNStructures.h"

@interface PNActionResponseParser (test)

@property (nonatomic, assign) PNOperationResultEvent actionType;
- (id)initWithResponse:(PNResponse *)response;

@end

@interface PNResponse (test)

@property (nonatomic, strong) id response;

@end


@interface PNActionResponseParserTest : XCTestCase

@end

@implementation PNActionResponseParserTest

-(void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	response.response = @{ @"action" : @"leave" };
	PNActionResponseParser *parser = [[PNActionResponseParser alloc] initWithResponse: response];
	XCTAssertTrue( parser.actionType == PNOperationResultLeave, @"");

	XCTAssertTrue( [[parser parsedData] intValue] == PNOperationResultLeave, @"");
}

@end
