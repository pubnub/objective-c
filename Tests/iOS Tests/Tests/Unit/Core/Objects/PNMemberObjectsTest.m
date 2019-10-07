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

@interface PNMemberObjectsTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNMemberObjectsTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}


#pragma mark - Tests :: Manage

- (void)testManageMembers_ShouldReturnBuilder {
    XCTAssertTrue([self.client.manageMembers() isKindOfClass:[PNManageMembersAPICallBuilder class]]);
}


#pragma mark - Tests :: Manage :: Call

- (void)testManageMembers_ShouldProcessOperation_WhenCalled {
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
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNManageMembersOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{space-id}"], expectedId);
            XCTAssertEqualObjects(parameters.query[@"include"], @"custom,user.custom");
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.manageMembers()
            .spaceId(expectedId)
            .add(addMembers).update(updateMembers).remove(removeMembers)
            .includeFields(PNMemberCustomField|PNMemberUserCustomField)
            .performWithCompletion(^(PNManageMembersStatus *status) {});
    }];
}

- (void)testManageMembers_ShouldReturnError_WhenSpaceIdIsMissing {
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

- (void)testManageMembers_ShouldReturnError_WhenUnsupportedDataTypeInCustom {
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

- (void)testFetchMembers_ShouldReturnBuilder {
    XCTAssertTrue([self.client.fetchMembers() isKindOfClass:[PNFetchMembersAPICallBuilder class]]);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testFetchMembers_ShouldProcessOperation_WhenCalled {
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
        XCTAssertNil(parameters.query[@"count"]);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchMembers()
            .spaceId(expectedId)
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .includeFields(PNMemberCustomField)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testFetchMembers_ShouldReturnError_WhenSpaceIdIsMissing {
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


@end
