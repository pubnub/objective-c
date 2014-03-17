//
//  PNOperationStatusResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/30/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
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



@interface PNOperationStatusResponseParserTest : SenTestCase

@end



@implementation PNOperationStatusResponseParserTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:0.1];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	response.response = @[@(0), @"status", @"123"];

	PNOperationStatusResponseParser *parser = [[PNOperationStatusResponseParser alloc] initWithResponse: response];
	STAssertTrue( parser != nil, @"");
	STAssertTrue( [[parser operationStatus] isKindOfClass: [PNOperationStatus class]], @"");
	STAssertTrue( [[parser operationStatus] isSuccessful] == NO, @"");
	STAssertTrue( [[[parser operationStatus] statusDescription] isEqualToString: @"status"] == YES, @"");
	STAssertTrue( [parser parsedData] == parser.operationStatus, @"");
	STAssertTrue( [[(PNOperationStatus*)[parser parsedData] timeToken] intValue] == 123, @"");
	STAssertTrue( [[[[parser operationStatus] error] errorMessage] isEqualToString: @"status"] == YES, @"");


	response = [[PNResponse alloc] init];
	response.response = @[@(123), @"status"];

	parser = [[PNOperationStatusResponseParser alloc] initWithResponse: response];
	STAssertTrue( [(PNOperationStatus*)[parser parsedData] timeToken] == nil, @"");
	STAssertTrue( [[parser operationStatus] error]  == nil, @"");
}

@end







