//
//  ChaosSubscribeUnsubscribeTest.m
//  UnitTests
//
//  Created by Sergey on 12/29/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ChaosSubscribeUnsubscribeTest : XCTestCase

<
PNDelegate
>

{
    GCDGroup *_resGroup;
}

@end

@implementation ChaosSubscribeUnsubscribeTest

- (void)setUp {
    [super setUp];
    
    [PubNub disconnect];
    [PubNub setDelegate:self];
}

- (void)tearDown {
    [PubNub disconnect];
    [super tearDown];
}

- (void)testSubscribeSerialCalls {
    
    [PubNub setConfiguration:[PNConfiguration defaultTestConfiguration]];
    [PubNub setDelegate:self];
    
    // Connect
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [PubNub connect];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't connect to PubNub");
        [_resGroup leave];
        _resGroup = nil;
        return;
    }
    
     // Number of channels
    int n = 20;

    NSMutableArray *channelsArray = [NSMutableArray new];
    for (int i = 1; i < n + 1; i++) {
        [channelsArray addObject:[NSString stringWithFormat:@"iosdev%d",i]];
    }

    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:n * 2 + 1];

    // Subscribe on channels
    [PubNub subscribeOn:[PNChannel channelsWithNames:channelsArray]];

    // Send message and unsubscribe from channel in loop
    for (int i = 1; i < n + 1; i++) {
        [PubNub sendMessage:@"Hello iosdev" toChannel:[PNChannel channelWithName:[NSString stringWithFormat:@"iosdev%d",i]]];
        [PubNub unsubscribeFrom:@[[PNChannel channelWithName:[NSString stringWithFormat:@"iosdev%d",i]]]];
    }
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:n * 1.5]) {
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
    }
    _resGroup = nil;
}


#pragma mark - PubNub Delegate

// Connect did
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Connect fail
- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    XCTFail(@"Did fail connection: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Subscribe on did
- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Subscribe on fail
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    XCTFail(@"Did fail subscription: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Send message did
- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Send message fail
- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
    XCTFail(@"Did fail message send: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

- (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
    if (_resGroup) {
        [_resGroup leave];
    }
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    XCTFail(@"Did fail unsubscription: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }

}

@end
