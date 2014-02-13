//
//  PNHereNowResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/30/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
//#import "PNHereNowResponseParser+Protected.h"
#import "PNHereNowResponseParser.h"
#import "PNResponse.h"
#import "PNHereNow.h"

@interface PNError (test)

@property (nonatomic, copy) NSString *errorMessage;

@end


@interface PNResponse (test)

@property (nonatomic, strong) id response;
@property (nonatomic, assign) NSInteger statusCode;

@end


@interface PNHereNowResponseParser (test)

@property (nonatomic, strong) PNHereNow *hereNow;
- (id)initWithResponse:(PNResponse *)response;

@end

@interface PNHereNowResponseParserTest : SenTestCase

@end



@implementation PNHereNowResponseParserTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	response.response = [NSMutableDictionary dictionary];
	NSArray *uuids = @[@"u1", @"u2"];
	[response.response setObject: uuids forKey: @"uuids"];
	[response.response setObject: @(123) forKey: @"occupancy"];

	PNHereNowResponseParser *parser = [[PNHereNowResponseParser alloc] initWithResponse: response];
	STAssertTrue( parser != nil, @"");
	STAssertTrue( [parser parsedData] == parser.hereNow, @"");
	STAssertTrue( [(PNHereNow*)[parser parsedData] participantsCount] == 123, @"");
	STAssertTrue( [[(PNHereNow*)[parser parsedData] participants] isEqualToArray: uuids], @"");
}

@end

