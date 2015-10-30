//
//  ChiperKeyTests.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 9/11/15.
//
//
#import <PubNub/PubNub.h>

#import "PNConfigurationChiperKeyTests.h"
#import "PNBasicClientTestCase.h"

#import "NSArray+PNTest.h"

@implementation PNConfigurationChiperKeyTests

- (BOOL)isRecording {
    return NO;
}

- (NSString *)channelString {
    return @"9BA810C6-985D-4797-926F-CC81749CC774";
}

- (NSString *)cryptedChannelName {
    return @"9FA810C6-985D-4797-926F-CC81749CC774";
}

- (void)testHistoryWithChiperKey {
    
    NSArray *messages = @[@"Test 1", @"Test 2", @"Test 3"];
    NSMutableArray *expectations = [NSMutableArray new];
    
    for (NSString *message in messages) {
        
        XCTestExpectation *expectation = [self expectationWithDescription:message];
        [expectations addObject:expectation];

        [self.cryptedClient publish:message
                   toChannel:[self channelString]
              storeInHistory:YES
              withCompletion:^(PNPublishStatus *status) {
                  if (status != nil) {
                      [expectation fulfill];
                  } else {
                      
                  }
              }];
        
    }
    
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    
    [self.cryptedClient historyForChannel:[self channelString]
                    withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
                        XCTAssertNotNil(status, @"Status shouldn't be nil");
                        XCTAssertNil(result, @"Results should be nil.");
                        
                        XCTAssertEqual(status.statusCode, 400, @"Status codes are not equal.");
                        XCTAssertEqual(status.category, PNDecryptionErrorCategory, @"Categories are not equal.");
                        XCTAssertEqual(status.operation, PNHistoryOperation, @"Operations are not equal.");
                        
                        NSArray *messages =             @[
                                                @{
                                                    @"test" : @"test"
                                                },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @{
                                                    @"test" : @"test"
                                                    },
                                                @"test",
                                                @"Test 3",
                                                @"Test 2",
                                                @"Test 1"
                                                ];
                        XCTAssertEqualObjects(messages, [(PNHistoryData *)status.associatedObject messages], @"Messages are not equal.");
                        
                        NSLog(@"Result: %@", result);
                        [historyExpectation fulfill];
                    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)testHistoryWithChiperKeyOnlyCryptedMessages {
    
    // Uncomment only if you want to upload refresh data in fixtures.
//    NSArray *messages = @[@"Test 2", @"Test 3", @"Test 1"];
//    NSMutableArray *expectations = [NSMutableArray new];
//    
//    for (NSString *message in messages) {
//        
//        XCTestExpectation *expectation = [self expectationWithDescription:message];
//        [expectations addObject:expectation];
//        
//        [self.cryptedClient publish:message
//                          toChannel:[self cryptedChannelName]
//                     storeInHistory:YES
//                     withCompletion:^(PNPublishStatus *status) {
//                         if (status != nil) {
//                             [expectation fulfill];
//                         } else {
//                             
//                         }
//                     }];
//        
//    }
//    
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
//        NSLog(@"error: %@", error);
//    }];
    
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    
    [self.cryptedClient historyForChannel:[self cryptedChannelName]
                           withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
                               XCTAssertNotNil(result, @"Result shouldn't be nil");
                               XCTAssertNil(status, @"Status should be nil.");
                               
                               XCTAssertEqual(result.statusCode, 200, @"Status codes are not equal.");
                               XCTAssertEqual(result.operation, PNHistoryOperation, @"Operations are not equal.");
                               
                               NSArray *messages =             @[
                                                                 @"Test 2",
                                                                 @"Test 3",
                                                                 @"Test 1",
                                                                 ];
                               XCTAssertEqualObjects(messages, [[result data] messages], @"Messages are not equal.");
                               XCTAssertEqualObjects(@14422371436802799, [[result data] end], @"Messages are not equal.");
                               XCTAssertEqualObjects(@14422371428544005, [[result data] start], @"Messages are not equal.");
                               
                               NSLog(@"Result: %@", result);
                               [historyExpectation fulfill];
                           }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

@end
