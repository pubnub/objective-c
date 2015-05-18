//
//  PNPresenceTests.m
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

@interface PNPresenceTests : XCTestCase

@end

@implementation PNPresenceTests {
    
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


- (void)testPresenceForChannel {

    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub subscribeToChannels:@[@"testChannel1"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
        
    }];
    
    [_pubNub hereNowData:PNHereNowOccupancy forChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
  
        if (status.error) {
            
            XCTFail(@"Error");
        }
        
        [_resGroup leave];
    }];
    
    [_pubNub hereNowData:PNHereNowUUID forChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        
        [_resGroup leave];
    }];
    
    
    [_pubNub hereNowData:PNHereNowState forChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during publishing");
    }
}

- (void)testPresenceForGroup {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub subscribeToChannels:@[@"testChannel1"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
        
    }];
    
    [_pubNub hereNowData:PNHereNowOccupancy forChannelGroup:@"testGroup1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        
        [_resGroup leave];
    }];
    
    [_pubNub hereNowData:PNHereNowUUID forChannelGroup:@"testGroup1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        
        [_resGroup leave];
    }];
    
    
    [_pubNub hereNowData:PNHereNowState forChannelGroup:@"testGroup1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during publishing");
    }
}

@end
