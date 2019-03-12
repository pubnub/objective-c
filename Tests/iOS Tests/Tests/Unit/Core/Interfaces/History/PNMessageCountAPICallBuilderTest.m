/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNAPICallBuilder+Private.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


#pragma mark Test interface declaration

@interface PNMessageCountAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNMessageCountAPICallBuilder *)builder;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNMessageCountAPICallBuilderTest


#pragma mark - Tests :: channels

- (void)testChannels_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.channels(@[@"PubNub"]), builder);
}

- (void)testChannels_ShouldSetChannels_WhenNSArrayPassed {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channels";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSString *> *expected = @[@"PubNub"];
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.channels(expected);
    
    OCMVerify(builderMock);
}

- (void)testChannels_ShouldNotSetChannels_WhenNonNSArrayPassed {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channels";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSString *> *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([[builderMock reject] setValue:expected forParameter:mockedParameter]);
    
    builder.channels(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: timetokens

- (void)testTimetokens_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.timetokens(@[@1234567890]), builder);
}

- (void)testTimetokens_ShouldSetChannels_WhenNSArrayPassed {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channels";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSNumber *> *expected = @[@1234567890];
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.timetokens(expected);
    
    OCMVerify(builderMock);
}

- (void)testTimetokens_ShouldNotSetChannels_WhenNonNSArrayPassed {
    
    PNMessageCountAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channels";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSNumber *> *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([[builderMock reject] setValue:expected forParameter:mockedParameter]);
    
    builder.timetokens(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Misc

- (PNMessageCountAPICallBuilder *)builder {
    
    PNAPICallCompletionBlock block = ^(NSArray<NSString *> *flags, NSDictionary *arguments) {
        
    };
    
    return [PNMessageCountAPICallBuilder builderWithExecutionBlock:block];
}

#pragma mark -


@end
