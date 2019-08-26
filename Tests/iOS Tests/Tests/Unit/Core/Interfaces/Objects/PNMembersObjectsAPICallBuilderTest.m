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

- (PNManageMembersAPICallBuilder *)manageBuilder;
- (PNFetchMembersAPICallBuilder *)fetchBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END

@implementation PNMembersObjectsAPICallBuilderTest


#pragma mark - Tests :: manage :: spaceId

- (void)testManageUserId_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetUserId_WhenNSStringPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetUserId_WhenEmptyNSStringPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetUserId_WhenNonNSStringPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: add

- (void)testManageAdd_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).add(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetAdd_WhenNSArrayPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetAdd_WhenEmptyNSArrayPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetAdd_WhenNonNSArrayPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: update

- (void)testManageUpdate_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).update(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetUpdate_WhenNSArrayPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetUpdate_WhenEmptyNSArrayPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetUpdate_WhenNonNSArrayPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: remove

- (void)testManageRemove_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).remove(@[ @"identifier" ]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetRemove_WhenNSArrayPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[ @"identifier" ];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetRemove_WhenEmptyNSArrayPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetRemove_WhenNonNSArrayPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: start

- (void)testManageStart_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id fetchBuilder = ((PNManageMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testManage_ShouldSetStart_WhenNSStringPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetStart_WhenEmptyNSStringPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetStart_WhenNonNSStringPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: end

- (void)testManageEnd_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetEnd_WhenNSStringPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetEnd_WhenEmptyNSStringPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetEnd_WhenNonNSStringPassed {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: limit

- (void)testManageLimit_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetLimit_WhenCalled {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: includeCount

- (void)testManageIncludeCount_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetIncludeCount_WhenCalled {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(NO);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: includeFields

- (void)testManageIncludeFields_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).includeFields(PNMemberCustomField);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetIncludeFields_WhenCalled {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
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

- (PNManageMembersAPICallBuilder *)manageBuilder {
    return [PNManageMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
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
