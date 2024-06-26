/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
*/
#import <PubNub/PNHistoryMessagesCountRequest.h>
#import <PubNub/PubNub+CorePrivate.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PNChannel.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNMessageCountTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMessageCountTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Builder

- (void)testItShouldReturnMessageCountsBuilder {
    XCTAssertTrue([self.client.messageCounts() isKindOfClass:[PNMessageCountAPICallBuilder class]]);
}


#pragma mark - Tests :: Call

- (void)testItShouldFetchMessageCountsWhenCalled {
    NSArray<NSString *> *expectedChannels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202)];
    NSString *expectedTimetokens = @(15501402020000000).stringValue;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNHistoryMessagesCountRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNHistoryMessagesCountRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.channels, expectedChannels);
            XCTAssertEqualObjects(request.request.query[@"timetoken"], expectedTimetokens);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.messageCounts().channels(expectedChannels).timetokens(timetokens)
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) { });
    }];
}

- (void)testItShouldUseTimetokenWhenOnlyOneTimetokenProvidedForChannels {
    NSArray<NSString *> *channels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202)];
    NSString *expectedTimetokens = @(15501402020000000).stringValue;
    
    
    id clientMock = [self mockForObject:self.client];
    OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNHistoryMessagesCountRequest class]]
                          withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNHistoryMessagesCountRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNil(request.request.query[@"channelsTimetoken"]);
            XCTAssertEqualObjects(request.request.query[@"timetoken"], expectedTimetokens);
        });

    self.client.messageCounts().channels(channels).timetokens(timetokens)
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) { });
}

- (void)testItShouldUseChannelsTimetokenWhenMultipleOneTimetokenProvidedForChannels {
    NSArray<NSString *> *channels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202), @(1550140204)];
    NSString *expectedTimetokens = [@[@(15501402020000000), @(15501402040000000)] componentsJoinedByString:@","];
    
    
    id clientMock = [self mockForObject:self.client];
    OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNHistoryMessagesCountRequest class]]
                          withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNHistoryMessagesCountRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNil(request.request.query[@"timetoken"]);
            XCTAssertEqualObjects(request.request.query[@"channelsTimetoken"], expectedTimetokens);
        });

    self.client.messageCounts().channels(channels).timetokens(timetokens)
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) { });
}

- (void)testItShouldFailValidationWhenNumberOfChannelsAndTimetokensIsDifferent {
    NSArray<NSString *> *channels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202), @(1550140204), @(1550140206)];
    
    
    id clientMock = [self mockForObject:self.client];
    OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNHistoryMessagesCountRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNHistoryMessagesCountRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNotNil([request validate]);
        });

    self.client.messageCounts().channels(channels).timetokens(timetokens)
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) { });
}

- (void)testItShouldReturnBadRequestWhenNumberOfChannelsAndTimetokensIsDifferent {
    NSArray<NSString *> *channels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202), @(1550140204), @(1550140206)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(channels).timetokens(timetokens)
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                XCTAssertNotNil(status);
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.statusCode, 400);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Retry

- (void)testItShouldRetryWhenRetryOnFailureCalled {
    NSArray<NSString *> *channels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202), @(1550140204), @(1550140206)];
    __block PNErrorStatus *errorStatus = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(channels).timetokens(timetokens)
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                errorStatus = status;
                handler();
            });
    }];
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNHistoryMessagesCountRequest class]]
                                        withCompletion:[OCMArg any]]);

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        [errorStatus retry];
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
