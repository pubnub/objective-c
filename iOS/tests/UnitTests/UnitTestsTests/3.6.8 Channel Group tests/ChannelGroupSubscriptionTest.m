//
//  ChannelGroupSubscriptionTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 10/10/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>

static NSString *kOriginPath = @"dara24.devbuild.pubnub.com";
static NSString *kPublishKey = @"demo";
static NSString *kSubscribeKey = @"demo";
static NSString *kSecretKey = @"mySecret";

@interface ChannelGroupSubscriptionTest : XCTestCase

<
PNDelegate
>

@end

@implementation ChannelGroupSubscriptionTest {
    dispatch_group_t _resGroup1;
    dispatch_group_t _resGroup2;
    dispatch_group_t _resGroup3;
    dispatch_group_t _resGroup4;
    dispatch_group_t _resGroup5;
    dispatch_group_t _resGroup6;
    
    NSString *_namespaceName;
    
    NSArray *_channels;
    PNChannelGroup *_group;
    
    PubNub *_pubNub;
    
    id _testMessage;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [PubNub disconnect];
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kOriginPath
                                                                  publishKey:kPublishKey
                                                                subscribeKey:kSubscribeKey
                                                                   secretKey:kSecretKey];
    
    [PubNub setupWithConfiguration:configuration andDelegate:self];
    
    [PubNub connect];
    
    _channels = [PNChannel channelsWithNames:@[@"test_ios_1", @"test_ios_2", @"test_ios_3"]];
    _group = [PNChannelGroup channelGroupWithName:@"test_channel_group" inNamespace:@"unit_test_ios_namespace" shouldObservePresence:NO];
    
    _testMessage = @"Test message";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [PubNub disconnect];
    
    [super tearDown];
}

/**
 Test cases:
  - subscribe on
  - subscribe with completion block
  - subscribe with client state
  - subscribe with client state and completion block
  - unsubscribe
  - unsubscribe with completion block
 */
 
#pragma mark - Tests

- (void)testSubscribeOn {
    
    _resGroup1 = dispatch_group_create();
    
    [[PubNub sharedInstance] addChannels:_channels toGroup:_group];
    
    [PubNub subscribeOn:@[_group]];
    
    [GCDWrapper sleepForSeconds:3];
    
    XCTAssert([PubNub isSubscribedOn:_group], @"Is not subscribed on group 1");
    
    // check that if we send a message to this group we are able to receive it
    
    dispatch_group_enter(_resGroup1);
    dispatch_group_enter(_resGroup1);
    
    [PubNub sendMessage:_testMessage
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

- (void)testSubscribeOnWithCompletionBlock {
}

- (void)testSubscribeWithClientState {
}

- (void)testSubscribeWithClientStateAndCompletionBlock {
    
}

- (void)testUnsubscribe {
    
}

- (void)testUnsubscribeWithCompletionBlock {
    
}

#pragma mark - Instance version

- (void)testSubscribeOnInstance {
}

- (void)testSubscribeOnWithCompletionBlockInstance {
}

- (void)testSubscribeWithClientStateInstance {
}

- (void)testSubscribeWithClientStateAndCompletionBlockInstance {
    
}

- (void)testUnsubscribeInstance {
    
}

- (void)testUnsubscribeWithCompletionBlockInstance {
    
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    if (_resGroup1) {
        dispatch_group_leave(_resGroup1);
    }
}

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    if (_resGroup1) {
        XCTFail(@"Did fail during test 1: %@", error);
        dispatch_group_leave(_resGroup1);
    }
}

@end
