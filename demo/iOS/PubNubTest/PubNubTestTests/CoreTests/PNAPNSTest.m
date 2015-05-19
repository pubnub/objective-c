//
//  PNAPNSTest.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

static NSString const *deviceid = @"F9D977FE-34AB-440D-B1D3-531F0780FD51";

@interface PNAPNSTest : XCTestCase

@end

@implementation PNAPNSTest  {
    
    PubNub *_pubNub;
    GCDGroup *_resGroup;
    NSData *_devicePushToken;
}


- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    _devicePushToken = nil;
}

- (void)tearDown {
    
    _pubNub = nil;
    [super tearDown];
}

- (void)testARNS {

    // Add push notifications on channels
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub addPushNotificationsOnChannels:@[@"testChannel1", @"testChannel2"] withDevicePushToken:_devicePushToken andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error"); //?
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired");
    }

     // Remove push notifications from channels
    [_resGroup enter];
    
    [_pubNub removePushNotificationsFromChannels:@[@"testChannel1", @"testChannel2"] withDevicePushToken:_devicePushToken andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired");
    }

    // Remove all push notifications from device
    [_resGroup enter];
    
    [_pubNub removeAllPushNotificationsFromDeviceWithPushToken:_devicePushToken andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired");
    }
    
    // Request for all channels on which push notification has been enabled
    [_resGroup enter];
    
    [_pubNub pushNotificationEnabledChannelsForDeviceWithPushToken:_devicePushToken andCompletion:^(PNResult *result, PNStatus *status) {
    
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired");
    }
}

@end
