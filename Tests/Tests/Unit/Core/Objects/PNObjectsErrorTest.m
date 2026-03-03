/**
 * @brief Error / negative path tests for App Context (Objects) operations.
 *
 * @author PubNub Tests
 * @copyright (c) 2010-2026 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNBaseObjectsRequest+Private.h>
#import <PubNub/PNSetChannelMetadataRequest.h>
#import <PubNub/PNRemoveChannelMetadataRequest.h>
#import <PubNub/PNFetchChannelMetadataRequest.h>
#import <PubNub/PNSetUUIDMetadataRequest.h>
#import <PubNub/PNRemoveUUIDMetadataRequest.h>
#import <PubNub/PNFetchUUIDMetadataRequest.h>
#import <PubNub/PNSetMembershipsRequest.h>
#import <PubNub/PNFetchMembershipsRequest.h>
#import <PubNub/PNSetChannelMembersRequest.h>
#import <PubNub/PNFetchChannelMembersRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNObjectsErrorTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNObjectsErrorTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Set UUID Metadata :: Missing identifier

- (void)testItShouldReturnValidationErrorWhenSetUUIDMetadataIdentifierIsNil {
    NSString *uuid = nil;
    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:uuid];
    request.name = @"Test User";

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"identifier"].location, NSNotFound);
}


#pragma mark - Tests :: Set UUID Metadata :: Identifier too long

- (void)testItShouldReturnValidationErrorWhenSetUUIDMetadataIdentifierIsTooLong {
    NSString *longId = [@[
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
    ] componentsJoinedByString:@""];

    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:longId];
    request.name = @"Test User";

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"too long"].location, NSNotFound);
}


#pragma mark - Tests :: Set UUID Metadata :: Unsupported custom data types

- (void)testItShouldReturnValidationErrorWhenSetUUIDMetadataCustomContainsUnsupportedTypes {
    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:@"test-uuid"];
    request.name = @"Test User";
    request.custom = @{ @"date": [NSDate date] };

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"custom"].location, NSNotFound);
}


#pragma mark - Tests :: Set UUID Metadata :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenSetUUIDMetadataParamsAreValid {
    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:@"test-uuid"];
    request.name = @"Test User";
    request.custom = @{ @"key": @"value" };

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Set Channel Metadata :: Missing identifier

- (void)testItShouldReturnValidationErrorWhenSetChannelMetadataChannelIsNil {
    NSString *channel = nil;
    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:channel];
    request.name = @"Test Channel";

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"identifier"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenSetChannelMetadataChannelIsEmpty {
    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:@""];
    request.name = @"Test Channel";

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark - Tests :: Set Channel Metadata :: Unsupported custom data types

- (void)testItShouldReturnValidationErrorWhenSetChannelMetadataCustomContainsUnsupportedTypes {
    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:@"test-ch"];
    request.name = @"Test Channel";
    request.custom = @{ @"date": [NSDate date] };

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"custom"].location, NSNotFound);
}


#pragma mark - Tests :: Set Channel Metadata :: Identifier too long

- (void)testItShouldReturnValidationErrorWhenSetChannelMetadataChannelIsTooLong {
    NSString *longChannel = [@[
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
        [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString,
    ] componentsJoinedByString:@""];

    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:longChannel];
    request.name = @"Test Channel";

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"too long"].location, NSNotFound);
}


#pragma mark - Tests :: Set Channel Metadata :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenSetChannelMetadataParamsAreValid {
    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:@"test-channel"];
    request.name = @"Test Channel";

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Remove UUID Metadata :: Missing identifier (using builder)

- (void)testItShouldReturnValidationErrorWhenRemoveUUIDMetadataIdentifierIsNil {
    NSString *uuid = nil;
    PNRemoveUUIDMetadataRequest *request = [PNRemoveUUIDMetadataRequest requestWithUUID:uuid];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark - Tests :: Fetch UUID Metadata :: Missing identifier

- (void)testItShouldReturnValidationErrorWhenFetchUUIDMetadataIdentifierIsNil {
    NSString *uuid = nil;
    PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:uuid];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark - Tests :: Remove Channel Metadata :: Missing channel

- (void)testItShouldReturnValidationErrorWhenRemoveChannelMetadataChannelIsEmpty {
    PNRemoveChannelMetadataRequest *request = [PNRemoveChannelMetadataRequest requestWithChannel:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark - Tests :: Fetch Channel Metadata :: Missing channel

- (void)testItShouldReturnValidationErrorWhenFetchChannelMetadataChannelIsEmpty {
    PNFetchChannelMetadataRequest *request = [PNFetchChannelMetadataRequest requestWithChannel:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark -

#pragma clang diagnostic pop

@end
