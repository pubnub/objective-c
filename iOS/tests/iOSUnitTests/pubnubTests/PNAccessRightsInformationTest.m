//
//  PNAccessRightsInformationTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/31/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNAccessRightsInformation+Protected.h"
#import "PNAccessRightsInformation.h"
#import "PNChannel.h"

@interface PNAccessRightsInformationTest : SenTestCase

@end

@implementation PNAccessRightsInformationTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testAccessRightsInformationForLevel {
	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNApplicationAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"applicationKey" forChannel: [PNChannel channelWithName: @"channel"] client: @"client" accessPeriod: 123];
	STAssertTrue( info.level == PNApplicationAccessRightsLevel, @"");
	STAssertTrue( info.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	STAssertTrue( [info.subscriptionKey isEqualToString: @"applicationKey"] == YES, @"");
	STAssertTrue( [info.channel.name isEqualToString: @"channel"] == YES, @"");
	STAssertTrue( [info.authorizationKey isEqualToString: @"client"] == YES, @"");
	STAssertTrue( info.accessPeriodDuration == 123, @"");

	STAssertTrue( [info hasReadRight] == YES, @"");
	STAssertTrue( [info hasWriteRight] == YES, @"");
	STAssertTrue( [info hasAllRights] == YES, @"");
	STAssertTrue( [info isAllRightsRevoked] == NO, @"");


	info = [PNAccessRightsInformation accessRightsInformationForLevel: PNApplicationAccessRightsLevel rights: PNNoAccessRights applicationKey: @"applicationKey" forChannel: [PNChannel channelWithName: @"channel"] client: @"client" accessPeriod: 123];
	STAssertTrue( [info hasReadRight] == NO, @"");
	STAssertTrue( [info hasWriteRight] == NO, @"");
	STAssertTrue( [info hasAllRights] == NO, @"");
	STAssertTrue( [info isAllRightsRevoked] == YES, @"");
}

-(void)testAccessRightsInformationForLevelFromList {
	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNApplicationAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"applicationKey" forChannel: [PNChannel channelWithName: @"channel"] client: @"client" accessPeriod: 123];

	NSArray *arr = [PNAccessRightsInformation accessRightsInformationForLevel: PNApplicationAccessRightsLevel fromList:@[info]];
	STAssertTrue( arr.count == 1, @"");
	STAssertTrue( arr[0] == info, @"");

	arr = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel fromList:@[info]];
	STAssertTrue( arr.count == 0, @"");
}

@end
