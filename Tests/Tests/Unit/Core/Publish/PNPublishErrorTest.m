/**
 * @brief Error / negative path tests for Publish, Signal, and Fire operations.
 *
 * @author PubNub Tests
 * @copyright (c) 2010-2026 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNBasePublishRequest+Private.h>
#import <PubNub/PNPublishRequest.h>
#import <PubNub/PNSignalRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNPublishErrorTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNPublishErrorTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Publish :: Missing channel

- (void)testItShouldReturnValidationErrorWhenPublishRequestChannelIsEmpty {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@""];
    request.message = @"Hello";

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channel"].location, NSNotFound);
}


#pragma mark - Tests :: Publish :: Missing message

- (void)testItShouldReturnValidationErrorWhenPublishRequestMessageIsNil {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"test-channel"];
    // message is nil by default

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"message"].location, NSNotFound);
}


#pragma mark - Tests :: Publish :: Non-serializable message

- (void)testItShouldReturnValidationErrorWhenPublishMessageIsNotSerializable {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"test-channel"];
    request.message = (id)[NSDate date];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark - Tests :: Signal :: Validate request

- (void)testItShouldReturnValidationErrorWhenSignalMessageIsNil {
    id signal = nil;
    PNSignalRequest *request = [PNSignalRequest requestWithChannel:@"test-channel" signal:signal];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"message"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenSignalMessageIsNotSerializable {
    PNSignalRequest *request = [PNSignalRequest requestWithChannel:@"test-channel" signal:(id)[NSDate date]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark - Tests :: Publish :: Non-serializable metadata

- (void)testItShouldReturnValidationErrorWhenPublishMetadataIsNotSerializable {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"test-channel"];
    request.message = @"Hello";
    request.metadata = @{ @"date": [NSDate date] };

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark - Tests :: Publish with request :: Missing channel

- (void)testItShouldReturnErrorWhenPublishWithRequestAndChannelIsEmpty {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@""];
    request.message = @"Hello";

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"channel"].location,
                              NSNotFound);

            handler();
        }];
    }];
}


#pragma mark - Tests :: Publish with request :: Missing message

- (void)testItShouldReturnErrorWhenPublishWithRequestAndMessageIsNil {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"test-channel"];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"message"].location,
                              NSNotFound);

            handler();
        }];
    }];
}


#pragma mark - Tests :: Signal with request :: Nil message

- (void)testItShouldReturnErrorWhenSendSignalWithRequestAndMessageIsNil {
    id signal = nil;
    PNSignalRequest *request = [PNSignalRequest requestWithChannel:@"test-channel" signal:signal];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client sendSignalWithRequest:request completion:^(PNSignalStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"message"].location,
                              NSNotFound);

            handler();
        }];
    }];
}


#pragma mark -

#pragma clang diagnostic pop

@end
