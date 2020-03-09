/**
* @author Serhii Mamontov
* @copyright © 2010-2020 PubNub, Inc.
*/
#import <PubNub/PNAPICallBuilder+Private.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNMessageCountAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNMessageCountAPICallBuilder *)builder;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMessageCountAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: channels

- (void)testItShouldReturnMessageCountBuilderWhenChannelsSpecifiedInChain {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.channels(@[@"PubNub"]), builder);
}

- (void)testItShouldSetChannelsWhenNSArrayPassedAsChannels {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channels";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSString *> *expected = @[@"PubNub"];
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.channels(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelsWhenNonNSArrayPassedAsChannels {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channels";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSString *> *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    OCMReject([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.channels(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: timetokens

- (void)testItShouldReturnMessageCountBuilderWhenTimetokensSpecifiedInChain {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.timetokens(@[@1234567890]), builder);
}

- (void)testItShouldSetChannelsWhenNSArrayPassedAsTimetokens {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    NSString *parameter = @"timetokens";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSNumber *> *expected = @[@1234567890];
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.timetokens(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelsWhenNonNSArrayPassedAsTimetokens {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    NSString *parameter = @"timetokens";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSNumber *> *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    OCMReject([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.timetokens(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNMessageCountAPICallBuilder *)builder {
    
    PNAPICallCompletionBlock block = ^(NSArray<NSString *> *flags, NSDictionary *arguments) {
        
    };
    
    return [PNMessageCountAPICallBuilder builderWithExecutionBlock:block];
}

#pragma mark -

#pragma clang diagnostic pop

@end
