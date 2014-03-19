//
//  PNPushNotificationsStateChangeRequestTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNPushNotificationsStateChangeRequest.h"
#import "PubNub+Protected.h"
#import "PubNub.h"

@interface PNPushNotificationsStateChangeRequest ()
@property (nonatomic, strong) NSString *pushToken;
- (NSTimeInterval)timeout;
@end

@interface PNPushNotificationsStateChangeRequestTest : SenTestCase

@end

@implementation PNPushNotificationsStateChangeRequestTest

-(void)setUp {
	[super setUp];
	[PubNub resetClient];
}

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testRequestWithDevicePushTokenChannel {
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNPushNotificationsStateChangeRequest *request = [PNPushNotificationsStateChangeRequest requestWithDevicePushToken:data toState:@"state" forChannel: channel];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.channels isEqualToArray: @[channel]] == YES, @"");
	STAssertTrue( [request.targetState isEqualToString: @"state"] == YES, @"");
	STAssertTrue( [request.pushToken isEqualToString: @"746f6b656e"] == YES, @"");
}

-(void)testRequestWithDevicePushTokenChannels {
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNPushNotificationsStateChangeRequest *request = [PNPushNotificationsStateChangeRequest requestWithDevicePushToken:data toState:@"state" forChannels: @[channel]];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.channels isEqualToArray: @[channel]] == YES, @"");
	STAssertTrue( [request.targetState isEqualToString: @"state"] == YES, @"");
	STAssertTrue( [request.pushToken isEqualToString: @"746f6b656e"] == YES, @"");
}

-(void)testInitWithTokenChannel {
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNPushNotificationsStateChangeRequest *request = [[PNPushNotificationsStateChangeRequest alloc] initWithToken:data  forChannel: channel state:@"state"];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.channels isEqualToArray: @[channel]] == YES, @"");
	STAssertTrue( [request.targetState isEqualToString: @"state"] == YES, @"");
	STAssertTrue( [request.pushToken isEqualToString: @"746f6b656e"] == YES, @"");
}

-(void)testInitWithTokenChannels {
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNPushNotificationsStateChangeRequest *request = [[PNPushNotificationsStateChangeRequest alloc] initWithToken:data  forChannels: @[channel] state:@"state"];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.channels isEqualToArray: @[channel]] == YES, @"");
	STAssertTrue( [request.targetState isEqualToString: @"state"] == YES, @"");
	STAssertTrue( [request.pushToken isEqualToString: @"746f6b656e"] == YES, @"");
}

-(void)testTimeout {
	[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
	PNPushNotificationsStateChangeRequest *request = [[PNPushNotificationsStateChangeRequest alloc] initWithToken: nil  forChannels: nil state:@"state"];
	STAssertTrue( request.timeout == [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout, @"");
}

-(void)testCallbackMethodName {
	PNPushNotificationsStateChangeRequest *request = [[PNPushNotificationsStateChangeRequest alloc] initWithToken: nil  forChannels: nil state:@"state"];
	STAssertTrue( [request.callbackMethodName isEqualToString: @"cpe"], @"");

	request = [[PNPushNotificationsStateChangeRequest alloc] initWithToken: nil  forChannels: nil state:@"remove"];
	STAssertTrue( [request.callbackMethodName isEqualToString: @"cpd"], @"");
}

-(void)testResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"cipher" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"id"];
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNPushNotificationsStateChangeRequest *request = [[PNPushNotificationsStateChangeRequest alloc] initWithToken:data  forChannels: @[channel] state:@"state"];
	NSString *resourcePath = [request resourcePath];
	NSLog( @"resourcePath |%@|", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/v1/push/sub-key/subscr/devices/746f6b656e?state=channel&callback=cpe_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"&uuid=id&auth=auth"].location != NSNotFound, @"");
	STAssertTrue( resourcePath.length == 93, @"");
}

@end
