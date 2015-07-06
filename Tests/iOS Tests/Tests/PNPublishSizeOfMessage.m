//
//  PNPublishSizeOfMessage.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 6/24/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
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
                    
                    XCTAssertEqualWithAccuracy(size, 411, 20, @"Size is different than expected %@ <> %@ +-20", @(size), @(411));
                    
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
    
    [self.client sizeOfMessage:message
                     toChannel:nil
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqual(size, -1, @"Size is different than expected %@ <> %@", @(size), @(-1));
                    
                    [completionBlockExpectation fulfill];
                }];
    
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
    
    [self.client sizeOfMessage:message
                     toChannel:nil
                storeInHistory:YES
                withCompletion:^(NSInteger size) {
                    NSLog(@"%@", @(size));
                    
                    XCTAssertEqual(size, -1, @"Size is different than expected %@ <> %@", @(size), @(-1));
                    
                    [completionBlockExpectation fulfill];
                }];
    
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
                    
                    XCTAssertEqualWithAccuracy(size, 521, 20, @"Size is different than expected %@ <> %@ +- 20", @(size), @(521));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 521, 20, @"Size is different than expected %@ <> %@ +- 20", @(size), @(521));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 411, 20, @"Size is different than expected %@ <> %@ +-20", @(size), @(411));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 411, 20, @"Size is different than expected %@ <> %@ +-20", @(size), @(411));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 529, 20, @"Size is different than expected %@ <> %@ +- 20", @(size), @(529));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 8000, 500, @"Size is different than expected %@ <> %@ +-500", @(size), @(8000));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 75000, 5000, @"Size is different than expected %@ <> %@ +- 5000", @(size), @(75000));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 528, 20,@"Size is different than expected %@ <> %@ +-528", @(size), @(528));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 538, 20, @"Size is different than expected %@ <> %@", @(size), @(538));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 529, 20, @"Size is different than expected %@ <> %@ +- 20", @(size), @(529));
                    
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
                    
                    XCTAssertEqualWithAccuracy(size, 544, 20, @"Size is different than expected %@ <> %@ +-20", @(size), @(544));
                    
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
