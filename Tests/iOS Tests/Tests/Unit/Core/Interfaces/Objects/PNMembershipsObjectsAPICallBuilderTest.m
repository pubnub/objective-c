/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PNAPICallBuilder+Private.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Test interface declaration

@interface PNMembershipsObjectsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNUpdateMembershipsAPICallBuilder *)updateBuilder;
- (PNFetchMembershipsAPICallBuilder *)fetchBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END

@implementation PNMembershipsObjectsAPICallBuilderTest


#pragma mark - Tests :: update :: userId

- (void)testUpdateUserId_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembershipsAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetUserId_WhenNSStringPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUserId_WhenEmptyNSStringPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUserId_WhenNonNSStringPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: add

- (void)testUpdateAdd_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembershipsAPICallBuilder *)builder).add(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetAdd_WhenNSArrayPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetAdd_WhenEmptyNSArrayPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetAdd_WhenNonNSArrayPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: update

- (void)testUpdateUpdate_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembershipsAPICallBuilder *)builder).update(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetUpdate_WhenNSArrayPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUpdate_WhenEmptyNSArrayPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUpdate_WhenNonNSArrayPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: remove

- (void)testUpdateRemove_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembershipsAPICallBuilder *)builder).remove(@[ @"identifier" ]);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetRemove_WhenNSArrayPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSString *> *expected = @[ @"identifier" ];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetRemove_WhenEmptyNSArrayPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetRemove_WhenNonNSArrayPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: start

- (void)testUpdateStart_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id fetchBuilder = ((PNUpdateMembershipsAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testUpdate_ShouldSetStart_WhenNSStringPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetStart_WhenEmptyNSStringPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetStart_WhenNonNSStringPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: end

- (void)testUpdateEnd_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembershipsAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetEnd_WhenNSStringPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetEnd_WhenEmptyNSStringPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetEnd_WhenNonNSStringPassed {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: limit

- (void)testUpdateLimit_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id fetchBuilder = ((PNUpdateMembershipsAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testUpdate_ShouldSetLimit_WhenCalled {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: includeCount

- (void)testUpdateIncludeCount_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembershipsAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetIncludeCount_WhenCalled {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(NO);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: includeFields

- (void)testUpdateIncludeFields_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembershipsAPICallBuilder *)builder).includeFields(PNMembershipCustomField);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetIncludeFields_WhenCalled {
    PNUpdateMembershipsAPICallBuilder *builder = [self updateBuilder];
    PNMembershipFields expected = PNMembershipCustomField | PNMembershipSpaceField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: userId

- (void)testFetchUserId_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetUserId_WhenNSStringPassed {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetUserId_WhenEmptyNSStringPassed {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetUserId_WhenNonNSStringPassed {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: start

- (void)testFetchStart_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetStart_WhenNSStringPassed {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetStart_WhenEmptyNSStringPassed {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetStart_WhenNonNSStringPassed {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: end

- (void)testFetchEnd_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetEnd_WhenNSStringPassed {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetEnd_WhenEmptyNSStringPassed {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetEnd_WhenNonNSStringPassed {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: limit

- (void)testFetchLimit_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetLimit_WhenCalled {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: includeCount

- (void)testFetchIncludeCount_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetIncludeCount_WhenCalled {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(NO);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testFetchIncludeFields_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).includeFields(PNMembershipCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetIncludeFields_WhenCalled {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    PNMembershipFields expected = PNMembershipCustomField | PNMembershipSpaceCustomField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerify(builderMock);
}


#pragma mark - Misc

- (PNUpdateMembershipsAPICallBuilder *)updateBuilder {
    return [PNUpdateMembershipsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                          NSDictionary *arguments) {
    }];
}

- (PNFetchMembershipsAPICallBuilder *)fetchBuilder {
    return [PNFetchMembershipsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                         NSDictionary *arguments) {
    }];
}

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter {
    parameter = [self mockedParameterFrom:parameter];

    if (shouldCall) {
        OCMExpect([mockedObject setValue:value forParameter:parameter]);
    } else {
        OCMExpect([[mockedObject reject] setValue:value forParameter:parameter]);
    }
}

- (NSString *)mockedParameterFrom:(NSString *)parameter {
    return [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
}

#pragma mark -


@end
