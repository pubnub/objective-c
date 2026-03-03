#import "PNRecordableTestCase.h"
#import <OCMock/OCMock.h>
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PubNub+PresencePrivate.h>
#import "PNBaseRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNSubscribeTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNSubscribeTest


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}

#pragma mark - Tests :: Request

- (void)testItShouldSetProperRequestValues {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch-a"] channelGroups:@[@"gr-a"]];

    id clientTransportMock = [self mockForObject:self.client.subscriptionNetwork];
    id recorded = OCMExpect([clientTransportMock sendRequest:[OCMArg isKindOfClass:[PNTransportRequest class]]
                                         withCompletionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNTransportRequest *transportRequest = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqual(transportRequest.timeout, self.client.configuration.subscribeMaximumIdleTime);
            XCTAssertTrue(transportRequest.cancellable);
            XCTAssertFalse(transportRequest.retriable);
        });

    [self waitForObject:clientTransportMock recordedInvocationCall:recorded afterBlock:^{
        [self.client subscribeWithRequest:request];
    }];
}

#pragma mark - Tests :: Subscribe channel uniqueness

- (void)testItShouldHaveUniqueChannelsInCompiledSubscribeRequest {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch1", @"ch1", @"ch2"]
                                                           channelGroups:nil];

    id clientTransportMock = [self mockForObject:self.client.subscriptionNetwork];
    id recorded = OCMExpect([clientTransportMock sendRequest:[OCMArg isKindOfClass:[PNTransportRequest class]]
                                         withCompletionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNTransportRequest *transportRequest = [self objectForInvocation:invocation argumentAtIndex:1];
            NSString *path = transportRequest.path;
            NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
            // Path: /v2/subscribe/<sub-key>/<channels>/0
            NSString *channelSegment = pathComponents[4];
            NSString *decoded = [channelSegment stringByRemovingPercentEncoding];
            NSArray *channels = [decoded componentsSeparatedByString:@","];

            XCTAssertEqual(channels.count, [NSSet setWithArray:channels].count,
                           @"Subscribe request path should contain unique channels.");
        });

    [self waitForObject:clientTransportMock recordedInvocationCall:recorded afterBlock:^{
        [self.client subscribeWithRequest:request];
    }];
}

- (void)testItShouldHaveUniqueChannelGroupsInCompiledSubscribeRequest {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch1"]
                                                           channelGroups:@[@"gr1", @"gr1", @"gr2"]];

    id clientTransportMock = [self mockForObject:self.client.subscriptionNetwork];
    id recorded = OCMExpect([clientTransportMock sendRequest:[OCMArg isKindOfClass:[PNTransportRequest class]]
                                         withCompletionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNTransportRequest *transportRequest = [self objectForInvocation:invocation argumentAtIndex:1];
            NSString *groupValue = transportRequest.query[@"channel-group"];
            NSArray *groups = [groupValue componentsSeparatedByString:@","];

            XCTAssertEqual(groups.count, [NSSet setWithArray:groups].count,
                           @"Subscribe request query should contain unique channel groups.");
        });

    [self waitForObject:clientTransportMock recordedInvocationCall:recorded afterBlock:^{
        [self.client subscribeWithRequest:request];
    }];
}

#pragma mark - Tests :: Heartbeat channel uniqueness

- (void)testItShouldHaveUniqueChannelsInCompiledHeartbeatRequest {
    PNConfiguration *configuration = [self defaultConfiguration];
    configuration.managePresenceListManually = YES;
    configuration.presenceHeartbeatValue = 20;
    PubNub *client = [self createPubNubForUser:@"heartbeat-ch" withConfiguration:configuration];

    [client.heartbeatManager setConnected:YES forChannels:@[@"ch1", @"ch1", @"ch2"]];

    id clientTransportMock = [self mockForObject:client.serviceNetwork];
    id recorded = OCMExpect([clientTransportMock sendRequest:[OCMArg isKindOfClass:[PNTransportRequest class]]
                                         withCompletionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNTransportRequest *transportRequest = [self objectForInvocation:invocation argumentAtIndex:1];
            NSString *path = transportRequest.path;
            NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
            // Path: /v2/presence/sub-key/<sub-key>/channel/<channels>/heartbeat
            NSString *channelSegment = pathComponents[5];
            NSString *decoded = [channelSegment stringByRemovingPercentEncoding];
            NSArray *channels = [decoded componentsSeparatedByString:@","];

            XCTAssertEqual(channels.count, [NSSet setWithArray:channels].count,
                           @"Heartbeat request path should contain unique channels.");
        });

    [self waitForObject:clientTransportMock recordedInvocationCall:recorded afterBlock:^{
        [client heartbeatWithCompletion:nil];
    }];
}

- (void)testItShouldHaveUniqueChannelGroupsInCompiledHeartbeatRequest {
    PNConfiguration *configuration = [self defaultConfiguration];
    configuration.managePresenceListManually = YES;
    configuration.presenceHeartbeatValue = 20;
    PubNub *client = [self createPubNubForUser:@"heartbeat-cg" withConfiguration:configuration];

    [client.heartbeatManager setConnected:YES forChannels:@[@"ch1"]];
    [client.heartbeatManager setConnected:YES forChannelGroups:@[@"gr1", @"gr1", @"gr2"]];

    id clientTransportMock = [self mockForObject:client.serviceNetwork];
    id recorded = OCMExpect([clientTransportMock sendRequest:[OCMArg isKindOfClass:[PNTransportRequest class]]
                                         withCompletionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNTransportRequest *transportRequest = [self objectForInvocation:invocation argumentAtIndex:1];
            NSString *groupValue = transportRequest.query[@"channel-group"];
            NSArray *groups = [groupValue componentsSeparatedByString:@","];

            XCTAssertEqual(groups.count, [NSSet setWithArray:groups].count,
                           @"Heartbeat request query should contain unique channel groups.");
        });

    [self waitForObject:clientTransportMock recordedInvocationCall:recorded afterBlock:^{
        [client heartbeatWithCompletion:nil];
    }];
}

#pragma mark -

@end
