//
//  PNWriteBufferTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNWriteBuffer.h"
#import "PNMessagePostRequest.h"
#import "PNMessage+Protected.h"
#import "PNMessage.h"
#import "PNBaseRequest+Protected.h"


@interface PNWriteBufferTest : XCTestCase {
	PNMessagePostRequest *request;
	PNWriteBuffer *buffer;
}

@end

@implementation PNWriteBufferTest

- (void)setUp {
    [super setUp];
    
	request = [PNMessagePostRequest postMessageRequestWithMessage: [PNMessage messageWithObject: @"message" forChannel: nil compressed: NO  storeInHistory:NO error:nil]];
	buffer = [PNWriteBuffer writeBufferForRequest: request];
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
    
    
}

- (void)testWriteBufferForRequest {
	buffer = [PNWriteBuffer writeBufferForRequest: request];
    XCTAssertNotNil( buffer, @"");

	XCTAssertTrue( [buffer buffer] != nil, @"");

	XCTAssertTrue( [buffer bufferLength] != 0, @"");

	XCTAssertTrue( [buffer hasData] == YES, @"");

	XCTAssertTrue( [buffer bufferLength] == [[request HTTPPayload] length], @"");

	buffer.offset = 10;
	XCTAssertTrue( [buffer isPartialDataSent] == YES, @"");
	[buffer reset];
	XCTAssertTrue( buffer.sendingBytes == NO, @"");
	XCTAssertTrue( buffer.offset == 0, @"");
}

@end
