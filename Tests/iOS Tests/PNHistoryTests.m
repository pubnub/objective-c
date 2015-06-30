//
//  PNHistoryTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/23/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

@interface PNHistoryTests : PNBasicClientTestCase
@end

@implementation PNHistoryTests

- (BOOL)isRecording {
    // TODO: find out why this fails when replaying
    return NO;
}

- (void)testHistory {
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    [self.client historyForChannel:@"a" start:@14356962344283504 end:@14356962619609342 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.start, @14356962364490888);
        XCTAssertEqualObjects(result.data.end, @14356962609521455);
        XCTAssertEqual(result.operation, PNHistoryOperation);
        // might want to assert message array is exactly equal, for now just get count
        XCTAssertNotNil(result.data.messages);
        XCTAssertEqual(result.data.messages.count, 13);
        NSArray *expectedMessages = @[
                                      @"*********...... 1244 - 2015-06-30 13:30:35",
                                      @"**********..... 1245 - 2015-06-30 13:30:37",
                                      @"***********.... 1246 - 2015-06-30 13:30:39",
                                      @"************... 1247 - 2015-06-30 13:30:41",
                                      @"*************.. 1248 - 2015-06-30 13:30:43",
                                      @"**************. 1249 - 2015-06-30 13:30:45",
                                      @"*************** 1250 - 2015-06-30 13:30:47",
                                      @"*.............. 1251 - 2015-06-30 13:30:49",
                                      @"**............. 1252 - 2015-06-30 13:30:51",
                                      @"***............ 1253 - 2015-06-30 13:30:53",
                                      @"****........... 1254 - 2015-06-30 13:30:55",
                                      @"*****.......... 1255 - 2015-06-30 13:30:58",
                                      @"******......... 1256 - 2015-06-30 13:31:00"
                                      ];
        NSLog(@"result: %@", result.data.messages);
        XCTAssertEqualObjects(result.data.messages, expectedMessages);
        NSLog(@"status: %@", status);
        [historyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
}

- (void)testHistoryWithTimeToken {
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    [self.client historyForChannel:@"a" start:@14356962344283504 end:@14356962619609342 includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.start, @14356962364490888);
        XCTAssertEqualObjects(result.data.end, @14356962609521455);
        XCTAssertEqual(result.operation, PNHistoryOperation);
        // might want to assert message array is exactly equal, for now just get count
        XCTAssertNotNil(result.data.messages);
        XCTAssertEqual(result.data.messages.count, 13);
        NSArray *expectedMessages = @[
                                      @{
                                        @"message" : @"*********...... 1244 - 2015-06-30 13:30:35",
                                        @"timetoken" : @14356962364490888
                                        },
                                      @{
                                        @"message" : @"**********..... 1245 - 2015-06-30 13:30:37",
                                        @"timetoken" : @14356962384898753
                                        },
                                      @{
                                        @"message" : @"***********.... 1246 - 2015-06-30 13:30:39",
                                        @"timetoken" : @14356962405294305
                                        },
                                      @{
                                        @"message" : @"************... 1247 - 2015-06-30 13:30:41",
                                        @"timetoken" : @14356962425704863
                                        },
                                      @{
                                        @"message" : @"*************.. 1248 - 2015-06-30 13:30:43",
                                        @"timetoken" : @14356962446126788
                                        },
                                      @{
                                        @"message" : @"**************. 1249 - 2015-06-30 13:30:45",
                                        @"timetoken" : @14356962466542248
                                        },
                                      @{
                                        @"message" : @"*************** 1250 - 2015-06-30 13:30:47",
                                        @"timetoken" : @14356962486987818
                                        },
                                      @{
                                        @"message" : @"*.............. 1251 - 2015-06-30 13:30:49",
                                        @"timetoken" : @14356962507478694
                                        },
                                      @{
                                        @"message" : @"**............. 1252 - 2015-06-30 13:30:51",
                                        @"timetoken" : @14356962527885179
                                        },
                                      @{
                                        @"message" : @"***............ 1253 - 2015-06-30 13:30:53",
                                        @"timetoken" : @14356962548281499
                                        },
                                      @{
                                        @"message" : @"****........... 1254 - 2015-06-30 13:30:55",
                                        @"timetoken" : @14356962568708660
                                        },
                                      @{
                                        @"message" : @"*****.......... 1255 - 2015-06-30 13:30:58",
                                        @"timetoken" : @14356962589101722
                                        },
                                      @{
                                        @"message" : @"******......... 1256 - 2015-06-30 13:31:00",
                                        @"timetoken" : @14356962609521455
                                        }
                                      ];
        NSLog(@"result: %@", result.data.messages);
        XCTAssertEqualObjects(result.data.messages, expectedMessages);
        NSLog(@"status: %@", status);
        [historyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)testHistoryWithLimit {
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    [self.client historyForChannel:@"a" start:@14356962344283504 end:@14356962619609342 limit:3 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.start, @14356962364490888);
        XCTAssertEqualObjects(result.data.end, @14356962405294305);
        XCTAssertEqual(result.operation, PNHistoryOperation);
        // might want to assert message array is exactly equal, for now just get count
        XCTAssertNotNil(result.data.messages);
        XCTAssertEqual(result.data.messages.count, 3);
        NSArray *expectedMessages = @[
                                      @"*********...... 1244 - 2015-06-30 13:30:35",
                                      @"**********..... 1245 - 2015-06-30 13:30:37",
                                      @"***********.... 1246 - 2015-06-30 13:30:39"
                                      ];
        NSLog(@"result: %@", result.data.messages);
        XCTAssertEqualObjects(result.data.messages, expectedMessages);
        NSLog(@"status: %@", status);
        [historyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)testHistoryWithLimitAndTimeToken {
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    [self.client historyForChannel:@"a" start:@14356962344283504 end:@14356962619609342 limit:3 includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.start, @14356962364490888);
        XCTAssertEqualObjects(result.data.end, @14356962405294305);
        XCTAssertEqual(result.operation, PNHistoryOperation);
        // might want to assert message array is exactly equal, for now just get count
        XCTAssertNotNil(result.data.messages);
        XCTAssertEqual(result.data.messages.count, 3);
        NSArray *expectedMessages = @[
                                      @{
                                          @"message" : @"*********...... 1244 - 2015-06-30 13:30:35",
                                          @"timetoken" : @14356962364490888
                                          },
                                      @{
                                          @"message" : @"**********..... 1245 - 2015-06-30 13:30:37",
                                          @"timetoken" : @14356962384898753
                                          },
                                      @{
                                          @"message" : @"***********.... 1246 - 2015-06-30 13:30:39",
                                          @"timetoken" : @14356962405294305
                                          }
                                      ];
        NSLog(@"result: %@", result.data.messages);
        XCTAssertEqualObjects(result.data.messages, expectedMessages);
        NSLog(@"status: %@", status);
        [historyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

@end
