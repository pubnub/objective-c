/**
 * @brief Error / negative path tests for Files operations (Send, List, Download, Delete).
 *
 * @author PubNub Tests
 * @copyright (c) 2010-2026 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNDownloadFileRequest.h>
#import <PubNub/PNDeleteFileRequest.h>
#import <PubNub/PNListFilesRequest.h>
#import <PubNub/PNSendFileRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNFilesErrorTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNFilesErrorTest


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Send File :: Empty data

- (void)testItShouldReturnValidationErrorWhenSendFileWithEmptyData {
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"test-channel"
                                                              fileName:@"test.txt"
                                                                  data:[NSData data]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"empty"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenSendFileWithNilData {
    NSData *data = nil;
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"test-channel"
                                                              fileName:@"test.txt"
                                                                  data:data];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark - Tests :: Send File :: Invalid file URL

- (void)testItShouldReturnValidationErrorWhenSendFileWithNonExistentFileURL {
    NSURL *fakeURL = [NSURL fileURLWithPath:@"/tmp/nonexistent_file_for_pubnub_test.txt"];
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"test-channel" fileURL:fakeURL];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"file"].location, NSNotFound);
}


#pragma mark - Tests :: Send File :: Directory URL instead of file

- (void)testItShouldReturnValidationErrorWhenSendFileWithDirectoryURL {
    NSURL *dirURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"test-channel" fileURL:dirURL];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"directory"].location, NSNotFound);
}


#pragma mark - Tests :: List Files :: Missing channel

- (void)testItShouldReturnValidationErrorWhenListFilesChannelIsEmpty {
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channel"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenListFilesChannelIsNil {
    NSString *channel = nil;
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:channel];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channel"].location, NSNotFound);
}


#pragma mark - Tests :: List Files :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenListFilesChannelIsValid {
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@"test-channel"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Download File :: Missing identifier

- (void)testItShouldReturnValidationErrorWhenDownloadFileIdentifierIsEmpty {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"test-channel"
                                                                    identifier:@""
                                                                          name:@"test.txt"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"identifier"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenDownloadFileIdentifierIsNil {
    NSString *identifier = nil;
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"test-channel"
                                                                    identifier:identifier
                                                                          name:@"test.txt"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"identifier"].location, NSNotFound);
}


#pragma mark - Tests :: Download File :: Missing channel

- (void)testItShouldReturnValidationErrorWhenDownloadFileChannelIsEmpty {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@""
                                                                    identifier:@"file-id"
                                                                          name:@"test.txt"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channel"].location, NSNotFound);
}


#pragma mark - Tests :: Download File :: Missing name

- (void)testItShouldReturnValidationErrorWhenDownloadFileNameIsEmpty {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"test-channel"
                                                                    identifier:@"file-id"
                                                                          name:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"name"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenDownloadFileNameIsNil {
    NSString *name = nil;
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"test-channel"
                                                                    identifier:@"file-id"
                                                                          name:name];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"name"].location, NSNotFound);
}


#pragma mark - Tests :: Download File :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenDownloadFileParamsAreValid {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"test-channel"
                                                                    identifier:@"file-id"
                                                                          name:@"test.txt"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Delete File :: Missing identifier

- (void)testItShouldReturnValidationErrorWhenDeleteFileIdentifierIsEmpty {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"test-channel"
                                                                identifier:@""
                                                                      name:@"test.txt"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"identifier"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenDeleteFileIdentifierIsNil {
    NSString *identifier = nil;
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"test-channel"
                                                                identifier:identifier
                                                                      name:@"test.txt"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"identifier"].location, NSNotFound);
}


#pragma mark - Tests :: Delete File :: Missing channel

- (void)testItShouldReturnValidationErrorWhenDeleteFileChannelIsEmpty {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@""
                                                                identifier:@"file-id"
                                                                      name:@"test.txt"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channel"].location, NSNotFound);
}


#pragma mark - Tests :: Delete File :: Missing name

- (void)testItShouldReturnValidationErrorWhenDeleteFileNameIsEmpty {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"test-channel"
                                                                identifier:@"file-id"
                                                                      name:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"name"].location, NSNotFound);
}


#pragma mark - Tests :: Delete File :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenDeleteFileParamsAreValid {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"test-channel"
                                                                identifier:@"file-id"
                                                                      name:@"test.txt"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark -

@end
