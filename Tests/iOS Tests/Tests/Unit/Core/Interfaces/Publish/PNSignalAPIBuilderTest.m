#import <XCTest/XCTest.h>
#import <PubNub/PNAPICallBuilder+Private.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


#pragma mark Test interface declaration

@interface PNSignalAPIBuilderTest : XCTestCase


#pragma mark - Misc

- (PNSignalAPICallBuilder *)builder;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNSignalAPIBuilderTest


#pragma mark - Tests :: channel

- (void)testChannel_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    PNSignalAPICallBuilder *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.channel(@"PubNub"), builder);
}

- (void)testChannel_ShouldSetChannel_WhenNSStringPassed {
    
    PNSignalAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channel";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}

- (void)testChannel_ShouldNotSetChannel_WhenNonNSStringPassed {
    
    PNSignalAPICallBuilder *builder = [self builder];
    NSString *parameter = @"channel";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = (id)@[@"PubNub"];
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([[builderMock reject] setValue:expected forParameter:mockedParameter]);
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: message

- (void)testMessage_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    PNSignalAPICallBuilder *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.message(@[@1234567890]), builder);
}

- (void)testMessage_ShouldSetMessage_WhenDataPassed {
    
    PNSignalAPICallBuilder *builder = [self builder];
    NSString *parameter = @"message";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSArray<NSNumber *> *expected = @[@1234567890];
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.message(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: metadata

- (void)testMetadata_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    PNSignalAPICallBuilder *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.metadata(@{ @"userID": @"PubNub" }), builder);
}

- (void)testMetadata_ShouldSetMetadata_WhenNSDictionaryPassed {
    
    PNSignalAPICallBuilder *builder = [self builder];
    NSString *parameter = @"metadata";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSDictionary *expected = @{ @"userID": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock setValue:expected forParameter:mockedParameter]);
    
    builder.metadata(expected);
    
    OCMVerify(builderMock);
}

- (void)testMetadata_ShouldNotSetMetadata_WhenNonNSDictionaryPassed {
    
    PNSignalAPICallBuilder *builder = [self builder];
    NSString *parameter = @"metadata";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSDictionary *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    OCMExpect([[builderMock reject] setValue:expected forParameter:mockedParameter]);
    
    builder.metadata(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Misc

- (PNSignalAPICallBuilder *)builder {
    
    PNAPICallCompletionBlock block = ^(NSArray<NSString *> *flags, NSDictionary *arguments) {
        
    };
    
    return [PNSignalAPICallBuilder builderWithExecutionBlock:block];
}

#pragma mark -


@end
