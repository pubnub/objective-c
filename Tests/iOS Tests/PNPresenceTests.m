//
//  PNPresenceTests.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 6/26/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

#import "NSDictionary+PNTest.h"

@interface PNPresenceTests : PNBasicClientTestCase

@property (nonatomic) XCTestExpectation *testExpectation;

@property (nonatomic) NSString *uniqueName;

@end

@implementation PNPresenceTests

- (void)setUp {
    [super setUp];
    
    self.uniqueName = @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
}

- (BOOL)isRecording{
    return NO;
}

#pragma mark - Simple tests without preparing steps

- (void)testHereNow {
    self.testExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowWithCompletion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
        XCTAssertNil(status);
        XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
        XCTAssertNotNil([result data]);
        XCTAssertEqual([result statusCode], 200);
        
        NSDictionary *expectedChannels = @{
                                  @"0_5098427633369088" :         @{
                                          @"occupancy" : @1,
                                          @"uuids" :             @[
                                                  @{
                                                      @"uuid" : @"JejuFan--79001"
                                                      }
                                                  ],
                                          },
                                  @"0_5650661106515968" :         @{
                                          @"occupancy" : @1,
                                          @"uuids" :             @[
                                                  @{
                                                      @"uuid" : @"JejuFan--79001"
                                                      }
                                                  ],
                                          },
                                  @"all_activity" :         @{
                                          @"occupancy" : @1,
                                          @"uuids" :             @[
                                                  @{
                                                      @"uuid" : @"JejuFan--79001"
                                                      }
                                                  ],
                                          }
                                  };
        
        XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
        
        [self.testExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowWithVerbosityNowUUID {
    self.testExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowWithVerbosity:PNHereNowUUID
                           completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
        XCTAssertNil(status);
        XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
        XCTAssertNotNil([result data]);
        XCTAssertEqual([result statusCode], 200);
                               
                               NSDictionary *expectedChannels = @{
                                                                  @"0_5098427633369088" :     @{
                                       @"occupancy" : @1,
                                       @"uuids" :   @[@"JejuFan--79001"]
                                   },
                                                                  @"0_5650661106515968" :     @{
                                       @"occupancy" : @1,
                                       @"uuids" :         @[
                                                        @"JejuFan--79001"
                                                        ]
                                   },
                                                                  @"all_activity" :     @{
                                                                          @"occupancy" : @1,
                                                                          @"uuids" :         @[
                                                        @"JejuFan--79001"
                                                        ]
                                                                          }};
                               
        XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                               
        [self.testExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowWithVerbosityNowState {
    self.testExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowWithVerbosity:PNHereNowState
                           completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
                               XCTAssertNil(status);
                               XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                               XCTAssertNotNil([result data]);
                               XCTAssertEqual([result statusCode], 200);
                               
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
                               
                               NSLog(@"%@", [result.data.channels codeFormatDescription]);
                               
                               XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                               
                               [self.testExpectation fulfill];
                           }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowWithVerbosityNowOccupancy {
    self.testExpectation = [self expectationWithDescription:@"network"];
    [self.client hereNowWithVerbosity:PNHereNowOccupancy
                           completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
                               XCTAssertNil(status);
                               XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                               XCTAssertNotNil([result data]);
                               XCTAssertEqual([result statusCode], 200);
                               
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
                               
                               [self.testExpectation fulfill];
                           }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannel {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelName = self.uniqueName;
    [self.client hereNowForChannel:channelName
                    withCompletion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                               XCTAssertNil(status);
                               XCTAssertEqual([result operation], PNHereNowForChannelOperation, @"Wrong operation");
                               XCTAssertNotNil([result data]);
                               XCTAssertEqual([result statusCode], 200);
                        
                                XCTAssertEqualObjects(result.data.occupancy, @0, @"Result and expected channels are not equal.");
                                XCTAssertEqualObjects(result.data.uuids, @[], @"Result and expected channels are not equal.");
                        
                               [self.testExpectation fulfill];
                           }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForNilChannel {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelName = nil;
    [self.client hereNowForChannel:channelName
                    withCompletion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                        XCTAssertNil(status);
                        XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                        XCTAssertNotNil([result data]);
                        XCTAssertEqual([result statusCode], 200);
                        
                        PNPresenceGlobalHereNowResult *globalResult = (PNPresenceGlobalHereNowResult *)result;
                        
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
                        
                        NSLog(@"%@", [globalResult.data.channels codeFormatDescription]);
                        
                        XCTAssertEqualObjects(globalResult.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                        [self.testExpectation fulfill];
                    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelWithVerbosityOccupancy {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelName = self.uniqueName;
    [self.client hereNowForChannel:channelName
                     withVerbosity:PNHereNowOccupancy
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowForChannelOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);
                            
                            XCTAssertEqualObjects(result.data.uuids, nil, @"Result and expected channels are not equal.");
                            XCTAssertEqualObjects(result.data.occupancy, @0, @"Result and expected channels are not equal.");
                            
                            
                            [self.testExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForNilChannelWithVerbosityOccupancy {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelName = nil;
    [self.client hereNowForChannel:channelName
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
                            
                            NSLog(@"%@", [globalResult.data.channels codeFormatDescription]);
                            
                            XCTAssertEqualObjects(globalResult.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                            
                            [self.testExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelWithVerbosityState {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelName = self.uniqueName;
    [self.client hereNowForChannel:channelName
                     withVerbosity:PNHereNowState
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowForChannelOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);
                            
                            XCTAssertEqualObjects(result.data.uuids, @[], @"Result and expected channels are not equal.");
                            XCTAssertEqualObjects(result.data.occupancy, @0, @"Result and expected channels are not equal.");
                            
                            [self.testExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForNilChannelWithVerbosityState {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelName = nil;
    [self.client hereNowForChannel:channelName
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
                            
                            NSLog(@"%@", [globalResult.data.channels codeFormatDescription]);
                            
                            XCTAssertEqualObjects(globalResult.data.channels, expectedChannels, @"Result and expected channels are not equal.");

                            
                            [self.testExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelWithVerbosityUUID {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelName = self.uniqueName;
    [self.client hereNowForChannel:channelName
                     withVerbosity:PNHereNowUUID
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowForChannelOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);
                            
                            XCTAssertEqualObjects(result.data.uuids, @[], @"Result and expected channels are not equal.");
                            XCTAssertEqualObjects(result.data.occupancy, @0, @"Result and expected channels are not equal.");
                            
                            [self.testExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForNilChannelWithVerbosityUUID {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelName = nil;
    [self.client hereNowForChannel:channelName
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
                            
                            NSLog(@"%@", [globalResult.data.channels codeFormatDescription]);
                            
                            XCTAssertEqualObjects(globalResult.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                            
                            [self.testExpectation fulfill];
                        }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelGroup {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelGroupName = self.uniqueName;
    [self.client hereNowForChannelGroup:channelGroupName
                         withCompletion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNil(status);
                            XCTAssertEqual([result operation], PNHereNowForChannelGroupOperation, @"Wrong operation");
                            XCTAssertNotNil([result data]);
                            XCTAssertEqual([result statusCode], 200);
                             
                             NSDictionary *expectedChannels = @{};
                             NSLog(@"%@", [result.data.channels codeFormatDescription]);
                             
                            XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                             
                            [self.testExpectation fulfill];
                        }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForNilChannelGroup {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelGroupName = nil;
    [self.client hereNowForChannelGroup:channelGroupName
                         withCompletion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                             XCTAssertNil(status);
                             XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                             XCTAssertNotNil([result data]);
                             XCTAssertEqual([result statusCode], 200);
                             
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
                             NSLog(@"%@", [result.data.channels codeFormatDescription]);
                             
                             XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                             
                             [self.testExpectation fulfill];
                         }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelGroupWithVerbosityOccupancy {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelGroupName = self.uniqueName;
    [self.client hereNowForChannelGroup:channelGroupName
                          withVerbosity:PNHereNowOccupancy
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowForChannelGroupOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
                                 NSDictionary *expectedChannels = @{};
                                 NSLog(@"%@", [result.data.channels codeFormatDescription]);
                                 
                                 XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");

                                 
                                 [self.testExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForNilChannelGroupWithVerbosityOccupancy {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelGroupName = nil;
    [self.client hereNowForChannelGroup:channelGroupName
                          withVerbosity:PNHereNowOccupancy
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
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
                                 NSLog(@"%@", [result.data.channels codeFormatDescription]);
                                 
                                 XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                                 
                                 [self.testExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelGroupWithVerbosityState {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelGroupName = self.uniqueName;
    [self.client hereNowForChannelGroup:channelGroupName
                          withVerbosity:PNHereNowState
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowForChannelGroupOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
                                 NSDictionary *expectedChannels = @{};
                                 NSLog(@"%@", [result.data.channels codeFormatDescription]);
                                 
                                 XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                                 
                                 [self.testExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForNilChannelGroupWithVerbosityState {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelGroupName = nil;
    [self.client hereNowForChannelGroup:channelGroupName
                          withVerbosity:PNHereNowState
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowGlobalOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
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
                                 NSLog(@"%@", [result.data.channels codeFormatDescription]);
                                 
                                 XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                                 
                                 [self.testExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForChannelGroupWithVerbosityUUID {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelGroupName = self.uniqueName;
    [self.client hereNowForChannelGroup:channelGroupName
                          withVerbosity:PNHereNowUUID
                             completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
                                 XCTAssertNil(status);
                                 XCTAssertEqual([result operation], PNHereNowForChannelGroupOperation, @"Wrong operation");
                                 XCTAssertNotNil([result data]);
                                 XCTAssertEqual([result statusCode], 200);
                                 
                                 NSDictionary *expectedChannels = @{};
                                 NSLog(@"%@", [result.data.channels codeFormatDescription]);
                                 
                                 XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                                 
                                 [self.testExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testHereNowForNilChannelGroupWithVerbosityUUID {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *channelGroupName = nil;
    [self.client hereNowForChannelGroup:channelGroupName
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
                                 NSLog(@"%@", [result.data.channels codeFormatDescription]);
                                 
                                 XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                                 
                                 [self.testExpectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testWhereNowUDID {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    [self.client whereNowUUID:uuid
               withCompletion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
                 XCTAssertNil(status);
                 XCTAssertEqual([result operation], PNWhereNowOperation, @"Wrong operation");
                 XCTAssertNotNil([result data]);
                 XCTAssertEqual([result statusCode], 200);
                   
                   NSArray *expectedChannels = @[];
                   NSLog(@"%@", result.data.channels);
                   
                   XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
                   
                 [self.testExpectation fulfill];
             }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testWhereNowNilUDID {
    self.testExpectation = [self expectationWithDescription:@"network"];
    NSString *uuid = nil;
    [self.client whereNowUUID:uuid
               withCompletion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
                   XCTAssertNotNil(status);
                   XCTAssertNil(result, @"Result is not nil");
                   XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                   XCTAssertEqual([status statusCode], 400);

                   [self.testExpectation fulfill];
               }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

@end
