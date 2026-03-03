/**
 * @brief Error / negative path tests for Channel Groups operations.
 *
 * @author PubNub Tests
 * @copyright (c) 2010-2026 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNChannelGroupManageRequest.h>
#import <PubNub/PNChannelGroupFetchRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNChannelGroupErrorTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNChannelGroupErrorTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Add Channels :: Missing group name

- (void)testItShouldReturnValidationErrorWhenAddChannelsToGroupWithEmptyGroupName {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:@[@"ch-a"]
                                                                              toChannelGroup:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenAddChannelsToGroupWithNilGroupName {
    NSString *channelGroup = nil;
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:@[@"ch-a"]
                                                                              toChannelGroup:channelGroup];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}


#pragma mark - Tests :: Add Channels :: Nil channels array

- (void)testItShouldNotReturnValidationErrorWhenAddChannelsWithNilChannelsArray {
    // SDK treats nil channels as "remove group" operation; group name is provided so it should pass.
    NSArray *channels = nil;
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:channels
                                                                              toChannelGroup:@"test-group"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Add Channels :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenAddChannelsParamsAreValid {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:@[@"ch-a", @"ch-b"]
                                                                              toChannelGroup:@"test-group"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Remove Channels :: Missing group name

- (void)testItShouldReturnValidationErrorWhenRemoveChannelsFromGroupWithEmptyGroupName {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannels:@[@"ch-a"]
                                                                               fromChannelGroup:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenRemoveChannelsFromGroupWithNilGroupName {
    NSString *channelGroup = nil;
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannels:@[@"ch-a"]
                                                                               fromChannelGroup:channelGroup];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}


#pragma mark - Tests :: Remove Channel Group :: Missing group name

- (void)testItShouldReturnValidationErrorWhenRemoveChannelGroupWithEmptyGroupName {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannelGroup:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenRemoveChannelGroupWithNilGroupName {
    NSString *channelGroup = nil;
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannelGroup:channelGroup];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}


#pragma mark - Tests :: Remove Channel Group :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenRemoveChannelGroupIsValid {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannelGroup:@"test-group"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Fetch Channels :: Missing group name

- (void)testItShouldReturnValidationErrorWhenFetchChannelsForGroupWithEmptyGroupName {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenFetchChannelsForGroupWithNilGroupName {
    NSString *channelGroup = nil;
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:channelGroup];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}


#pragma mark - Tests :: Fetch Channels :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenFetchChannelsForGroupIsValid {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:@"test-group"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Fetch Channel Groups :: No group required

- (void)testItShouldNotReturnValidationErrorWhenFetchAllChannelGroups {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestChannelGroups];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark -

#pragma clang diagnostic pop

@end
