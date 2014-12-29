//
//  ChaosSubscribeUnsubscribeTest.m
//  UnitTests
//
//  Created by Sergey Kazanskiy on 12/29/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ChaosSubscribeUnsubscribeTest : XCTestCase <PNDelegate> {
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

- (void)testSubscribeSeria {
    
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
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
    
//    Send message and unsubscribe from channel in order in one group
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:21];
    
    [PubNub subscribeOn:[PNChannel channelsWithNames:@[@"iosdev1",@"iosdev2",@"iosdev3",@"iosdev4",@"iosdev5",@"iosdev6",@"iosdev7",@"iosdev8",@"iosdev9",@"iosdev10"]]];
    
    [PubNub sendMessage:@"Hello iosdev1" toChannel:[PNChannel channelWithName:@"iosdev1"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev1"]]];
    
    [PubNub sendMessage:@"Hello iosdev2" toChannel:[PNChannel channelWithName:@"iosdev2"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev2"]]];
    
    [PubNub sendMessage:@"Hello iosdev3" toChannel:[PNChannel channelWithName:@"iosdev3"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev3"]]];
    
    [PubNub sendMessage:@"Hello iosdev4" toChannel:[PNChannel channelWithName:@"iosdev4"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev4"]]];
    
    [PubNub sendMessage:@"Hello iosdev5" toChannel:[PNChannel channelWithName:@"iosdev5"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev5"]]];
    
    [PubNub sendMessage:@"Hello iosdev6" toChannel:[PNChannel channelWithName:@"iosdev6"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev6"]]];
    
    [PubNub sendMessage:@"Hello iosdev7" toChannel:[PNChannel channelWithName:@"iosdev7"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev7"]]];
    
    [PubNub sendMessage:@"Hello iosdev8" toChannel:[PNChannel channelWithName:@"iosdev8"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev8"]]];
    
    [PubNub sendMessage:@"Hello iosdev9" toChannel:[PNChannel channelWithName:@"iosdev9"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev9"]]];
    
    [PubNub sendMessage:@"Hello iosdev10" toChannel:[PNChannel channelWithName:@"iosdev10"]];
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev10"]]];
    
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:20]) {
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
    }
    _resGroup = nil;
}

- (void)testSubscribeLoop {
    
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
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
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:n * 1.2]) {
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
}

// Unsubscribe from did
- (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
    if (_resGroup) {
        [_resGroup leave];
    }
    NSLog(@"!!! %@", channelObjects);
}

// Unsubscribe from fail
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    XCTFail(@"Did fail unsubscription: %@", error);
}

@end


//- (void)testAll {
//
//    for (int i = 0; i < 2; i++) {
//        [PubNub disconnect];
//        [self t1estSubscribeSeria];
//    }
//
//    for (int i = 0; i < 2; i++) {
//        [PubNub disconnect];
//        [GCDWrapper sleepForSeconds:1];
//        [self t2estSubscribeLoop];
//    }
//}



