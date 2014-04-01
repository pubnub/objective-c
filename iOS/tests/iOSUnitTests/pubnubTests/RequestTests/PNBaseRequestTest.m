//
//  PNBaseRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNBaseRequestTest.h"
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface PNBaseRequest ()

@property (nonatomic, assign) NSUInteger retryCount;

@end


@implementation PNBaseRequestTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

#pragma mark - States tests
-(void)testInit {
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	NSLog(@"id %@", request.identifier);
	STAssertTrue( request.identifier.length == 36, @"" );
	STAssertTrue( request.shortIdentifier.length == 5, @"" );
}

- (void)testTimeout {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout == [baseRequest timeout], @"Default value of timeout should be qual nonSubscriptionRequestTimeout");
}

- (void)testCallbackMethodName {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([[baseRequest callbackMethodName] isEqualToString:@"0"], @"Default value of callback method name is 0");
}

- (void)testResourcePath {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([[baseRequest resourcePath] isEqualToString:@"/"], @"Default value of callback method name is //");
}

- (void)testBuffer {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([[baseRequest buffer] isKindOfClass:[PNWriteBuffer class]], @"Should return valid object of write buffer here");
}

// Protected methods
/*
- (void)testReset {
    id mockBaseRequest = [OCMockObject partialMockForObject:[[PNBaseRequest alloc] init]];
    [[mockBaseRequest expect] setRetryCount:0];
    [[mockBaseRequest expect] setProcessed:NO];
    [[mockBaseRequest expect] setProcessing:NO];
    
    [mockBaseRequest reset];
    
    [mockBaseRequest verify];
}
*/
- (void)testAllowedRetryCount {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([baseRequest allowedRetryCount] == kPNRequestMaximumRetryCount, @"Should be defined as kPNRequestMaximumRetryCount");
}


- (void)testIncreaseRetryCount {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    [baseRequest increaseRetryCount];
    
    STAssertTrue([baseRequest retryCount] == 1, @"By default retryCount should be 0");
}

/*
- (void)testCanRetry {
    id mockBaseRequest = [OCMockObject partialMockForObject:[[PNBaseRequest alloc] init]];
    [[mockBaseRequest expect] retryCount];
    [[mockBaseRequest expect] allowedRetryCount];
    
    [mockBaseRequest canRetry];
    
    [mockBaseRequest verify];
}
*/
//- (void)testHTTPPayload {
//    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
//    
//    NSData *payload = [baseRequest HTTPPayload];
//    
//    STAssertTrue([payload isKindOfClass:[NSData class]], @"Payload should be a string");
//    STAssertTrue([payload length] > 0, @"Payload should has length more than zero");
//}

-(void)testAuthorizationField {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey:@"publish" subscribeKey: @"subscr" secretKey: @"secret" authorizationKey: @"auth"];
	[[PubNub sharedInstance] setConfiguration: conf];
	STAssertTrue( [[baseRequest authorizationField] isEqualToString: @"auth=auth"]==YES, @"" );

	conf = [PNConfiguration configurationWithPublishKey:@"publish" subscribeKey: @"subscr" secretKey: @"secret"];
	[[PubNub sharedInstance] setConfiguration: conf];
	STAssertTrue( [baseRequest authorizationField] == nil, @"" );
}

-(void)testRequestPath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey:@"publish" subscribeKey: @"subscr" secretKey: @"secret"];
	[[PubNub sharedInstance] setConfiguration: conf];
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
	STAssertTrue( [[baseRequest requestPath] isEqualToString: @"http://origin/"], @"");
}

-(void)testHTTPMethod {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
	STAssertTrue( [baseRequest HTTPMethod] == PNRequestGETMethod, @"");
}

-(void)testShouldCompressPOSTBody {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
	STAssertTrue( [baseRequest shouldCompressPOSTBody] == NO, @"");
}

-(void)testPOSTBody {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
	STAssertTrue( [baseRequest POSTBody] == nil, @"");
}

-(void)testHTTPPayload {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey:@"publish" subscribeKey: @"subscr" secretKey: @"secret"];
	[[PubNub sharedInstance] setConfiguration: conf];
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
	NSData *http = [baseRequest HTTPPayload];
	NSString *payload = [NSString stringWithUTF8String:[http bytes]];
	STAssertTrue( [payload rangeOfString: @"GET / HTTP/1.1\r"
				   @"Host: origin\r"
				   @"V: 3.5.7\r"
				   @"User-Agent: Obj-C-iOS\r"
				   @"Accept: */*\r"
				   @"Accept-Encoding: gzip, deflate\r"
				   @"\r"].location, @"");

}

@end



