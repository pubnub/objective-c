//
//  PNAccessRightOptionsTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/22/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNAccessRightOptions+Protected.h"
#import "PNAccessRightOptions.h"
#import "PNStructures.h"
#import "PNChannel.h"
#import "PNPrivateMacro.h"

@interface PNAccessRightOptionsTest : SenTestCase

@end

@implementation PNAccessRightOptionsTest

- (void)setUp {
    [super setUp];
}

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testAccessRightOptionsForApplication {
	PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: nil clients: nil accessPeriod: 123];
	STAssertEqualObjects( options.applicationKey, @"key", @"");
	STAssertTrue( options.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	STAssertTrue( options.level == PNApplicationAccessRightsLevel, @"");
	STAssertTrue( options.accessPeriodDuration == 123, @"");

	NSArray *channels = [PNChannel channelsWithNames: @[@"ch1", @"ch2"]];
	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: channels clients: nil accessPeriod: 123];
	STAssertTrue( options.level == PNChannelAccessRightsLevel, @"");
	STAssertTrue( options.channels == channels, @"");

	NSArray *keys = @[@"a1", @"a2"];
	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: channels clients: keys accessPeriod: 123];
	STAssertTrue( options.level == PNUserAccessRightsLevel, @"");
	STAssertTrue( options.clientsAuthorizationKeys == keys, @"");

	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: channels clients: keys accessPeriod: 0];
	STAssertTrue( options.accessPeriodDuration == 0, @"");

	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNUnknownAccessRights channels: channels clients: keys accessPeriod: 123];
	STAssertTrue( options.accessPeriodDuration == 0, @"");
}

-(void)testIsAccessRight {
	PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNReadAccessRight | PNWriteAccessRight channels: nil clients: nil accessPeriod: 123];
	STAssertTrue(  [options isEnablingReadAccessRight], @"");
	STAssertTrue(  [options isEnablingWriteAccessRight], @"");
	STAssertTrue(  [options isEnablingAllAccessRights], @"");
	STAssertFalse( [options isRevokingAccessRights], @"");

	options = [PNAccessRightOptions accessRightOptionsForApplication: @"key" withRights: PNNoAccessRights channels: nil clients: nil accessPeriod: 123];
	STAssertFalse( [options isEnablingReadAccessRight], @"");
	STAssertFalse( [options isEnablingWriteAccessRight], @"");
	STAssertFalse( [options isEnablingAllAccessRights], @"");
	STAssertTrue(  [options isRevokingAccessRights], @"");
}

@end


