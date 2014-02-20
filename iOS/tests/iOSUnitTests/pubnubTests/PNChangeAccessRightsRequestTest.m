//
//  PNChangeAccessRightsRequestTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNChangeAccessRightsRequest.h"
#import "PNChannel.h"
#import "PNAccessRightOptions.h"
#import "PNConfiguration.h"
#import "PubNub.h"
#import "PNImports.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface PNChangeAccessRightsRequest (test)
@property (nonatomic, assign) PNAccessRightsLevel level;
- (id)initWithApplication:(NSString *)applicationKey withRights:(PNAccessRights)rights channels:(NSArray *)channels
                  clients:(NSArray *)clientsAuthorizationKeys accessPeriod:(NSInteger)accessPeriodDuration;
- (NSString *)PAMSignature;
@end

@interface PNChangeAccessRightsRequestTest : SenTestCase

@end

@implementation PNChangeAccessRightsRequestTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testChangeAccessRightsRequestForChannels {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr'" secretKey: @"secret"];
	[[PubNub sharedInstance] setConfiguration: conf];
	NSArray *channels = [PNChannel channelsWithNames: @[@"ch1", @"ch2"]];
	NSArray *clients = @[@"client1", @"client2"];
	PNChangeAccessRightsRequest *request = [PNChangeAccessRightsRequest changeAccessRightsRequestForChannels: channels accessRights:PNNoAccessRights clients: clients forPeriod: 123];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.accessRightOptions.applicationKey isEqualToString: [PubNub sharedInstance].configuration.subscriptionKey], @"");
	STAssertTrue( request.accessRightOptions.channels == channels, @"");
	STAssertTrue( request.accessRightOptions.clientsAuthorizationKeys == clients, @"");
}

-(void)testInitWithChannels {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr'" secretKey: @"secret"];
	[[PubNub sharedInstance] setConfiguration: conf];
	NSArray *channels = [PNChannel channelsWithNames: @[@"ch1", @"ch2"]];
	NSArray *clients = @[@"client1", @"client2"];
	PNChangeAccessRightsRequest *request = [[PNChangeAccessRightsRequest alloc] initWithChannels: channels accessRights: PNWriteAccessRight clients: clients period: 123];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.accessRightOptions.applicationKey isEqualToString: [PubNub sharedInstance].configuration.subscriptionKey], @"");
	STAssertTrue( request.accessRightOptions.channels == channels, @"");
	STAssertTrue( request.accessRightOptions.clientsAuthorizationKeys == clients, @"");
}

-(void)testPAMSignature {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr'" secretKey: @"secret"];
	[[PubNub sharedInstance] setConfiguration: conf];
	NSArray *channels = [PNChannel channelsWithNames: @[@"ch1", @"ch2"]];
	NSArray *clients = @[@"client1", @"client2"];
	PNChangeAccessRightsRequest *request = [PNChangeAccessRightsRequest changeAccessRightsRequestForChannels: channels accessRights:PNNoAccessRights clients: clients forPeriod: 123];
	STAssertTrue( [[request PAMSignature] length] == 46, @"");
}

-(void)testCallbackMethodName {
	PNChangeAccessRightsRequest *request = [PNChangeAccessRightsRequest changeAccessRightsRequestForChannels: nil accessRights:PNNoAccessRights clients: nil forPeriod: 123];
	STAssertTrue( [[request callbackMethodName] isEqualToString: @"arc"] == YES, @"");
}

-(void)testResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr'" secretKey: @"secret"];
	[[PubNub sharedInstance] setConfiguration: conf];
	NSArray *channels = [PNChannel channelsWithNames: @[@"ch1", @"ch2"]];
	NSArray *clients = @[@"client1", @"client2"];
	PNChangeAccessRightsRequest *request = [PNChangeAccessRightsRequest changeAccessRightsRequestForChannels: channels accessRights:PNNoAccessRights clients: clients forPeriod: 123];
	NSString *resourcePath = [request resourcePath];
	NSLog(@"res |%@|", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/v1/auth/grant/sub-key/subscr'?"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"auth=client1%2Cclient2&callback=arc_"].location != NSNotFound, @"");
	STAssertTrue( [resourcePath rangeOfString: @"&channel=ch1%2Cch2&r=0&timestamp="].location != NSNotFound, @"");
	STAssertTrue( [resourcePath rangeOfString: @"&ttl=123&signature="].location != NSNotFound, @"");
}

@end





