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


@implementation PNSpaceObjectsAPICallBuilderTest


#pragma mark - Tests :: create :: spaceId

- (void)testCreateSpaceId_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateSpaceAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetSpaceId_WhenNSStringPassed {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetSpaceId_WhenEmptyNSStringPassed {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetSpaceId_WhenNonNSStringPassed {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: create :: information

- (void)testCreateInformation_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateSpaceAPICallBuilder *)builder).information(@"Test space");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetInformation_WhenNSStringPassed {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"Test information";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetInformation_WhenEmptyNSStringPassed {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetInformation_WhenNonNSStringPassed {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: create :: custom

- (void)testCreateCustom_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateSpaceAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetCustom_WhenNSDictionaryPassed {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetCustom_WhenEmptyNSDictionaryPassed {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetCustom_WhenNonNSDictionaryPassed {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: create :: includeFields

- (void)testCreateIncludeFields_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateSpaceAPICallBuilder *)builder).includeFields(PNSpaceCustomField);
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetIncludeFields_WhenCalled {
    PNCreateSpaceAPICallBuilder *builder = [self createBuilder];
    PNSpaceFields expected = PNSpaceCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: spaceId

- (void)testUpdateSpaceId_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id createBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testUpdate_ShouldSetSpaceId_WhenNSStringPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetSpaceId_WhenEmptyNSStringPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetSpaceId_WhenNonNSStringPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: name

- (void)testUpdateName_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).name(@"PubNub");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetName_WhenNSStringPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotName_WhenEmptyNSStringPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotName_WhenNonNSStringPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: information

- (void)testUpdateInformation_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).information(@"Test information");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetInformation_WhenNSStringPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"Test information";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetInformation_WhenEmptyNSStringPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetInformation_WhenNonNSStringPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: custom

- (void)testUpdateCustom_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetCustom_WhenNSDictionaryPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetCustom_WhenEmptyNSDictionaryPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetCustom_WhenNonNSDictionaryPassed {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: includeFields

- (void)testUpdateIncludeFields_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateSpaceAPICallBuilder *)builder).includeFields(PNSpaceCustomField);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetIncludeFields_WhenCalled {
    PNUpdateSpaceAPICallBuilder *builder = [self updateBuilder];
    PNSpaceFields expected = PNSpaceCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: delete :: spaceId

- (void)testDeleteSpaceId_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self deleteBuilder];
    
    id createBuilder = ((PNDeleteSpaceAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testDelete_ShouldSetSpaceId_WhenNSStringPassed {
    PNDeleteSpaceAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}

- (void)testDelete_ShouldNotSetSpaceId_WhenEmptyNSStringPassed {
    PNDeleteSpaceAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}

- (void)testDelete_ShouldNotSetSpaceId_WhenNonNSStringPassed {
    PNDeleteSpaceAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: spaceId

- (void)testFetchSpaceId_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self fetchBuilder];
    
    id createBuilder = ((PNFetchSpaceAPICallBuilder *)builder).spaceId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testFetch_ShouldSetSpaceId_WhenNSStringPassed {
    PNFetchSpaceAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetSpaceId_WhenEmptyNSStringPassed {
    PNFetchSpaceAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetSpaceId_WhenNonNSStringPassed {
    PNFetchSpaceAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"spaceId"];
    
    builder.spaceId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testFetchIncludeFields_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self fetchBuilder];
    
    id fetchBuilder = ((PNFetchSpaceAPICallBuilder *)builder).includeFields(PNSpaceCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetIncludeFields_WhenCalled {
    PNFetchSpaceAPICallBuilder *builder = [self fetchBuilder];
    PNSpaceFields expected = PNSpaceCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: start

- (void)testFetchAllStart_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchSpacesAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetchAll_ShouldSetStart_WhenNSStringPassed {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetchAll_ShouldNotSetStart_WhenEmptyNSStringPassed {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetchAll_ShouldNotSetStart_WhenNonNSStringPassed {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: end

- (void)testFetchAllEnd_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchSpacesAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetchAll_ShouldSetEnd_WhenNSStringPassed {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetchAll_ShouldNotSetEnd_WhenEmptyNSStringPassed {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetchAll_ShouldNotSetEnd_WhenNonNSStringPassed {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: limit

- (void)testFetchAllLimit_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchSpacesAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetchAll_ShouldSetLimit_WhenCalled {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @YES;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];
    
    builder.limit(35);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: includeCount

- (void)testFetchAllIncludeCount_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id updateBuilder = ((PNFetchSpacesAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testFetchAll_ShouldSetIncludeCount_WhenCalled {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @YES;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];
    
    builder.includeCount(NO);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: includeFields

- (void)testFetchAllIncludeFields_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchSpacesAPICallBuilder *)builder).includeFields(PNSpaceCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetchAll_ShouldSetIncludeFields_WhenCalled {
    PNFetchSpacesAPICallBuilder *builder = [self fetchAllBuilder];
    PNSpaceFields expected = PNSpaceCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerify(builderMock);
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
        OCMExpect([[mockedObject reject] setValue:value forParameter:parameter]);
    }
}

- (NSString *)mockedParameterFrom:(NSString *)parameter {
    return [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
}

#pragma mark -


@end
