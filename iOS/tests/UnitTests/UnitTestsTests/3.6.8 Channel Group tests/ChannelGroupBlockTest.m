//
//  ChannelGroupBlockTest.m
//  UnitTests
//
//  Created by Sergey on 10/9/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ChannelGroupBlockTest : XCTestCase

<PNDelegate>

{
    dispatch_group_t _resGroup1;
    GCDGroup *_resGroup2;
    GCDGroup *_resGroup3;
    GCDGroup *_resGroup4;
    dispatch_group_t _resGroup5;
    dispatch_group_t _resGroup6;
    dispatch_group_t _resGroup7;
    dispatch_group_t _resGroup8;
    
    NSString *_namespaceName;
    NSString *_groupName;
    NSArray *_channels;
    PNChannelGroup *_group1;
    PubNub *_pubNub;
}
@end

@implementation ChannelGroupBlockTest

- (void)setUp {
    [super setUp];
    [PubNub disconnect];
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:kTestPNOriginHost
                                                                            publishKey:kTestPNPublishKey
                                                                          subscribeKey:kTestPNSubscriptionKey
                                                                             secretKey:kTestPNSecretKey] andDelegate:self];
    
    [_pubNub connect];
    
    _namespaceName = @"namespace1";
    _groupName = @"group1";
    _group1 = [PNChannelGroup channelGroupWithName:_groupName
                                       inNamespace:_namespaceName
                             shouldObservePresence:NO];
    
    _channels = [PNChannel channelsWithNames:@[@"test_group_channel_1", @"test_group_channel_2"]];
}

- (void)tearDown {
    [PubNub disconnect];
    [super tearDown];
}

#pragma mark - Tests

// 1. Add channels in group with block
- (void)testAddChannelGroups {
    _resGroup1 = dispatch_group_create();
    dispatch_group_enter(_resGroup1);
    
    [_pubNub addChannels:_channels toGroup:_group1 withCompletionHandlingBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
        if (!error) {
            for(NSArray *channel in channels) {
                NSLog(@"PubNub client added channels: %@ to the group: %@", channel, group);
            }
        } else {
            XCTFail(@"PubNub client did fail to add channels to the group");
        }
        
        dispatch_group_leave(_resGroup1);
    }];
    
    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't add channels to the group");
    }
}

// 2.1 Request list of namespaces with block
- (void)testRequestChannelGroupNamespaces {

    _resGroup2 = [GCDGroup group];
    [_resGroup2 enterTimes:3];
    
    [_pubNub.observationCenter addChannelGroupNamespacesRequestObserver:self withCallbackBlock:^(NSArray *namespaces, PNError *error) {
        
        if (!error) {
            
            // PubNub client received list of namespaces which is registered under current subscribe key.
        }
        else {
            
            // PubNub client did fail to retrieve list of namespaces.
            //
            // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
            // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
            XCTFail(@"Fail to retrieve list of namespace(observer): %@", [error localizedFailureReason]);
        }
        
        [_resGroup2 leave];
    }];
    
    [_pubNub requestChannelGroupNamespacesWithCompletionHandlingBlock:^(NSArray *namespaces, PNError *error) {
        if (_resGroup2 != NULL) {
            
            if (error == nil) {
                
                if ([namespaces count] == 0) {
                    XCTFail(@"Cannot find test namespace.");
                }
            } else {
                XCTFail(@"PubNub client did fail to receive list of namespaces");
            }
            
            [_resGroup2 leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup2 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive list of namespaces with completion block");
    }
    
    [_pubNub.observationCenter removeChannelGroupNamespacesRequestObserver:self];
    
    _resGroup2 = nil;
}


// 2.2 Request list of groups for namespace with block
 - (void)testRequestChannelGroupsForNamespace {
        
    [_pubNub addChannels:_channels toGroup:_group1];
     
    _resGroup3 = [GCDGroup group];
    [_resGroup3 enter];
    
    [_pubNub requestChannelGroupsForNamespace:_namespaceName
                  withCompletionHandlingBlock:^(NSString *nameSpace, NSArray *groups, PNError *error) {
                      if (_resGroup3 != NULL) {
                          
                          if (error == nil) {
                              BOOL res = NO;
                              
                              for (PNChannelGroup *group in groups) {
                                  if ([group.name isEqualToString:_group1.name]) {
                                      res = YES;
                                      break;
                                 }
                              }
                              
                              if (!res) {
                                  XCTFail(@"Cannot find test group.");
                              }
                          } else {
                              XCTFail(@"PubNub client did fail to receive groups from the namespace");
                          }
                          
                          [_resGroup3 leave];
                      }
                  }];
        if ([GCDWrapper isGCDGroup:_resGroup3 timeoutFiredValue:10]) {
            XCTFail(@"Timeout is fired. Didn't receive list of channel groups with completion block");
        }
}

// 2.3 Request list of all groups with block ???
- (void)testRequestDefaultChannelGroups {
    
    _resGroup4 = [GCDGroup group];
    [_resGroup4 enter];
    
    _group1 = [PNChannelGroup channelGroupWithName:_groupName
                                       inNamespace:nil
                             shouldObservePresence:NO];
    
    _channels = [PNChannel channelsWithNames:@[@"test_ios_channel_1", @"test_ios_channel_2"]];
    
    [_pubNub addChannels:_channels toGroup:_group1];
    
    [_pubNub requestDefaultChannelGroupsWithCompletionHandlingBlock:^(NSString *nameSpace, NSArray *groups, PNError *error) {
        if (_resGroup4 != NULL) {
            
            if (error == nil) {
                BOOL res = NO;
                
                for (PNChannelGroup *group in groups) {
                    if ([group.groupName isEqualToString:_group1.groupName]) {
                        res = YES;
                        break;
                    }
                }
                
                if (!res) {
                    XCTFail(@"Cannot find test group.");
                }
            } else {
                XCTFail(@"PubNub client did fail to receive groups from the namespace: %@", error);
            }
            
            [_resGroup4 leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup4 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive list of all groups with completion block");
    }
    
    _resGroup4 = nil;
}

// 2.4 Request list of channels for group with block ???
- (void)testRequestChannelsForGroup {
    
    _resGroup5 = dispatch_group_create();
    dispatch_group_enter(_resGroup5);

    [_pubNub addChannels:_channels toGroup:_group1];
    
    [_pubNub requestChannelsForGroup:_group1 withCompletionHandlingBlock:^(PNChannelGroup *group, PNError *error) {
        if (_resGroup5 != NULL) {
            
            if (error == nil) {
                XCTAssert([group isEqual:_group1], @"Received group is wrong: %@ <> %@", group, _group1);
                
                NSUInteger equalChannelsCounter = 0;
                for (PNChannel *channelInGroup in group.channels) {
                    for (PNChannel *channel in _channels) {
                        if ([channelInGroup.name isEqualToString:channel.name]) {
                            equalChannelsCounter += 1;
                        }
                    }
                }
                
                XCTAssert(equalChannelsCounter == [_channels count], @"Cannot find all channels here.");
                
            } else {
                XCTFail(@"PubNub client did fail to receive channels from the group: %@", error);
            }
            
            dispatch_group_leave(_resGroup5);
        }

    }];
    
    if ([GCDWrapper isGroup:_resGroup5 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive list channel for group with completion block");
    }
}


// 3.1 Remove channels, group, namespace with block
- (void)testRemoveChannelsFromGroups {

    [_pubNub addChannels:_channels toGroup:_group1];
    
    _resGroup6 = dispatch_group_create();
    dispatch_group_enter(_resGroup6);


    [_pubNub removeChannels:_channels
                  fromGroup:_group1
withCompletionHandlingBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
        if (_resGroup6 != NULL) {
        
            if (error == nil) {
            
                XCTAssert([group isEqual:_group1], @"Received group is wrong: %@ <> %@", group, _group1);
                XCTAssert([channels isEqual:_channels], @"Received array channels is wrong: %@ <> %@", group.channels, _channels);
            
                for(NSArray *channel in channels){
                    NSLog(@"PubNub client remove channel: %@ from the group: %@", channel, group);
                }
            } else {
                XCTFail(@"PubNub client did fail to remove channel from the group");
            }
            
            dispatch_group_leave(_resGroup6);
        }
    }];
    if ([GCDWrapper isGroup:_resGroup6 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't remove channel from the group with completion block");
    }
}
    
// 3.2 Remove group with block
- (void)testRemoveChannelGroup {
    
    _resGroup7 = dispatch_group_create();
    dispatch_group_enter(_resGroup7);
    
    [_pubNub addChannels:_channels toGroup:_group1];

    [_pubNub removeChannelGroup:_group1
    withCompletionHandlingBlock:^(PNChannelGroup *group, PNError *error) {
        if (_resGroup7 != NULL) {
            if (error == nil) {
                XCTAssert([group isEqual:_group1], @"Removed group is wrong: %@ <> %@", group, _group1);
            } else {
                XCTFail(@"PubNub client did fail to remove group: %@", error);
            }
            
            dispatch_group_leave(_resGroup7);
         }
     }];
    
    if ([GCDWrapper isGroup:_resGroup7 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't remove group with completion block");
        dispatch_group_leave(_resGroup7);
    }
    
    _resGroup7 = NULL;
}

// 3.3 Remove namespace
- (void)testRemoveChannelGroupNamespace {
    
    _resGroup8 = dispatch_group_create();
    dispatch_group_enter(_resGroup8);
    
    [_pubNub removeChannelGroupNamespace:_namespaceName withCompletionHandlingBlock:^(NSString *namespace, PNError *error) {
        if (_resGroup8 != NULL) {
            if (error == nil) {
                XCTAssert([namespace isEqualToString:_namespaceName], @"Removed group is wrong: %@ <> %@", namespace, _namespaceName);
            }
            else {
                XCTFail(@"PubNub client did fail to namespace");
            }
        dispatch_group_leave(_resGroup8);
        }
    }];
    
    if ([GCDWrapper isGroup:_resGroup8 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't remove namespace with completion block");
    }
}

#pragma mark - PubNub Delegate

- (void)pubnubClient:(PubNub *)client didReceiveChannelGroupNamespaces:(NSArray *)namespaces {
    
    // PubNub client received list of namespaces which is registered under current subscribe key.
    if (_resGroup2) {
        [_resGroup2 leave];
    }
}

- (void)pubnubClient:(PubNub *)client channelGroupNamespacesRequestDidFailWithError:(PNError *)error {
    
    // PubNub client did fail to retrieve list of namespaces.
    //
    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
    if (_resGroup2) {
        XCTFail(@"Did fail to get group in default namespace: %@", [error localizedFailureReason]);
    }
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    
    // Update your interface to let user know that we are ready to work.
    NSLog(@"Connected: %@", origin);
}

@end
