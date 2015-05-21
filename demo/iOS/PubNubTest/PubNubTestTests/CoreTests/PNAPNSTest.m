//
//  PNAPNSTest.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "GCDGroup.h"
#import "GCDWrapper.h"

#import "TestConfigurator.h"

static NSString const *deviceid = @"F9D977FE-34AB-440D-B1D3-531F0780FD51";

@interface PNAPNSTest : XCTestCase

@end

@implementation PNAPNSTest  {
    
    PubNub *_pubNub;
    NSData *_devicePushToken;
}


- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub.uuid = @"testUUID";
    
    _devicePushToken = nil;
}

- (void)tearDown {
    
    _pubNub = nil;
    [super tearDown];
}

- (void)testARNS {

    // Add push notifications on channels
    XCTestExpectation *_addPushNotifications = [self expectationWithDescription:@"Adding PushNotifications"];
    
    [_pubNub addPushNotificationsOnChannels:@[@"testChannel1", @"testChannel2"] withDevicePushToken:_devicePushToken andCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error"); //?
        }
        [_addPushNotifications fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
     // Remove push notifications from channels
    XCTestExpectation *_removePushNotifications = [self expectationWithDescription:@"Removing PushNotifications"];
    
    [_pubNub removePushNotificationsFromChannels:@[@"testChannel1", @"testChannel2"] withDevicePushToken:_devicePushToken andCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
        }
        [_removePushNotifications fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];

    // Remove all push notifications from device
    XCTestExpectation *_removeAllPushNotifications = [self expectationWithDescription:@"Removing all PushNotifications"];
    
    [_pubNub removeAllPushNotificationsFromDeviceWithPushToken:_devicePushToken andCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
        }
        [_removeAllPushNotifications fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    // Request for all channels on which push notification has been enabled
    XCTestExpectation *_getChannelsWithPushNotifications = [self expectationWithDescription:@"Getting all channels with PushNotifications"];;
    
    [_pubNub pushNotificationEnabledChannelsForDeviceWithPushToken:_devicePushToken andCompletion:^(PNResult *result, PNStatus *status) {
    
        if (status.isError) {
            
            XCTFail(@"Error");
        }
        [_getChannelsWithPushNotifications fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
}

@end
