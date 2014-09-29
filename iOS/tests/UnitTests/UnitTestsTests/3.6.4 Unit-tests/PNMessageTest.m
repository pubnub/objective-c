//
//  PNMessageTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNMessage.h"
#import "PNChannel.h"
#import "PNError.h"
#import "PNError+Protected.h"
#import "PNJSONSerialization.h"

@interface PNMessage (test)

+ (PNMessage *)messageWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
                  storeInHistory:(BOOL)shouldStoreInHistory error:(PNError **)error;
+ (PNMessage *)messageFromServiceResponse:(id)messageBody onChannel:(PNChannel *)channel atDate:(PNDate *)messagePostDate;
- (id)initWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

@property (nonatomic, assign, getter = shouldCompressMessage) BOOL compressMessage;

@end

@interface PNMessageTest : XCTestCase

@end

@implementation PNMessageTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testMessageWithObject {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNError *error = nil;
    
    PNMessage *message = [PNMessage messageWithObject:@"object" forChannel:channel compressed:YES storeInHistory:YES error:&error];
   
	XCTAssertTrue( message != nil, @"");
	XCTAssertTrue( error == nil, @"");
	XCTAssertTrue( message.channel == channel, @"");
	XCTAssertTrue( [message.message isEqualToString: [PNJSONSerialization stringFromJSONObject: @"object"]], @"");
	XCTAssertTrue( message.compressMessage == YES, @"");

    message = [PNMessage messageWithObject:@"object" forChannel:nil compressed:YES storeInHistory:NO error:&error];
	XCTAssertTrue( message == nil, @"");
	XCTAssertTrue( error.code == kPNMessageHasNoChannelError, @"");

    message = [PNMessage messageWithObject:nil forChannel:channel compressed:YES storeInHistory:YES error:&error];
	XCTAssertTrue( message == nil, @"");
	XCTAssertTrue( error.code == kPNMessageHasNoContentError, @"");
}

-(void)testMessageFromServiceResponse {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	NSDictionary *body = @{@"timetoken": @(123), @"message": @"message"};
	PNDate *postDate = [PNDate dateWithToken: @(200)];
	PNMessage *message = [PNMessage messageFromServiceResponse: body onChannel: channel atDate: postDate];

	XCTAssertTrue( message != nil, @"");
	XCTAssertTrue( [[message.receiveDate timeToken] intValue] == 123, @"");
	XCTAssertTrue( [message.message isEqualToString: @"message"] == YES, @"");
	XCTAssertTrue( message.channel == channel, @"");

	message = [PNMessage messageFromServiceResponse: @{@"message": @"message"} onChannel: channel atDate: postDate];
	XCTAssertTrue( [[message.receiveDate timeToken] intValue] == 200, @"");
	XCTAssertTrue( [message.message isEqualToDictionary:@{@"message": @"message"}] == YES, @"");
	XCTAssertTrue( message.channel == channel, @"");
}

-(void)testInitWithObject {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
    PNMessage *message = [[PNMessage alloc] initWithObject:@"message" forChannel:channel compressed:YES storeInHistory:YES];
    
    XCTAssertTrue( message != nil, @"");
	XCTAssertTrue( message.channel == channel, @"");
	XCTAssertTrue( [message.message isEqualToString: [PNJSONSerialization stringFromJSONObject: @"message"]], @"");
	XCTAssertTrue( message.compressMessage == YES, @"");
}

@end
