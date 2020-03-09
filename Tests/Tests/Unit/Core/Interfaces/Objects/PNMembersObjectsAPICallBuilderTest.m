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

@interface PNMembersObjectsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNManageMembersAPICallBuilder *)manageBuilder;
- (PNFetchMembersAPICallBuilder *)fetchBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMembersObjectsAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: manage :: spaceId

- (void)testItShouldReturnManageBuilderWhenSpaceIdSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSpaceIdWhenNSStringPassedAsManageSpaceId {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenEmptyNSStringPassedAsManageSpaceId {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenNonNSStringPassedAsManageSpaceId {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: filter

- (void)testItShouldReturnManageBuilderWhenFilterSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).filter(@"custom.name == 'Bob'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsManageFilter {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"custom.name like 'Darth*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsManageFilter {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsManageFilter {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: sort

- (void)testItShouldReturnManageBuilderWhenSortSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSArrayPassedAsManageSort {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSArrayPassedAsManageSort {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSArrayPassedAsManageSort {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: add

- (void)testItShouldReturnManageBuilderWhenAddUsersSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).add(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetAddWhenNSArrayPassedAsManageUsers {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenEmptyNSArrayPassedAsManageUsers {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenNonNSArrayPassedAsManageUsers {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: update

- (void)testItShouldReturnManageBuilderWhenUpdateUsersSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).update(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetUpdateWhenNSArrayPassedAsManageUsers {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUpdateWhenEmptyNSArrayPassedAsManageUsers {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUpdateWhenNonNSArrayPassedAsManageUsers {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: remove

- (void)testItShouldReturnManageBuilderWhenRemoveUsersSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).remove(@[ @"identifier" ]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testMItShouldSetRemoveWhenNSArrayPassedAsManageUsers {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[ @"identifier" ];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenEmptyNSArrayPassedAsManageUsers {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenNonNSArrayPassedAsManageUsers {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: start

- (void)testItShouldReturnManageBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self manageBuilder];

    id fetchBuilder = ((PNManageMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsManageStartToken {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsManageStartToken {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsManageStartToken {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: end

- (void)testItShouldReturnManageBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsManageEndToken {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsManageEndToken {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsManageEndToken {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: limit

- (void)testItShouldReturnManageBuilderWhenLimitSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetLimitWhenLimitSpecifiedInChain {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: includeCount

- (void)testItShouldReturnManageBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenIncludeCountSpecifiedInChain {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: includeFields

- (void)testItShouldReturnManageBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).includeFields(PNMemberCustomField);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenIncludeFieldsSpecifiedInChain {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    PNMemberFields expected = PNMemberCustomField | PNMemberUserField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: spaceId

- (void)testItShouldReturnCreateBuilderWhenSpaceIdSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetSpaceIdWhenNSStringPassedAsFetchSpaceId {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenEmptyNSStringPassedAsFetchSpaceId {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenNonNSStringPassedAsFetchSpaceId {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];

    builder.spaceId(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: filter

- (void)testItShouldReturnFetchBuilderWhenFilterSpecifiedInChain {
    id builder = [self fetchBuilder];

    id manageBuilder = ((PNFetchMembersAPICallBuilder *)builder).filter(@"custom.name == 'Bob'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsFetchFilter {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"custom.name like 'Darth*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsFetchFilter {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsFetchFilter {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: sort

- (void)testItShouldReturnFetchBuilderWhenSortSpecifiedInChain {
    id builder = [self fetchBuilder];

    id manageBuilder = ((PNFetchMembersAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSortWhenNSArrayPassedAsFetchSort {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(@[@"name", @"created:desc"]);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenEmptyNSArrayPassedAsFetchSort {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenNonNSArrayPassedAsFetchSort {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: start

- (void)testItShouldReturnFetchBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsFetchStartToken {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsFetchStartToken {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsFetchStartToken {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: end

- (void)testFetchEnd_ShouldReturnFetchBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsFetchEndToken {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsFetchEndToken {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsFetchEndToken {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: limit

- (void)testItShouldReturnFetchBuilderWhenLimitSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetLimitWhenFetchLimitSpecifiedInChain {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeCount

- (void)testItShouldReturnFetchBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenFetchIncludeCountSpecifiedInChain {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testItShouldReturnFetchBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembersAPICallBuilder *)builder).includeFields(PNMemberCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenFetchIncludeFieldsSpecifiedInChain {
    PNFetchMembersAPICallBuilder *builder = [self fetchBuilder];
    PNMemberFields expected = PNMemberCustomField | PNMemberUserCustomField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
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
        OCMReject([mockedObject setValue:value forParameter:parameter]);
    }
}

- (NSString *)mockedParameterFrom:(NSString *)parameter {
    return [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
}

#pragma mark -

#pragma clang diagnostic pop

@end
