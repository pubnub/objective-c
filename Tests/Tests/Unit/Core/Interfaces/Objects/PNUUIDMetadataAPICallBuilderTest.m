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

@interface PNUUIDMetadataAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNSetUUIDMetadataAPICallBuilder *)setBuilder;
- (PNRemoveUUIDMetadataAPICallBuilder *)removeBuilder;
- (PNFetchUUIDMetadataAPICallBuilder *)fetchBuilder;
- (PNFetchAllUUIDMetadataAPICallBuilder *)fetchAllBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNUUIDMetadataAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: set :: uuid

- (void)testItShouldReturnSetBuilderWhenUUIDSpecifiedInChain {
    id builder = [self setBuilder];
    
    id createBuilder = ((PNSetUUIDMetadataAPICallBuilder *)builder).uuid(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetUUIDWhenNSStringPassedAsSetUUID {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuid"];
    
    builder.uuid(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenEmptyNSStringPassedAsSetUUID {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];
    
    builder.uuid(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenNonNSStringPassedAsSetUUID {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];
    
    builder.uuid(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: name

- (void)testItShouldReturnSetBuilderWhenNameSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetUUIDMetadataAPICallBuilder *)builder).name(@"PubNub");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetNameWhenNSStringPassedAsSetName {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotNameWhenEmptyNSStringPassedAsSetName {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotNameWhenNonNSStringPassedAsSetName {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: externalId

- (void)testItShouldReturnSetBuilderWhenExternalIdSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetUUIDMetadataAPICallBuilder *)builder).externalId(@"id");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetExternalIdWhenNSStringPassedAsSetExternalId {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetExternalIdWhenEmptyNSStringPassedAsSetExternalId {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetExternalIdWhenNonNSStringPassedAsSetExternalId {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: profileUrl

- (void)testItShouldReturnSetBuilderWhenProfileUrlSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetUUIDMetadataAPICallBuilder *)builder).profileUrl(@"id");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetProfileUrlWhenNSStringPassedAsSetProfileUrl {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"https://pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetProfileUrlWhenEmptyNSStringPassedAsSetProfileUrl {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetProfileUrlWhenNonNSStringPassedAsSetProfileUrl {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: email

- (void)testItShouldReturnSetBuilderWhenEmailSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetUUIDMetadataAPICallBuilder *)builder).email(@"support@pubnub.com");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetEmailWhenNSStringPassedAsSetEmail {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"support@pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEmailWhenEmptyNSStringPassedAsSetEmail {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEmailWhenNonNSStringPassedAsSetEmail {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: custom

- (void)testItShouldReturnSetBuilderWhenCustomSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetUUIDMetadataAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetCustomWhenNSDictionaryPassedAsSetCustom {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenEmptyNSDictionaryPassedAsSetCustom {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenNonNSDictionaryPassedAsSetCustom {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: includeFields

- (void)testItShouldReturnSetBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetUUIDMetadataAPICallBuilder *)builder).includeFields(PNUUIDCustomField);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenSetIncludeFieldsSpecifiedInChain {
    PNSetUUIDMetadataAPICallBuilder *builder = [self setBuilder];
    PNUUIDFields expected = PNUUIDCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: uuid

- (void)testItShouldReturnRemoveBuilderWhenUUIDSpecifiedInChain {
    id builder = [self removeBuilder];
    
    id removeBuilder = ((PNRemoveUUIDMetadataAPICallBuilder *)builder).uuid(@"id");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetUUIDWhenNSStringPassedAsRemoveUUID {
    PNRemoveUUIDMetadataAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuid"];
    
    builder.uuid(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenEmptyNSStringPassedAsRemoveUUID {
    PNRemoveUUIDMetadataAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];
    
    builder.uuid(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenNonNSStringPassedAsRemoveUUID {
    PNRemoveUUIDMetadataAPICallBuilder *builder = [self removeBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];
    
    builder.uuid(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: uuid

- (void)testItShouldReturnFetchBuilderWhenUUIDSpecifiedInChain {
    id builder = [self fetchBuilder];
    
    id fetchBuilder = ((PNFetchUUIDMetadataAPICallBuilder *)builder).uuid(@"id");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetUUIDWhenNSStringPassedAsFetchUUID {
    PNFetchUUIDMetadataAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"uuid"];
    
    builder.uuid(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenEmptyNSStringPassedAsFetchUUID {
    PNFetchUUIDMetadataAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];
    
    builder.uuid(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUUIDWhenNonNSStringPassedAsFetchUUID {
    PNFetchUUIDMetadataAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"uuid"];
    
    builder.uuid(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testItShouldReturnFetchBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchBuilder];
    
    id fetchBuilder = ((PNFetchUUIDMetadataAPICallBuilder *)builder).includeFields(PNUUIDCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenFetchIncludeFieldsSpecifiedInChain {
    PNFetchUUIDMetadataAPICallBuilder *builder = [self fetchBuilder];
    PNUUIDFields expected = PNUUIDCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: filter

- (void)testItShouldReturnFetchBuilderWhenFilterSpecifiedInChain {
    id builder = [self fetchAllBuilder];

    id manageBuilder = ((PNFetchAllUUIDMetadataAPICallBuilder *)builder).filter(@"name == 'Bob'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsFetchAllFilter {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"name like 'General*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsFetchAllFilter {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsFetchAllFilter {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: sort

- (void)testItShouldReturnFetchBuilderWhenSortSpecifiedInChain {
    id builder = [self fetchAllBuilder];

    id manageBuilder = ((PNFetchAllUUIDMetadataAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSortWhenNSArrayPassedAsFetchAllSort {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected =@[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(@[@"name", @"created:desc"]);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenEmptyNSArrayPassedAsFetchAllSort {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenNonNSArrayPassedAsFetchAllSort {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: start

- (void)testItShouldReturnFetchAllBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchAllUUIDMetadataAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsFetchAllStartToken {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsFetchAllStartToken {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsFetchAllStartToken {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: end

- (void)testItShouldReturnFetchAllBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchAllUUIDMetadataAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsFetchAllEndToken {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsFetchAllEndToken {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsFetchAllEndToken {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: limit

- (void)testItShouldReturnFetchAllBuilderWhenLimitSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchAllUUIDMetadataAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetLimitWhenFetchAllLimitSpecifiedInChain {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @35;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];
    
    builder.limit(35);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: includeCount

- (void)testItShouldReturnFetchAllBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id setBuilder = ((PNFetchAllUUIDMetadataAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenFetchAllIncludeCountSpecifiedInChain {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @YES;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];
    
    builder.includeCount(YES);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: includeFields

- (void)testItShouldReturnFetchAllBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchAllUUIDMetadataAPICallBuilder *)builder).includeFields(PNUUIDCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenFetchAllIncludeFieldsSpecifiedInChain {
    PNFetchAllUUIDMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    PNUUIDFields expected = PNUUIDCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNSetUUIDMetadataAPICallBuilder *)setBuilder {
    return [PNSetUUIDMetadataAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                        NSDictionary *arguments) {
    }];
}

- (PNRemoveUUIDMetadataAPICallBuilder *)removeBuilder {
    return [PNRemoveUUIDMetadataAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                           NSDictionary *arguments) {
    }];
}

- (PNFetchUUIDMetadataAPICallBuilder *)fetchBuilder {
    return [PNFetchUUIDMetadataAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                          NSDictionary *arguments) {
    }];
}

- (PNFetchAllUUIDMetadataAPICallBuilder *)fetchAllBuilder {
    return [PNFetchAllUUIDMetadataAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
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
