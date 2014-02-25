//
//  PNSubscribeRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNSubscribeRequestTest.h"
#import "PNSubscribeRequest.h"
#import "PNSubscribeRequest+Protected.h"
#import <OCMock/OCMock.h>
#import "PNChannel.h"
#import "PubNub.h"
#import "PubNub+Protected.h"

@interface PNSubscribeRequest ()
@property (nonatomic, strong) NSString *pushToken;
@property (nonatomic, copy) NSString *clientIdentifier;
@property (nonatomic, copy) NSString *updateTimeToken;
- (NSArray *)channelsForSubscription;
@end

@interface PNChannel ()
@property (nonatomic, copy) NSString *updateTimeToken;
@end

@implementation PNSubscribeRequestTest

-(void)setUp {
	[super setUp];
	[PubNub resetClient];
}

-(void)tearDown {
	[NSThread sleepForTimeInterval:1.0];
    [super tearDown];
}

-(void)testSubscribeRequestForChannel {
	[PubNub setClientIdentifier: @"id"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	channel.updateTimeToken = @"123";
	PNSubscribeRequest *request = [PNSubscribeRequest subscribeRequestForChannel: channel byUserRequest: YES];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.channels isEqualToArray: @[channel]] == YES, @"");
	STAssertTrue( [request.clientIdentifier isEqualToString: @"id"] == YES, @"");
	STAssertTrue( [request.updateTimeToken isEqualToString: @"123"] == YES, @"");
}

-(void)testSubscribeRequestForChannels {
	[PubNub setClientIdentifier: @"id"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	channel.updateTimeToken = @"123";
	PNSubscribeRequest *request = [PNSubscribeRequest subscribeRequestForChannels: @[channel] byUserRequest: YES];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.channels isEqualToArray: @[channel]] == YES, @"");
	STAssertTrue( [request.clientIdentifier isEqualToString: @"id"] == YES, @"");
	STAssertTrue( [request.updateTimeToken isEqualToString: @"123"] == YES, @"");
}

-(void)testInitForChannel {
	[PubNub setClientIdentifier: @"id"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	channel.updateTimeToken = @"123";
	PNSubscribeRequest *request = [[PNSubscribeRequest alloc] initForChannel: channel byUserRequest: YES];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.channels isEqualToArray: @[channel]] == YES, @"");
	STAssertTrue( [request.clientIdentifier isEqualToString: @"id"] == YES, @"");
	STAssertTrue( [request.updateTimeToken isEqualToString: @"123"] == YES, @"");
}

-(void)testInitForChannela {
	[PubNub setClientIdentifier: @"id"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	channel.updateTimeToken = @"123";
	PNSubscribeRequest *request = [[PNSubscribeRequest alloc] initForChannels: @[channel] byUserRequest: YES];
	STAssertTrue( request.sendingByUserRequest == YES, @"");
	STAssertTrue( [request.channels isEqualToArray: @[channel]] == YES, @"");
	STAssertTrue( [request.clientIdentifier isEqualToString: @"id"] == YES, @"");
	STAssertTrue( [request.updateTimeToken isEqualToString: @"123"] == YES, @"");
}

-(void)testResetTimeToken {
	[PubNub setClientIdentifier: @"id"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	channel.updateTimeToken = @"123";
	PNSubscribeRequest *request = [[PNSubscribeRequest alloc] initForChannels: @[channel] byUserRequest: YES];
	[request resetTimeToken];
	STAssertTrue( [request.updateTimeToken isEqualToString: @"0"] == YES, @"");
	STAssertTrue( [channel.updateTimeToken isEqualToString: @"0"] == YES, @"");
}

-(void)testResetTimeTokenTo {
	[PubNub setClientIdentifier: @"id"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	channel.updateTimeToken = @"123";
	PNSubscribeRequest *request = [[PNSubscribeRequest alloc] initForChannels: @[channel] byUserRequest: YES];
	[request resetTimeTokenTo: @"1"];
	STAssertTrue( [request.updateTimeToken isEqualToString: @"1"] == YES, @"");
	STAssertTrue( [channel.updateTimeToken isEqualToString: @"0"] == YES, @"");
}

-(void)testChannelsForSubscription {
	[PubNub setClientIdentifier: @"id"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNSubscribeRequest *request = [[PNSubscribeRequest alloc] initForChannels: @[channel] byUserRequest: YES];
	STAssertTrue( [[request channelsForSubscription] isEqualToArray: @[channel]] == YES, @"");
}

-(void)testIsInitialSubscription {
	[PubNub setClientIdentifier: @"id"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	channel.updateTimeToken = @"123";
	PNSubscribeRequest *request = [[PNSubscribeRequest alloc] initForChannels: @[channel] byUserRequest: YES];
	STAssertTrue( [request isInitialSubscription] == NO, @"");
	[request resetTimeToken];
	STAssertTrue( [request isInitialSubscription] == YES, @"");
}

-(void)testTimeout {
	[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
	PNSubscribeRequest *request = [[PNSubscribeRequest alloc] initForChannels: nil byUserRequest: YES];
	STAssertTrue( request.timeout == [PubNub sharedInstance].configuration.subscriptionRequestTimeout, @"");
}

-(void)testCallbackMethodName {
	PNSubscribeRequest *request = [[PNSubscribeRequest alloc] initForChannels: nil byUserRequest: YES];
	STAssertTrue( [[request callbackMethodName] isEqualToString: @"s"] == YES, @"" );
}

-(void)testResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"cipher" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];
	[PubNub setClientIdentifier: @"id"];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	channel.updateTimeToken = @"123";
	PNSubscribeRequest *request = [[PNSubscribeRequest alloc] initForChannels: @[channel] byUserRequest: YES];
	NSString *resourcePath = [request resourcePath];
	NSLog( @"resourcePath |%@|", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/subscribe/subscr/channel/s_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"/123?uuid=id&auth=auth"].location != NSNotFound, @"");
	STAssertTrue( resourcePath.length == 55, @"");
}


@end
