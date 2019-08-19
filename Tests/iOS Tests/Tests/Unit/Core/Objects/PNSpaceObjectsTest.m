/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PNRequestParameters.h>
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>
#import "PNTestCase.h"


#pragma mark Test interface declaration

@interface PNSpaceObjectsTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNSpaceObjectsTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}


#pragma mark - Tests :: Create

- (void)testCreateSpace_ShouldReturnBuilder {
    XCTAssertTrue([self.client.createSpace() isKindOfClass:[PNCreateSpaceAPICallBuilder class]]);
}


#pragma mark - Tests :: Create :: Call

- (void)testCreateSpace_ShouldProcessOperation_WhenCalled {
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
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{space_id}"], expectedId);
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

- (void)testCreateSpace_ShouldReturnError_WhenSpaceIdIsMissing {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createSpace().name(expectedName).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNCreateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space_id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testCreateSpace_ShouldReturnError_WhenSpaceIdIsTooLong {
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

- (void)testCreateSpace_ShouldReturnError_WhenNameIsMissing {
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

- (void)testCreateSpace_ShouldReturnError_WhenUnsupportedDataTypeInCustom {
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

- (void)testUpdateSpace_ShouldReturnBuilder {
    XCTAssertTrue([self.client.updateSpace() isKindOfClass:[PNUpdateSpaceAPICallBuilder class]]);
}


#pragma mark - Tests :: Update :: Call

- (void)testUpdateSpace_ShouldProcessOperation_WhenCalled {
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
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{space_id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.updateSpace().spaceId(expectedId).name(expectedName)
            .information(expectedInformation).custom(@{ @"user": expectedUserData })
            .includeFields(PNSpaceCustomField).performWithCompletion(^(PNUpdateSpaceStatus *status) {});
    }];
}

- (void)testUpdateSpace_ShouldReturnError_WhenSpaceIdIsMissing {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateSpace().name(expectedName).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNUpdateSpaceStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space_id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testUpdateSpace_ShouldNotReturnError_WhenNameIsMissing {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateSpace().spaceId(expectedId)
            .includeFields(PNSpaceCustomField).performWithCompletion(^(PNUpdateSpaceStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
    }];
}

- (void)testUpdateUser_ShouldReturnError_WhenUnsupportedDataTypeInCustom {
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

- (void)testDeleteSpace_ShouldReturnBuilder {
    XCTAssertTrue([self.client.deleteSpace() isKindOfClass:[PNDeleteSpaceAPICallBuilder class]]);
}


#pragma mark - Tests :: Delete :: Call

- (void)testDeleteSpace_ShouldProcessOperation_WhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNDeleteSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertEqualObjects(parameters.pathComponents[@"{space_id}"], expectedId);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.deleteSpace().spaceId(expectedId)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}

- (void)testDeleteSpace_ShouldReturnError_WhenSpaceIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.deleteSpace().performWithCompletion(^(PNAcknowledgmentStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space_id'"].location,
                              NSNotFound);
            
            handler();
        });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testFetchSpace_ShouldReturnBuilder {
    XCTAssertTrue([self.client.fetchSpace() isKindOfClass:[PNFetchSpaceAPICallBuilder class]]);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testFetchSpace_ShouldProcessOperation_WhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchSpaceOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{space_id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchSpace().spaceId(expectedId).includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNFetchSpaceResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testFetchSpace_ShouldReturnError_WhenSpaceIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchSpace()
            .performWithCompletion(^(PNFetchSpaceResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space_id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch all

- (void)testFetchSpaces_ShouldReturnBuilder {
    XCTAssertTrue([self.client.fetchSpaces() isKindOfClass:[PNFetchSpacesAPICallBuilder class]]);
}


#pragma mark - Tests :: Fetch all :: Call

- (void)testFetchAllSpaces_ShouldProcessOperation_WhenCalled {
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
        XCTAssertNil(parameters.query[@"count"]);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchSpaces()
            .start(expectedStart).end(expectedEnd).limit(expectedLimit.unsignedIntegerValue)
            .includeFields(PNSpaceCustomField)
            .performWithCompletion(^(PNFetchSpacesResult *result, PNErrorStatus *status) {});
    }];
}

#pragma mark -


@end
