//
//  PNSubscribeTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import "TestConfigurator.h"

@interface PNSubscribeTests : XCTestCase <PNObjectEventListener>

@end

@implementation PNSubscribeTests {
    
    PubNub *_pubNub;
    PubNub *_pubNub1;
    PubNub *_pubNub2;
    BOOL _clientListening;
    
    XCTestExpectation *_receiveStatusExpectation;
    XCTestExpectation *_receiveMessageExpectation;
    
    int _numberOfTestChannels;
    int _numberOfTestGroups;
    int _numberOfTestPresences;
    
    BOOL _isTestError;
    NSException *_stopTestException;
}

- (void)setUp {
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub.uuid = @"testUUID";
    
    _pubNub1 = [PubNub clientWithPublishKey:[[TestConfigurator shared] adminPubKey] andSubscribeKey:[[TestConfigurator shared] adminSubKey]];
    _pubNub1.uuid = @"testUUID1";
    _pubNub2 = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub2.uuid = @"testUUID2";
    
    _numberOfTestChannels = 10;
    _numberOfTestGroups = 10;
    _numberOfTestPresences = 10;
    
    _stopTestException = [NSException exceptionWithName:@"StopTestException"
                                                 reason:nil
                                               userInfo:nil];
}

- (void)tearDown {
    
    _pubNub = nil;
    _pubNub1 = nil;
    _pubNub2 = nil;
    [super tearDown];
}

#pragma mark - Subscribe / unsubscribe channels

- (void)testSubscribeToChannelsInBlock {
    
    // Subscribe to channels inside complection block
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToChannels:@[@"testChannel1"] withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.isError) {
                             
                             XCTFail(@"Error occurs during subscription %@", status.data);
                             _isTestError = YES;
                         } else {
                             
                             [_pubNub subscribeToChannels:@[@"testChannel2"] withPresence:YES
                                              clientState:nil andCompletion:^(PNStatus *status) {
                                                  
                                                  if (status.isError) {
                                                      
                                                      XCTFail(@"Error occurs during subscription %@", status.data);
                                                      _isTestError = YES;
                                                  } else {
                                                      
                                                      [_pubNub subscribeToChannels:@[@"testChannel3"] withPresence:YES
                                                                       clientState:nil andCompletion:^(PNStatus *status) {
                                                                           
                                                                           if (status.isError) {
                                                                               
                                                                               XCTFail(@"Error occurs during subscription %@", status.data);
                                                                               _isTestError = YES;
                                                                           }
                                                                           [subscribeExpectation fulfill];
                                                                       }];
                                                  }
                                              }];
                        }
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
    
     // Chesk that the array of subscribed channels contains all test channels
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:[_pubNub channels]];
    NSSet *testChannelsSet = [[NSSet alloc] initWithObjects:@"testChannel1", @"testChannel2", @"testChannel3", nil];
    XCTAssertTrue([testChannelsSet isSubsetOfSet:subscribedChannelsSet]);
}

- (void)testSubscribeToChannelsInLoop {
    
    // Subscribe to channels in loop
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    NSMutableArray *testChannels = [NSMutableArray new];
    __block NSMutableArray *subscribedChannels = [NSMutableArray new];
    
    int numberOfTestChannels = 10;
    
    for (int i = 1; i <= numberOfTestChannels ; i++) {
        
        NSString *testChannel = [NSString stringWithFormat:@"testChannel%d", i];
        [testChannels addObject:testChannel];
        
        [_pubNub subscribeToChannels:@[testChannel] withPresence:YES andCompletion:^(PNStatus *status) {
            
            if (status.isError) {
                
                XCTFail(@"Error occurs during subscription %@", status.data);
                _isTestError = YES;
            }
            
            NSUInteger index = [status.channels indexOfObject:testChannel];
            if (index != NSNotFound) {
                
                [subscribedChannels addObject:status.channels[index]];
            }
            
            if (i == numberOfTestChannels) {
                
                [subscribeExpectation fulfill];
            }
        }];
    }
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        return;
    }
    
    // Chesk that the array of subscribed channels contains  all testchannels
    NSSet *testChannelsSet = [[NSSet alloc] initWithArray:testChannels];
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:subscribedChannels];
    XCTAssertTrue([testChannelsSet isSubsetOfSet:subscribedChannelsSet], @"test channels %@, subscribed channels %@", testChannels, subscribedChannels);
}

- (void)testUnsubscribeFromChannelsInBlock {
    
    // Subscribe to channels
    [self subscribeOnChannels:@[@"testChannel1", @"testChannel2", @"testChannel3"]];
    
    // Unsubscribe from channels inside complection block
    XCTestExpectation *unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    [_pubNub unsubscribeFromChannels:@[@"testChannel1"]
                        withPresence:YES andCompletion:^(PNStatus *status) {
                            
                            if (status.isError) {
                                
                                XCTFail(@"Error occurs during subscription %@", status.data);
                                _isTestError = YES;
                            } else {
                                
                                [_pubNub unsubscribeFromChannels:@[@"testChannel2"]
                                                    withPresence:YES andCompletion:^(PNStatus *status) {
                                                        
                                                        if (status.isError) {
                                                            
                                                            XCTFail(@"Error occurs during subscription %@", status.data);
                                                            _isTestError = YES;
                                                        } else {
                                                            
                                                            [_pubNub unsubscribeFromChannels:@[@"testChannel3"]
                                                                                withPresence:YES andCompletion:^(PNStatus *status) {
                                                                                    
                                                                                    if (status.isError) {
                                                                                        
                                                                                        XCTFail(@"Error occurs during subscription %@", status.data);
                                                                                        _isTestError = YES;
                                                                                    }
                                                                                    [unsubscribeExpectation fulfill];
                                                                                }];
                                                        }
                                                    }];
                            }
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
    
    // Chesk that the array of subscribed channels don't contains any test channel
    NSSet *testChannelsSet = [[NSSet alloc] initWithObjects:@"testChannel1", @"testChannel2", @"testChannel3", nil];
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:[_pubNub channels]];
    XCTAssertFalse([testChannelsSet intersectsSet:subscribedChannelsSet]);
}

- (void)testUnsubscribeFromChannelsInLoop {
    
    // Subscribe to severel channels
    NSMutableArray *testChannels = [NSMutableArray new];
    
     for (int i = 1; i <= _numberOfTestChannels ; i++) {
        
        [testChannels addObject:[NSString stringWithFormat:@"testChannel%d", i]];
    }
    [self subscribeOnChannels:testChannels];
     
    // Unsubscribe from the channels in loop
    XCTestExpectation *unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    for (int i = 1; i <= _numberOfTestChannels ; i++) {
        
        [_pubNub unsubscribeFromChannels:@[[NSString stringWithFormat:@"testChannel%d", i]] withPresence:YES andCompletion:^(PNStatus *status) {

            if (status.isError) {
                
                XCTFail(@"Error occurs during subscription %@", status.data);
                _isTestError = YES;
            }
            
            if (i == _numberOfTestChannels) {
                
                [unsubscribeExpectation fulfill];
            }
        }];
    }
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        return;
    }
    
    // Chesk that the array of subscribed channels don't contains any test channel
    NSSet *testChannelsSet = [[NSSet alloc] initWithArray:testChannels];
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:[_pubNub channels]];
    XCTAssertFalse([testChannelsSet intersectsSet:subscribedChannelsSet]);
}


#pragma mark - Subscribe / unsubscribe groups

#warning Error occurs during adding channels to group

- (void)testSubscribeToGroupsInBlock {
    
    // Create groups in loop
    for (int i = 1; i <= 3; i++) {
        
        [self createGroup:[NSString stringWithFormat:@"testGroup%d", i] withChannel:[NSString stringWithFormat:@"testChannel%d", i]];
    }

    // Subscribe to groups inside complection block
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub1 subscribeToChannelGroups:@[@"testGroup1"] withPresence:YES
                          clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.isError) {
                             
                             XCTFail(@"Error occurs during subscription %@", status.data);
                             _isTestError = YES;
                         } else {
                             
                             [_pubNub1 subscribeToChannelGroups:@[@"testGroup2"] withPresence:YES
                                                   clientState:nil andCompletion:^(PNStatus *status) {
                                                  
                                                  if (status.isError) {
                                                      
                                                      XCTFail(@"Error occurs during subscription %@", status.data);
                                                      _isTestError = YES;
                                                  } else {
                                                      
                                                      [_pubNub1 subscribeToChannelGroups:@[@"testGroup3"] withPresence:YES
                                                                            clientState:nil andCompletion:^(PNStatus *status) {
                                                                           
                                                                           if (status.isError) {
                                                                               
                                                                               XCTFail(@"Error occurs during subscription %@", status.data);
                                                                               _isTestError = YES;
                                                                           }
                                                                           [subscribeExpectation fulfill];
                                                                       }];
                                                  }
                                              }];
                         }
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
    
    // Chesk that the array of subscribed channels contains all test channels
    NSSet *subscribedGroupsSet = [[NSSet alloc] initWithArray:[_pubNub1 channelGroups]];
    NSSet *testGroupsSet = [[NSSet alloc] initWithObjects:@"testGroup1", @"testGroup2", @"testGroup3", nil];
    XCTAssertTrue([testGroupsSet isSubsetOfSet:subscribedGroupsSet]);
}

- (void)t1estSubscribeToGroupsInLoop {
    
    // Create groups in loop
    for (int i = 1; i <= _numberOfTestGroups ; i++) {
        
        [self createGroup:[NSString stringWithFormat:@"testGroup%d",i] withChannel:[NSString stringWithFormat:@"testChannel%d",i]];
    }
    
    // Subscribe to groups in loop
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    NSMutableArray *testGroups = [NSMutableArray new];
    __block NSMutableArray *subscribedGroups = [NSMutableArray new];
    
    for (int i = 1; i <= _numberOfTestGroups ; i++) {
        
        NSString *testGroup = [NSString stringWithFormat:@"testGroup%d", i];
        [testGroups addObject:testGroup];
        
        [_pubNub subscribeToChannelGroups:@[testGroup] withPresence:YES andCompletion:^(PNStatus *status) {
            
            if (status.isError) {
                
                XCTFail(@"Error occurs during subscription %@", status.data);
                _isTestError = YES;
            }
            
            NSUInteger index = [status.channelGroups indexOfObject:testGroup];
            if (index != NSNotFound) {
                
                [subscribedGroups addObject:status.channelGroups[index]];
            }
            
            if (i == _numberOfTestGroups) {
                
                [subscribeExpectation fulfill];
            }
        }];
    }
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        return;
    }
    
    // Chesk that the array of subscribed channels contains  all testchannels
    NSSet *testGroupsSet = [[NSSet alloc] initWithArray:testGroups];
    NSSet *subscribedGroupsSet = [[NSSet alloc] initWithArray:subscribedGroups];
    XCTAssertTrue([testGroupsSet isSubsetOfSet:subscribedGroupsSet], @"test channels %@, subscribed channels %@", testGroups, subscribedGroups);
}

- (void)t1estUnubscribeFromGroupsInBlock {
    
    // Create groups
    [self createGroup:@"testGroup1" withChannel:@"testChannel1"];
    [self createGroup:@"testGroup2" withChannel:@"testChannel2"];
    [self createGroup:@"testGroup3" withChannel:@"testChannel3"];
    
    // Subscribe to groups
    [self subscribeOnChannelGroups:@[@"testGroup1", @"testGroup2", @"testGroup3"]];
    
    // Unsubscribe from channels inside complection block
    XCTestExpectation *unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    [_pubNub unsubscribeFromChannelGroups:@[@"testGroup1"]
                             withPresence:YES andCompletion:^(PNStatus *status) {
                            
                            if (status.isError) {
                                
                                XCTFail(@"Error occurs during subscription %@", status.data);
                                _isTestError = YES;
                            } else {
                                
                                [_pubNub unsubscribeFromChannelGroups:@[@"testGroup2"]
                                                         withPresence:YES andCompletion:^(PNStatus *status) {
                                                        
                                                        if (status.isError) {
                                                            
                                                            XCTFail(@"Error occurs during subscription %@", status.data);
                                                            _isTestError = YES;
                                                        } else {
                                                            
                                                            [_pubNub unsubscribeFromChannelGroups:@[@"testGroup3"]
                                                                                     withPresence:YES andCompletion:^(PNStatus *status) {
                                                                                    
                                                                                    if (status.isError) {
                                                                                        
                                                                                        XCTFail(@"Error occurs during subscription %@", status.data);
                                                                                        _isTestError = YES;
                                                                                    }
                                                                                    [unsubscribeExpectation fulfill];
                                                                                }];
                                                        }
                                                    }];
                            }
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
    
    // Chesk that the array of subscribed channels don't contains any test channel
    NSSet *testGroupsSet = [[NSSet alloc] initWithObjects:@"testGroup1", @"testGroup2", @"testGroup3", nil];
    NSSet *subscribedGroupsSet = [[NSSet alloc] initWithArray:[_pubNub channelGroups]];
    XCTAssertFalse([testGroupsSet intersectsSet:subscribedGroupsSet]);
}

- (void)t1estUnubscribeFromGroupsInLoop {
    
    // Create groups in loop
    int numberOfTestGroups = 10;
    NSMutableArray *testGroups = [NSMutableArray new];
    
    for (int i = 1; i <= numberOfTestGroups ; i++) {
        
        [self createGroup:[NSString stringWithFormat:@"testGroup%d",i] withChannel:[NSString stringWithFormat:@"testChannel%d",i]];
        [testGroups addObject:[NSString stringWithFormat:@"testGroup%d", i]];
    }
    
    // Subscribe to groups
    [self subscribeOnChannelGroups:testGroups];
    
    // Unsubscribe from groups in loop
    XCTestExpectation *unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    for (int i = 1; i <= numberOfTestGroups ; i++) {
        
        [_pubNub unsubscribeFromChannelGroups:@[[NSString stringWithFormat:@"testChannel%d", i]] withPresence:YES andCompletion:^(PNStatus *status) {
            
            if (status.isError) {
                
                XCTFail(@"Error occurs during subscription %@", status.data);
                _isTestError = YES;
            }
            
            if (i == numberOfTestGroups) {
                
                [unsubscribeExpectation fulfill];
            }
        }];
    }
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        return;
    }
    
    // Chesk that the array of subscribed channels don't contains any test channel
    NSSet *testGroupsSet = [[NSSet alloc] initWithArray:testGroups];
    NSSet *subscribedGroupsSet = [[NSSet alloc] initWithArray:[_pubNub channelGroups]];
    XCTAssertFalse([testGroupsSet intersectsSet:subscribedGroupsSet]);
}


#pragma mark - Subscribe / unsubscribe presenceChannels

- (void)testSimpleSubUnsubPresenceChannels {
    
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToPresenceChannels:@[@"testPresenceChannel-pnpres"] withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during subscription %@", status.data);
            [subscribeExpectation fulfill];
        } else {
            
            [_pubNub unsubscribeFromPresenceChannels:@[@"testPresenceChannel-pnpres"] andCompletion:^(PNStatus *status) {
                
                if (status.isError) {
                    
                    XCTFail(@"Error occurs during unsubscription %@", status.data);
                }
                [subscribeExpectation fulfill];
            }];
       }
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
}
- (void)testSubscribeToPresenceChannelsInBlock {
    
    // Subscribe to channels inside complection block
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToPresenceChannels:@[@"testPresenceChannel1"] withCompletion:^(PNStatus *status) {
        
                         if (status.isError) {
                             
                             XCTFail(@"Error occurs during subscription %@", status.data);
                             _isTestError = YES;
                         } else {
                             
                             [_pubNub subscribeToPresenceChannels:@[@"testPresenceChannel2"] withCompletion:^(PNStatus *status) {
                                 
                                                  if (status.isError) {
                                                      
                                                      XCTFail(@"Error occurs during subscription %@", status.data);
                                                      _isTestError = YES;
                                                  } else {
                                                      
                                                      [_pubNub subscribeToPresenceChannels:@[@"testPresenceChannel3"] withCompletion:^(PNStatus *status) {
                                                                           
                                                                           if (status.isError) {
                                                                               
                                                                               XCTFail(@"Error occurs during subscription %@", status.data);
                                                                               _isTestError = YES;
                                                                           }
                                                                           [subscribeExpectation fulfill];
                                                                       }];
                                                  }
                                              }];
                         }
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
    
    // Chesk that the array of subscribed channels contains all test channels
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:[_pubNub presenceChannels]];
    NSSet *testChannelsSet = [[NSSet alloc] initWithObjects:@"testPresenceChannel1", @"testPresenceChannel2", @"testPresenceChannel3", nil];
    XCTAssertTrue([testChannelsSet isSubsetOfSet:subscribedChannelsSet]);
}

- (void)testSubscribeToPresenceChannelsInLoop {
    
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    NSMutableArray *testChannels = [NSMutableArray new];
    __block NSMutableArray *subscribedChannels = [NSMutableArray new];
    
    for (int i = 1; i <= _numberOfTestChannels ; i++) {
        
        NSString *testChannel = [NSString stringWithFormat:@"testPresenceChannel%d", i];
        [testChannels addObject:testChannel];
        
        [_pubNub subscribeToPresenceChannels:@[testChannel] withCompletion:^(PNStatus *status) {
            
            if (status.isError) {
                
                XCTFail(@"Error occurs during subscription");
                _isTestError = YES;
            }
            
            NSUInteger index = [status.channels indexOfObject:testChannel];
            if (index != NSNotFound) {
                
                [subscribedChannels addObject:status.channels[index]];
            }
            
            if (i == _numberOfTestChannels) {
                
                [subscribeExpectation fulfill];
            }
        }];
    }
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        return;
    }
    
    // Chesk that the array of subscribed channels contains  all testchannels
    NSSet *testChannelsSet = [[NSSet alloc] initWithArray:testChannels];
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:subscribedChannels];
    XCTAssertTrue([testChannelsSet isSubsetOfSet:subscribedChannelsSet], @"test channels %@, subscribed channels %@", testChannels, subscribedChannels);
}

#warning Error occurs during Unsubscription

- (void)testUnsubscribeFromPresenceChannelsInBlock {
    
    // Subscribe to PresenceChannels
    [self subscribeOnPresenceChannels:@[@"testPresenceChannel1-pnpres", @"testPresenceChannel2-pnpres", @"testPresenceChannel3-pnpres"]];
    
    // Unsubscribe from PresenceChannels inside complection block
    XCTestExpectation *unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    [_pubNub unsubscribeFromPresenceChannels:@[@"testPresenceChannel1-pnpres"] andCompletion:^(PNStatus *status) {
                            
                            if (status.isError) {
                                
                                XCTFail(@"Error occurs during unsubscription %@", status.data);
                                _isTestError = YES;
                            } else {
                                
                                [_pubNub unsubscribeFromPresenceChannels:@[@"testPresenceChannel2-pnpres"] andCompletion:^(PNStatus *status) {
                                                        
                                                        if (status.isError) {
                                                            
                                                            XCTFail(@"Error occurs during unsubscription %@", status.data);
                                                            _isTestError = YES;
                                                        } else {
                                                            
                                                            [_pubNub unsubscribeFromPresenceChannels:@[@"testPresenceChannel3-pnpres"] andCompletion:^(PNStatus *status) {
                                                                                    
                                                                                    if (status.isError) {
                                                                                        
                                                                                        XCTFail(@"Error occurs during unsubscription %@", status.data);
                                                                                        _isTestError = YES;
                                                                                    }
                                                                                    [unsubscribeExpectation fulfill];
                                                                                }];
                                                        }
                                                    }];
                            }
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
    
    // Chesk that the array of subscribed channels don't contains any test channel
    NSSet *testChannelsSet = [[NSSet alloc] initWithObjects:@"testPresenceChannel1-pnpres", @"testPresenceChannel2-pnpres", @"testPresenceChannel3-pnpres", nil];
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:[_pubNub presenceChannels]];
    XCTAssertFalse([testChannelsSet intersectsSet:subscribedChannelsSet]);
}

#warning Error occurs during Unsubscription

- (void)testUnsubscribeFromPresenceChannelsInLoop {
    
    // Subscribe to PresenceChannels
    NSMutableArray *testPresenceChannels = [NSMutableArray new];
    
    for (int i = 1; i <= _numberOfTestChannels ; i++) {
        
        [testPresenceChannels addObject:[NSString stringWithFormat:@"testPresenceChannel%d", i]];
    }
    [self subscribeOnPresenceChannels:testPresenceChannels];
    
    // Unsubscribe from channels in loop
    XCTestExpectation *unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    for (int i = 1; i <= _numberOfTestChannels ; i++) {
        
        [_pubNub unsubscribeFromPresenceChannels:@[[NSString stringWithFormat:@"testPresenceChannel%d", i]] andCompletion:^(PNStatus *status) {
            
            if (status.isError) {
                
                XCTFail(@"Error occurs during unsubscription %@", status.data);
                _isTestError = YES;
            }
            
            if (i == _numberOfTestChannels) {
                
                [unsubscribeExpectation fulfill];
            }
        }];
    }
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        return;
    }

    // Chesk that the array of subscribed channels don't contains any test presenceChannels
    NSSet *testChannelsSet = [[NSSet alloc] initWithArray:testPresenceChannels];
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:[_pubNub presenceChannels]];
    XCTAssertFalse([testChannelsSet intersectsSet:subscribedChannelsSet]);
}

     
#pragma mark - Return subscribed objects

- (void)testReturnSubscribedChannels {
    
    // Prepare data
    NSArray *testChannels = @[@"testChannel1", @"testChannel2"];
    [self subscribeOnChannels:testChannels];
    
    // Get subscribed channels
    NSArray *subscribedChannels = [_pubNub channels];
    
    // Checking result
    NSSet *channelsSet = [[NSSet alloc] initWithArray:testChannels];
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:subscribedChannels];
    XCTAssertTrue([channelsSet isSubsetOfSet:subscribedChannelsSet]);
}

#warning _pubNub channelGroups don't work

- (void)testReturnSubscribedGroups {
    
    // Prepare data
    [self createGroup:@"testGroup1" withChannel:@"testChannel1"];
    [self createGroup:@"testGroup2" withChannel:@"testChannel2"];
    
    NSArray *testGroups = @[@"testGroup1", @"testGroup2"];
    [self subscribeOnChannelGroups:testGroups];
    
    // Get subscribed groups
    NSArray *subscribedGroups = [_pubNub channelGroups];
    
    // Checking result
    NSSet *groupsSet = [[NSSet alloc] initWithArray:testGroups];
    NSSet *subscribedGroupsSet = [[NSSet alloc] initWithArray:subscribedGroups];
    XCTAssertTrue([groupsSet isSubsetOfSet:subscribedGroupsSet]);
}

- (void)testReturnSubscribedPresenceChannels {
    
    // Prepare data
    NSArray *testChannels = @[@"testChannel1-pnpres", @"testChannel2-pnpres"];
    [self subscribeOnPresenceChannels:testChannels];
    
    // Get subscribed channels
    NSArray *subscribedChannels = [_pubNub presenceChannels];
    
    // Checking result
    NSSet *channelsSet = [[NSSet alloc] initWithArray:testChannels];
    NSSet *subscribedChannelsSet = [[NSSet alloc] initWithArray:subscribedChannels];
    XCTAssertTrue([channelsSet isSubsetOfSet:subscribedChannelsSet]);
}

- (void)testCheckIsSubscribeOn {
    
    // Prepare data
    [self subscribeOnChannels:@[@"testChannel"]];
    [self subscribeOnPresenceChannels:@[@"testPresenceChannel"]];
    
    [self createGroup:@"testGroup" withChannel:@"testChannel"];
    [self subscribeOnChannelGroups:@[@"testGroup"]];
    
    // Checking result
    XCTAssertTrue([_pubNub isSubscribedOn:@"testChannel"]);
    XCTAssertTrue([_pubNub isSubscribedOn:@"testGroup"]);
    XCTAssertTrue([_pubNub isSubscribedOn:@"testPresenceChannel"]);
}


#pragma mark - Listeners

- (void)testAddRemoveListeners {
    
    // Add listeners
    [_pubNub addListeners:@[self]];
    _clientListening = YES;
    
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    _receiveStatusExpectation = [self expectationWithDescription:@"Delegate:'ReceiveStatus'"];
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    _receiveMessageExpectation = [self expectationWithDescription:@"Delegate:'ReceiveMessage'"];
    
    // Delegate:"ReceiveStatus" have to invoked
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.isError) {
                             
                             XCTFail(@"Error %@", status.data);
                             _isTestError = YES;
                         }
                         [subscribeExpectation fulfill];
                     }];
    
    // Delegate:"ReceivePresenceEvent" have to invoked
//    [_pubNub2 subscribeToChannels:@[@"testChannel1"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
//        
//        if (status.isError) {
//            
//            XCTFail(@"Error %@", status.data);
//           _isTestError = YES;
//        }
//        [_resGroup leave];
//        
//    }];
    
    // Delegate:"ReceiveMessage" have to invoked
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:YES withCompletion:^(PNStatus *status) {
     
        if (status.isError) {
            
            XCTFail(@"Error %@", status.data);
            _isTestError = YES;
        }
        [_publishExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    

    //      Remove listeners
    [_pubNub removeListeners:@[self]];
    _clientListening = NO;
    
    
    XCTestExpectation *unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    // Delegate:"ReceiveStatus" have not be invoked
    [_pubNub unsubscribeFromChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES andCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error %@", status.data);
            _isTestError = YES;
        }
        [unsubscribeExpectation fulfill];
    }];
    
    
    // Delegate:"ReceivePresenceEvent" have not be invoked
//    [_pubNub2 unsubscribeFromChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES andCompletion:^(PNStatus *status) {
//        
//        if (status.isError) {
//            
//            XCTFail(@"Error");
//           _isTestError = YES;
//        }
//        [_resGroup leave];
//        
//    }];

    _publishExpectation = [self expectationWithDescription:@"Send message"];
    
    // Delegate:"ReceiveMessage" have not be invoked
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:YES withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error %@", status.data);
            _isTestError = YES;
        }
        [_publishExpectation fulfill];
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


#pragma mark - Delegate methods

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    if (_receiveStatusExpectation && _clientListening) {
        
        [_receiveStatusExpectation fulfill];
    } else if (_receiveStatusExpectation && !_clientListening) {
        
        XCTFail(@"Error");
        _isTestError = YES;
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    
//    if (_resGroup && _clientListening) {
//        
//        [_resGroup leave];
//    } else if ((_resGroup && !_clientListening) ) {
//        
//        XCTFail(@"Error");
//       _isTestError = YES;
//    }
}

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message {
    
    if (_receiveMessageExpectation && _clientListening) {
        
        [_receiveMessageExpectation fulfill];
    } else if ((_receiveMessageExpectation && !_clientListening) ) {
        
        XCTFail(@"Error");
        _isTestError = YES;
    }
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
        @throw _stopTestException;
    }
}

- (void)subscribeOnChannels:(NSArray *)channels {
    
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    __block NSArray *statusChannels;

    [_pubNub subscribeToChannels:channels withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.isError) {
                             
                             XCTFail(@"Error occurs during subscription %@", status.data);
                             _isTestError = YES;
                         } else {
                             
                             statusChannels = status.channels;
                         }
                         [subscribeExpectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    // Checking received from PNStatus channels
    NSSet *channelsSet = [[NSSet alloc] initWithArray:channels];
    NSSet *statusChannelsSet = [[NSSet alloc] initWithArray:statusChannels];
    XCTAssertTrue([channelsSet isSubsetOfSet:statusChannelsSet]);
    
    // Checking isSubscribedOn
    for (NSString *testChannel in channels) {
        
        if (![_pubNub isSubscribedOn:testChannel]) {
            
            XCTFail(@"Error client didn't subscribe on all specified channels");
            _isTestError = YES;
        }
    }
    
    if (_isTestError) {
        @throw _stopTestException;
    }
}

- (void)subscribeOnChannelGroups:(NSArray *)groups {
    
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    __block NSArray *statusGroups;
    
    [_pubNub subscribeToChannelGroups:groups withPresence:YES andCompletion:^(PNStatus *status) {

                         if (status.isError) {
                             
                             XCTFail(@"Error occurs during subscription %@", status.data);
                             _isTestError = YES;
                         } else {
                             
                             statusGroups = status.channelGroups;
                         }
                         [subscribeExpectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    // Checking received from PNStatus channels
    NSSet *groupsSet = [[NSSet alloc] initWithArray:groups];
    NSSet *statusGroupsSet = [[NSSet alloc] initWithArray:statusGroups];
    XCTAssertTrue([groupsSet isSubsetOfSet:statusGroupsSet]);
    
    // Checking isSubscribedOn
    for (NSString *testGroup in groups) {
        
        if (![_pubNub isSubscribedOn:testGroup]) {
            
            XCTFail(@"Error client didn't subscribe on all specified channels");
            _isTestError = YES;
        }
    }
    
    if (_isTestError) {
        @throw _stopTestException;
    }
}

- (void)subscribeOnPresenceChannels:(NSArray *)presenceChannels {
    
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    __block NSArray *statusChannels;
    
    [_pubNub subscribeToPresenceChannels:presenceChannels withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during subscription %@", status.data);
            _isTestError = YES;
        } else {
            
            statusChannels = status.channels;
        }

        [subscribeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    // Checking received from PNStatus channels
    NSSet *channelsSet = [[NSSet alloc] initWithArray:presenceChannels];
    NSSet *statusChannelsSet = [[NSSet alloc] initWithArray:statusChannels];
    XCTAssertTrue([channelsSet isSubsetOfSet:statusChannelsSet]);
    
    // Checking isSubscribedOn
    for (NSString *testPresenceChannel in presenceChannels) {
        
        if (![_pubNub isSubscribedOn:testPresenceChannel]) {
            
            XCTFail(@"Error client didn't subscribe on all specified channels");
            _isTestError = YES;
        }
    }
    
    if (_isTestError) {
        @throw _stopTestException;
    }
}


@end
