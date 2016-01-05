//
//  PNPresenceChannelGroupTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/3/15.
//
//

#import <PubNub/PubNub.h>
#import "PNBasicPresenceTestCase.h"
#import "NSDictionary+PNTest.h"

@interface PNPresenceChannelGroupTests : PNBasicPresenceTestCase
@property (nonatomic, strong) XCTestExpectation *presenceExpectation;
@end

@implementation PNPresenceChannelGroupTests

- (BOOL)isRecording {
    return NO;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    PNWeakify(self);
    [self setUpChannelSubscription];
    [self performVerifiedAddChannels:@[@"a", self.otherClientChannelName] toGroup:[self channelGroupName] withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHereNowForChannelGroup {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannelGroup:self.channelGroupName
                         withCompletion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                             XCTAssertNil(status);
                             XCTAssertEqual([result operation], PNHereNowForChannelGroupOperation, @"Wrong operation");
                             XCTAssertNotNil([result data]);
                             XCTAssertEqual([result statusCode], 200);
                             
                             NSDictionary *expectedChannels = @{
                                                                @"a" : @{
                                                                        @"uuids" : @[
                                                                                @{
                                                                                    @"uuid" : @"d063790a-5fac-4c7b-9038-b511b61eb23d"
                                                                                    }
                                                                                ],
                                                                        @"occupancy" : @1
                                                                        },
                                                                @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA" : @{
                                                                        @"uuids" : @[
                                                                                @{
                                                                                    @"uuid" : @"d063790a-5fac-4c7b-9038-b511b61eb23d"
                                                                                    }
                                                                                ],
                                                                        @"occupancy" : @1
                                                                        }
                                                                };
                             
                             NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                             XCTAssertEqualObjects(result.data.totalChannels, @2);
                             XCTAssertEqualObjects(result.data.totalOccupancy, @2);
                             XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                             
                             [self.presenceExpectation fulfill];
                         }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#warning fix test, server or sdk
- (void)testHereNowForNilChannelGroup {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannelGroup:nil
                         withCompletion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                             XCTAssertNotNil(status);
                             XCTAssertNil(result, @"Result is not nil");
                             XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                             XCTAssertEqual([status statusCode], 400);
                             XCTAssertTrue(status.isError);
                             [self.presenceExpectation fulfill];
                         }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelGroupWithVerbosityOccupancy {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannelGroup:self.channelGroupName
                          withVerbosity:PNHereNowOccupancy
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowForChannelGroupOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
                                 NSDictionary *expectedChannels = @{
                                                                    @"a" : @{
                                                                            @"occupancy" : @1
                                                                            },
                                                                    @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA" : @{
                                                                            @"occupancy" : @1
                                                                            }
                                                                    };
                                 
                                 NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                                 XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                                 XCTAssertEqualObjects(result.data.totalOccupancy, @2);
                                 XCTAssertEqualObjects(result.data.totalChannels, @2);
                                 
                                 
                                 [self.presenceExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#warning fix test, server or sdk
- (void)testHereNowForNilChannelGroupWithVerbosityOccupancy {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannelGroup:nil
                          withVerbosity:PNHereNowOccupancy
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNotNil(status);
                                 XCTAssertNil(result, @"Result is not nil");
                                 XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                                 XCTAssertEqual([status statusCode], 400);
                                 XCTAssertTrue(status.isError);
                                 
                                 [self.presenceExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelGroupWithVerbosityState {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannelGroup:self.channelGroupName
                          withVerbosity:PNHereNowState
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowForChannelGroupOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
                                 NSDictionary *expectedChannels = @{
                                                                    @"a" : @{
                                                                            @"uuids" : @[
                                                                                    @{
                                                                                        @"uuid" : @"d063790a-5fac-4c7b-9038-b511b61eb23d"
                                                                                        }
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            },
                                                                    @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA" : @{
                                                                            @"uuids" : @[
                                                                                    @{
                                                                                        @"uuid" : @"d063790a-5fac-4c7b-9038-b511b61eb23d"
                                                                                        }
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            }
                                                                    };
                                 
                                 NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                                 XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                                 XCTAssertEqualObjects(result.data.totalChannels, @2);
                                 XCTAssertEqualObjects(result.data.totalOccupancy, @2);
                                 
                                 [self.presenceExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#warning fix test, server or sdk
- (void)testHereNowForNilChannelGroupWithVerbosityState {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannelGroup:nil
                          withVerbosity:PNHereNowState
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNotNil(status);
                                 XCTAssertNil(result, @"Result is not nil");
                                 XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                                 XCTAssertEqual([status statusCode], 400);
                                 XCTAssertTrue(status.isError);
                                 
                                 [self.presenceExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelGroupWithVerbosityUUID {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannelGroup:self.channelGroupName
                          withVerbosity:PNHereNowUUID
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowForChannelGroupOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
                                 NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                                 NSDictionary *expectedChannels = @{
                                                                    @"a" : @{
                                                                            @"uuids" : @[
                                                                                    @"d063790a-5fac-4c7b-9038-b511b61eb23d"
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            },
                                                                    @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA" : @{
                                                                            @"uuids" : @[
                                                                                    @"d063790a-5fac-4c7b-9038-b511b61eb23d"
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            }
                                                                    };
                                 
                                 XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                                 XCTAssertEqualObjects(result.data.totalOccupancy, @2);
                                 XCTAssertEqualObjects(result.data.totalChannels, @2);
                                 
                                 [self.presenceExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#warning fix test, server or sdk
- (void)testHereNowForNilChannelGroupWithVerbosityUUID {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannelGroup:nil
                          withVerbosity:PNHereNowUUID
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNotNil(status);
                                 XCTAssertNil(result, @"Result is not nil");
                                 XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                                 XCTAssertEqual([status statusCode], 400);
                                 XCTAssertTrue(status.isError);
                                 [self.presenceExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

@end
