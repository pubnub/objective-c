#import <XCTest/XCTest.h>
#import <PubNub/PNAddMessageActionRequest.h>
#import <PubNub/PNRemoveMessageActionRequest.h>
#import <PubNub/PNFetchMessageActionsRequest.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNMessageActionsRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNMessageActionsRequestTest


#pragma mark - PNAddMessageActionRequest :: Construction

- (void)testItShouldCreateAddMessageActionRequestWhenChannelAndTimetokenProvided {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"test-channel"
                                                                      messageTimetoken:@(16000000000000000)];

    XCTAssertNotNil(request);
}

- (void)testItShouldIncludeTypeAndValueInBodyWhenAddActionValidated {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(16000000000000000)];
    request.type = @"reaction";
    request.value = @"smiley";

    PNError *error = [request validate];

    XCTAssertNil(error);
    XCTAssertNotNil(request.body, @"Body should be built during validation");

    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:request.body options:0 error:nil];
    XCTAssertEqualObjects(body[@"type"], @"reaction");
    XCTAssertEqualObjects(body[@"value"], @"smiley");
}

- (void)testItShouldHaveNilTypeAndValueWhenAddActionCreated {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(16000000000000000)];

    XCTAssertNil(request.type, @"type should default to nil");
    XCTAssertNil(request.value, @"value should default to nil");
}


#pragma mark - PNAddMessageActionRequest :: Validation

- (void)testItShouldPassValidationWhenAllRequiredParamsProvided {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(16000000000000000)];
    request.type = @"reaction";
    request.value = @"smiley";

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenChannelIsEmpty {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@""
                                                                      messageTimetoken:@(16000000000000000)];
    request.type = @"reaction";
    request.value = @"smiley";

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel");
}

- (void)testItShouldFailValidationWhenMessageTimetokenIsZero {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(0)];
    request.type = @"reaction";
    request.value = @"smiley";

    XCTAssertNotNil([request validate], @"Validation should fail with zero timetoken");
}

- (void)testItShouldFailValidationWhenTypeIsMissing {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(16000000000000000)];
    request.value = @"smiley";

    XCTAssertNotNil([request validate], @"Validation should fail without type");
}

- (void)testItShouldFailValidationWhenTypeIsEmpty {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(16000000000000000)];
    request.type = @"";
    request.value = @"smiley";

    XCTAssertNotNil([request validate], @"Validation should fail with empty type");
}

- (void)testItShouldFailValidationWhenTypeExceedsMaxLength {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(16000000000000000)];
    request.type = @"this-type-is-way-too-long";
    request.value = @"smiley";

    XCTAssertNotNil([request validate], @"Validation should fail when type exceeds 15 characters");
}

- (void)testItShouldPassValidationWhenTypeIsExactlyMaxLength {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(16000000000000000)];
    request.type = @"123456789012345";
    request.value = @"value";

    XCTAssertNil([request validate], @"Validation should pass when type is exactly 15 characters");
}

- (void)testItShouldFailValidationWhenValueIsMissing {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(16000000000000000)];
    request.type = @"reaction";

    XCTAssertNotNil([request validate], @"Validation should fail without value");
}

- (void)testItShouldFailValidationWhenValueIsEmpty {
    PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"ch"
                                                                      messageTimetoken:@(16000000000000000)];
    request.type = @"reaction";
    request.value = @"";

    XCTAssertNotNil([request validate], @"Validation should fail with empty value");
}


#pragma mark - PNRemoveMessageActionRequest :: Construction

- (void)testItShouldCreateRemoveMessageActionRequestWhenAllParamsProvided {
    PNRemoveMessageActionRequest *request = [PNRemoveMessageActionRequest requestWithChannel:@"ch"
                                                                            messageTimetoken:@(16000000000000000)
                                                                             actionTimetoken:@(16000000000000001)];

    XCTAssertNotNil(request);
}


#pragma mark - PNRemoveMessageActionRequest :: Validation

- (void)testItShouldPassValidationWhenRemoveActionAllParamsProvided {
    PNRemoveMessageActionRequest *request = [PNRemoveMessageActionRequest requestWithChannel:@"ch"
                                                                            messageTimetoken:@(16000000000000000)
                                                                             actionTimetoken:@(16000000000000001)];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenRemoveActionChannelIsEmpty {
    PNRemoveMessageActionRequest *request = [PNRemoveMessageActionRequest requestWithChannel:@""
                                                                            messageTimetoken:@(16000000000000000)
                                                                             actionTimetoken:@(16000000000000001)];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel");
}

- (void)testItShouldFailValidationWhenRemoveActionMessageTimetokenIsZero {
    PNRemoveMessageActionRequest *request = [PNRemoveMessageActionRequest requestWithChannel:@"ch"
                                                                            messageTimetoken:@(0)
                                                                             actionTimetoken:@(16000000000000001)];

    XCTAssertNotNil([request validate], @"Validation should fail with zero message timetoken");
}

- (void)testItShouldFailValidationWhenRemoveActionActionTimetokenIsZero {
    PNRemoveMessageActionRequest *request = [PNRemoveMessageActionRequest requestWithChannel:@"ch"
                                                                            messageTimetoken:@(16000000000000000)
                                                                             actionTimetoken:@(0)];

    XCTAssertNotNil([request validate], @"Validation should fail with zero action timetoken");
}


#pragma mark - PNFetchMessageActionsRequest :: Construction

- (void)testItShouldCreateFetchMessageActionsRequestWhenChannelProvided {
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@"test-channel"];

    XCTAssertNotNil(request);
}

- (void)testItShouldHaveDefaultLimitWhenFetchActionsCreated {
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@"ch"];

    XCTAssertEqual(request.limit, 100, @"limit should default to 100");
}

- (void)testItShouldHaveDefaultValuesWhenFetchActionsCreated {
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@"ch"];

    XCTAssertNil(request.start, @"start should default to nil");
    XCTAssertNil(request.end, @"end should default to nil");
}


#pragma mark - PNFetchMessageActionsRequest :: Query parameters

- (void)testItShouldIncludeStartInFetchActionsQuery {
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@"ch"];
    request.start = @(16000000000000000);

    XCTAssertNotNil(request.query[@"start"]);
}

- (void)testItShouldIncludeEndInFetchActionsQuery {
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@"ch"];
    request.end = @(16100000000000000);

    XCTAssertNotNil(request.query[@"end"]);
}

- (void)testItShouldIncludeLimitInFetchActionsQuery {
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@"ch"];
    request.limit = 50;

    XCTAssertEqualObjects(request.query[@"limit"], @(50));
}


#pragma mark - PNFetchMessageActionsRequest :: Validation

- (void)testItShouldPassValidationWhenFetchActionsChannelProvided {
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@"ch"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenFetchActionsChannelIsEmpty {
    PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel");
}


#pragma mark -

@end
