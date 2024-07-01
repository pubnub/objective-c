#import "PNRecordableTestCase.h"
#import <OCMock/OCMock.h>
#import <PubNub/PubNub+CorePrivate.h>
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
            NSLog(@"CALLED");

            XCTAssertEqual(transportRequest.timeout, self.client.configuration.subscribeMaximumIdleTime);
            XCTAssertTrue(transportRequest.cancellable);
            XCTAssertFalse(transportRequest.retriable);
        });

    [self waitForObject:clientTransportMock recordedInvocationCall:recorded afterBlock:^{
        [self.client subscribeWithRequest:request];
    }];
}

#pragma mark -

@end
