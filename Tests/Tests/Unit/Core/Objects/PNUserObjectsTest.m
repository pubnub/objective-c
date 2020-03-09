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

@interface PNUserObjectsTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNUserObjectsTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Create

- (void)testItShouldReturnCreateUserBuilder {
    XCTAssertTrue([self.client.createUser() isKindOfClass:[PNCreateUserAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultCreateUserIncludeFields {
    PNCreateUserRequest *request = [PNCreateUserRequest requestWithUserID:[NSUUID UUID].UUIDString
                                                                     name:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, PNUserCustomField);
}


#pragma mark - Tests :: Create :: Call

- (void)testItShouldCreateUserWhenCalled {
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

- (void)testItShouldNotSetDefaultIncludeFieldsWhenCalledWithOutCreateUserIncludeFields {
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

- (void)testItShouldNotCreateUserWhenUserIdIsMissing {
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

- (void)testItShouldNotCreateUserWhenUserIdIsTooLong {
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

- (void)testItShouldNotCreateUserWhenUserNameIsMissing {
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

- (void)testItShouldNotCreateUserWhenUnsupportedDataTypeInCustom {
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

- (void)testItShouldReturnUpdateUserBuilder {
    XCTAssertTrue([self.client.updateUser() isKindOfClass:[PNUpdateUserAPICallBuilder class]]);
}

- (void)testItShouldNotSetDefaultUpdateUserIncludeFields {
    PNUpdateUserRequest *request = [PNUpdateUserRequest requestWithUserID:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, 0);
}


#pragma mark - Tests :: Update :: Call

- (void)testItShouldUpdateUserWhenCalled {
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

- (void)testItShouldNotSetDefaultIncludeFieldsWhenCalledWithOutUpdateUserIncludeFields {
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

- (void)testItShouldNotUpdateUserWhenUserIdIsMissing {
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

- (void)testItShouldNotUpdateUserWhenUserNameIsMissing {
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

- (void)testItShouldNotUpdateUserWhenUnsupportedDataTypeInCustom {
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

- (void)testItShouldReturnDeleteUserBuilder {
    XCTAssertTrue([self.client.deleteUser() isKindOfClass:[PNDeleteUserAPICallBuilder class]]);
}


#pragma mark - Tests :: Delete :: Call

- (void)testItShouldDeleteUserWhenCalled {
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

- (void)testItShouldNotDeleteUserWhenUserIdIsMissing {
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

- (void)testItShouldReturnFetchUserBuilder {
    XCTAssertTrue([self.client.fetchUser() isKindOfClass:[PNFetchUserAPICallBuilder class]]);
}

- (void)testItShouldNotSetDefaultFetchUserIncludeFields {
    PNFetchUserRequest *request = [PNFetchUserRequest requestWithUserID:[NSUUID UUID].UUIDString];
    
    
    XCTAssertEqual(request.includeFields, 0);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testItShouldFetchUserWhenCalled {
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

- (void)testItShouldNotSetDefaultIncludeFieldsWhenCalledWithOutFetchUserIncludeFields {
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

- (void)testItShouldNotFetchUserWhenUserIdIsMissing {
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

- (void)testItShouldReturnFetchUsersBuilder {
    XCTAssertTrue([self.client.fetchUsers() isKindOfClass:[PNFetchUsersAPICallBuilder class]]);
}

- (void)testItShouldNotSetDefaultFetchUsersIncludeFields {
    PNFetchUsersRequest *request = [PNFetchUsersRequest new];
    
    
    XCTAssertEqual(request.includeFields, 0);
}


#pragma mark - Tests :: Fetch all :: Call

- (void)testItShouldFetchAllUsersWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
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
        XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
        XCTAssertNil(parameters.query[@"count"]);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchUsers()
            .start(expectedStart).end(expectedEnd).limit(expectedLimit.unsignedIntegerValue)
            .filter(filterExpression)
            .includeFields(PNUserCustomField)
            .performWithCompletion(^(PNFetchUsersResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldNotSetDefaultIncludeFieldsWhenCalledWithOutFetchUsersIncludeFields {
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

#pragma clang diagnostic pop

@end
