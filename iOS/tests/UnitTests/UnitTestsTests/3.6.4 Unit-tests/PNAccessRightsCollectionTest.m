//
//  PNAccessRightsCollectionTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/22/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNAccessRightsCollection.h"
#import "PNAccessRightsCollection+Protected.h"
#import "PNAccessRightsInformation+Protected.h"
#import "PNAccessRightsInformation.h"
#import "PNAccessRightOptions+Protected.h"
#import "PNAccessRightOptions.h"
#import "PNStructures.h"
#import "PNChannel.h"

@interface PNAccessRightsCollection (test)

- (void)storeClientAccessRightsInformation:(PNAccessRightsInformation *)information forChannel:(PNChannel *)channel;

@end

@interface PNAccessRightsCollectionTest : XCTestCase

@end

@implementation PNAccessRightsCollectionTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:0.1];
}

- (void)testAccessRightsCollectionForApplication {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	XCTAssertNotNil( collection, @"");
	XCTAssertEqualObjects( collection.applicationKey, @"key", @"");
	XCTAssertTrue( [collection.channelsAccessRightsInformation isKindOfClass: [NSMutableDictionary class]] == YES, @"");
	XCTAssertTrue( [collection.clientsAccessRightsInformation isKindOfClass: [NSMutableDictionary class]] == YES, @"");
}

-(void)testAccessRightsInformationForApplication {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	collection.applicationAccessRightsInformation = [[PNAccessRightsInformation alloc] init];
	PNAccessRightsInformation *info = [collection accessRightsInformationForApplication];
	XCTAssertTrue( info == collection.applicationAccessRightsInformation, @"");

	collection.applicationAccessRightsInformation = nil;
	info = [collection accessRightsInformationForApplication];
	XCTAssertTrue( info.level == PNApplicationAccessRightsLevel, @"");
	XCTAssertTrue( info.rights == PNUnknownAccessRights, @"");
	XCTAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	XCTAssertTrue( info.object == nil, @"");
	XCTAssertTrue( info.authorizationKey == nil, @"");
	XCTAssertTrue( info.accessPeriodDuration == 0, @"");
}

-(void)testAccessRightsInformationForAllChannels {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel:PNApplicationAccessRightsLevel];
    
    PNAccessRightsInformation *accessRightsInformation = [PNAccessRightsInformation accessRightsInformationForLevel:PNChannelAccessRightsLevel
                                                                                          rights:PNAllAccessRights                                                                                  applicationKey:@"key"
                                                                                      forChannel:[PNChannel channelWithName: @"channel"]
                                                                                          client:@"client"
                                                                                    accessPeriod: 123];
    XCTAssertTrue( accessRightsInformation.object == [PNChannel channelWithName: @"channel"], @"");
    XCTAssertFalse( accessRightsInformation.object.isChannelGroup);
    
    [collection.channelsAccessRightsInformation setObject:accessRightsInformation forKey:@"key"];
    
	NSArray *informationForAllChannels = [collection accessRightsInformationForAllChannels];
	XCTAssertTrue( [informationForAllChannels isEqualToArray: [collection.channelsAccessRightsInformation allValues]], @"");
}

-(void)testAccessRightsInformationForChannel {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];

	PNAccessRightsInformation *info = [collection accessRightsInformationFor:channel];
	XCTAssertTrue( info.level == PNChannelAccessRightsLevel, @"");
	XCTAssertTrue( info.rights == PNUnknownAccessRights, @"");
	XCTAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	XCTAssertTrue( info.object == channel, @"");
	XCTAssertTrue( info.authorizationKey == nil, @"");
	XCTAssertTrue( info.accessPeriodDuration == 0, @"");

	collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	info = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
	[collection storeChannelAccessRightsInformation: info];

	info = [collection accessRightsInformationFor:channel];
	XCTAssertTrue( info.level == PNChannelAccessRightsLevel, @"");
	XCTAssertTrue( info.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	XCTAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	XCTAssertTrue( info.object == channel, @"");
	XCTAssertTrue( [info.authorizationKey isEqualToString: @"client"], @"");
	XCTAssertTrue( info.accessPeriodDuration == 123, @"");
}

-(void)testAccessRightsForClientsOnChannel {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
    
	PNChannel *channel = [PNChannel channelWithName: @"channel"];

	XCTAssertTrue( [[collection accessRightsForClientsOn: channel] count] == 0, @"");

	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
    
	[collection storeClientAccessRightsInformation: info forChannel: channel];
	NSArray *arr = [collection accessRightsForClientsOn: channel];
	XCTAssertTrue( [[collection accessRightsForClientsOn: channel] count] == 1, @"");
	info = arr[0];
	XCTAssertTrue( info.level == PNChannelAccessRightsLevel, @"");
	XCTAssertTrue( info.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	XCTAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	XCTAssertTrue( info.object == channel, @"");
	XCTAssertTrue( [info.authorizationKey isEqualToString: @"client"], @"");
	XCTAssertTrue( info.accessPeriodDuration == 123, @"");
}

-(void)testAccessRightsInformationForAllClientAuthorizationKeys {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
    
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
    
	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
    
	[collection storeClientAccessRightsInformation:info forChannel:channel];

	NSArray *arr = [collection accessRightsInformationForAllClientAuthorizationKeys];
	XCTAssertTrue( [arr count] == 1, @"");
	XCTAssertTrue( arr[0] == info, @"");
}

-(void)testAccessRightsInformationForClientAuthorizationKey {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
	[collection storeChannelAccessRightsInformation: info];

	NSArray *arr = [collection accessRightsInformationForClientAuthorizationKey: @"client"];
	XCTAssertTrue( [arr count] == 1, @"");
	XCTAssertTrue( arr[0] == info, @"");

	arr = [collection accessRightsInformationForClientAuthorizationKey: @"invalid_auth_key"];
	XCTAssertTrue( [arr count] == 0, @"");
}

-(void)testAccessRightsInformationClientAuthorizationKey {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
//	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];

	PNAccessRightsInformation *info = [collection accessRightsInformationClientAuthorizationKey: @"key" onChannel: channel];
	XCTAssertTrue( info.level == PNUserAccessRightsLevel, @"");
	XCTAssertTrue( info.rights == PNUnknownAccessRights, @"");
	XCTAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	XCTAssertTrue( info.object == channel, @"");
	XCTAssertTrue( [info.authorizationKey isEqualToString: @"key"] == TRUE, @"");
	XCTAssertTrue( info.accessPeriodDuration == 0, @"");

	info = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
	[collection storeChannelAccessRightsInformation: info];
	info = [collection accessRightsInformationClientAuthorizationKey: @"key" onChannel: channel];
	XCTAssertTrue( info.level == PNUserAccessRightsLevel, @"");
	XCTAssertTrue( info.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	XCTAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	XCTAssertTrue( info.object == channel, @"");
	XCTAssertTrue( [info.authorizationKey isEqualToString: @"key"], @"");
}

-(void)testStoreApplicationAccessRightsInformation {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: nil client: @"client" accessPeriod: 123];
	[collection storeApplicationAccessRightsInformation: info];
	XCTAssertTrue( collection.applicationAccessRightsInformation == info, @"");
}

-(void)testStoreClientAccessRightsInformation {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNUserAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];

	[collection storeClientAccessRightsInformation: info forChannel: channel];
	NSArray *arr = [collection accessRightsForClientsOn: channel];
	XCTAssertTrue( [arr count] == 1, @"");
	info = arr[0];
	XCTAssertTrue( info.level == PNUserAccessRightsLevel, @"");
	XCTAssertTrue( info.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	XCTAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	XCTAssertTrue( info.object == channel, @"");
	XCTAssertTrue( [info.authorizationKey isEqualToString: @"client"], @"");
	XCTAssertTrue( info.accessPeriodDuration == 123, @"");
}

-(void)testCorrelateAccessRightsWithOptions {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];

	PNAccessRightOptions *options = [[PNAccessRightOptions alloc] init];
	options.level = PNApplicationAccessRightsLevel;
	[collection correlateAccessRightsWithOptions: options];
	XCTAssertTrue( collection.level == options.level, @"");
}

-(void)testPopulateAccessRightsFrom {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];

	PNAccessRightsInformation *info1 = [PNAccessRightsInformation accessRightsInformationForLevel: PNUserAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
	PNAccessRightsInformation *info2 = [[PNAccessRightsInformation alloc] init];
	[collection populateAccessRightsFrom: info1 to: info2];
	XCTAssertTrue( info2.rights == (PNReadAccessRight | PNWriteAccessRight), @"");

	info1 = [PNAccessRightsInformation accessRightsInformationForLevel: PNUserAccessRightsLevel rights: PNReadAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
	info2 = [[PNAccessRightsInformation alloc] init];
	[collection populateAccessRightsFrom: info1 to: info2];
	XCTAssertTrue( info2.rights == (PNReadAccessRight), @"");

	info1 = [PNAccessRightsInformation accessRightsInformationForLevel: PNUserAccessRightsLevel rights: PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
	info2 = [[PNAccessRightsInformation alloc] init];
	[collection populateAccessRightsFrom: info1 to: info2];
	XCTAssertTrue( info2.rights == (PNWriteAccessRight), @"");
}

@end




