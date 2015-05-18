//
//  PNChannelGroupTests.m
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


@interface PNChannelGroupTests : XCTestCase

@end

@implementation PNChannelGroupTests  {
    
    PubNub *_pubNub;
    GCDGroup *_resGroup;
}


- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}

- (void)testChannelGroup {
    
    // Add channels to group
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub addChannels:@[@"testChannel1", @"testChannel2"] toGroup:@"testGroup" withCompletion:^(PNStatus *status) {

        if (status.error) {
            
            XCTFail(@"Error"); //?
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired");
    }
 
    // Get channels from group
    [_resGroup enter];
    
    [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired");
    }
    
    // Get group
    [_resGroup enter];
    
    [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired");
    }
    
    
    // Remove channels from group
    [_resGroup enter];
    
    [_pubNub removeChannels:@[@"testChannel1"] fromGroup:@"testGroup" withCompletion:^(PNStatus *status) {

        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired");
    }

    
    // Remove group
    [_resGroup enter];
    
    [_pubNub removeChannelsFromGroup:@"testGroup" withCompletion:^(PNStatus *status) {

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
