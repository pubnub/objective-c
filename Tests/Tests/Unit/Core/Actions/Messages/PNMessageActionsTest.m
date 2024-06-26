/**
 * @author Serhii Mamontov
 * @copyright © 2010-2022 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNRemoveMessageActionRequest+Private.h>
#import <PubNub/PNBaseMessageActionRequest+Private.h>
#import <PubNub/PNFetchMessageActionsRequest.h>
#import <PubNub/PNAddMessageActionRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNMessageActionsTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMessageActionsTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Add Message Action

- (void)testItShouldReturnAddMessageActionBuilder {
    XCTAssertTrue([self.client.addMessageAction() isKindOfClass:[PNAddMessageActionAPICallBuilder class]]);
}


#pragma mark - Tests :: Add Message Action :: Call

- (void)testItShouldAddMessageActionWhenCalled {
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSString *expectedValue = [NSUUID UUID].UUIDString;
    NSDictionary *expectedBody = @{ @"type": @"custom", @"value": expectedValue };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNAddMessageActionRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNAddMessageActionRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNil([request validate]);
            XCTAssertEqualObjects(request.channel, expectedChannel);
            XCTAssertEqualObjects(request.messageTimetoken, expectedMessageTimetoken);
            XCTAssertEqualObjects(request.body, expectedPayload);
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

- (void)testItShouldNotAddMessageActionWhenChannelIsMissing {
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

- (void)testItShouldNotAddMessageActionWhenMessageTimetokenIsMissing {
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

- (void)testItShouldNotAddMessageActionWhenValueIsMissing {
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

- (void)testItShouldNotAddMessageActionWhenActionTypeNotSet {
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

- (void)testItShouldNotAddMessageActionWhenActionTypeTooLong {
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

- (void)testItShouldNotAddMessageActionWhenUnableToSerializeValue {
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

- (void)testItShouldReturnRemoveMessageActionBuilder {
    XCTAssertTrue([self.client.removeMessageAction() isKindOfClass:[PNRemoveMessageActionAPICallBuilder class]]);
}


#pragma mark - Tests :: Remove Message Action :: Call

- (void)testItShouldRemoveMessageActionWhenCalled {
    NSNumber *expectedActionTimetoken = @([NSDate date].timeIntervalSince1970 * 1000 + 1);
    NSNumber *expectedMessageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNRemoveMessageActionRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRemoveMessageActionRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.channel, expectedChannel);
            XCTAssertEqualObjects(request.messageTimetoken, expectedMessageTimetoken);
            XCTAssertEqualObjects(request.messageActionTimetoken, expectedActionTimetoken);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.removeMessageAction()
            .channel(expectedChannel)
            .messageTimetoken(expectedMessageTimetoken)
            .actionTimetoken(expectedActionTimetoken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}

- (void)testItShouldNotRemoveMessageActionWhenChannelIsMissing {
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

- (void)testItShouldNotRemoveMessageActionWhenMessageTimetokenIsMissing {
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

- (void)testItShouldNotRemoveMessageActionWhenActionTimetokenIsMissing {
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

- (void)testItShouldReturnFetchMessagesActionsBuilder {
    XCTAssertTrue([self.client.fetchMessageActions() isKindOfClass:[PNFetchMessagesActionsAPICallBuilder class]]);
}


#pragma mark - Tests :: Fetch Messages Actions

- (void)testItShouldFetchMessagesActionsWhenCalled {
    NSNumber *expectedStart = @([NSDate date].timeIntervalSince1970 * 1000 + 1);
    NSNumber *expectedEnd = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchMessageActionsRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchMessageActionsRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.start, expectedStart);
            XCTAssertEqualObjects(request.end, expectedEnd);
            XCTAssertEqual(request.limit, expectedLimit.unsignedIntegerValue);
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

- (void)testItShouldNotFetchMessagesActionsWhenChannelIsMissing {
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

#pragma clang diagnostic pop

@end
