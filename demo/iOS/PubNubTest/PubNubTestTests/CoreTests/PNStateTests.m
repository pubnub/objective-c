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

#import "TestConfigurator.h"

@interface PNStateTests : XCTestCase

@end

#warning together don't work and strong "self"

@implementation PNStateTests {
    
    PubNub *_pubNub;
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

- (void)testStateForClientOnChannel {
    
    XCTestExpectation *_setState = [self expectationWithDescription:@"Setting state for client on channel"];
    XCTestExpectation *_getState = [self expectationWithDescription:@"Getting state for client on channel"];
    
    [_pubNub setState:@{@"Name" : @"Jeims", @"Surname" : @"Bond"} forUUID:@"testUUID" onChannel:@"testChannel" withCompletion:^(PNStatus *status) {
 
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_setState fulfill];
    }];
                        
    [_pubNub stateForUUID:@"testUUID" onChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
                        if (status.error) {
            
                            XCTFail(@"Error");
                        }
                        [_getState fulfill];
     }];

                        
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
}
     
- (void)testStateForClientOnGroup {
    
    XCTestExpectation *_setState = [self expectationWithDescription:@"Setting state for client on channel"];
    XCTestExpectation *_getState = [self expectationWithDescription:@"Getting state for client on channel"];
    
    [_pubNub setState:@{@"Name" : @"Jeims", @"Surname" : @"Bond"} forUUID:@"testUUID" onChannelGroup:@"testGroup" withCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_setState fulfill];
    }];
    
    [_pubNub stateForUUID:@"testUUID" onChannelGroup:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_getState fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
}


@end
