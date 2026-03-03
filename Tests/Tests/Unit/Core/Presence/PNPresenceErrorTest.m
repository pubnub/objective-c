/**
 * @brief Error / negative path tests for Presence operations (HereNow, WhereNow, State, Heartbeat).
 *
 * @author PubNub Tests
 * @copyright (c) 2010-2026 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNPresenceHeartbeatRequest.h>
#import <PubNub/PNPresenceStateSetRequest.h>
#import <PubNub/PNPresenceStateFetchRequest.h>
#import <PubNub/PNWhereNowRequest.h>
#import <PubNub/PNHereNowRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNPresenceErrorTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNPresenceErrorTest


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: HereNow :: Missing channels (channel-specific request)

- (void)testItShouldReturnValidationErrorWhenHereNowForChannelsIsEmpty {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenHereNowForChannelsIsNil {
    NSArray *channels = nil;
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:channels];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}


#pragma mark - Tests :: HereNow :: Missing channel groups (channel-group request)

- (void)testItShouldReturnValidationErrorWhenHereNowForChannelGroupsIsEmpty {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannelGroups:@[]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenHereNowForChannelGroupsIsNil {
    NSArray *channelGroups = nil;
    PNHereNowRequest *request = [PNHereNowRequest requestForChannelGroups:channelGroups];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channelGroup"].location, NSNotFound);
}


#pragma mark - Tests :: HereNow :: Global request should pass

- (void)testItShouldNotReturnValidationErrorForGlobalHereNow {
    PNHereNowRequest *request = [PNHereNowRequest requestGlobal];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: HereNow :: Valid channel request

- (void)testItShouldNotReturnValidationErrorWhenHereNowChannelsAreValid {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"test-channel"]];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: WhereNow :: Missing userId

- (void)testItShouldReturnValidationErrorWhenWhereNowUserIdIsEmpty {
    PNWhereNowRequest *request = [PNWhereNowRequest requestForUserId:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"userId"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenWhereNowUserIdIsNil {
    NSString *userId = nil;
    PNWhereNowRequest *request = [PNWhereNowRequest requestForUserId:userId];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"userId"].location, NSNotFound);
}


#pragma mark - Tests :: WhereNow :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenWhereNowUserIdIsValid {
    PNWhereNowRequest *request = [PNWhereNowRequest requestForUserId:@"user-123"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Set State :: Missing userId

- (void)testItShouldReturnValidationErrorWhenSetStateUserIdIsEmpty {
    PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:@""];
    request.channels = @[@"test-channel"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"userId"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenSetStateUserIdIsNil {
    NSString *userId = nil;
    PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:userId];
    request.channels = @[@"test-channel"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"userId"].location, NSNotFound);
}


#pragma mark - Tests :: Set State :: Missing channels

- (void)testItShouldReturnValidationErrorWhenSetStateChannelsAndGroupsAreEmpty {
    PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:@"user-123"];
    // No channels or groups set

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}


#pragma mark - Tests :: Set State :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenSetStateParamsAreValid {
    PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:@"user-123"];
    request.channels = @[@"test-channel"];
    request.state = @{ @"mood": @"happy" };

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Fetch State :: Missing userId

- (void)testItShouldReturnValidationErrorWhenFetchStateUserIdIsEmpty {
    PNPresenceStateFetchRequest *request = [PNPresenceStateFetchRequest requestWithUserId:@""];
    request.channels = @[@"test-channel"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"userId"].location, NSNotFound);
}


#pragma mark - Tests :: Fetch State :: Missing channels

- (void)testItShouldReturnValidationErrorWhenFetchStateChannelsAndGroupsAreEmpty {
    PNPresenceStateFetchRequest *request = [PNPresenceStateFetchRequest requestWithUserId:@"user-123"];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}


#pragma mark - Tests :: Heartbeat :: Missing channels

- (void)testItShouldReturnValidationErrorWhenHeartbeatChannelsAndGroupsAreEmpty {
    PNPresenceHeartbeatRequest *request = [PNPresenceHeartbeatRequest requestWithHeartbeat:300
                                                                                  channels:@[]
                                                                             channelGroups:@[]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenHeartbeatChannelsAndGroupsAreNil {
    NSArray *channels = nil;
    NSArray *channelGroups = nil;
    PNPresenceHeartbeatRequest *request = [PNPresenceHeartbeatRequest requestWithHeartbeat:300
                                                                                  channels:channels
                                                                             channelGroups:channelGroups];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}


#pragma mark - Tests :: Heartbeat :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenHeartbeatChannelsAreValid {
    NSArray *channelGroups = nil;
    PNPresenceHeartbeatRequest *request = [PNPresenceHeartbeatRequest requestWithHeartbeat:300
                                                                                  channels:@[@"ch-a"]
                                                                             channelGroups:channelGroups];

    PNError *error = [request validate];

    XCTAssertNil(error);
}

- (void)testItShouldNotReturnValidationErrorWhenHeartbeatChannelGroupsAreValid {
    NSArray *channels = nil;
    PNPresenceHeartbeatRequest *request = [PNPresenceHeartbeatRequest requestWithHeartbeat:300
                                                                                  channels:channels
                                                                             channelGroups:@[@"group-a"]];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark -

@end
