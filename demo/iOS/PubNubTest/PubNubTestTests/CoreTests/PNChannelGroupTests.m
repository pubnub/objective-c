//
//  PNChannelGroupTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import "TestConfigurator.h"

@interface PNChannelGroupTests : XCTestCase

@end

@implementation PNChannelGroupTests  {
    
    PubNub *_pubNub;
    NSString *_testChannel;
    NSString *_testGroup;
    
    BOOL _isTestError;
}

- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub.uuid = @"testUUID";
    
    _testChannel = @"testChannel";
    _testGroup = @"testGroup";
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}


#pragma mark - Tests

- (void)testAddChannelsToGroup {
    
    // Adding channels to group
    XCTestExpectation *addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    __block NSArray *addedChannels;
    
    [_pubNub addChannels:@[_testChannel] toGroup:_testGroup withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
             XCTFail(@"!!! Error during adding channels %@", status.data);
        } else {
            
            addedChannels = status.channelGroups;
        }
        [addChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
         }
    }];
    
    // Checking result
    XCTAssertEqual(@[_testChannel], addedChannels);
}

- (void)testGetChannelsForGroup {
    
    // Adding channels to group
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Getting channels from group
    XCTestExpectation *_getChannelsExpectation = [self expectationWithDescription:@"Getting channels for group"];
    __block NSArray *channelsForGroup;
    
    [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
             XCTFail(@"Error occurs during getting channels for group %@", status.data);
        } else {
            
            channelsForGroup = [status.data objectForKey:@"channels"];
        }
        [_getChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    XCTAssertEqual(@[_testChannel], channelsForGroup);
}

- (void)testGetGroups {
    
    // Get groups
    XCTestExpectation *_getGroupsExpectation = [self expectationWithDescription:@"Getting groups"];
    __block NSArray *resultGroups;
    
    [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting groups %@", status.data);
        } else {
            
            resultGroups = [status.data objectForKey:@"channelgroups"];
        }
        [_getGroupsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];

    // Checking result
    XCTAssertFalse(resultGroups == nil);
}

- (void)testRemoveChannelsFromGroup {
    
    // Adding channels to group
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Removing channels from group
    XCTestExpectation *_removeChannelsExpectation = [self expectationWithDescription:@"Removing channels from group"];
    __block NSArray *removedChannels;
    
    [_pubNub removeChannels:@[@"testChannel1"] fromGroup:@"testGroup" withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during removing channels from group %@", status.data);
        } else {
            
            removedChannels = [status.data objectForKey:@"channels"];
        }
        [_removeChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSArray *channelsGroup = [self channelsForGroup:_testGroup];
    XCTAssertEqual(channelsGroup, removedChannels);
}

- (void)testRemoveAllChannelsFromGroup {
    
    // Adding channels to group
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Removing all channels
    XCTestExpectation *_removeGroupExpectation = [self expectationWithDescription:@"Removing group"];
    __block NSArray *removedChannels;
    
    [_pubNub removeChannelsFromGroup:@"testGroup" withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during removing group %@", status.data);
            _isTestError = YES;
        } else {
            
         removedChannels = [status.data objectForKey:@"channels"];
        }
        [_removeGroupExpectation fulfill];;
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSArray *channelsGroup = [self channelsForGroup:_testGroup];
    XCTAssertEqual(channelsGroup, @[]);
}


#pragma mark - Private methods

- (void)createGroup:(NSString *)groupName withChannel:(NSString *)channelName {
    
    XCTestExpectation *_addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    
    [_pubNub addChannels:@[channelName] toGroup:groupName withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            NSLog(@"!!! Error occurs during adding channels %@", status.data);
            _isTestError = YES;
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
        
        return;
    }
}

- (NSArray *)channelsForGroup:(NSString *)group {
    
    XCTestExpectation *_getChannelsExpectation = [self expectationWithDescription:@"Getting channels for group"];
    __block NSArray *channelsForGroup;
    
    [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting channels for group %@", status.data);
            _isTestError = YES;
        } else {
            
            channelsForGroup = [status.data objectForKey:@"channels"];
        }
        [_getChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        return @[];
    }
    return channelsForGroup;
}

@end
