/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import "NSString+PNTest.h"


#pragma mark Interface declaration

@interface PNMessageActionsIntegrationTest : PNRecordableTestCase


#pragma mark - Information

#pragma mark -


@end


#pragma mark - Tests

@implementation PNMessageActionsIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
}


#pragma mark - Tests :: Builder pattern-based add action

- (void)testItShouldAddActionAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *expectedValue = [self randomizedValuesWithValues:@[@"test-value"]].firstObject;
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 1;
    NSString *expectedType = @"custom";
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(channel)
            .messageTimetoken(timetokens.firstObject)
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                PNMessageAction *action = status.data.action;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(action);
                XCTAssertEqualObjects(action.type, expectedType);
                XCTAssertEqualObjects(action.value, expectedValue);
                XCTAssertEqualObjects(action.uuid, self.client.userID);
                XCTAssertEqualObjects(action.messageTimetoken, timetokens[0]);
                XCTAssertNotNil(action.actionTimetoken);
                XCTAssertNotEqual([action.debugDescription rangeOfString:@"actionTimetoken"].location, NSNotFound);
                XCTAssertEqual(status.operation, PNAddMessageActionOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldAddActionAndNotCrashWhenCompletionBlockIsNil {
    NSString *expectedValue = [self randomizedValuesWithValues:@[@"test-value"]].firstObject;
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 1;
    NSString *expectedType = @"custom";
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.addMessageAction()
                .channel(channel)
                .messageTimetoken(timetokens.firstObject)
                .type(expectedType)
                .value(expectedValue)
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldAddActionAndTriggerAddedEvent {
    NSString *expectedValue = [self randomizedValuesWithValues:@[@"test-value"]].firstObject;
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSUInteger expectedMessagesCount = 1;
    NSString *expectedType = @"custom";
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:client1];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addActionHandlerForClient:client2
                              withBlock:^(PubNub *client, PNMessageActionResult *event, BOOL *remove) {
            
            *remove = YES;
            PNMessageAction *action = event.data.action;
            XCTAssertNotNil(action);
            XCTAssertEqualObjects(action.type, expectedType);
            XCTAssertEqualObjects(action.value, expectedValue);
            XCTAssertEqualObjects(action.uuid, client1.userID);
            XCTAssertEqualObjects(action.messageTimetoken, timetokens.firstObject);
            XCTAssertNotNil(action.actionTimetoken);
            XCTAssertEqualObjects(event.data.event, @"added");
            
            handler();
        }];
        
        client1.addMessageAction()
            .channel(channel)
            .messageTimetoken(timetokens.firstObject)
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    [self deleteHistoryForChannel:channel usingClient:client1];
}

- (void)testItShouldNotAddActionAndReceiveBadRequestStatusWhenChannelIsNil {
    NSString *expectedValue = [self randomizedValuesWithValues:@[@"test-value"]].firstObject;
    NSString *expectedType = @"custom";
    NSNumber *timetoken = @1577918412;
    __block BOOL retried = NO;
    NSString *channel = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(channel)
            .messageTimetoken(timetoken)
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"'channel'"]);
                XCTAssertEqual(status.operation, PNAddMessageActionOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
            });
    }];
}

- (void)testItShouldNotAddActionAndReceiveBadRequestStatusWhenTimetokenIsNil {
    NSString *expectedValue = [self randomizedValuesWithValues:@[@"test-value"]].firstObject;
    NSString *channel = [self channelWithName:@"test-channel"];
    NSString *expectedType = @"custom";
    NSNumber *timetoken = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(channel)
            .messageTimetoken(timetoken)
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"'messageTimetoken'"]);
                XCTAssertEqual(status.operation, PNAddMessageActionOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                handler();
            });
    }];
}

- (void)testItShouldNotAddActionAndReceiveBadRequestStatusWhenTypeIsNil {
    NSString *expectedValue = [self randomizedValuesWithValues:@[@"test-value"]].firstObject;
    NSString *channel = [self channelWithName:@"test-channel"];
    NSNumber *timetoken = @1577918412;
    NSString *expectedType = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(channel)
            .messageTimetoken(timetoken)
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"'type'"]);
                XCTAssertEqual(status.operation, PNAddMessageActionOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                handler();
            });
    }];
}

- (void)testItShouldNotAddActionAndReceiveBadRequestStatusWhenTypeIsTooLong {
    NSString *expectedValue = [self randomizedValuesWithValues:@[@"test-value"]].firstObject;
    NSString *channel = [self channelWithName:@"test-channel"];
    NSString *expectedType = [NSUUID UUID].UUIDString;
    NSNumber *timetoken = @1577918412;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(channel)
            .messageTimetoken(timetoken)
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"too long"]);
                XCTAssertEqual(status.operation, PNAddMessageActionOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                handler();
            });
    }];
}

- (void)testItShouldNotAddActionAndReceiveBadRequestStatusWhenValueIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSString *expectedType = @"custom";
    NSNumber *timetoken = @1577918412;
    NSString *expectedValue = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(channel)
            .messageTimetoken(timetoken)
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"'value'"]);
                XCTAssertEqual(status.operation, PNAddMessageActionOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                handler();
            });
    }];
}

- (void)testItShouldNotAddActionAndReceiveBadRequestStatusWhenValueIsNotJSONSerializable {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSString *expectedValue = (id)[NSDate date];
    NSString *expectedType = @"custom";
    NSNumber *timetoken = @1577918412;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(channel)
            .messageTimetoken(timetoken)
            .type(expectedType)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"'value'"]);
                XCTAssertEqual(status.operation, PNAddMessageActionOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Builder pattern-based add action

- (void)testItShouldRemoveActionAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 1;
    NSUInteger expectedActionsCount = 1;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    NSArray<PNMessageAction *> *actions = [self addActions:expectedActionsCount
                                                toMessages:timetokens
                                                 inChannel:channel
                                               usingClient:nil];
    
    [self verifyMessageActionsCountInChannel:channel shouldEqualTo:actions.count usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.removeMessageAction()
            .channel(channel)
            .messageTimetoken(timetokens.firstObject)
            .actionTimetoken(actions.firstObject.actionTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNRemoveMessageActionOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    
    [self verifyMessageActionsCountInChannel:channel shouldEqualTo:0 usingClient:nil];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldRemoveActionAndNotCrashWhenCompletionBlockIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 1;
    NSUInteger expectedActionsCount = 1;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    NSArray<PNMessageAction *> *actions = [self addActions:expectedActionsCount
                                                toMessages:timetokens
                                                 inChannel:channel
                                               usingClient:nil];
    
    [self verifyMessageActionsCountInChannel:channel shouldEqualTo:actions.count usingClient:nil];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.removeMessageAction()
                .channel(channel)
                .messageTimetoken(timetokens.firstObject)
                .actionTimetoken(actions.firstObject.actionTimetoken)
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    
    [self verifyMessageActionsCountInChannel:channel shouldEqualTo:0 usingClient:nil];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldRemoveActionAndTriggerRemovingEvent {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSUInteger expectedMessagesCount = 1;
    NSUInteger expectedActionsCount = 1;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:client1];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    NSArray<PNMessageAction *> *actions = [self addActions:expectedActionsCount
                                                toMessages:timetokens
                                                 inChannel:channel
                                               usingClient:client1];
    
    [self verifyMessageActionsCountInChannel:channel shouldEqualTo:actions.count usingClient:client1];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addActionHandlerForClient:client2
                              withBlock:^(PubNub *client, PNMessageActionResult *event, BOOL *remove) {
            
            *remove = YES;
            PNMessageAction *action = event.data.action;
            XCTAssertNotNil(action);
            XCTAssertEqualObjects(action.uuid, client1.userID);
            XCTAssertEqualObjects(action.messageTimetoken, timetokens.firstObject);
            XCTAssertNotNil(action.actionTimetoken);
            XCTAssertEqualObjects(event.data.event, @"removed");
            
            handler();
        }];
        
        client1.removeMessageAction()
            .channel(channel)
            .messageTimetoken(timetokens.firstObject)
            .actionTimetoken(actions.firstObject.actionTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
    
    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
    
    
    [self verifyMessageActionsCountInChannel:channel shouldEqualTo:0 usingClient:client1];
    
    [self deleteHistoryForChannel:channel usingClient:client1];
}

- (void)testItShouldNotRemoveActionAndReceiveBadRequestStatusWhenChannelIsNil {
    NSNumber *messageTimetoken = @1577918412;
    NSNumber *actionTimetoken = @1577918414;
    __block BOOL retried = NO;
    NSString *channel = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.removeMessageAction()
            .channel(channel)
            .messageTimetoken(messageTimetoken)
            .actionTimetoken(actionTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"'channel'"]);
                XCTAssertEqual(status.operation, PNRemoveMessageActionOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
            });
    }];
}

- (void)testItShouldNotRemoveActionAndReceiveBadRequestStatusWhenMessageTimetokenIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSNumber *actionTimetoken = @1577918414;
    NSNumber *messageTimetoken = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.removeMessageAction()
            .channel(channel)
            .messageTimetoken(messageTimetoken)
            .actionTimetoken(actionTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"'messageTimetoken'"]);
                XCTAssertEqual(status.operation, PNRemoveMessageActionOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                handler();
            });
    }];
}

- (void)testItShouldNotRemoveActionAndReceiveBadRequestStatusWhenActionTimetokenIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSNumber *messageTimetoken = @1577918412;
    NSNumber *actionTimetoken = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.removeMessageAction()
            .channel(channel)
            .messageTimetoken(messageTimetoken)
            .actionTimetoken(actionTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"'actionTimetoken'"]);
                XCTAssertEqual(status.operation, PNRemoveMessageActionOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Builder pattern-based fetch action

- (void)testItShouldFetchActionAndReceiveResultWithExpectedOperation {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 2;
    NSUInteger expectedActionsCount = 3;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    NSArray<PNMessageAction *> *publishedActions = [self addActions:expectedActionsCount
                                                         toMessages:timetokens
                                                          inChannel:channel
                                                        usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMessageActions()
            .channel(channel)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                NSArray<PNMessageAction *> *fetchedActions = result.data.actions;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedActions);
                XCTAssertEqual([fetchedActions.firstObject.actionTimetoken
                                compare:publishedActions.firstObject.actionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([fetchedActions.lastObject.actionTimetoken
                                compare:publishedActions.lastObject.actionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual(fetchedActions.count, publishedActions.count);
                XCTAssertEqual([result.data.start compare:publishedActions.firstObject.actionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([result.data.end compare:publishedActions.lastObject.actionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual(result.operation, PNFetchMessagesActionsOperation);
                
                handler();
            });
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldFetchNextActionsPageWhenCalledWithLimitAndStart {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSUInteger expectedMessagesCount = 2;
    NSUInteger expectedActionsCount = 5;
    
    NSArray<NSDictionary *> *publishedMessages = [self publishMessages:expectedMessagesCount
                                                             toChannel:channel
                                                           usingClient:nil];
    NSArray<NSNumber *> *timetokens = [publishedMessages valueForKey:@"timetoken"];
    NSArray<PNMessageAction *> *actions = [self addActions:expectedActionsCount
                                                toMessages:timetokens
                                                 inChannel:channel
                                               usingClient:nil];
    NSUInteger halfSize = (NSUInteger)(actions.count * 0.5f);
    NSNumber *middleMinusOneTimetoken = actions[halfSize - 1].actionTimetoken;
    NSNumber *middleTimetoken = actions[halfSize].actionTimetoken;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMessageActions()
            .channel(channel)
            .limit(halfSize)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                NSArray<PNMessageAction *> *fetchedActions = result.data.actions;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedActions);
                
                XCTAssertEqual([fetchedActions.firstObject.actionTimetoken compare:middleTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([fetchedActions.lastObject.actionTimetoken 
                                compare:actions.lastObject.actionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual(fetchedActions.count, halfSize);
                XCTAssertEqual([result.data.start compare:middleTimetoken], NSOrderedSame);
                XCTAssertEqual([result.data.end compare:actions.lastObject.actionTimetoken],
                               NSOrderedSame);
                
                handler();
            });
    }];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMessageActions()
            .channel(channel)
            .start(middleTimetoken)
            .limit(halfSize)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                NSArray<PNMessageAction *> *fetchedActions = result.data.actions;
                XCTAssertNil(status);
                XCTAssertNotNil(fetchedActions);
                
                XCTAssertEqual([fetchedActions.firstObject.actionTimetoken
                                compare:actions.firstObject.actionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([fetchedActions.lastObject.actionTimetoken compare:middleMinusOneTimetoken],
                               NSOrderedSame);
                XCTAssertEqual(fetchedActions.count, halfSize);
                XCTAssertEqual([result.data.start compare:actions.firstObject.actionTimetoken],
                               NSOrderedSame);
                XCTAssertEqual([result.data.end compare:middleMinusOneTimetoken], NSOrderedSame);
                
                handler();
            });
    }];
    
    [self deleteHistoryForChannel:channel usingClient:nil];
}

- (void)testItShouldNotFetchActionAndReceiveBadRequestStatusWhenChannelIsNil {
    __block BOOL retried = NO;
    NSString *channel = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMessageActions()
            .channel(channel)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                NSString *errorInformation = status.errorData.information;
                XCTAssertTrue(status.isError);
                XCTAssertNotNil(errorInformation);
                XCTAssertTrue([errorInformation pnt_includesString:@"'channel'"]);
                XCTAssertEqual(status.operation, PNFetchMessagesActionsOperation);
                XCTAssertEqual(status.category, PNBadRequestCategory);
                
                if (!retried) {
                    retried = YES;
                    [status retry];
                } else {
                    handler();
                }
            });
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
