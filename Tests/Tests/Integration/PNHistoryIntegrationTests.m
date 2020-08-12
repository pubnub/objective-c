/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import "NSString+PNTest.h"


#pragma mark Interface declaration

@interface PNHistoryIntegrationTests : PNRecordableTestCase


#pragma mark - Information

/**
 * @brief Property used to create various test cases based on number of PubNub instances.
 */
@property (nonatomic, assign) NSUInteger configurationRequestCounter;

/**
 * @brief Message encryption / decryption key.
 */
@property (nonatomic, copy) NSString *cipherKey;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNHistoryIntegrationTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    BOOL shouldSetupVCR = [super shouldSetupVCR];
    
    if (!shouldSetupVCR) {
        NSArray<NSString *> *testNames = @[
            @"ShouldNotDeleteMessagesForChannelAndReceiveBadRequestStatusWhenChannelIsNil"
        ];
        
        shouldSetupVCR = [self.name pnt_includesAnyString:testNames];
    }
    
    return shouldSetupVCR;
}

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
    
    if ([self.name rangeOfString:@"Encrypt"].location != NSNotFound) {
        NSString *cipherKey = self.cipherKey;
        
        if (self.configurationRequestCounter > 0) {
            if ([self.name rangeOfString:@"DifferentCipherKeyIsSet"].location != NSNotFound) {
                cipherKey = [NSUUID UUID].UUIDString;
            }
        }
        
        configuration.cipherKey = cipherKey;
        self.configurationRequestCounter++;
    }
    
    return configuration;
}

- (void)setUp {
    [super setUp];
    
    
    self.cipherKey = @"enigma";
    [self completePubNubConfiguration:self.client];
}


#pragma mark - Tests :: History for channel

- (void)testItShouldFetchHistoryForChannelAndReceiveResultWithExpectedOperation {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 4;
    NSUInteger checkedMessageIdx = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSNumber *firstTimetoken = publishedMessages.firstObject[@"timetoken"];
    NSNumber *lastTimetoken = publishedMessages.lastObject[@"timetoken"];
    NSDictionary *checkedMessage = publishedMessages[checkedMessageIdx];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel
                        withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            XCTAssertEqual(fetchedMessages.count, expectedMessagesCount);
            XCTAssertEqualObjects(fetchedMessages[checkedMessageIdx], checkedMessage[@"message"]);
            XCTAssertEqual([result.data.start compare:firstTimetoken], NSOrderedSame);
            XCTAssertEqual([result.data.end compare:lastTimetoken], NSOrderedSame);
            XCTAssertEqual(result.operation, PNHistoryOperation);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldFetchHistoryForChannelInSpecifiedTimeframeWhenStartAndEndIsSet {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 5;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSNumber *middleMinusOneTimetoken = publishedMessages[1][@"timetoken"];
    NSNumber *middleTimetoken = publishedMessages[2][@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel start:middleTimetoken end:middleMinusOneTimetoken limit:101
                               reverse:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            XCTAssertEqual(fetchedMessages.count, 1);
            XCTAssertEqualObjects(fetchedMessages.firstObject, publishedMessages[2][@"message"]);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldFetchHistoryForChannelWithTimetokenWhenFlagItSet {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 4;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSUInteger checkedMessageIdx = (NSUInteger)(expectedMessagesCount * 0.5f);
    NSDictionary *checkedMessage = publishedMessages[checkedMessageIdx];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel start:nil end:nil includeTimeToken:YES
                        withCompletion:^(PNHistoryResult *result, PNErrorStatus * status) {
            
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            XCTAssertEqualObjects(fetchedMessages[checkedMessageIdx][@"message"], checkedMessage[@"message"]);
            XCTAssertEqualObjects(fetchedMessages[checkedMessageIdx][@"timetoken"], checkedMessage[@"timetoken"]);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldFetchHistoryForChannelWithMetadataWhenFlagIsSet {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 4;
    NSUInteger checkedMessageIdx = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSDictionary *checkedMessage = publishedMessages[checkedMessageIdx];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel withMetadata:YES
                            completion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            XCTAssertEqualObjects(fetchedMessages[checkedMessageIdx][@"metadata"],
                                  @{ @"time": checkedMessage[@"message"][@"time"] });
            XCTAssertEqual(result.operation, PNHistoryOperation);

            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldFetchHistoryForChannelWithEncryptedMessagesAndDecrypt {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 4;
    NSUInteger halfSize = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    
        
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel start:nil end:nil includeMetadata:YES
                        withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            XCTAssertEqualObjects(fetchedMessages[halfSize][@"message"],
                                  publishedMessages[halfSize][@"message"]);
            XCTAssertTrue([fetchedMessages[halfSize] isKindOfClass:[NSDictionary class]]);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldFetchHistoryForChannelWithEncryptedMessagesAndFailToDecryptWhenDifferentCipherKeyIsSet {
    PubNub *consumerClient = [self createPubNubClients:1].lastObject;
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 4;
    NSUInteger halfSize = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [consumerClient historyForChannel:channel start:nil end:nil includeMessageActions:YES
                           withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNHistoryOperation);
            XCTAssertEqual(status.category, PNDecryptionErrorCategory);
            NSArray *encryptedMessages = status.associatedObject[@"channels"][channel];
            XCTAssertNotNil(status.associatedObject);
            XCTAssertNotNil(encryptedMessages);
            XCTAssertNotEqualObjects(encryptedMessages[halfSize][@"message"], publishedMessages[halfSize][@"message"]);
            XCTAssertTrue([encryptedMessages[halfSize][@"message"] isKindOfClass:[NSString class]]);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldFetchOlderChannelHistoryPageWhenCalledWithLimitAndStartAndReceiveResultWithExpectedOperation {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 10;
    NSUInteger halfSize = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSNumber *firstTimetoken = publishedMessages.firstObject[@"timetoken"];
    NSNumber *lastTimetoken = publishedMessages.lastObject[@"timetoken"];
    NSNumber *middleMinusOneTimetoken = publishedMessages[halfSize - 1][@"timetoken"];
    NSNumber *middleTimetoken = publishedMessages[halfSize][@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel start:nil end:nil limit:halfSize
                      includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            NSNumber *firstFetchedTimetoken = fetchedMessages.firstObject[@"timetoken"];
            NSNumber *lastFetchedTimetoken = fetchedMessages.lastObject[@"timetoken"];
            
            XCTAssertEqual([firstFetchedTimetoken compare:middleTimetoken], NSOrderedSame);
            XCTAssertEqual([lastFetchedTimetoken compare:lastTimetoken], NSOrderedSame);
            XCTAssertEqual(fetchedMessages.count, halfSize);
            XCTAssertEqual([result.data.start compare:middleTimetoken], NSOrderedSame);
            XCTAssertEqual([result.data.end compare:lastTimetoken], NSOrderedSame);
            
            handler();
        }];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel start:middleTimetoken end:nil limit:halfSize
                      includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            NSNumber *firstFetchedTimetoken = fetchedMessages.firstObject[@"timetoken"];
            NSNumber *lastFetchedTimetoken = fetchedMessages.lastObject[@"timetoken"];
            
            XCTAssertEqual([firstFetchedTimetoken compare:firstTimetoken], NSOrderedSame);
            XCTAssertEqual([lastFetchedTimetoken compare:middleMinusOneTimetoken], NSOrderedSame);
            XCTAssertEqual(fetchedMessages.count, halfSize);
            XCTAssertEqual([result.data.start compare:firstTimetoken], NSOrderedSame);
            XCTAssertEqual([result.data.end compare:middleMinusOneTimetoken], NSOrderedSame);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldFetchNewerChannelHistoryPageWhenCalledWithLimitAndStart {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 10;
    NSUInteger halfSize = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSNumber *firstTimetoken = publishedMessages.firstObject[@"timetoken"];
    NSNumber *lastTimetoken = publishedMessages.lastObject[@"timetoken"];
    NSNumber *middleMinusOneTimetoken = publishedMessages[halfSize - 1][@"timetoken"];
    NSNumber *middleTimetoken = publishedMessages[halfSize][@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel start:nil end:nil limit:halfSize reverse:YES
                      includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            NSNumber *firstFetchedTimetoken = fetchedMessages.firstObject[@"timetoken"];
            NSNumber *lastFetchedTimetoken = fetchedMessages.lastObject[@"timetoken"];
            
            XCTAssertEqual([firstFetchedTimetoken compare:firstTimetoken], NSOrderedSame);
            XCTAssertEqual([lastFetchedTimetoken compare:middleMinusOneTimetoken], NSOrderedSame);
            XCTAssertEqual(fetchedMessages.count, halfSize);
            XCTAssertEqual([result.data.start compare:firstTimetoken], NSOrderedSame);
            XCTAssertEqual([result.data.end compare:middleMinusOneTimetoken], NSOrderedSame);
            
            handler();
        }];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel start:middleMinusOneTimetoken end:nil limit:halfSize reverse:YES
                      includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            NSNumber *firstFetchedTimetoken = fetchedMessages.firstObject[@"timetoken"];
            NSNumber *lastFetchedTimetoken = fetchedMessages.lastObject[@"timetoken"];
            
            XCTAssertEqual([firstFetchedTimetoken compare:middleTimetoken], NSOrderedSame);
            XCTAssertEqual([lastFetchedTimetoken compare:lastTimetoken], NSOrderedSame);
            XCTAssertEqual(fetchedMessages.count, halfSize);
            XCTAssertEqual([result.data.start compare:middleTimetoken], NSOrderedSame);
            XCTAssertEqual([result.data.end compare:lastTimetoken], NSOrderedSame);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldNotFetchHistoryForChannelAndReceiveBadRequestStatusWhenChannelIsNil {
    __block BOOL retried = NO;
    NSString *channel = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNHistoryOperation);
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


#pragma mark - Tests :: Builder pattern-based history for channel

- (void)testItShouldFetchHistoryForChannelUsingBuilderPatternInterface {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 4;
    NSUInteger checkedMessageIdx = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSNumber *firstTimetoken = publishedMessages.firstObject[@"timetoken"];
    NSNumber *lastTimetoken = publishedMessages.lastObject[@"timetoken"];
    NSDictionary *checkedMessage = publishedMessages[checkedMessageIdx];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channel(channel)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                NSArray *fetchedMessages = result.data.messages;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedMessages);
                XCTAssertEqual(fetchedMessages.count, expectedMessagesCount);
                XCTAssertEqualObjects(fetchedMessages[checkedMessageIdx], checkedMessage[@"message"]);
                XCTAssertEqual([result.data.start compare:firstTimetoken], NSOrderedSame);
                XCTAssertEqual([result.data.end compare:lastTimetoken], NSOrderedSame);
                XCTAssertEqual(result.operation, PNHistoryOperation);
                
                handler();
            });
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}


#pragma mark - Tests :: History for channel with actions

- (void)testItShouldFetchHistoryForChannelWithActionsAndReceiveResultWithExpectedOperation {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 2;
    NSUInteger expectedActionsCount = 4;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    NSArray<PNMessageAction *> *actions = [self addActions:expectedActionsCount
                                                toMessages:timetokens
                                                 inChannel:channel
                                               usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel withMessageActions:YES
                            completion:^(PNHistoryResult *result, PNErrorStatus *status) {
            
            NSArray *fetchedMessages = result.data.channels[channel];
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            
            NSDictionary *actionsByType = [fetchedMessages.firstObject valueForKey:@"actions"];
            NSUInteger historyActionsCount = 0;
            
            for (NSString *actionType in actionsByType) {
                for (NSString *actionValue in actionsByType[actionType]) {
                    BOOL actionFound = NO;
                    historyActionsCount++;
                    
                    for (PNMessageAction *action in actions) {
                        if (![action.value isEqualToString:actionValue]) {
                            continue;
                        }
                        
                        actionFound = YES;
                    }
                    
                    XCTAssertTrue(actionFound);
                }
            };
            
            XCTAssertEqual(historyActionsCount, expectedActionsCount);
            XCTAssertEqualObjects(fetchedMessages.firstObject[@"timetoken"], timetokens.firstObject);
            XCTAssertEqualObjects(fetchedMessages.lastObject[@"timetoken"], timetokens.lastObject);
            XCTAssertEqual(result.operation, PNHistoryWithActionsOperation);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based history for channel with actions

- (void)testItShouldFetchHistoryWithActionsUsingBuilderPatternInterface {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 2;
    NSUInteger expectedActionsCount = 4;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    NSArray<PNMessageAction *> *actions = [self addActions:expectedActionsCount
                                                toMessages:timetokens
                                                 inChannel:channel
                                               usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channel(channel)
            .includeMessageActions(YES)
            .includeMetadata(YES)
            .limit(16)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                NSArray *fetchedMessages = result.data.channels[channel];
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedMessages);
                NSDictionary *actionsByType = [fetchedMessages.firstObject valueForKey:@"actions"];
                XCTAssertNotNil(fetchedMessages.firstObject[@"uuid"]);
                NSUInteger historyActionsCount = 0;
                
                for (NSString *actionType in actionsByType) {
                    for (NSString *actionValue in actionsByType[actionType]) {
                        BOOL actionFound = NO;
                        historyActionsCount++;
                        
                        for (PNMessageAction *action in actions) {
                            if (![action.value isEqualToString:actionValue]) {
                                continue;
                            }
                            
                            actionFound = YES;
                        }
                        
                        XCTAssertTrue(actionFound);
                    }
                };
                
                XCTAssertEqual(historyActionsCount, expectedActionsCount);
                XCTAssertEqualObjects(fetchedMessages.firstObject[@"timetoken"], timetokens.firstObject);
                XCTAssertEqualObjects(fetchedMessages.lastObject[@"timetoken"], timetokens.lastObject);
                XCTAssertEqual(result.operation, PNHistoryWithActionsOperation);
                
                handler();
            });
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldNotFetchHistoryWithActionsAndReceiveBadRequestStatusWhenMultupleChannelsSet {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            self.client.history()
                .channels(channels)
                .includeMessageActions(YES)
                .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                    XCTAssertTrue(status.isError);
                    XCTAssertEqual(status.operation, PNHistoryOperation);
                    XCTAssertEqual(status.category, PNBadRequestCategory);
                    XCTAssertEqual(status.statusCode, 400);
                });
        } @catch (NSException *exception) {
            handler();
        }
    }];
}


#pragma mark - Tests :: Builder pattern-based history for channels

- (void)testItShouldFetchOneMessageForEachChannelUsingBuilderPatternInterfaceAndReceiveResultWithExpectedOperation {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSUInteger expectedMessagesCount = 4;
    
    NSDictionary<NSString *, NSArray *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                                        toChannels:channels
                                                                       usingClient:nil];
    NSArray<NSDictionary *> *messages1 = publishedMessages[channels.firstObject];
    NSArray<NSDictionary *> *messages2 = publishedMessages[channels.lastObject];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channels(channels)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertNil(status);
                XCTAssertNotEqualObjects(result.data.channels, @{});
                NSDictionary<NSString *, NSArray *> *channelsWithMessages = result.data.channels;
                NSArray<NSDictionary *> *channel1Messages = channelsWithMessages[channels.firstObject];
                NSArray<NSDictionary *> *channel2Messages = channelsWithMessages[channels.lastObject];
                XCTAssertEqual(channelsWithMessages.count, channels.count);
                XCTAssertEqual(channel1Messages.count, 1);
                XCTAssertEqual(channel2Messages.count, 1);
                XCTAssertNotNil(channel2Messages.firstObject[@"uuid"]);
                XCTAssertEqualObjects(channel1Messages.firstObject[@"message"], messages1.lastObject[@"message"]);
                XCTAssertEqualObjects(channel2Messages.firstObject[@"message"], messages2.lastObject[@"message"]);
                XCTAssertEqual([channel1Messages.firstObject[@"timetoken"] compare:messages1.lastObject[@"timetoken"]],
                               NSOrderedSame);
                XCTAssertEqual([channel2Messages.firstObject[@"timetoken"] compare:messages2.lastObject[@"timetoken"]],
                               NSOrderedSame);
                XCTAssertEqual([result.data.start compare:@(0)], NSOrderedSame);
                XCTAssertEqual([result.data.end compare:@(0)], NSOrderedSame);
                XCTAssertEqual(result.operation, PNHistoryForChannelsOperation);
                
                handler();
        });
    }];
    
    [self deleteHistoryForChannels:channels usingClient:nil];
}

- (void)testItShouldFetchOneMessageForEachChannelWithOutUUIDUsingBuilder {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSUInteger expectedMessagesCount = 4;
    
    [self publishMessages:expectedMessagesCount toChannels:channels usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channels(channels)
            .includeUUID(NO)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertNil(status);
                XCTAssertNotEqualObjects(result.data.channels, @{});
                NSDictionary<NSString *, NSArray *> *channelsWithMessages = result.data.channels;
                NSArray<NSDictionary *> *channel1Messages = channelsWithMessages[channels.firstObject];
                NSArray<NSDictionary *> *channel2Messages = channelsWithMessages[channels.lastObject];
                XCTAssertEqual(channelsWithMessages.count, channels.count);
                XCTAssertEqual(channel1Messages.count, 1);
                XCTAssertEqual(channel2Messages.count, 1);
                XCTAssertNil(channel2Messages.firstObject[@"uuid"]);
                
                handler();
        });
    }];
    
    [self deleteHistoryForChannels:channels usingClient:nil];
}

- (void)testItShouldFetchMessagesForEachChannelUsingBuilderPatternInterfaceWhenLimitIsSet {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSUInteger expectedMessagesCount = 4;
    NSUInteger checkedMessageIdx = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSDictionary<NSString *, NSArray *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                                        toChannels:channels
                                                                       usingClient:nil];
    NSArray<NSDictionary *> *messages1 = publishedMessages[channels.firstObject];
    NSArray<NSDictionary *> *messages2 = publishedMessages[channels.lastObject];
    NSNumber *channel1FirstTimetoken = messages1.firstObject[@"timetoken"];
    NSNumber *channel1LastTimetoken = messages1.lastObject[@"timetoken"];
    NSNumber *channel2FirstTimetoken = messages2.firstObject[@"timetoken"];
    NSNumber *channel2LastTimetoken = messages2.lastObject[@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channels(channels)
            .limit(20)
            .includeMetadata(YES)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertNil(status);
                XCTAssertNotEqualObjects(result.data.channels, @{});
                NSDictionary<NSString *, NSArray *> *channelsWithMessages = result.data.channels;
                NSArray<NSDictionary *> *channel1Messages = channelsWithMessages[channels.firstObject];
                NSArray<NSDictionary *> *channel2Messages = channelsWithMessages[channels.lastObject];
                XCTAssertEqual(channelsWithMessages.count, channels.count);
                XCTAssertEqual(channel1Messages.count, messages1.count);
                XCTAssertEqual(channel2Messages.count, messages2.count);
                XCTAssertEqualObjects(channel1Messages[checkedMessageIdx][@"message"],
                                      messages1[checkedMessageIdx][@"message"]);
                XCTAssertEqualObjects(channel2Messages[checkedMessageIdx][@"message"],
                                      messages2[checkedMessageIdx][@"message"]);
                XCTAssertEqualObjects(channel1Messages[checkedMessageIdx][@"metadata"],
                                      @{ @"time": messages1[checkedMessageIdx][@"message"][@"time"]});
                XCTAssertEqualObjects(channel2Messages[checkedMessageIdx][@"metadata"],
                                      @{ @"time": messages2[checkedMessageIdx][@"message"][@"time"]});
                XCTAssertEqual([channel1Messages.firstObject[@"timetoken"]
                                compare:channel1FirstTimetoken], NSOrderedSame);
                XCTAssertEqual([channel1Messages.lastObject[@"timetoken"]
                                compare:channel1LastTimetoken], NSOrderedSame);
                XCTAssertEqual([channel2Messages.firstObject[@"timetoken"]
                                compare:channel2FirstTimetoken], NSOrderedSame);
                XCTAssertEqual([channel2Messages.lastObject[@"timetoken"]
                                compare:channel2LastTimetoken], NSOrderedSame);
                
                handler();
            });
    }];
    
    [self deleteHistoryForChannels:channels usingClient:nil];
}


#pragma mark - Tests :: Delete history for channel

- (void)testItShouldDeleteMessagesForChannelAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 10;
    
    [self publishMessages:expectedMessagesCount toChannel:channel usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client deleteMessagesFromChannel:channel start:nil end:nil
                                withCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNDeleteMessageOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqualObjects(result.data.messages, @[]);
            XCTAssertEqual(result.operation, PNHistoryOperation);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldDeleteMessagesForChannelExcludingSpecifiedTimetokenAndOlderWhenStartIsSet {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 10;
    NSUInteger halfSize = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSNumber *middleTimetoken = publishedMessages[halfSize][@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client deleteMessagesFromChannel:channel start:middleTimetoken end:nil
                                withCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            
            handler();
        }];
    }];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            XCTAssertEqual(fetchedMessages.count, halfSize);
            XCTAssertEqualObjects(fetchedMessages.firstObject, publishedMessages[halfSize][@"message"]);
            XCTAssertEqualObjects(fetchedMessages.lastObject, publishedMessages.lastObject[@"message"]);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldDeleteMessagesForChannelIncludingSpecifiedTimetokenAndNewerWhenEndIsSet {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 10;
    NSUInteger halfSize = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSNumber *middleTimetoken = publishedMessages[halfSize][@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client deleteMessagesFromChannel:channel start:nil end:middleTimetoken
                                withCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            
            handler();
        }];
    }];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            XCTAssertEqual(fetchedMessages.count, halfSize);
            XCTAssertEqualObjects(fetchedMessages.firstObject, publishedMessages.firstObject[@"message"]);
            XCTAssertEqualObjects(fetchedMessages.lastObject, publishedMessages[halfSize - 1][@"message"]);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldDeleteMessagesForChannelExcludingSpecifiedStartAndIncludingEndTimetokenWhenStartAndEndIsSet {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 10;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSNumber *firstTimetoken = publishedMessages[0][@"timetoken"];
    NSNumber *lastTimetoken = publishedMessages[publishedMessages.count - 2][@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client deleteMessagesFromChannel:channel start:lastTimetoken end:firstTimetoken
                                withCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            
            handler();
        }];
    }];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            XCTAssertEqual(fetchedMessages.count, 2);
            XCTAssertEqualObjects(fetchedMessages.firstObject, publishedMessages.firstObject[@"message"]);
            XCTAssertEqualObjects(fetchedMessages.lastObject, publishedMessages.lastObject[@"message"]);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldNotDeleteMessagesForChannelAndReceiveBadRequestStatusWhenChannelIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 4;
    __block BOOL retried = NO;
    NSString *expectedChannel = nil;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client deleteMessagesFromChannel:expectedChannel start:nil end:nil
                                withCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNDeleteMessageOperation);
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
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            NSArray *fetchedMessages = result.data.messages;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedMessages);
            XCTAssertEqual(fetchedMessages.count, publishedMessages.count);
            XCTAssertEqualObjects(fetchedMessages.firstObject, publishedMessages.firstObject[@"message"]);
            XCTAssertEqualObjects(fetchedMessages.lastObject, publishedMessages.lastObject[@"message"]);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based delete history for channel

- (void)testItShouldDeleteMessagesForChannelUsingBuilderPatternInterface {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 10;
    
    [self publishMessages:expectedMessagesCount toChannel:channel usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.deleteMessage()
            .channel(channel)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNDeleteMessageOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqualObjects(result.data.messages, @[]);
            XCTAssertEqual(result.operation, PNHistoryOperation);
            
            handler();
        }];
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}


#pragma mark - Tests :: Builder pattern-based channel messages count

- (void)testItShouldFetchMessagesCountForChannelAndReceiveResultWithExpectedOperation {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSUInteger expectedMessagesCount = 5;
    NSUInteger expectedCount = 2;
    NSUInteger checkedMessageIdx = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSDictionary<NSString *, NSArray *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                                        toChannels:channels
                                                                       usingClient:nil];
    NSNumber *channel1CheckedTimetoken = publishedMessages[channels.firstObject][checkedMessageIdx][@"timetoken"];
    NSNumber *channel2CheckedTimetoken = publishedMessages[channels.lastObject][checkedMessageIdx][@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts()
            .channels(channels)
            .timetokens(@[channel1CheckedTimetoken, channel2CheckedTimetoken])
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                NSDictionary<NSString *, NSNumber *> *messagesCount = result.data.channels;
                XCTAssertNil(status);
                XCTAssertEqual(messagesCount[channels.firstObject].unsignedIntegerValue, expectedCount);
                XCTAssertEqual(messagesCount[channels.lastObject].unsignedIntegerValue, expectedCount);
                XCTAssertEqual(result.operation, PNMessageCountOperation);
                
                handler();
            });
    }];
    
    [self deleteHistoryForChannels:channels usingClient:nil];
}

- (void)testItShouldFetchMessagesCountForChannelAndSingleTimetokenForFewChannels {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSUInteger expectedMessagesCount = 5;
    NSUInteger expectedChannel1Count = 2;
    NSUInteger expectedChannel2Count = expectedMessagesCount;
    NSUInteger checkedMessageIdx = (NSUInteger)(expectedMessagesCount * 0.5f);
    
    NSDictionary<NSString *, NSArray *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                                        toChannels:channels
                                                                       usingClient:nil];
    NSNumber *channel1CheckedTimetoken = publishedMessages[channels.firstObject][checkedMessageIdx][@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts()
            .channels(channels)
            .timetokens(@[channel1CheckedTimetoken])
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                NSDictionary<NSString *, NSNumber *> *messagesCount = result.data.channels;
                XCTAssertNil(status);
                XCTAssertEqual(messagesCount[channels.firstObject].unsignedIntegerValue, expectedChannel1Count);
                XCTAssertEqual(messagesCount[channels.lastObject].unsignedIntegerValue, expectedChannel2Count);
                XCTAssertEqual(result.operation, PNMessageCountOperation);
                
                handler();
            });
    }];
    
    [self deleteHistoryForChannels:channels usingClient:nil];
}

- (void)testItShouldNotFetchMessagesCountForChannelAndReceiveBadRequestStatusWhenChannelsIsNil {
    NSArray<NSNumber *> *timetokens = @[@1000000];
    NSArray<NSString *> *channels = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts()
            .channels(channels)
            .timetokens(timetokens)
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.operation, PNMessageCountOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                XCTAssertEqual(status.statusCode, 400);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
                
                handler();
            });
    }];
}

- (void)testItShouldNotFetchMessagesCountForChannelAndReceiveBadRequestStatusWhenDifferentThanChannelsTimetokensCountPassed {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1"]];
    NSArray<NSNumber *> *timetokens = @[@1000000, @1000001];
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts()
            .channels(channels)
            .timetokens(timetokens)
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.operation, PNMessageCountOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                XCTAssertEqual(status.statusCode, 400);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
                
                handler();
            });
    }];
}

- (void)testItShouldNotFetchMessagesCountForChannelAndReceiveBadRequestStatusWhenTimetokensIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1"]];
    NSArray<NSNumber *> *timetokens = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts()
            .channels(channels)
            .timetokens(timetokens)
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.operation, PNMessageCountOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                XCTAssertEqual(status.statusCode, 400);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
                
                handler();
            });
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
