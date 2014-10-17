//
//  ChannelGroupBlockTest.m
//  UnitTests
//
//  Created by Sergey on 10/9/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSString *kOrigin = @"pubsub-emea.pubnub.com";
static NSString *kPublishKey = @"demo";
static NSString *kSubscribeKey = @"demo";
static NSString *kSecretKey = @"mySecret";

@interface ChannelGroupBlockTest : XCTestCase {
    dispatch_group_t _resGroup1;
    dispatch_group_t _resGroup2;
    dispatch_group_t _resGroup3;
    dispatch_group_t _resGroup4;
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
    
    _pubNub = [[PubNub alloc] init];
    [_pubNub setConfiguration:[PNConfiguration configurationForOrigin:kOrigin
                                                           publishKey:kPublishKey
                                                         subscribeKey:kSubscribeKey
                                                            secretKey:kSecretKey]];
    [_pubNub connect];
    
    _namespaceName = @"namespace1";
    _groupName = @"group1";
    _group1 = [PNChannelGroup channelGroupWithName:_groupName
                                       inNamespace:_namespaceName
                             shouldObservePresence:NO];
    
    _channels = [PNChannel channelsWithNames:@[@"test_group_channel_1", @"test_group_channel_2"]];
}

- (void)tearDown {
//    _resGroup = NULL;
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

    _resGroup2 = dispatch_group_create();
    dispatch_group_enter(_resGroup2);
    
    [_pubNub requestChannelGroupNamespacesWithCompletionHandlingBlock:^(NSArray *namespaces, PNError *error) {
        if (_resGroup2 != NULL) {
            
            if (error == nil) {
                BOOL res = NO;
                
                for (NSString *namespaceName in namespaces) {
                    if ([namespaceName isEqualToString:_namespaceName]) {
                        res = YES;
                        break;
                    }
                }
                
                if (!res) {
                    XCTFail(@"Cannot find test namespace.");
                }
            } else {
                XCTFail(@"PubNub client did fail to receive list of namespaces");
            }
            
            dispatch_group_leave(_resGroup2);
        }
    }];
    
    if ([GCDWrapper isGroup:_resGroup2 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive list of namespaces with completion block");
    }
}


// 2.2 Request list of groups for namespace with block
 - (void)testRequestChannelGroupsForNamespace {
        
    [_pubNub addChannels:_channels toGroup:_group1];
     
    _resGroup3 = dispatch_group_create();
    dispatch_group_enter(_resGroup3);
    
    [_pubNub requestChannelGroupsForNamespace:_namespaceName
                  withCompletionHandlingBlock:^(NSString *nameSpace, NSArray *groups, PNError *error) {
                      if (_resGroup3 != NULL) {
                          
                          if (error == nil) {
                              BOOL res = NO;
                              
                              for (NSArray *group in groups) {
                                  if ([group isEqual:_group1]) {
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
                          
                          dispatch_group_leave(_resGroup3);
                      }
                  }];
        if ([GCDWrapper isGroup:_resGroup3 timeoutFiredValue:10]) {
            XCTFail(@"Timeout is fired. Didn't receive list of channel groups with completion block");
        }
}

// 2.3 Request list of all groups with block ???
- (void)testRequestDefaultChannelGroups {
    
    _resGroup4 = dispatch_group_create();
    dispatch_group_enter(_resGroup4);
    
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
                    if ([group.name isEqualToString:_group1.name]) {
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
            
            dispatch_group_leave(_resGroup4);
        }
    }];
    
    if ([GCDWrapper isGroup:_resGroup4 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive list of all groups with completion block");
        dispatch_group_leave(_resGroup4);
    }
    
    _resGroup4 = NULL;
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
                for (NSString *channelName in group.channels) {
                    for (PNChannel *channel in _channels) {
                        if ([channelName isEqualToString:channel.name]) {
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

@end
