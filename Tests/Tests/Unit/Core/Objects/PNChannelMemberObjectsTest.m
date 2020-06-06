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

@interface PNChannelMemberObjectsTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNChannelMemberObjectsTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Set

- (void)testItShouldReturnSetMembersBuilder {
    XCTAssertTrue([self.client.objects().setChannelMembers(@"secret") isKindOfClass:[PNSetChannelMembersAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultSetMembersIncludeFields {
    PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:[NSUUID UUID].UUIDString
                                                                                   uuids:@[]];


    XCTAssertEqual(request.includeFields, PNChannelMembersTotalCountField);
}


#pragma mark - Tests :: Set :: Call

- (void)testItShouldSetMembersWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray<NSDictionary *> *uuids = @[
        @{ @"uuid": [NSUUID UUID].UUIDString, @"custom": @{ @"uuid": [NSUUID UUID].UUIDString } }
    ];
    NSDictionary *expectedBody = @{
        @"set": @[@{ @"uuid": @{ @"id": uuids[0][@"uuid"] }, @"custom": uuids[0][@"custom"] }],
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNSetChannelMembersOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            NSArray *includeFields = [parameters.query[@"include"] componentsSeparatedByString:@","];
            SEL sortSelector = @selector(caseInsensitiveCompare:);
            NSString *includeQuery = [[includeFields sortedArrayUsingSelector:sortSelector] componentsJoinedByString:@","];

            XCTAssertEqualObjects(parameters.pathComponents[@"{channel}"], expectedId);
            XCTAssertEqualObjects(includeQuery, @"custom,uuid.custom");
            XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
            XCTAssertEqualObjects(sentData, expectedPayload);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setChannelMembers(expectedId)
            .uuids(uuids)
            .filter(filterExpression)
            .includeFields(PNChannelMemberCustomField|PNChannelMemberUUIDCustomField)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {});
    }];
}

- (void)testItShouldNotSetMembersWhenUnsupportedDataTypeInCustom {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray<NSDictionary *> *uuids = @[
        @{ @"uuid": [NSUUID UUID].UUIDString, @"custom": @{ @"uuid": [NSDate date] } }
    ];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().setChannelMembers(expectedId)
            .uuids(uuids)
            .includeFields(PNChannelMemberCustomField)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                        NSNotFound);
                XCTAssertNotEqual([status.errorData.information rangeOfString:uuids[0][@"uuid"]].location,
                        NSNotFound);

                handler();
            });
    }];
}


#pragma mark - Tests :: Remove

- (void)testItShouldReturnRemoveMembersBuilder {
    XCTAssertTrue([self.client.objects().removeChannelMembers(@"secret") isKindOfClass:[PNRemoveChannelMembersAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultRemoveMembersIncludeFields {
    PNRemoveChannelMembersRequest *request = [PNRemoveChannelMembersRequest requestWithChannel:[NSUUID UUID].UUIDString
                                                                                         uuids:@[]];


    XCTAssertEqual(request.includeFields, PNChannelMembersTotalCountField);
}


#pragma mark - Tests :: Remove :: Call

- (void)testItShouldRemoveMembersWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray<NSString *> *uuids = @[ [NSUUID UUID].UUIDString ];
    NSDictionary *expectedBody = @{
        @"delete": @[@{ @"uuid": @{ @"id": uuids[0] } }],
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNRemoveChannelMembersOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            NSArray *includeFields = [parameters.query[@"include"] componentsSeparatedByString:@","];
            SEL sortSelector = @selector(caseInsensitiveCompare:);
            NSString *includeQuery = [[includeFields sortedArrayUsingSelector:sortSelector] componentsJoinedByString:@","];

            XCTAssertEqualObjects(parameters.pathComponents[@"{channel}"], expectedId);
            XCTAssertEqualObjects(includeQuery, @"custom,uuid.custom");
            XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
            XCTAssertEqualObjects(sentData, expectedPayload);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().removeChannelMembers(expectedId)
                .uuids(uuids)
                .filter(filterExpression)
                .includeFields(PNChannelMemberCustomField|PNChannelMemberUUIDCustomField)
                .performWithCompletion(^(PNManageChannelMembersStatus *status) {});
    }];
}


#pragma mark - Tests :: Manage

- (void)testItShouldReturnManageMembersBuilder {
    XCTAssertTrue([self.client.objects().manageChannelMembers(@"secret") isKindOfClass:[PNManageChannelMembersAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultManageMembersIncludeFields {
    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:[NSUUID UUID].UUIDString];


    XCTAssertEqual(request.includeFields, PNChannelMembersTotalCountField);
}


#pragma mark - Tests :: Manage :: Call

- (void)testItShouldManageMembersWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray<NSDictionary *> *setMembers = @[
        @{ @"uuid": [NSUUID UUID].UUIDString, @"custom": @{ @"uuid": [NSUUID UUID].UUIDString } }
    ];
    NSArray<NSString *> *removeMembers = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSDictionary *expectedBody = @{
        @"set": @[@{ @"uuid": @{ @"id": setMembers[0][@"uuid"] }, @"custom": setMembers[0][@"custom"] }],
        @"delete": @[
            @{ @"uuid": @{ @"id": removeMembers[0] } },
            @{ @"uuid": @{ @"id": removeMembers[1] } }
        ],
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    NSString *expectedFilterExpression = [PNString percentEscapedString:filterExpression];
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock processOperation:PNManageChannelMembersOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
            NSData *sentData = [self objectForInvocation:invocation argumentAtIndex:3];
            NSArray *includeFields = [parameters.query[@"include"] componentsSeparatedByString:@","];
            SEL sortSelector = @selector(caseInsensitiveCompare:);
            NSString *includeQuery = [[includeFields sortedArrayUsingSelector:sortSelector] componentsJoinedByString:@","];
            
            XCTAssertEqualObjects(parameters.pathComponents[@"{channel}"], expectedId);
            XCTAssertEqualObjects(includeQuery, @"custom,uuid.custom");
            XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
            XCTAssertEqualObjects(sentData, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().manageChannelMembers(expectedId)
            .set(setMembers)
            .remove(removeMembers)
            .filter(filterExpression)
            .includeFields(PNChannelMemberCustomField|PNChannelMemberUUIDCustomField)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {});
    }];
}

- (void)testItShouldNotManageMembersWhenUnsupportedDataTypeInCustom {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray<NSDictionary *> *uuids = @[
        @{ @"uuid": [NSUUID UUID].UUIDString, @"custom": @{ @"user": [NSDate date] } }
    ];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageChannelMembers(expectedId)
            .set(uuids)
            .includeFields(PNChannelMemberCustomField)
            .performWithCompletion(^(PNManageChannelMembersStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);
                XCTAssertNotEqual([status.errorData.information rangeOfString:uuids[0][@"uuid"]].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testItShouldReturnFetchMembersBuilder {
    XCTAssertTrue([self.client.objects().channelMembers(@"secret") isKindOfClass:[PNFetchChannelMembersAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultFetchMembersIncludeFields {
    PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:[NSUUID UUID].UUIDString];


    XCTAssertEqual(request.includeFields, PNChannelMembersTotalCountField);
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
    id recorded = OCMExpect([clientMock processOperation:PNFetchChannelMembersOperation
                                          withParameters:[OCMArg any]
                                                    data:[OCMArg any]
                                         completionBlock:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        PNRequestParameters *parameters = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertEqualObjects(parameters.pathComponents[@"{channel}"], expectedId);
        XCTAssertEqualObjects(parameters.query[@"include"], @"custom");
        XCTAssertEqualObjects(parameters.query[@"start"], expectedStart);
        XCTAssertEqualObjects(parameters.query[@"end"], expectedEnd);
        XCTAssertEqualObjects(parameters.query[@"limit"], expectedLimit.stringValue);
        XCTAssertEqualObjects(parameters.query[@"filter"], expectedFilterExpression);
        XCTAssertNil(parameters.query[@"count"]);
    });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().channelMembers(expectedId)
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .filter(filterExpression)
            .includeFields(PNChannelMemberCustomField)
            .performWithCompletion(^(PNFetchChannelMembersResult *result, PNErrorStatus *status) {});
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
