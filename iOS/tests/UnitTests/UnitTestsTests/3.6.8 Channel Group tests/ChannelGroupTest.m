//
//  TestChannelGroup.m
//  UnitTests
//
//  Created by Sergey on 10/6/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSString *kOriginPath = @"dara24.devbuild.pubnub.com";
static NSString *kPublishKey = @"demo";
static NSString *kSubscribeKey = @"demo";
static NSString *kSecretKey = @"mySecret";

@interface ChannelGroupTest : XCTestCase <PNDelegate> {
    dispatch_group_t _resGroup1;
    dispatch_group_t _resGroup2;
    dispatch_group_t _resGroup3;
    dispatch_group_t _resGroup4;
    dispatch_group_t _resGroup5;
    dispatch_group_t _resGroup6;
    
    NSString *_namespaceName;
    NSString *_groupName;
    
    NSArray *_channels;
    PNChannelGroup *_group1;
    
    PubNub *_pubNub;
   }
@end

@implementation ChannelGroupTest

- (void)setUp {
    [super setUp];
    
    [PubNub disconnect];
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:kOriginPath
                                                                           publishKey:kPublishKey
                                                                         subscribeKey:kSubscribeKey
                                                                            secretKey:nil] andDelegate:self];
    [_pubNub connect];
    
    _namespaceName = @"namespace_test";
    _groupName = @"group_test";
    
    _group1 = [PNChannelGroup channelGroupWithName:_groupName
                                       inNamespace:_namespaceName
                             shouldObservePresence:NO];
    
    _channels = [PNChannel channelsWithNames:@[@"test_ios_channel_1", @"test_ios_channel_2"]];
}

- (void)tearDown {
    [PubNub disconnect];
    
    [super tearDown];
}

#pragma mark - Tests

// 2. Add namespace, group, channels with delegate
- (void)testAddChannelGroups {
    
    _resGroup1 = dispatch_group_create();
    
    // 2.1 Add next namespase or group (the same as creat)
    dispatch_group_enter(_resGroup1);
    
    [_pubNub addChannels:_channels toGroup:_group1];
    
    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:30]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
    }
}

// 3. Request namespace, group, channels with delegate
- (void)testRequestChannelGroupNamespaces {
    
    _resGroup2 = dispatch_group_create();
    
    // add test channels to group
    [_pubNub addChannels:_channels toGroup:_group1];
    
    // 3.1 Request list of namespaces
    dispatch_group_enter(_resGroup2);
    
    [_pubNub requestChannelGroupNamespaces];
    
    if ([GCDWrapper isGroup:_resGroup2 timeoutFiredValue:30]) {
        XCTFail(@"Timeout is fired. Didn't receive list of namespases with delegates");
    }
}

- (void)testRequestChannelGroupNamespace {
    
    _resGroup3 = dispatch_group_create();
    
    // add test channels to group
    [_pubNub addChannels:_channels toGroup:_group1];
    
    [GCDWrapper sleepForSeconds:5];
    
    dispatch_group_enter(_resGroup3);
    
    [_pubNub requestChannelGroupsForNamespace:_namespaceName];
    
    if ([GCDWrapper isGroup:_resGroup3 timeoutFiredValue:30]) {
        XCTFail(@"Timeout is fired. Didn't receive list of group channels with delegates");
        dispatch_group_leave(_resGroup3);
    }
    
    _resGroup3 = NULL;
}

- (void)testRequestDefaultChannelGroups {
        
    _resGroup4 = dispatch_group_create();
    
    _group1 = [PNChannelGroup channelGroupWithName:_groupName
                                       inNamespace:nil
                             shouldObservePresence:NO];
    
    _channels = [PNChannel channelsWithNames:@[@"test_ios_channel_1", @"test_ios_channel_2"]];
    
    // add test channels to group
    [_pubNub addChannels:_channels toGroup:_group1];
    
    // 3.2.2 Request list of all groups
    dispatch_group_enter(_resGroup4);
    
    [_pubNub requestDefaultChannelGroups];
    
    if ([GCDWrapper isGroup:_resGroup4 timeoutFiredValue:5]) {
        XCTFail(@"Timeout fired. Didn't receive list of channel groups with delegates");
        dispatch_group_leave(_resGroup4);
    }
    
    _resGroup4 = NULL;
}
    
- (void)testRequestChannelsForGroup {
    
    _resGroup5 = dispatch_group_create();
    
    // add test channels to group
    [_pubNub addChannels:_channels toGroup:_group1];
    
    // 3.2.2 Request list of all groups
    dispatch_group_enter(_resGroup5);

    [_pubNub requestChannelsForGroup:_group1];
    
    if ([GCDWrapper isGroup:_resGroup5 timeoutFiredValue:5]) {
        XCTFail(@"Timeout fired. Didn't receive list of channels for group with delegates");
        dispatch_group_leave(_resGroup5);
    }
    
    _resGroup5 = NULL;
}

// 4. Remove channels, group, namespace with delegate
- (void)testRemoveChannelGroups {
    
    _resGroup6 = dispatch_group_create();
    
    // 4.1 Remove channels from group (have to started delegate method)
    _channels = [PNChannel channelsWithNames:@[@"test_channel_ios1", @"test_channel_ios2"]];
    
    dispatch_group_enter(_resGroup6);
    
    [_pubNub removeChannels:_channels
                  fromGroup:_group1];
    
    if ([GCDWrapper isGroup:_resGroup6 timeoutFiredValue:5]) {
        XCTFail(@"!!! Timeout fired. Didn't receive delegates call about remove channels from group");
        dispatch_group_leave(_resGroup6);
        return;
    }
    
//    // 4.2 Remove group with delegate (have to started delegate method)
//    dispatch_group_enter(_resGroup);
//    [_pubNub removeChannelGroup:_group1];
//    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:5]) {
//        XCTFail(@"!!! Timeout fired. Didn't receive delegates call about remove group");
//    }

    // 4.3 Remove namespace with delegate (have to started delegate method)
    dispatch_group_enter(_resGroup6);
    
    [_pubNub removeChannelGroupNamespace:_namespaceName];
    if ([GCDWrapper isGroup:_resGroup6 timeoutFiredValue:5]) {
        XCTFail(@"!!! Timeout fired. Didn't receive delegates call about remove nameSpace");
        dispatch_group_leave(_resGroup6);
    }
    
    _resGroup6 = NULL;
}

#pragma mark - PubNub Delegate

// _2.1.1 Add channels in group (did)
- (void)pubnubClient:(PubNub *)client didAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    
    if (_resGroup1 != NULL) {
        dispatch_group_leave(_resGroup1);
    }
    
//    for(NSArray *channel in channels){
//        NSLog(@"!!! Did receive channel: %@ in group: %@", channel, group);
//    }
//    
//    dispatch_group_leave(_resGroup);
}

// _2.1.2 Add channels to group (fail)
- (void)pubnubClient:(PubNub *)client channelsAdditionToGroupDidFailWithError:(PNError *)error {
    
    if (_resGroup1 != NULL) {
        dispatch_group_leave(_resGroup1);
    }
    
    if (error) {
        XCTFail(@"PubNub client did fail to add channels from the group: %@", error);
    }
}

// _3.1.1 Request namespaces
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroupNamespaces:(NSArray *)namespaces {
    
    if (_resGroup2 != NULL) {
    
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
        
            dispatch_group_leave(_resGroup2);
        }
}

// _3.1.2 Request namespaces (fail)
- (void)pubnubClient:(PubNub *)client channelGroupNamespacesRequestDidFailWithError:(PNError *)error {
    if (error) {
        XCTFail(@"!!! PubNub client did fail to resive namespaces: %@", error);
    }
    dispatch_group_leave(_resGroup1);
}


// _3.2.1 Request groups (did)
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroups:(NSArray *)groups forNamespace:(NSString *)nspace {
    
    if (_resGroup2 != NULL) {
        XCTAssert([nspace isEqualToString:_namespaceName], @"Received namepsace is wrong: %@ <> %@", nspace, _namespaceName);
        
        BOOL res = NO;
        for (PNChannelGroup *group in groups) {
            if ([group.name isEqualToString:_groupName]) {
                res = YES;
                break;
            }
        }
        
        if (!res) {
            XCTFail(@"Cannot find test group in test namespace.");
        }
        
        dispatch_group_leave(_resGroup2);
    }
    
    if (_resGroup4 != NULL) {
        
        BOOL res = NO;
        for (PNChannelGroup *group in groups) {
            if ([group.name isEqualToString:_groupName]) {
                res = YES;
                break;
            }
        }
        
        if (!res) {
            XCTFail(@"Cannot find test group in test namespace.");
        }
        
        dispatch_group_leave(_resGroup4);
    }
    
    if (_resGroup3 != NULL) {
        
        BOOL res = NO;
        NSString *fullGroupName = [NSString stringWithFormat:@"%@:%@", _namespaceName, _groupName];
        for (PNChannelGroup *group in groups) {
            if ([group.name isEqualToString:fullGroupName]) {
                res = YES;
                break;
            }
        }
        
        if (!res) {
            XCTFail(@"Cannot find test group in test namespace.");
        }
        
        dispatch_group_leave(_resGroup3);
    }
}

// _3.2.2 Request groups (fail)
- (void)pubnubClient:(PubNub *)client channelGroupsRequestDidFailWithError:(PNError *)error {
    if (error) {
        XCTFail(@"!!! PubNub client did fail to resive groups: %@", error);
    }
    dispatch_group_leave(_resGroup1);
}


// _3.3.1 Request channels for group (did) ???
- (void)pubnubClient:(PubNub *)client didReceiveChannelsForGroup:(PNChannelGroup *)group {
    
    if (_resGroup1 != NULL) {
        dispatch_group_leave(_resGroup1);
    }
    
    if (_resGroup5 != NULL) {
        dispatch_group_leave(_resGroup5);
    }
}

// _3.3.2 Request channels for group
- (void)pubnubClient:(PubNub *)client channelsForGroupRequestDidFailWithError:(PNError *)error {
    
    if (_resGroup1 != NULL) {
        XCTFail(@"PubNub client did fail to receive channels for group: %@", error);
        dispatch_group_leave(_resGroup1);
    }
    
    if (_resGroup5 != NULL) {
        XCTFail(@"PubNub client did fail to receive channels for group: %@", error);
        dispatch_group_leave(_resGroup5);
    }
}

#pragma mark - Remove calls

// _4.1.1 Remove channels from group (did)
- (void)pubnubClient:(PubNub *)client didRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
    
    if (_resGroup6 != NULL) {
        dispatch_group_leave(_resGroup6);
    }
    
    if (_resGroup1 != NULL) {
        dispatch_group_leave(_resGroup1);
    }
}

// _4.1.2 Remove channels from group (fail)
- (void)pubnubClient:(PubNub *)client channelsRemovalFromGroupDidFailWithError:(PNError *)error {
    if (error) {
        XCTFail(@"!!! PubNub client did fail to remove channels from the group: %@", error);
    }
    dispatch_group_leave(_resGroup1);
}

// _4.2.1 Remove group (did) do not work !!!
- (void)pubnubClient:(PubNub *)client didRemoveChannelGroup:(PNChannelGroup *)group {
    NSLog(@"!!! Did remove group: %@", group);
    dispatch_group_leave(_resGroup1);
}

// _4.2.2 Remove group (fail)
- (void)pubnubClient:(PubNub *)client groupRemovalDidFailWithError:(PNError *)error {
    if (error) {
        XCTFail(@"!!! PubNub client did fail to remove group: %@", error);
    }
    dispatch_group_leave(_resGroup1);
}


// 4.3.1 Remove namespace (did)
- (void)pubnubClient:(PubNub *)client didRemoveNamespace:(NSString *)nspace {
    
    if (_resGroup1 != NULL) {
        dispatch_group_leave(_resGroup1);
    }
    
    if (_resGroup6 != NULL) {
        dispatch_group_leave(_resGroup6);
    }
}

// 4.3.2 Remove namespace (fail)
- (void)pubnubClient:(PubNub *)client namespaceRemovalDidFailWithError:(PNError *)error {
    
    if (_resGroup1 != NULL) {
        XCTFail(@"PubNub client did fail to remove namespace: %@", error);
        dispatch_group_leave(_resGroup1);
    }
    
    if (_resGroup6 != NULL) {
        XCTFail(@"PubNub client did fail to remove namespace: %@", error);
        dispatch_group_leave(_resGroup6);
    }
}

@end
