/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import <PubNub/PNBaseObjectsRequest+Private.h>
#import <PubNub/PNRemoveMembershipsRequest.h>
#import <PubNub/PNManageMembershipsRequest.h>
#import <PubNub/PNFetchMembershipsRequest.h>
#import <PubNub/PNSetMembershipsRequest.h>
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
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Set

- (void)testItShouldReturnSetMembershipsBuilder {
    XCTAssertTrue([self.client.objects().setMemberships() isKindOfClass:[PNSetMembershipsAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultSetMembershipIncludeFields {
    PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:[NSUUID UUID].UUIDString
                                                                       channels:@[]];


    XCTAssertEqual(request.includeFields, PNMembershipsTotalCountField);
}


#pragma mark - Tests :: Set :: Call

- (void)testItShouldSetMembershipsWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": [NSUUID UUID].UUIDString, @"custom": @{ @"channel": [NSUUID UUID].UUIDString } }
    ];
    NSDictionary *expectedBody = @{
        @"set": @[
            @{ @"channel": @{ @"id": channels[0][@"channel"] }, @"custom": channels[0][@"custom"] }
        ]
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    // Encoding is transport layer responsibility, so we are expecting raw string in query.
    NSString *expectedFilterExpression = filterExpression;

    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNSetMembershipsRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSetMembershipsRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];
            NSArray *includeFields = [request.query[@"include"] componentsSeparatedByString:@","];
            SEL sortSelector = @selector(caseInsensitiveCompare:);
            NSString *includeQuery = [[includeFields sortedArrayUsingSelector:sortSelector] componentsJoinedByString:@","];

            XCTAssertNil([request validate]);
            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertEqualObjects(includeQuery, @"channel.custom,custom");
            XCTAssertEqualObjects(request.query[@"filter"], expectedFilterExpression);
            XCTAssertEqualObjects(request.body, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setMemberships()
            .uuid(expectedId)
            .channels(channels)
            .filter(filterExpression)
            .includeFields(PNMembershipCustomField|PNMembershipChannelCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {});
    }];
}

- (void)testItShouldSetMembershipsUsingPubNubClientUUIDWhenUUIDIsMissing {
    NSString *expectedId = self.client.currentConfiguration.userID;
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": [NSUUID UUID].UUIDString, @"custom": @{ @"channel": [NSUUID UUID].UUIDString } }
    ];


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNSetMembershipsRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSetMembershipsRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

                XCTAssertEqualObjects(request.identifier, expectedId);
                XCTAssertEqualObjects(request.query[@"include"], @"custom");
            });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setMemberships()
            .channels(channels)
            .includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}


#pragma mark - Tests :: Remove

- (void)testItShouldReturnRemoveMembershipsBuilder {
    XCTAssertTrue([self.client.objects().removeMemberships() isKindOfClass:[PNRemoveMembershipsAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultRemoveMembershipIncludeFields {
    PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:[NSUUID UUID].UUIDString
                                                                             channels:@[]];


    XCTAssertEqual(request.includeFields, PNMembershipsTotalCountField);
}


#pragma mark - Tests :: Remove :: Call

- (void)testItShouldRemoveMembershipsWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray<NSString *> *channels = @[ [NSUUID UUID].UUIDString ];
    NSDictionary *expectedBody = @{
            @"delete": @[@{ @"channel": @{ @"id": channels[0] } }],
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    // Encoding is transport layer responsibility, so we are expecting raw string in query.
    NSString *expectedFilterExpression = filterExpression;


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNRemoveMembershipsRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNRemoveMembershipsRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];
            NSArray *includeFields = [request.query[@"include"] componentsSeparatedByString:@","];
            SEL sortSelector = @selector(caseInsensitiveCompare:);
            NSString *includeQuery = [[includeFields sortedArrayUsingSelector:sortSelector] componentsJoinedByString:@","];

            XCTAssertNil([request validate]);
            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertEqualObjects(includeQuery, @"channel.custom,custom");
            XCTAssertEqualObjects(request.query[@"filter"], expectedFilterExpression);
            XCTAssertEqualObjects(request.body, expectedPayload);
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().removeMemberships()
            .uuid(expectedId)
            .channels(channels)
            .filter(filterExpression)
            .includeFields(PNMembershipCustomField|PNMembershipChannelCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {});
    }];
}

- (void)testItShouldRemoveMembershipsUsingPubNubClientUUIDWhenUUIDIsMissing {
    NSString *expectedId = self.client.currentConfiguration.userID;
    NSArray<NSDictionary *> *channels = @[
        @{ @"channel": [NSUUID UUID].UUIDString, @"custom": @{ @"channel": [NSUUID UUID].UUIDString } }
    ];


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNSetMembershipsRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSetMembershipsRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

                XCTAssertEqualObjects(request.identifier, expectedId);
            });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().setMemberships()
            .channels(channels)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {});
    }];
}


#pragma mark - Tests :: Manage

- (void)testItShouldReturnManageBuilder {
    XCTAssertTrue([self.client.objects().manageMemberships() isKindOfClass:[PNManageMembershipsAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultManageMembershipIncludeFields {
    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:[NSUUID UUID].UUIDString];


    XCTAssertEqual(request.includeFields, PNMembershipsTotalCountField);
}


#pragma mark - Tests :: Manage :: Call

- (void)testItShouldManageMembershipsWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray<NSDictionary *> *setChannels = @[
        @{ @"channel": [NSUUID UUID].UUIDString, @"custom": @{ @"channel": [NSUUID UUID].UUIDString } }
    ];
    NSArray<NSString *> *removeChannels = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSDictionary *expectedBody = @{
        @"set": @[ @{ @"channel": @{ @"id": setChannels[0][@"channel"] }, @"custom": setChannels[0][@"custom"] }],
        @"delete": @[ @{ @"channel": @{ @"id": removeChannels[0] } },  @{ @"channel": @{ @"id": removeChannels[1] } }],
    };
    NSData *expectedPayload = [NSJSONSerialization dataWithJSONObject:expectedBody
                                                              options:(NSJSONWritingOptions)0
                                                                error:nil];
    // Encoding is transport layer responsibility, so we are expecting raw string in query.
    NSString *expectedFilterExpression = filterExpression;

    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNManageMembershipsRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNManageMembershipsRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];
            NSArray *includeFields = [request.query[@"include"] componentsSeparatedByString:@","];
            SEL sortSelector = @selector(caseInsensitiveCompare:);
            NSString *includeQuery = [[includeFields sortedArrayUsingSelector:sortSelector] componentsJoinedByString:@","];

            XCTAssertNil([request validate]);
            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertEqualObjects(includeQuery, @"channel.custom,custom");
            XCTAssertEqualObjects(request.query[@"filter"], expectedFilterExpression);
            XCTAssertEqualObjects(request.body, expectedPayload);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().manageMemberships()
            .uuid(expectedId)
            .set(setChannels)
            .remove(removeChannels)
            .filter(filterExpression)
            .includeFields(PNMembershipCustomField|PNMembershipChannelCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {});
    }];
}

- (void)testItShouldManageMembershipsUsingPubNubClientUUIDWhenUUIDIsMissing {
    NSString *expectedId = self.client.currentConfiguration.userID;
    NSArray<NSDictionary *> *setChannels = @[
            @{ @"channel": [NSUUID UUID].UUIDString, @"custom": @{ @"channel": [NSUUID UUID].UUIDString } }
    ];


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNManageMembershipsRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNManageMembershipsRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertEqualObjects(request.query[@"include"], @"custom");
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().manageMemberships()
            .set(setChannels)
            .includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {});
    }];
}

- (void)testItShouldNotManageMembershipsWhenUnsupportedDataTypeInCustom {
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSArray *setChannels = @[
        @{ @"channel": [NSUUID UUID].UUIDString, @"custom": @{ @"channel": [NSDate date] } }
    ];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().manageMemberships()
            .uuid(expectedId)
            .set(setChannels)
            .includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertTrue(status.isError);
                XCTAssertNotEqual([status.errorData.information rangeOfString:@"'custom'"].location,
                                  NSNotFound);
                XCTAssertNotEqual([status.errorData.information rangeOfString:setChannels[0][@"channel"]].location,
                                  NSNotFound);
                
                handler();
            });
    }];
}


#pragma mark - Tests :: Fetch

- (void)testItShouldReturnFetchBuilder {
    XCTAssertTrue([self.client.objects().memberships() isKindOfClass:[PNFetchMembershipsAPICallBuilder class]]);
}

- (void)testItShouldSetDefaultFetchMembershipIncludeFields {
    PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:[NSUUID UUID].UUIDString];


    XCTAssertEqual(request.includeFields, PNMembershipsTotalCountField);
}


#pragma mark - Tests :: Fetch :: Call

- (void)testItShouldFetchMembershipsWhenCalled {
    NSString *filterExpression = @"updated >= '2019-08-31T00:00:00Z'";
    // Encoding is transport layer responsibility, so we are expecting raw string in query.
    NSString *expectedFilterExpression = filterExpression;
    NSString *expectedStart = [NSUUID UUID].UUIDString;
    NSString *expectedEnd = [NSUUID UUID].UUIDString;
    NSString *expectedId = [NSUUID UUID].UUIDString;
    NSNumber *expectedLimit = @(56);
    
    
    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchMembershipsRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchMembershipsRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];
            
            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertEqualObjects(request.query[@"include"], @"custom");
            XCTAssertEqualObjects(request.query[@"start"], expectedStart);
            XCTAssertEqualObjects(request.query[@"end"], expectedEnd);
            XCTAssertEqualObjects(request.query[@"limit"], expectedLimit.stringValue);
            XCTAssertEqualObjects(request.query[@"filter"], expectedFilterExpression);
            XCTAssertNil(request.query[@"count"]);
        });
    
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().memberships()
            .uuid(expectedId)
            .start(expectedStart)
            .end(expectedEnd)
            .limit(expectedLimit.unsignedIntegerValue)
            .filter(filterExpression)
            .includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {});
    }];
}

- (void)testItShouldFetchMembershipsUsingPubNubClientUUIDMembershipsWhenUUIDIsMissing {
    NSString *expectedId = self.client.currentConfiguration.userID;


    id clientMock = [self mockForObject:self.client];
    id recorded = OCMExpect([clientMock performRequest:[OCMArg isKindOfClass:[PNFetchMembershipsRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNFetchMembershipsRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertEqualObjects(request.identifier, expectedId);
            XCTAssertEqualObjects(request.query[@"include"], @"custom");
        });

    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.objects().memberships()
            .includeFields(PNMembershipCustomField)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {});
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
