//
//  PNSubscribeLoopTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/21/16.
//
//

#import "PNSubscribeLoopTestCase.h"
#import "XCTestCase+PNChannelGroup.h"
#import "XCTestCase+PNSubscription.h"
//#import "PNTestConstants.h"

@interface PNSubscribeLoopTestCase ()
@property (nonatomic, strong) XCTestExpectation *channelSubscribeSetUpExpectation;
@property (nonatomic, strong) XCTestExpectation *channelGroupSubscribeSetUpExpectation;
@property (nonatomic, strong) XCTestExpectation *tearDownExpectation;
@property (nonatomic, assign) BOOL hasSetUpChannelSubscriptions;
@property (nonatomic, assign) BOOL hasSetUpChannelGroupSubscriptions;
@property (nonatomic, assign, readonly) BOOL isSettingUp;
@property (nonatomic, assign) BOOL isTearingDown;
@property (nonatomic, strong) dispatch_queue_t accessQueue;
@property (nonatomic, assign) NSInteger expectedMessageResultIndex;
@property (nonatomic, assign) NSInteger expectedSubscribeStatusIndex;
@property (nonatomic, assign) NSInteger expectedPresenceResultIndex;
@end

@implementation PNSubscribeLoopTestCase

- (NSInteger)expectedMessageResultIndex {
    __block NSInteger currentMessageResultIndex = 0;
    PNWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        PNStrongify(self);
        currentMessageResultIndex = self->_expectedMessageResultIndex;
    });
    return currentMessageResultIndex;
}

- (NSInteger)expectedPresenceResultIndex {
    __block NSInteger currentPresenceResultIndex = 0;
    PNWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        PNStrongify(self);
        currentPresenceResultIndex = self->_expectedPresenceResultIndex;
    });
    return currentPresenceResultIndex;
}

- (NSInteger)expectedSubscribeStatusIndex {
    __block NSInteger currentSubscribeStatusIndex = 0;
    PNWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        PNStrongify(self);
        currentSubscribeStatusIndex = self->_expectedSubscribeStatusIndex;
    });
    return currentSubscribeStatusIndex;
}

- (void)incrementExpectedMessageResultIndex {
    PNWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        PNStrongify(self);
        self->_expectedMessageResultIndex++;
    });
}

- (void)incrementExpectedSubscribeStatusIndex {
    PNWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        PNStrongify(self);
        self->_expectedSubscribeStatusIndex++;
    });
}

- (void)incrementExpectedPresenceResultIndex {
    PNWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        PNStrongify(self);
        self->_expectedPresenceResultIndex++;
    });
}

- (void)setUp {
    [super setUp];
    self.accessQueue = dispatch_queue_create("com.PubNubTest.subscriberAccessQueue", DISPATCH_QUEUE_CONCURRENT);
    _expectedMessageResultIndex = 0;
    _expectedPresenceResultIndex = 0;
    _expectedSubscribeStatusIndex = 0;
//    self.isSettingUp = YES;
    self.hasSetUpChannelSubscriptions = NO;
    self.hasSetUpChannelGroupSubscriptions = NO;
    self.isTearingDown = NO;
    [self.client addListener:self];
    if (![self shouldRunSetUp]) {
//        self.isSettingUp = NO;
        self.hasSetUpChannelGroupSubscriptions = YES;
        self.hasSetUpChannelGroupSubscriptions = YES;
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
    [self waitFor:kPNSubscribeTimeout];
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

- (BOOL)isSettingUp {
    return (
            !self.hasSetUpChannelSubscriptions &&
            !self.hasSetUpChannelGroupSubscriptions
            );
}

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
        
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
//        XCTAssertEqualObjects(subscribeStatus.subscribedChannels, self.subscribedChannels);
        if (!self.hasSetUpChannelSubscriptions) {
            XCTAssertEqualObjects(self.client.channels, self.subscribedChannels);
            XCTAssertTrue([self expectedSubscribeChannelsMatches:subscribeStatus.subscribedChannels]);
            self.hasSetUpChannelSubscriptions = YES;
            [self.channelSubscribeSetUpExpectation fulfill];
        }
        if (!self.hasSetUpChannelGroupSubscriptions) {
            XCTAssertEqualObjects(self.client.channelGroups, self.subscribedChannelGroups);
            XCTAssertTrue([self expectedSubscribeChannelGroupsMatches:subscribeStatus.subscribedChannelGroups]);
            self.hasSetUpChannelGroupSubscriptions = YES;
            [self.channelGroupSubscribeSetUpExpectation fulfill];
        }
//        XCTAssertTrue([self expectedSubscribeChannelsMatches:subscribeStatus.subscribedChannels]);
//        XCTAssertEqualObjects(subscribeStatus.subscribedChannelGroups, self.subscribedChannelGroups);
        
        //        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @14612663455086844);
        //        XCTAssertEqualObjects(subscribeStatus.data.subscribedChannel, self.subscribedChannels.firstObject);
        //        XCTAssertEqualObjects(subscribeStatus.data.actualChannel, self.subscribedChannels.firstObject);
//        [self.channelSubscribeSetUpExpectation fulfill];
        return; // return after setUp
    } else if (self.isTearingDown) {
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        XCTAssertEqualObjects(self.client.channels, @[]);
        XCTAssertEqualObjects(self.client.channelGroups, @[]);
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
        XCTAssertEqualObjects(subscribeStatus.subscribedChannels, @[]);
        XCTAssertEqualObjects(subscribeStatus.subscribedChannelGroups, @[]);
        //        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @12);
        //        XCTAssertEqualObjects(subscribeStatus.data.subscribedChannel, self.subscribedChannels.firstObject);
        //        XCTAssertEqualObjects(subscribeStatus.data.actualChannel, self.subscribedChannels.firstObject);
        [self.tearDownExpectation fulfill];
        return; //return after tearDown
    }
    NSInteger index = self.expectedSubscribeStatusIndex;
    if (self.expectedSubscribeStatuses[index]) {
        PNTestSubscribeStatus *expectedSubscribeStatus = self.expectedSubscribeStatuses[index];
        [self PN_successfulSubscribeWithExpectedResult:expectedSubscribeStatus andActualStatus:(PNSubscribeStatus *)status withComparisonType:PNTestSubscribeComparisonTypeContains];
        [self incrementExpectedSubscribeStatusIndex];
    }
    if (self.didReceiveStatusHandler) {
        self.didReceiveStatusHandler(client, status);
    }
    
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    NSInteger index = self.expectedMessageResultIndex;
    if (self.expectedMessageResults[index]) {
        PNTestMessageResult *expectedMessage = self.expectedMessageResults[index];
        // assert here
        [self PN_successfulMessageWithExpectedMessage:expectedMessage andActualMessage:message];
        [self incrementExpectedMessageResultIndex];
    }
    if (self.didReceiveMessageHandler) {
        self.didReceiveMessageHandler(client, message);
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    NSInteger index = self.expectedPresenceResultIndex;
    if (self.expectedPresenceResults[index]) {
        PNTestPresenceResult *expectedPresenceResult = self.expectedPresenceResults[index];
        // assert here
        [self PN_successfulPresenceEventWithExpectedEvent:expectedPresenceResult andActualEvent:event];
        [self incrementExpectedPresenceResultIndex];
    }
    if (self.didReceivePresenceEventHandler) {
        self.didReceivePresenceEventHandler(client, event);
    }
}

@end
