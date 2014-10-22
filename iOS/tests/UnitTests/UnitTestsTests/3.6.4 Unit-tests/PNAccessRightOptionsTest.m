//
//  PNAccessRightOptionsTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/22/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNAccessRightOptions+Protected.h"
#import "PNAccessRightOptions.h"
#import "PNStructures.h"
#import "PNChannel.h"

@interface PNAccessRightOptionsTest : XCTestCase

@end

@implementation PNAccessRightOptionsTest

- (void)setUp {
    [super setUp];
}

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:0.1];
}

-(void)testAccessRightOptionsForApplication {
	PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: nil clients: nil accessPeriod: 123];
	XCTAssertEqualObjects( options.applicationKey, @"key", @"");
	XCTAssertTrue( options.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	XCTAssertTrue( options.level == PNApplicationAccessRightsLevel, @"");
	XCTAssertTrue( options.accessPeriodDuration == 123, @"");

	NSArray *channels = [PNChannel channelsWithNames: @[@"ch1", @"ch2"]];
	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: channels clients: nil accessPeriod: 123];
	XCTAssertTrue( options.level == PNChannelAccessRightsLevel, @"");
	XCTAssertTrue( options.channels == channels, @"");

	NSArray *keys = @[@"a1", @"a2"];
	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: channels clients: keys accessPeriod: 123];
	XCTAssertTrue( options.level == PNUserAccessRightsLevel, @"");
	XCTAssertTrue( options.clientsAuthorizationKeys == keys, @"");

	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: channels clients: keys accessPeriod: 0];
	XCTAssertTrue( options.accessPeriodDuration == 0, @"");

	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNUnknownAccessRights channels: channels clients: keys accessPeriod: 123];
	XCTAssertTrue( options.accessPeriodDuration == 0, @"");
}

-(void)testIsAccessRight {
	PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: nil clients: nil accessPeriod: 123];
	XCTAssertTrue(  [options isEnablingReadAccessRight], @"");
	XCTAssertTrue(  [options isEnablingWriteAccessRight], @"");
	XCTAssertTrue(  [options isEnablingAllAccessRights], @"");
	XCTAssertFalse( [options isRevokingAccessRights], @"");

	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNNoAccessRights channels: nil clients: nil accessPeriod: 123];
	XCTAssertFalse( [options isEnablingReadAccessRight], @"");
	XCTAssertFalse( [options isEnablingWriteAccessRight], @"");
	XCTAssertFalse( [options isEnablingAllAccessRights], @"");
	XCTAssertTrue(  [options isRevokingAccessRights], @"");
}

@end


