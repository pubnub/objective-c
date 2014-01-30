//
//  PNWriteBufferTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNWriteBuffer.h"
#import "PNMessagePostRequest.h"
#import "PNMessage+Protected.h"
#import "PNMessage.h"
#import "PNBaseRequest+Protected.h"


@interface PNWriteBufferTest : SenTestCase {
	PNMessagePostRequest *request;
	PNWriteBuffer *buffer;
}

@end

@implementation PNWriteBufferTest

- (void)setUp {
    [super setUp];
	request = [PNMessagePostRequest postMessageRequestWithMessage: [PNMessage messageWithObject: @"message" forChannel: nil error:nil]];
	buffer = [PNWriteBuffer writeBufferForRequest: request];
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

- (void)writeBufferForRequest {
	buffer = [PNWriteBuffer writeBufferForRequest: request];
    STAssertNotNil( buffer, @"");

	STAssertTrue( [buffer buffer] != nil, @"");

	STAssertTrue( [buffer bufferLength] != 0, @"");

	STAssertTrue( [buffer hasData] == YES, @"");

	STAssertTrue( [buffer bufferLength] == [[request HTTPPayload] length], @"");

	buffer.offset = 10;
	STAssertTrue( [buffer isPartialDataSent] == YES, @"");
	[buffer reset];
	STAssertTrue( buffer.sendingBytes == NO, @"");
	STAssertTrue( buffer.offset == 0, @"");
}

@end
