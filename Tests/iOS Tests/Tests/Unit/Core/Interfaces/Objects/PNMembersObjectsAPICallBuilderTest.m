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

@interface PNMembersObjectsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNUpdateMembersAPICallBuilder *)updateBuilder;
- (PNFetchMembersAPICallBuilder *)fetchBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END

@implementation PNMembersObjectsAPICallBuilderTest


#pragma mark - Tests :: update :: spaceId

- (void)testUpdateUserId_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembersAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetUserId_WhenNSStringPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUserId_WhenEmptyNSStringPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUserId_WhenNonNSStringPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: add

- (void)testUpdateAdd_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembersAPICallBuilder *)builder).add(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetAdd_WhenNSArrayPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetAdd_WhenEmptyNSArrayPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetAdd_WhenNonNSArrayPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: update

- (void)testUpdateUpdate_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembersAPICallBuilder *)builder).update(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetUpdate_WhenNSArrayPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUpdate_WhenEmptyNSArrayPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUpdate_WhenNonNSArrayPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: remove

- (void)testUpdateRemove_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembersAPICallBuilder *)builder).remove(@[ @"identifier" ]);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetRemove_WhenNSArrayPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSString *> *expected = @[ @"identifier" ];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetRemove_WhenEmptyNSArrayPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetRemove_WhenNonNSArrayPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: start

- (void)testUpdateStart_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id fetchBuilder = ((PNUpdateMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testUpdate_ShouldSetStart_WhenNSStringPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetStart_WhenEmptyNSStringPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetStart_WhenNonNSStringPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: end

- (void)testUpdateEnd_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetEnd_WhenNSStringPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetEnd_WhenEmptyNSStringPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetEnd_WhenNonNSStringPassed {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: limit

- (void)testUpdateLimit_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id fetchBuilder = ((PNUpdateMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testUpdate_ShouldSetLimit_WhenCalled {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: includeCount

- (void)testUpdateIncludeCount_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetIncludeCount_WhenCalled {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(NO);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: includeFields

- (void)testUpdateIncludeFields_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];

    id updateBuilder = ((PNUpdateMembersAPICallBuilder *)builder).includeFields(PNMemberCustomField);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetIncludeFields_WhenCalled {
    PNUpdateMembersAPICallBuilder *builder = [self updateBuilder];
    PNMemberFields expected = PNMemberCustomField | PNMemberUserField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: spaceId

- (void)testFetchSpaceId_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetSpaceId_WhenNSStringPassed {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetSpaceId_WhenEmptyNSStringPassed {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetSpaceId_WhenNonNSStringPassed {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: start

- (void)testFetchStart_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetStart_WhenNSStringPassed {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetStart_WhenEmptyNSStringPassed {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetStart_WhenNonNSStringPassed {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: end

- (void)testFetchEnd_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetEnd_WhenNSStringPassed {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetEnd_WhenEmptyNSStringPassed {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetEnd_WhenNonNSStringPassed {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: limit

- (void)testFetchLimit_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetLimit_WhenCalled {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: includeCount

- (void)testFetchIncludeCount_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetIncludeCount_WhenCalled {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(NO);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testFetchIncludeFields_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).includeFields(PNMemberCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetIncludeFields_WhenCalled {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    PNMemberFields expected = PNMemberCustomField | PNMemberUserCustomField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerify(builderMock);
}


#pragma mark - Misc

- (PNUpdateMembersAPICallBuilder *)updateBuilder {
    return [PNUpdateMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                      NSDictionary *arguments) {
    }];
}

- (PNFetchMembersAPICallBuilder *)fetchBuilder {
    return [PNFetchMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
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
