/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PNAPICallBuilder+Private.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


#pragma mark Test interface declaration

@interface PNUserObjectsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNCreateUserAPICallBuilder *)createBuilder;
- (PNUpdateUserAPICallBuilder *)updateBuilder;
- (PNDeleteUserAPICallBuilder *)deleteBuilder;
- (PNFetchUserAPICallBuilder *)fetchBuilder;
- (PNFetchUsersAPICallBuilder *)fetchAllBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNUserObjectsAPICallBuilderTest


#pragma mark - Tests :: create :: userId

- (void)testCreateUserId_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetUserId_WhenNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetUserId_WhenEmptyNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetUserId_WhenNonNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: create :: name

- (void)testCreateName_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).name(@"PubNub");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetName_WhenNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetName_WhenEmptyNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetName_WhenNonNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: create :: externalId

- (void)testCreateExternalId_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).externalId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetExternalId_WhenNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetExternalId_WhenEmptyNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetExternalId_WhenNonNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: create :: profileUrl

- (void)testCreateProfileUrl_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).profileUrl(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetProfileUrl_WhenNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"https://pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetProfileUrl_WhenEmptyNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetProfileUrl_WhenNonNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: create :: email

- (void)testCreateEmail_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).email(@"support@pubnub.com");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetEmail_WhenNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"support@pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetEmail_WhenEmptyNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetEmail_WhenNonNSStringPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: create :: custom

- (void)testCreateCustom_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetCustom_WhenNSDictionaryPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetCustom_WhenEmptyNSDictionaryPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}

- (void)testCreate_ShouldNotSetCustom_WhenNonNSDictionaryPassed {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: create :: includeFields

- (void)testCreateIncludeFields_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).includeFields(PNUserCustomField);
    XCTAssertEqual(createBuilder, builder);
}

- (void)testCreate_ShouldSetIncludeFields_WhenCalled {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    PNUserFields expected = PNUserCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: userId

- (void)testUpdateUserId_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id createBuilder = ((PNUpdateUserAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testUpdate_ShouldSetUserId_WhenNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUserId_WhenEmptyNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetUserId_WhenNonNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: name

- (void)testUpdateName_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).name(@"PubNub");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetName_WhenNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotName_WhenEmptyNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotName_WhenNonNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: externalId

- (void)testUpdateExternalId_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).externalId(@"id");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetExternalId_WhenNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetExternalId_WhenEmptyNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetExternalId_WhenNonNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: profileUrl

- (void)testUpdateProfileUrl_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).profileUrl(@"id");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetProfileUrl_WhenNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"https://pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetProfileUrl_WhenEmptyNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetProfileUrl_WhenNonNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: email

- (void)testUpdateEmail_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).email(@"support@pubnub.com");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetEmail_WhenNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"support@pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetEmail_WhenEmptyNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetEmail_WhenNonNSStringPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: custom

- (void)testUpdateCustom_ShouldReturnUpdateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetCustom_WhenNSDictionaryPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetCustom_WhenEmptyNSDictionaryPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}

- (void)testUpdate_ShouldNotSetCustom_WhenNonNSDictionaryPassed {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: update :: includeFields

- (void)testUpdateIncludeFields_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).includeFields(PNUserCustomField);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testUpdate_ShouldSetIncludeFields_WhenCalled {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    PNUserFields expected = PNUserCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: delete :: userId

- (void)testDeleteUserId_ShouldReturnDeleteBuilder_WhenCalled {
    id builder = [self deleteBuilder];
    
    id createBuilder = ((PNDeleteUserAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testDelete_ShouldSetUserId_WhenNSStringPassed {
    PNDeleteUserAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}

- (void)testDelete_ShouldNotSetUserId_WhenEmptyNSStringPassed {
    PNDeleteUserAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}

- (void)testDelete_ShouldNotSetUserId_WhenNonNSStringPassed {
    PNDeleteUserAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: userId

- (void)testFetchUserId_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchBuilder];
    
    id createBuilder = ((PNFetchUserAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testFetch_ShouldSetUserId_WhenNSStringPassed {
    PNFetchUserAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetUserId_WhenEmptyNSStringPassed {
    PNFetchUserAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetUserId_WhenNonNSStringPassed {
    PNFetchUserAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testFetchIncludeFields_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self fetchBuilder];
    
    id fetchBuilder = ((PNFetchUserAPICallBuilder *)builder).includeFields(PNUserCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetIncludeFields_WhenCalled {
    PNFetchUserAPICallBuilder *builder = [self fetchBuilder];
    PNUserFields expected = PNUserCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: start

- (void)testFetchAllStart_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchUsersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetchAll_ShouldSetStart_WhenNSStringPassed {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetchAll_ShouldNotSetStart_WhenEmptyNSStringPassed {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetchAll_ShouldNotSetStart_WhenNonNSStringPassed {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: end

- (void)testFetchAllEnd_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchUsersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetchAll_ShouldSetEnd_WhenNSStringPassed {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetchAll_ShouldNotSetEnd_WhenEmptyNSStringPassed {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetchAll_ShouldNotSetEnd_WhenNonNSStringPassed {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: limit

- (void)testFetchAllLimit_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchUsersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetchAll_ShouldSetLimit_WhenCalled {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @YES;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];
    
    builder.limit(35);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: includeCount

- (void)testFetchAllIncludeCount_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id updateBuilder = ((PNFetchUsersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testFetchAll_ShouldSetIncludeCount_WhenCalled {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @YES;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];
    
    builder.includeCount(NO);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch all :: includeFields

- (void)testFetchAllIncludeFields_ShouldReturnCreateBuilder_WhenCalled {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchUsersAPICallBuilder *)builder).includeFields(PNUserCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetchAll_ShouldSetIncludeFields_WhenCalled {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    PNUserFields expected = PNUserCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Misc

- (PNCreateUserAPICallBuilder *)createBuilder {
    return [PNCreateUserAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *arguments) {
    }];
}

- (PNUpdateUserAPICallBuilder *)updateBuilder {
    return [PNUpdateUserAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *arguments) {
    }];
}

- (PNDeleteUserAPICallBuilder *)deleteBuilder {
    return [PNDeleteUserAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *arguments) {
    }];
}

- (PNFetchUserAPICallBuilder *)fetchBuilder {
    return [PNFetchUserAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                  NSDictionary *arguments) {
    }];
}

- (PNFetchUsersAPICallBuilder *)fetchAllBuilder {
    return [PNFetchUsersAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
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
