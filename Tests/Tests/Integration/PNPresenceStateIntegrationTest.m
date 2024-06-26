/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub+CorePrivate.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNPresenceStateIntegrationTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNPresenceStateIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
}


#pragma mark - Tests :: Set state for channel

- (void)testItShouldSetPresenceStateForChannelAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *channel = [self channelWithName:@"test-channel1"];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]]
    };
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client setState:state forUUID:uuid onChannel:channel
               withCompletion:^(PNClientStateUpdateStatus *status) {
            
            NSDictionary *clientState = status.data.state;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(clientState);
            XCTAssertEqualObjects(clientState, state);
            XCTAssertEqual(status.operation, PNSetStateOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
}

- (void)testItShouldSetPresenceStateForChannelAndNotCrashWhenCompletionBlockIsNil {
    NSString *channel = [self channelWithName:@"test-channel1"];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]]
    };
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [self.client setState:state forUUID:uuid onChannel:channel withCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
}

- (void)testItShouldSetPresenceStateForChannelAndTriggerUpdateEventToTargetChannel {
    NSString *channel = [self channelWithName:@"test-channel1"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"serhii"];
    NSDictionary *state = @{
        @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]]
    };
    NSDictionary *updatedState = @{
        @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-updated-random-value"]]
    };
    
    
    [self setState:state onChannel:channel usingClient:client1];
    [self subscribeClient:client2 toChannels:@[channel] withPresence:YES];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addPresenceHandlerForClient:client2
                                withBlock:^(PubNub *client, PNPresenceEventResult *event, BOOL *remove) {
            
            if ([event.data.presenceEvent isEqualToString:@"state-change"]) {
                XCTAssertEqualObjects(event.data.presence.uuid, client1.currentConfiguration.userID);
                XCTAssertEqualObjects(event.data.presence.state, updatedState);
                XCTAssertNotNil(event.data.presence.timetoken);
                *remove = YES;

                handler();
            }
        }];
        
        [client1 setState:updatedState forUUID:client1.currentConfiguration.userID onChannel:channel
           withCompletion:^(PNClientStateUpdateStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldNotSetPresenceStateForChannelAndReceiveBadRequestStatusWhenChannelIsNil {
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]]
    };
    __block BOOL retried = NO;
    NSString *channel = nil;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client setState:state forUUID:uuid onChannel:channel
               withCompletion:^(PNClientStateUpdateStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNSetStateOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}

- (void)testItShouldNotSetPresenceStateForChannelAndReceiveBadRequestStatusWhenUUIDIsNil {
    NSString *channel = [self channelWithName:@"test-channel1"];
    NSDictionary *state = @{
        @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]]
    };
    __block BOOL retried = NO;
    NSString *uuid = nil;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client setState:state forUUID:uuid onChannel:channel
               withCompletion:^(PNClientStateUpdateStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNSetStateOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based set state for channel

- (void)testItShouldSetPresenceStateForChannelUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"users-state": [self randomizedValuesWithValues:@[@"users-random-value"]]
    };
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.state().set()
            .state(state)
            .uuid(uuid)
            .channels(channels)
            .performWithCompletion(^(PNClientStateUpdateStatus *status) {
                NSDictionary *clientState = status.data.state;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(clientState);
                XCTAssertEqualObjects(clientState, state);
                XCTAssertEqual(status.operation, PNSetStateOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
                
            });
    }];
}


#pragma mark - Tests :: Set state for channel group

- (void)testItShouldSetPresenceStateForChannelGroupAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"user-state": [self randomizedValuesWithValues:@[@"users-random-value"]]
    };
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client setState:state forUUID:uuid onChannelGroup:channelGroup
               withCompletion:^(PNClientStateUpdateStatus *status) {
            
            NSDictionary *clientState = status.data.state;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(clientState);
            XCTAssertEqualObjects(clientState, state);
            XCTAssertEqual(status.operation, PNSetStateOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldSetPresenceStateForChannelGroupAndNotCrashWhenCompletionBlockIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"user-state": [self randomizedValuesWithValues:@[@"users-random-value"]]
    };
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [self.client setState:state forUUID:uuid onChannelGroup:channelGroup withCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
}

- (void)testItShouldNotSetPresenceStateForChannelGroupAndReceiveBadRequestStatusWhenChannelGroupIsNil {
    NSString *uuid = self.client.currentConfiguration.userID;
    NSString *channelGroup = nil;
    NSDictionary *state = @{
        @"user-state": [self randomizedValuesWithValues:@[@"users-random-value"]]
    };
    __block BOOL retried = NO;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client setState:state forUUID:uuid onChannelGroup:channelGroup
               withCompletion:^(PNClientStateUpdateStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNSetStateOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}

- (void)testItShouldNotSetPresenceStateForChannelGroupAndReceiveBadRequestStatusWhenUUIDIsNil {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSDictionary *state = @{
        @"user-state": [self randomizedValuesWithValues:@[@"users-random-value"]]
    };
    __block BOOL retried = NO;
    NSString *uuid = nil;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client setState:state forUUID:uuid onChannelGroup:channelGroup
               withCompletion:^(PNClientStateUpdateStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNSetStateOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based set state for channel

- (void)testItShouldSetPresenceStateForChannelGroupUsingBuilderPatternInterface {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels1 = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSArray<NSString *> *channels2 = [self channelsWithNames:@[@"test-channel3", @"test-channel4"]];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"users-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]]
    };
    
    
    [self addChannels:channels1 toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:channels2 toChannelGroup:channelGroups.lastObject usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.state().set()
            .state(state)
            .uuid(uuid)
            .channelGroups(channelGroups)
            .performWithCompletion(^(PNClientStateUpdateStatus *status) {
                NSDictionary *clientState = status.data.state;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(clientState);
                XCTAssertEqualObjects(clientState, state);
                XCTAssertEqual(status.operation, PNSetStateOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
                
            });
    }];
    
    [self removeChannelGroup:channelGroups.firstObject usingClient:nil];
    [self removeChannelGroup:channelGroups.lastObject usingClient:nil];
}


#pragma mark - Tests :: Fetch state for channel

- (void)testItShouldFetchPresenceStateForChannelAndReceiveResultWithExpectedOperation {
    NSString *channel = [self channelWithName:@"test-channel1"];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]]
    };
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client setState:state forUUID:uuid onChannel:channel
               withCompletion:^(PNClientStateUpdateStatus *status) {
            
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client stateForUUID:uuid onChannel:channel
                   withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {

            NSDictionary *clientState = result.data.state;
            XCTAssertNotNil(clientState);
            XCTAssertEqualObjects(clientState, state);
            XCTAssertEqual(result.operation, PNStateForChannelOperation);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotFetchPresenceStateForChannelAndReceiveBadRequestStatusWhenChannelIsNil {
    NSString *uuid = self.client.currentConfiguration.userID;
    __block BOOL retried = NO;
    NSString *channel = nil;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client stateForUUID:uuid onChannel:channel
                   withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}

- (void)testItShouldNotFetchPresenceStateForChannelAndReceiveBadRequestStatusWhenUUIDIsNil {
    NSString *channel = [self channelWithName:@"test-channel1"];
    __block BOOL retried = NO;
    NSString *uuid = nil;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client stateForUUID:uuid onChannel:channel
                   withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNStateForChannelOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based fetch state for channel

- (void)testItShouldFetchPresenceStateForChannelUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"users-state": [self randomizedValuesWithValues:@[@"users-random-value"]]
    };
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.state().set()
            .state(state)
            .uuid(uuid)
            .channels(channels)
            .performWithCompletion(^(PNClientStateUpdateStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.state().audit()
            .uuid(uuid)
            .channels(channels)
            .performWithCompletion(^(PNClientStateGetResult *result, PNErrorStatus *status) {
                NSDictionary *fetchedChannels = result.data.channels;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqualObjects(fetchedChannels[channels.firstObject], state);
                XCTAssertEqualObjects(fetchedChannels[channels.firstObject],
                                      fetchedChannels[channels.lastObject]);
                XCTAssertEqual(result.operation, PNGetStateOperation);

                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch state for channel group

- (void)testItShouldFetchPresenceStateForChannelGroupAndReceiveResultWithExpectedOperation {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"user-state": [self randomizedValuesWithValues:@[@"users-random-value"]]
    };
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client setState:state forUUID:uuid onChannelGroup:channelGroup
               withCompletion:^(PNClientStateUpdateStatus *status) {
            
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client stateForUUID:uuid onChannelGroup:channelGroup
                   withCompletion:^(PNChannelGroupClientStateResult *result, PNErrorStatus *status) {
            
            NSDictionary *fetchedChannels = result.data.channels;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(fetchedChannels);
            XCTAssertEqualObjects(fetchedChannels[channels.firstObject], state);
            XCTAssertEqualObjects(fetchedChannels[channels.firstObject],
                                  fetchedChannels[channels.lastObject]);
            XCTAssertEqual(result.operation, PNStateForChannelGroupOperation);

            handler();
        }];
    }];
    
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldNotFetchPresenceStateForChannelGroupAndReceiveBadRequestStatusWhenChannelGroupIsNil {
    NSString *uuid = self.client.currentConfiguration.userID;
    NSString *channelGroup = nil;
    __block BOOL retried = NO;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client stateForUUID:uuid onChannelGroup:channelGroup
                   withCompletion:^(PNChannelGroupClientStateResult *result, PNErrorStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}

- (void)testItShouldNotFetchPresenceStateForChannelGroupAndReceiveBadRequestStatusWhenUUIDIsNil {
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    __block BOOL retried = NO;
    NSString *uuid = nil;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client stateForUUID:uuid onChannelGroup:channelGroup
                   withCompletion:^(PNChannelGroupClientStateResult *result, PNErrorStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNStateForChannelGroupOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based fetch state for channel

- (void)testItShouldFetchPresenceStateForChannelGroupUsingBuilderPatternInterface {
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<NSString *> *channels1 = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSArray<NSString *> *channels2 = [self channelsWithNames:@[@"test-channel3", @"test-channel4"]];
    NSString *uuid = self.client.currentConfiguration.userID;
    NSDictionary *state = @{
        @"users-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]]
    };
    
    
    [self addChannels:channels1 toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:channels2 toChannelGroup:channelGroups.lastObject usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.state().set()
            .state(state)
            .uuid(uuid)
            .channelGroups(channelGroups)
            .performWithCompletion(^(PNClientStateUpdateStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.state().audit()
            .uuid(uuid)
            .channelGroups(channelGroups)
            .performWithCompletion(^(PNClientStateGetResult *result, PNErrorStatus *status) {
                NSDictionary *fetchedChannels = result.data.channels;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqualObjects(fetchedChannels[channels1.firstObject], state);
                XCTAssertEqualObjects(fetchedChannels[channels2.firstObject], state);
                XCTAssertEqualObjects(fetchedChannels[channels1.firstObject],
                                      fetchedChannels[channels2.lastObject]);
                XCTAssertEqual(result.operation, PNGetStateOperation);

                handler();
            });
    }];
    
    [self removeChannelGroup:channelGroups.firstObject usingClient:nil];
    [self removeChannelGroup:channelGroups.lastObject usingClient:nil];
}

#pragma mark -

#pragma clang diagnostic pop

@end
