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

@interface PNMemberObjectsTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMemberObjectsTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Manage

- (void)testItShouldReturnManageMembersBuilder {
    XCTAssertTrue([self.client.manageMembers() isKindOfClass:[PNManageMembersAPICallBuilder class]]);
}


#pragma mark - Tests :: Manage :: Call

- (void)testItShouldManageMembersWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray *addMembers = @[
        @{ @"userId": [NSUUID UUID].UUIDString, @"custom": @{ @"user": [NSUUID UUID].UUIDString } }
    ];
    NSArray *updateMembers = @[
        @{ @"userId": [NSUUID UUID].UUIDString, @"custom": @{ @"user": [NSUUID UUID].UUIDString } }
    ];
    NSArray *removeMembers = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSDictionary *expectedBody = @{
        @"add": @[@{ @"id": addMembers[0][@"userId"], @"custom": addMembers[0][@"custom"] }],
        @"update": @[@{ @"id": updateMembers[0][@"userId"], @"custom": updateMembers[0][@"custom"] }],
        @"remove": @[@{ @"id": removeMembers[0] }, @{ @"id": removeMembers[1] }],
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNManageMembersOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            NSArray *includeFields = [parameters.query[@"include"] componentsSeparatedByString:@","];
            SEL sortSelector = @selector(caseInsensitiveCompare:);
            NSString *includeQuery = [[includeFields sortedArrayUsingSelector:sortSelector] componentsJoinedByString:@","];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{space-id}"], expectedId);
            XCTAssertEqualObjects(includeQuery, @"custom,user.custom");
            XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.manageMembers()
            .spaceId(expectedId)
            .add(addMembers).update(updateMembers).remove(removeMembers)
            .filter(filterExpression)
            .includeFields(PNMemberCustomField|PNMemberUserCustomField)
            .performWithCompletion(^(PNManageMembersStatus *status) {});
    }];
}

- (void)testItShouldNotManageMembersWhenSpaceIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers().includeFields(PNMemberCustomField)
        .performWithCompletion(^(PNManageMembersStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space-id'"].location,
                              NSNotFound);
            
            handler();
        });
    }];
}

- (void)testItShouldNotManageMembersWhenUnsupportedDataTypeInCustom {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray *updateSpaces = @[
        @{ @"userId": [NSUUID UUID].UUIDString, @"custom": @{ @"user": [NSDate date] } }
    ];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMembers()
            .spaceId(expectedId)
            .update(updateSpaces)
            .includeFields(PNMemberCustomField)
            .performWithCompletion(^(PNManageMembersStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);
                XCTAssertNotEqual([status.errorData.information rangeOfString:updateSpaces[0][@"userId"]].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testItShouldReturnFetchMembersBuilder {
    XCTAssertTrue([self.client.fetchMembers() isKindOfClass:[PNFetchMembersAPICallBuilder class]]);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testItShouldFetchMembersWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    NSString *expectedStart = [NSUUID UUID].UUIDString;
    NSString *expectedEnd = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNFetchMembersOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertEqualObjects(parameters.pathComponents[@"{space-id}"], expectedId);
        XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
        XCTAssertEqualObjects(parameters.query[@"start"], expectedStart);
        XCTAssertEqualObjects(parameters.query[@"end"], expectedEnd);
        XCTAssertEqualObjects(parameters.query[@"limit"], expectedLimit.stringValue);
        XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
        XCTAssertNil(parameters.query[@"count"]);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchMembers()
            .spaceId(expectedId)
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .filter(filterExpression)
            .includeFields(PNMemberCustomField)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldNotFetchMembersWhenSpaceIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.fetchMembers()
        .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotEqual([status.errorData.information rangeOfString:@"'space-id'"].location,
                              NSNotFound);
            
            handler();
        });
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
