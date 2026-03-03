/**
 * @brief Error / negative path tests for Message Actions operations.
 *
 * @author PubNub Tests
 * @copyright (c) 2010-2026 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNFetchMessageActionsRequest.h>
#import <PubNub/PNAddMessageActionRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNMessageActionsErrorTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMessageActionsErrorTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Add Message Action :: Non-serializable value

- (void)testItShouldNotAddMessageActionWhenValueIsNotSerializable {
    NSNumber *messageTimetoken = @([NSDate date].timeIntervalSince1970 * 1000);
    NSString *channel = [NSUUID UUID].UUIDString;
    NSString *nonSerializableValue = (id)[NSDate date];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:channel
                                                                          messageTimetoken:messageTimetoken];
        request.type = @"custom";
        request.value = nonSerializableValue;

        [self.client addMessageActionWithRequest:request completion:^(PNAddMessageActionStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"Message action"].location,
                              NSNotFound);

            handler();
        }];
    }];
}


#pragma mark - Tests :: Fetch Message Actions with request :: Missing channel

- (void)testItShouldReturnErrorWhenFetchMessageActionsWithRequestAndChannelIsNil {
    NSString *channel = nil;
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:channel];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client fetchMessageActionsWithRequest:request
                                         completion:^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
            XCTAssertNotNil(status);
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"channel"].location,
                              NSNotFound);

            handler();
        }];
    }];
}

- (void)testItShouldReturnErrorWhenFetchMessageActionsWithRequestAndChannelIsEmpty {
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@""];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client fetchMessageActionsWithRequest:request
                                         completion:^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
            XCTAssertNotNil(status);
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"channel"].location,
                              NSNotFound);

            handler();
        }];
    }];
}


#pragma mark - Tests :: Add Message Action with request :: Missing channel

- (void)testItShouldReturnErrorWhenAddMessageActionWithRequestAndChannelIsNil {
    NSString *channel = nil;
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:channel
                                                                      messageTimetoken:@(1234567890)];
    request.type = @"custom";
    request.value = @"smile";

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addMessageActionWithRequest:request completion:^(PNAddMessageActionStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"channel"].location,
                              NSNotFound);

            handler();
        }];
    }];
}


#pragma mark -

#pragma clang diagnostic pop

@end
