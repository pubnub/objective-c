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
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}


- (void)testPresenceForChannel {

    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    XCTestExpectation *_hereNowOccupancyExpectation = [self expectationWithDescription:@"Getting hereNowOccupancy"];
    XCTestExpectation *_hereNowUUIDExpectation = [self expectationWithDescription:@"Getting hereNowUUID"];
    XCTestExpectation *_hereNowStateExpectation = [self expectationWithDescription:@"Getting hereNowState"];
    
    [_pubNub subscribeToChannels:@[@"testChannel1"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_subscribeExpectation fulfill];
    }];
    
    [_pubNub hereNowData:PNHereNowOccupancy forChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
  
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_hereNowOccupancyExpectation fulfill];
    }];
    
    [_pubNub hereNowData:PNHereNowUUID forChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_hereNowUUIDExpectation fulfill];
    }];
    
    
    [_pubNub hereNowData:PNHereNowState forChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_hereNowStateExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestTimout handler:^(NSError *error) {
    }];
}

- (void)testPresenceForGroup {
    
    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    XCTestExpectation *_hereNowOccupancyExpectation = [self expectationWithDescription:@"Getting hereNowOccupancy"];
    XCTestExpectation *_hereNowUUIDExpectation = [self expectationWithDescription:@"Getting hereNowUUID"];
    XCTestExpectation *_hereNowStateExpectation = [self expectationWithDescription:@"Getting hereNowState"];
    
    [_pubNub subscribeToChannels:@[@"testChannel1"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_subscribeExpectation fulfill];
        
    }];
    
    [_pubNub hereNowData:PNHereNowOccupancy forChannelGroup:@"testGroup1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        
        [_hereNowOccupancyExpectation fulfill];
    }];
    
    [_pubNub hereNowData:PNHereNowUUID forChannelGroup:@"testGroup1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_hereNowUUIDExpectation fulfill];
    }];
    
    
    [_pubNub hereNowData:PNHereNowState forChannelGroup:@"testGroup1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_hereNowStateExpectation fulfill];;
    }];
    
    [self waitForExpectationsWithTimeout:kTestTimout handler:^(NSError *error) {
    }];
}

@end
