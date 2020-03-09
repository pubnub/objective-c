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

@interface PNSignalAPIBuilderTest : XCTestCase


#pragma mark - Misc

- (PNSignalAPICallBuilder *)builder;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNSignalAPIBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: channel

- (void)testItShouldReturnSignalBuilderWhenChannelSpecifiedInChain {
    
    PNSignalAPICallBuilder *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.channel(@"PubNub"), builder);
}

- (void)testItShouldSetChannelWhenNSStringPassedAsChannel {
    
    PNSignalAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channel";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedAsChannel {
    
    PNSignalAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channel";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = (id)@[@"PubNub"];
    
    
    id builderMock = OCMPartialMock(builder);
    OCMReject([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: message

- (void)testItShouldReturnSignalBuilderWhenMessageSpecifiedInChain {
    
    PNSignalAPICallBuilder *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.message(@[@1234567890]), builder);
}

- (void)testItShouldSetMessageWhenDataPassedAsMessage {
    
    PNSignalAPICallBuilder *builder = [self builder];
    NSString *parameter = @"message";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSNumber *> *expected = @[@1234567890];
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.message(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNSignalAPICallBuilder *)builder {
    
    PNAPICallCompletionBlock block = ^(NSArray<NSString *> *flags, NSDictionary *arguments) {
        
    };
    
    return [PNSignalAPICallBuilder builderWithExecutionBlock:block];
}

#pragma mark -

#pragma clang diagnostic pop

@end
