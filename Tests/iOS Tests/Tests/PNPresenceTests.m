//
//  PNPresenceTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 11/20/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicPresenceTestCase.h"

#import "NSDictionary+PNTest.h"

@interface PNPresenceTests : PNBasicPresenceTestCase

@property (nonatomic) XCTestExpectation *presenceExpectation;
@property (nonatomic, strong) NSString *channelName;
@end

@implementation PNPresenceTests

- (void)setUp {
    [super setUp];
    self.channelName = [self otherClientChannelName];
}

- (BOOL)isRecording{
    return NO;
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
                                                   }
                                           };
        
        NSLog(@"expected: %@", result.data.channels.testAssertionFormat);
        XCTAssertEqualObjects(result.data.channels, expectedChannels, @"Result and expected channels are not equal.");
        XCTAssertEqualObjects(result.data.totalChannels, @1);
        XCTAssertEqualObjects(result.data.totalOccupancy, @1);
        
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

- (void)testHereNowForNilChannel {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    [self.client hereNowForChannel:nil
                    withCompletion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                        XCTAssertNotNil(status);
                        XCTAssertNil(result, @"Result is not nil");
                        XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                        XCTAssertEqual([status statusCode], 400);
                        XCTAssertTrue(status.isError);
                        [self.presenceExpectation fulfill];
                    }];
    #pragma clang diagnostic pop
    
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

- (void)testHereNowForNilChannelWithVerbosityOccupancy {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    [self.client hereNowForChannel:nil
                     withVerbosity:PNHereNowOccupancy
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNotNil(status);
                            XCTAssertNil(result, @"Result is not nil");
                            XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                            XCTAssertEqual([status statusCode], 400);
                            XCTAssertTrue(status.isError);
                            [self.presenceExpectation fulfill];
                        }];
    #pragma clang diagnostic pop
    
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

- (void)testHereNowForNilChannelWithVerbosityState {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    [self.client hereNowForChannel:nil
                     withVerbosity:PNHereNowState
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNotNil(status);
                            XCTAssertNil(result, @"Result is not nil");
                            XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                            XCTAssertEqual([status statusCode], 400);
                            XCTAssertTrue(status.isError);
                            
                            [self.presenceExpectation fulfill];
                        }];
    #pragma clang diagnostic pop
    
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
                            
                            XCTAssertEqualObjects(result.data.uuids, @[@"d063790a-5fac-4c7b-9038-b511b61eb23d"], @"Result and expected channels are not equal.");
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

- (void)testHereNowForNilChannelWithVerbosityUUID {
    self.presenceExpectation = [self expectationWithDescription:@"network"];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    [self.client hereNowForChannel:nil
                     withVerbosity:PNHereNowUUID
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            XCTAssertNotNil(status);
                            XCTAssertNil(result, @"Result is not nil");
                            XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                            XCTAssertEqual([status statusCode], 400);
                            XCTAssertTrue(status.isError);
                            [self.presenceExpectation fulfill];
                        }];
    #pragma clang diagnostic pop
    
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
                   
                   NSArray *expectedChannels = @[@"a", @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA"];
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
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    [self.client whereNowUUID:nil
               withCompletion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
                   XCTAssertNotNil(status);
                   XCTAssertNil(result, @"Result is not nil");
                   XCTAssertEqual([status category], PNBadRequestCategory, @"Should be wrong in current logic");
                   XCTAssertEqual([status statusCode], 400);
                   XCTAssertTrue(status.isError);
                   
                   [self.presenceExpectation fulfill];
               }];
    #pragma clang diagnostic pop
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

@end