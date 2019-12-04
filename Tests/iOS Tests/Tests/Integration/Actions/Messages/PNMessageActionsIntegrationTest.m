#import "PNTestCase.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Test interface declaration

@interface PNMessageActionsIntegrationTest : PNTestCase


#pragma mark - Information

/**
 * @brief Client which can be used to generate events.
 */
@property (nonatomic, strong) PubNub *client1;

/**
 * @brief Client which can be used to handle and verify actions of first client.
 */
@property (nonatomic, strong) PubNub *client2;


#pragma mark - Misc

/**
 * @brief Publish test messages to specified \c channel.
 *
 * @param messagesCount How many messages should be published to specified \c channel.
 * @param channel Name of channel which will be used in test with pre-published messages.
 *
 * @return List of published messages timetokens.
 */
- (NSArray<NSNumber *> *)publishMessages:(NSUInteger)messagesCount toChannel:(NSString *)channel;

/**
 * @brief Publish test messages to specified \c channel.
 *
 * @param actionsCount How many actions should be added for each message.
 * @param messages List of publish timetokens for messages to which \c actions will be added.
 * @param channel Name of channel which contains references messages.
 *
 * @return List of message action timetokens.
 */
- (NSArray<NSNumber *> *)addActions:(NSUInteger)actionsCount
                         toMessages:(NSArray<NSNumber *> *)messages
                          inChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMessageActionsIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    self.client1 = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
    self.client2 = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}

- (void)tearDown {
    [self removeAllHandlersForClient:self.client1];
    
    if (self.client2) {
        [self removeAllHandlersForClient:self.client2];
        [self.client2 removeListener:self];
    }
    
    [self.client1 removeListener:self];
    
    
    [super tearDown];
}


#pragma mark - Tests :: Add Action

- (void)testAddAction_ShouldAddAction_WhenCalled {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSString *expectedValue = [NSUUID UUID].UUIDString;
    NSString *expectedType = @"custom";
    
    
    NSArray<NSNumber *> *messageTimetokens = [self publishMessages:1 toChannel:expectedChannel];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.addMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(messageTimetokens[0])
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                PNMessageAction *action = status.data.action;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(action);
                XCTAssertEqualObjects(action.type, expectedType);
                XCTAssertEqualObjects(action.value, expectedValue);
                XCTAssertEqualObjects(action.uuid, self.client1.uuid);
                XCTAssertEqualObjects(action.messageTimetoken, messageTimetokens[0]);
                XCTAssertNotNil(action.actionTimetoken);
                
                handler();
            });
    }];
}

- (void)testAddAction_ShouldTriggerAddedEvent_WhenAddingAction {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSString *expectedValue = [NSUUID UUID].UUIDString;
    NSString *expectedType = @"custom";
    [self.client2 addListener:self];
    
    
    NSArray<NSNumber *> *messageTimetokens = [self publishMessages:1 toChannel:expectedChannel];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client2
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {

            if (status.category == PNConnectedCategory) {
                *remove = YES;
                
                handler();
            }
        }];
        
        self.client2.subscribe().channels(@[expectedChannel]).perform();
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addActionHandlerForClient:self.client2
                              withBlock:^(PubNub *client, PNMessageActionResult *event, BOOL *remove) {
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            PNMessageAction *action = event.data.action;
            XCTAssertNotNil(action);
            XCTAssertEqualObjects(action.type, expectedType);
            XCTAssertEqualObjects(action.value, expectedValue);
            XCTAssertEqualObjects(action.uuid, self.client1.uuid);
            XCTAssertEqualObjects(action.messageTimetoken, messageTimetokens[0]);
            XCTAssertNotNil(action.actionTimetoken);
            XCTAssertEqualObjects(event.data.event, @"added");
#pragma GCC diagnostic pop
                                         
            handler();
        }];
        
        self.client1.addMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(messageTimetokens[0])
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
}


#pragma mark - Tests :: Remove Action

- (void)testRemoveAction_ShouldRemoveAction_WhenCalled {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    
    
    NSArray<NSNumber *> *messageTimetokens = [self publishMessages:1 toChannel:expectedChannel];
    NSArray<NSNumber *> *actionTimetokens = [self addActions:1
                                                  toMessages:messageTimetokens
                                                   inChannel:expectedChannel];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMessageActions()
            .channel(expectedChannel)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                    XCTAssertFalse(status.isError);
                    XCTAssertEqual(result.data.actions.count, actionTimetokens.count);
                
                    handler();
                });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.removeMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(messageTimetokens[0])
            .actionTimetoken(actionTimetokens[0])
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                
                handler();
            });
    }];
    
    [self waitTask:@"actionDeletePropagation" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMessageActions()
            .channel(expectedChannel)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                    XCTAssertFalse(status.isError);
                    XCTAssertEqual(result.data.actions.count, 0);
                
                    handler();
                });
    }];
}

- (void)testRemoveAction_ShouldTriggerRemoveEvent_WhenRemovingAction {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    [self.client2 addListener:self];
    
    
    NSArray<NSNumber *> *messageTimetokens = [self publishMessages:1 toChannel:expectedChannel];
    NSArray<NSNumber *> *actionTimetokens = [self addActions:1
                                                  toMessages:messageTimetokens
                                                   inChannel:expectedChannel];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client2
                              withBlock:^(PubNub *client, PNSubscribeStatus *status, BOOL *remove) {

            if (status.category == PNConnectedCategory) {
                *remove = YES;
                
                handler();
            }
        }];
        
        self.client2.subscribe().channels(@[expectedChannel]).perform();
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addActionHandlerForClient:self.client2
                              withBlock:^(PubNub *client, PNMessageActionResult *event, BOOL *remove) {
            *remove = YES;
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            PNMessageAction *action = event.data.action;
            XCTAssertNotNil(action);
            XCTAssertEqualObjects(action.uuid, self.client1.uuid);
            XCTAssertEqualObjects(action.messageTimetoken, messageTimetokens[0]);
            XCTAssertNotNil(action.actionTimetoken);
            XCTAssertEqualObjects(event.data.event, @"removed");
#pragma GCC diagnostic pop
                                         
            handler();
        }];
        
        self.client1.removeMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(messageTimetokens[0])
            .actionTimetoken(actionTimetokens[0])
            .performWithCompletion(^(PNAcknowledgmentStatus *status) { });
    }];
}


#pragma mark - Tests :: Fetch Action

- (void)testFetchActions_ShouldFetchActions_WhenCalled {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    
    
    NSArray<NSNumber *> *messageTimetokens = [self publishMessages:2 toChannel:expectedChannel];
    NSArray<NSNumber *> *actionTimetokens = [self addActions:3
                                                  toMessages:messageTimetokens
                                                   inChannel:expectedChannel];
    NSNumber *firstPublishedActionTimetoken = actionTimetokens[0];
    NSNumber *lastPublishedActionTimetoken = actionTimetokens[actionTimetokens.count - 1];
    
    [self waitTask:@"actionsStore" completionFor:2.f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMessageActions()
            .channel(expectedChannel)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                NSArray<PNMessageAction *> *fetchedActions = result.data.actions;
                XCTAssertFalse(status.isError);
                NSNumber *firstFetchedActionTimetoken = fetchedActions[0].actionTimetoken;
                NSNumber *lastFetchedActionTimetoken = fetchedActions[fetchedActions.count - 1].actionTimetoken;
                
                XCTAssertEqual([firstFetchedActionTimetoken compare:firstPublishedActionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([lastFetchedActionTimetoken compare:lastPublishedActionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual(fetchedActions.count, actionTimetokens.count);
                XCTAssertEqual([result.data.start compare:firstPublishedActionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([result.data.end compare:lastPublishedActionTimetoken],
                               NSOrderedSame);
                
                
                handler();
            });
    }];
}

- (void)testFetchActions_ShouldFetchNextActionsPage_WhenCalledWithLimitAndStart {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    
    
    NSArray<NSNumber *> *messageTimetokens = [self publishMessages:2 toChannel:expectedChannel];
    NSArray<NSNumber *> *actionTimetokens = [self addActions:5
                                                  toMessages:messageTimetokens
                                                   inChannel:expectedChannel];
    NSNumber *firstPublishedActionTimetoken = actionTimetokens[0];
    NSNumber *lastPublishedActionTimetoken = actionTimetokens[actionTimetokens.count - 1];
    NSUInteger halfSize = (NSUInteger)(actionTimetokens.count * 0.5f);
    NSNumber *middlePublishedActionTimetoken = actionTimetokens[halfSize];
    NSNumber *middleMinusOnePublishedActionTimetoken = actionTimetokens[halfSize - 1];
    
    [self waitTask:@"actionsStore" completionFor:2.f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMessageActions()
            .channel(expectedChannel)
            .limit(halfSize)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                NSArray<PNMessageAction *> *fetchedActions = result.data.actions;
                XCTAssertFalse(status.isError);
                NSNumber *firstFetchedActionTimetoken = fetchedActions[0].actionTimetoken;
                NSNumber *lastFetchedActionTimetoken = fetchedActions[fetchedActions.count - 1].actionTimetoken;
                
                XCTAssertEqual([firstFetchedActionTimetoken compare:middlePublishedActionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([lastFetchedActionTimetoken compare:lastPublishedActionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual(fetchedActions.count, halfSize);
                XCTAssertEqual([result.data.start compare:middlePublishedActionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([result.data.end compare:lastPublishedActionTimetoken],
                               NSOrderedSame);
                
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client1.fetchMessageActions()
            .channel(expectedChannel)
            .start(middlePublishedActionTimetoken)
            .limit(halfSize)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                NSArray<PNMessageAction *> *fetchedActions = result.data.actions;
                XCTAssertFalse(status.isError);
                NSNumber *firstFetchedActionTimetoken = fetchedActions[0].actionTimetoken;
                NSNumber *lastFetchedActionTimetoken = fetchedActions[fetchedActions.count - 1].actionTimetoken;
                
                XCTAssertEqual([firstFetchedActionTimetoken compare:firstPublishedActionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([lastFetchedActionTimetoken compare:middleMinusOnePublishedActionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual(fetchedActions.count, halfSize);
                XCTAssertEqual([result.data.start compare:firstPublishedActionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([result.data.end compare:middleMinusOnePublishedActionTimetoken],
                               NSOrderedSame);
                
                handler();
            });
    }];
}


#pragma mark - Misc

- (NSArray<NSNumber *> *)publishMessages:(NSUInteger)messagesCount toChannel:(NSString *)channel {
    NSMutableArray *timetokens = [NSMutableArray new];
    
    for (NSUInteger messageIdx = 0; messageIdx < messagesCount; messageIdx++) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client1.publish()
                .message(@{
                    @"messageIdx": @(messageIdx),
                    @"time": @([NSDate date].timeIntervalSince1970)
                })
                .channel(channel)
                .performWithCompletion(^(PNPublishStatus *status) {
                    if (!status.isError) {
                        [timetokens addObject:status.data.timetoken];
                    } else {
                        NSLog(@"Publish did fail: %@", status.errorData.information);
                    }
                    
                    handler();
                });
        }];
    }
    
    return timetokens;
}

- (NSArray<NSNumber *> *)addActions:(NSUInteger)actionsCount
                         toMessages:(NSArray<NSNumber *> *)messages
                          inChannel:(NSString *)channel {
    NSArray<NSString *> *types = @[@"reaction", @"receipt", @"custom"];
    NSArray<NSString *> *values = @[
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString
    ];
    NSMutableArray *timetokens = [NSMutableArray new];
    
    for (NSUInteger messageIdx = 0; messageIdx < messages.count; messageIdx++) {
        NSNumber *messageTimetoken = messages[messageIdx];
        
        for (NSUInteger messageActionIdx = 0; messageActionIdx < actionsCount; messageActionIdx++) {
            [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
                self.client1.addMessageAction()
                    .channel(channel)
                    .messageTimetoken(messageTimetoken)
                    .type(types[(messageActionIdx + 1)%3])
                    .value(values[(messageActionIdx + 1)%10])
                    .performWithCompletion(^(PNAddMessageActionStatus *status) {
                        if (!status.isError) {
                            [timetokens addObject:status.data.action.actionTimetoken];
                        }
                        handler();
                    });
            }];
        }
    }
    
    return timetokens;
}

#pragma mark -


@end
