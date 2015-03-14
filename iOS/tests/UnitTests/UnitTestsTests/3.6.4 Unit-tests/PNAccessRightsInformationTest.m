//
//  PNAccessRightsInformationTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/31/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNAccessRightsInformation+Protected.h"
#import "PNAccessRightsInformation.h"
#import "PNChannel.h"

@interface PNAccessRightsInformationTest : XCTestCase

@end

@implementation PNAccessRightsInformationTest

-(void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

-(void)testAccessRightsInformationForLevel {
	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNApplicationAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"applicationKey" forChannel: [PNChannel channelWithName: @"channel"] client: @"client" accessPeriod: 123];
	XCTAssertTrue( info.level == PNApplicationAccessRightsLevel, @"");
	XCTAssertTrue( info.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	XCTAssertTrue( [info.subscriptionKey isEqualToString: @"applicationKey"] == YES, @"");
	XCTAssertTrue( [info.object.name isEqualToString: @"channel"] == YES, @"");
	XCTAssertTrue( [info.authorizationKey isEqualToString: @"client"] == YES, @"");
	XCTAssertTrue( info.accessPeriodDuration == 123, @"");

	XCTAssertTrue( [info hasReadRight] == YES, @"");
	XCTAssertTrue( [info hasWriteRight] == YES, @"");
	XCTAssertTrue( [info hasAllRights] == YES, @"");
	XCTAssertTrue( [info isAllRightsRevoked] == NO, @"");


	info = [PNAccessRightsInformation accessRightsInformationForLevel: PNApplicationAccessRightsLevel rights: PNNoAccessRights applicationKey: @"applicationKey" forChannel: [PNChannel channelWithName: @"channel"] client: @"client" accessPeriod: 123];
	XCTAssertTrue( [info hasReadRight] == NO, @"");
	XCTAssertTrue( [info hasWriteRight] == NO, @"");
	XCTAssertTrue( [info hasAllRights] == NO, @"");
	XCTAssertTrue( [info isAllRightsRevoked] == YES, @"");
}

-(void)testAccessRightsInformationForLevelFromList {
	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNApplicationAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"applicationKey" forChannel: [PNChannel channelWithName: @"channel"] client: @"client" accessPeriod: 123];

	NSArray *arr = [PNAccessRightsInformation accessRightsInformationForLevel: PNApplicationAccessRightsLevel fromList:@[info]];
	XCTAssertTrue( arr.count == 1, @"");
	XCTAssertTrue( arr[0] == info, @"");

	arr = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel fromList:@[info]];
	XCTAssertTrue( arr.count == 0, @"");
}

@end
