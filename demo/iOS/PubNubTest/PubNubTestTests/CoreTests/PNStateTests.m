//
//  PNStateTests.m
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

@interface PNStateTests : XCTestCase

@end

#warning together don't work and strong "self"

@implementation PNStateTests {
    
    PubNub *_pubNub;
}

- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
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
 
                         if (status.isError) {
                             
                             XCTFail(@"Error occurs during setting state for client on channel %@", status.data);
                         }
                         [_setState fulfill];
    }];
                        
    [_pubNub stateForUUID:@"testUUID" onChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
                        if (status.isError) {
            
                            XCTFail(@"Error occurs during getting status for client on channel %@", status.data);
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
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during setting state for client on channelgroup %@", status.data);
        }
        [_setState fulfill];
    }];
    
    [_pubNub stateForUUID:@"testUUID" onChannelGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting status for client on channelgroup %@", status.data);
        }
        [_getState fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
}


@end
