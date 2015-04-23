//
//  PNSubscribeUnsubscribeChannelsTest.m
//  UnitTests
//
//  Created by Sergey on 11/25/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface PNSubscribeUnsubscribeChannelsTest : XCTestCase {
    GCDGroup *_resGroup;
 }

@end

@implementation PNSubscribeUnsubscribeChannelsTest

- (void)setUp
{
    [super setUp];
    [PubNub disconnect];
}

- (void)tearDown
{
    [PubNub disconnect];
    [super tearDown];
}

- (BOOL)connectToPubNub {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    PNConfiguration *configuration = [PNConfiguration defaultTestConfiguration];
    configuration.cipherKey = nil;
    
    configuration.presenceHeartbeatTimeout = 30;
    configuration.presenceHeartbeatInterval = 7;
    
    [PubNub setConfiguration:configuration];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [_resGroup leave];
    } errorBlock:^(PNError *connectionError) {
        XCTFail(@"Error when connection %@", connectionError);
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. PubNub does't connected");
    }
    
    _resGroup = nil;
    
    return [[PubNub sharedInstance] isConnected];
}
    
- (BOOL)subscribeOnChannels:(NSArray*)subChannels {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    NSArray *_channels = [PNChannel channelsWithNames:subChannels];
    
    [PubNub subscribeOn:_channels withClientState:nil andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        XCTAssertNil(error,@"Error when subscribing on channels");
        switch (state) {
            case PNSubscriptionProcessSubscribedState: {
                [_resGroup leave];
            }
                break;
            default:
                break;
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
        
        _resGroup = nil;
        
        return NO;
    } else {
        
        _resGroup = nil;
        
        return YES;
    }
}

- (BOOL)unsubscribeFromChannels:(NSArray*)unsubChannels {

    _resGroup = [GCDGroup group];
    
    NSArray *_channels = [PNChannel channelsWithNames:unsubChannels];
    
    [_resGroup enter];
    
    [PubNub unsubscribeFrom:_channels withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        XCTAssertNil(error,@"Error unsubscribing from channels");
        [_resGroup leave];
    }];
    
    BOOL res = YES;
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't unsubscribing from channels");
        res = NO;
    }
    
    _resGroup = nil;
    
    return res;
}

- (NSUInteger)getCountSubscribedChannels {
    return [[PubNub subscribedObjectsList] count];
}

- (void)testScenario {
    
    XCTAssertTrue(([self connectToPubNub]));

    // Test subscribe on channel with the same name
    XCTAssertTrue(([self subscribeOnChannels:@[@"test_a", @"test_b", @"test_c"]]));
    XCTAssertTrue(([self subscribeOnChannels:@[@"test_a", @"test_b", @"test_d"]]));
    XCTAssertEqual([self getCountSubscribedChannels], 4);

    // Test unsubscribe from channel
    XCTAssertTrue(([self unsubscribeFromChannels:@[@"test_a", @"test_b", @"test_c", @"test_d"]]));
    XCTAssertEqual([self getCountSubscribedChannels], 0);
    
    // Test unsubscribe from unsubscribed channel next more
    XCTAssertTrue(([self unsubscribeFromChannels:@[@"test_a"]]));
    XCTAssertEqual([self getCountSubscribedChannels], 0);
}

@end

