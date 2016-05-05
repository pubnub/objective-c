//
//  PNSubscribeLoopTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/21/16.
//
//

#import "PNSubscribeLoopTestCase.h"
#import "XCTestCase+PNChannelGroup.h"
//#import "PNTestConstants.h"

@interface PNSubscribeLoopTestCase ()
@property (nonatomic, strong) XCTestExpectation *channelSubscribeSetUpExpectation;
@property (nonatomic, strong) XCTestExpectation *channelGroupSubscribeSetUpExpectation;
@property (nonatomic, strong) XCTestExpectation *tearDownExpectation;
@property (nonatomic, assign) BOOL isSettingUp;
@property (nonatomic, assign) BOOL isTearingDown;
@end

@implementation PNSubscribeLoopTestCase

- (void)setUp {
    [super setUp];
    self.isSettingUp = YES;
    self.isTearingDown = NO;
    [self.client addListener:self];
    if (![self shouldRunSetUp]) {
        self.isSettingUp = NO;
        return;
    }
    if (self.subscribedChannels.count) {
        self.channelSubscribeSetUpExpectation = [self expectationWithDescription:@"channel subscribe setUp"];
        [self.client subscribeToChannels:self.subscribedChannels withPresence:self.shouldSubscribeWithPresence];
    }
    if (self.subscribedChannelGroups.count) {
        // loop through all channel groups
        for (NSString *channelGroup in self.subscribedChannelGroups) {
            // first remove channel group
            [self.client removeChannelsFromGroup:channelGroup withCompletion:[self PN_channelGroupRemoveAllChannels]];
            [self waitFor:kPNChannelGroupChangeTimeout];
            NSArray<NSString *> *channels = [self expectedChannelsForChannelGroup:channelGroup];
            [self.client addChannels:channels toGroup:channelGroup withCompletion:[self PN_channelGroupAdd]];
            [self waitFor:kPNChannelGroupChangeTimeout];
        }
        self.channelGroupSubscribeSetUpExpectation = [self expectationWithDescription:@"channel group subscribe setUp"];
        [self.client subscribeToChannelGroups:self.subscribedChannelGroups withPresence:self.shouldSubscribeWithPresence];
    }
    PNWeakify(self);
    [self waitFor:kPNSubscribeTimeout withHandler:^(NSError * _Nullable error) {
        PNStrongify(self);
        self.isSettingUp = NO;
    }];
}

- (void)tearDown {
    if ([self shouldRunTearDown]) {
        self.isTearingDown = YES;
        self.tearDownExpectation = [self expectationWithDescription:@"tearDown"];
        [self.client unsubscribeFromAll];
        [self waitFor:kPNUnsubscribeTimeout];
    }
    [self.client removeListener:self];
    self.isTearingDown = NO;
    [super tearDown];
}

#pragma mark - Subscribed Channels

- (NSArray<NSString *> *)subscribedChannels {
    return @[];
}

- (NSArray<NSString *> *)subscribedChannelGroups {
    return @[];;
}

- (BOOL)shouldSubscribeWithPresence {
    return NO;
}

- (BOOL)shouldRunSetUp {
    return YES;
}

- (BOOL)shouldRunTearDown {
    return YES;
}

- (NSArray<NSString *> *)expectedChannelsForChannelGroup:(NSString *)channelGroup {
    return @[];
}

#pragma mark - Helpers

- (BOOL)expectedSubscribeChannelGroupsMatches:(NSArray<NSString *> *)actualChannelGroups {
    return [self _compareExpectedSubscribables:self.subscribedChannelGroups withActualSubscribables:actualChannelGroups];
}

- (BOOL)expectedSubscribeChannelsMatches:(NSArray<NSString *> *)actualChannels {
    return [self _compareExpectedSubscribables:self.subscribedChannels withActualSubscribables:actualChannels];
}

- (BOOL)_compareExpectedSubscribables:(NSArray<NSString *> *)expectedSubscribables withActualSubscribables:(NSArray<NSString *> *)actualSubscribables {
    if (
        !expectedSubscribables &&
        !actualSubscribables
        ) {
        return YES;
    }
    NSArray *finalExpectedSubscribables = expectedSubscribables.copy;
    if (self.shouldSubscribeWithPresence) {
        NSMutableArray<NSString *> *updatedExpectedSubscribables = [NSMutableArray array];
        for (NSString *channel in finalExpectedSubscribables) {
            [updatedExpectedSubscribables addObject:channel];
            NSString *presenceChannel = [channel stringByAppendingString:@"-pnpres"];
            [updatedExpectedSubscribables addObject:presenceChannel];
        }
        finalExpectedSubscribables = updatedExpectedSubscribables.copy;
    }
    NSSet *expectedSubscribablesSet = [NSSet setWithArray:finalExpectedSubscribables];
    NSSet *actualSubscribablesSet = [NSSet setWithArray:actualSubscribables];
    
    return [expectedSubscribablesSet isEqualToSet:actualSubscribablesSet];
}

- (BOOL)expectedAllSubscriptionsMatchesChannels:(NSArray<NSString *> *)actualChannels andChannelGroups:(NSArray<NSString *> *)actualChannelGroups {
    return (
            ([self expectedSubscribeChannelsMatches:actualChannels]) &&
            ([self expectedSubscribeChannelGroupsMatches:actualChannelGroups])
            );
}


#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    if (self.isSettingUp) {
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqualObjects(self.client.channels, self.subscribedChannels);
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
//        XCTAssertEqualObjects(subscribeStatus.subscribedChannels, self.subscribedChannels);
        XCTAssertTrue([self expectedSubscribeChannelsMatches:subscribeStatus.subscribedChannels]);
        XCTAssertEqualObjects(subscribeStatus.subscribedChannelGroups, self.subscribedChannelGroups);
        //        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @14612663455086844);
        //        XCTAssertEqualObjects(subscribeStatus.data.subscribedChannel, self.subscribedChannels.firstObject);
        //        XCTAssertEqualObjects(subscribeStatus.data.actualChannel, self.subscribedChannels.firstObject);
        [self.channelSubscribeSetUpExpectation fulfill];
        return; // return after setUp
    } else if (self.isTearingDown) {
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        XCTAssertEqualObjects(self.client.channels, @[]);
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
        XCTAssertEqualObjects(subscribeStatus.subscribedChannels, @[]);
        //        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @12);
        //        XCTAssertEqualObjects(subscribeStatus.data.subscribedChannel, self.subscribedChannels.firstObject);
        //        XCTAssertEqualObjects(subscribeStatus.data.actualChannel, self.subscribedChannels.firstObject);
        [self.tearDownExpectation fulfill];
        return; //return after tearDown
    }
    if (self.didReceiveStatusHandler) {
        self.didReceiveStatusHandler(client, status);
    }
    
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    if (self.didReceiveMessageHandler) {
        self.didReceiveMessageHandler(client, message);
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    if (self.didReceivePresenceEventHandler) {
        self.didReceivePresenceEventHandler(client, event);
    }
}

@end
