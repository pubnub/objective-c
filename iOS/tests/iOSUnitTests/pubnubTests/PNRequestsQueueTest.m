//
//  PNRequestsQueueTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNRequestsQueue.h"
#import "PNBaseRequest.h"
#import "PNTimeTokenRequest.h"
#import "PNWriteBuffer.h"

@interface PNRequestsQueue (test)
@property (nonatomic, strong) NSMutableArray *query;
- (PNBaseRequest *)dequeRequestWithIdentifier:(NSString *)requestIdentifier;
- (NSString *)nextRequestIdentifier;
@end

@interface PNRequestsQueueTest : SenTestCase

@end

@implementation PNRequestsQueueTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInit {
	PNRequestsQueue *queue = [[PNRequestsQueue alloc] init];
	STAssertTrue( [queue.query isKindOfClass: [NSMutableArray class]], @"");
	STAssertTrue( queue != nil, @"");
	STAssertTrue( queue.query == [queue requestsQueue], @"");
}

-(void)testEnqueueRequest {
	PNBaseRequest *request1 = [[PNBaseRequest alloc] init];
	request1.identifier = @"id1";
	PNBaseRequest *request2 = [[PNBaseRequest alloc] init];
	request2.identifier = @"id2";

	PNRequestsQueue *queue = [[PNRequestsQueue alloc] init];
	STAssertTrue( [queue enqueueRequest: request2] == YES, @"");
	STAssertTrue( [queue enqueueRequest: request1] == YES, @"");
	STAssertTrue( [queue enqueueRequest: request1] == NO, @"");
	STAssertTrue( queue.query.count == 2, @"");
	STAssertTrue( queue.query[1] == request1, @"");
}

-(void)testEnqueueRequestOutOfOrder {
	PNBaseRequest *request1 = [[PNBaseRequest alloc] init];
	request1.identifier = @"id1";
	PNBaseRequest *request2 = [[PNBaseRequest alloc] init];
	request2.identifier = @"id2";

	PNRequestsQueue *queue = [[PNRequestsQueue alloc] init];
	STAssertTrue( [queue enqueueRequest: request2] == YES, @"");
	STAssertTrue( [queue enqueueRequest: request1 outOfOrder: NO] == YES, @"");
	STAssertTrue( queue.query.count == 2, @"");
	STAssertTrue( queue.query[1] == request1, @"");

	[queue removeRequest: request1];
	STAssertTrue( [queue enqueueRequest: request1 outOfOrder: YES] == YES, @"");
	STAssertTrue( queue.query.count == 2, @"");
	STAssertTrue( queue.query[0] == request1, @"");


	STAssertTrue( [queue dequeRequestWithIdentifier: @"id1"] == request1, @"");
	[queue removeRequest: request1];
	STAssertTrue( queue.query.count == 1, @"");
	STAssertTrue( [queue dequeRequestWithIdentifier: @"id1"] == nil, @"");

	[queue removeAllRequests];
	STAssertTrue( queue.query.count == 0, @"");
	[queue enqueueRequest: request2];
	request1.processing = YES;
	[queue enqueueRequest: request1];
	[queue removeAllRequests];

}

-(void)testNextRequestIdentifier {
	PNBaseRequest *request1 = [[PNBaseRequest alloc] init];
	request1.identifier = @"id1";
	PNBaseRequest *request2 = [[PNBaseRequest alloc] init];
	request2.identifier = @"id2";

	PNRequestsQueue *queue = [[PNRequestsQueue alloc] init];
	[queue enqueueRequest: request2];
	[queue enqueueRequest: request1];
	STAssertTrue( [[queue nextRequestIdentifier] isEqualToString: @"id2"], @"");
	STAssertTrue( [[queue nextRequestIdentifierForConnection: nil] isEqualToString: @"id2"], @"");
	STAssertTrue( [queue nextRequestForConnection: nil] == request2, @"");

	STAssertTrue( [queue hasDataForConnection: nil] == (queue.query.count>0), @"");
	[queue removeAllRequests];
	STAssertTrue( [queue hasDataForConnection: nil] == (queue.query.count>0), @"");
}

-(void)testConnectionRequestDataForIdentifier {
	PNTimeTokenRequest *request = [[PNTimeTokenRequest alloc] init];
	PNRequestsQueue *queue = [[PNRequestsQueue alloc] init];
	request.identifier = @"id1";
	[queue enqueueRequest: request];

	PNWriteBuffer *writeBuffer = [queue connection: nil requestDataForIdentifier: @"id1"];
	NSString *buffer = [[NSString alloc] initWithBytes: writeBuffer.buffer length:(NSUInteger)writeBuffer.length encoding:NSUTF8StringEncoding];
	NSLog(@"buffer %@", buffer);
	STAssertTrue( [buffer rangeOfString: @"GET /time/t_"].location == 0, @"" );
	STAssertTrue( [buffer rangeOfString: @"HTTP/1.1\r\nHost: (null)\r\nV: 3."].location != NSNotFound, @"" );
	STAssertTrue( [buffer rangeOfString: @"User-Agent: Obj-C-iOS\r\nAccept: */*"].location != NSNotFound, @"" );
}

@end



