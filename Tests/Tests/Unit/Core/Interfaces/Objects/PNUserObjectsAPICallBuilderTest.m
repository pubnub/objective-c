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

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNUserObjectsAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: create :: userId

- (void)testItShouldReturnCreateBuilderWhenUserIdSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetUserIdWhenNSStringPassedAsCreateUserId {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenEmptyNSStringPassedAsCreateUserId {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenNonNSStringPassedAsCreateUserId {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: create :: name

- (void)testItShouldReturnCreateBuilderWhenNameSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).name(@"PubNub");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetNameWhenNSStringPassedAsCreateName {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetNameWhenEmptyNSStringPassedAsCreateName {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetNameWhenNonNSStringPassedAsCreateName {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: create :: externalId

- (void)testItShouldReturnCreateBuilderWhenExternalIdSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).externalId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetExternalIdWhenNSStringPassedAsCreateExternalId {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetExternalIdWhenEmptyNSStringPassedAsCreateExternalId {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetExternalIdWhenNonNSStringPassedAsCreateExternalId {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: create :: profileUrl

- (void)testItShouldReturnCreateBuilderWhenProfileUrlSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).profileUrl(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetProfileUrlWhenNSStringPassedAsCreateProfileUrl {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"https://pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetProfileUrlWhenEmptyNSStringPassedAsCreateProfileUrl {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetProfileUrlWhenNonNSStringPassedAsCreateProfileUrl {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: create :: email

- (void)testItShouldReturnCreateBuilderWhenEmailSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).email(@"support@pubnub.com");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetEmailWhenNSStringPassedAsCreateEmail {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"support@pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEmailWhenEmptyNSStringPassedAsCreateEmail {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEmailWhenNonNSStringPassedAsCreateEmail {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: create :: custom

- (void)testItShouldReturnCreateBuilderWhenCustomSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetCustomWhenNSDictionaryPassedAsCreateCustom {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenEmptyNSDictionaryPassedAsCreateCustom {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenNonNSDictionaryPassedAsCreateCustom {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: create :: includeFields

- (void)testItShouldReturnCreateBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self createBuilder];
    
    id createBuilder = ((PNCreateUserAPICallBuilder *)builder).includeFields(PNUserCustomField);
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenCreateIncludeFieldsSpecifiedInChain {
    PNCreateUserAPICallBuilder *builder = [self createBuilder];
    PNUserFields expected = PNUserCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: userId

- (void)testItShouldReturnUpdateBuilderWhenUserIdSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id createBuilder = ((PNUpdateUserAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetUserIdWhenNSStringPassedAsUpdateUserId {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenEmptyNSStringPassedAsUpdateUserId {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenNonNSStringPassedAsUpdateUserId {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: name

- (void)testItShouldReturnUpdateBuilderWhenNameSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).name(@"PubNub");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetNameWhenNSStringPassedAsUpdateName {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotNameWhenEmptyNSStringPassedAsUpdateName {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotNameWhenNonNSStringPassedAsUpdateName {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: externalId

- (void)testItShouldReturnUpdateBuilderWhenExternalIdSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).externalId(@"id");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetExternalIdWhenNSStringPassedAsUpdateExternalId {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetExternalIdWhenEmptyNSStringPassedAsUpdateExternalId {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetExternalIdWhenNonNSStringPassedAsUpdateExternalId {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"externalId"];
    
    builder.externalId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: profileUrl

- (void)testItShouldReturnUpdateBuilderWhenProfileUrlSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).profileUrl(@"id");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetProfileUrlWhenNSStringPassedAsUpdateProfileUrl {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"https://pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetProfileUrlWhenEmptyNSStringPassedAsUpdateProfileUrl {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetProfileUrlWhenNonNSStringPassedAsUpdateProfileUrl {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"profileUrl"];
    
    builder.profileUrl(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: email

- (void)testItShouldReturnUpdateBuilderWhenEmailSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).email(@"support@pubnub.com");
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetEmailWhenNSStringPassedAsUpdateEmail {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"support@pubnub.com";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEmailWhenEmptyNSStringPassedAsUpdateEmail {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEmailWhenNonNSStringPassedAsUpdateEmail {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"email"];
    
    builder.email(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: custom

- (void)testItShouldReturnUpdateBuilderWhenCustomSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetCustomWhenNSDictionaryPassedAsUpdateCustom {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenEmptyNSDictionaryPassedAsUpdateCustom {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenNonNSDictionaryPassedAsUpdateCustom {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: update :: includeFields

- (void)testItShouldReturnUpdateBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self updateBuilder];
    
    id updateBuilder = ((PNUpdateUserAPICallBuilder *)builder).includeFields(PNUserCustomField);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenUpdateIncludeFieldsSpecifiedInChain {
    PNUpdateUserAPICallBuilder *builder = [self updateBuilder];
    PNUserFields expected = PNUserCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: delete :: userId

- (void)testItShouldReturnDeleteBuilderWhenUserIdSpecifiedInChain {
    id builder = [self deleteBuilder];
    
    id createBuilder = ((PNDeleteUserAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetUserIdWhenNSStringPassedAsDeleteUserId {
    PNDeleteUserAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenEmptyNSStringPassedAsDeleteUserId {
    PNDeleteUserAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenNonNSStringPassedAsDeleteUserId {
    PNDeleteUserAPICallBuilder *builder = [self deleteBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: userId

- (void)testItShouldReturnFetchBuilderWhenUserIdSpecifiedInChain {
    id builder = [self fetchBuilder];
    
    id createBuilder = ((PNFetchUserAPICallBuilder *)builder).userId(@"id");
    XCTAssertEqual(createBuilder, builder);
}

- (void)testItShouldSetUserIdWhenNSStringPassedAsFetchUserId {
    PNFetchUserAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"OpenID";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenEmptyNSStringPassedAsFetchUserId {
    PNFetchUserAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetUserIdWhenNonNSStringPassedAsFetchUserId {
    PNFetchUserAPICallBuilder *builder = [self fetchBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"userId"];
    
    builder.userId(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testItShouldReturnFetchBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchBuilder];
    
    id fetchBuilder = ((PNFetchUserAPICallBuilder *)builder).includeFields(PNUserCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenFetchIncludeFieldsSpecifiedInChain {
    PNFetchUserAPICallBuilder *builder = [self fetchBuilder];
    PNUserFields expected = PNUserCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: filter

- (void)testItShouldReturnFetchBuilderWhenFilterSpecifiedInChain {
    id builder = [self fetchAllBuilder];

    id manageBuilder = ((PNFetchUsersAPICallBuilder *)builder).filter(@"name == 'Bob'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsFetchAllFilter {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"name like 'General*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsFetchAllFilter {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsFetchAllFilter {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: sort

- (void)testItShouldReturnFetchBuilderWhenSortSpecifiedInChain {
    id builder = [self fetchAllBuilder];

    id manageBuilder = ((PNFetchUsersAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSortWhenNSArrayPassedAsFetchAllSort {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected =@[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(@[@"name", @"created:desc"]);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenEmptyNSArrayPassedAsFetchAllSort {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenNonNSArrayPassedAsFetchAllSort {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: start

- (void)testItShouldReturnFetchAllBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchUsersAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsFetchAllStartToken {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsFetchAllStartToken {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsFetchAllStartToken {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: end

- (void)testItShouldReturnFetchAllBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchUsersAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsFetchAllEndToken {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsFetchAllEndToken {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsFetchAllEndToken {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: limit

- (void)testItShouldReturnFetchAllBuilderWhenLimitSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchUsersAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetLimitWhenFetchAllLimitSpecifiedInChain {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @35;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];
    
    builder.limit(35);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: includeCount

- (void)testItShouldReturnFetchAllBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id updateBuilder = ((PNFetchUsersAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(updateBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenFetchAllIncludeCountSpecifiedInChain {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @YES;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];
    
    builder.includeCount(YES);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: includeFields

- (void)testItShouldReturnFetchAllBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchUsersAPICallBuilder *)builder).includeFields(PNUserCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenFetchAllIncludeFieldsSpecifiedInChain {
    PNFetchUsersAPICallBuilder *builder = [self fetchAllBuilder];
    PNUserFields expected = PNUserCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
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
        OCMReject([mockedObject setValue:value forParameter:parameter]);
    }
}

- (NSString *)mockedParameterFrom:(NSString *)parameter {
    return [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
}

#pragma mark -

#pragma clang diagnostic pop

@end
