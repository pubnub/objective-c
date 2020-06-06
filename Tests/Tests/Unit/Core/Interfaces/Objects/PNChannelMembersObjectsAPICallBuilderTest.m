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

@interface PNChannelMembersObjectsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNSetChannelMembersAPICallBuilder *)setBuilder;
- (PNRemoveChannelMembersAPICallBuilder *)removeBuilder;
- (PNManageChannelMembersAPICallBuilder *)manageBuilder;
- (PNFetchChannelMembersAPICallBuilder *)fetchBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNChannelMembersObjectsAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: set :: filter

- (void)testItShouldReturnSetBuilderWhenFilterSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetChannelMembersAPICallBuilder *)builder).filter(@"custom.name == 'Bob'");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsSetFilter {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"custom.name like 'Darth*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsSetFilter {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsSetFilter {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: sort

- (void)testItShouldReturnSetBuilderWhenSortSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetChannelMembersAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSArrayPassedAsSetSort {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSArrayPassedAsSetSort {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSArrayPassedAsSetSort {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: uuids

- (void)testItShouldReturnSetBuilderWhenAddUUIDsSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetChannelMembersAPICallBuilder *)builder).uuids(@[@{@"uuid": @"identifier" }]);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetAddWhenNSArrayPassedAsSetUUIDs {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"uuid": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenEmptyNSArrayPassedAsSetUUIDs {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenNonNSArrayPassedAsSetUUIDs {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: start

- (void)testItShouldReturnSetBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetChannelMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsSetStartToken {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsSetStartToken {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsSetStartToken {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: end

- (void)testItShouldReturnSetBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetChannelMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsSetEndToken {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsSetEndToken {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsSetEndToken {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: limit

- (void)testItShouldReturnSetBuilderWhenLimitSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetChannelMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetLimitWhenSetLimitSpecifiedInChain {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: includeCount

- (void)testItShouldReturnSetBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetChannelMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenSetIncludeCountSpecifiedInChain {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: includeFields

- (void)testItShouldReturnSetBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetChannelMembersAPICallBuilder *)builder).includeFields(PNChannelMemberCustomField);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenSetIncludeFieldsSpecifiedInChain {
    PNSetChannelMembersAPICallBuilder *builder = [self setBuilder];
    PNChannelMemberFields expected = PNChannelMemberCustomField | PNChannelMemberUUIDField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: filter

- (void)testItShouldReturnRemoveBuilderWhenFilterSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveChannelMembersAPICallBuilder *)builder).filter(@"custom.name == 'Bob'");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsRemoveFilter {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"custom.name like 'Darth*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsRemoveFilter {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsRemoveFilter {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: sort

- (void)testItShouldReturnRemoveBuilderWhenSortSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveChannelMembersAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSArrayPassedAsRemoveSort {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSArrayPassedAsRemoveSort {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSArrayPassedAsRemoveSort {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: uuids

- (void)testItShouldReturnRemoveBuilderWhenUUIDsSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveChannelMembersAPICallBuilder *)builder).uuids(@[@"identifier"]);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetUUIDsWhenNSArrayPassedAsRemoveUUIDs {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray<NSString *> *expected = @[@"identifier"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDsWhenEmptyNSArrayPassedAsRemoveUUIDs {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetAddWhenNonNSArrayPassedAsRemoveUUIDs {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuids"];

    builder.uuids(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: start

- (void)testItShouldReturnRemoveBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveChannelMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsRemoveStartToken {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsRemoveStartToken {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsRemoveStartToken {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: end

- (void)testItShouldReturnRemoveBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveChannelMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsRemoveEndToken {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsRemoveEndToken {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsRemoveEndToken {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: limit

- (void)testItShouldReturnRemoveBuilderWhenLimitSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveChannelMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetLimitWhenRemoveLimitSpecifiedInChain {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: includeCount

- (void)testItShouldReturnRemoveBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveChannelMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenRemoveIncludeCountSpecifiedInChain {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: includeFields

- (void)testItShouldReturnRemoveBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveChannelMembersAPICallBuilder *)builder).includeFields(PNChannelMemberCustomField);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenRemoveIncludeFieldsSpecifiedInChain {
    PNRemoveChannelMembersAPICallBuilder *builder = [self removeBuilder];
    PNChannelMemberFields expected = PNChannelMemberCustomField | PNChannelMemberUUIDField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: filter

- (void)testItShouldReturnManageBuilderWhenFilterSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageChannelMembersAPICallBuilder *)builder).filter(@"custom.name == 'Bob'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsManageFilter {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"custom.name like 'Darth*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsManageFilter {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsManageFilter {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: sort

- (void)testItShouldReturnManageBuilderWhenSortSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageChannelMembersAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSArrayPassedAsManageSort {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSArrayPassedAsManageSort {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSArrayPassedAsManageSort {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: set

- (void)testItShouldReturnManageBuilderWhenSetUUIDsSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageChannelMembersAPICallBuilder *)builder).set(@[@{ @"uuid": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSetWhenNSArrayPassedAsManageUUIDs {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"uuid": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"set"];

    builder.set(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSetWhenEmptyNSArrayPassedAsManageUUIDs {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"set"];

    builder.set(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSetWhenNonNSArrayPassedAsManageUUIDs {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"set"];

    builder.set(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: remove

- (void)testItShouldReturnManageBuilderWhenRemoveUUIDsSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageChannelMembersAPICallBuilder *)builder).remove(@[ @"identifier" ]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testMItShouldSetRemoveWhenNSArrayPassedAsManageUUIDs {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[ @"identifier" ];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenEmptyNSArrayPassedAsManageUUIDs {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenNonNSArrayPassedAsManageUUIDs {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: start

- (void)testItShouldReturnManageBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self manageBuilder];

    id fetchBuilder = ((PNManageChannelMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsManageStartToken {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsManageStartToken {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsManageStartToken {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: end

- (void)testItShouldReturnManageBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageChannelMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsManageEndToken {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsManageEndToken {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsManageEndToken {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: limit

- (void)testItShouldReturnManageBuilderWhenLimitSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageChannelMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetLimitWhenLimitSpecifiedInChain {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: includeCount

- (void)testItShouldReturnManageBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageChannelMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenIncludeCountSpecifiedInChain {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: includeFields

- (void)testItShouldReturnManageBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageChannelMembersAPICallBuilder *)builder).includeFields(PNChannelMemberCustomField);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenIncludeFieldsSpecifiedInChain {
    PNManageChannelMembersAPICallBuilder *builder = [self manageBuilder];
    PNChannelMemberFields expected = PNChannelMemberCustomField | PNChannelMemberUUIDField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: filter

- (void)testItShouldReturnFetchBuilderWhenFilterSpecifiedInChain {
    id builder = [self fetchBuilder];

    id manageBuilder = ((PNFetchChannelMembersAPICallBuilder *)builder).filter(@"custom.name == 'Bob'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsFetchFilter {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"custom.name like 'Darth*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsFetchFilter {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsFetchFilter {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: sort

- (void)testItShouldReturnFetchBuilderWhenSortSpecifiedInChain {
    id builder = [self fetchBuilder];

    id manageBuilder = ((PNFetchChannelMembersAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSortWhenNSArrayPassedAsFetchSort {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(@[@"name", @"created:desc"]);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenEmptyNSArrayPassedAsFetchSort {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenNonNSArrayPassedAsFetchSort {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: start

- (void)testItShouldReturnFetchBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchChannelMembersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsFetchStartToken {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsFetchStartToken {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsFetchStartToken {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: end

- (void)testFetchEnd_ShouldReturnFetchBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchChannelMembersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsFetchEndToken {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsFetchEndToken {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsFetchEndToken {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: limit

- (void)testItShouldReturnFetchBuilderWhenLimitSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchChannelMembersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetLimitWhenFetchLimitSpecifiedInChain {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeCount

- (void)testItShouldReturnFetchBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchChannelMembersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenFetchIncludeCountSpecifiedInChain {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testItShouldReturnFetchBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchChannelMembersAPICallBuilder *)builder).includeFields(PNChannelMemberCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenFetchIncludeFieldsSpecifiedInChain {
    PNFetchChannelMembersAPICallBuilder *builder = [self fetchBuilder];
    PNChannelMemberFields expected = PNChannelMemberCustomField | PNChannelMemberUUIDCustomField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNSetChannelMembersAPICallBuilder *)setBuilder {
    return [PNSetChannelMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *arguments) {
    }];
}

- (PNRemoveChannelMembersAPICallBuilder *)removeBuilder {
    return [PNRemoveChannelMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                      NSDictionary *arguments) {
    }];
}

- (PNManageChannelMembersAPICallBuilder *)manageBuilder {
    return [PNManageChannelMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                      NSDictionary *arguments) {
    }];
}

- (PNFetchChannelMembersAPICallBuilder *)fetchBuilder {
    return [PNFetchChannelMembersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
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
