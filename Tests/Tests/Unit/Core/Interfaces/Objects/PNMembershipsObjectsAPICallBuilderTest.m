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

@interface PNMembershipsObjectsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNManageMembershipsAPICallBuilder *)manageBuilder;
- (PNFetchMembershipsAPICallBuilder *)fetchBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMembershipsObjectsAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: manage :: userId

- (void)testItShouldReturnManageBuilderWhenUserIdSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetUserIdWhenNSStringPassedAsManageUserId {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenEmptyNSStringPassedAsManageUserId {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenNonNSStringPassedAsManageUserId {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: filter

- (void)testItShouldReturnManageBuilderWhenFilterSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).filter(@"custom.name == 'lobby'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsManageFilter {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"custom.name like 'secret-*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsManageFilter {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsManageFilter {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: sort

- (void)testItShouldReturnManageBuilderWhenSortSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSArrayPassedAsManageSort {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSArrayPassedAsManageSort {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSArrayPassedAsManageSort {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: add

- (void)testItShouldReturnManageBuilderWhenAddSpacesSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).add(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetAddWhenNSArrayPassedAsManageSpaces {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenEmptyNSArrayPassedAsManageSpaces {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenNonNSArrayPassedAsManageSpaces {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"add"];

    builder.add(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: update

- (void)testItShouldReturnManageBuilderWhenUpdateSpacesSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).update(@[@{ @"id": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetUpdateWhenNSArrayPassedAsManageSpaces {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"id": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUpdateWhenEmptyNSArrayPassedAsManageSpaces {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUpdateWhenNonNSArrayPassedAsManageSpaces {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"update"];

    builder.update(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: remove

- (void)testItShouldReturnManageBuilderWhenRemoveSpacesSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).remove(@[ @"identifier" ]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetRemoveWhenNSArrayPassedAsManageSpaces {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[ @"identifier" ];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenEmptyNSArrayPassedAsManageSpaces {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenNonNSArrayPassedAsManageSpaces {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: start

- (void)testItShouldReturnManageBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self manageBuilder];

    id fetchBuilder = ((PNManageMembershipsAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsManageStartToken {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsManageStartToken {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsManageStartToken {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: end

- (void)testItShouldReturnManageBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsManageEndToken {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsManageEndToken {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsManageEndToken {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: limit

- (void)testItShouldReturnManageBuilderWhenLimitSpecifiedInChain {
    id builder = [self manageBuilder];

    id fetchBuilder = ((PNManageMembershipsAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetLimitWhenManageLimitSpecifiedInChain {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: includeCount

- (void)testItShouldReturnManageBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenManageIncludeCountSpecifiedInChain {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: includeFields

- (void)testItShouldReturnManageBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).includeFields(PNMembershipCustomField);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenManageIncludeFieldsSpecifiedInChain {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    PNMembershipFields expected = PNMembershipCustomField | PNMembershipSpaceField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: userId

- (void)testItShouldReturnFetchBuilderWhenUserIdSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetUserIdWhenNSStringPassedAsFetchUserId {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenEmptyNSStringPassedAsFetchUserId {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenNonNSStringPassedAsFetchUserId {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];

    builder.userId(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: filter

- (void)testItShouldReturnFetchBuilderWhenFilterSpecifiedInChain {
    id builder = [self fetchBuilder];

    id manageBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).filter(@"custom.name == 'lobby'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsFetchFilter {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"custom.name like 'secret-*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsFetchFilter {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsFetchFilter {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: sort

- (void)testItShouldReturnFetchBuilderWhenSortSpecifiedInChain {
    id builder = [self fetchBuilder];

    id manageBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSortWhenNSArrayPassedAsFetchSort {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenEmptyNSArrayPassedAsFetchSort {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenNonNSArrayPassedAsFetchSort {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: start

- (void)testItShouldReturnFetchBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsFetchStartToken {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsFetchStartToken {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsFetchStartToken {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: end

- (void)testItShouldReturnFetchBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsFetchEndToken {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsFetchEndToken {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsFetchEndToken {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: limit

- (void)testItShouldReturnFetchBuilderWhenLimitTokenSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetLimitWhenFetchLimitSpecifiedInChain {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeCount

- (void)testItShouldReturnFetchBuilderWhenFetchIncludeCountSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenFetchIncludeCountSpecifiedInChain {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testItShouldReturnFetchBuilderWhenFetchIncludeFieldsSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).includeFields(PNMembershipCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenFetchIncludeFieldsSpecifiedInChain {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    PNMembershipFields expected = PNMembershipCustomField | PNMembershipSpaceCustomField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
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
        OCMReject([mockedObject setValue:value forParameter:parameter]);
    }
}

- (NSString *)mockedParameterFrom:(NSString *)parameter {
    return [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
}

#pragma mark -

#pragma clang diagnostic pop

@end
