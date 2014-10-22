//
//  PNOperationStatusResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/30/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNResponse.h"
#import "PNOperationStatusResponseParser.h"
#import "PNOperationStatus.h"
#import "PNError.h"

@interface PNError (test)
@property (nonatomic, copy) NSString *errorMessage;
@end

@interface PNResponse (test)

@property (nonatomic, strong) id response;
@property (nonatomic, assign) NSInteger statusCode;

@end


@interface PNOperationStatusResponseParser (test)

@property (nonatomic, strong) PNOperationStatus *operationStatus;
- (id)initWithResponse:(PNResponse *)response;

@end


@interface PNOperationStatusResponseParserTest : XCTestCase

@end


@implementation PNOperationStatusResponseParserTest

-(void)tearDown {
    [super tearDown];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	response.response = @[@(0), @"status", @"123"];

	PNOperationStatusResponseParser *parser = [[PNOperationStatusResponseParser alloc] initWithResponse: response];
	XCTAssertTrue( parser != nil, @"");
	XCTAssertTrue( [[parser operationStatus] isKindOfClass: [PNOperationStatus class]], @"");
	XCTAssertTrue( [[parser operationStatus] isSuccessful] == NO, @"");
	XCTAssertTrue( [[[parser operationStatus] statusDescription] isEqualToString: @"status"] == YES, @"");
	XCTAssertTrue( [parser parsedData] == parser.operationStatus, @"");
	XCTAssertTrue( [[(PNOperationStatus*)[parser parsedData] timeToken] intValue] == 123, @"");
	XCTAssertTrue( [[[[parser operationStatus] error] errorMessage] isEqualToString: @"status"] == YES, @"");


	response = [[PNResponse alloc] init];
	response.response = @[@(123), @"status"];

	parser = [[PNOperationStatusResponseParser alloc] initWithResponse: response];
    
	XCTAssertTrue( [(PNOperationStatus*)[parser parsedData] timeToken] == nil, @"");
	XCTAssertTrue( [[parser operationStatus] error]  == nil, @"");
}

@end
