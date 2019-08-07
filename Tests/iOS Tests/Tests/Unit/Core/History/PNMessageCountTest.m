/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PNRequestParameters.h>
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNChannel.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>
#import "PNTestCase.h"


#pragma mark Test interface declaration

@interface PNMessageCountTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNMessageCountTest

  
#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];

    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}


#pragma mark - Tests :: Builder

- (void)testMessageCounts_ShouldReturnBuilder {
    
    XCTAssertTrue([self.client.messageCounts() isKindOfClass:[PNMessageCountAPICallBuilder class]]);
}


#pragma mark - Tests :: Call

- (void)testMessageCounts_ShouldProcessOperation_WhenCalled {
    
    NSArray<NSString *> *channels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202)];
    NSString *expectedChannels = [PNChannel namesForRequest:channels];
    NSString *expectedTimetokens = @(15501402020000000).stringValue;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNMessageCountOperation
                                          withParameters:[OCMArg any] completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{channels}"], expectedChannels);
            XCTAssertEqualObjects(parameters.query[@"timetoken"], expectedTimetokens);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.messageCounts().channels(channels).timetokens(timetokens)
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) { });
    }];
}

- (void)testMessageCounts_ShouldUseTimetoken_WhenOnlyOneTimetokenProvidedForChannels {
    
    NSArray<NSString *> *channels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202)];
    NSString *expectedTimetokens = @(15501402020000000).stringValue;
    
    
    id clientMock = [self mockForObject:self.client];
    OCMStub([clientMock processOperation:PNMessageCountOperation withParameters:[OCMArg any]
                           completionBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertNil(parameters.query[@"channelsTimetoken"]);
        XCTAssertEqualObjects(parameters.query[@"timetoken"], expectedTimetokens);
    });
    
    self.client.messageCounts().channels(channels).timetokens(timetokens)
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) { });
}

- (void)testMessageCounts_ShouldUseChannelsTimetoken_WhenMultipleOneTimetokenProvidedForChannels {
    
    NSArray<NSString *> *channels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202), @(1550140204)];
    NSString *expectedTimetokens = [@[@(15501402020000000), @(15501402040000000)] componentsJoinedByString:@","];
    
    
    id clientMock = [self mockForObject:self.client];
    OCMStub([clientMock processOperation:PNMessageCountOperation withParameters:[OCMArg any]
                           completionBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertNil(parameters.query[@"timetoken"]);
        XCTAssertEqualObjects(parameters.query[@"channelsTimetoken"], expectedTimetokens);
    });
    
    self.client.messageCounts().channels(channels).timetokens(timetokens)
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) { });
}

- (void)testMessageCounts_ShouldNotSetChannels_WhenNumberOfChannelsAndTimetokensIsDifferent {
    
    NSArray<NSString *> *channels = @[@"PubNub 1", @"PubNub-2"];
    NSArray<NSNumber *> *timetokens = @[@(1550140202), @(1550140204), @(1550140206)];
    
    
    id clientMock = [self mockForObject:self.client];
    OCMStub([clientMock processOperation:PNMessageCountOperation withParameters:[OCMArg any]
                         completionBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertNil(parameters.pathComponents[@"{channels}"]);
    });
    
    self.client.messageCounts().channels(channels).timetokens(timetokens)
        .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) { });
}

- (void)testMessageCounts_ShouldReturnBadRequest_WhenNumberOfChannelsAndTimetokensIsDifferent {
    
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

- (void)testMessageCounts_ShouldCallMethodAgain_WhenRetryOnFailureCalled {
    
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
    id recorded = OCMExpect([clientMock processOperation:PNMessageCountOperation
                                          withParameters:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        [errorStatus retry];
    }];
}

#pragma mark -


@end
