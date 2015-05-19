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

- (void)testChannelGroup {
    
    // Add channels to group
    XCTestExpectation *_addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    
    [_pubNub addChannels:@[@"testChannel1", @"testChannel2"] toGroup:@"testGroup" withCompletion:^(PNStatus *status) {

        if (status.error) {
            
            XCTFail(@"Error"); //?
        }
        [_addChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestTimout handler:^(NSError *error) {
    }];
 
    // Get channels from group
     XCTestExpectation *_getChannelsExpectation = [self expectationWithDescription:@"Getting channels for group"];
    
    [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_getChannelsExpectation fulfill];
    }];
    
    // Get group
    XCTestExpectation *_getGroupsExpectation = [self expectationWithDescription:@"Getting groups"];
    
    [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_getGroupsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestTimout handler:^(NSError *error) {
    }];
    
    
    // Remove channels from group
    XCTestExpectation *_removeChannelsExpectation = [self expectationWithDescription:@"Removing channels from group"];
    
    [_pubNub removeChannels:@[@"testChannel1"] fromGroup:@"testGroup" withCompletion:^(PNStatus *status) {

        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_removeChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestTimout handler:^(NSError *error) {
    }];
    
    // Remove group
    XCTestExpectation *_removeGroupExpectation = [self expectationWithDescription:@"Removing group"];
    
    [_pubNub removeChannelsFromGroup:@"testGroup" withCompletion:^(PNStatus *status) {

        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_removeGroupExpectation fulfill];;
    }];
    
    [self waitForExpectationsWithTimeout:kTestTimout handler:^(NSError *error) {
    }];
}

@end
