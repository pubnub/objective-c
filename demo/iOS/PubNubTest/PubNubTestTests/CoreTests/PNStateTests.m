//
//  PNStateTests.m
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


@interface PNStateTests : XCTestCase

@end

#warning together don't work and strong "self"

@implementation PNStateTests {
    
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

- (void)testStateForClientOnChannel {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    [_pubNub setState:@{@"Name" : @"Jeims", @"Surname" : @"Bond"} forUUID:@"testUUID" onChannel:@"testChannel" withCompletion:^(PNStatus *status) {
 
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_resGroup leave];
    }];
                        
    [_pubNub stateForUUID:@"testUUID" onChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
                        if (status.error) {
            
                            XCTFail(@"Error");
                        }
                        [_resGroup leave];
     }];

                        
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }}
     
- (void)testStateForClientOnGroup {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    [_pubNub setState:@{@"Name" : @"Jeims", @"Surname" : @"Bond"} forUUID:@"testUUID" onChannelGroup:@"testGroup" withCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    [_pubNub stateForUUID:@"testUUID" onChannelGroup:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }}


@end
