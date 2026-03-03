/**
 * @brief Error / negative path tests for Subscribe operations.
 *
 * @author PubNub Tests
 * @copyright (c) 2010-2026 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNSubscribeRequest.h>
#import "PNRecordableTestCase.h"
#import "PNBaseRequest+Private.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNSubscribeErrorTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNSubscribeErrorTest


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Subscribe :: Empty channels and nil channel groups

- (void)testItShouldReturnValidationErrorWhenSubscribeWithEmptyChannelsAndNilGroups {
    NSArray *channelGroups = nil;
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[] channelGroups:channelGroups];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenSubscribeWithNilChannelsAndEmptyGroups {
    NSArray *channels = nil;
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:channels channelGroups:@[]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenSubscribeWithNilChannelsAndNilGroups {
    NSArray *channels = nil;
    NSArray *channelGroups = nil;
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:channels channelGroups:channelGroups];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}


#pragma mark - Tests :: Subscribe :: Valid with at least one channel

- (void)testItShouldNotReturnValidationErrorWhenSubscribeWithOneChannel {
    NSArray *channelGroups = nil;
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"channel-a"] channelGroups:channelGroups];

    PNError *error = [request validate];

    XCTAssertNil(error);
}

- (void)testItShouldNotReturnValidationErrorWhenSubscribeWithOneChannelGroup {
    NSArray *channels = nil;
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:channels channelGroups:@[@"group-a"]];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Presence Subscribe :: Empty channels and groups

- (void)testItShouldReturnValidationErrorWhenPresenceSubscribeWithEmptyChannelsAndGroups {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithPresenceChannels:@[] channelGroups:@[]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenPresenceSubscribeWithNilChannelsAndNilGroups {
    NSArray *channels = nil;
    NSArray *channelGroups = nil;
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithPresenceChannels:channels channelGroups:channelGroups];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark -

@end
