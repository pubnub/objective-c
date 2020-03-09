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

@interface PNMembershipObjectsTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMembershipObjectsTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Manage

- (void)testItShouldReturnManageBuilder {
    XCTAssertTrue([self.client.manageMemberships() isKindOfClass:[PNManageMembershipsAPICallBuilder class]]);
}


#pragma mark - Tests :: Manage :: Call

- (void)testItShouldManageMembershipsWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray *addSpaces = @[
        @{ @"spaceId": [NSUUID UUID].UUIDString, @"custom": @{ @"space": [NSUUID UUID].UUIDString } }
    ];
    NSArray *updateSpaces = @[
        @{ @"spaceId": [NSUUID UUID].UUIDString, @"custom": @{ @"space": [NSUUID UUID].UUIDString } }
    ];
    NSArray *removeSpaces = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSDictionary *expectedBody = @{
        @"add": @[@{ @"id": addSpaces[0][@"spaceId"], @"custom": addSpaces[0][@"custom"] }],
        @"update": @[@{ @"id": updateSpaces[0][@"spaceId"], @"custom": updateSpaces[0][@"custom"] }],
        @"remove": @[@{ @"id": removeSpaces[0] }, @{ @"id": removeSpaces[1] }],
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNManageMembershipsOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            NSArray *includeFields = [parameters.query[@"include"] componentsSeparatedByString:@","];
            SEL sortSelector = @selector(caseInsensitiveCompare:);
            NSString *includeQuery = [[includeFields sortedArrayUsingSelector:sortSelector] componentsJoinedByString:@","];

            XCTAssertEqualObjects(parameters.pathComponents[@"{user-id}"], expectedId);
            XCTAssertEqualObjects(includeQuery, @"custom,space.custom");
            XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.manageMemberships()
            .userId(expectedId)
            .add(addSpaces).update(updateSpaces).remove(removeSpaces)
            .filter(filterExpression)
            .includeFields(PNMembershipCustomField|PNMembershipSpaceCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {});
    }];
}

- (void)testItShouldNotManageMembershipsWhenUserIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'user-id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testItShouldNotManageMembershipsWhenUnsupportedDataTypeInCustom {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray *updateSpaces = @[
        @{ @"spaceId": [NSUUID UUID].UUIDString, @"custom": @{ @"space": [NSDate date] } }
    ];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships()
            .userId(expectedId)
            .update(updateSpaces)
            .includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);
                XCTAssertNotEqual([status.errorData.information rangeOfString:updateSpaces[0][@"spaceId"]].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testItShouldReturnFetchBuilder {
    XCTAssertTrue([self.client.fetchMemberships() isKindOfClass:[PNFetchMembershipsAPICallBuilder class]]);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testItShouldFetchMembershipsWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSString *expectedStart = [NSUUID UUID].UUIDString;
    NSString *expectedEnd = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchMembershipsOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{user-id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
            XCTAssertEqualObjects(parameters.query[@"start"], expectedStart);
            XCTAssertEqualObjects(parameters.query[@"end"], expectedEnd);
            XCTAssertEqualObjects(parameters.query[@"limit"], expectedLimit.stringValue);
            XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
            XCTAssertNil(parameters.query[@"count"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchMemberships()
            .userId(expectedId)
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .filter(filterExpression)
            .includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldNotFetchMembershipsWhenUserIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMemberships()
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'user-id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
