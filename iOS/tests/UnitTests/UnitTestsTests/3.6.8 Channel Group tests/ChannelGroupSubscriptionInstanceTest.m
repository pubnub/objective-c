//
//  ChannelGroupSubscriptionInstanceTest.m
//  UnitTests
//
//  Created by Sergey Kazanskiy on 10/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

/*
 Prerequisities:
  - 'Access Manager'should be disabled in account.
 Test Purpose:
  - subscripe/unsubscribe to group and send messages.
 */

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ChannelGroupSubscriptionInstanceTest : XCTestCase
<
PNDelegate
>
@end

@implementation ChannelGroupSubscriptionInstanceTest {
    GCDGroup *_resGroup1;
    GCDGroup *_resGroup2;
    GCDGroup *_resGroup3;
    GCDGroup *_resGroup4;
    GCDGroup *_resGroup5;
    GCDGroup *_resGroup6;
    
    NSString *_namespaceName;
    NSArray *_channels;
    PNChannelGroup *_group;
    PNChannelGroup *_group2;
    NSArray *_groups;
    NSDictionary *_dictionary;
    
    PubNub *_pubNub;
    id _testMessage;
}

- (void)setUp {
    [super setUp];

    [_pubNub disconnect];
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultTestConfiguration] andDelegate:self];
    [_pubNub connect];
    
    _channels = [PNChannel channelsWithNames:@[@"test_ios_1", @"test_ios_2", @"test_ios_3"]];
    _group = [PNChannelGroup channelGroupWithName:@"test_channel_group1" inNamespace:@"unit_test_ios_namespace" shouldObservePresence:NO];
    _group2 = [PNChannelGroup channelGroupWithName:@"test_channel_group2" inNamespace:@"unit_test_ios_namespace" shouldObservePresence:NO];

    _groups = [NSArray arrayWithObjects:_group,_group2, nil];
    _testMessage = @"Test message";
}

- (void)tearDown {
    [_pubNub disconnect];
    
    [super tearDown];
}

// Test 1
- (void)testSubscribeOnInstance {
    _resGroup1 = [GCDGroup group];

    // 1. Add channels to group
    [_resGroup1 enter];
    [_pubNub addChannels:_channels toGroup:_group];
    
    if ([GCDWrapper isGCDGroup:_resGroup1 timeoutFiredValue:20]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup1 = nil;
        return;
    }

    // 2. Subscribe on group
    
    [_resGroup1 enter];
    [_pubNub subscribeOn:@[_group]];
    
    if ([GCDWrapper isGCDGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup1 = nil;
        return;
    }

    XCTAssert([_pubNub isSubscribedOn:_group], @"Is not subscribed on group 1");

    // 3. Check that if we send a message to this group we are able to receive it
    [_resGroup1 enterTimes:2];
    [_pubNub sendMessage:_testMessage
              toChannel:_channels[0]
             compressed:YES
         storeInHistory:YES
    withCompletionBlock:^(PNMessageState state, id message) {
        if (state == PNMessageSent) {
            [_resGroup1 leave];
        } else if (state == PNMessageSendingError) {
            XCTFail(@"Failed to send message");
        }
    }];

    if ([GCDWrapper isGCDGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. We didn't receive message about sending channel.");
    }
    
    _resGroup1 = nil;
}

// Test 2
- (void)testSubscribeOnWithCompletionBlockInstance {
    _resGroup2 = [GCDGroup group];
    
    // 1. Add channels to group
    [_resGroup2 enter];
    [_pubNub addChannels:_channels toGroup:_group];
    
    if ([GCDWrapper isGCDGroup:_resGroup2 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup2 = nil;
        return;
    }

    // 2. Subscribe on groups with block
    [_resGroup2 enter];

    [_pubNub subscribeOn:@[_group] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *groups, PNError *error) {

        if (_resGroup2 != NULL) {
            if (error == nil) {
                XCTAssert([groups isEqual:@[_group]], @"Received groups is wrong: %@ <> %@", groups, _group);
            } else {
                XCTFail(@"PubNub client did fail to subscribe to an array of groups %@", error);
            }
            [_resGroup2 leave];
        }
    }];

    if ([GCDWrapper isGCDGroup:_resGroup2 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. We didn't subscribe to an array of groups.");
        [_resGroup2 leave];
    }
    
    _resGroup2 = nil;
}

// Test 3
- (void)testSubscribeWithClientStateInstance {
    _resGroup3 = [GCDGroup group];
    
    // 1. Add channels to group
    [_resGroup3 enter];
    [_pubNub addChannels:_channels toGroup:_group];
    
    if ([GCDWrapper isGCDGroup:_resGroup3 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup3 = nil;
        return;
    }
    
    // 2. Subscribe on group with client state
    [_resGroup3 enter];
    _dictionary = [NSDictionary dictionaryWithObject:@"tObject1" forKey:@"tKey1"];
    
    [_pubNub subscribeOn:@[_group] withClientState:_dictionary];
    
    if ([GCDWrapper isGCDGroup:_resGroup3 timeoutFiredValue:3]) {
        XCTFail(@"Timeout during group subscription.");
        _resGroup3 = nil;
        return;
    }
    
    XCTAssert([_pubNub isSubscribedOn:_group], @"Is not subscribed on group 1");
    
    _resGroup3 = nil;
}

// Test 4
- (void)testSubscribeWithClientStateAndCompletionBlockInstance {
    _resGroup4 = [GCDGroup group];
    
    // 1. Add channels to group
    [_resGroup4 enter];
    [_pubNub addChannels:_channels toGroup:_group];
    
    if ([GCDWrapper isGCDGroup:_resGroup4 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup4 = nil;
        return;
    }
    
    // 2. Subscribe on group with client state and block
    [_resGroup4 enter];
    _dictionary = [NSDictionary dictionaryWithObject:@"tObject1" forKey:@"tKey1"];

    [_pubNub subscribeOn:@[_group] withClientState:_dictionary andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *groups, PNError *error) {
        if (_resGroup4 != nil) {
            if (error == nil) {
                XCTAssert([groups isEqual:@[_group]], @"Received groups is wrong: %@ <> %@", groups, _groups);
            } else {
                XCTFail(@"PubNub client did fail to subscribe to an array of groups %@", error);
            }
            [_resGroup4 leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup4 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. We didn't subscribe to an array of groups.");
    }
    
    _resGroup4 = nil;
}

// Test 5
- (void)testUnsubscribeInstance {
    _resGroup5 = [GCDGroup group];
    
    // 1. Add channels to group
    [_resGroup5 enter];
    [_pubNub addChannels:_channels toGroup:_group];
    
    if ([GCDWrapper isGCDGroup:_resGroup5 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup5 = nil;
        return;
    }
    
    // 2. Subscribe on group
    [_resGroup5 enter];
    [_pubNub subscribeOn:@[_group]];
    
    if ([GCDWrapper isGCDGroup:_resGroup5 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup5 = nil;
        return;
    }

    // 3. Unubscribe from group
    [_resGroup5 enter];
    [_pubNub unsubscribeFrom:@[_group]];
    
    if ([GCDWrapper isGCDGroup:_resGroup5 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup5 = nil;
        return;
    }

    if ([_pubNub isSubscribedOn:_group]) {
        XCTFail(@"Is not unsubscribed from group 1");
    }
    
    _resGroup5 = nil;
}

// Test 6
- (void)testUnsubscribeWithCompletionBlockInstance {
    _resGroup6 = [GCDGroup group];
    
    // 1. Add channels to group
    [_resGroup6 enter];
    [_pubNub addChannels:_channels toGroup:_group];
    
    if ([GCDWrapper isGCDGroup:_resGroup6 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup6 = nil;
        return;
    }
    
    // 2. Subscribe on group
    [_resGroup6 enter];
    [_pubNub subscribeOn:@[_group]];

    if ([GCDWrapper isGCDGroup:_resGroup6 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        _resGroup6 = nil;
        return;
    }
    
    XCTAssert([_pubNub isSubscribedOn:_group], @"Is not subscribed on group 1");
    
    // 3. Unubscribe from group with block
    [_resGroup6 enter];
    
    [_pubNub unsubscribeFrom:@[_group] withCompletionHandlingBlock:^(NSArray *groups, PNError *error) {
        if (_resGroup6 != nil) {
            if (error == nil) {
                XCTAssert([groups isEqual:@[_group]], @"Received groups is wrong: %@ <> %@", groups, _group);
            } else {
                XCTFail(@"PubNub client did fail to unsubscribe from groups %@", error);
            }
            [_resGroup6 leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup6 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. We didn't unsubscribe from groups.");
    }

    _resGroup6 = nil;
}

#pragma mark - PNDelegate

// Receive message (did)
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    if (_resGroup1) {
        [_resGroup1 leave];
    }
}

// Receive message (fail)
- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    if (_resGroup1) {
        XCTFail(@"Did fail during test 1: %@", error);
        [_resGroup1 leave];
    }
}


// Add channels in group (did)
- (void)pubnubClient:(PubNub *)client didAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    if (_resGroup1 != nil) {
        [_resGroup1 leave];
    }
    if (_resGroup2 != nil) {
        [_resGroup2 leave];
    }
    if (_resGroup3 != nil) {
        [_resGroup3 leave];
    }
    if (_resGroup4 != nil) {
        [_resGroup4 leave];
    }
    if (_resGroup5 != nil) {
        [_resGroup5 leave];
    }
    if (_resGroup6 != nil) {
        [_resGroup6 leave];
    }
     for(NSArray *channel in channels){
        NSLog(@"!!! Did receive channel: %@ in group: %@", channel, group);
    }
 }

// Add channels to group (fail)
- (void)pubnubClient:(PubNub *)client channelsAdditionToGroupDidFailWithError:(PNError *)error {
    if (_resGroup1 != nil) {
        [_resGroup1 leave];
    }
    if (_resGroup2 != nil) {
        [_resGroup2 leave];
    }
    if (_resGroup3 != nil) {
        [_resGroup3 leave];
    }
    if (_resGroup4 != nil) {
        [_resGroup4 leave];
    }
    if (_resGroup5 != nil) {
        [_resGroup5 leave];
    }
    if (_resGroup6 != nil) {
        [_resGroup6 leave];
    }
    if (error) {
        XCTFail(@"PubNub client did fail to add channels from the group: %@", error);
    }
}

// Subscribe on group (did)
- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    if (_resGroup1) {
        [_resGroup1 leave];
    }
    
    if (_resGroup3) {
        [_resGroup3 leave];
    }
    if (_resGroup5) {
        [_resGroup5 leave];
    }
    if (_resGroup6) {
        [_resGroup6 leave];
    }
}

// Subscribe on group (fail)
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    if (_resGroup1) {
        XCTFail(@"Did fail during test 1: %@", error);
        [_resGroup1 leave];
    }
    if (_resGroup3) {
        XCTFail(@"Did fail during test 3: %@", error);
        [_resGroup3 leave];
    }
    if (_resGroup5) {
        XCTFail(@"Did fail during test 5: %@", error);
        [_resGroup5 leave];
    }
    if (_resGroup6) {
        XCTFail(@"Did fail during test 6: %@", error);
        [_resGroup6 leave];
    }
}


// Unsubscribe from group (did)
- (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
    if (_resGroup5) {
        [_resGroup5 leave];
    }
}

// Unsubscribe from group (fail)
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    if (_resGroup5) {
        XCTFail(@"Did fail during test 5: %@", error);
        [_resGroup5 leave];
    }
}

@end
