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

@interface PNChannelMetadataAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNSetChannelMetadataAPICallBuilder *)setBuilder;
- (PNFetchChannelMetadataAPICallBuilder *)fetchBuilder;
- (PNFetchAllChannelsMetadataAPICallBuilder *)fetchAllBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNChannelMetadataAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: set :: name

- (void)testItShouldReturnSetBuilderWhenNameSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetChannelMetadataAPICallBuilder *)builder).name(@"PubNub");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetNameWhenNSStringPassedAsSetName {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotNameWhenEmptyNSStringPassedAsSetName {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotNameWhenNonNSStringPassedAsSetName {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"name"];
    
    builder.name(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: information

- (void)testItShouldReturnSetBuilderWhenInformationSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetChannelMetadataAPICallBuilder *)builder).information(@"Test information");
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetInformationWhenNSStringPassedAsSetInformation {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"Test information";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetInformationWhenEmptyNSStringPassedAsSetInformation {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetInformationWhenNonNSStringPassedAsSetInformation {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"information"];
    
    builder.information(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: custom

- (void)testItShouldReturnSetBuilderWhenCustomSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetChannelMetadataAPICallBuilder *)builder).custom(@{ @"company": @"PubNub" });
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetCustomWhenNSDictionaryPassedAsSetCustom {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    NSDictionary *expected = @{ @"company": @"PubNub" };
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenEmptyNSDictionaryPassedAsSetCustom {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    NSDictionary *expected = @{};
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetCustomWhenNonNSDictionaryPassedAsSetCustom {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"custom"];
    
    builder.custom(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: set :: includeFields

- (void)testItShouldReturnSetBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self setBuilder];
    
    id setBuilder = ((PNSetChannelMetadataAPICallBuilder *)builder).includeFields(PNChannelCustomField);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenSetIncludeFieldsSpecifiedInChain {
    PNSetChannelMetadataAPICallBuilder *builder = [self setBuilder];
    PNChannelFields expected = PNChannelCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: includeFields

- (void)testItShouldReturnFetchBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchBuilder];
    
    id fetchBuilder = ((PNFetchChannelMetadataAPICallBuilder *)builder).includeFields(PNChannelCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetIncludeFieldsWhenFetchIncludeFieldsSpecifiedInChain {
    PNFetchChannelMetadataAPICallBuilder *builder = [self fetchBuilder];
    PNChannelFields expected = PNChannelCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: filter

- (void)testItShouldReturnFetchBuilderWhenFilterSpecifiedInChain {
    id builder = [self fetchAllBuilder];

    id manageBuilder = ((PNFetchAllChannelsMetadataAPICallBuilder *)builder).filter(@"name == 'Public'");
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetFilterWhenNSStringPassedAsFetchAllFilter {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"name like 'Program*'";


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenEmptyNSStringPassedAsFetchAllFilter {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetFilterWhenNonNSStringPassedAsFetchAllFilter {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"filter"];

    builder.filter(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: sort

- (void)testItShouldReturnFetchBuilderWhenSortSpecifiedInChain {
    id builder = [self fetchAllBuilder];

    id manageBuilder = ((PNFetchAllChannelsMetadataAPICallBuilder *)builder).sort(@[@"name"]);
    XCTAssertEqual(manageBuilder, builder);
}

- (void)testItShouldSetSortWhenNSArrayPassedAsFetchAllSort {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = @[@"name", @"created:desc"];


    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenEmptyNSArrayPassedAsFetchAllSort {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = @[];


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetSortWhenNonNSArrayPassedAsFetchAllSort {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSArray *expected = (id)@2010;


    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"sort"];

    builder.sort(expected);

    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: start

- (void)testItShouldReturnFetchAllBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchAllChannelsMetadataAPICallBuilder *)builder).start(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSStringPassedAsFetchAllStartToken {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenEmptyNSStringPassedAsFetchAllStartToken {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSStringPassedAsFetchAllStartToken {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: end

- (void)testItShouldReturnFetchAllBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchAllChannelsMetadataAPICallBuilder *)builder).end(@"NjA");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsFetchAllEndToken {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"NjA";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenEmptyNSStringPassedAsFetchAllEndToken {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsFetchAllEndToken {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: limit

- (void)testItShouldReturnFetchAllBuilderWhenLimitSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchAllChannelsMetadataAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetLimitWhenFetchAllLimitSpecifiedInChain {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @35;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];
    
    builder.limit(35);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: includeCount

- (void)testItShouldReturnFetchAllBuilderWhenIncludeCountSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id setBuilder = ((PNFetchAllChannelsMetadataAPICallBuilder *)builder).includeCount(YES);
    XCTAssertEqual(setBuilder, builder);
}

- (void)testItShouldSetIncludeCountWhenFetchAllIncludeCountSpecifiedInChain {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    NSNumber *expected = @YES;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"includeCount"];
    
    builder.includeCount(YES);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch all :: includeFields

- (void)testItShouldReturnFetchAllBuilderWhenIncludeFieldsSpecifiedInChain {
    id builder = [self fetchAllBuilder];
    
    id fetchBuilder = ((PNFetchAllChannelsMetadataAPICallBuilder *)builder).includeFields(PNChannelCustomField);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testShouldSetIncludeFieldsWhenFetchAllIncludeFieldsSpecifiedInChain {
    PNFetchAllChannelsMetadataAPICallBuilder *builder = [self fetchAllBuilder];
    PNChannelFields expected = PNChannelCustomField;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:@(expected) toParameter:@"includeFields"];
    
    builder.includeFields(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNSetChannelMetadataAPICallBuilder *)setBuilder {
    return [PNSetChannelMetadataAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                           NSDictionary *arguments) {
    }];
}

- (PNFetchChannelMetadataAPICallBuilder *)fetchBuilder {
    return [PNFetchChannelMetadataAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                             NSDictionary *arguments) {
    }];
}

- (PNFetchAllChannelsMetadataAPICallBuilder *)fetchAllBuilder {
    return [PNFetchAllChannelsMetadataAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
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
