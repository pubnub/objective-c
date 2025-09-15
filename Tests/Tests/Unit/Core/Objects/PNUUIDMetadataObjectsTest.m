/**
* @author Serhii Mamontov
* @copyright © 2010-2020 PubNub, Inc.
*/
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNFetchAllUUIDMetadataRequest.h>
#import <PubNub/PNBaseObjectsRequest+Private.h>
#import <PubNub/PNRemoveUUIDMetadataRequest.h>
#import <PubNub/PNFetchUUIDMetadataRequest.h>
#import <PubNub/PNSetUUIDMetadataRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PNHelpers.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNUUIDMetadataObjectsTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNUUIDMetadataObjectsTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Set

- (void)testItShouldReturnSetUUIDMetadataBuilder {
    XCTAssertTrue([self.client.objects().setUUIDMetadata() isKindOfClass:[PNSetUUIDMetadataAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultSetUUIDMetadataIncludeFields {
    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, PNUUIDCustomField|PNUUIDStatusField|PNUUIDTypeField);
}


#pragma mark - Tests :: Create :: Call

- (void)testItShouldSetUUIDMetadataWhenCalled {
    NSString *expectedUUIDData = [NSUUID UUID].UUIDString;
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSDictionary *expectedBody = @{
        @"name": expectedName,
        @"custom": @{ @"uuid": expectedUUIDData }
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    

    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNSetUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSetUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNil([request validate]);
            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertTrue([request.query[@"include"] containsString:@"custom"]);
            XCTAssertTrue([request.query[@"include"] containsString:@"status"]);
            XCTAssertTrue([request.query[@"include"] containsString:@"type"]);
            XCTAssertEqualObjects(request.body, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setUUIDMetadata()
            .uuid(expectedId)
            .name(expectedName)
            .custom(@{ @"uuid": expectedUUIDData })
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {});
    }];
}

- (void)testItShouldSetUUIDMetadataWhenCalledWithETag {
    NSString *expectedUUIDData = [NSUUID UUID].UUIDString;
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedETag = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSDictionary *expectedBody = @{
        @"name": expectedName,
        @"custom": @{ @"uuid": expectedUUIDData }
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNSetUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        PNSetUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];


        XCTAssertNil([request validate]);
        XCTAssertNotNil(request.headers[@"If-Match"]);
        XCTAssertEqualObjects(request.headers[@"If-Match"], expectedETag);
        XCTAssertEqualObjects(request.identifier, expectedId);
        XCTAssertTrue([request.query[@"include"] containsString:@"custom"]);
        XCTAssertTrue([request.query[@"include"] containsString:@"status"]);
        XCTAssertTrue([request.query[@"include"] containsString:@"type"]);
        XCTAssertEqualObjects(request.body, expectedPayload);
    });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:expectedId];
        request.name = expectedName;
        request.custom = @{ @"uuid": expectedUUIDData };
        request.ifMatchesEtag = expectedETag;
        [self.client setUUIDMetadataWithRequest:request completion:^(PNSetUUIDMetadataStatus *status) {}];
    }];
}

- (void)testItShouldNotSetIncludeFieldsWhenCalledWithSetUUIDMetadataIncludeFieldsSetToZero {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNSetUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSetUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNil(request.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setUUIDMetadata()
            .uuid([NSUUID UUID].UUIDString)
            .name([NSUUID UUID].UUIDString)
            .includeFields(0)
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) { });
    }];
}

- (void)testItShouldSetUUIDMetadataUsingPubNubClientUUIDWhenUUIDIsMissing {
    NSString *expectedId = self.client.currentConfiguration.userID;


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNSetUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSetUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertTrue([request.query[@"include"] containsString:@"custom"]);
            XCTAssertTrue([request.query[@"include"] containsString:@"status"]);
            XCTAssertTrue([request.query[@"include"] containsString:@"type"]);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setUUIDMetadata()
            .name([NSUUID UUID].UUIDString)
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {});
    }];
}

- (void)testItShouldNotSetUUIDMetadataWhenUUIDIsTooLong {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [@[
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
    ] componentsJoinedByString:@""];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setUUIDMetadata()
            .uuid(expectedId)
            .name(expectedName)
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"too long"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testItShouldNotSetUUIDMetadataWhenUnsupportedDataTypeInCustom {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setUUIDMetadata()
            .uuid(expectedId)
            .name(expectedName)
            .custom(@{ @"date": [NSDate date] })
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Remove

- (void)testItShouldReturnRemoveUUIDMetadataBuilder {
    XCTAssertTrue([self.client.objects().removeUUIDMetadata() isKindOfClass:[PNRemoveUUIDMetadataAPICallBuilder class]]);
}


#pragma mark - Tests :: Remove :: Call

- (void)testItShouldRemoveUUIDMetadataWhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNRemoveUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRemoveUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.identifier, expectedId);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().removeUUIDMetadata()
            .uuid(expectedId)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}

- (void)testItShouldRemoveUUIDMetadataUsingPubNubClientUUIDWhenUUIDIsMissing {
    NSString *expectedId = self.client.currentConfiguration.userID;


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNRemoveUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRemoveUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.identifier, expectedId);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().removeUUIDMetadata()
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}


#pragma mark - Tests :: Fetch

- (void)testItShouldReturnFetchUUIDMetadataBuilder {
    XCTAssertTrue([self.client.objects().uuidMetadata() isKindOfClass:[PNFetchUUIDMetadataAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultFetchUUIDMetadataIncludeFields {
    PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, PNUUIDCustomField|PNUUIDStatusField|PNUUIDTypeField);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testItShouldFetchUUIDMetadataWhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertTrue([request.query[@"include"] containsString:@"custom"]);
            XCTAssertTrue([request.query[@"include"] containsString:@"status"]);
            XCTAssertTrue([request.query[@"include"] containsString:@"type"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().uuidMetadata()
            .uuid(expectedId)
            .performWithCompletion(^(PNFetchUUIDMetadataResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldNotSetIncludeFieldsWhenCalledWithFetchUUIDMetadataIncludeFieldsSetToZero {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];
            
            XCTAssertNil(request.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().uuidMetadata()
            .uuid([NSUUID UUID].UUIDString)
            .includeFields(0)
            .performWithCompletion(^(PNFetchUUIDMetadataResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldFetchUUIDMetadataUsingPubNubClientUUIDWhenUUIDIsMissing {
    NSString *expectedId = self.client.currentConfiguration.userID;


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertTrue([request.query[@"include"] containsString:@"custom"]);
            XCTAssertTrue([request.query[@"include"] containsString:@"status"]);
            XCTAssertTrue([request.query[@"include"] containsString:@"type"]);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().uuidMetadata()
            .performWithCompletion(^(PNFetchUUIDMetadataResult *result, PNErrorStatus *status) { });
    }];
}


#pragma mark - Tests :: Fetch all

- (void)testItShouldReturnFetchAllUUIDMetadataBuilder {
    XCTAssertTrue([self.client.objects().allUUIDMetadata() isKindOfClass:[PNFetchAllUUIDMetadataAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultFetchAllUUIDMetadataIncludeFields {
    PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
    
    
    XCTAssertEqual(request.includeFields, PNUUIDTotalCountField|PNUUIDStatusField|PNUUIDTypeField);
}


#pragma mark - Tests :: Fetch all :: Call

- (void)testItShouldFetchAllUsersWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    // Encoding is transport layer responsibility, so we are expecting raw string in query.
    NSString *expectedFilterExpression = filterExpression;
    NSString *expectedStart = [NSUUID UUID].UUIDString;
    NSString *expectedEnd = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchAllUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchAllUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

        XCTAssertEqualObjects(request.query[@"start"], expectedStart);
        XCTAssertEqualObjects(request.query[@"end"], expectedEnd);
        XCTAssertEqualObjects(request.query[@"include"], @"custom");
        XCTAssertEqualObjects(request.query[@"limit"], expectedLimit.stringValue);
        XCTAssertEqualObjects(request.query[@"filter"], expectedFilterExpression);
        XCTAssertNil(request.query[@"count"]);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().allUUIDMetadata()
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .filter(filterExpression)
            .includeFields(PNUUIDCustomField)
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldSetDefaultIncludeFieldsWhenCalledWithOutFetchAllUUIDMetadataIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchAllUUIDMetadataRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchAllUUIDMetadataRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];
            
            XCTAssertNotNil(request.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().allUUIDMetadata()
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {});
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
