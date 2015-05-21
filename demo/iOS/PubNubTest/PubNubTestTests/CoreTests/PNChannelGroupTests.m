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
#import "TestConfigurator.h"

@interface PNChannelGroupTests : XCTestCase

@end

@implementation PNChannelGroupTests  {
    
    PubNub *_pubNub;
    BOOL _isTestError;
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

- (void)testChannelGroup {
    
    // Add channels to group
    XCTestExpectation *_addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    
    [_pubNub addChannels:@[@"testChannel1", @"testChannel2"] toGroup:@"testGroup" withCompletion:^(PNStatus *status) {

        if (status.isError) {
            
            _isTestError = YES;
            NSLog(@"!!! Error during adding channels %@", status.data);
        }
        [_addChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        XCTFail(@"Error occurs during adding channels to group");
        return;
    }
 
    // Get channels from group
     XCTestExpectation *_getChannelsExpectation = [self expectationWithDescription:@"Getting channels for group"];
    
    [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            _isTestError = YES;

            XCTFail(@"Error occurs during getting channels for group %@", status.data);
        }
        [_getChannelsExpectation fulfill];
    }];
    
    // Get group
    XCTestExpectation *_getGroupsExpectation = [self expectationWithDescription:@"Getting groups"];
    
    [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting groups %@", status.data);
        }
        [_getGroupsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        XCTFail(@"Error occurs during getting info");
        return;
    }
   
    
    // Remove channels from group
    XCTestExpectation *_removeChannelsExpectation = [self expectationWithDescription:@"Removing channels from group"];
    
    [_pubNub removeChannels:@[@"testChannel1"] fromGroup:@"testGroup" withCompletion:^(PNStatus *status) {

        if (status.isError) {
            
            XCTFail(@"Error occurs during removing channels from group %@", status.data);
        }
        [_removeChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        return;
    }

    
    // Remove group
    XCTestExpectation *_removeGroupExpectation = [self expectationWithDescription:@"Removing group"];
    
    [_pubNub removeChannelsFromGroup:@"testGroup" withCompletion:^(PNStatus *status) {

        if (status.isError) {
            
             XCTFail(@"Error occurs during removing group %@", status.data);
            _isTestError = YES;
        }
        [_removeGroupExpectation fulfill];;
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
}

@end
