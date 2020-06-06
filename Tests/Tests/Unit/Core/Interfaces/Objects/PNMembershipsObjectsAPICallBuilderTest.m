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

- (PNSetMembershipsAPICallBuilder *)setBuilder;
- (PNRemoveMembershipsAPICallBuilder *)removeBuilder;
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


#pragma mark - Tests :: set :: uuid

- (void)testItShouldReturnSetBuilderWhenUUIDSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembershipsAPICallBuilder *)builder).uuid(@"id");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetUUIDWhenNSStringPassedAsSetUUID {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenEmptyNSStringPassedAsSetUUID {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenNonNSStringPassedAsSetUUID {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: filter

- (void)testItShouldReturnSetBuilderWhenFilterSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembershipsAPICallBuilder *)builder).filter(@"custom.name == 'lobby'");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsSetFilter {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"custom.name like 'secret-*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsSetFilter {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsSetFilter {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: sort

- (void)testItShouldReturnSetBuilderWhenSortSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembershipsAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSArrayPassedAsSetSort {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSArrayPassedAsSetSort {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSArrayPassedAsSetSort {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: channels

- (void)testItShouldReturnSetBuilderWhenChannelsSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembershipsAPICallBuilder *)builder).channels(@[@{@"channel": @"identifier" }]);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetChannelsWhenNSArrayPassedAsSetChannels {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"channel": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"channels"];

    builder.channels(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelsWhenEmptyNSArrayPassedAsSetChannels {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channels"];

    builder.channels(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelsWhenNonNSArrayPassedAsSetChannels {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channels"];

    builder.channels(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: start

- (void)testItShouldReturnSetBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembershipsAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsSetStartToken {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsSetStartToken {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsSetStartToken {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: end

- (void)testItShouldReturnSetBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembershipsAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsSetEndToken {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsSetEndToken {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsSetEndToken {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: limit

- (void)testItShouldReturnSetBuilderWhenLimitSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembershipsAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetLimitWhenSetLimitSpecifiedInChain {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: includeCount

- (void)testItShouldReturnSetBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembershipsAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenSetIncludeCountSpecifiedInChain {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: includeFields

- (void)testItShouldReturnSetBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self setBuilder];

    id setBuilder = ((PNSetMembershipsAPICallBuilder *)builder).includeFields(PNMembershipCustomField);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenSetIncludeFieldsSpecifiedInChain {
    PNSetMembershipsAPICallBuilder *builder = [self setBuilder];
    PNMembershipFields expected = PNMembershipCustomField | PNMembershipChannelField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: uuid

- (void)testItShouldReturnRemoveBuilderWhenUUIDSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembershipsAPICallBuilder *)builder).uuid(@"id");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetUUIDWhenNSStringPassedAsRemoveUUID {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenEmptyNSStringPassedAsRemoveUUID {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenNonNSStringPassedAsRemoveUUID {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: filter

- (void)testItShouldReturnRemoveBuilderWhenFilterSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembershipsAPICallBuilder *)builder).filter(@"custom.name == 'lobby'");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsRemoveFilter {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"custom.name like 'secret-*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsRemoveFilter {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsRemoveFilter {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: sort

- (void)testItShouldReturnRemoveBuilderWhenSortSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembershipsAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSArrayPassedAsRemoveSort {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSArrayPassedAsRemoveSort {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSArrayPassedAsRemoveSort {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: channels

- (void)testItShouldReturnRemoveBuilderWhenChannelsSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembershipsAPICallBuilder *)builder).channels(@[@"identifier"]);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetChannelsWhenNSArrayPassedAsRemoveChannels {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSArray<NSString *> *expected = @[@"identifier"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"channels"];

    builder.channels(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelsWhenEmptyNSArrayPassedAsRemoveChannels {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channels"];

    builder.channels(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelsWhenNonNSArrayPassedAsRemoveChannels {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSArray<NSString *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channels"];

    builder.channels(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: start

- (void)testItShouldReturnRemoveBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembershipsAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsRemoveStartToken {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsRemoveStartToken {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsRemoveStartToken {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];

    builder.start(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: end

- (void)testItShouldReturnRemoveBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembershipsAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsRemoveEndToken {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"NjA";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsRemoveEndToken {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsRemoveEndToken {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];

    builder.end(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: limit

- (void)testItShouldReturnRemoveBuilderWhenLimitSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembershipsAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetLimitWhenRemoveLimitSpecifiedInChain {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSNumber *expected = @35;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];

    builder.limit(35);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: includeCount

- (void)testItShouldReturnRemoveBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembershipsAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenRemoveIncludeCountSpecifiedInChain {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    NSNumber *expected = @YES;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];

    builder.includeCount(YES);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: includeFields

- (void)testItShouldReturnRemoveBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self removeBuilder];

    id removeBuilder = ((PNRemoveMembershipsAPICallBuilder *)builder).includeFields(PNMembershipCustomField);
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenRemoveIncludeFieldsSpecifiedInChain {
    PNRemoveMembershipsAPICallBuilder *builder = [self removeBuilder];
    PNMembershipFields expected = PNMembershipCustomField | PNMembershipChannelField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: uuid

- (void)testItShouldReturnManageBuilderWhenUUIDSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).uuid(@"id");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetUUIDWhenNSStringPassedAsManageUUID {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenEmptyNSStringPassedAsManageUUID {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenNonNSStringPassedAsManageUUID {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

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


#pragma mark - Tests :: manage :: set

- (void)testItShouldReturnManageBuilderWhenSetChannelsSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).set(@[@{ @"channel": @"identifier" }]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSetWhenNSArrayPassedAsManageSetChannels {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[@{ @"channel": @"identifier" }];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"set"];

    builder.set(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSetWhenEmptyNSArrayPassedAsManageSetChannels {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"set"];

    builder.set(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSetWhenNonNSArrayPassedAsManageSetChannels {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSDictionary *> *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"set"];

    builder.set(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: manage :: remove

- (void)testItShouldReturnManageBuilderWhenRemoveChannelsSpecifiedInChain {
    id builder = [self manageBuilder];

    id manageBuilder = ((PNManageMembershipsAPICallBuilder *)builder).remove(@[ @"identifier" ]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetRemoveWhenNSArrayPassedAsManageRemoveChannels {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[ @"identifier" ];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenEmptyNSArrayPassedAsManageRemoveChannels {
    PNManageMembershipsAPICallBuilder *builder = [self manageBuilder];
    NSArray<NSString *> *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"remove"];

    builder.remove(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetRemoveWhenNonNSArrayPassedAsManageRemoveChannels {
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
    PNMembershipFields expected = PNMembershipCustomField | PNMembershipChannelField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: uuid

- (void)testItShouldReturnFetchBuilderWhenUUIDSpecifiedInChain {
    id builder = [self fetchBuilder];

    id fetchBuilder = ((PNFetchMembershipsAPICallBuilder *)builder).uuid(@"id");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetUUIDWhenNSStringPassedAsFetchUUID {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenEmptyNSStringPassedAsFetchUUID {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenNonNSStringPassedAsFetchUUID {
    PNFetchMembershipsAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];

    builder.uuid(expected);

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
    PNMembershipFields expected = PNMembershipCustomField | PNMembershipChannelField;


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];

    builder.includeFields(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNSetMembershipsAPICallBuilder *)setBuilder {
    return [PNSetMembershipsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                       NSDictionary *arguments) {
    }];
}

- (PNRemoveMembershipsAPICallBuilder *)removeBuilder {
    return [PNRemoveMembershipsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                          NSDictionary *arguments) {
    }];
}

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
