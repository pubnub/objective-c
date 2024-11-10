/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import "PNSubscribeEventData+Private.h"
#import "NSString+PNTest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNSubscribeIntegrationTest : PNRecordableTestCase


#pragma mark - Information

@property (nonatomic, assign) NSUInteger initializedClientsCount;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNSubscribeIntegrationTest


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    BOOL shouldSetupVCR = [super shouldSetupVCR];
    
    if ([self.name pnt_includesString:@"RandomIV"]) {
        shouldSetupVCR = NO;
    }
    
    return shouldSetupVCR;
}


#pragma mark - Setup / Tear down

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
    configuration.useRandomInitializationVector = [self.name rangeOfString:@"RandomIV"].location != NSNotFound;
    configuration.presenceHeartbeatValue = 20;
    configuration.presenceHeartbeatInterval = 0;
    
    if ([name pnt_includesAnyString:@[@"SetToKeepTimetokenOnChannelsListChange", @"SetToKeepTimetokenChannelGroupsListChange"]]) {
        configuration.keepTimeTokenOnListChange = YES;
    } else if ([name pnt_includesAnyString:@[@"SetToNotKeepTimetokenOnChannelsListChange", @"SetToNotKeepTimetokenOnChannelGroupsListChange"]]) {
        configuration.keepTimeTokenOnListChange = NO;
    } else if ([name pnt_includesString:@"CipherKey"]) {
        configuration.cipherKey = @"enigma";
        
        if ([name pnt_includesString:@"DifferentCipherKey"] && self.initializedClientsCount >= 2) {
            configuration.cipherKey = @"secret";
        }
    }

    self.initializedClientsCount++;
    
    return configuration;
}

- (BOOL)usePAMEnabledKeysForTestCaseWithName:(NSString *)name {
    return [self.name pnt_includesString:@"AccessDenied"];
}

- (void)setUp {
    [super setUp];
    
    if (![self.name pnt_includesString:@"Encrypted"]) {
        [self completePubNubConfiguration:self.client];
    }
}


#pragma mark - Tests :: Subscribe to channel

- (void)testItShouldSubscribeToSingleChannelAndReceiveConnectedEvent {
    NSString *channel = [self channelWithName:@"test-channel1"];

    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                XCTAssertNotEqual([status.subscribedChannels indexOfObject:channel], NSNotFound);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedAscending);
                XCTAssertTrue([self.client isSubscribedOn:channel]);
                *remove = YES;

                handler();
            }
        }];
        
        [self.client subscribeToChannels:@[channel] withPresence:NO];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndTriggerOnlineEvent {
    NSString *channel = [self channelWithName:@"test-channel1"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];

    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {

                XCTAssertEqual([@0 compare:event.data.presence.timetoken], NSOrderedAscending);
                XCTAssertEqualObjects(event.data.subscription, channel);
                XCTAssertEqualObjects(event.data.channel, channel);
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 subscribeToChannels:@[channel] withPresence:NO];
    }];
}

- (void)testItShouldSubscribeToSingleChannelWithPresenceAndReceiveOwnOnlineEvent {
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:self.client
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:self.client.currentConfiguration.userID]) {

                NSString *presenceChannel = [channel stringByAppendingString:@"-pnpres"];
                XCTAssertEqualObjects(event.data.presence.uuid, self.client.currentConfiguration.userID);
                XCTAssertEqual([@0 compare:event.data.presence.timetoken], NSOrderedAscending);
                XCTAssertNotEqual([self.client.presenceChannels indexOfObject:presenceChannel], NSNotFound);
                XCTAssertEqualObjects(event.data.subscription, channel);
                XCTAssertEqualObjects(event.data.channel, channel);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:@[channel] withPresence:YES];
    }];
}

- (void)testItShouldSubscribeToMultipleChannelsAndReceiveConnectedEvent {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *subscriptionChannelsSet = [NSSet setWithArray:channels];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                NSSet *subscribedChannelsSet = [NSSet setWithArray:status.subscribedChannels];
                XCTAssertTrue([subscribedChannelsSet isEqualToSet:subscriptionChannelsSet]);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedAscending);
                XCTAssertTrue([self.client isSubscribedOn:channels.lastObject]);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:channels withPresence:NO];
    }];
}

- (void)testItShouldSubscribeToMultipleChannelsAndTriggerOnlineEvent {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    __block NSUInteger reportedOnlineCount = 0;
    
    
    [self subscribeClient:client2 toChannels:channels withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {

                XCTAssertTrue([channels containsObject:event.data.subscription]);
                XCTAssertTrue([channels containsObject:event.data.channel]);
                reportedOnlineCount++;
            }
            
            if (reportedOnlineCount == channels.count) {
                *remove = YES;
                handler();
            }
        }];
        
        [client1 subscribeToChannels:channels withPresence:NO];
    }];
}

- (void)testItShouldSubscribeToMultipleChannelsAndTriggerOnlineEventWhenSubscribedOnPresenceChannelSeparatelly {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    
    [self subscribeClient:client2 toChannels:channels withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 subscribeToChannels:@[channels.firstObject] withPresence:NO];
    }];
    

    [client2 subscribeToPresenceChannels:@[channels.lastObject]];
    [self waitTask:@"waitForSubscribeOnPresence" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];

    XCTAssertTrue([client2 isSubscribedOn:[channels.lastObject stringByAppendingString:@"-pnpres"]]);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 subscribeToChannels:@[channels.lastObject] withPresence:NO];
    }];
}

- (void)testItShouldSubscribeToMultipleChannelsWithPresenceAndReceiveOwnOnlineEvent {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    __block NSUInteger reportedOnlineCount = 0;
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:self.client
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:self.client.currentConfiguration.userID]) {

                XCTAssertTrue([channels containsObject:event.data.subscription]);
                XCTAssertTrue([channels containsObject:event.data.channel]);
                reportedOnlineCount++;
            }
            
            if (reportedOnlineCount == channels.count) {
                *remove = YES;
                handler();
            }
        }];
        
        [self.client subscribeToChannels:channels withPresence:YES];
    }];
}

/**
 * Test added to cover usage of legacy code allowed to set presence state during subscription call.
 */
- (void)testItShouldSubscribeToSingleChannelAndSetState {
    NSString *channel = [self channelWithName:@"test-channel1"];
    NSDictionary *states = @{
        channel: @{ @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]] }
    };
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:@[channel] withPresence:NO clientState:states];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client stateForUUID:self.client.currentConfiguration.userID onChannel:channel
                   withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
            
            NSDictionary *fetchedState = result.data.state;
            XCTAssertNotNil(fetchedState);
            XCTAssertEqualObjects(fetchedState, states[channel]);
            
            handler();
        }];
    }];
}

/**
 * Test added to cover usage of legacy code allowed to set presence state during subscription call.
 */
- (void)testItShouldSubscribeToMultipleChannelsAndSetState {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSDictionary *states = @{
        channels.firstObject: @{ @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]] },
        channels.lastObject: @{ @"channel2-state": [self randomizedValuesWithValues:@[@"channel-2-random-value"]] }
    };
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:channels withPresence:NO clientState:states];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.state().audit()
            .uuid(self.client.currentConfiguration.userID)
            .channels(channels)
            .performWithCompletion(^(PNClientStateGetResult *result, PNErrorStatus *status) {
                NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqualObjects(fetchedChannels[channels.firstObject], states[channels.firstObject]);
                XCTAssertEqualObjects(fetchedChannels[channels.lastObject], states[channels.lastObject]);
                XCTAssertNotEqualObjects(fetchedChannels[channels.firstObject],
                                         fetchedChannels[channels.lastObject]);
                
                handler();
            });
    }];
}

- (void)testItShouldNotSubscribeToChannelAndReceiveAccessDeniedEventWhenPAMKeysUsed {
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNAccessDeniedCategory) {
                XCTAssertTrue(status.willAutomaticallyRetry);
                [status cancelAutomaticRetry];
                
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:@[channel] withPresence:NO];
    }];
}

- (void)testItShouldNotSubscribeToChannelAndRetryWhenReceiveAccessDeniedEvent {
    NSString *channel = [self channelWithName:@"test-channel1"];
    __block NSUInteger retriedCount = 0;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNAccessDeniedCategory) {
                XCTAssertTrue(status.willAutomaticallyRetry);
                
                if (retriedCount == 1) {
                    [status cancelAutomaticRetry];
                    *remove = YES;
                    handler();
                } else {
                    retriedCount++;
                }
            }
        }];
        
        [self.client subscribeToChannels:@[channel] withPresence:NO];
    }];
}


#pragma mark - Tests :: Subscribe to channel group

- (void)testItShouldSubscribeToSingleChannelGroupAndReceiveConnectedEvent {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    [self addChannels:@[channel] toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                XCTAssertNotEqual([status.subscribedChannelGroups indexOfObject:channelGroup], NSNotFound);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedAscending);
                XCTAssertTrue([self.client isSubscribedOn:channelGroup]);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:@[channelGroup] withPresence:NO];
    }];

    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldSubscribeToSingleChannelGroupAndTriggerOnlineEvent {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSString *channel = [self channelWithName:@"test-channel1"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    
    [self addChannels:@[channel] toChannelGroup:channelGroup usingClient:client1];
    [self subscribeClient:client2 toChannelGroups:@[channelGroup] withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {

                XCTAssertEqual([@0 compare:event.data.presence.timetoken], NSOrderedAscending);
                XCTAssertEqualObjects(event.data.subscription, channelGroup);
                XCTAssertEqualObjects(event.data.channel, channel);
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 subscribeToChannelGroups:@[channelGroup] withPresence:NO];
    }];

    [self removeChannelGroup:channelGroup usingClient:client1];
}

- (void)testItShouldSubscribeToSingleChannelGroupWithPresenceAndReceiveOwnOnlineEvent {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    [self addChannels:@[channel] toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:self.client
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:self.client.currentConfiguration.userID]) {
                NSString *presenceChannelGroup = [channelGroup stringByAppendingString:@"-pnpres"];
                XCTAssertNotEqual([self.client.channelGroups indexOfObject:presenceChannelGroup], NSNotFound);
                XCTAssertEqualObjects(event.data.presence.uuid, self.client.currentConfiguration.userID);
                XCTAssertEqual([@0 compare:event.data.presence.timetoken], NSOrderedAscending);
                XCTAssertEqualObjects(event.data.subscription, channelGroup);
                XCTAssertEqualObjects(event.data.channel, channel);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:@[channelGroup] withPresence:YES];
    }];

    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldSubscribeToMultipleChannelGroupsAndReceiveConnectedEvent {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet<NSString *> *subscriptionChannelGroupsSet = [NSSet setWithArray:channelGroups];
    
    
    [self addChannels:@[channels.firstObject] toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:@[channels.lastObject] toChannelGroup:channelGroups.lastObject usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                NSSet *subscribedChannelGroupsSet = [NSSet setWithArray:status.subscribedChannelGroups];
                XCTAssertTrue([subscribedChannelGroupsSet isEqualToSet:subscriptionChannelGroupsSet]);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedAscending);
                XCTAssertTrue([self.client isSubscribedOn:channelGroups.lastObject]);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:channelGroups withPresence:NO];
    }];

    [self removeChannelGroup:channelGroups.firstObject usingClient:nil];
    [self removeChannelGroup:channelGroups.lastObject usingClient:nil];
}

- (void)testItShouldSubscribeToMultipleChannelGroupsAndTriggerOnlineEvent {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    __block NSUInteger reportedOnlineCount = 0;
    
    
    [self addChannels:@[channels.firstObject] toChannelGroup:channelGroups.firstObject usingClient:client1];
    [self addChannels:@[channels.lastObject] toChannelGroup:channelGroups.lastObject usingClient:client1];
    [self subscribeClient:client2 toChannelGroups:channelGroups withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {

                XCTAssertTrue([channelGroups containsObject:event.data.subscription]);
                XCTAssertTrue([channels containsObject:event.data.channel]);
                reportedOnlineCount++;
            }
            
            if (reportedOnlineCount == channelGroups.count) {
                *remove = YES;
                handler();
            }
        }];
        
        [client1 subscribeToChannelGroups:channelGroups withPresence:NO];
    }];

    [self removeChannelGroup:channelGroups.firstObject usingClient:client1];
    [self removeChannelGroup:channelGroups.lastObject usingClient:client1];
}

- (void)testItShouldSubscribeToMultipleChannelGroupsWithPresenceAndReceiveOwnOnlineEvent {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    __block NSUInteger reportedOnlineCount = 0;
    
    
    [self addChannels:@[channels.firstObject] toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:@[channels.lastObject] toChannelGroup:channelGroups.lastObject usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:self.client
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:self.client.currentConfiguration.userID]) {

                XCTAssertTrue([channelGroups containsObject:event.data.subscription]);
                XCTAssertTrue([channels containsObject:event.data.channel]);
                reportedOnlineCount++;
            }
            
            if (reportedOnlineCount == channelGroups.count) {
                *remove = YES;
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:channelGroups withPresence:YES];
    }];

    [self removeChannelGroup:channelGroups.firstObject usingClient:nil];
    [self removeChannelGroup:channelGroups.lastObject usingClient:nil];
}

/**
 * Test added to cover usage of legacy code allowed to set presence state during subscription call.
 */
- (void)testItShouldSubscribeToSingleChannelGroupAndSetState {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSString *channel = [self channelWithName:@"test-channel1"];
    NSDictionary *states = @{
        channelGroup: @{ @"channel-group-1-state": [self randomizedValuesWithValues:@[@"channel-group-1-random-value"]] }
    };
    
    
    [self addChannels:@[channel] toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:@[channelGroup] withPresence:NO clientState:states];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client stateForUUID:self.client.currentConfiguration.userID onChannel:channel
                   withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
            
            NSDictionary *fetchedState = result.data.state;
            XCTAssertNotNil(fetchedState);
            XCTAssertEqualObjects(fetchedState, states[channelGroup]);
            
            handler();
        }];
    }];

    [self removeChannelGroup:channelGroup usingClient:nil];
}

/**
 * Test added to cover usage of legacy code allowed to set presence state during subscription call.
 */
- (void)testItShouldSubscribeToMultipleChannelGroupsAndSetState {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSDictionary *states = @{
        channelGroups.firstObject: @{
                @"channel-group-1-state": [self randomizedValuesWithValues:@[@"channel-group-1-random-value"]]
        },
        channelGroups.lastObject: @{
                @"channel-group-2-state": [self randomizedValuesWithValues:@[@"channel-group-2-random-value"]]
        }
    };
    
    
    [self addChannels:@[channels.firstObject] toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:@[channels.lastObject] toChannelGroup:channelGroups.lastObject usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:channelGroups withPresence:NO clientState:states];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.state().audit()
            .uuid(self.client.currentConfiguration.userID)
            .channelGroups(channelGroups)
            .performWithCompletion(^(PNClientStateGetResult *result, PNErrorStatus *status) {
                NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqualObjects(fetchedChannels[channels.firstObject], states[channelGroups.firstObject]);
                XCTAssertEqualObjects(fetchedChannels[channels.lastObject], states[channelGroups.lastObject]);
                XCTAssertNotEqualObjects(fetchedChannels[channels.firstObject],
                                         fetchedChannels[channels.lastObject]);
                
                handler();
            });
    }];

    [self removeChannelGroup:channelGroups.firstObject usingClient:nil];
    [self removeChannelGroup:channelGroups.lastObject usingClient:nil];
}

- (void)testItShouldNotSubscribeToChannelGroupAndReceiveAccessDeniedEventWhenPAMKeysUsed {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNAccessDeniedCategory) {
                XCTAssertTrue(status.willAutomaticallyRetry);
                [status cancelAutomaticRetry];
                
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:@[channelGroup] withPresence:NO];
    }];
}

- (void)testItShouldNotSubscribeToChannelGroupAndRetryWhenReceiveAccessDeniedEvent {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    __block NSUInteger retriedCount = 0;
    

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNAccessDeniedCategory) {
                XCTAssertTrue(status.willAutomaticallyRetry);
                
                if (retriedCount == 1) {
                    [status cancelAutomaticRetry];
                    *remove = YES;
                    handler();
                } else {
                    retriedCount++;
                }
            }
        }];
        
        [self.client subscribeToChannelGroups:@[channelGroup] withPresence:NO];
    }];
}


#pragma mark - Tests :: Builder pattern-based subscribe

- (void)testItShouldSubscribeToChannelAndGroupUsingBuilderPatternInterface {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *channel = [self channelWithName:@"test-channel3"];
    NSSet<NSString *> *subscriptionChannelGroupsSet = [NSSet setWithArray:@[channelGroup]];
    NSSet<NSString *> *subscriptionChannelsSet = [NSSet setWithArray:@[channel]];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                NSSet *subscribedChannelGroupsSet = [NSSet setWithArray:status.subscribedChannelGroups];
                NSSet *subscribedChannelsSet = [NSSet setWithArray:status.subscribedChannels];
                XCTAssertTrue([subscribedChannelGroupsSet isEqualToSet:subscriptionChannelGroupsSet]);
                XCTAssertTrue([subscribedChannelsSet isEqualToSet:subscriptionChannelsSet]);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedAscending);
                *remove = YES;
                
                handler();
            }
        }];
        
        self.client.subscribe()
            .channels(@[channel])
            .channelGroups(@[channelGroup])
            .withPresence(NO)
            .perform();
    }];
    
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldSubscribeToPresenceChannelUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    
    [self subscribeClient:client2 toChannels:channels withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertFalse(self.client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 subscribeToChannels:@[channels.firstObject] withPresence:NO];
    }];
    

    client2.subscribe().presenceChannels(@[channels.lastObject]).perform();
    [self waitTask:@"waitForSubscribeOnPresence" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertTrue([client2 isSubscribedOn:[channels.lastObject stringByAppendingString:@"-pnpres"]]);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"join"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 subscribeToChannels:@[channels.lastObject] withPresence:NO];
    }];
}


#pragma mark - Tests :: Unsubscribe from channel

- (void)testItShouldUnsubscribeFromSingleChannelAndReceiveDisconnectedEvent {
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNUnsubscribeOperation && status.category == PNDisconnectedCategory) {
                XCTAssertEqual([status.subscribedChannels indexOfObject:channel], NSNotFound);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedSame);
                *remove = YES;
            }
            
            handler();
        }];
        
        [self.client unsubscribeFromChannels:@[channel] withPresence:NO];
    }];
}

- (void)testItShouldUnsubscribeFromSingleChannelAndTriggerOfflineEvent {
    NSString *channel = [self channelWithName:@"test-channel1"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    
    [self subscribeClient:client1 toChannels:@[channel] withPresence:NO];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"leave"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {

                XCTAssertEqual([@0 compare:event.data.presence.timetoken], NSOrderedAscending);
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 unsubscribeFromChannels:@[channel] withPresence:NO];
    }];
}

- (void)testItShouldUnsubscribeFromMultipleChannelsAndReceiveDisconnectedEvent {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *subscriptionChannelsSet = [NSSet setWithArray:channels];
    
    
    [self subscribeClient:self.client toChannels:channels withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNUnsubscribeOperation && status.category == PNDisconnectedCategory) {
                NSSet *subscribedChannelsSet = [NSSet setWithArray:status.subscribedChannels];
                XCTAssertFalse([subscribedChannelsSet isEqualToSet:subscriptionChannelsSet]);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedSame);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client unsubscribeFromChannels:channels withPresence:NO];
    }];
}

- (void)testItShouldUnsubscribeFromMultipleChannelsAndTriggerOfflineEvent {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    __block NSUInteger reportedOfflineCount = 0;
    
    
    [self subscribeClient:client1 toChannels:channels withPresence:NO];
    [self subscribeClient:client2 toChannels:channels withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"leave"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {

                reportedOfflineCount++;
            }
            
            if (reportedOfflineCount == channels.count) {
                *remove = YES;
                handler();
            }
        }];
        
        [client1 unsubscribeFromChannels:channels withPresence:NO];
    }];
}

- (void)testItShouldUnsubscribeFromoMultipleChannelAndNotTriggerOfflineEventWhenUnsubscribedFromPresenceChannelSeparatelly {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    
    [self subscribeClient:client1 toChannels:channels withPresence:NO];
    [self subscribeClient:client2 toChannels:channels withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"leave"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];

        [client1 unsubscribeFromChannels:@[channels.firstObject] withPresence:NO];
    }];
    
    [client2 unsubscribeFromPresenceChannels:@[channels.lastObject]];
    [self waitTask:@"waitForUnsubscribeFromPresence" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertFalse([client2 isSubscribedOn:[channels.lastObject stringByAppendingString:@"-pnpres"]]);
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"leave"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 unsubscribeFromChannels:@[channels.lastObject] withPresence:NO];
    }];
}


#pragma mark - Tests :: Unsubscribe from channel group

- (void)testItShouldUnsubscribeFromSingleChannelGroupAndReceiveDisconnectedEvent {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    [self addChannels:@[channel] toChannelGroup:channelGroup usingClient:nil];
    [self subscribeClient:self.client toChannelGroups:@[channelGroup] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNUnsubscribeOperation && status.category == PNDisconnectedCategory) {
                XCTAssertEqual([status.subscribedChannelGroups indexOfObject:channelGroup], NSNotFound);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedSame);
                *remove = YES;
            }
            
            handler();
        }];
        
        [self.client unsubscribeFromChannelGroups:@[channelGroup] withPresence:NO];
    }];
    
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldUnsubscribeFromSingleChannelGroupAndTriggerOfflineEvent {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSString *channel = [self channelWithName:@"test-channel1"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    
    [self addChannels:@[channel] toChannelGroup:channelGroup usingClient:client1];
    [self subscribeClient:client1 toChannelGroups:@[channelGroup] withPresence:NO];
    [self subscribeClient:client2 toChannelGroups:@[channelGroup] withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"leave"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {

                XCTAssertEqual([@0 compare:event.data.presence.timetoken], NSOrderedAscending);
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 unsubscribeFromChannelGroups:@[channelGroup] withPresence:NO];
    }];
    
    [self removeChannelGroup:channelGroup usingClient:client1];
}

- (void)testItShouldUnsubscribeFromMultipleChannelGroupsAndReceiveDisconnectedEvent {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *subscriptionChannelGroupsSet = [NSSet setWithArray:channelGroups];
    
    
    [self addChannels:@[channels.firstObject] toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:@[channels.lastObject] toChannelGroup:channelGroups.lastObject usingClient:nil];
    [self subscribeClient:self.client toChannelGroups:channelGroups withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNUnsubscribeOperation && status.category == PNDisconnectedCategory) {
                NSSet *subscribedChannelGroupsSet = [NSSet setWithArray:status.subscribedChannelGroups];
                XCTAssertFalse([subscribedChannelGroupsSet isEqualToSet:subscriptionChannelGroupsSet]);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedSame);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client unsubscribeFromChannelGroups:channelGroups withPresence:NO];
    }];
    
    [self removeChannelGroup:channels.firstObject usingClient:nil];
    [self removeChannelGroup:channels.lastObject usingClient:nil];
}

- (void)testItShouldUnsubscribeFromMultipleChannelGroupsAndTriggerOfflineEvent {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    __block NSUInteger reportedOfflineCount = 0;
    
    
    [self addChannels:@[channels.firstObject] toChannelGroup:channelGroups.firstObject usingClient:client1];
    [self addChannels:@[channels.lastObject] toChannelGroup:channelGroups.lastObject usingClient:client1];
    [self subscribeClient:client1 toChannelGroups:channelGroups withPresence:NO];
    [self subscribeClient:client2 toChannelGroups:channelGroups withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"leave"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {

                reportedOfflineCount++;
            }
            
            if (reportedOfflineCount == channels.count) {
                *remove = YES;
                handler();
            }
        }];
        
        [client1 unsubscribeFromChannelGroups:channelGroups withPresence:NO];
    }];
    
    [self removeChannelGroup:channels.firstObject usingClient:client1];
    [self removeChannelGroup:channels.lastObject usingClient:client1];
}


#pragma mark - Tests :: Builder pattern-based unsubscribe

- (void)testItShouldUnsubscribeFromChannelAndGroupUsingBuilderPatternInterface {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *channel = [self channelWithName:@"test-channel3"];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self subscribeClient:self.client toChannelGroups:@[channelGroup] withPresence:NO];
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
                                  
            if (status.operation == PNUnsubscribeOperation && status.category == PNDisconnectedCategory) {
                XCTAssertEqual(status.subscribedChannelGroups.count, 0);
                XCTAssertEqual(status.subscribedChannels.count, 0);
                *remove = YES;

                handler();
            }
        }];
        
        self.client.unsubscribe()
            .channels(@[channel])
            .channelGroups(@[channelGroup])
            .withPresence(YES)
            .perform();
    }];
    
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldUnsubscribeFromPresenceChannelUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    
    [self subscribeClient:client1 toChannels:channels withPresence:NO];
    [self subscribeClient:client2 toChannels:channels withPresence:YES];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"leave"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];

        [client1 unsubscribeFromChannels:@[channels.firstObject] withPresence:NO];
    }];
    
    client2.unsubscribe().presenceChannels(@[channels.lastObject]).perform();
    [self waitTask:@"waitForUnsubscribeFromPresence" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertFalse([client2 isSubscribedOn:[channels.lastObject stringByAppendingString:@"-pnpres"]]);
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"leave"] &&
                [event.data.presence.uuid isEqualToString:client1.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 unsubscribeFromChannels:@[channels.lastObject] withPresence:NO];
    }];
}


#pragma mark - Tests :: Unsubscribe from all

- (void)testItShouldUnsubscribeFromAllChannelsAndGroupsAndReceiveDisconnectedEvent {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *channel = [self channelWithName:@"test-channel3"];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self subscribeClient:self.client toChannelGroups:@[channelGroup] withPresence:NO];
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForUnsubscribeFromPresence" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNUnsubscribeOperation && status.category == PNDisconnectedCategory) {
                XCTAssertEqual([status.subscribedChannelGroups indexOfObject:channelGroup], NSNotFound);
                XCTAssertEqual([status.subscribedChannels indexOfObject:channel], NSNotFound);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedSame);
                *remove = YES;
            }
            
            handler();
        }];
        
        [self.client unsubscribeFromAll];
    }];
    
    [self removeChannelGroup:channelGroup usingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based unsubscribe from all

- (void)testItShouldUnsubscribeFromAllChannelsAndGroupsUsingBuilderPatternInterface {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *channel = [self channelWithName:@"test-channel3"];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self subscribeClient:self.client toChannelGroups:@[channelGroup] withPresence:NO];
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForUnsubscribeFromPresence" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNUnsubscribeOperation && status.category == PNDisconnectedCategory) {
                XCTAssertEqual([status.subscribedChannelGroups indexOfObject:channelGroup], NSNotFound);
                XCTAssertEqual([status.subscribedChannels indexOfObject:channel], NSNotFound);
                XCTAssertEqual([@0 compare:status.currentTimetoken], NSOrderedSame);
                *remove = YES;
            }
            
            handler();
        }];
        
        self.client.unsubscribe().perform();
    }];
    
    [self removeChannelGroup:channelGroup usingClient:nil];
}


#pragma mark - Tests :: Messages

- (void)testItShouldSubscribeToSingleChannelAndReceiveMessageWhenPublished {
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSString *channel = [self channelWithName:@"test-channel1"];
    NSString *expectedMessageType = @"test-message-type";

    
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
                                   
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                XCTAssertEqualObjects(message.data.customMessageType, expectedMessageType);
                XCTAssertEqualObjects(message.data.subscription, channel);
                XCTAssertEqualObjects(message.data.channel, channel);
                *remove = YES;

                handler();
            }
        }];

        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = publishedMessage;
        request.customMessageType = expectedMessageType;
        [self.client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndReceiveMessageWithUserTimetokenWhenPublished {
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSString *channel = [self channelWithName:@"test-channel1"];


    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {

            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                XCTAssertEqualObjects(message.data.subscription, channel);
                XCTAssertEqualObjects(message.data.channel, channel);
                XCTAssertEqualObjects(message.data.userTimetoken.timetoken, 
                                      @(message.data.timetoken.unsignedIntegerValue - 1));
                XCTAssertNil(message.data.userTimetoken.region);
                XCTAssertNotNil(message.data.userTimetoken);
                *remove = YES;

                handler();
            }
        }];

        [self.client publish:publishedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
}

/**
 * @brief Follow instructions to simulate server response with "broken" payload.
 *
 * Also requires in \c -fixedSerialisedResponse:forHTTPResponse:fromData:withSerialisationError:processingError:
 * with Base64 output of received service response:
 *   NSLog(@"BASE64: %@", [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0]);
 * Use received string with any hex editors to replace random user name and channel with their non-random values and convert back to
 * Base64 string.
 *
 * Received information should be used to add new entry to `ItShouldSubscribeToSingleChannelAndReceiveMessageWhenDataWithNulBytePublished.json`
 * with packet type \b 2 (check previous entries with same type).
 */
- (void)disabled_testItShouldSubscribeToSingleChannelAndReceiveMessageWhenDataWithNulBytePublished {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSString *randomChannel = [self channelWithName:@"nul-channel"];
    NSString *subscription = [randomChannel stringByAppendingString:@".*"];
    NSString *channel = [randomChannel stringByAppendingString:@"."];
    NSString *publishedMessage = @"hello";
    
    if (YHVVCR.cassette.isNewCassette) {
        PNConfiguration *configuration = self.client.currentConfiguration;
        NSLog(@"Run following command in Terminal:\n\ncurl 'http://%@/publish/%@/%@/0/%@.%%FF/0/%%22hel%%FFlo%%22?uuid=%@' ; echo\n\n",
              configuration.origin, configuration.publishKey, configuration.subscribeKey, randomChannel, configuration.userID);
        [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.5f)];
    }
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
                                   
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.subscription, subscription);
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                XCTAssertEqualObjects(message.data.channel, channel);
                *remove = YES;

                handler();
            }
        }];
        
        [self subscribeClient:self.client toChannels:@[subscription] withPresence:NO];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndReceiveDecryptedMessageWhenPublisherAndReceivedHasSameCipherKey {
    NSDictionary *publishedMessage = @{ @"test-message": @"message for encryption" };
    NSString *channel = [self channelWithName:@"test-channel1"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertNotNil(client1.currentConfiguration.cipherKey);
    XCTAssertNotNil(client2.currentConfiguration.cipherKey);
    XCTAssertEqualObjects(client1.currentConfiguration.cipherKey, client2.currentConfiguration.cipherKey);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {

            if ([message.data.publisher isEqualToString:client1.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                XCTAssertEqualObjects(message.data.subscription, channel);
                XCTAssertEqualObjects(message.data.channel, channel);
                *remove = YES;

                handler();
            }
        }];
        
        [client1 publish:publishedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndReceiveDecryptedMessageWhenPublisherAndReceivedHasSameCipherKeyRandomIV {
    NSDictionary *publishedMessage = @{ @"test-message": @"message for encryption" };
    NSString *channel = [self channelWithName:@"test-channel1"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    XCTAssertTrue(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertTrue(client2.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertNotNil(client1.currentConfiguration.cipherKey);
    XCTAssertNotNil(client2.currentConfiguration.cipherKey);
    XCTAssertEqualObjects(client1.currentConfiguration.cipherKey, client2.currentConfiguration.cipherKey);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {

            if ([message.data.publisher isEqualToString:client1.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                XCTAssertEqualObjects(message.data.subscription, channel);
                XCTAssertEqualObjects(message.data.channel, channel);
                *remove = YES;

                handler();
            }
        }];
        
        [client1 publish:publishedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndReceiveNotDecryptedMessageWhenPublishedReceivedHasDifferentCipherKey {
    NSDictionary *publishedMessage = @{ @"test-message": @"message for encryption" };
    NSData *publishedMessageData = [NSJSONSerialization dataWithJSONObject:publishedMessage options:(NSJSONWritingOptions)0 error:nil];
    NSString *channel = [self channelWithName:@"test-channel1"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];


    NSString *encryptedMessage = [PNAES encrypt:publishedMessageData withKey:client1.currentConfiguration.cipherKey];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertNotNil(client1.currentConfiguration.cipherKey);
    XCTAssertNotNil(client2.currentConfiguration.cipherKey);
    XCTAssertNotEqualObjects(client1.currentConfiguration.cipherKey, client2.currentConfiguration.cipherKey);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:client2 withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            if (status.operation == PNSubscribeOperation && status.category == PNDecryptionErrorCategory) {
                PNSubscribeMessageEventData *messageData = status.associatedObject;

                XCTAssertEqualObjects(messageData.message, encryptedMessage);
                XCTAssertEqualObjects(messageData.subscription, channel);
                XCTAssertEqualObjects(messageData.channel, channel);
                *remove = YES;
                
                handler();
            }
        }];
        
        [client1 publish:publishedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToMultipleChannelsAndReceiveMessageWhenPublished {
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    
    [self subscribeClient:self.client toChannels:channels withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
                                   
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                XCTAssertEqualObjects(message.data.subscription, channels.lastObject);
                XCTAssertEqualObjects(message.data.channel, channels.lastObject);
                *remove = YES;

                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channels.lastObject
              withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelWithCatchUpOnSecondChannelWhenSetToKeepTimetokenOnChannelsListChange {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    __block NSNumber *lastTimetoken = nil;
    

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                lastTimetoken = status.currentTimetoken;
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:@[channels.firstObject] withPresence:NO];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client publish:publishedMessage toChannel:channels.lastObject
              withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {

            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:@[channels.lastObject] withPresence:NO];
    }];
}

- (void)testItShouldSubscribeToSingleChannelWithCatchUpOnSecondChannelWhenSubscribedWithTimetoken {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    __block NSNumber *lastTimetoken = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                lastTimetoken = status.currentTimetoken;
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:@[channels.firstObject] withPresence:NO];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client publish:publishedMessage toChannel:channels.lastObject
              withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {

            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                *remove = YES;
                
                handler();
            }
        }];
        
        NSNumber *timetoken = @(lastTimetoken.unsignedLongLongValue - 1);
        [self.client subscribeToChannels:@[channels.lastObject] withPresence:NO usingTimeToken:timetoken];
    }];
}

- (void)testItShouldSubscribeToSingleChannelWithOutCatchUpOnSecondChannelWhenSetToNotKeepTimetokenOnChannelsListChange {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    __block NSNumber *lastTimetoken = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                lastTimetoken = status.currentTimetoken;
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:@[channels.firstObject] withPresence:NO];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client publish:publishedMessage toChannel:channels.lastObject
              withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            NSURLRequest *request = [message valueForKey:@"clientRequest"];
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertTrue([request.URL.absoluteString pnt_includesString:lastTimetoken.stringValue]);
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannels:@[channels.lastObject] withPresence:NO];
    }];
}

- (void)testItShouldSubscribeToSingleChannelGroupAndReceiveMessageWhenPublished {
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group1"];
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    [self addChannels:@[channel] toChannelGroup:channelGroup usingClient:nil];
    [self subscribeClient:self.client toChannelGroups:@[channelGroup] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
                                   
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                XCTAssertEqualObjects(message.data.subscription, channelGroup);
                XCTAssertEqualObjects(message.data.channel, channel);
                *remove = YES;

                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
    
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldSubscribeToMultipleChannelGroupsAndReceiveMessageWhenPublished {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    
    [self addChannels:@[channels.firstObject] toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:@[channels.lastObject] toChannelGroup:channelGroups.lastObject usingClient:nil];
    [self subscribeClient:self.client toChannelGroups:channelGroups withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
                                   
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                XCTAssertEqualObjects(message.data.subscription, channelGroups.firstObject);
                XCTAssertEqualObjects(message.data.channel, channels.firstObject);
                *remove = YES;

                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channels.firstObject
              withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
    
    [self removeChannelGroup:channelGroups.firstObject usingClient:nil];
    [self removeChannelGroup:channelGroups.lastObject usingClient:nil];
}

- (void)testItShouldSubscribeToSingleChannelGroupWithCatchUpOnSecondChannelGroupWhenSetToKeepTimetokenChannelGroupsListChange {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    __block NSNumber *lastTimetoken = nil;
    
    
    [self addChannels:@[channels.firstObject] toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:@[channels.lastObject] toChannelGroup:channelGroups.lastObject usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                lastTimetoken = status.currentTimetoken;
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:@[channelGroups.firstObject] withPresence:NO];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client publish:publishedMessage toChannel:channels.lastObject
              withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {

            NSURLRequest *request = [message valueForKey:@"clientRequest"];
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:@[channelGroups.lastObject] withPresence:NO];
    }];
    
    [self removeChannelGroup:channelGroups.firstObject usingClient:nil];
    [self removeChannelGroup:channelGroups.lastObject usingClient:nil];
}

- (void)testItShouldSubscribeToSingleChannelGroupWithOutCatchUpOnSecondChannelGrpoupWhenSetToNotKeepTimetokenOnChannelGroupsListChange {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    __block NSNumber *lastTimetoken = nil;
    
    
    [self addChannels:@[channels.firstObject] toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:@[channels.lastObject] toChannelGroup:channelGroups.lastObject usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {
            
            if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
                lastTimetoken = status.currentTimetoken;
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:@[channelGroups.firstObject] withPresence:NO];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client publish:publishedMessage toChannel:channels.lastObject
              withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            NSURLRequest *request = [message valueForKey:@"clientRequest"];
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertTrue([request.URL.absoluteString pnt_includesString:lastTimetoken.stringValue]);
                XCTAssertEqualObjects(message.data.message, publishedMessage);
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client subscribeToChannelGroups:@[channelGroups.lastObject] withPresence:NO];
    }];
    
    [self removeChannelGroup:channelGroups.firstObject usingClient:nil];
    [self removeChannelGroup:channelGroups.lastObject usingClient:nil];
}


#pragma mark - Tests :: Signals

- (void)testItShouldSubscribeToSingleChannelAndReceiveSignalWhenSent {
    NSDictionary *message = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSString *channel = [self channelWithName:@"test-channel1"];
    NSString *expectedMessageType = @"test-message-type";


    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addSignalHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNSignalResult *signal, BOOL *remove) {

            if ([signal.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                XCTAssertEqualObjects(signal.data.message, message);
                XCTAssertEqualObjects(signal.data.customMessageType, expectedMessageType);
                XCTAssertEqualObjects(signal.data.subscription, channel);
                XCTAssertEqualObjects(signal.data.channel, channel);
                *remove = YES;

                handler();
            }
        }];

        PNSignalRequest *request = [PNSignalRequest requestWithChannel:channel signal:message];
        request.customMessageType = expectedMessageType;
        [self.client sendSignalWithRequest:request completion:^(PNSignalStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
}


#pragma mark - Tests :: Messages filter expression

- (void)testItShouldSubscribeToSingleChannelAndReceiveMessageWhenFilterExpressionIsSetToExactMatch {
    NSString *filterExpression = [NSString stringWithFormat:@"uuid == '%@'", self.client.currentConfiguration.userID];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSDictionary *messageMetadata = @{ @"uuid": self.client.currentConfiguration.userID };
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    self.client.filterExpression = filterExpression;
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertEqualObjects(self.client.filterExpression, filterExpression);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channel withMetadata:messageMetadata
                  completion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndReceiveMessageWhenFilterExpressionIsSetToCompound {
    NSString *filterExpression = [NSString stringWithFormat:@"uuid == '%@' && (('admin','super-user') contains role) && age >= 32",
                                  self.client.currentConfiguration.userID];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSDictionary *messageMetadata = @{
        @"uuid": self.client.currentConfiguration.userID,
        @"role": @"super-user",
        @"age": @32
    };
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    self.client.filterExpression = filterExpression;
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertEqualObjects(self.client.filterExpression, filterExpression);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channel withMetadata:messageMetadata
                  completion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndReceiveMessageWhenFilterExpressionIsSetToCompoundWithSubstringCheck {
    NSString *filterExpression = [NSString stringWithFormat:@"uuid == '%@' && role contains 'adm' && age >= 32",
                                  self.client.currentConfiguration.userID];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSDictionary *messageMetadata = @{
        @"uuid": self.client.currentConfiguration.userID,
        @"role": @"admin",
        @"age": @32
    };
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    self.client.filterExpression = filterExpression;
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertEqualObjects(self.client.filterExpression, filterExpression);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channel withMetadata:messageMetadata
                  completion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndReceiveMessageWhenFilterExpressionIsSetToCompoundWithLike {
    NSString *filterExpression = [NSString stringWithFormat:@"uuid == '%@' && privileges like '*write' && age >= 32",
                                  self.client.currentConfiguration.userID];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSDictionary *messageMetadata = @{
        @"uuid": self.client.currentConfiguration.userID,
        @"privileges": @[@"write", @"read-write"],
        @"age": @32
    };
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    self.client.filterExpression = filterExpression;
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertEqualObjects(self.client.filterExpression, filterExpression);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channel withMetadata:messageMetadata
                  completion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndNotReceiveMessageWhenFilterExpressionIsSetToExactMatch {
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSDictionary *messageMetadata = @{ @"uuid": self.client.currentConfiguration.userID };
    NSString *channel = [self channelWithName:@"test-channel1"];
    NSString *filterExpression = @"uuid == 'bob'";
    
    
    self.client.filterExpression = filterExpression;
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertEqualObjects(self.client.filterExpression, filterExpression);
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channel withMetadata:messageMetadata
                  completion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndNotReceiveMessageWhenFilterExpressionIsSetToCompound {
    NSString *filterExpression = [NSString stringWithFormat:@"uuid == '%@' && !admin && age >= 32",
                                  self.client.currentConfiguration.userID];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSDictionary *messageMetadata = @{
        @"uuid": self.client.currentConfiguration.userID,
        @"admin": @YES,
        @"age": @33
    };
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    self.client.filterExpression = filterExpression;
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    XCTAssertEqualObjects(self.client.filterExpression, filterExpression);
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channel withMetadata:messageMetadata
                  completion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
}

- (void)testItShouldSubscribeToSingleChannelAndReceiveFilteredMessagesWhenFilterExpressionSetAfterSubscribe {
    NSString *filterExpression = [NSString stringWithFormat:@"uuid == '%@' && !admin && age >= 32",
                                  self.client.currentConfiguration.userID];
    NSDictionary *publishedMessage = @{ @"test-message": [self randomizedValuesWithValues:@[@"message"]] };
    NSDictionary *messageMetadata = @{
        @"uuid": self.client.currentConfiguration.userID,
        @"admin": @YES,
        @"age": @33
    };
    NSString *channel = [self channelWithName:@"test-channel1"];
    
    
    [self subscribeClient:self.client toChannels:@[channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channel withMetadata:messageMetadata
                  completion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
    
    
    self.client.filterExpression = filterExpression;
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *remove) {
            
            if ([message.data.publisher isEqualToString:self.client.currentConfiguration.userID]) {
                *remove = YES;
                
                handler();
            }
        }];
        
        [self.client publish:publishedMessage toChannel:channel withMetadata:messageMetadata
                  completion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
}

#pragma mark -


@end

#pragma clang diagnostic pop
