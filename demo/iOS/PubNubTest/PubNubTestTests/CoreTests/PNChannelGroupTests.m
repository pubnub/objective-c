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
    int _numberOfTestChannels;
    
    BOOL _isTestError;
    NSException *_stopTestException;
}

- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] VadimPubKey] andSubscribeKey:[[TestConfigurator shared] VadimSubKey]];
    _pubNub.uuid = @"testUUID";
    
    _testChannel = @"testChannel";
    _testGroup = @"testGroup";
    
    _numberOfTestChannels = 3;
    
    _stopTestException = [NSException exceptionWithName:@"StopTestException"
                                                 reason:nil
                                               userInfo:nil];
}

- (void)tearDown {
    
    _pubNub = nil;
    [super tearDown];
}


#pragma mark - Add channels to group

- (void)testSimpleAddChannelsToGroup {
    
    // Preparing
    [self removeAllChannelsFromGroup:_testGroup];
    
    // Adding channels to group
    XCTestExpectation *addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    
    [_pubNub addChannels:@[_testChannel] toGroup:_testGroup withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
             XCTFail(@"Error during adding channels %@", status.data);
        }
        [addChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
         }
    }];
    
    // Checking result
     NSArray *channelsGroup  = [self channelsForGroup:_testGroup];
    XCTAssertFalse([channelsGroup containsObject:_testChannel], @"Channels for the group %@", channelsGroup);
}

- (void)testAddChannelsToGroupInBlock {
    
    // Preparing
    [self removeAllChannelsFromGroup:_testGroup];
    
    // Adding channels to group in complection block
    XCTestExpectation *addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    
    [_pubNub addChannels:@[@"testChannel1"] toGroup:_testGroup withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error during adding channels %@", status.data);
        } else {
            
            [_pubNub addChannels:@[@"testChannel2"] toGroup:_testGroup withCompletion:^(PNStatus *status) {
                
                if (status.isError) {
                    
                    XCTFail(@"Error during adding channels %@", status.data);
                } else {
                    
                    [_pubNub addChannels:@[@"testChannel3"] toGroup:_testGroup withCompletion:^(PNStatus *status) {
                        
                        if (status.isError) {
                            
                            XCTFail(@"Error during adding channels %@", status.data);
                        }
                        [addChannelsExpectation fulfill];
                    }];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Chesk that the array of subscribed channels contains all test channels
    NSSet *channelsGroupSet = [[NSSet alloc] initWithArray:[self channelsForGroup:_testGroup]];
    NSSet *testChannelsSet = [[NSSet alloc] initWithObjects:@"testChannel1", @"testChannel2", @"testChannel3", nil];
    XCTAssertTrue([testChannelsSet isSubsetOfSet:channelsGroupSet]);
}


- (void)testAddChannelsToGroupInLoop {
    
    // Preparing
    [self removeAllChannelsFromGroup:_testGroup];
    
    // Adding channels to group in complection block
    XCTestExpectation *addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    
    NSMutableArray *testChannels = [NSMutableArray new];
    
    for (int i = 1; i <= _numberOfTestChannels ; i++) {
        
        NSString *testChannel = [NSString stringWithFormat:@"testChannel%d", i];
        [testChannels addObject:testChannel];
        
         [_pubNub addChannels:@[testChannel] toGroup:_testGroup withCompletion:^(PNStatus *status) {
            
             if (status.isError) {
                 
                 XCTFail(@"!!! Error during adding channels %@", status.data);
             }
             
             if (i == _numberOfTestChannels) {
                 
                 [addChannelsExpectation fulfill];
             }
        }];
    }
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Chesk that the array of subscribed channels contains all test channels
    NSSet *channelsGroupSet = [[NSSet alloc] initWithArray:[self channelsForGroup:_testGroup]];
    NSSet *testChannelsSet = [[NSSet alloc] initWithArray:testChannels];
    XCTAssertTrue([testChannelsSet isSubsetOfSet:channelsGroupSet]);
}


#pragma mark - Get channels for group
#warning Error occurs sometimes
- (void)testSimpleGetChannelsForGroup {
    
    // Preparing
    [self removeAllChannelsFromGroup:_testGroup];
//    sleep(5);
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Getting channels for group
    XCTestExpectation *channelsExpectation = [self expectationWithDescription:@"Getting channels for group"];
    __block NSArray *resultChannels;
    
    [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
             XCTFail(@"Error occurs during getting channels for group %@", status.data);
        } else {
            
            resultChannels = (NSArray *)[result.data objectForKey:@"channels"];
        }
        [channelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    XCTAssertTrue([_testChannel isEqual:resultChannels[0]], @"Result channel: %@", resultChannels[0]);
}

- (void)testGetChannelsForGroupInBlock {
    
    // Preparig
    [self removeAllChannelsFromGroup:_testGroup];
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Getting channels for group
    XCTestExpectation *channelsExpectation = [self expectationWithDescription:@"Getting channels for group"];
    
    [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError || ![[result.data objectForKey:@"channels"][0] isEqual:_testChannel]) {
            
            XCTFail(@"Error occurs during getting channels for group %@", status.data);
        } else {
            
            [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
                
                if (status.isError || ![[result.data objectForKey:@"channels"][0] isEqual:_testChannel]) {
                    
                    XCTFail(@"Error occurs during getting channels for group %@", status.data);
                } else {
                    
                    [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
                        
                        if (status.isError || ![[result.data objectForKey:@"channels"][0] isEqual:_testChannel]) {
                            
                            XCTFail(@"Error occurs during getting channels for group %@", status.data);
                        }
                        [channelsExpectation fulfill];
                    }];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testGetChannelsForGroupInLoop {
    
    // Preparig
    [self removeAllChannelsFromGroup:_testGroup];
    [self createGroup:_testGroup withChannel:_testChannel];

    // Getting channels for group
    XCTestExpectation *channelsExpectation = [self expectationWithDescription:@"Getting channels for group"];
    
    for (int i = 1; i <= _numberOfTestChannels ; i++) {
    
        [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
            
            if (status.isError || ![[result.data objectForKey:@"channels"][0] isEqual:_testChannel]) {
                
                XCTFail(@"Error occurs during getting channels for group %@", status.data);
            }
            
            if (i == _numberOfTestChannels) {
                [channelsExpectation fulfill];
            }
        }];
    }
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
}

#pragma mark - Get groups

- (void)testSimpleGetGroups {
    
    // Preparig
    [self removeAllChannelsFromGroup:_testGroup];
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Getting groups
    XCTestExpectation *groupsExpectation = [self expectationWithDescription:@"Getting groups"];
    __block NSArray *resultGroups;
    
    [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting groups %@", status.data);
        } else {
            
            resultGroups = (NSArray *)[result.data objectForKey:@"channel-groups"];
        }
        [groupsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];

    // Checking result
    XCTAssertTrue([resultGroups containsObject:_testGroup], @"Сhannels for the group %@", resultGroups);
}

- (void)testGetGroupsInBlock {
    
    // Preparig
    [self removeAllChannelsFromGroup:_testGroup];
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Getting groups in block
    XCTestExpectation *groupsExpectation = [self expectationWithDescription:@"Getting groups"];
    
    [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError || ![[result.data objectForKey:@"channel-groups"] containsObject:_testGroup]) {
            
            XCTFail(@"Error occurs during getting groups %@", status.data);
        } else {
            
            [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
                
                if (status.isError || ![[result.data objectForKey:@"channel-groups"] containsObject:_testGroup]) {
                    
                    XCTFail(@"Error occurs during getting groups %@", status.data);
                } else {
                    
                    [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
                        
                        if (status.isError || ![[result.data objectForKey:@"channel-groups"] containsObject:_testGroup]) {
                            
                            XCTFail(@"Error occurs during getting groups %@", status.data);
                        }
                        [groupsExpectation fulfill];
                    }];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testGetGroupsInLoop {
    
    // Preparig
    [self removeAllChannelsFromGroup:_testGroup];
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Getting groups in loop
    XCTestExpectation *groupsExpectation = [self expectationWithDescription:@"Getting groups"];
    
    for (int i = 1; i <= _numberOfTestChannels ; i++) {
        
        [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
            
            if (status.isError || ![[result.data objectForKey:@"channel-groups"] containsObject:_testGroup]) {
                
                XCTFail(@"Error occurs during getting groups %@", status.data);
            }
            [groupsExpectation fulfill];
        }];
    }
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
}


#pragma mark - Remove channels from group

- (void)testSimpleRemoveChannelsFromGroup {
    
    // Preparig
    [self removeAllChannelsFromGroup:_testGroup];
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Removing channels from group
    XCTestExpectation *removeChannelsExpectation = [self expectationWithDescription:@"Removing channels from group"];
    
    [_pubNub removeChannels:@[_testChannel] fromGroup:_testGroup withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during removing channels from group %@", status.data);
        }
        [removeChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSArray *channelsGroup  = [self channelsForGroup:_testGroup];
    XCTAssertFalse([channelsGroup containsObject:_testChannel], @"Сhannels for the group %@", channelsGroup);
}

- (void)testRemoveChannelsFromGroupInBlock {
    
    // Preparing
    [self removeAllChannelsFromGroup:_testGroup];
    [self createGroup:_testGroup withChannel:@"testChannel1"];
    [self createGroup:_testGroup withChannel:@"testChannel2"];
    [self createGroup:_testGroup withChannel:@"testChannel3"];
    
    // Removing channels from group in block
    XCTestExpectation *removeChannelsExpectation = [self expectationWithDescription:@"Removing channels from group"];
    
    [_pubNub removeChannels:@[@"testChannel1"] fromGroup:_testGroup withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during removing channels from group %@", status.data);
        } else {
            
            [_pubNub removeChannels:@[@"testChannel2"] fromGroup:_testGroup withCompletion:^(PNStatus *status) {
                
                if (status.isError) {
                    
                    XCTFail(@"Error occurs during removing channels from group %@", status.data);
                } else {
                    
                    [_pubNub removeChannels:@[@"testChannel3"] fromGroup:_testGroup withCompletion:^(PNStatus *status) {
                        
                        if (status.isError) {
                            
                            XCTFail(@"Error occurs during removing channels from group %@", status.data);
                        }
                        [removeChannelsExpectation fulfill];
                    }];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSArray *channelsGroup  = [self channelsForGroup:_testGroup];
    XCTAssertTrue([channelsGroup count] == 0, @"Remaining channels %@", channelsGroup);
}

- (void)testRemoveChannelsFromGroupInLoop {
    
    // Preparing
    [self removeAllChannelsFromGroup:_testGroup];
    [self createGroup:_testGroup withChannel:@"testChannel1"];
    [self createGroup:_testGroup withChannel:@"testChannel2"];
    [self createGroup:_testGroup withChannel:@"testChannel3"];
    
    // Removing channels from group in loop
    XCTestExpectation *removeChannelsExpectation = [self expectationWithDescription:@"Removing channels from group"];
    
    for (int i = 1; i <= _numberOfTestChannels ; i++) {
        
        NSString *testChannel = [NSString stringWithFormat:@"testChannel%d", i];
        
        [_pubNub removeChannels:@[testChannel] fromGroup:_testGroup withCompletion:^(PNStatus *status) {
            
            if (status.isError) {
                
                XCTFail(@"Error occurs during removing channels from group %@", status.data);
            }
            
            if (i == _numberOfTestChannels) {
                
                [removeChannelsExpectation fulfill];
            }
        }];
    }
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSArray *channelsGroup  = [self channelsForGroup:_testGroup];
    XCTAssertTrue([channelsGroup count] == 0, @"Remaining channels %@", channelsGroup);
}


#pragma mark - Remove all channels from group

- (void)testSimpleRemoveAllChannelsFromGroup {
    
    // Adding channels to group
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Removing all channels
    XCTestExpectation *removeGroupExpectation = [self expectationWithDescription:@"Removing group"];
    
    [_pubNub removeChannelsFromGroup:@"testGroup" withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during removing group %@", status.data);
        }
        [removeGroupExpectation fulfill];;
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSArray *channelsGroup = [self channelsForGroup:_testGroup];
    XCTAssertTrue([channelsGroup count] == 0, @"Remaining channels %@", channelsGroup);
}

- (void)testRemoveAllChannelsFromGroupInBlock {
    
    // Adding channels to group
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Removing all channels several times in block
    XCTestExpectation *removeGroupExpectation = [self expectationWithDescription:@"Removing group"];
    
    [_pubNub removeChannelsFromGroup:@"testGroup" withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during removing group %@", status.data);
        } else {
            
            [_pubNub removeChannelsFromGroup:@"testGroup" withCompletion:^(PNStatus *status) {
                
                if (status.isError) {
                    
                    XCTFail(@"Error occurs during removing group %@", status.data);
                } else {
                    
                    [_pubNub removeChannelsFromGroup:@"testGroup" withCompletion:^(PNStatus *status) {
                        
                        if (status.isError) {
                            
                            XCTFail(@"Error occurs during removing group %@", status.data);
                        }
                        [removeGroupExpectation fulfill];;
                    }];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
}

#warning Error occurs sometimes
- (void)testRemoveAllChannelsFromGroupInLoop {
    
    // Adding channels to group
    [self createGroup:_testGroup withChannel:_testChannel];
    
    // Removing all channels
    XCTestExpectation *removeGroupExpectation = [self expectationWithDescription:@"Removing group"];
    
    for (int i = 1; i <= _numberOfTestChannels ; i++) {

        [_pubNub removeChannelsFromGroup:_testGroup withCompletion:^(PNStatus *status) {
            
            if (status.isError) {
                
                XCTFail(@"Error occurs during removing group %@", status.data);
            }
            
            if (i == _numberOfTestChannels) {
                
                [removeGroupExpectation fulfill];
            }
        }];
    }
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    NSArray *channelsGroup = [self channelsForGroup:_testGroup];
    XCTAssertTrue([channelsGroup count] == 0, @"Remaining channels %@", channelsGroup);
}


#pragma mark - Chaos tests
#warning Error occurs sometimes
- (void)testChaosInBlock {
    
    XCTestExpectation *groupExpectation = [self expectationWithDescription:@"Removing group"];
    
    [_pubNub removeChannelsFromGroup:_testGroup withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during removing all cannels from group %@", status.data);
        } else {
            
            [_pubNub addChannels:@[_testChannel] toGroup:_testGroup withCompletion:^(PNStatus *status) {

                if (status.isError) {

                    XCTFail(@"Error occurs during adding channels to group %@", status.data);
                } else {

                     [_pubNub channelsForGroup:_testGroup withCompletion:^(PNResult *result, PNStatus *status) {

                         if (status.isError || ![[result.data objectForKey:@"channels"] containsObject:_testChannel]) {

                             XCTFail(@"Error occurs during getting channels for group %@", status.data);
                         } else {

                             [_pubNub channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {

                                 if (status.isError || ![[result.data objectForKey:@"channel-groups"] containsObject:_testGroup]) {

                                     XCTFail(@"Error occurs during getting groups %@", status.data);
                                 } else {

                                     [_pubNub removeChannels:@[_testChannel] fromGroup:_testGroup withCompletion:^(PNStatus *status) {

                                         if (status.isError || [[result.data objectForKey:@"channels"] containsObject:_testChannel]) {

                                             XCTFail(@"Error occurs during removing channels from group %@", status.data);
                                         }
                                         [groupExpectation fulfill];
                                     }];
                                 }
                             }];
                         }
                     }];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
}

#pragma mark - Private methods

- (void)createGroup:(NSString *)groupName withChannel:(NSString *)channelName {
    
    XCTestExpectation *addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    
    [_pubNub addChannels:@[channelName] toGroup:groupName withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            NSLog(@"Error occurs during adding channels %@", status.data);
            _isTestError = YES;
        }
        [addChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        @throw _stopTestException;
    }
}

- (NSArray *)channelsForGroup:(NSString *)group {
    
    XCTestExpectation *channelsExpectation = [self expectationWithDescription:@"Getting channels for group"];
    __block NSArray *channelsForGroup;
    
    [_pubNub channelsForGroup:@"testGroup" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting channels for group %@", status.data);
            _isTestError = YES;
        } else {
            
            channelsForGroup = [result.data objectForKey:@"channels"];
        }
        [channelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        @throw _stopTestException;
    }
    return channelsForGroup;
}

- (void)removeAllChannelsFromGroup:(NSString *)group {
    
    XCTestExpectation *removeGroupExpectation = [self expectationWithDescription:@"Removing group"];
    
    [_pubNub removeChannelsFromGroup:group withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during removing group %@", status.data);
            _isTestError = YES;
        }
        [removeGroupExpectation fulfill];;
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        @throw _stopTestException;
    }
}

@end
