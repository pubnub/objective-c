//
//  PNPushNotificationsEnabledChannelsRequestTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNPushNotificationsEnabledChannelsRequest.h"
#import "PubNub.h"
#import "PubNub+Protected.h"

@interface PNPushNotificationsEnabledChannelsRequest ()
@property (nonatomic, strong) NSString *pushToken;
@end

@interface PNPushNotificationsEnabledChannelsRequestTest : SenTestCase

@end

@implementation PNPushNotificationsEnabledChannelsRequestTest

- (void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testRequestWithDevicePushToken {
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNPushNotificationsEnabledChannelsRequest *requst = [PNPushNotificationsEnabledChannelsRequest requestWithDevicePushToken: data];
	STAssertTrue( requst.sendingByUserRequest == YES, @"");
	NSLog(@"requst.pushToken %@", requst.pushToken);
	STAssertTrue( [requst.pushToken isEqualToString: @"746f6b656e"] == YES, @"");
}

-(void)testInitWithDevicePushToken {
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNPushNotificationsEnabledChannelsRequest *requst = [[PNPushNotificationsEnabledChannelsRequest alloc] initWithDevicePushToken: data];
	STAssertTrue( requst.sendingByUserRequest == YES, @"");
	NSLog(@"requst.pushToken %@", requst.pushToken);
	STAssertTrue( [requst.pushToken isEqualToString: @"746f6b656e"] == YES, @"");

}

-(void)testTimeout {
	[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
	PNPushNotificationsEnabledChannelsRequest *requst = [PNPushNotificationsEnabledChannelsRequest requestWithDevicePushToken: nil];
	STAssertTrue( requst.timeout == [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout, @"");
}

-(void)testCallbackMethodName {
	PNPushNotificationsEnabledChannelsRequest *requst = [PNPushNotificationsEnabledChannelsRequest requestWithDevicePushToken: nil];
	STAssertTrue( [[requst callbackMethodName] isEqualToString: @"pec"] == YES, @"" );
}

-(void)testResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"cipher" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"id"];
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNPushNotificationsEnabledChannelsRequest *requst = [PNPushNotificationsEnabledChannelsRequest requestWithDevicePushToken: data];
	NSString *resourcePath = [requst resourcePath];
	NSLog( @"resourcePath |%@|", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/v1/push/sub-key/subscr/devices/746f6b656e?callback=pec_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"&uuid=id&auth=auth"].location != NSNotFound, @"");
	STAssertTrue( resourcePath.length == 79, @"");
}

@end
