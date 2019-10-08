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

@interface PNMembershipObjectsTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNMembershipObjectsTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}


#pragma mark - Tests :: Manage

- (void)testManageMemberships_ShouldReturnBuilder {
    XCTAssertTrue([self.client.manageMemberships() isKindOfClass:[PNManageMembershipsAPICallBuilder class]]);
}


#pragma mark - Tests :: Manage :: Call

- (void)testManageMemberships_ShouldProcessOperation_WhenCalled {
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
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNManageMembershipsOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
        
        XCTAssertEqualObjects(parameters.pathComponents[@"{user-id}"], expectedId);
        XCTAssertEqualObjects(parameters.query[@"include"], @"custom,space.custom");
        XCTAssertEqualObjects(sentData, expectedPayload);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.manageMemberships()
            .userId(expectedId)
            .add(addSpaces).update(updateSpaces).remove(removeSpaces)
            .includeFields(PNMembershipCustomField|PNMembershipSpaceCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {});
    }];
}

- (void)testManageMemberships_ShouldReturnError_WhenUserIdIsMissing {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.manageMemberships().includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'user-id'"].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}

- (void)testManageMemberships_ShouldReturnError_WhenUnsupportedDataTypeInCustom {
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

- (void)testFetchMemberships_ShouldReturnBuilder {
    XCTAssertTrue([self.client.fetchMemberships() isKindOfClass:[PNFetchMembershipsAPICallBuilder class]]);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testFetchMemberships_ShouldProcessOperation_WhenCalled {
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
            XCTAssertNil(parameters.query[@"count"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.fetchMemberships()
            .userId(expectedId)
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testFetchMemberships_ShouldReturnError_WhenUserIdIsMissing {
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


@end
