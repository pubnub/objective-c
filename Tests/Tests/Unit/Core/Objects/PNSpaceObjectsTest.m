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

@interface PNSpaceObjectsTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNSpaceObjectsTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Create

- (void)testItShouldReturnCreateSpaceBuilder {
    XCTAssertTrue([self.client.createSpace() isKindOfClass:[PNCreateSpaceAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultCreateSpaceIncludeFields {
    PNCreateSpaceRequest *request = [PNCreateSpaceRequest requestWithSpaceID:[NSUUID UUID].UUIDString
                                                                        name:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, PNSpaceCustomField);
}


#pragma mark - Tests :: Create :: Call

- (void)testItShouldCreateSpaceWhenCalled {
    NSString *expectedInformation = [NSUUID UUID].UUIDString;
    NSString *expectedSpaceData = [NSUUID UUID].UUIDString;
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSDictionary *expectedBody = @{
        @"id": expectedId,
        @"name": expectedName,
        @"description": expectedInformation,
        @"custom": @{ @"space": expectedSpaceData }
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNCreateSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{space-id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.createSpace()
            .spaceId(expectedId).name(expectedName).information(expectedInformation)
            .custom(@{ @"space": expectedSpaceData }).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {});
    }];
}

- (void)testItShouldNotSetDefaultIncludeFieldsWhenCalledWithOutCreateSpaceIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNCreateSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.createSpace().spaceId([NSUUID UUID].UUIDString).name([NSUUID UUID].UUIDString)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {});
    }];
}

- (void)testItShouldNotCreateSpaceWhenSpaceIdIsMissing {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createSpace().name(expectedName).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space-id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testItShouldNotCreateSpaceWhenSpaceIdIsTooLong {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [@[
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
    ] componentsJoinedByString:@""];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createSpace().spaceId(expectedId).name(expectedName)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"too long"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testItShouldNotCreateSpaceWhenNameIsMissing {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createSpace().spaceId(expectedId)
        .includeFields(PNSpaceCustomField).performWithCompletion(^(PNCreateSpaceStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"'name'"].location,
                              NSNotFound);
            
            handler();
        });
    }];
}

- (void)testItShouldNotCreateSpaceWhenUnsupportedDataTypeInCustom {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createSpace().spaceId(expectedId).name(expectedName)
            .custom(@{ @"date": [NSDate date] }).performWithCompletion(^(PNCreateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Update

- (void)testItShouldReturnUpdateSpaceBuilder {
    XCTAssertTrue([self.client.updateSpace() isKindOfClass:[PNUpdateSpaceAPICallBuilder class]]);
}

- (void)testItShouldNotSetDefaultUpdateSpaceIncludeFields {
    PNUpdateSpaceRequest *request = [PNUpdateSpaceRequest requestWithSpaceID:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, 0);
}


#pragma mark - Tests :: Update :: Call

- (void)testItShouldUpdateSpaceWhenCalled {
    NSString *expectedInformation = [NSUUID UUID].UUIDString;
    NSString *expectedUserData = [NSUUID UUID].UUIDString;
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSDictionary *expectedBody = @{
        @"id": expectedId,
        @"name": expectedName,
        @"description": expectedInformation,
        @"custom": @{ @"user": expectedUserData }
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNUpdateSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{space-id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.updateSpace().spaceId(expectedId).name(expectedName)
            .information(expectedInformation).custom(@{ @"user": expectedUserData })
            .includeFields(PNSpaceCustomField).performWithCompletion(^(PNUpdateSpaceStatus *status) {});
    }];
}

- (void)testItShouldNotSetDefaultIncludeFieldsWhenCalledWithOutUpdateSpaceIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNUpdateSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.updateSpace().spaceId([NSUUID UUID].UUIDString)
            .performWithCompletion(^(PNUpdateSpaceStatus *status) {});
    }];
}

- (void)testItShouldNotUpdateSpaceWhenSpaceIdIsMissing {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateSpace().name(expectedName).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNUpdateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space-id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testItShouldNotUpdateSpaceWhenNameIsMissing {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNUpdateSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]]).andDo(nil);
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.updateSpace().spaceId(expectedId)
            .includeFields(PNSpaceCustomField).performWithCompletion(^(PNUpdateSpaceStatus *status) { });
    }];
}

- (void)testItShouldNotUpdateSpaceWhenUnsupportedDataTypeInCustom {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateSpace().spaceId(expectedId).name(expectedName)
            .custom(@{ @"date": [NSDate date] }).performWithCompletion(^(PNUpdateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Delete

- (void)testItShouldReturnDeleteSpaceBuilder {
    XCTAssertTrue([self.client.deleteSpace() isKindOfClass:[PNDeleteSpaceAPICallBuilder class]]);
}


#pragma mark - Tests :: Delete :: Call

- (void)testItShouldDeleteSpaceWhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNDeleteSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertEqualObjects(parameters.pathComponents[@"{space-id}"], expectedId);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.deleteSpace().spaceId(expectedId)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}

- (void)testItShouldNotDeleteSpaceWhenSpaceIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.deleteSpace().performWithCompletion(^(PNAcknowledgmentStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space-id'"].location,
                              NSNotFound);
            
            handler();
        });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testItShouldReturnFetchSpaceBuilder {
    XCTAssertTrue([self.client.fetchSpace() isKindOfClass:[PNFetchSpaceAPICallBuilder class]]);
}

- (void)testItShouldNotSetDefaultFetchSpaceIncludeFields {
    PNFetchSpaceRequest *request = [PNFetchSpaceRequest requestWithSpaceID:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, 0);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testItShouldFetchSpaceWhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{space-id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchSpace().spaceId(expectedId).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNFetchSpaceResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldNotSetDefaultIncludeFieldsWhenCalledWithOutFetchSpaceIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchSpace().spaceId([NSUUID UUID].UUIDString)
            .performWithCompletion(^(PNFetchSpaceResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldNotFetchSpaceWhenSpaceIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpace()
            .performWithCompletion(^(PNFetchSpaceResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space-id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch all

- (void)testItShouldReturnFetchSpacesBuilder {
    XCTAssertTrue([self.client.fetchSpaces() isKindOfClass:[PNFetchSpacesAPICallBuilder class]]);
}

- (void)testItShouldNotSetDefaultFetchSpacesIncludeFields {
    PNFetchSpacesRequest *request = [PNFetchSpacesRequest new];
    
    
    XCTAssertEqual(request.includeFields, 0);
}


#pragma mark - Tests :: Fetch all :: Call

- (void)testItShouldFetchAllSpacesWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSString *expectedStart = [NSUUID UUID].UUIDString;
    NSString *expectedEnd = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchSpacesOperation
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
        self.client.fetchSpaces()
            .start(expectedStart).end(expectedEnd).limit(expectedLimit.unsignedIntegerValue)
            .filter(filterExpression)
            .includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldNotSetDefaultIncludeFieldsWhenCalledWithOutFetchAllSpacesIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchSpacesOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchSpaces()
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {});
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
