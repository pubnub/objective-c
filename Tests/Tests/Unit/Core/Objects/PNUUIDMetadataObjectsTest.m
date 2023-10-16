/**
* @author Serhii Mamontov
* @copyright © 2010-2020 PubNub, Inc.
*/
#import <PubNub/PNRequestParameters.h>
#import <PubNub/PubNub+CorePrivate.h>
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
    
    
    XCTAssertEqual(request.includeFields, PNUUIDCustomField);
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
    id recorded = OCMExpect([clientMock processOperation:PNSetUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{uuid}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setUUIDMetadata()
            .uuid(expectedId)
            .name(expectedName)
            .custom(@{ @"uuid": expectedUUIDData })
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {});
    }];
}

- (void)testItShouldNotSetIncludeFieldsWhenCalledWithSetUUIDMetadataIncludeFieldsSetToZero {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNSetUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setUUIDMetadata()
            .uuid([NSUUID UUID].UUIDString)
            .name([NSUUID UUID].UUIDString)
            .includeFields(0)
            .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {});
    }];
}

- (void)testItShouldSetUUIDMetadataUsingPubNubClientUUIDWhenUUIDIsMissing {
    NSString *expectedId = self.client.currentConfiguration.userID;


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNSetUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];

            XCTAssertEqualObjects(parameters.pathComponents[@"{uuid}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
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
    id recorded = OCMExpect([clientMock processOperation:PNRemoveUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];

            XCTAssertEqualObjects(parameters.pathComponents[@"{uuid}"], expectedId);
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
    id recorded = OCMExpect([clientMock processOperation:PNRemoveUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];

            XCTAssertEqualObjects(parameters.pathComponents[@"{uuid}"], expectedId);
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
    
    
    XCTAssertEqual(request.includeFields, PNUUIDCustomField);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testItShouldFetchUUIDMetadataWhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{uuid}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().uuidMetadata()
            .uuid(expectedId)
            .performWithCompletion(^(PNFetchUUIDMetadataResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldNotSetIncludeFieldsWhenCalledWithFetchUUIDMetadataIncludeFieldsSetToZero {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
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
    id recorded = OCMExpect([clientMock processOperation:PNFetchUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];

            XCTAssertEqualObjects(parameters.pathComponents[@"{uuid}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
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
    
    
    XCTAssertEqual(request.includeFields, PNUUIDTotalCountField);
}


#pragma mark - Tests :: Fetch all :: Call

- (void)testItShouldFetchAllUsersWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSString *expectedStart = [NSUUID UUID].UUIDString;
    NSString *expectedEnd = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchAllUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertEqualObjects(parameters.query[@"start"], expectedStart);
        XCTAssertEqualObjects(parameters.query[@"end"], expectedEnd);
        XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
        XCTAssertEqualObjects(parameters.query[@"limit"], expectedLimit.stringValue);
        XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
        XCTAssertNil(parameters.query[@"count"]);
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
    id recorded = OCMExpect([clientMock processOperation:PNFetchAllUUIDMetadataOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNotNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().allUUIDMetadata()
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {});
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
