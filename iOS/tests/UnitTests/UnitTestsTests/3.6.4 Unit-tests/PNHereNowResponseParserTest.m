//
//  PNHereNowResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/30/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "PNHereNowResponseParser+Protected.h"
#import "PNHereNowResponseParser.h"
#import "PNHereNowResponseParser+Protected.h"
#import "PNResponse.h"
#import "PNHereNow.h"

@interface PNError (test)

@property (nonatomic, copy) NSString *errorMessage;

@end


@interface PNResponse (test)

@property (nonatomic, strong) id response;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) id additionalData;

@end


@interface PNHereNowResponseParser (test)

@property (nonatomic, strong) PNHereNow *hereNow;
- (id)initWithResponse:(PNResponse *)response;

@end

@interface PNHereNowResponseParserTest : XCTestCase

@end



@implementation PNHereNowResponseParserTest

-(void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	NSArray *uuids = @[@"u1", @"u2"];
    
    NSMutableDictionary *rawResponse = [NSMutableDictionary dictionary];
    
	[rawResponse setObject: uuids forKey: @"uuids"];
	[rawResponse setObject: @(2) forKey: @"occupancy"];
    
    response.response = rawResponse;
    
	PNChannel *channel = [PNChannel channelWithName:@"channel"];
	response.additionalData = @[channel];

	PNHereNowResponseParser *parser = [[PNHereNowResponseParser alloc] initWithResponse: response];
	XCTAssertTrue( parser != nil, @"");
    
	XCTAssertTrue( [parser parsedData] == parser.hereNow, @"");
	XCTAssertTrue( [(PNHereNow*)[parser parsedData] participantsCountForChannel:channel] == 2, @"");
    NSArray *arr = [NSArray arrayWithArray:[(PNHereNow*)[parser parsedData] participantsForChannel:channel]];
    PNClient *client = arr[0];
	XCTAssertTrue( [client.identifier isEqualToString:uuids[0]], @"");

	response = [[PNResponse alloc] init];
	rawResponse = [NSMutableDictionary dictionary];
    
	[rawResponse setObject: uuids forKey: @"uuids"];
	[rawResponse setObject: @(10) forKey: @"occupancy"];
    
    response.response = rawResponse;
    
	channel = [PNChannel channelWithName:@"channel"];
	response.additionalData = @[channel];

	parser = [[PNHereNowResponseParser alloc] initWithResponse: response];
	XCTAssertTrue( parser != nil, @"");
	XCTAssertTrue( [parser parsedData] == parser.hereNow, @"");
	XCTAssertTrue( [(PNHereNow*)[parser parsedData] participantsCountForChannel:channel] == 10, @"");
}

@end

