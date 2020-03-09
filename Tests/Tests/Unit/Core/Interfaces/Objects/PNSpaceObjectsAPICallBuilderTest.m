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

@interface PNSpaceObjectsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNCreateSpaceAPICallBuilder *)createBuilder;
- (PNUpdateSpaceAPICallBuilder *)updateBuilder;
- (PNDeleteSpaceAPICallBuilder *)deleteBuilder;
- (PNFetchSpaceAPICallBuilder *)fetchBuilder;
- (PNFetchSpacesAPICallBuilder *)fetchAllBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNSpaceObjectsAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: create :: spaceId

- (void)testItShouldReturnCreateBuilderWhenSpaceIdSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateSpaceAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetSpaceIdWhenNSStringPassedAsCreateSpaceId {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenEmptyNSStringPassedAsCreateSpaceId {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    ((PNCreateSpaceAPICallBuilder *)builderMock).spaceId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenNonNSStringPassedAsCreateSpaceId {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: create :: information

- (void)testItShouldReturnCreateBuilderWhenInformationSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateSpaceAPICallBuilder *)builder).information(@"Test space");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetInformationWhenNSStringPassedAsCreateInformation {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"Test information";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetInformationWhenEmptyNSStringPassedAsCreateInformation {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetInformationWhenNonNSStringPassedAsCreateInformation {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: create :: custom

- (void)testItShouldReturnCreateBuilderWhenCustomSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateSpaceAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetCustomWhenNSDictionaryPassedAsCreateCustom {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenEmptyNSDictionaryPassedAsCreateCustom {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenNonNSDictionaryPassedAsCreateCustom {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: create :: includeFields

- (void)testItShouldReturnCreateBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateSpaceAPICallBuilder *)builder).includeFields(PNSpaceCustomField);
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenCreateIncludeFieldsSpecifiedInChain {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    PNSpaceFields expected = PNSpaceCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: spaceId

- (void)testItShouldReturnUpdateBuilderWhenSpaceIdSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id createBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetSpaceIdWhenNSStringPassedAsUpdateSpaceId {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenEmptyNSStringPassedAsUpdateSpaceId {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenNonNSStringPassedAsUpdateSpaceId {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: name

- (void)testItShouldReturnUpdateBuilderWhenNameSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).name(@"PubNub");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetNameWhenNSStringPassedAsUpdateName {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotNameWhenEmptyNSStringPassedAsUpdateName {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotNameWhenNonNSStringPassedAsUpdateName {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: information

- (void)testItShouldReturnUpdateBuilderWhenInformationSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).information(@"Test information");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetInformationWhenNSStringPassedAsUpdateInformation {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"Test information";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetInformationWhenEmptyNSStringPassedAsUpdateInformation {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetInformationWhenNonNSStringPassedAsUpdateInformation {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: custom

- (void)testItShouldReturnUpdateBuilderWhenCustomSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetCustomWhenNSDictionaryPassedAsUpdateCustom {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenEmptyNSDictionaryPassedAsUpdateCustom {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenNonNSDictionaryPassedAsUpdateCustom {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: includeFields

- (void)testItShouldReturnUpdateBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).includeFields(PNSpaceCustomField);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenUpdateIncludeFieldsSpecifiedInChain {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    PNSpaceFields expected = PNSpaceCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: delete :: spaceId

- (void)testItShouldReturnDeleteBuilderWhenSpaceIdSpecifiedInChain {
    id builder = [self deleteBuilder];
    
    id createBuilder = ((PNDeleteSpaceAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetSpaceIdWhenNSStringPassedAsDeleteSpaceId {
    PNDeleteSpaceAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenEmptyNSStringPassedAsDeleteSpaceId {
    PNDeleteSpaceAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenNonNSStringPassedAsDeleteSpaceId {
    PNDeleteSpaceAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: spaceId

- (void)testItShouldReturnFetchBuilderWhenSpaceIdSpecifiedInChain {
    id builder = [self fetchBuilder];
    
    id createBuilder = ((PNFetchSpaceAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetSpaceIdWhenNSStringPassedAsFetchSpaceId {
    PNFetchSpaceAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenEmptyNSStringPassedAsFetchSpaceId {
    PNFetchSpaceAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSpaceIdWhenNonNSStringPassedAsFetchSpaceId {
    PNFetchSpaceAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testItShouldReturnFetchBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchBuilder];
    
    id fetchBuilder = ((PNFetchSpaceAPICallBuilder *)builder).includeFields(PNSpaceCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenFetchIncludeFieldsSpecifiedInChain {
    PNFetchSpaceAPICallBuilder *builder = [self fetchBuilder];
    PNSpaceFields expected = PNSpaceCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: filter

- (void)testItShouldReturnFetchBuilderWhenFilterSpecifiedInChain {
    id builder = [self fetchAllBuilder];

    id manageBuilder = ((PNFetchSpacesAPICallBuilder *)builder).filter(@"name == 'Public'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsFetchAllFilter {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"name like 'Program*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsFetchAllFilter {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsFetchAllFilter {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: sort

- (void)testItShouldReturnFetchBuilderWhenSortSpecifiedInChain {
    id builder = [self fetchAllBuilder];

    id manageBuilder = ((PNFetchSpacesAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSortWhenNSArrayPassedAsFetchAllSort {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenEmptyNSArrayPassedAsFetchAllSort {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenNonNSArrayPassedAsFetchAllSort {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: start

- (void)testItShouldReturnFetchAllBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchSpacesAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsFetchAllStartToken {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsFetchAllStartToken {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsFetchAllStartToken {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: end

- (void)testItShouldReturnFetchAllBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchSpacesAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsFetchAllEndToken {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsFetchAllEndToken {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsFetchAllEndToken {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: limit

- (void)testItShouldReturnFetchAllBuilderWhenLimitSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchSpacesAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetLimitWhenFetchAllLimitSpecifiedInChain {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @35;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];
    
    builder.limit(35);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: includeCount

- (void)testItShouldReturnFetchAllBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id updateBuilder = ((PNFetchSpacesAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenFetchAllIncludeCountSpecifiedInChain {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @YES;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];
    
    builder.includeCount(YES);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: includeFields

- (void)testItShouldReturnFetchAllBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchSpacesAPICallBuilder *)builder).includeFields(PNSpaceCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testShouldSetIncludeFieldsWhenFetchAllIncludeFieldsSpecifiedInChain {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    PNSpaceFields expected = PNSpaceCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNCreateSpaceAPICallBuilder *)createBuilder {
    return [PNCreateSpaceAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                    NSDictionary *arguments) {
    }];
}

- (PNUpdateSpaceAPICallBuilder *)updateBuilder {
    return [PNUpdateSpaceAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                    NSDictionary *arguments) {
    }];
}

- (PNDeleteSpaceAPICallBuilder *)deleteBuilder {
    return [PNDeleteSpaceAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                    NSDictionary *arguments) {
    }];
}

- (PNFetchSpaceAPICallBuilder *)fetchBuilder {
    return [PNFetchSpaceAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *arguments) {
    }];
}

- (PNFetchSpacesAPICallBuilder *)fetchAllBuilder {
    return [PNFetchSpacesAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
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
