//
//  MessageToUnsubChannelTest.m
//  UnitTests
//
//  Created by Sergey on 12/16/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface MessageToUnsubChannelTest : XCTestCase <PNDelegate>
@end

@implementation MessageToUnsubChannelTest {
    GCDGroup *_resGroup1;
    GCDGroup *_resGroup2;
    GCDGroup *_resGroup3;
    GCDGroup *_resGroup4;
    GCDGroup *_resGroup6;
}


- (void)setUp {
    [super setUp];
    [PubNub disconnect];
    [PubNub setDelegate:self];
}

- (void)tearDown {
    [PubNub setDelegate:nil];
    [PubNub disconnect];
    [super tearDown];
}

- (BOOL)connectToPubNub {
    
    _resGroup1 = [GCDGroup group];
    [_resGroup1 enter];
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kTestPNOriginHost
                                                                  publishKey:kTestPNPublishKey
                                                                subscribeKey:kTestPNSubscriptionKey
                                                                   secretKey:nil
                                                                   cipherKey:nil];
    configuration.presenceHeartbeatTimeout = 30;
    configuration.presenceHeartbeatInterval = 7;
    
    [PubNub setConfiguration:configuration];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [_resGroup1 leave];
    } errorBlock:^(PNError *connectionError) {
        XCTFail(@"Error when connection %@", connectionError);
        [_resGroup1 leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup1 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. PubNub does't connected");
    }
    
    _resGroup1 = nil;
    return [[PubNub sharedInstance] isConnected];
}

- (BOOL)subscribeOnChannels:(NSArray*)subChannels {
    
    _resGroup2 = [GCDGroup group];
    [_resGroup2 enter];
    
    NSArray *_channels = [PNChannel channelsWithNames:subChannels];
    
    [PubNub subscribeOn:_channels withClientState:nil andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        XCTAssertNil(error,@"Error when subscribing on channels");
        switch (state) {
            case PNSubscriptionProcessSubscribedState: {
                [_resGroup2 leave];
            }
                break;
            default:
                break;
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup2 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
        _resGroup2 = nil;
        return NO;
    } else {
        _resGroup2 = nil;
        return YES;
    }
}

- (BOOL)sendMessageToChannel:(NSString *)channel
                     message:(NSString *)message {
    PNChannel *_channel = [PNChannel channelWithName:channel];
    
    _resGroup3 = [GCDGroup group];
    [_resGroup3 enter];
    
    [PubNub sendMessage:message
              toChannel:_channel
             compressed:YES
    withCompletionBlock:^(PNMessageState state, id data) {
        switch (state) {
            case PNMessageSending:
                break;
            case PNMessageSendingError:
                XCTFail(@"Error during PNMessageSending occured: PNMessageSendingError");
                [_resGroup3 leave];
                break;
            case PNMessageSent:
                [_resGroup3 leave];
                break;
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup3 timeoutFiredValue:3]) {
        XCTFail(@"Timeout is fired. Not all messages were sent");
        _resGroup3 = nil;
        return NO;
    }
    else {
        _resGroup3 = nil;
        return  YES;
    }
    
}

- (BOOL)unsubscribeFromChannels:(NSArray*)unsubChannels {
    
    _resGroup4 = [GCDGroup group];
    [_resGroup4 enter];
    
    NSArray *_channels = [PNChannel channelsWithNames:unsubChannels];
    
    [PubNub unsubscribeFrom:_channels withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        XCTAssertNil(error,@"Error unsubscribing from channels");
        [_resGroup4 leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup3 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't unsubscribing from channels");
        _resGroup4 = nil;
        return NO;
    }
    else {
        _resGroup4 = nil;
        return YES;
    }
    
}

- (void)t1estScenario1 {
    
    XCTAssertTrue([self connectToPubNub]);
    
    XCTAssertTrue(([self subscribeOnChannels:@[@"iosdev1",@"iosdev2",@"iosdev3",@"iosdev4"]]));
 
    XCTAssertTrue([self sendMessageToChannel:@"iosdev3" message:@"Hello world #1"]);
    
    XCTAssertTrue([self unsubscribeFromChannels:@[@"iosdev2"]]);
    
    XCTAssertTrue([self sendMessageToChannel:@"iosdev4" message:@"Hello world #2"]);
    
}

- (void)testScenario2 {
    
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub setDelegate:self];
    
    // Connect
    _resGroup1 = [GCDGroup group];
    [_resGroup1 enter];
    
    [PubNub connect];
    
    if ([GCDWrapper isGCDGroup:_resGroup1 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't connect to PubNub");
        _resGroup1 = nil;
    }
    
    // Subscribe on group
    _resGroup2 = [GCDGroup group];
    [_resGroup2 enter];

    [PubNub subscribeOn:[PNChannel channelsWithNames:@[@"iosdev1",@"iosdev2",@"iosdev3",@"iosdev4"]]];
    
    if ([GCDWrapper isGCDGroup:_resGroup2 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
        _resGroup2 = nil;
     }
    
    // Send message 1
    _resGroup3 = [GCDGroup group];
    [_resGroup3 enter];
    
    [PubNub sendMessage:@"Hello world #1" toChannel:[PNChannel channelWithName:@"iosdev3"]];
    
    if ([GCDWrapper isGCDGroup:_resGroup3 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't send message");
        _resGroup3 = nil;
    }
    
    // Unsubscribe from channel
    _resGroup4 = [GCDGroup group];
    [_resGroup4 enter];
    
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"iosdev2"]]];
    
    if ([GCDWrapper isGCDGroup:_resGroup4 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't unsubscribe from channels");
        _resGroup4 = nil;
    }

    // Send message 2
    _resGroup3 = [GCDGroup group];
    [_resGroup3 enter];
    
    [PubNub sendMessage:@"Hello world #2" toChannel:[PNChannel channelWithName:@"iosdev4"]];

    if ([GCDWrapper isGCDGroup:_resGroup3 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't send message");
        _resGroup3 = nil;
    }
    
    // Unsubscribe from left channels
    _resGroup6 = [GCDGroup group];
    [_resGroup6 enter];
    
    [PubNub unsubscribeFrom:@[[PNChannel channelsWithNames:@[@"iosdev1",@"iosdev3",@"iosdev4"]]]];
    
    if ([GCDWrapper isGCDGroup:_resGroup6 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't unsubscribe from channels");
        _resGroup6 = nil;
    }

}


#pragma mark - PubNub Delegate

// Connect will
- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {

}

// Connect did
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    if (_resGroup1) {
        [_resGroup1 leave];
    }
}

// Connect fail
- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    XCTFail(@"Did fail connection: %@", error);
}


// Subscribe on did
- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    if (_resGroup2) {
        [_resGroup2 leave];
    }
}

// Subscribe on fail
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    XCTFail(@"Did fail subscription: %@", error);
}


// Send message did
- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
    if (_resGroup3) {
        [_resGroup3 leave];
    }
}

// Send message fail
- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
    XCTFail(@"Did fail message send: %@", error);
}


// Unsubscribe from did
- (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
    if (_resGroup4) {
        [_resGroup4 leave];
    }
    if (_resGroup6) {
        [_resGroup6 leave];
    }

}

// Unsubscribe from fail
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    XCTFail(@"Did fail unsubscription: %@", error);
}


@end
