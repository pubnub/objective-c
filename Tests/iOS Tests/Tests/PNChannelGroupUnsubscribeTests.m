//
//  PNChannelGroupUnsubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/28/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

static NSString * const kPNChannelGroupTestsName = @"PNChannelGroupUnsubscribeTests";

@interface PNChannelGroupUnsubscribeTests : PNBasicSubscribeTestCase

@end

@implementation PNChannelGroupUnsubscribeTests

- (BOOL)isRecording{
    return NO;
}

- (NSArray *)channelGroups {
    return @[
             kPNChannelGroupTestsName
             ];
}

- (void)setUp {
    [super setUp];
    [self performVerifiedRemoveAllChannelsFromGroup:kPNChannelGroupTestsName withAssertions:nil];
    PNWeakify(self);
    [self performVerifiedAddChannels:@[@"a", @"b"] toGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
    
    BOOL shouldObservePresence = NO;
    NSString *expectedMessage;
    NSNumber *expectedTimeToken;
    NSArray *expectedChannelGroups;
    if (self.invocation.selector == @selector(testSimpleUnsubscribeWithNoPresence)) {
        shouldObservePresence = NO;
        expectedMessage = @"********....... 8449 - 2015-12-22 13:28:00";
        expectedTimeToken = @14508196796692323;
        expectedChannelGroups = @[
                                  kPNChannelGroupTestsName
                                  ];
    } else if (self.invocation.selector == @selector(testSimpleUnsubscribeWithPresence)) {
        shouldObservePresence = YES;
        expectedMessage =  @"*********...... 8450 - 2015-12-22 13:28:01";
        expectedTimeToken = @14508196810395526;
        expectedChannelGroups = @[
                                  kPNChannelGroupTestsName,
                                  [kPNChannelGroupTestsName stringByAppendingString:@"-pnpres"]
                                  ];
    } else {
        XCTFail(@"unexpected presence state for channel group unsubscribe test");
    }
    
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups],
                              [NSSet setWithArray:expectedChannelGroups]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, expectedTimeToken);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertEqualObjects(message.data.channel, @"a");
        XCTAssertEqualObjects(message.data.subscription, kPNChannelGroupTestsName);
        XCTAssertEqualObjects(message.data.message, expectedMessage);
        [self.channelGroupSubscribeExpectation fulfill];
        self.channelGroupSubscribeExpectation = nil;
    };
    
    [self PNTest_subscribeToChannelGroups:[self channelGroups] withPresence:shouldObservePresence];
}

- (void)testSimpleUnsubscribeWithPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertNotNil(status);
        XCTAssertEqualObjects(self.client, client);
        if (
            !(
              (status.category == PNDisconnectedCategory) ||
              (status.category == PNCancelledCategory)
              )
            ) {
            return;
        }
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        [self.channelGroupUnsubscribeExpectation fulfill];
    };
    [self PNTest_unsubscribeFromChannelGroups:[self channelGroups] withPresence:YES];
}

- (void)testSimpleUnsubscribeWithNoPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertNotNil(status);
        XCTAssertEqualObjects(self.client, client);
        if (
            !(
              (status.category == PNDisconnectedCategory) ||
              (status.category == PNCancelledCategory)
              )
            ) {
            return;
        }
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        [self.channelGroupUnsubscribeExpectation fulfill];
    };
    [self PNTest_unsubscribeFromChannelGroups:[self channelGroups] withPresence:NO];
}

@end
