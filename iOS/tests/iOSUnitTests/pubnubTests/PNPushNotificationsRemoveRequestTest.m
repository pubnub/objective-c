//
//  PNPushNotificationsRemoveRequestTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNPushNotificationsRemoveRequest.h"
#import "PubNub.h"
#import "PubNub+Protected.h"

@interface PNPushNotificationsRemoveRequest ()
@property (nonatomic, strong) NSString *pushToken;
+ (PNPushNotificationsRemoveRequest *)requestWithDevicePushToken:(NSData *)pushToken;
@end

@interface PNPushNotificationsRemoveRequestTest : SenTestCase

@end

@implementation PNPushNotificationsRemoveRequestTest

- (void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testRequestWithDevicePushToken {
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNPushNotificationsRemoveRequest *requst = [PNPushNotificationsRemoveRequest requestWithDevicePushToken: data];
	STAssertTrue( requst.sendingByUserRequest == YES, @"");
	NSLog(@"requst.pushToken %@", requst.pushToken);
	STAssertTrue( [requst.pushToken isEqualToString: @"746f6b656e"] == YES, @"");
}

-(void)testInitWithDevicePushToken {
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNPushNotificationsRemoveRequest *requst = [[PNPushNotificationsRemoveRequest alloc] initWithDevicePushToken: data];
	STAssertTrue( requst.sendingByUserRequest == YES, @"");
	NSLog(@"requst.pushToken %@", requst.pushToken);
	STAssertTrue( [requst.pushToken isEqualToString: @"746f6b656e"] == YES, @"");

}

-(void)testTimeout {
	[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
	PNPushNotificationsRemoveRequest *requst = [PNPushNotificationsRemoveRequest requestWithDevicePushToken: nil];
	STAssertTrue( requst.timeout == [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout, @"");
}

-(void)testCallbackMethodName {
	PNPushNotificationsRemoveRequest *requst = [PNPushNotificationsRemoveRequest requestWithDevicePushToken: nil];
	STAssertTrue( [[requst callbackMethodName] isEqualToString: @"pnr"] == YES, @"" );
}

-(void)testResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"cipher" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"id"];
	NSData *data = [@"token" dataUsingEncoding:NSUTF8StringEncoding];
	PNPushNotificationsRemoveRequest *requst = [PNPushNotificationsRemoveRequest requestWithDevicePushToken: data];
	NSString *resourcePath = [requst resourcePath];
	NSLog( @"resourcePath |%@|", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/v1/push/sub-key/subscr/devices/746f6b656e/remove?callback=pnr_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"&uuid=id&auth=auth"].location != NSNotFound, @"");
	STAssertTrue( resourcePath.length == 86, @"");
}


@end
