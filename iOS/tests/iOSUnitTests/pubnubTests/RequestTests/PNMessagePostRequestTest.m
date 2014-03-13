//
//  PNMessagePostRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNMessagePostRequestTest.h"
#import "PNMessagePostRequest.h"
#import "PNMessagePostRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PNMessage.h"

typedef NS_OPTIONS(NSInteger , PNRequestHTTPMethod) {
    PNRequestGETMethod,
    PNRequestPOSTMethod
};


@interface PNMessagePostRequest ()

@property (nonatomic, strong) PNMessage *message;
@property (nonatomic, copy) NSString *clientIdentifier;
- (PNRequestHTTPMethod)HTTPMethod;
- (BOOL)shouldCompressPOSTBody;
- (NSData *)POSTBody;
- (NSString *)preparedMessage;
- (NSString *)signature;

@end

@interface PNMessage ()

@property (nonatomic, assign, getter = shouldCompressMessage) BOOL compressMessage;
@property (nonatomic, strong) id message;
@property (nonatomic, strong) PNChannel *channel;

<<<<<<< HEAD
@end


@implementation PNMessagePostRequestTest

- (void)tearDown {
=======
- (void)tearDown
{
	[NSThread sleepForTimeInterval:0.1];
>>>>>>> presence-v3
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}


#pragma mark - States tests

- (void)testInitWithMessageMock {
    id mockMessage = [OCMockObject mockForClass:[PNMessage class]];
    
    id mockRequest = [OCMockObject partialMockForObject:[PNMessagePostRequest alloc]];
    
    [[mockRequest expect] setMessage:mockMessage];
    
    PNMessagePostRequest *request = [mockRequest initWithMessage:mockMessage];
    
    STAssertNotNil(request, @"Cannot initialize message post request");
    
    [mockRequest verify];
}

#pragma mark - Interaction tests

//- (void)testPostMessageRequestWithMessage {
//    STAssertNotNil([[PNMessagePostRequest alloc] initWithMessage:nil], @"Cannot initialize post message request");
//}

-(void)testPostMessageRequestWithMessage {
	[PubNub setClientIdentifier: @"id"];
	PNMessage *message = [[PNMessage alloc] init];
	PNMessagePostRequest *request = [PNMessagePostRequest postMessageRequestWithMessage: message];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( request.message == message, @"");
	STAssertTrue( [request.clientIdentifier isEqualToString: @"id"], @"");
}

-(void)testInitWithMessage {
	[PubNub setClientIdentifier: @"id"];
	PNMessage *message = [[PNMessage alloc] init];
	PNMessagePostRequest *request = [[PNMessagePostRequest alloc] initWithMessage: message];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( request.message == message, @"");
	STAssertTrue( [request.clientIdentifier isEqualToString: @"id"], @"");
}

-(void)testCallbackMethodName {
	PNMessage *message = [[PNMessage alloc] init];
	PNMessagePostRequest *request = [[PNMessagePostRequest alloc] initWithMessage: message];
	STAssertTrue( [[request callbackMethodName] isEqualToString: @"m"] == YES, @"");
}

-(void)testHTTPMethod {
	PNMessage *message = [[PNMessage alloc] init];
	message.compressMessage = NO;
	PNMessagePostRequest *request = [[PNMessagePostRequest alloc] initWithMessage: message];
	STAssertTrue( [request HTTPMethod] == PNRequestGETMethod, @"");

	message.compressMessage = YES;
	request = [[PNMessagePostRequest alloc] initWithMessage: message];
	STAssertTrue( [request HTTPMethod] == PNRequestPOSTMethod, @"");
}

-(void)testShouldCompressPOSTBody {
	PNMessage *message = [[PNMessage alloc] init];
	message.compressMessage = NO;
	PNMessagePostRequest *request = [[PNMessagePostRequest alloc] initWithMessage: message];
	STAssertTrue( [request shouldCompressPOSTBody] == NO, @"");

	message.compressMessage = YES;
	request = [[PNMessagePostRequest alloc] initWithMessage: message];
	STAssertTrue( [request shouldCompressPOSTBody] == YES, @"");
}

-(void)testPOSTBody {
	PNMessage *message = [[PNMessage alloc] init];
	message.compressMessage = NO;
	message.message = @"message";
	PNMessagePostRequest *request = [[PNMessagePostRequest alloc] initWithMessage: message];

	STAssertTrue( [[request POSTBody] isEqualToData: [request.preparedMessage dataUsingEncoding:NSUTF8StringEncoding]], @"");
}

-(void)testPreparedMessage {
	PNMessage *message = [[PNMessage alloc] init];
	message.compressMessage = NO;
	message.message = @"message";
	PNMessagePostRequest *request = [[PNMessagePostRequest alloc] initWithMessage: message];

	NSString *prepared = [request preparedMessage];
	STAssertTrue( [prepared isEqualToString: @"message"], @"");

	message.compressMessage = NO;
	message.message = @(123);
	request = [[PNMessagePostRequest alloc] initWithMessage: message];
	prepared = [request preparedMessage];
	STAssertTrue( [prepared isEqualToString: @"123"], @"");
}

-(void)testResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret"authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"id"];
	PNMessage *message = [[PNMessage alloc] init];
	message.channel = [PNChannel channelWithName: @"channel"];
	message.compressMessage = NO;
	message.message = @"message";
	PNMessagePostRequest *request = [[PNMessagePostRequest alloc] initWithMessage: message];

	NSString *resourcePath = [request resourcePath];
	STAssertTrue( [resourcePath rangeOfString: @"/publish/publish/subscr/0/channel/m_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"/message?uuid=id&auth=auth"].location != NSNotFound, @"");
	STAssertTrue( resourcePath.length == 67, @"");
}

-(void)testSignature {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret"authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"id"];
	PNMessage *message = [[PNMessage alloc] init];
	message.channel = [PNChannel channelWithName: @"channel"];
	message.compressMessage = NO;
	message.message = @"message";
	PNMessagePostRequest *request = [[PNMessagePostRequest alloc] initWithMessage: message];
	NSString *signature = [request signature];
#ifndef PN_SHOULD_USE_SIGNATURE
	STAssertTrue( [signature isEqualToString: @"0"] == YES, @"");
#endif
}

@end


