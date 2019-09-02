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

@interface PNUserObjectsTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNUserObjectsTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}


#pragma mark - Tests :: Create

- (void)testCreateUser_ShouldReturnBuilder {
    XCTAssertTrue([self.client.createUser() isKindOfClass:[PNCreateUserAPICallBuilder class]]);
}

- (void)testCreateUser_ShouldSetDefaultIncludeFields {
    PNCreateUserRequest *request = [PNCreateUserRequest requestWithUserID:[NSUUID UUID].UUIDString
                                                                     name:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, PNUserCustomField);
}


#pragma mark - Tests :: Create :: Call

- (void)testCreateUser_ShouldProcessOperation_WhenCalled {
    NSString *expectedUserData = [NSUUID UUID].UUIDString;
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSDictionary *expectedBody = @{
        @"id": expectedId,
        @"name": expectedName,
        @"custom": @{ @"user": expectedUserData }
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNCreateUserOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{user-id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.createUser()
            .userId(expectedId).name(expectedName).custom(@{ @"user": expectedUserData })
            .includeFields(PNUserCustomField).performWithCompletion(^(PNCreateUserStatus *status) {});
    }];
}

- (void)testCreateUser_ShouldNotSetDefaultIncludeFields_WhenCalledWithOutIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNCreateUserOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.createUser().userId([NSUUID UUID].UUIDString).name([NSUUID UUID].UUIDString)
            .performWithCompletion(^(PNCreateUserStatus *status) {});
    }];
}

- (void)testCreateUser_ShouldReturnError_WhenUserIdIsMissing {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createUser().name(expectedName).includeFields(PNUserCustomField)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'user-id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testCreateUser_ShouldReturnError_WhenUserIdIsTooLong {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [@[
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
    ] componentsJoinedByString:@""];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createUser().userId(expectedId).name(expectedName)
            .performWithCompletion(^(PNCreateUserStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"too long"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testCreateUser_ShouldReturnError_WhenUserNameIsMissing {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createUser().userId(expectedId)
        .includeFields(PNUserCustomField).performWithCompletion(^(PNCreateUserStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"'name'"].location,
                              NSNotFound);
            
            handler();
        });
    }];
}

- (void)testCreateUser_ShouldReturnError_WhenUnsupportedDataTypeInCustom {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.createUser().userId(expectedId).name(expectedName)
            .custom(@{ @"date": [NSDate date] }).performWithCompletion(^(PNCreateUserStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Update

- (void)testUpdateUser_ShouldReturnBuilder {
    XCTAssertTrue([self.client.updateUser() isKindOfClass:[PNUpdateUserAPICallBuilder class]]);
}

- (void)testUpdateUser_ShouldNotSetDefaultIncludeFields {
    PNUpdateUserRequest *request = [PNUpdateUserRequest requestWithUserID:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, 0);
}


#pragma mark - Tests :: Update :: Call

- (void)testUpdateUser_ShouldProcessOperation_WhenCalled {
    NSString *expectedUserData = [NSUUID UUID].UUIDString;
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSDictionary *expectedBody = @{
        @"id": expectedId,
        @"name": expectedName,
        @"custom": @{ @"user": expectedUserData }
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNUpdateUserOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{user-id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.updateUser()
            .userId(expectedId).name(expectedName).custom(@{ @"user": expectedUserData })
            .includeFields(PNUserCustomField).performWithCompletion(^(PNUpdateUserStatus *status) {});
    }];
}

- (void)testUpdateUser_ShouldNotSetDefaultIncludeFields_WhenCalledWithOutIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNUpdateUserOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.updateUser().userId([NSUUID UUID].UUIDString)
            .performWithCompletion(^(PNUpdateUserStatus *status) {});
    }];
}

- (void)testUpdateUser_ShouldReturnError_WhenUserIdIsMissing {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateUser().name(expectedName).includeFields(PNUserCustomField)
            .performWithCompletion(^(PNUpdateUserStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'user-id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testUpdateUser_ShouldNotReturnError_WhenUserNameIsMissing {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNUpdateUserOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]]).andDo(nil);
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.updateUser().userId(expectedId)
            .includeFields(PNUserCustomField).performWithCompletion(^(PNUpdateUserStatus *status) { });
    }];
}

- (void)testUpdateUser_ShouldReturnError_WhenUnsupportedDataTypeInCustom {
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateUser().userId(expectedId).name(expectedName)
            .custom(@{ @"date": [NSDate date] }).performWithCompletion(^(PNUpdateUserStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Delete

- (void)testDeleteUser_ShouldReturnBuilder {
    XCTAssertTrue([self.client.deleteUser() isKindOfClass:[PNDeleteUserAPICallBuilder class]]);
}


#pragma mark - Tests :: Delete :: Call

- (void)testDeleteUser_ShouldProcessOperation_WhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNDeleteUserOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertEqualObjects(parameters.pathComponents[@"{user-id}"], expectedId);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.deleteUser().userId(expectedId)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}

- (void)testDeleteUser_ShouldReturnError_WhenUserIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.updateUser().performWithCompletion(^(PNAcknowledgmentStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"'user-id'"].location,
                              NSNotFound);
            
            handler();
        });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testFetchUser_ShouldReturnBuilder {
    XCTAssertTrue([self.client.fetchUser() isKindOfClass:[PNFetchUserAPICallBuilder class]]);
}

- (void)testFetchUser_ShouldNotSetDefaultIncludeFields {
    PNFetchUserRequest *request = [PNFetchUserRequest requestWithUserID:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, 0);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testFetchUser_ShouldProcessOperation_WhenCalled {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchUserOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{user-id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchUser().userId(expectedId).includeFields(PNUserCustomField)
            .performWithCompletion(^(PNFetchUserResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testFetchUser_ShouldNotSetDefaultIncludeFields_WhenCalledWithOutIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchUserOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchUser().userId([NSUUID UUID].UUIDString)
            .performWithCompletion(^(PNFetchUserResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testFetchUser_ShouldReturnError_WhenUserIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchUser()
            .performWithCompletion(^(PNFetchUserResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'user-id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch all

- (void)testFetchUsers_ShouldReturnBuilder {
    XCTAssertTrue([self.client.fetchUsers() isKindOfClass:[PNFetchUsersAPICallBuilder class]]);
}

- (void)testFetchUserS_ShouldNotSetDefaultIncludeFields {
    PNFetchUsersRequest *request = [PNFetchUsersRequest new];
    
    
    XCTAssertEqual(request.includeFields, 0);
}


#pragma mark - Tests :: Fetch all :: Call

- (void)testFetchAllUsers_ShouldProcessOperation_WhenCalled {
    NSString *expectedStart = [NSUUID UUID].UUIDString;
    NSString *expectedEnd = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchUsersOperation
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
        self.client.fetchUsers()
            .start(expectedStart).end(expectedEnd).limit(expectedLimit.unsignedIntegerValue)
            .includeFields(PNUserCustomField)
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testFetchUsers_ShouldNotSetDefaultIncludeFields_WhenCalledWithOutIncludeFields {
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchUsersOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertNil(parameters.query[@"include"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchUsers()
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {});
    }];
}

#pragma mark -


@end
