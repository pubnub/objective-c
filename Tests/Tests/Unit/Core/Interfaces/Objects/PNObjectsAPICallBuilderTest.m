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

@interface PNObjectsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNObjectsAPICallBuilder *)objectsBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNObjectsAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: uuid :: setUUIDMetadata

- (void)testItShouldReturnSetUUIDMetadataBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.setUUIDMetadata() isKindOfClass:[PNSetUUIDMetadataAPICallBuilder class]]);
}


#pragma mark - Tests :: uuid :: removeUUIDMetadata

- (void)testItShouldReturnRemoveUUIDMetadataBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.removeUUIDMetadata() isKindOfClass:[PNRemoveUUIDMetadataAPICallBuilder class]]);
}


#pragma mark - Tests :: uuid :: uuidMetadata

- (void)testItShouldReturnUUIDMetadataBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.uuidMetadata() isKindOfClass:[PNFetchUUIDMetadataAPICallBuilder class]]);
}


#pragma mark - Tests :: uuid :: allUUIDMetadata

- (void)testItShouldReturnAllUUIDMetadataBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.allUUIDMetadata() isKindOfClass:[PNFetchAllUUIDMetadataAPICallBuilder class]]);
}


#pragma mark - Tests :: channel :: setChannelMetadata

- (void)testItShouldReturnSetChannelMetadataBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.setChannelMetadata(@"secret") isKindOfClass:[PNSetChannelMetadataAPICallBuilder class]]);
}

- (void)testItShouldSetChannelWhenNSStringPassedToSetChannelMetadata {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.setChannelMetadata(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedToSetChannelMetadata {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.setChannelMetadata(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedToSetChannelMetadata {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.setChannelMetadata(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: channel :: removeChannelMetadata

- (void)testItShouldReturnRemoveChannelMetadataBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.removeChannelMetadata(@"secret") isKindOfClass:[PNRemoveChannelMetadataAPICallBuilder class]]);
}

- (void)testItShouldSetChannelWhenNSStringPassedToRemoveChannel {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.removeChannelMetadata(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedToRemoveChannel {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.removeChannelMetadata(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedToRemoveChannel {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.removeChannelMetadata(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: channel :: channelMetadata

- (void)testItShouldReturnChannelMetadataBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.channelMetadata(@"secret") isKindOfClass:[PNFetchChannelMetadataAPICallBuilder class]]);
}

- (void)testItShouldSetChannelWhenNSStringPassedToChannelMetadata {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channelMetadata(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedToChannelMetadata {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channelMetadata(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedToChannelMetadata {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channelMetadata(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: channel :: allChannelsMetadata

- (void)testItShouldReturnAllChannelMetadataBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.allChannelsMetadata() isKindOfClass:[PNFetchAllChannelsMetadataAPICallBuilder class]]);
}


#pragma mark - Tests :: membership :: manageMemberships

- (void)testItShouldReturnManageMembershipsBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.manageMemberships() isKindOfClass:[PNManageMembershipsAPICallBuilder class]]);
}


#pragma mark - Tests :: membership :: setMemberships

- (void)testItShouldReturnSetMembershipsBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.setMemberships() isKindOfClass:[PNSetMembershipsAPICallBuilder class]]);
}


#pragma mark - Tests :: membership :: removeMemberships

- (void)testItShouldReturnRemoveMembershipBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.removeMemberships() isKindOfClass:[PNRemoveMembershipsAPICallBuilder class]]);
}


#pragma mark - Tests :: membership :: memberships

- (void)testItShouldReturnFetchMembershipsBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.memberships() isKindOfClass:[PNFetchMembershipsAPICallBuilder class]]);
}


#pragma mark - Tests :: member :: manageMembers

- (void)testItShouldReturnManageMembersBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.manageMembers(@"secret") isKindOfClass:[PNManageMembersAPICallBuilder class]]);
}

- (void)testItShouldSetChannelWhenNSStringPassedToManageMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.manageMembers(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedToManageMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.manageMembers(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedToManageMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.manageMembers(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: member :: setMembers

- (void)testItShouldReturnSetMembersBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.setMembers(@"secret") isKindOfClass:[PNSetMembersAPICallBuilder class]]);
}

- (void)testItShouldSetChannelWhenNSStringPassedToSetMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.setMembers(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedToSetMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.setMembers(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedToSetMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.setMembers(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: member :: removeMembers

- (void)testItShouldReturnRemoveMembersBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.removeMembers(@"secret") isKindOfClass:[PNRemoveMembersAPICallBuilder class]]);
}

- (void)testItShouldSetChannelWhenNSStringPassedToRemoveMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.removeMembers(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedToRemoveMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.removeMembers(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedToRemoveMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.removeMembers(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: member :: members

- (void)testItShouldReturnFetchMembersBuilderWhenCalled {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    
    
    XCTAssertTrue([builder.members(@"secret") isKindOfClass:[PNFetchMembersAPICallBuilder class]]);
}

- (void)testItShouldSetChannelWhenNSStringPassedToFetchMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.members(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedToFetchMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.members(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedToFetchMembers {
    PNObjectsAPICallBuilder *builder = [self objectsBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.members(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNObjectsAPICallBuilder *)objectsBuilder {
    return [PNObjectsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                NSDictionary *arguments) {
    }];
}

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter {
    parameter = [self mockedParameterFrom:parameter];
    
    if (shouldCall) {
        OCMExpect([mockedObject setValue:value forParameter:parameter]);
    } else {
        OCMReject([mockedObject setValue:value forParameter:parameter]);
    }
}

- (NSString *)mockedParameterFrom:(NSString *)parameter {
    return [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
}

#pragma mark -

#pragma clang diagnostic pop

@end
