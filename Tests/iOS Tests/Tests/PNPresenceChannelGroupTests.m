//
//  PNPresenceChannelGroupTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/3/15.
//
//

#import <PubNub/PubNub.h>
#import "PNPresenceTestCase.h"
#import "NSDictionary+PNTest.h"

@interface PNPresenceChannelGroupTests : PNPresenceTestCase
@property (nonatomic, strong) XCTestExpectation *presenceExpectation;
@property (nonatomic, strong) NSString *channelGroupName;
@end

@implementation PNPresenceChannelGroupTests

- (BOOL)isRecording {
    return NO;
}

- (NSString *)otherClientChannelName {
    return @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    XCTestExpectation *setUpExpectation = [self expectationWithDescription:@"setUp"];
    self.channelGroupName = @"testGroup";
    
    [self.client addChannels:@[@"a", self.otherClientChannelName] toGroup:self.channelGroupName withCompletion:^(PNAcknowledgmentStatus *status) {
        NSLog(@"status: %@", status);
        [setUpExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"failed to set up");
        }
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
    [self.client hereNowForChannelGroup:self.channelGroupName
                         withCompletion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                             XCTAssertNil(status);
                             XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                             XCTAssertNotNil([result data]);
                             XCTAssertEqual([result statusCode], 200);
                             
                             NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                             NSDictionary *expectedChannels = @{
                                                                @"0_5098427633369088" : @{
                                                                        @"uuids" : @[
                                                                                @{
                                                                                    @"uuid" : @"JejuFan--79001"
                                                                                    }
                                                                                ],
                                                                        @"occupancy" : @1
                                                                        },
                                                                @"0_5650661106515968" : @{
                                                                        @"uuids" : @[
                                                                                @{
                                                                                    @"uuid" : @"JejuFan--79001"
                                                                                    }
                                                                                ],
                                                                        @"occupancy" : @1
                                                                        },
                                                                @"all_activity" : @{
                                                                        @"uuids" : @[
                                                                                @{
                                                                                    @"uuid" : @"JejuFan--79001"
                                                                                    }
                                                                                ],
                                                                        @"occupancy" : @1
                                                                        }
                                                                };
                             
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
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
                                 NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                                 NSDictionary *expectedChannels = @{
                                                                    @"0_5098427633369088" : @{
                                                                            @"occupancy" : @1
                                                                            },
                                                                    @"0_5650661106515968" : @{
                                                                            @"occupancy" : @1
                                                                            },
                                                                    @"all_activity" : @{
                                                                            @"occupancy" : @1
                                                                            }
                                                                    };
                                 
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
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
                                 NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                                 NSDictionary *expectedChannels = @{
                                                                    @"0_5098427633369088" : @{
                                                                            @"uuids" : @[
                                                                                    @{
                                                                                        @"uuid" : @"JejuFan--79001"
                                                                                        }
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            },
                                                                    @"0_5650661106515968" : @{
                                                                            @"uuids" : @[
                                                                                    @{
                                                                                        @"uuid" : @"JejuFan--79001"
                                                                                        }
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            },
                                                                    @"all_activity" : @{
                                                                            @"uuids" : @[
                                                                                    @{
                                                                                        @"uuid" : @"JejuFan--79001"
                                                                                        }
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            }
                                                                    };
                                 
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
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
                                 NSDictionary *expectedChannels = @{@"0_5098427633369088" : @{
                                                                            @"uuids" : @[
                                                                                    @"JejuFan--79001"
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            },
                                                                    @"0_5650661106515968" : @{
                                                                            @"uuids" : @[
                                                                                    @"JejuFan--79001"
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            },
                                                                    @"all_activity" : @{
                                                                            @"uuids" : @[
                                                                                    @"JejuFan--79001"
                                                                                    ],
                                                                            @"occupancy" : @1
                                                                            }};
                                 
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

@end
