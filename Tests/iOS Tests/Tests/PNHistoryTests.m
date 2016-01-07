//
//  PNHistoryTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/23/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

#import "NSArray+PNTest.h"

@interface PNHistoryTests : PNBasicClientTestCase
@end

@implementation PNHistoryTests

- (BOOL)isRecording {
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

#pragma mark - Negative tests

- (void)testHistoryWithNilStart {
    
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    
    [self.client historyForChannel:@"a" start:nil end:@14356962619609342 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.start, @14370552240720549);
        XCTAssertEqualObjects(result.data.end, @14370554273730457);
        XCTAssertEqual(result.operation, PNHistoryOperation);
        // might want to assert message array is exactly equal, for now just get count
        XCTAssertNotNil(result.data.messages);
        XCTAssertEqual(result.data.messages.count, 100);
        NSArray *expectedMessages = @[
                                       @"*****.......... 5857 - 2015-07-16 07:00:23",
                                       @"******......... 5858 - 2015-07-16 07:00:25",
                                       @"*******........ 5859 - 2015-07-16 07:00:27",
                                       @"********....... 5860 - 2015-07-16 07:00:29",
                                       @"*********...... 5861 - 2015-07-16 07:00:31",
                                       @"**********..... 5862 - 2015-07-16 07:00:33",
                                       @"***********.... 5863 - 2015-07-16 07:00:35",
                                       @"************... 5864 - 2015-07-16 07:00:37",
                                       @"*************.. 5865 - 2015-07-16 07:00:39",
                                       @"**************. 5866 - 2015-07-16 07:00:41",
                                       @"*************** 5867 - 2015-07-16 07:00:44",
                                       @"*.............. 5868 - 2015-07-16 07:00:46",
                                       @"**............. 5869 - 2015-07-16 07:00:48",
                                       @"***............ 5870 - 2015-07-16 07:00:50",
                                       @"****........... 5871 - 2015-07-16 07:00:52",
                                       @"*****.......... 5872 - 2015-07-16 07:00:54",
                                       @"******......... 5873 - 2015-07-16 07:00:56",
                                       @"*******........ 5874 - 2015-07-16 07:00:58",
                                       @"********....... 5875 - 2015-07-16 07:01:00",
                                       @"*********...... 5876 - 2015-07-16 07:01:03",
                                       @"**********..... 5877 - 2015-07-16 07:01:05",
                                       @"***********.... 5878 - 2015-07-16 07:01:07",
                                       @"************... 5879 - 2015-07-16 07:01:09",
                                       @"*************.. 5880 - 2015-07-16 07:01:11",
                                       @"**************. 5881 - 2015-07-16 07:01:13",
                                       @"*************** 5882 - 2015-07-16 07:01:15",
                                       @"*.............. 5883 - 2015-07-16 07:01:17",
                                       @"**............. 5884 - 2015-07-16 07:01:19",
                                       @"***............ 5885 - 2015-07-16 07:01:21",
                                       @"****........... 5886 - 2015-07-16 07:01:23",
                                       @"*****.......... 5887 - 2015-07-16 07:01:25",
                                       @"******......... 5888 - 2015-07-16 07:01:27",
                                       @"*******........ 5889 - 2015-07-16 07:01:29",
                                       @"********....... 5890 - 2015-07-16 07:01:31",
                                       @"*********...... 5891 - 2015-07-16 07:01:33",
                                       @"**********..... 5892 - 2015-07-16 07:01:35",
                                       @"***********.... 5893 - 2015-07-16 07:01:37",
                                       @"************... 5894 - 2015-07-16 07:01:39",
                                       @"*************.. 5895 - 2015-07-16 07:01:41",
                                       @"**************. 5896 - 2015-07-16 07:01:43",
                                       @"*************** 5897 - 2015-07-16 07:01:45",
                                       @"*.............. 5898 - 2015-07-16 07:01:47",
                                       @"**............. 5899 - 2015-07-16 07:01:49",
                                       @"***............ 5900 - 2015-07-16 07:01:52",
                                       @"****........... 5901 - 2015-07-16 07:01:54",
                                       @"*****.......... 5902 - 2015-07-16 07:01:56",
                                       @"******......... 5903 - 2015-07-16 07:01:58",
                                       @"*******........ 5904 - 2015-07-16 07:02:00",
                                       @"********....... 5905 - 2015-07-16 07:02:02",
                                       @"*********...... 5906 - 2015-07-16 07:02:04",
                                       @"**********..... 5907 - 2015-07-16 07:02:06",
                                       @"***********.... 5908 - 2015-07-16 07:02:08",
                                       @"************... 5909 - 2015-07-16 07:02:10",
                                       @"*************.. 5910 - 2015-07-16 07:02:12",
                                       @"**************. 5911 - 2015-07-16 07:02:14",
                                       @"*************** 5912 - 2015-07-16 07:02:16",
                                       @"*.............. 5913 - 2015-07-16 07:02:18",
                                       @"**............. 5914 - 2015-07-16 07:02:20",
                                       @"***............ 5915 - 2015-07-16 07:02:22",
                                       @"****........... 5916 - 2015-07-16 07:02:24",
                                       @"*****.......... 5917 - 2015-07-16 07:02:26",
                                       @"******......... 5918 - 2015-07-16 07:02:28",
                                       @"*******........ 5919 - 2015-07-16 07:02:30",
                                       @"********....... 5920 - 2015-07-16 07:02:32",
                                       @"*********...... 5921 - 2015-07-16 07:02:35",
                                       @"**********..... 5922 - 2015-07-16 07:02:37",
                                       @"***********.... 5923 - 2015-07-16 07:02:39",
                                       @"************... 5924 - 2015-07-16 07:02:41",
                                       @"*************.. 5925 - 2015-07-16 07:02:43",
                                       @"**************. 5926 - 2015-07-16 07:02:45",
                                       @"*************** 5927 - 2015-07-16 07:02:47",
                                       @"*.............. 5928 - 2015-07-16 07:02:49",
                                       @"**............. 5929 - 2015-07-16 07:02:51",
                                       @"***............ 5930 - 2015-07-16 07:02:53",
                                       @"****........... 5931 - 2015-07-16 07:02:55",
                                       @"*****.......... 5932 - 2015-07-16 07:02:57",
                                       @"******......... 5933 - 2015-07-16 07:02:59",
                                       @"*******........ 5934 - 2015-07-16 07:03:01",
                                       @"********....... 5935 - 2015-07-16 07:03:03",
                                       @"*********...... 5936 - 2015-07-16 07:03:05",
                                       @"**********..... 5937 - 2015-07-16 07:03:07",
                                       @"***********.... 5938 - 2015-07-16 07:03:09",
                                       @"************... 5939 - 2015-07-16 07:03:11",
                                       @"*************.. 5940 - 2015-07-16 07:03:13",
                                       @"**************. 5941 - 2015-07-16 07:03:15",
                                       @"*************** 5942 - 2015-07-16 07:03:17",
                                       @"*.............. 5943 - 2015-07-16 07:03:19",
                                       @"**............. 5944 - 2015-07-16 07:03:21",
                                       @"***............ 5945 - 2015-07-16 07:03:24",
                                       @"****........... 5946 - 2015-07-16 07:03:26",
                                       @"*****.......... 5947 - 2015-07-16 07:03:28",
                                       @"******......... 5948 - 2015-07-16 07:03:30",
                                       @"*******........ 5949 - 2015-07-16 07:03:32",
                                       @"********....... 5950 - 2015-07-16 07:03:34",
                                       @"*********...... 5951 - 2015-07-16 07:03:36",
                                       @"**********..... 5952 - 2015-07-16 07:03:38",
                                       @"***********.... 5953 - 2015-07-16 07:03:40",
                                       @"************... 5954 - 2015-07-16 07:03:42",
                                       @"*************.. 5955 - 2015-07-16 07:03:44",
                                       @"**************. 5956 - 2015-07-16 07:03:46"
                                       ];
        XCTAssertEqualObjects(result.data.messages, expectedMessages);
        [historyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
}

- (void)testHistoryWithNilEnd {
    
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    [self.client historyForChannel:@"a" start:@14370749493660012 end:nil withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.start, @14370747463988719);
        XCTAssertEqualObjects(result.data.end, @14370749484421496);
        XCTAssertEqual(result.operation, PNHistoryOperation);
        // might want to assert message array is exactly equal, for now just get count
        XCTAssertNotNil(result.data.messages);
        XCTAssertEqual(result.data.messages.count, 100);
        
        NSArray *expectedMessages = @[
                                      @"********....... 5521 - 2015-07-16 12:25:45",
                                      @"*********...... 5522 - 2015-07-16 12:25:47",
                                      @"**********..... 5523 - 2015-07-16 12:25:49",
                                      @"***********.... 5524 - 2015-07-16 12:25:51",
                                      @"************... 5525 - 2015-07-16 12:25:53",
                                      @"*************.. 5526 - 2015-07-16 12:25:55",
                                      @"**************. 5527 - 2015-07-16 12:25:57",
                                      @"*************** 5528 - 2015-07-16 12:25:59",
                                      @"*.............. 5529 - 2015-07-16 12:26:01",
                                      @"**............. 5530 - 2015-07-16 12:26:03",
                                      @"***............ 5531 - 2015-07-16 12:26:05",
                                      @"****........... 5532 - 2015-07-16 12:26:07",
                                      @"*****.......... 5533 - 2015-07-16 12:26:09",
                                      @"******......... 5534 - 2015-07-16 12:26:12",
                                      @"*******........ 5535 - 2015-07-16 12:26:14",
                                      @"********....... 5536 - 2015-07-16 12:26:16",
                                      @"*********...... 5537 - 2015-07-16 12:26:18",
                                      @"**********..... 5538 - 2015-07-16 12:26:20",
                                      @"***********.... 5539 - 2015-07-16 12:26:22",
                                      @"************... 5540 - 2015-07-16 12:26:24",
                                      @"*************.. 5541 - 2015-07-16 12:26:26",
                                      @"**************. 5542 - 2015-07-16 12:26:28",
                                      @"*************** 5543 - 2015-07-16 12:26:30",
                                      @"*.............. 5544 - 2015-07-16 12:26:32",
                                      @"**............. 5545 - 2015-07-16 12:26:34",
                                      @"***............ 5546 - 2015-07-16 12:26:36",
                                      @"****........... 5547 - 2015-07-16 12:26:38",
                                      @"*****.......... 5548 - 2015-07-16 12:26:40",
                                      @"******......... 5549 - 2015-07-16 12:26:42",
                                      @"*******........ 5550 - 2015-07-16 12:26:44",
                                      @"********....... 5551 - 2015-07-16 12:26:46",
                                      @"*********...... 5552 - 2015-07-16 12:26:48",
                                      @"**********..... 5553 - 2015-07-16 12:26:50",
                                      @"***********.... 5554 - 2015-07-16 12:26:52",
                                      @"************... 5555 - 2015-07-16 12:26:54",
                                      @"*************.. 5556 - 2015-07-16 12:26:56",
                                      @"**************. 5557 - 2015-07-16 12:26:58",
                                      @"*************** 5558 - 2015-07-16 12:27:00",
                                      @"*.............. 5559 - 2015-07-16 12:27:03",
                                      @"**............. 5560 - 2015-07-16 12:27:05",
                                      @"***............ 5561 - 2015-07-16 12:27:07",
                                      @"****........... 5562 - 2015-07-16 12:27:09",
                                      @"*****.......... 5563 - 2015-07-16 12:27:11",
                                      @"******......... 5564 - 2015-07-16 12:27:13",
                                      @"*******........ 5565 - 2015-07-16 12:27:15",
                                      @"********....... 5566 - 2015-07-16 12:27:17",
                                      @"*********...... 5567 - 2015-07-16 12:27:19",
                                      @"**********..... 5568 - 2015-07-16 12:27:21",
                                      @"***********.... 5569 - 2015-07-16 12:27:23",
                                      @"************... 5570 - 2015-07-16 12:27:25",
                                      @"*************.. 5571 - 2015-07-16 12:27:27",
                                      @"**************. 5572 - 2015-07-16 12:27:29",
                                      @"*************** 5573 - 2015-07-16 12:27:31",
                                      @"*.............. 5574 - 2015-07-16 12:27:33",
                                      @"**............. 5575 - 2015-07-16 12:27:35",
                                      @"***............ 5576 - 2015-07-16 12:27:37",
                                      @"****........... 5577 - 2015-07-16 12:27:39",
                                      @"*****.......... 5578 - 2015-07-16 12:27:41",
                                      @"******......... 5579 - 2015-07-16 12:27:43",
                                      @"*******........ 5580 - 2015-07-16 12:27:45",
                                      @"********....... 5581 - 2015-07-16 12:27:47",
                                      @"*********...... 5582 - 2015-07-16 12:27:50",
                                      @"**********..... 5583 - 2015-07-16 12:27:52",
                                      @"***********.... 5584 - 2015-07-16 12:27:54",
                                      @"************... 5585 - 2015-07-16 12:27:56",
                                      @"*************.. 5586 - 2015-07-16 12:27:58",
                                      @"**************. 5587 - 2015-07-16 12:28:00",
                                      @"*************** 5588 - 2015-07-16 12:28:02",
                                      @"*.............. 5589 - 2015-07-16 12:28:04",
                                      @"**............. 5590 - 2015-07-16 12:28:06",
                                      @"***............ 5591 - 2015-07-16 12:28:08",
                                      @"****........... 5592 - 2015-07-16 12:28:10",
                                      @"*****.......... 5593 - 2015-07-16 12:28:12",
                                      @"******......... 5594 - 2015-07-16 12:28:14",
                                      @"*******........ 5595 - 2015-07-16 12:28:16",
                                      @"********....... 5596 - 2015-07-16 12:28:18",
                                      @"*********...... 5597 - 2015-07-16 12:28:20",
                                      @"**********..... 5598 - 2015-07-16 12:28:22",
                                      @"***********.... 5599 - 2015-07-16 12:28:24",
                                      @"************... 5600 - 2015-07-16 12:28:26",
                                      @"*************.. 5601 - 2015-07-16 12:28:28",
                                      @"**************. 5602 - 2015-07-16 12:28:30",
                                      @"*************** 5603 - 2015-07-16 12:28:32",
                                      @"*.............. 5604 - 2015-07-16 12:28:34",
                                      @"**............. 5605 - 2015-07-16 12:28:36",
                                      @"***............ 5606 - 2015-07-16 12:28:39",
                                      @"****........... 5607 - 2015-07-16 12:28:41",
                                      @"*****.......... 5608 - 2015-07-16 12:28:43",
                                      @"******......... 5609 - 2015-07-16 12:28:45",
                                      @"*******........ 5610 - 2015-07-16 12:28:47",
                                      @"********....... 5611 - 2015-07-16 12:28:49",
                                      @"*********...... 5612 - 2015-07-16 12:28:51",
                                      @"**********..... 5613 - 2015-07-16 12:28:53",
                                      @"***********.... 5614 - 2015-07-16 12:28:55",
                                      @"************... 5615 - 2015-07-16 12:28:57",
                                      @"*************.. 5616 - 2015-07-16 12:28:59",
                                      @"**************. 5617 - 2015-07-16 12:29:01",
                                      @"*************** 5618 - 2015-07-16 12:29:03",
                                      @"*.............. 5619 - 2015-07-16 12:29:05",
                                      @"**............. 5620 - 2015-07-16 12:29:07"
                                      ];
        XCTAssertEqualObjects(result.data.messages, expectedMessages);
        [historyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
}

- (void)testHistoryWithNilStartEnd {
    
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    [self.client historyForChannel:@"a" start:nil end:nil withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.start, @14370790071455550);
        XCTAssertEqualObjects(result.data.end, @14370792106187530);
        XCTAssertEqual(result.operation, PNHistoryOperation);
        // might want to assert message array is exactly equal, for now just get count
        XCTAssertNotNil(result.data.messages);
        XCTAssertEqual(result.data.messages.count, 100);
        NSArray *expectedMessages = @[
                                      @"*************** 7628 - 2015-07-16 13:36:46",
                                      @"*.............. 7629 - 2015-07-16 13:36:48",
                                      @"**............. 7630 - 2015-07-16 13:36:50",
                                      @"***............ 7631 - 2015-07-16 13:36:52",
                                      @"****........... 7632 - 2015-07-16 13:36:54",
                                      @"*****.......... 7633 - 2015-07-16 13:36:56",
                                      @"******......... 7634 - 2015-07-16 13:36:58",
                                      @"*******........ 7635 - 2015-07-16 13:37:00",
                                      @"********....... 7636 - 2015-07-16 13:37:02",
                                      @"*********...... 7637 - 2015-07-16 13:37:04",
                                      @"**********..... 7638 - 2015-07-16 13:37:06",
                                      @"***********.... 7639 - 2015-07-16 13:37:08",
                                      @"************... 7640 - 2015-07-16 13:37:10",
                                      @"*************.. 7641 - 2015-07-16 13:37:12",
                                      @"**************. 7642 - 2015-07-16 13:37:14",
                                      @"*************** 7643 - 2015-07-16 13:37:16",
                                      @"*.............. 7644 - 2015-07-16 13:37:18",
                                      @"**............. 7645 - 2015-07-16 13:37:20",
                                      @"***............ 7646 - 2015-07-16 13:37:22",
                                      @"****........... 7647 - 2015-07-16 13:37:25",
                                      @"*****.......... 7648 - 2015-07-16 13:37:27",
                                      @"******......... 7649 - 2015-07-16 13:37:29",
                                      @"*******........ 7650 - 2015-07-16 13:37:31",
                                      @"********....... 7651 - 2015-07-16 13:37:33",
                                      @"*********...... 7652 - 2015-07-16 13:37:35",
                                      @"**********..... 7653 - 2015-07-16 13:37:37",
                                      @"***********.... 7654 - 2015-07-16 13:37:39",
                                      @"************... 7655 - 2015-07-16 13:37:41",
                                      @"*************.. 7656 - 2015-07-16 13:37:43",
                                      @"**************. 7657 - 2015-07-16 13:37:45",
                                      @"*************** 7658 - 2015-07-16 13:37:47",
                                      @"*.............. 7659 - 2015-07-16 13:37:49",
                                      @"**............. 7660 - 2015-07-16 13:37:51",
                                      @"***............ 7661 - 2015-07-16 13:37:53",
                                      @"****........... 7662 - 2015-07-16 13:37:55",
                                      @"*****.......... 7663 - 2015-07-16 13:37:57",
                                      @"******......... 7664 - 2015-07-16 13:37:59",
                                      @"*******........ 7665 - 2015-07-16 13:38:02",
                                      @"********....... 7666 - 2015-07-16 13:38:04",
                                      @"*********...... 7667 - 2015-07-16 13:38:06",
                                      @"**********..... 7668 - 2015-07-16 13:38:08",
                                      @"***********.... 7669 - 2015-07-16 13:38:11",
                                      @"************... 7670 - 2015-07-16 13:38:13",
                                      @"*************.. 7671 - 2015-07-16 13:38:15",
                                      @"**************. 7672 - 2015-07-16 13:38:17",
                                      @"*************** 7673 - 2015-07-16 13:38:19",
                                      @"*.............. 7674 - 2015-07-16 13:38:21",
                                      @"**............. 7675 - 2015-07-16 13:38:23",
                                      @"***............ 7676 - 2015-07-16 13:38:25",
                                      @"****........... 7677 - 2015-07-16 13:38:27",
                                      @"*****.......... 7678 - 2015-07-16 13:38:29",
                                      @"******......... 7679 - 2015-07-16 13:38:31",
                                      @"*******........ 7680 - 2015-07-16 13:38:33",
                                      @"********....... 7681 - 2015-07-16 13:38:35",
                                      @"*********...... 7682 - 2015-07-16 13:38:37",
                                      @"**********..... 7683 - 2015-07-16 13:38:39",
                                      @"***********.... 7684 - 2015-07-16 13:38:41",
                                      @"************... 7685 - 2015-07-16 13:38:43",
                                      @"*************.. 7686 - 2015-07-16 13:38:45",
                                      @"**************. 7687 - 2015-07-16 13:38:48",
                                      @"*************** 7688 - 2015-07-16 13:38:50",
                                      @"*.............. 7689 - 2015-07-16 13:38:52",
                                      @"**............. 7690 - 2015-07-16 13:38:54",
                                      @"***............ 7691 - 2015-07-16 13:38:56",
                                      @"****........... 7692 - 2015-07-16 13:38:58",
                                      @"*****.......... 7693 - 2015-07-16 13:39:00",
                                      @"******......... 7694 - 2015-07-16 13:39:02",
                                      @"*******........ 7695 - 2015-07-16 13:39:04",
                                      @"********....... 7696 - 2015-07-16 13:39:06",
                                      @"*********...... 7697 - 2015-07-16 13:39:08",
                                      @"**********..... 7698 - 2015-07-16 13:39:10",
                                      @"***********.... 7699 - 2015-07-16 13:39:12",
                                      @"************... 7700 - 2015-07-16 13:39:14",
                                      @"*************.. 7701 - 2015-07-16 13:39:16",
                                      @"**************. 7702 - 2015-07-16 13:39:18",
                                      @"*************** 7703 - 2015-07-16 13:39:20",
                                      @"*.............. 7704 - 2015-07-16 13:39:22",
                                      @"**............. 7705 - 2015-07-16 13:39:24",
                                      @"***............ 7706 - 2015-07-16 13:39:26",
                                      @"****........... 7707 - 2015-07-16 13:39:28",
                                      @"*****.......... 7708 - 2015-07-16 13:39:30",
                                      @"******......... 7709 - 2015-07-16 13:39:33",
                                      @"*******........ 7710 - 2015-07-16 13:39:35",
                                      @"********....... 7711 - 2015-07-16 13:39:37",
                                      @"*********...... 7712 - 2015-07-16 13:39:39",
                                      @"**********..... 7713 - 2015-07-16 13:39:41",
                                      @"***********.... 7714 - 2015-07-16 13:39:43",
                                      @"************... 7715 - 2015-07-16 13:39:45",
                                      @"*************.. 7716 - 2015-07-16 13:39:47",
                                      @"**************. 7717 - 2015-07-16 13:39:49",
                                      @"*************** 7718 - 2015-07-16 13:39:51",
                                      @"*.............. 7719 - 2015-07-16 13:39:53",
                                      @"**............. 7720 - 2015-07-16 13:39:55",
                                      @"***............ 7721 - 2015-07-16 13:39:57",
                                      @"****........... 7722 - 2015-07-16 13:39:59",
                                      @"*****.......... 7723 - 2015-07-16 13:40:01",
                                      @"******......... 7724 - 2015-07-16 13:40:03",
                                      @"*******........ 7725 - 2015-07-16 13:40:05",
                                      @"********....... 7726 - 2015-07-16 13:40:07",
                                      @"*********...... 7727 - 2015-07-16 13:40:09"
                                      ];
        XCTAssertEqualObjects(result.data.messages, expectedMessages);
        [historyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
}

@end
