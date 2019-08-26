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

- (PNManageMembershipsAPICallBuilder *)manageBuilder;
- (PNFetchMembershipsAPICallBuilder *)fetchBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END

@implementation PNMembershipsObjectsAPICallBuilderTest


#pragma mark - Tests :: manage :: userId

- (void)testManageUserId_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetUserId_WhenNSStringPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetUserId_WhenEmptyNSStringPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetUserId_WhenNonNSStringPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: add

- (void)testManageAdd_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).add(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetAdd_WhenNSArrayPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetAdd_WhenEmptyNSArrayPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetAdd_WhenNonNSArrayPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: update

- (void)testManageUpdate_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).update(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetUpdate_WhenNSArrayPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetUpdate_WhenEmptyNSArrayPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetUpdate_WhenNonNSArrayPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: remove

- (void)testManageRemove_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).remove(@[ @"identifier" ]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetRemove_WhenNSArrayPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[ @"identifier" ];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetRemove_WhenEmptyNSArrayPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetRemove_WhenNonNSArrayPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: start

- (void)testManageStart_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id fetchBuilder = ((PNManageMembershipsAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testManage_ShouldSetStart_WhenNSStringPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetStart_WhenEmptyNSStringPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetStart_WhenNonNSStringPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: end

- (void)testManageEnd_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetEnd_WhenNSStringPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetEnd_WhenEmptyNSStringPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}

- (void)testManage_ShouldNotSetEnd_WhenNonNSStringPassed {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: limit

- (void)testManageLimit_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id fetchBuilder = ((PNManageMembershipsAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testManage_ShouldSetLimit_WhenCalled {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: includeCount

- (void)testManageIncludeCount_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetIncludeCount_WhenCalled {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(NO);

    OCMVerify(builderMock);
}


#pragma mark - Tests :: manage :: includeFields

- (void)testManageIncludeFields_ShouldReturnManageBuilder_WhenCalled {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).includeFields(PNMembershipCustomField);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testManage_ShouldSetIncludeFields_WhenCalled {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
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

- (PNManageMembershipsAPICallBuilder *)manageBuilder {
    return [PNManageMembershipsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
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
