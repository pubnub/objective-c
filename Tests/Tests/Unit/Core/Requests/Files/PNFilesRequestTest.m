#import <XCTest/XCTest.h>
#import <PubNub/PNSendFileRequest.h>
#import <PubNub/PNListFilesRequest.h>
#import <PubNub/PNDownloadFileRequest.h>
#import <PubNub/PNDeleteFileRequest.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNFilesRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNFilesRequestTest


#pragma mark - PNSendFileRequest :: Construction (data)

- (void)testItShouldCreateSendFileRequestWhenChannelAndDataProvided {
    NSData *data = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"test-channel"
                                                              fileName:@"test.txt"
                                                                  data:data];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channel, @"test-channel");
    XCTAssertEqualObjects(request.filename, @"test.txt");
}

- (void)testItShouldHaveDefaultValuesWhenSendFileRequestCreated {
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"ch" fileName:@"f.txt" data:data];

    XCTAssertTrue(request.fileMessageStore, @"fileMessageStore should default to YES");
    XCTAssertEqual(request.fileMessageTTL, 0, @"fileMessageTTL should default to 0");
    XCTAssertNil(request.message, @"message should default to nil");
    XCTAssertNil(request.fileMessageMetadata, @"fileMessageMetadata should default to nil");
    XCTAssertNil(request.customMessageType, @"customMessageType should default to nil");
}

- (void)testItShouldIncludeArbitraryParametersInSendFileQuery {
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"ch" fileName:@"f.txt" data:data];
    request.arbitraryQueryParameters = @{ @"key": @"value" };

    XCTAssertEqualObjects(request.query[@"key"], @"value");
}

- (void)testItShouldPassValidationWhenValidDataProvided {
    NSData *data = [@"content" dataUsingEncoding:NSUTF8StringEncoding];
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"ch" fileName:@"f.txt" data:data];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenEmptyDataProvided {
    NSData *data = [NSData data];
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"ch" fileName:@"f.txt" data:data];

    XCTAssertNotNil([request validate], @"Validation should fail with empty data");
}


#pragma mark - PNSendFileRequest :: Construction (stream)

- (void)testItShouldCreateSendFileRequestWhenStreamProvided {
    NSData *data = [@"stream data" dataUsingEncoding:NSUTF8StringEncoding];
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"ch"
                                                              fileName:@"stream.bin"
                                                                stream:stream
                                                                  size:data.length];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channel, @"ch");
    XCTAssertEqualObjects(request.filename, @"stream.bin");
}

- (void)testItShouldFailValidationWhenStreamSizeIsZero {
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"ch"
                                                              fileName:@"empty.bin"
                                                                stream:stream
                                                                  size:0];

    XCTAssertNotNil([request validate], @"Validation should fail with zero size stream");
}


#pragma mark - PNListFilesRequest :: Construction

- (void)testItShouldCreateListFilesRequestWhenChannelProvided {
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@"test-channel"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channel, @"test-channel");
}

- (void)testItShouldHaveDefaultValuesWhenListFilesCreated {
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@"ch"];

    XCTAssertNil(request.next, @"next should default to nil");
}


#pragma mark - PNListFilesRequest :: Query parameters

- (void)testItShouldIncludeLimitInListFilesQuery {
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@"ch"];
    request.limit = 50;

    XCTAssertEqualObjects(request.query[@"limit"], @(50).stringValue);
}

- (void)testItShouldIncludeNextCursorInListFilesQuery {
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@"ch"];
    request.next = @"next-page-cursor";

    XCTAssertNotNil(request.query[@"next"]);
}

- (void)testItShouldIncludeArbitraryParametersInListFilesQuery {
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@"ch"];
    request.arbitraryQueryParameters = @{ @"custom": @"param" };

    XCTAssertEqualObjects(request.query[@"custom"], @"param");
}


#pragma mark - PNListFilesRequest :: Validation

- (void)testItShouldPassValidationWhenListFilesChannelProvided {
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@"ch"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenListFilesChannelIsEmpty {
    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel");
}


#pragma mark - PNDownloadFileRequest :: Construction

- (void)testItShouldCreateDownloadFileRequestWhenAllParamsProvided {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"ch"
                                                                   identifier:@"file-id-123"
                                                                         name:@"photo.jpg"];

    XCTAssertNotNil(request);
}

- (void)testItShouldHaveDefaultValuesWhenDownloadFileCreated {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"ch"
                                                                   identifier:@"id"
                                                                         name:@"file.txt"];

    XCTAssertNil(request.targetURL, @"targetURL should default to nil");
    XCTAssertNil(request.cipherKey, @"cipherKey should default to nil");
}


#pragma mark - PNDownloadFileRequest :: Validation

- (void)testItShouldPassValidationWhenAllDownloadParamsProvided {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"ch"
                                                                   identifier:@"file-id"
                                                                         name:@"file.txt"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenDownloadChannelIsEmpty {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@""
                                                                   identifier:@"file-id"
                                                                         name:@"file.txt"];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel");
}

- (void)testItShouldFailValidationWhenDownloadIdentifierIsEmpty {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"ch"
                                                                   identifier:@""
                                                                         name:@"file.txt"];

    XCTAssertNotNil([request validate], @"Validation should fail with empty identifier");
}

- (void)testItShouldFailValidationWhenDownloadNameIsEmpty {
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"ch"
                                                                   identifier:@"file-id"
                                                                         name:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty name");
}


#pragma mark - PNDeleteFileRequest :: Construction

- (void)testItShouldCreateDeleteFileRequestWhenAllParamsProvided {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"ch"
                                                               identifier:@"file-id-123"
                                                                     name:@"photo.jpg"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.identifier, @"file-id-123");
}

- (void)testItShouldIncludeArbitraryParametersInDeleteFileQuery {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"ch"
                                                               identifier:@"id"
                                                                     name:@"file.txt"];
    request.arbitraryQueryParameters = @{ @"key": @"value" };

    XCTAssertEqualObjects(request.query[@"key"], @"value");
}


#pragma mark - PNDeleteFileRequest :: Validation

- (void)testItShouldPassValidationWhenAllDeleteParamsProvided {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"ch"
                                                               identifier:@"file-id"
                                                                     name:@"file.txt"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenDeleteChannelIsEmpty {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@""
                                                               identifier:@"file-id"
                                                                     name:@"file.txt"];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel");
}

- (void)testItShouldFailValidationWhenDeleteIdentifierIsEmpty {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"ch"
                                                               identifier:@""
                                                                     name:@"file.txt"];

    XCTAssertNotNil([request validate], @"Validation should fail with empty identifier");
}

- (void)testItShouldFailValidationWhenDeleteNameIsEmpty {
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"ch"
                                                               identifier:@"file-id"
                                                                     name:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty name");
}


#pragma mark -

@end
