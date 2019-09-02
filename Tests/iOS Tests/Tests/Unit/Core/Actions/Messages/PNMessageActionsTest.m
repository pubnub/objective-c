/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PNRequestParameters.h>
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>
#import "PNTestCase.h"


#pragma mark Test interface declaration

@interface PNMessageActionsTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNMessageActionsTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}


#pragma mark - Tests :: Add Message Action

- (void)testAddMessageAction_ShouldReturnBuilder {
    XCTAssertTrue([self.client.addMessageAction() isKindOfClass:[PNAddMessageActionAPICallBuilder class]]);
}


#pragma mark - Tests :: Add Message Action :: Call

- (void)testAddMessageAction_ShouldProcessOperation_WhenCalled {
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSString *expectedValue = [NSUUID UUID].UUIDString;
    NSDictionary *expectedBody = @{ @"type": @"custom", @"value": expectedValue };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNAddMessageActionOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{channel}"], expectedChannel);
            XCTAssertEqualObjects(parameters.pathComponents[@"{message-timetoken}"],
                                  expectedMessageTimetoken.stringValue);
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.addMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(expectedMessageTimetoken)
            .type(@"custom")
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {});
    }];
}

- (void)testAddMessageAction_ShouldReturnError_WhenChannelIsMissing {
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedValue = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .messageTimetoken(expectedMessageTimetoken)
            .type(@"custom")
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'channel'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testAddMessageAction_ShouldReturnError_WhenMessageTimetokenIsMissing {
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSString *expectedValue = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(expectedChannel)
            .type(@"custom")
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'messageTimetoken'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testAddMessageAction_ShouldReturnError_WhenValueIsMissing {
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(expectedMessageTimetoken)
            .type(@"custom")
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'value'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testAddMessageAction_ShouldReturnError_WhenActionTypeNotSet {
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSString *expectedValue = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(expectedMessageTimetoken)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'type'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testAddMessageAction_ShouldReturnError_WhenActionTypeTooLong {
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSString *expectedValue = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.addMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(expectedMessageTimetoken)
            .type([NSUUID UUID].UUIDString)
            .value(expectedValue)
            .performWithCompletion(^(PNAddMessageActionStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"too long"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testAddMessageAction_ShouldReturnError_WhenUnableToSerializeValue {
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSString *expectedValue = (id)[NSDate date];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:expectedChannel
                                                                          messageTimetoken:expectedMessageTimetoken];
        request.type = @"custom";
        request.value = expectedValue;
        
        [self.client addMessageActionWithRequest:request completion:^(PNAddMessageActionStatus *status) {
#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            XCTAssertTrue(status.isError);
#pragma GCC diagnostic pop
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"Message action"].location,
                              NSNotFound);
            
            handler();
        }];
    }];
}


#pragma mark - Tests :: Remove Message Action

- (void)testRemoveMessageAction_ShouldReturnBuilder {
    XCTAssertTrue([self.client.removeMessageAction() isKindOfClass:[PNRemoveMessageActionAPICallBuilder class]]);
}


#pragma mark - Tests :: Remove Message Action :: Call

- (void)testRemoveMessageAction_ShouldProcessOperation_WhenCalled {
    NSNumber *expectedActionTimetoken = @([NSDate date].timeIntervalSince1970 * 1000 + 1);
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNRemoveMessageActionOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{channel}"], expectedChannel);
            XCTAssertEqualObjects(parameters.pathComponents[@"{message-timetoken}"],
                                  expectedMessageTimetoken.stringValue);
            XCTAssertEqualObjects(parameters.pathComponents[@"{action-timetoken}"],
                                  expectedActionTimetoken.stringValue);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.removeMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(expectedMessageTimetoken)
            .actionTimetoken(expectedActionTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}

- (void)testRemoveMessageAction_ShouldReturnError_WhenChannelIsMissing {
    NSNumber *expectedActionTimetoken = @([NSDate date].timeIntervalSince1970 * 1000 + 1);
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.removeMessageAction()
            .messageTimetoken(expectedMessageTimetoken)
            .actionTimetoken(expectedActionTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'channel'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testRemoveMessageAction_ShouldReturnError_WhenMessageTimetokenIsMissing {
    NSNumber *expectedActionTimetoken = @([NSDate date].timeIntervalSince1970 * 1000 + 1);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.removeMessageAction()
            .channel(expectedChannel)
            .actionTimetoken(expectedActionTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'messageTimetoken'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testRemoveMessageAction_ShouldReturnError_WhenActionTimetokenIsMissing {
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.removeMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(expectedMessageTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'actionTimetoken'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch Messages Actions

- (void)testFetchMessagesActions_ShouldReturnBuilder {
    XCTAssertTrue([self.client.fetchMessageActions() isKindOfClass:[PNFetchMessagesActionsAPICallBuilder class]]);
}


#pragma mark - Tests :: Fetch Messages Actions

- (void)testFetchMessagesActions_ShouldProcessOperation_WhenCalled {
    NSNumber *expectedStart = @([NSDate date].timeIntervalSince1970 * 1000 + 1);
    NSNumber *expectedEnd = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchMessagesActionsOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertEqualObjects(parameters.query[@"start"], expectedStart.stringValue);
            XCTAssertEqualObjects(parameters.query[@"end"], expectedEnd.stringValue);
            XCTAssertEqualObjects(parameters.query[@"limit"], expectedLimit.stringValue);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchMessageActions()
            .channel(expectedChannel)
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testFetchMessagesActions_ShouldReturnError_WhenChannelIsMissing {
    NSNumber *expectedStart = @([NSDate date].timeIntervalSince1970 * 1000 + 1);
    NSNumber *expectedEnd = @([NSDate date].timeIntervalSince1970 * 1000);
    NSNumber *expectedLimit = @(56);
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMessageActions()
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'channel'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

#pragma mark -


@end
