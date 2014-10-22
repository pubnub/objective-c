//
//  PNAccessRightsAuditRequestTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNAccessRightsAuditRequest.h"
#import "PNChannel.h"
#import "PNAccessRightOptions.h"
#import "PubNub.h"
#import "PNConfiguration.h"

@interface PNAccessRightsAuditRequest (test)
- (NSString *)PAMSignature;
@end

@interface PubNub (test)
@property (nonatomic, strong) PNConfiguration *configuration;
@end


@interface PNAccessRightsAuditRequestTest : XCTestCase

@end

@implementation PNAccessRightsAuditRequestTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInitWithChannels {
	NSArray *channels = [PNChannel channelsWithNames: @[@"ch1", @"ch2", @"ch3"]];
	NSArray *keys = @[@"key1", @"key2"];
	PNAccessRightsAuditRequest *request = [[PNAccessRightsAuditRequest alloc] initWithChannels: channels andClients: keys];
	XCTAssertTrue( request.sendingByUserRequest == YES, @"");
	XCTAssertTrue( request.accessRightOptions.rights == PNUnknownAccessRights, @"");
	XCTAssertTrue( request.accessRightOptions.accessPeriodDuration == 0, @"");
	XCTAssertTrue( request.accessRightOptions.channels == channels, @"");
	XCTAssertTrue( request.accessRightOptions.clientsAuthorizationKeys == keys, @"");
}

-(void)testPAMSignature {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr'" secretKey: @"secret"];
	[[PubNub sharedInstance] setConfiguration: conf];
	PNAccessRightsAuditRequest *request = [[PNAccessRightsAuditRequest alloc] initWithChannels: nil andClients: nil];
	NSString *pam = [request PAMSignature];
	XCTAssertTrue( pam.length == 46, @"" );
}

-(void)testCallbackMethodName {
	PNAccessRightsAuditRequest *request = [[PNAccessRightsAuditRequest alloc] initWithChannels: nil andClients: nil];
	XCTAssertTrue( [[request callbackMethodName] isEqualToString: @"arr"] == YES, @"");
}

-(void)testResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr'" secretKey: @"secret"];
	[[PubNub sharedInstance] setConfiguration: conf];
	NSArray *channels = [PNChannel channelsWithNames: @[@"channel1", @"channel2"]];
	NSArray *keys = @[@"key1", @"key2"];
	PNAccessRightsAuditRequest *request = [[PNAccessRightsAuditRequest alloc] initWithChannels: channels andClients: keys];
	NSString *resourcePath = [request resourcePath];
	NSLog(@"res %@", resourcePath);
	XCTAssertTrue( [resourcePath rangeOfString: @"/v1/auth/audit/sub-key/subscr'?"].location == 0, @"");
	XCTAssertTrue( [resourcePath rangeOfString: @"auth=key1%2Ckey2&callback=arr_0b94b&channel=channel1%2Cchannel2&timestamp="].location == NSNotFound, @"");
	NSString *pam = [NSString stringWithFormat: @"&signature=%@", [request PAMSignature]];
	XCTAssertTrue( [resourcePath rangeOfString: pam].location + [resourcePath rangeOfString: pam].length == resourcePath.length, @"");
}

@end


