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

- (PNSetMembersAPICallBuilder *)setBuilder;
- (PNRemoveMembersAPICallBuilder *)removeBuilder;
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


#pragma mark - Tests :: set :: filter

- (void)testItShouldReturnSetBuilderWhenFilterSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembersAPICallBuilder *)builder).filter(@"custom.name == 'Bob'");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsSetFilter {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"custom.name like 'Darth*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsSetFilter {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsSetFilter {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: sort

- (void)testItShouldReturnSetBuilderWhenSortSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembersAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSArrayPassedAsSetSort {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSArrayPassedAsSetSort {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSArrayPassedAsSetSort {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: uuids

- (void)testItShouldReturnSetBuilderWhenAddUUIDsSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembersAPICallBuilder *)builder).uuids(@[@{@"uuid": @"identifier" }]);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetAddWhenNSArrayPassedAsSetUUIDs {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"uuid": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenEmptyNSArrayPassedAsSetUUIDs {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenNonNSArrayPassedAsSetUUIDs {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: start

- (void)testItShouldReturnSetBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsSetStartToken {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsSetStartToken {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsSetStartToken {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: end

- (void)testItShouldReturnSetBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsSetEndToken {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsSetEndToken {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsSetEndToken {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: limit

- (void)testItShouldReturnSetBuilderWhenLimitSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetLimitWhenSetLimitSpecifiedInChain {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: includeCount

- (void)testItShouldReturnSetBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenSetIncludeCountSpecifiedInChain {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: includeFields

- (void)testItShouldReturnSetBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembersAPICallBuilder *)builder).includeFields(PNMemberCustomField);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenSetIncludeFieldsSpecifiedInChain {
    PNSetMembersAPICallBuilder *builder = [self setBuilder];
    PNMemberFields expected = PNMemberCustomField | PNMemberUUIDField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: filter

- (void)testItShouldReturnRemoveBuilderWhenFilterSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembersAPICallBuilder *)builder).filter(@"custom.name == 'Bob'");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsRemoveFilter {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"custom.name like 'Darth*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsRemoveFilter {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsRemoveFilter {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: sort

- (void)testItShouldReturnRemoveBuilderWhenSortSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembersAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSArrayPassedAsRemoveSort {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSArrayPassedAsRemoveSort {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSArrayPassedAsRemoveSort {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: uuids

- (void)testItShouldReturnRemoveBuilderWhenUUIDsSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembersAPICallBuilder *)builder).uuids(@[@"identifier"]);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetUUIDsWhenNSArrayPassedAsRemoveUUIDs {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray<NSString *> *expected = @[@"identifier"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDsWhenEmptyNSArrayPassedAsRemoveUUIDs {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenNonNSArrayPassedAsRemoveUUIDs {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: start

- (void)testItShouldReturnRemoveBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsRemoveStartToken {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsRemoveStartToken {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsRemoveStartToken {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: end

- (void)testItShouldReturnRemoveBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsRemoveEndToken {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsRemoveEndToken {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsRemoveEndToken {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: limit

- (void)testItShouldReturnRemoveBuilderWhenLimitSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetLimitWhenRemoveLimitSpecifiedInChain {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: includeCount

- (void)testItShouldReturnRemoveBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenRemoveIncludeCountSpecifiedInChain {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: includeFields

- (void)testItShouldReturnRemoveBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembersAPICallBuilder *)builder).includeFields(PNMemberCustomField);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenRemoveIncludeFieldsSpecifiedInChain {
    PNRemoveMembersAPICallBuilder *builder = [self removeBuilder];
    PNMemberFields expected = PNMemberCustomField | PNMemberUUIDField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

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


#pragma mark - Tests :: manage :: set

- (void)testItShouldReturnManageBuilderWhenSetUUIDsSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).set(@[@{ @"uuid": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSetWhenNSArrayPassedAsManageUUIDs {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"uuid": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"set"];

    builder.set(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSetWhenEmptyNSArrayPassedAsManageUUIDs {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"set"];

    builder.set(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSetWhenNonNSArrayPassedAsManageUUIDs {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"set"];

    builder.set(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: remove

- (void)testItShouldReturnManageBuilderWhenRemoveUUIDsSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembersAPICallBuilder *)builder).remove(@[ @"identifier" ]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testMItShouldSetRemoveWhenNSArrayPassedAsManageUUIDs {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[ @"identifier" ];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenEmptyNSArrayPassedAsManageUUIDs {
    PNManageMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenNonNSArrayPassedAsManageUUIDs {
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
    PNMemberFields expected = PNMemberCustomField | PNMemberUUIDField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

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
    PNMemberFields expected = PNMemberCustomField | PNMemberUUIDCustomField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNSetMembersAPICallBuilder *)setBuilder {
    return [PNSetMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *arguments) {
    }];
}

- (PNRemoveMembersAPICallBuilder *)removeBuilder {
    return [PNRemoveMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                      NSDictionary *arguments) {
    }];
}

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
