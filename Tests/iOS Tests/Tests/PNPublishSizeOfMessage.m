//
//  PNPublishSizeOfMessage.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 3/23/16.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

#import "NSString+PNTest.h"

@interface PNPublishSizeOfMessage : XCTestCase

@property (nonatomic) PubNub *client;

@end

@implementation PNPublishSizeOfMessage

- (void)setUp {
    [super setUp];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    config.stripMobilePayload = NO;
#pragma clang diagnostic pop
    config.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C";
    self.client = [PubNub clientWithConfiguration:config];
}

- (void)tearDown {
    self.client = nil;
    [super tearDown];
}

- (void)testSizeOfMessageToChannel {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSString *message = @"test";
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 424, 20, @"Size is different than expected %@ <> %@ +-20", @(size), @(424));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeOfMessageToNilChannel {
    
    NSString *message = @"test";
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    [self.client sizeOfMessage:message
                     toChannel:nil
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqual(size, -1, @"Size is different than expected %@ <> %@", @(size), @(-1));
                    
                    [completionBlockExpectation fulfill];
                }];
    #pragma clang diagnostic pop
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeOfMessageStoreInHistory {
    
    NSString *message = @"test";
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    [self.client sizeOfMessage:message
                     toChannel:nil
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqual(size, -1, @"Size is different than expected %@ <> %@", @(size), @(-1));
                    
                    [completionBlockExpectation fulfill];
                }];
    #pragma clang diagnostic pop
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeOfMessageCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSString *message = @"test";
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 534, 20, @"Size is different than expected %@ <> %@ +- 20", @(size), @(534));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeOfMessageStoreInHistoryAndCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSString *message = @"test";
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:YES
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 534, 20, @"Size is different than expected %@ <> %@ +- 20", @(size), @(534));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeOfMessageStoreInHistoryNotCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSString *message = @"test";
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:NO
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 424, 20, @"Size is different than expected %@ <> %@ +-20", @(size), @(424));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeOfMessageNotStoreInHistoryNotCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSString *message = @"test";
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:NO
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 424, 20, @"Size is different than expected %@ <> %@ +-20", @(size), @(424));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeOfMessageNotStoreInHistoryCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSString *message = @"test";
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:YES
                storeInHistory:NO
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 542, 20, @"Size is different than expected %@ <> %@ +- 20", @(size), @(542));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSize10kMessageStoreInHistoryCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSString *message = [NSString randomAlphanumericStringWithLength:10000];

    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:YES
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 8052, 500, @"Size is different than expected %@ <> %@ +-500", @(size), @(8052));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSize100kMessageStoreInHistoryCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSString *message = [NSString randomAlphanumericStringWithLength:100000];
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:YES
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 75732, 5000, @"Size is different than expected %@ <> %@ +- 5000", @(size), @(75732));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeDictionaryMessageStoreInHistoryCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSDictionary *message = @{@"1": @"3", @"2": @"3"};
    
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:YES
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 541, 20,@"Size is different than expected %@ <> %@ +-528", @(size), @(541));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeNestedDictionaryMessageStoreInHistoryCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSDictionary *message = @{@"1": @{@"1": @{@"3": @"5"}}, @"2": @"3"};
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:YES
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 551, 20, @"Size is different than expected %@ <> %@", @(size), @(551));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeArrayMessageStoreInHistoryCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSArray *message = @[@"1", @"2", @"3", @"4"];
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:YES
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 542, 20, @"Size is different than expected %@ <> %@ +- 20", @(size), @(542));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

- (void)testSizeComplexArrayMessageStoreInHistoryCompressed {
    
    NSString *channelName = [[NSUUID UUID] UUIDString];
    NSArray *message =   @[@"1", @{@"1": @{@"1": @"2"}}, @[@"1", @"2", @(2)], @(567)];
    
    XCTestExpectation *completionBlockExpectation = [self expectationWithDescription:@"Completion"];
    
    [self.client sizeOfMessage:message
                     toChannel:channelName
                    compressed:YES
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqualWithAccuracy(size, 557, 20, @"Size is different than expected %@ <> %@ +-20", @(size), @(557));
                    
                    [completionBlockExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

@end
