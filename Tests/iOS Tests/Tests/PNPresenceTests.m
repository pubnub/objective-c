//
//  PNPresenceTests.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 6/26/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

#import "NSDictionary+PNTest.h"

@interface PNPresenceTests : PNBasicClientTestCase <PNObjectEventListener>

@property (nonatomic) XCTestExpectation *presenceExpectation;
@property (nonatomic) XCTestExpectation *setUpExpectation;

@property (nonatomic) NSString *channelName;
@property (nonatomic, strong) PubNub *otherClient;

@end

@implementation PNPresenceTests

- (void)setUp {
    [super setUp];
    self.channelName = @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
    self.setUpExpectation = [self expectationWithDescription:@"setUp"];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    config.uuid = @"d063790a-5fac-4c7b-9038-b511b61eb23d";
    self.otherClient = [PubNub clientWithConfiguration:config];
    [self.otherClient addListener:self];
    [self.otherClient subscribeToChannels:@[self.channelName] withPresence:YES clientState:@{@"foo" : @"bar"}];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTFail(@"failed to set up");
    }];
    
    
}

- (BOOL)isRecording{
    return YES;
}

#pragma mark - Simple tests without preparing steps

- (void)testHereNow {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowWithCompletion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
        XCTAssertNil(status);
        XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
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
                                                   },
                                           @"futureChannel" : @{
                                                   @"uuids" : @[
                                                           @{
                                                               @"uuid" : @"b47f8377-9aa8-4bac-92e5-6abd096982f3"
                                                               }
                                                           ],
                                                   @"occupancy" : @1
                                                   }
                                  };
        
        NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
        XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
        XCTAssertEqualObjects(result.data.totalChannels, @3);
        XCTAssertEqualObjects(result.data.totalOccupancy, @3);
        
        [self.presenceExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowWithVerbosityNowUUID {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowWithVerbosity:PNHereNowUUID
                           completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
                               XCTAssertNil(status);
                               XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                               XCTAssertNotNil([result data]);
                               XCTAssertEqual([result statusCode], 200);
                               
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
                                                                          },
                                                                  @"futureChannel" : @{
                                                                          @"uuids" : @[
                                                                                  @"b47f8377-9aa8-4bac-92e5-6abd096982f3"
                                                                                  ],
                                                                          @"occupancy" : @1
                                                                          }
                                                                  };
                               NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                               XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                               XCTAssertEqualObjects(result.data.totalChannels, @3);
                               XCTAssertEqualObjects(result.data.totalOccupancy, @3);
                               
                               [self.presenceExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowWithVerbosityNowState {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowWithVerbosity:PNHereNowState
                           completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
                               XCTAssertNil(status);
                               XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
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
                                                                          },
                                                                  @"futureChannel" : @{
                                                                          @"uuids" : @[
                                                                                  @{
                                                                                      @"uuid" : @"b47f8377-9aa8-4bac-92e5-6abd096982f3"
                                                                                      }
                                                                                  ],
                                                                          @"occupancy" : @1
                                                                          }
                                                                  };
                               
                               NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                               
                               XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                               XCTAssertEqualObjects(result.data.totalOccupancy, @3);
                               XCTAssertEqualObjects(result.data.totalChannels, @3);
                               
                               [self.presenceExpectation fulfill];
                           }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowWithVerbosityNowOccupancy {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowWithVerbosity:PNHereNowOccupancy
                           completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
                               XCTAssertNil(status);
                               XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                               XCTAssertNotNil([result data]);
                               XCTAssertEqual([result statusCode], 200);
                               
                               NSDictionary *expectedChannels = @{
                                                                  @"a" : @{
                                                                          @"occupancy" : @1
                                                                          },
                                                                  @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA" : @{
                                                                          @"occupancy" : @1
                                                                          },
                                                                  @"futureChannel" : @{
                                                                          @"occupancy" : @1
                                                                          }
                                                                  };
                               
                               NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
                               XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                               XCTAssertEqualObjects(result.data.totalChannels, @3);
                               XCTAssertEqualObjects(result.data.totalOccupancy, @3);
                               
                               [self.presenceExpectation fulfill];
                           }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannel {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannel:self.channelName
                    withCompletion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                        XCTAssertNil(status);
                        XCTAssertEqual([result operation], PNHereNowForChannelOperation, @"Wrong operation");
                        XCTAssertNotNil([result data]);
                        XCTAssertEqual([result statusCode], 200);
                        
                        XCTAssertEqualObjects(result.data.occupancy, @1, @"Result and expected channels are not equal.");
                        
                        NSArray *expectedUUIDs = @[
                                                   @{
                                                       @"uuid" : @"d063790a-5fac-4c7b-9038-b511b61eb23d"
                                                       }
                                                   ];
                        
                        XCTAssertEqualObjects(result.data.uuids, expectedUUIDs, @"Result and expected channels are not equal.");
                        
                        [self.presenceExpectation fulfill];
                    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#warning Fix test, SDK, or server
- (void)testHereNowForNilChannel {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannel:nil
                    withCompletion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                        XCTAssertNil(status);
                        XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                        XCTAssertNotNil([result data]);
                        XCTAssertEqual([result statusCode], 200);
                        
                        PNPresenceGlobalHereNowResult *globalResult = (PNPresenceGlobalHereNowResult *)result;
                        
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
                                                                   },
                                                           @"futureChannel" : @{
                                                                   @"uuids" : @[
                                                                           @{
                                                                               @"uuid" : @"b47f8377-9aa8-4bac-92e5-6abd096982f3"
                                                                               }
                                                                           ],
                                                                   @"occupancy" : @1
                                                                   }
                                                           };
                        
                        NSLog(@"expected: %@", globalResult.data.channels.testAssertionFormat);
                        XCTAssertEqualObjects(globalResult.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                        XCTAssertEqualObjects(globalResult.data.totalOccupancy, @3);
                        XCTAssertEqualObjects(globalResult.data.totalChannels, @3);
                        [self.presenceExpectation fulfill];
                    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelWithVerbosityOccupancy {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannel:self.channelName
                     withVerbosity:PNHereNowOccupancy
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowForChannelOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);

                            XCTAssertNil(result.data.uuids);
                            XCTAssertEqualObjects(result.data.occupancy, @1, @"Result and expected channels are not equal.");
                            
                            
                            [self.presenceExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#warning fix test, sdk or server
- (void)testHereNowForNilChannelWithVerbosityOccupancy {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannel:nil
                     withVerbosity:PNHereNowOccupancy
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);
                            
                            PNPresenceGlobalHereNowResult *globalResult = (PNPresenceGlobalHereNowResult *)result;
                            
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
                            
                            
                            XCTAssertEqualObjects(globalResult.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                            
                            [self.presenceExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelWithVerbosityState {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannel:self.channelName
                     withVerbosity:PNHereNowState
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowForChannelOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);
                            
                            NSLog(@"actual: %@", result.data.uuids);
                            NSArray *expected = @[
                                                  @{
                                                      @"uuid" : @"d063790a-5fac-4c7b-9038-b511b61eb23d"
                                                      }
                                                  ];
                            XCTAssertEqualObjects(result.data.uuids, expected, @"Result and expected channels are not equal.");
                            XCTAssertEqualObjects(result.data.occupancy, @1, @"Result and expected channels are not equal.");
                            
                            [self.presenceExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#warning fix test, sdk, or server
- (void)testHereNowForNilChannelWithVerbosityState {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannel:nil
                     withVerbosity:PNHereNowState
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);
                            
                            PNPresenceGlobalHereNowResult *globalResult = (PNPresenceGlobalHereNowResult *)result;
                            
                            NSDictionary *expectedChannels = @{@"0_5098427633369088" : @{
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
                                                }};
                            
                            XCTAssertEqualObjects(globalResult.data.channels, expectedChannels, @"Result and expected channels are not equal.");

                            
                            [self.presenceExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelWithVerbosityUUID {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannel:self.channelName
                     withVerbosity:PNHereNowUUID
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowForChannelOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);
                            
                            XCTAssertEqualObjects(result.data.uuids, @[], @"Result and expected channels are not equal.");
                            XCTAssertEqualObjects(result.data.occupancy, @0, @"Result and expected channels are not equal.");
                            
                            [self.presenceExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForNilChannelWithVerbosityUUID {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowForChannel:nil
                     withVerbosity:PNHereNowUUID
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);
                            
                            PNPresenceGlobalHereNowResult *globalResult = (PNPresenceGlobalHereNowResult *)result;
                            
                            NSDictionary *expectedChannels = @{
                                                               @"0_5098427633369088" : @{
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
                                                                       }
                                                               };
                            
                            
                            XCTAssertEqualObjects(globalResult.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                            
                            [self.presenceExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testWhereNowUUID {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    NSString *uuid = @"d063790a-5fac-4c7b-9038-b511b61eb23d";
    [self.client whereNowUUID:uuid
               withCompletion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
                 XCTAssertNil(status);
                 XCTAssertEqual([result operation], PNWhereNowOperation, @"Wrong operation");
                 XCTAssertNotNil([result data]);
                 XCTAssertEqual([result statusCode], 200);
                   
                   NSArray *expectedChannels = @[];
                   NSLog(@"%@", result.data.channels);
                   
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

- (void)testWhereNowNilUDID {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    [self.client whereNowUUID:nil
               withCompletion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
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

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    NSLog(@"status: %@", status.debugDescription);
    [self.setUpExpectation fulfill];
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    NSLog(@"event: %@", event.debugDescription);
}

@end
