#import "PNTestCase.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Test interface declaration

@interface PNHistoryIntegrationTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;


#pragma mark - Misc

/**
 * @brief Publish test messages to specified \c channel.
 *
 * @param messagesCount How many messages should be published to specified \c channel.
 * @param channel Name of channel which will be used in test with pre-published messages.
 *
 * @return List of published message and timetokens.
 */
- (NSArray<NSDictionary *> *)publishMessages:(NSUInteger)messagesCount
                                   toChannel:(NSString *)channel;

/**
 * @brief Publish test messages to set of specified \c channels.
 *
 * @param messagesCount How many messages should be published to specified \c channel.
 * @param channels List of channel names which will be used in test with pre-published messages.
 *
 * @return List of published message and timetokens mapped to channel names.
 */
- (NSDictionary<NSString *, NSArray<NSDictionary *> *> *)publishMessages:(NSUInteger)messagesCount
                                                              toChannels:(NSArray<NSString *> *)channels;

/**
 * @brief Publish test messages to specified \c channel.
 *
 * @param actionsCount How many actions should be added for each message.
 * @param messages List of publish timetokens for messages to which \c actions will be added.
 * @param channel Name of channel which contains references messages.
 *
 * @return List of message actions.
 */
- (NSArray<PNMessageAction *> *)addActions:(NSUInteger)actionsCount
                                toMessages:(NSArray<NSNumber *> *)messages
                                 inChannel:(NSString *)channel;

/**
 * @brief Publish test messages to set of specified \c channels.
 *
 * @param actionsCount How many actions should be added for each message.
 * @param messages List of publish timetokens for messages to which \c actions will be added.
 * @param channel List of channel names which contains references messages.
 *
 * @return List of message actions mapped to channel names.
 */
- (NSDictionary<NSString *, NSArray<PNMessageAction *> *> *)addActions:(NSUInteger)actionsCount
                                                            toMessages:(NSArray<NSNumber *> *)messages
                                                            inChannels:(NSArray<NSString *> *)channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNHistoryIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}

- (void)tearDown {
    [self removeAllHandlersForClient:self.client];
    [self.client removeListener:self];
    
    
    [super tearDown];
}


#pragma mark - Tests :: History for channel

- (void)testHistoryForChannel_ShouldFetchHistory_WhenCalled {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSUInteger expectedCount = 4;
    NSUInteger verifiedMessageIdx = (NSUInteger)(expectedCount * 0.5f);
    
    
    NSArray<NSDictionary *> *messages = [self publishMessages:expectedCount toChannel:expectedChannel];
    NSNumber *firstMessageTimetoken = messages[0][@"timetoken"];
    NSNumber *lastMessageTimetoken = messages[expectedCount - 1][@"timetoken"];
    
    [self waitTask:@"propagateToStorage" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channel(expectedChannel)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(result.data.messages);
                XCTAssertEqualObjects(result.data.channels, @{});
                XCTAssertEqual(result.data.messages.count, messages.count);
                XCTAssertEqualObjects(result.data.messages[verifiedMessageIdx],
                                      messages[verifiedMessageIdx][@"message"]);
                XCTAssertEqual([result.data.start compare:firstMessageTimetoken], NSOrderedSame);
                XCTAssertEqual([result.data.end compare:lastMessageTimetoken], NSOrderedSame);
                
                handler();
            });
    }];
}

- (void)testHistoryForChannel_ShouldFetchHistoryWithMessageMetadata_WhenCalled {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSUInteger expectedCount = 4;
    NSUInteger verifiedMessageIdx = (NSUInteger)(expectedCount * 0.5f);
    
    
    NSArray<NSDictionary *> *messages = [self publishMessages:expectedCount toChannel:expectedChannel];
    NSNumber *firstMessageTimetoken = messages[0][@"timetoken"];
    NSNumber *lastMessageTimetoken = messages[expectedCount - 1][@"timetoken"];
    NSDictionary *verifiedMessage = messages[verifiedMessageIdx];
    
    [self waitTask:@"propagateToStorage" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channel(expectedChannel)
            .includeMetadata(YES)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(result.data.messages);
                XCTAssertEqualObjects(result.data.channels, @{});
                XCTAssertEqual(result.data.messages.count, messages.count);
                XCTAssertEqualObjects(result.data.messages[verifiedMessageIdx][@"message"],
                                      verifiedMessage[@"message"]);
                XCTAssertEqualObjects(result.data.messages[verifiedMessageIdx][@"metadata"],
                                      @{ @"time": verifiedMessage[@"message"][@"time"]});
                XCTAssertEqual([result.data.start compare:firstMessageTimetoken], NSOrderedSame);
                XCTAssertEqual([result.data.end compare:lastMessageTimetoken], NSOrderedSame);
                
                handler();
            });
    }];
}

- (void)testHistoryForChannel_ShouldFetchNextMessagesPage_WhenCalledWithLimitAndStart {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSUInteger expectedCount = 10;
    NSUInteger halfSize = (NSUInteger)(expectedCount * 0.5f);
    
    
    NSArray<NSDictionary *> *messages = [self publishMessages:expectedCount toChannel:expectedChannel];
    [self waitTask:@"propagateToStorage" completionFor:2.f];
    NSNumber *firstMessageTimetoken = messages[0][@"timetoken"];
    NSNumber *lastMessageTimetoken = messages[expectedCount - 1][@"timetoken"];
    NSNumber *middlePublishedMessageTimetoken = messages[halfSize][@"timetoken"];
    NSNumber *middleMinusOnePublishedPublishedTimetoken = messages[halfSize - 1][@"timetoken"];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channel(expectedChannel)
            .includeTimeToken(YES)
            .limit(halfSize)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                NSArray<NSDictionary *> *fetchedMessages = result.data.messages;
                NSNumber *firstFetchedMessageTimetoken = fetchedMessages[0][@"timetoken"];
                NSNumber *lastFetchedMessageTimetoken = fetchedMessages.lastObject[@"timetoken"];
                
                XCTAssertEqual([firstFetchedMessageTimetoken compare:middlePublishedMessageTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([lastFetchedMessageTimetoken compare:lastMessageTimetoken],
                               NSOrderedSame);
                XCTAssertEqual(fetchedMessages.count, halfSize);
                XCTAssertEqual([result.data.start compare:middlePublishedMessageTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([result.data.end compare:lastMessageTimetoken],
                               NSOrderedSame);
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channel(expectedChannel)
            .includeTimeToken(YES)
            .start(middlePublishedMessageTimetoken)
            .limit(halfSize)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                NSArray<NSDictionary *> *fetchedMessages = result.data.messages;
                NSNumber *firstFetchedMessageTimetoken = fetchedMessages[0][@"timetoken"];
                NSNumber *lastFetchedMessageTimetoken = fetchedMessages.lastObject[@"timetoken"];

                XCTAssertEqual([firstFetchedMessageTimetoken compare:firstMessageTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([lastFetchedMessageTimetoken compare:middleMinusOnePublishedPublishedTimetoken],
                               NSOrderedSame);
                XCTAssertEqual(fetchedMessages.count, halfSize);
                XCTAssertEqual([result.data.start compare:firstMessageTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([result.data.end compare:middleMinusOnePublishedPublishedTimetoken],
                               NSOrderedSame);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: History for channel with actions

- (void)testHistoryWithActions_ShouldFetchWithActions_WhenCalled {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSUInteger expectedMessagesCount = 2;
    NSUInteger expectedActionsCount = 4;
    
    
    NSArray<NSDictionary *> *messages = [self publishMessages:expectedMessagesCount
                                                    toChannel:expectedChannel];
    NSArray<NSNumber *> *messageTimetokens = [messages valueForKey:@"timetoken"];
    NSArray<PNMessageAction *> *actions = [self addActions:expectedActionsCount
                                                toMessages:messageTimetokens
                                                 inChannel:expectedChannel];

    [self waitTask:@"propagateToStorage" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channel(expectedChannel)
            .includeMessageActions(YES)
            .includeMetadata(YES)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                NSArray<NSDictionary *> *messages = result.data.channels[expectedChannel];
                NSDictionary *actionsByType = [messages.firstObject valueForKey:@"actions"];
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
                XCTAssertEqualObjects(messages.firstObject[@"timetoken"], messageTimetokens.firstObject);
                XCTAssertEqualObjects(messages.lastObject[@"timetoken"], messageTimetokens.lastObject);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: History for channels

- (void)testHistoryForChannels_ShouldFetchOneMessageForEachChannel_WhenCalledWithOutLimit {
    NSArray<NSString *> *expectedChannels = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSUInteger expectedCount = 4;
    
    
    NSDictionary<NSString *, NSArray *> *messages = [self publishMessages:expectedCount
                                                               toChannels:expectedChannels];
    NSArray<NSDictionary *> *messages1 = messages[expectedChannels.firstObject];
    NSArray<NSDictionary *> *messages2 = messages[expectedChannels.lastObject];
    
    [self waitTask:@"propagateToStorage" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channels(expectedChannels)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertNotEqualObjects(result.data.channels, @{});
                XCTAssertEqualObjects(result.data.messages, @[]);
                NSDictionary<NSString *, NSArray *> *channels = result.data.channels;
                NSArray<NSDictionary *> *channel1Messages = channels[expectedChannels.firstObject];
                NSArray<NSDictionary *> *channel2Messages = channels[expectedChannels.lastObject];
                XCTAssertEqual(channels.count, expectedChannels.count);
                XCTAssertEqual(channel1Messages.count, 1);
                XCTAssertEqual(channel2Messages.count, 1);
                XCTAssertEqualObjects(channel1Messages.firstObject[@"message"],
                                      messages1.lastObject[@"message"]);
                XCTAssertEqualObjects(channel2Messages.firstObject[@"message"],
                                      messages2.lastObject[@"message"]);
                XCTAssertEqual([channel1Messages.firstObject[@"timetoken"]
                                compare:messages1.lastObject[@"timetoken"]], NSOrderedSame);
                XCTAssertEqual([channel2Messages.firstObject[@"timetoken"]
                                compare:messages2.lastObject[@"timetoken"]], NSOrderedSame);
                XCTAssertEqual([result.data.start compare:@(0)], NSOrderedSame);
                XCTAssertEqual([result.data.end compare:@(0)], NSOrderedSame);
                
                handler();
            });
    }];
}

- (void)testHistoryForChannels_ShouldFetchMessagesForEachChannel_WhenCalledWithLimit {
    NSArray<NSString *> *expectedChannels = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSUInteger expectedCount = 4;
    NSUInteger verifiedMessageIdx = (NSUInteger)(expectedCount * 0.5f);
    
    NSDictionary<NSString *, NSArray *> *messages = [self publishMessages:expectedCount
                                                               toChannels:expectedChannels];
    NSArray<NSDictionary *> *messages1 = messages[expectedChannels.firstObject];
    NSArray<NSDictionary *> *messages2 = messages[expectedChannels.lastObject];
    NSNumber *firstChannl1MessageTimetoken = messages1.firstObject[@"timetoken"];
    NSNumber *lastChannl1MessageTimetoken = messages1.lastObject[@"timetoken"];
    NSNumber *firstChannl2MessageTimetoken = messages2.firstObject[@"timetoken"];
    NSNumber *lastChannl2MessageTimetoken = messages2.lastObject[@"timetoken"];
    
    [self waitTask:@"propagateToStorage" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channels(expectedChannels)
            .limit(25)
            .includeMetadata(YES)
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertNotEqualObjects(result.data.channels, @{});
                XCTAssertEqualObjects(result.data.messages, @[]);
                NSDictionary<NSString *, NSArray *> *channels = result.data.channels;
                NSArray<NSDictionary *> *channel1Messages = channels[expectedChannels.firstObject];
                NSArray<NSDictionary *> *channel2Messages = channels[expectedChannels.lastObject];
                XCTAssertEqual(channels.count, expectedChannels.count);
                XCTAssertEqual(channel1Messages.count, messages1.count);
                XCTAssertEqual(channel2Messages.count, messages2.count);
                XCTAssertEqualObjects(channel1Messages[verifiedMessageIdx][@"message"],
                                      messages1[verifiedMessageIdx][@"message"]);
                XCTAssertEqualObjects(channel2Messages[verifiedMessageIdx][@"message"],
                                      messages2[verifiedMessageIdx][@"message"]);
                XCTAssertEqualObjects(channel1Messages[verifiedMessageIdx][@"metadata"],
                                      @{ @"time": messages1[verifiedMessageIdx][@"message"][@"time"]});
                XCTAssertEqualObjects(channel2Messages[verifiedMessageIdx][@"metadata"],
                                      @{ @"time": messages2[verifiedMessageIdx][@"message"][@"time"]});
                XCTAssertEqual([channel1Messages.firstObject[@"timetoken"]
                                compare:firstChannl1MessageTimetoken], NSOrderedSame);
                XCTAssertEqual([channel1Messages.lastObject[@"timetoken"]
                                compare:lastChannl1MessageTimetoken], NSOrderedSame);
                XCTAssertEqual([channel2Messages.firstObject[@"timetoken"]
                                compare:firstChannl2MessageTimetoken], NSOrderedSame);
                XCTAssertEqual([channel2Messages.lastObject[@"timetoken"]
                                compare:lastChannl2MessageTimetoken], NSOrderedSame);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Messages Count

- (void)testMessageCounts_ShouldFetchCount_WhenSingleChannelAndTimetokenPassed {
    NSArray<NSString *> *expectedChannels = @[[NSUUID UUID].UUIDString];
    NSUInteger expectedCount = 3;
    
    
    NSDictionary<NSString *, NSArray *> *messages = [self publishMessages:expectedCount
                                                               toChannels:expectedChannels];
    NSArray<NSNumber *> *channelTimetokens = [messages[expectedChannels.firstObject] valueForKey:@"timetoken"];
    NSNumber *timetoken = channelTimetokens[channelTimetokens.count - 2];
    NSDictionary *expected = @{ expectedChannels.firstObject: @(1) };
    
    [self waitTask:@"propagateToStorage" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(expectedChannels).timetokens(@[timetoken])
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqualObjects(result.data.channels, expected);
            handler();
        });
    }];
}

- (void)testMessageCounts_ShouldFetchCount_WhenSingleTimetokenAndMultipleChannelsPassed {
    NSArray<NSString *> *expectedChannels = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSUInteger expectedCount = 3;
    
    
    NSDictionary<NSString *, NSArray *> *messages = [self publishMessages:expectedCount
                                                               toChannels:expectedChannels];
    NSArray<NSNumber *> *channelTimetokens = [messages[expectedChannels.firstObject] valueForKey:@"timetoken"];
    NSNumber *timetoken = channelTimetokens[channelTimetokens.count - 2];
    NSDictionary *expected = @{ expectedChannels.firstObject: @(1), expectedChannels.lastObject: @(3) };
    
    [self waitTask:@"propagateToStorage" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(expectedChannels).timetokens(@[timetoken])
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqualObjects(result.data.channels, expected);
            handler();
        });
    }];
}

- (void)testMessageCounts_ShouldFetchCount_WhenPerChannelTimetokenPassed {
    NSArray<NSString *> *expectedChannels = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSUInteger expectedCount = 3;
    
    
    NSDictionary<NSString *, NSArray *> *messages = [self publishMessages:expectedCount
                                                               toChannels:expectedChannels];
    NSArray<NSNumber *> *channelTimetokens1 = [messages[expectedChannels.firstObject] valueForKey:@"timetoken"];
    NSArray<NSNumber *> *channelTimetokens2 = [messages[expectedChannels.lastObject] valueForKey:@"timetoken"];
    NSNumber *timetoken1 = channelTimetokens1[channelTimetokens1.count - 2];
    NSNumber *timetoken2 = channelTimetokens2[channelTimetokens2.count - 2];
    NSArray<NSNumber *> *timetokens = @[timetoken1, timetoken2];
    NSDictionary *expected = @{ expectedChannels.firstObject: @(1), expectedChannels.lastObject: @(1) };
    
    [self waitTask:@"propagateToStorage" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(expectedChannels).timetokens(timetokens)
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqualObjects(result.data.channels, expected);
            handler();
        });
    }];
}

- (void)testMessageCounts_ShouldFail_WhenTimetokenNotPassed {
    NSArray<NSString *> *channels = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(channels)
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            handler();
        });
    }];
}


#pragma mark - Misc

- (NSArray<NSDictionary *> *)publishMessages:(NSUInteger)messagesCount
                                   toChannel:(NSString *)channel {
    
    NSMutableArray *messages = [NSMutableArray new];
    
    for (NSUInteger messageIdx = 0; messageIdx < messagesCount; messageIdx++) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            NSDictionary *message = @{
                @"messageIdx": [@[channel, @(messageIdx)] componentsJoinedByString:@": "],
                @"time": @([NSDate date].timeIntervalSince1970)
            };
            
            PNPublishAPICallBuilder *builder = self.client.publish().message(message).channel(channel);
            if (messageIdx % 2 == 0) {
                builder = builder.metadata(@{ @"time": message[@"time"] });
            }
            
            builder.performWithCompletion(^(PNPublishStatus *status) {
                if (!status.isError) {
                    [messages addObject:@{ @"message": message, @"timetoken": status.data.timetoken }];
                }
                
                handler();
            });
        }];
    }
    
    return messages;
}

- (NSDictionary<NSString *, NSArray<NSDictionary *> *> *)publishMessages:(NSUInteger)messagesCount
                                                              toChannels:(NSArray<NSString *> *)channels {
    
    NSMutableDictionary *channelMessages = [NSMutableDictionary new];
    
    for (NSString *channel in channels) {
        channelMessages[channel] = [self publishMessages:messagesCount toChannel:channel];
    }
    
    return channelMessages;
}

- (NSArray<PNMessageAction *> *)addActions:(NSUInteger)actionsCount
                                toMessages:(NSArray<NSNumber *> *)messages
                                 inChannel:(NSString *)channel {
    
    NSArray<NSString *> *types = @[@"reaction", @"receipt", @"custom"];
    
    static NSArray<NSString *> *_sharedHistoryActionValues;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHistoryActionValues = @[
            [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
            [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
            [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
            [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
            [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString
        ];
    });
    
    NSMutableArray *actions = [NSMutableArray new];
    
    for (NSUInteger messageIdx = 0; messageIdx < messages.count; messageIdx++) {
        NSNumber *messageTimetoken = messages[messageIdx];
        
        for (NSUInteger actionIdx = 0; actionIdx < actionsCount; actionIdx++) {
            [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
                self.client.addMessageAction()
                    .channel(channel)
                    .messageTimetoken(messageTimetoken)
                    .type(types[(actionIdx + 1)%3])
                    .value(_sharedHistoryActionValues[(actionIdx + 1)%10])
                    .performWithCompletion(^(PNAddMessageActionStatus *status) {
                        if (!status.isError) {
                            [actions addObject:status.data.action];
                        }
                        handler();
                    });
            }];
        }
    }
    
    return actions;
}

- (NSDictionary<NSString *, NSArray<PNMessageAction *> *> *)addActions:(NSUInteger)actionsCount
                                                            toMessages:(NSArray<NSNumber *> *)messages
                                                            inChannels:(NSArray<NSString *> *)channels {
    
    NSMutableDictionary *channelActions = [NSMutableDictionary new];
    
    for (NSString *channel in channels) {
        channelActions[channel] = [self addActions:actionsCount
                                        toMessages:messages
                                         inChannel:channel];
    }
    
    return channelActions;
}

#pragma mark -

@end
