/**
* @author Serhii Mamontov
* @copyright © 2010-2020 PubNub, Inc.
*/
#import <PubNub/PNFetchAllChannelsMetadataRequest.h>
#import <PubNub/PNRemoveChannelMetadataRequest.h>
#import <PubNub/PNFetchChannelMetadataRequest.h>
#import <PubNub/PNBaseObjectsRequest+Private.h>
#import <PubNub/PNSetChannelMembersRequest.h>
#import <PubNub/PubNub+CorePrivate.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PNHelpers.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNChannelMetadataObjectsTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNChannelMetadataObjectsTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}

#pragma mark - Tests :: Set

- (void)testItShouldReturnSetChannelMetadataBuilder {
    XCTAssertTrue([self.client.objects().setChannelMetadata(@"secret") isKindOfClass:[PNSetChannelMetadataAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultSetChannelMetadataIncludeFields {
    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:[NSUUID UUID].UUIDString];


    XCTAssertEqual(request.includeFields, PNChannelCustomField);
}

#pragma mark - Tests :: Set :: Call

- (void)testItShouldSetChannelMetadataWhenCalled {
    NSString *expectedInformation = [NSUUID UUID].UUIDString;
    NSString *expectedChannelData = [NSUUID UUID].UUIDString;
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSDictionary *expectedBody = @{
        @"name": expectedName,
        @"description": expectedInformation,
        @"custom": @{ @"channel": expectedChannelData }
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNSetChannelMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSetChannelMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNil([request validate]);
            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertEqualObjects(request.query[@"include"], @"custom");
            XCTAssertEqualObjects(request.body, expectedPayload);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setChannelMetadata(expectedId)
            .name(expectedName)
            .information(expectedInformation)
            .custom(@{ @"channel": expectedChannelData })
            .performWithCompletion(^(PNSetChannelMetadataStatus *status) {});
    }];
}

- (void)testItShouldNotSetIncludeFieldsWhenCalledWithSetChannelMetadataIncludeFieldsSetToZero {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNSetChannelMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSetChannelMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNil(request.query[@"include"]);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setChannelMetadata([NSUUID UUID].UUIDString)
            .name([NSUUID UUID].UUIDString)
            .includeFields(0)
            .performWithCompletion(^(PNSetChannelMetadataStatus *status) {});
    }];
}

- (void)testItShouldNotSetChannelMetadataWhenChannelNameIsTooLong {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [@[
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
    ] componentsJoinedByString:@""];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setChannelMetadata(expectedId)
            .name(expectedName)
            .performWithCompletion(^(PNSetChannelMetadataStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"too long"].location,
                                  NSNotFound);

                handler();
            });
    }];
}

- (void)testItShouldNotSetChannelMetadataWhenUnsupportedDataTypeInCustom {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setChannelMetadata(expectedId)
            .name(expectedName)
            .custom(@{ @"date": [NSDate date] })
            .performWithCompletion(^(PNSetChannelMetadataStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);

                handler();
            });
    }];
}


#pragma mark - Tests :: Remove

- (void)testItShouldReturnRemoveChannelMetadataBuilder {
    XCTAssertTrue([self.client.objects().removeChannelMetadata(@"secret") isKindOfClass:[PNRemoveChannelMetadataAPICallBuilder class]]);
}

#pragma mark - Tests :: Remove :: Call

- (void)testItShouldRemoveChannelMetadataWhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNRemoveChannelMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRemoveChannelMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.identifier, expectedId);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().removeChannelMetadata(expectedId)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}


#pragma mark - Tests :: Fetch

- (void)testItShouldReturnFetchChannelMetadataBuilder {
    XCTAssertTrue([self.client.objects().channelMetadata(@"secret") isKindOfClass:[PNFetchChannelMetadataAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultFetchChannelMetadataIncludeFields {
    PNFetchChannelMetadataRequest *request = [PNFetchChannelMetadataRequest requestWithChannel:[NSUUID UUID].UUIDString];


    XCTAssertEqual(request.includeFields, PNChannelCustomField);
}

- (void)testItShouldFetchChannelMetadataWhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchChannelMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchChannelMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertEqualObjects(request.query[@"include"], @"custom");
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().channelMetadata(expectedId)
            .performWithCompletion(^(PNFetchChannelMetadataResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldNotSetIncludeFieldsWhenCalledWithFetchChannelMetadataIncludeFieldsSetToZero {
    NSString *expectedId = [NSUUID UUID].UUIDString;


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchChannelMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchChannelMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNil(request.query[@"include"]);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().channelMetadata(expectedId)
            .includeFields(0)
            .performWithCompletion(^(PNFetchChannelMetadataResult *result, PNErrorStatus *status) {});
    }];
}


#pragma mark - Tests :: Fetch all

- (void)testItShouldReturnFetchAllChannelsMetadataBuilder {
    XCTAssertTrue([self.client.objects().allChannelsMetadata() isKindOfClass:[PNFetchAllChannelsMetadataAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultFetchAllChannelsMetadataIncludeFields {
    PNFetchAllChannelsMetadataRequest *request = [PNFetchAllChannelsMetadataRequest new];
    
    
    XCTAssertEqual(request.includeFields, PNChannelTotalCountField);
}


#pragma mark - Tests :: Fetch all :: Call

- (void)testItShouldFetchAllChannelsMetadataWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    // Encoding is transport layer responsibility, so we are expecting raw string in query.
    NSString *expectedFilterExpression = filterExpression;
    NSString *expectedStart = [NSUUID UUID].UUIDString;
    NSString *expectedEnd = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchAllChannelsMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchAllChannelsMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.query[@"start"], expectedStart);
            XCTAssertEqualObjects(request.query[@"end"], expectedEnd);
            XCTAssertEqualObjects(request.query[@"include"], @"custom");
            XCTAssertEqualObjects(request.query[@"limit"], expectedLimit.stringValue);
            XCTAssertEqualObjects(request.query[@"filter"], expectedFilterExpression);
            XCTAssertNil(request.query[@"count"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().allChannelsMetadata()
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .filter(filterExpression)
            .includeFields(PNChannelCustomField)
            .performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) { });
    }];
}

- (void)testItShouldSetDefaultIncludeFieldsWhenCalledWithOutFetchAllChannelsMetadataIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchAllChannelsMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchAllChannelsMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];
            
            XCTAssertNotNil(request.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().allChannelsMetadata()
            .performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {});
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
