//
//  MetadataTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/26/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNClientMetadataUpdateRequest.h"
#import "PNConfiguration.h"
#import "PubNub.h"
#import "PNChannel.h"
#import "PNHeartbeatRequest.h"
#import "PNClientStateUpdateRequest.h"
#import "PNHereNowRequest.h"
#import "PNSubscribeRequest+Protected.h"
#import "PNSubscribeRequest.h"

@interface MetadataTest : SenTestCase

@end

@implementation MetadataTest

-(void)tearDown {
	[NSThread sleepForTimeInterval:1.0];
    [super tearDown];
}

-(void)testMetadataUpdateResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	NSDictionary *metadata = @{@"key1":@"value1", @"key2":@(2)};
	PNClientMetadataUpdateRequest *request = [PNClientMetadataUpdateRequest clientMetadataUpdateRequestWithIdentifier:@"id" channel:channel andMetadata: metadata];
	NSString *resourcePath = [request resourcePath];
	STAssertTrue( [resourcePath rangeOfString: @"/v2/presence/sub-key/subscr/channel/channel/uuid/id/data?callback=mu_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"&metadata=%7B%22key2%22%3A2%2C%22key1%22%3A%22value1%22%7D&auth=auth"].location != NSNotFound, @"");
	STAssertTrue( resourcePath.length == 142, @"");
}

-(void)testHeartbeatRequestResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"clientId"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	NSDictionary *state = @{@"key1":@"value1", @"key2":@(2)};
	PNHeartbeatRequest *request = [PNHeartbeatRequest heartbeatRequestForChannel: channel withClientState: state];
	NSString *resourcePath = [request resourcePath];
	NSLog(@"resourcePath %@", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/v2/presence/sub-key/subscr/channel/channel/heartbeat?uuid=clientId&state=%7B%22key2%22%3A2%2C%22key1%22%3A%22value1%22%7D&auth=auth"].location == 0, @"");
}

-(void)testClientStateUpdateRequestResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"clientId"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	NSDictionary *state = @{@"key1":@"value1", @"key2":@(2)};
	PNClientStateUpdateRequest *request = [PNClientStateUpdateRequest clientStateUpdateRequestWithIdentifier: @"id" channel: channel andClientState: state];
	NSString *resourcePath = [request resourcePath];
	NSLog(@"resourcePath %@", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/v2/presence/sub-key/subscr/channel/channel/uuid/id/data?callback=mu_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"&state=%7B%22key2%22%3A2%2C%22key1%22%3A%22value1%22%7D&auth=auth"].location != NSNotFound, @"");
	STAssertTrue( resourcePath.length == 139, @"");
}

-(void)testHereNowRequestResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"clientId"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
//	NSDictionary *state = @{@"key1":@"value1", @"key2":@(2)};
	PNHereNowRequest *request = [PNHereNowRequest whoNowRequestForChannel: channel clientIdentifiersRequired: YES clientState: YES];
	NSString *resourcePath = [request resourcePath];
	NSLog(@"resourcePath %@", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/v2/presence/sub-key/subscr/channel/channel?callback=p_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"&disable_uuids=0&state=1&auth=auth"].location != NSNotFound, @"");
	STAssertTrue( resourcePath.length == 94, @"");
}

-(void)testSubscribeRequestResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"clientId"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	NSDictionary *state = @{@"key1":@"value1", @"key2":@(2)};
	PNSubscribeRequest *request = [PNSubscribeRequest subscribeRequestForChannel: channel byUserRequest: YES withClientState: state];
	NSString *resourcePath = [request resourcePath];
	NSLog(@"resourcePath %@", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/subscribe/subscr/channel/s_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"/0?uuid=clientId&state=%7B%22key2%22%3A2%2C%22key1%22%3A%22value1%22%7D&auth=auth"].location != NSNotFound, @"");
	STAssertTrue( resourcePath.length == 114, @"");
}

@end
