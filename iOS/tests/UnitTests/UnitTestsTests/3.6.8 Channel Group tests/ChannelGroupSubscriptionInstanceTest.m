//
//  ChannelGroupSubscriptionInstanceTest.m
//  UnitTests
//
//  Created by Sergey on 10/13/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSString *kOriginPath = @"dara24.devbuild.pubnub.com";
static NSString *kPublishKey = @"demo";
static NSString *kSubscribeKey = @"demo";
static NSString *kSecretKey = @"mySecret";

@interface ChannelGroupSubscriptionInstanceTest : XCTestCase
<
PNDelegate
>
@end

@implementation ChannelGroupSubscriptionInstanceTest {
    dispatch_group_t _resGroup1;
    dispatch_group_t _resGroup2;
    dispatch_group_t _resGroup3;
    dispatch_group_t _resGroup4;
    dispatch_group_t _resGroup5;
    dispatch_group_t _resGroup6;
    
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

    [PubNub disconnect];
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:kOriginPath
                                                                           publishKey:kPublishKey
                                                                         subscribeKey:kSubscribeKey
                                                                            secretKey:kSecretKey] andDelegate:self];
    [_pubNub connect];
    
    _channels = [PNChannel channelsWithNames:@[@"test_ios_1", @"test_ios_2", @"test_ios_3"]];
    _group = [PNChannelGroup channelGroupWithName:@"test_channel_group1" inNamespace:@"unit_test_ios_namespace" shouldObservePresence:NO];
    _group2 = [PNChannelGroup channelGroupWithName:@"test_channel_group2" inNamespace:@"unit_test_ios_namespace" shouldObservePresence:NO];

    _groups = [NSArray arrayWithObjects:_group,_group2, nil];
    _testMessage = @"Test message";
    
}

- (void)tearDown {
    [PubNub disconnect];
    
    [super tearDown];
}

- (void)testSubscribeOnInstance {
        _resGroup1 = dispatch_group_create();
    
    
        // Subscribe on channels, group
        dispatch_group_enter(_resGroup1);
        dispatch_group_enter(_resGroup1);
    
        [_pubNub addChannels:_channels toGroup:_group];
        [_pubNub subscribeOn:@[_group]];
    
        [GCDWrapper sleepForSeconds:3];
        XCTAssert([_pubNub isSubscribedOn:_group], @"Is not subscribed on group 1");
    
    
        // Check that if we send a message to this group we are able to receive it
        dispatch_group_enter(_resGroup1);
        dispatch_group_enter(_resGroup1);
    
        [_pubNub sendMessage:_testMessage
                  toChannel:_channels[0]
                 compressed:YES
             storeInHistory:YES
        withCompletionBlock:^(PNMessageState state, id message) {
            if (state == PNMessageSent) {
                dispatch_group_leave(_resGroup1);
            } else if (state == PNMessageSendingError) {
                XCTFail(@"Failed to send message");
                dispatch_group_leave(_resGroup1);
            }
        }];
    
        // try to receive message
        if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:30]) {
            XCTFail(@"Timeout is fired. We didn't receive message about sending channel.");
        }
}

- (void)testSubscribeOnWithCompletionBlockInstance {
    //    _resGroup2 = dispatch_group_create();
    //
    //
    //        // Subscribe on channels, group
    //        dispatch_group_enter(_resGroup2);
    //        dispatch_group_enter(_resGroup2);
    //
    //        [_pubNub addChannels:_channels toGroup:_group];
    //        [_pubNub subscribeOn:@[_group] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *groups, PNError *error) {
    //
    //            if (_resGroup2 != NULL) {
    //                if (error == nil) {
    //                    XCTAssert([groups isEqual:_groups], @"Received groups is wrong: %@ <> %@", groups, _groups);
    //                } else {
    //                    XCTFail(@"PubNub client did fail to receive list of groups %@", error);
    //                }
    //                dispatch_group_leave(_resGroup2);
    //            }
    //        }];
    //
    //        if ([GCDWrapper isGroup:_resGroup2 timeoutFiredValue:30]) {
    //            XCTFail(@"Timeout is fired. We didn't subscribe to an array of groups.");
    //        }
}


- (void)testSubscribeWithClientStateInstance {
    _resGroup3 = dispatch_group_create();
    
    
//    // Unsubscribe from channels, group
//    dispatch_group_enter(_resGroup3);
//    
//    [_pubNub unsubscribeFrom:@[_channels]];
//    [_pubNub unsubscribeFrom:@[_group]];
//    
//    [GCDWrapper sleepForSeconds:3];
//    if ([_pubNub isSubscribedOn:_group]) {
//        XCTFail(@"Is not subscribed on group 1");
//    }
//    dispatch_group_leave(_resGroup3);
    
    
    // Subscribe on channels, group with client state
    dispatch_group_enter(_resGroup3);
    
    [_pubNub addChannels:_channels toGroup:_group];
    _dictionary = [NSDictionary dictionaryWithObject:@"tObject1" forKey:@"tKey1"];
    
    [_pubNub subscribeOn:@[_group] withClientState:_dictionary];
    
//    [GCDWrapper sleepForSeconds:3];
    XCTAssert([_pubNub isSubscribedOn:_group], @"Is not subscribed on group 1");
    dispatch_group_leave(_resGroup3);
}

- (void)testSubscribeWithClientStateAndCompletionBlockInstance {
    _resGroup4 = dispatch_group_create();
    
    
    // Subscribe from channels, group
    dispatch_group_enter(_resGroup4);
    
//    [_pubNub unsubscribeFrom:@[_channels]];
//    [_pubNub unsubscribeFrom:@[_group]];
    
//    [GCDWrapper sleepForSeconds:3];
    if ([_pubNub isSubscribedOn:_group]) {
        XCTFail(@"Is not subscribed on group 1");
    }
    dispatch_group_leave(_resGroup4);
    
    
    // Subscribe on channels, group with client state
    dispatch_group_enter(_resGroup4);
    
    [_pubNub addChannels:_channels toGroup:_group];
    _dictionary = [NSDictionary dictionaryWithObject:@"tObject1" forKey:@"tKey1"];
    
    [_pubNub subscribeOn:@[_group] withClientState:_dictionary andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *groups, PNError *error) {
        if (_resGroup4 != NULL) {
            if (error == nil) {
                XCTAssert([groups isEqual:_groups], @"Received groups is wrong: %@ <> %@", groups, _groups);
            } else {
                XCTFail(@"PubNub client did fail to receive list of groups %@", error);
            }
            
            dispatch_group_leave(_resGroup4);
        }
    }];
    
//    [GCDWrapper sleepForSeconds:3];
    XCTAssert([_pubNub isSubscribedOn:_group], @"Is not subscribed on group 1");
}

- (void)testUnsubscribeInstance {
    _resGroup5 = dispatch_group_create();
    dispatch_group_enter(_resGroup5);
    
    [_pubNub unsubscribeFrom:@[_channels]];
    [_pubNub unsubscribeFrom:@[_group]];
    
    // ???   [GCDWrapper sleepForSeconds:3];
    if ([_pubNub isSubscribedOn:_group]) {
        XCTFail(@"Is not subscribed on group 1");
    }
    dispatch_group_leave(_resGroup5);
}


- (void)testUnsubscribeWithCompletionBlockInstance {
    _resGroup6 = dispatch_group_create();
    dispatch_group_enter(_resGroup6);
    
    [_pubNub unsubscribeFrom:@[_channels] withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        if (_resGroup6 != NULL) {
            if (error == nil) {
                XCTAssert([channels isEqual:_channels], @"Received groups is wrong: %@ <> %@", channels, _channels);
            } else {
                XCTFail(@"PubNub client did fail to unsubscribe from channels %@", error);
            }
            
            dispatch_group_leave(_resGroup6);
        }
    }];
    
    //        [GCDWrapper sleepForSeconds:3];
    if ([_pubNub isSubscribedOn:_channels]) {
        XCTFail(@"Is not unsubscribe from channels");
    }
}



#pragma mark - PNDelegate

// Receive message (did)
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    if (_resGroup1) {
        dispatch_group_leave(_resGroup1);
    }
    
    if (_resGroup2) {
        dispatch_group_leave(_resGroup2);
    }
    
    if (_resGroup3) {
        dispatch_group_leave(_resGroup3);
    }
    
    if (_resGroup4) {
        dispatch_group_leave(_resGroup3);
    }
    
    if (_resGroup5) {
        dispatch_group_leave(_resGroup3);
    }
    
    if (_resGroup6) {
        dispatch_group_leave(_resGroup3);
    }
}

// Receive message (fail)
- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    if (_resGroup1) {
        XCTFail(@"Did fail during test 1: %@", error);
        dispatch_group_leave(_resGroup1);
    }
    
    if (_resGroup2) {
        XCTFail(@"Did fail during test 2: %@", error);
        dispatch_group_leave(_resGroup2);
    }
    
    if (_resGroup3) {
        XCTFail(@"Did fail during test 3: %@", error);
        dispatch_group_leave(_resGroup3);
    }
    
    if (_resGroup4) {
        XCTFail(@"Did fail during test 3: %@", error);
        dispatch_group_leave(_resGroup3);
    }
    
    if (_resGroup5) {
        XCTFail(@"Did fail during test 3: %@", error);
        dispatch_group_leave(_resGroup3);
    }
    
    if (_resGroup6) {
        XCTFail(@"Did fail during test 3: %@", error);
        dispatch_group_leave(_resGroup3);
    }
}


// Add channels in group (did)
- (void)pubnubClient:(PubNub *)client didAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    if (_resGroup1 != NULL) {
        dispatch_group_leave(_resGroup1);
    }
        for(NSArray *channel in channels){
            NSLog(@"!!! Did receive channel: %@ in group: %@", channel, group);
        }
 }

// Add channels to group (fail)
- (void)pubnubClient:(PubNub *)client channelsAdditionToGroupDidFailWithError:(PNError *)error {
    if (_resGroup1 != NULL) {
        dispatch_group_leave(_resGroup1);
    }
    if (error) {
        XCTFail(@"PubNub client did fail to add channels from the group: %@", error);
    }
}


// Subscribe on (did)
- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    if (_resGroup1) {
        dispatch_group_leave(_resGroup1);
    }
    
    if (_resGroup3) {
        dispatch_group_leave(_resGroup3);
    }

}

// Subscribe on channels (did)
- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
    if (_resGroup2) {
        dispatch_group_leave(_resGroup2);
    }
}

// Subscribe on channels (fail)
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    if (_resGroup2) {
        XCTFail(@"Did fail during test 2: %@", error);
        dispatch_group_leave(_resGroup2);
    }
    
    if (_resGroup3) {
        XCTFail(@"Did fail during test 2: %@", error);
        dispatch_group_leave(_resGroup2);
    }
}


// Unsubscribe on channels in group (did)
- (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
    if (_resGroup5) {
        dispatch_group_leave(_resGroup5);
    }
}

// Unsubscribe on channels in group (fail)
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    if (_resGroup5) {
        XCTFail(@"Did fail during test 5: %@", error);
        dispatch_group_leave(_resGroup5);
    }
}

@end
