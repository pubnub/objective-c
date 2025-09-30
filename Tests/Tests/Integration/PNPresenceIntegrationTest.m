/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import "PubNub+CorePrivate.h"
#import "NSString+PNTest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNPresenceIntegrationTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNPresenceIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
    configuration.presenceHeartbeatValue = 20;
    configuration.presenceHeartbeatInterval = 0;
    
    if ([self.name pnt_includesAnyString:@[@"SetConnected", @"SetNotConnected"]]) {
        configuration.managePresenceListManually = ![self.name pnt_includesString:@"ManualPresenceManagementIsDisabled"];
    }
    
    return configuration;
}

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
}


#pragma mark - Tests :: Global here now

- (void)testItShouldFetchGlobalHereNowAndReceiveResultWithExpectedOperation {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowWithCompletion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
            NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannels);
            XCTAssertEqual(fetchedChannels.count, channels.count);
            XCTAssertEqual(result.data.totalChannels.unsignedIntegerValue, channels.count);
            XCTAssertEqual(result.data.totalOccupancy.unsignedIntegerValue, clients.count);
            XCTAssertEqual(result.operation, PNHereNowGlobalOperation);
            
            for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;

                XCTAssertEqual(((NSNumber *)channelInformation[@"occupancy"]).unsignedIntegerValue, 1);
                XCTAssertEqualObjects(channelInformation[@"uuids"], @[@{ @"uuid": clientUUID }]);
            }
            
            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldFetchGlobalHereNowWithParticipantsUUIDWhenUUIDVerbosityIsSet {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowWithVerbosity:PNHereNowUUID
                               completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
            
            NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannels);
            XCTAssertEqual(fetchedChannels.count, channels.count);
            XCTAssertEqual(result.data.totalChannels.unsignedIntegerValue, channels.count);
            XCTAssertEqual(result.data.totalOccupancy.unsignedIntegerValue, clients.count);

            for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;

                XCTAssertEqual(((NSNumber *)channelInformation[@"occupancy"]).unsignedIntegerValue, 1);
                XCTAssertEqualObjects(channelInformation[@"uuids"], @[clientUUID]);
            }

            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldFetchGlobalHereNowWithParticipantsStateWhenStateVerbosityIsSet {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSArray<NSDictionary *> *states = @[
        @{ @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]] },
        @{ @"channel2-state": [self randomizedValuesWithValues:@[@"channel-2-random-value"]] },
        @{ @"channel3-state": [self randomizedValuesWithValues:@[@"channel-3-random-value"]] },
    ];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self setState:states[clientIdx] onChannel:channels[clientIdx] usingClient:clients[clientIdx]];
    }
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowWithVerbosity:PNHereNowState
                               completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
            NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannels);

            for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;
                NSDictionary *channelParticipant = channelInformation[@"uuids"][0];
                
                XCTAssertEqualObjects(channelParticipant[@"uuid"], clientUUID);
                XCTAssertEqualObjects(channelParticipant[@"state"], states[channelIdx]);
            }

            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchGlobalHereWithParticipantsOccupancyWhenOccupancyVerbosityIsSet.json' should
 *  be modified after cassette recording. Find first place where presence fetch API usage and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change `Content-Type` to `text/html`.
 */
- (void)testItShouldFetchGlobalHereNowWithParticipantsOccupancyWhenOccupancyVerbosityIsSet {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    __block BOOL retried = NO;
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNHereNowRequest *request = [PNHereNowRequest requestGlobal];
        request.verbosityLevel = PNHereNowOccupancy;
        __block __weak PNHereNowCompletionBlock weakBlock;
        __block PNHereNowCompletionBlock block;
        
        block = ^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
            __strong PNHereNowCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            if (!retried) {
                XCTAssertTrue(status.error);
                XCTAssertEqual(status.operation, PNHereNowGlobalOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);

                retried = YES;
                [self.client hereNowWithRequest:request completion:strongBlock];
            } else {
                NSDictionary<NSString *, PNPresenceChannelData *> *fetchedChannels = result.data.channels;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannels);

                for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                    PNPresenceChannelData *channelInformation = fetchedChannels[channels[channelIdx]];
                    
                    XCTAssertNil(channelInformation.uuids);
                    XCTAssertEqual(((NSNumber *)channelInformation.occupancy).unsignedIntegerValue, 1);
                }

                handler();
            }
        };
        
        weakBlock = block;
        [self.client hereNowWithRequest:request completion:block];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}


#pragma mark - Tests :: Builder pattern-based global here now

- (void)testItShouldFetchGlobalHereNowUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().hereNow()
            .performWithCompletion(^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
                NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqual(fetchedChannels.count, channels.count);
                XCTAssertEqual(result.data.totalChannels.unsignedIntegerValue, channels.count);
                XCTAssertEqual(result.data.totalOccupancy.unsignedIntegerValue, clients.count);
                XCTAssertEqual(result.operation, PNHereNowGlobalOperation);
                
                for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                    NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                    NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;

                    XCTAssertEqual(((NSNumber *)channelInformation[@"occupancy"]).unsignedIntegerValue, 1);
                    XCTAssertEqualObjects(channelInformation[@"uuids"], @[@{ @"uuid": clientUUID }]);
                }
                
                handler();
            });
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}


#pragma mark - Tests :: Channel here now

- (void)testItShouldFetchChannelHereNowAndReceiveResultWithExpectedOperation {
    NSString *channel = [self channelsWithNames:@[@"test-channel1"]].lastObject;
    NSArray<PubNub *> *clients = [self createPubNubClients:3];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowForChannel:channel
                        withCompletion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
            
            NSArray<NSDictionary *> *uuids = result.data.uuids;
            XCTAssertNil(status);
            XCTAssertNotNil(uuids);
            XCTAssertEqual(uuids.count, clients.count);
            XCTAssertEqual(result.data.occupancy.unsignedIntegerValue, clients.count);
            XCTAssertEqual(result.operation, PNHereNowForChannelOperation);
            
            for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
                PubNub *client = clients[clientIdx];
                
                XCTAssertTrue([uuids containsObject:@{ @"uuid": client.currentConfiguration.userID }]);
            }
            
            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldFetchChannelHereNowWithParticipantsUUIDWhenUUIDVerbosityIsSet {
    NSString *channel = [self channelsWithNames:@[@"test-channel1"]].lastObject;
    NSArray<PubNub *> *clients = [self createPubNubClients:3];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowForChannel:channel withVerbosity:PNHereNowUUID
                            completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
            
            NSArray<NSString *> *uuids = result.data.uuids;
            XCTAssertNil(status);
            XCTAssertNotNil(uuids);
            XCTAssertEqual(uuids.count, clients.count);
            XCTAssertEqual(result.data.occupancy.unsignedIntegerValue, clients.count);
            
            for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
                PubNub *client = clients[clientIdx];
                
                XCTAssertTrue([uuids containsObject:client.currentConfiguration.userID]);
            }

            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldFetchChannelHereNowWithParticipantsStateWhenStateVerbosityIsSet {
    NSString *channel = [self channelsWithNames:@[@"test-channel1"]].lastObject;
    NSDictionary *state = @{ @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]] };
    NSArray<PubNub *> *clients = [self createPubNubClients:3];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self setState:state onChannel:channel usingClient:clients[clientIdx]];
    }
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowForChannel:channel withVerbosity:PNHereNowState
                               completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
            
            NSArray<NSDictionary *> *uuids = result.data.uuids;
            XCTAssertNil(status);
            XCTAssertNotNil(uuids);
            
            for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
                NSString *clientUUID = clients[clientIdx].currentConfiguration.userID;
                NSDictionary *userInformation = nil;
                
                for (NSDictionary *information in uuids) {
                    if ([information[@"uuid"] isEqualToString:clientUUID]) {
                        userInformation = information;
                        break;
                    }
                }
                
                XCTAssertNotNil(userInformation);
                XCTAssertEqualObjects(userInformation[@"state"], state);
            }

            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldFetchChannelHereNowWithParticipantsOccupancyWhenOccupancyVerbosityIsSet {
    NSString *channel = [self channelsWithNames:@[@"test-channel1"]].lastObject;
    NSArray<PubNub *> *clients = [self createPubNubClients:3];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowForChannel:channel
                         withVerbosity:PNHereNowOccupancy
                            completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {

            NSNumber *fetchedOccupancy = result.data.occupancy;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedOccupancy);
            XCTAssertEqual(fetchedOccupancy.unsignedIntegerValue, clients.count);

            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldFetchChannelHereNowWithNextSetWhenParticipantsMoreOrEqualToTheLimit {
    NSString *channel = [self channelsWithNames:@[@"test-channel1"]].lastObject;
    NSUInteger expectedNumberOfParticipants = 3;
    NSArray<PubNub *> *clients = [self createPubNubClients:expectedNumberOfParticipants];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[channel]];
        request.limit = expectedNumberOfParticipants;
        
        [self.client hereNowWithRequest:request completion:^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
            PNTransportRequest *transportRequest = [clients[0].serviceNetwork transportRequestFromTransportRequest:request.request];
            NSNumber *fetchedOccupancy = result.data.totalOccupancy;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedOccupancy);
            XCTAssertEqual(fetchedOccupancy.unsignedIntegerValue, clients.count);
            XCTAssertEqualObjects(transportRequest.query[@"limit"], @(request.limit).stringValue);
            
            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldFetchChannelHereNowWithoutNextSetWhenParticipantsLessThanTheLimit {
    NSString *channel = [self channelsWithNames:@[@"test-channel1"]].lastObject;
    NSArray<PubNub *> *clients = [self createPubNubClients:3];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[channel]];
        request.limit = 2000;
        
        [self.client hereNowWithRequest:request completion:^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
            PNTransportRequest *transportRequest = [clients[0].serviceNetwork transportRequestFromTransportRequest:request.request];
            NSNumber *fetchedOccupancy = result.data.totalOccupancy;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedOccupancy);
            XCTAssertEqual(fetchedOccupancy.unsignedIntegerValue, clients.count);
            XCTAssertEqualObjects(transportRequest.query[@"limit"], @"1000");
            
            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldNotFetchChannelsHereNowAndReceiveBadRequestStatusWhenChannelsIsEmpty {
    __block BOOL retried = NO;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[]];
        __block __weak PNHereNowCompletionBlock weakBlock;
        __block PNHereNowCompletionBlock block;
        
        block = ^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
            __strong PNHereNowCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNHereNowForChannelOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                [self.client hereNowWithRequest:request completion:strongBlock];
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        [self.client hereNowWithRequest:request completion:block];
    }];
}


#pragma mark - Tests :: Builder pattern-based channel here now

- (void)testItShouldFetchChannelHereNowUsingBuilderPatternInterface {
    NSString *channel = [self channelsWithNames:@[@"test-channel1"]].lastObject;
    NSArray<PubNub *> *clients = [self createPubNubClients:3];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    /**
     void (^)(PNPresenceChannelHereNowResult *__strong, PNErrorStatus *__strong)' to parameter of type 'PNHereNowCompletionBlock  _Nonnull __strong' (aka 'void (^__strong)(PNPresenceHereNowResult * _Nullable __strong, PNErrorStatus * _Nullable __strong)
     */

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().hereNow()
            .channel(channel)
            .verbosity(PNHereNowOccupancy)
            .performWithCompletion(^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                NSNumber *fetchedOccupancy = result.data.occupancy;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedOccupancy);
                XCTAssertEqual(fetchedOccupancy.unsignedIntegerValue, clients.count);
                XCTAssertEqual(result.operation, PNHereNowForChannelOperation);
                
                handler();
        });
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channel] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldFetchChannelsListHereNowUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().hereNow()
            .channels(channels)
            .performWithCompletion(^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqual(fetchedChannels.count, channels.count);
                XCTAssertEqual(result.data.totalOccupancy.unsignedIntegerValue, clients.count);
                XCTAssertEqual(result.operation, PNHereNowForChannelOperation);

                for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                    NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                    NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;

                    XCTAssertEqual(((NSNumber *)channelInformation[@"occupancy"]).unsignedIntegerValue, 1);
                    XCTAssertEqualObjects(channelInformation[@"uuids"], @[@{ @"uuid": clientUUID }]);
                }
                
                handler();
            });
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}


#pragma mark - Tests :: Channel group here now

- (void)testItShouldFetchChannelGroupHereNowAndReceiveResultWithExpectedOperation {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowForChannelGroup:channelGroup
                             withCompletion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
            
            NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannels);
            XCTAssertEqual(fetchedChannels.count, channels.count);
            XCTAssertEqual(result.data.totalChannels.unsignedIntegerValue, channels.count);
            XCTAssertEqual(result.data.totalOccupancy.unsignedIntegerValue, clients.count);
            XCTAssertEqual(result.operation, PNHereNowForChannelGroupOperation);

            for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;

                XCTAssertEqual(((NSNumber *)channelInformation[@"occupancy"]).unsignedIntegerValue, 1);
                XCTAssertEqualObjects(channelInformation[@"uuids"], @[@{ @"uuid": clientUUID }]);
            }

            handler();
            
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:channels withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldFetchChannelGroupHereNowWithParticipantsUUIDWhenUUIDVerbosityIsSet {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowForChannelGroup:channelGroup
                              withVerbosity:PNHereNowUUID
                               completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
            
            NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannels);
            XCTAssertEqual(fetchedChannels.count, channels.count);
            XCTAssertEqual(result.data.totalChannels.unsignedIntegerValue, channels.count);
            XCTAssertEqual(result.data.totalOccupancy.unsignedIntegerValue, clients.count);

            for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;

                XCTAssertEqual(((NSNumber *)channelInformation[@"occupancy"]).unsignedIntegerValue, 1);
                XCTAssertEqualObjects(channelInformation[@"uuids"], @[clientUUID]);
            }

            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:channels withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldFetchChannelGroupHereNowWithParticipantsStateWhenStateVerbosityIsSet {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSArray<NSDictionary *> *states = @[
        @{ @"channel1-state": [self randomizedValuesWithValues:@[@"channel-1-random-value"]] },
        @{ @"channel2-state": [self randomizedValuesWithValues:@[@"channel-2-random-value"]] },
        @{ @"channel3-state": [self randomizedValuesWithValues:@[@"channel-3-random-value"]] },
    ];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self setState:states[clientIdx] onChannel:channels[clientIdx] usingClient:clients[clientIdx]];
    }
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowForChannelGroup:channelGroup
                              withVerbosity:PNHereNowState
                               completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
            
            NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannels);

            for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;
                NSDictionary *channelParticipant = channelInformation[@"uuids"][0];
                
                XCTAssertEqualObjects(channelParticipant[@"uuid"], clientUUID);
                XCTAssertEqualObjects(channelParticipant[@"state"], states[channelIdx]);
            }

            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:channels withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldFetchChannelGroupHereNowWithParticipantsOccupancyWhenOccupancyVerbosityIsSet {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client hereNowForChannelGroup:channelGroup
                              withVerbosity:PNHereNowOccupancy
                               completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {

            NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannels);

            for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                
                XCTAssertNil(channelInformation[@"uuids"]);
                XCTAssertEqual(((NSNumber *)channelInformation[@"occupancy"]).unsignedIntegerValue, 1);
            }

            handler();
        }];
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:channels withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldNotFetchChannelGroupsHereNowAndReceiveBadRequestStatusWhenChannelGroupsIsEmpty {
    __block BOOL retried = NO;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNHereNowRequest *request = [PNHereNowRequest requestForChannelGroups:@[]];
        __block __weak PNHereNowCompletionBlock weakBlock;
        __block PNHereNowCompletionBlock block;
        
        block = ^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
            __strong PNHereNowCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNHereNowForChannelGroupOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                [self.client hereNowWithRequest:request completion:strongBlock];
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        [self.client hereNowWithRequest:request completion:block];
    }];
}


#pragma mark - Tests :: Builder pattern-based channel group here now

- (void)testItShouldFetchChannelGroupHereNowUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().hereNow()
            .channelGroup(channelGroup)
            .performWithCompletion(^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqual(fetchedChannels.count, channels.count);
                XCTAssertEqual(result.data.totalChannels.unsignedIntegerValue, channels.count);
                XCTAssertEqual(result.data.totalOccupancy.unsignedIntegerValue, clients.count);
                XCTAssertEqual(result.operation, PNHereNowForChannelGroupOperation);
                
                for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                    NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                    NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;

                    XCTAssertEqual(((NSNumber *)channelInformation[@"occupancy"]).unsignedIntegerValue, 1);
                    XCTAssertEqualObjects(channelInformation[@"uuids"], @[@{ @"uuid": clientUUID }]);
                }
                
                handler();
            });
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:channels withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldFetchChannelGroupsListHereNowUsingBuilderPatternInterface {
    NSArray<NSString *> *channels1 = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSArray<NSString *> *channels2 = [self channelsWithNames:@[@"test-channel4", @"test-channel5", @"test-channel6"]];
    NSArray<NSString *> *channels = [channels1 arrayByAddingObjectsFromArray:channels2];
    NSArray<NSString *> *channelGroups = [self channelGroupsWithNames:@[@"test-channel-group1", @"test-channel-group2"]];
    NSArray<PubNub *> *clients = [self createPubNubClients:channels.count];
    
    
    [self addChannels:channels1 toChannelGroup:channelGroups.firstObject usingClient:nil];
    [self addChannels:channels2 toChannelGroup:channelGroups.lastObject usingClient:nil];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self subscribeClient:clients[clientIdx] toChannels:@[channels[clientIdx]] withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().hereNow()
            .channelGroups(channelGroups)
            .performWithCompletion(^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqual(fetchedChannels.count, channels.count);
                XCTAssertEqual(result.data.totalChannels.unsignedIntegerValue, channels.count);
                XCTAssertEqual(result.data.totalOccupancy.unsignedIntegerValue, clients.count);
                XCTAssertEqual(result.operation, PNHereNowForChannelGroupOperation);

                for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                    NSDictionary *channelInformation = fetchedChannels[channels[channelIdx]];
                    NSString *clientUUID = clients[channelIdx].currentConfiguration.userID;

                    XCTAssertEqual(((NSNumber *)channelInformation[@"occupancy"]).unsignedIntegerValue, 1);
                    XCTAssertEqualObjects(channelInformation[@"uuids"], @[@{ @"uuid": clientUUID }]);
                }
                
                handler();
            });
    }];
    
    for (NSUInteger clientIdx = 0; clientIdx < clients.count; clientIdx++) {
        [self unsubscribeClient:clients[clientIdx] fromChannels:channels withPresence:NO];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    [self removeChannelGroup:channelGroups.firstObject usingClient:nil];
    [self removeChannelGroup:channelGroups.lastObject usingClient:nil];
}


#pragma mark - Tests :: Where now

- (void)testItShouldFetchWhereNowAndReceiveResultWithExpectedOperation {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    
    
    [self subscribeClient:self.client toChannels:channels withPresence:NO];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client whereNowUUID:self.client.currentConfiguration.userID
                   withCompletion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
            
            NSArray<NSString *> *fetchedChannels = result.data.channels;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannels);
            XCTAssertEqual(result.operation, PNWhereNowOperation);

            for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                XCTAssertTrue([fetchedChannels containsObject:channels[channelIdx]]);
            }

            handler();
        }];
    }];

    [self unsubscribeClient:self.client fromChannels:channels withPresence:NO];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldNotFetchWhereNowAndReceiveBadRequestStatusWhenUUIDIsNil {
    __block BOOL retried = NO;
    NSString *uuid = nil;
        
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNWhereNowRequest *request = [PNWhereNowRequest requestForUserId:uuid];
        __block __weak PNWhereNowCompletionBlock weakBlock;
        __block PNWhereNowCompletionBlock block;
        
        block = ^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
            __strong PNWhereNowCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNWhereNowOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                [self.client whereNowWithRequest:request completion:strongBlock];
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        [self.client whereNowWithRequest:request completion:block];
    }];
}


#pragma mark - Tests :: Builder pattern-based where now

- (void)testItShouldFetchWhereNowUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    
    
    [self subscribeClient:self.client toChannels:channels withPresence:NO];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().whereNow()
            .uuid(self.client.currentConfiguration.userID)
            .performWithCompletion(^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
                NSArray<NSString *> *fetchedChannels = result.data.channels;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedChannels);
                XCTAssertEqual(result.operation, PNWhereNowOperation);
                XCTAssertEqual(fetchedChannels.count, channels.count);
                
                handler();
            });
    }];

    [self unsubscribeClient:self.client fromChannels:channels withPresence:NO];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}


#pragma mark - Tests :: Builder pattern-based connected channels

- (void)testItShouldSetConnectedStateForChannelsAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(YES)
            .channels(channels)
            .performWithCompletion(^(PNStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNHeartbeatOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().whereNow()
            .uuid(self.client.currentConfiguration.userID)
            .performWithCompletion(^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.channels.count, channels.count);
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(NO)
            .channels(channels)
            .performWithCompletion(^(PNStatus *status) {
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldSetConnectedStateForChannelsWithState {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSDictionary *states = @{
        channels[0]: @{ @"test-channel1": [self randomizedValuesWithValues:@[@"channel-1-random-value"]] },
        channels[1]: @{ @"test-channel2": [self randomizedValuesWithValues:@[@"channel-2-random-value"]] },
        channels[2]: @{ @"test-channel3": [self randomizedValuesWithValues:@[@"channel-3-random-value"]] }
    };
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(YES)
            .channels(channels)
            .state(states)
            .performWithCompletion(^(PNStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().hereNow().channel(channels.firstObject).verbosity(PNHereNowState)
            .performWithCompletion(^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                NSArray<NSDictionary *> *uuids = result.data.uuids;
                NSDictionary *fetchedState = uuids.firstObject[@"state"];
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedState);
                XCTAssertEqualObjects(fetchedState, states[channels.firstObject]);
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(NO)
            .channels(channels)
            .performWithCompletion(^(PNStatus *status) {
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
}

- (void)testItShouldNotSetConnectedStateForChannelsAndReceiveBadRequestStatusWhenChannelsIsNil {
    NSArray<NSString *> *channels = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        __block __weak void (^weakBlock)(PNStatus *status);
        __block void (^block)(PNStatus *status);
        
        block = ^(PNStatus *status) {
            __strong void (^strongBlock)(PNStatus *status) = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNHeartbeatOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                self.client.presence().connected(YES).channels(channels).performWithCompletion(strongBlock);
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        self.client.presence().connected(YES).channels(channels).performWithCompletion(block);
    }];
}

- (void)testItShouldNotSetConnectedStateForChannelsAndReceiveBadRequestStatusWhenManualPresenceManagementIsDisabled {
    NSArray<NSString *> *channels = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        __block __weak void (^weakBlock)(PNStatus *status);
        __block void (^block)(PNStatus *status);
        
        block = ^(PNStatus *status) {
            __strong void (^strongBlock)(PNStatus *status) = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNHeartbeatOperation);
            XCTAssertEqual(status.category, PNCancelledCategory);
            
            if (!retried) {
                retried = YES;
                self.client.presence().connected(YES).channels(channels).performWithCompletion(strongBlock);
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        self.client.presence().connected(YES).channels(channels).performWithCompletion(block);
    }];
}

- (void)testItShouldSetNotConnectedStateForChannelsAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(YES)
            .channels(channels)
            .performWithCompletion(^(PNStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(NO)
            .channels(channels)
            .performWithCompletion(^(PNStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNUnsubscribeOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().whereNow()
            .uuid(self.client.currentConfiguration.userID)
            .performWithCompletion(^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.channels.count, 0);
                
                handler();
            });
    }];
}

- (void)testItShouldNotSetNotConnectedStateForChannelsAndReceiveBadRequestStatusWhenChannelsIsNil {
    NSArray<NSString *> *channels = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        __block __weak void (^weakBlock)(PNStatus *status);
        __block void (^block)(PNStatus *status);
        
        block = ^(PNStatus *status) {
            __strong void (^strongBlock)(PNStatus *status) = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNUnsubscribeOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                self.client.presence().connected(NO).channels(channels).performWithCompletion(strongBlock);
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        self.client.presence().connected(NO).channels(channels).performWithCompletion(block);
    }];
}


#pragma mark - Tests :: Builder pattern-based connected channel groups

- (void)testItShouldSetConnectedStateForChannelGroupsAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(YES)
            .channelGroups(@[channelGroup])
            .performWithCompletion(^(PNStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNHeartbeatOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().hereNow()
            .channelGroup(channelGroup)
            .performWithCompletion(^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.channels.count, channels.count);
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(NO)
            .channelGroups(@[channelGroup])
            .performWithCompletion(^(PNStatus *status) {
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)disabled_testItShouldSetConnectedStateForChannelGroupsWithState {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    NSDictionary *states = @{
        channelGroup: @{ @"channel-group": [self randomizedValuesWithValues:@[@"channel-group-random-value"]] }
    };
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(YES)
            .channelGroups(@[channelGroup])
            .state(states)
            .performWithCompletion(^(PNStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().hereNow().channelGroup(channelGroup).verbosity(PNHereNowState)
            .performWithCompletion(^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                NSDictionary<NSString *, NSDictionary *> *fetchedChannels = result.data.channels;
                NSArray<NSDictionary *> *uuids = fetchedChannels[channels.firstObject][@"uuids"];
                NSDictionary *fetchedState = uuids.firstObject[self.client.currentConfiguration.userID];
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedState);
                XCTAssertEqualObjects(fetchedState, states[channelGroup]);
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(NO)
            .channelGroups(@[channelGroup])
            .performWithCompletion(^(PNStatus *status) {
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldNotSetConnectedStateForChannelGroupsAndReceiveBadRequestStatusWhenChannelGroupsIsNil {
    NSArray<NSString *> *channelGroups = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        __block __weak void (^weakBlock)(PNStatus *status);
        __block void (^block)(PNStatus *status);
        
        block = ^(PNStatus *status) {
            __strong void (^strongBlock)(PNStatus *status) = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNHeartbeatOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                self.client.presence().connected(YES).channelGroups(channelGroups).performWithCompletion(strongBlock);
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        self.client.presence().connected(YES).channelGroups(channelGroups).performWithCompletion(block);
    }];
}

- (void)testItShouldNotSetConnectedStateForChannelGroupsAndReceiveBadRequestStatusManualPresenceManagementIsDisabled {
    NSArray<NSString *> *channelGroups = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        __block __weak void (^weakBlock)(PNStatus *status);
        __block void (^block)(PNStatus *status);
        
        block = ^(PNStatus *status) {
            __strong void (^strongBlock)(PNStatus *status) = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNHeartbeatOperation);
            XCTAssertEqual(status.category, PNCancelledCategory);
            
            if (!retried) {
                retried = YES;
                self.client.presence().connected(YES).channelGroups(channelGroups).performWithCompletion(strongBlock);
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        self.client.presence().connected(YES).channelGroups(channelGroups).performWithCompletion(block);
    }];
}

- (void)testItShouldSetNotConnectedStateForChannelGroupsAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2", @"test-channel3"]];
    NSString *channelGroup = [self channelGroupWithName:@"test-channel-group"];
    
    
    [self addChannels:channels toChannelGroup:channelGroup usingClient:nil];
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(YES)
            .channelGroups(@[channelGroup])
            .performWithCompletion(^(PNStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 5.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence()
            .connected(NO)
            .channelGroups(@[channelGroup])
            .performWithCompletion(^(PNStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNUnsubscribeOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.presence().whereNow()
            .uuid(self.client.currentConfiguration.userID)
            .performWithCompletion(^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
                XCTAssertEqual(result.data.channels.count, 0);
                
                handler();
            });
    }];
    
    [self removeChannelGroup:channelGroup usingClient:nil];
}

- (void)testItShouldNotSetNotConnectedStateForChannelGroupsAndReceiveBadRequestStatusWhenChannelsIsNil {
    NSArray<NSString *> *channelGroups = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        __block __weak void (^weakBlock)(PNStatus *status);
        __block void (^block)(PNStatus *status);
        
        block = ^(PNStatus *status) {
            __strong void (^strongBlock)(PNStatus *status) = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNUnsubscribeOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            if (!retried) {
                retried = YES;
                self.client.presence().connected(NO).channelGroups(channelGroups).performWithCompletion(strongBlock);
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        self.client.presence().connected(NO).channelGroups(channelGroups).performWithCompletion(block);
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
