//
//  PNFilteringSubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/16/15.
//
//

#import "PNBasicSubscribeTestCase.h"

static NSString * const kPNChannelTestName = @"PNFilterSubscribeTests";

@interface PNFilteringSubscribeTests : PNBasicSubscribeTestCase
@property (nonatomic, assign) BOOL hasPublished;
@property (nonatomic, strong) PNSubscribeTestData *testData;
@end

@implementation PNFilteringSubscribeTests

- (BOOL)isRecording{
    return NO;
}

- (void)setUp {
    [super setUp];
    [self setupMessageFiltering];
    self.hasPublished = NO;
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testData = [[PNSubscribeTestData alloc] init];
    self.testData.publishMessage = @"message";
    self.testData.publishChannel = kPNChannelTestName;
    self.testData.subscribedChannels = @[kPNChannelTestName];
    self.testData.expectedStatusRegion = @56;
    self.testData.expectedPublishInformation = @"Sent";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.publishExpectation = nil;
    self.subscribeExpectation = nil;
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        NSLog(@"***************** status: %@", status.debugDescription);
        if (status.operation == PNSubscribeOperation) {
            return;
        }
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        NSLog(@"tearDown status: %@", status.debugDescription);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        [self.unsubscribeExpectation fulfill];
        
    };
    [self PNTest_unsubscribeFromChannels:@[kPNChannelTestName] withPresence:NO];
    [super tearDown];
}

- (void)setupMessageFiltering {
    
    if (
        (self.invocation.selector == @selector(testPublishWithNoMetadataAndReceivedMessageForSubscribeWithNoFiltering)) ||
        (self.invocation.selector == @selector(testPublishWithNoMetadataAndReceiveMultipleMessagesForSubscribeWithNoFiltering))
        ) {
        // No filter expression
    } else if (self.invocation.selector == @selector(testPublishWithMetadataAndNoReceivedMessageForSubscribeWithDifferentFiltering)) {
        [self.client setFilterExpression:@"(a == 'b')"];
    } else if (self.invocation.selector == @selector(testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSameKeyAndDifferentValue)) {
        [self.client setFilterExpression:@"(foo == 'b')"];
    } else if (self.invocation.selector == @selector(testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSwitchedKeysAndValues)) {
        [self.client setFilterExpression:@"(bar == 'foo')"];
    } else {
        [self.client setFilterExpression:@"(foo=='bar')"];
    }
}

- (void)testPublishWithNoMetadataAndReceiveMultipleMessagesForSubscribeWithNoFiltering {
    PNWeakify(self);
    __block XCTestExpectation *secondPublishExpectation = [self expectationWithDescription:@"secondPublishExpectation"];
    __block NSInteger messageNumber = 0;
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannels.count, 1);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
//        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertNotNil(message.data);
        switch (messageNumber) {
            case 0:
            {
                XCTAssertEqualObjects(message.data.message, @"message");
                XCTAssertNil(message.data.actualChannel);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14521912345094137);
            }
                break;
            case 1:
            {
                XCTAssertEqualObjects(message.data.message, @"message1");
                XCTAssertNil(message.data.actualChannel);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14521912346468431);
                [self.subscribeExpectation fulfill];
                self.subscribeExpectation = nil;
            }
                break;
            default:
            {
                XCTFail(@"shouldn't be here!. Should only receive two messages.");
            }
                break;
        }
        messageNumber++;
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    __block NSNumber *firstPublishTimeToken = nil;
    __block NSNumber *secondPublishTimeToken = nil;
    [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:nil completion:^(PNPublishStatus *status) {
        NSLog(@"status: %@", status.debugDescription);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        firstPublishTimeToken = status.data.timetoken;
//        [self fulfillSubscribeExpectationAfterDelay:10];
        [self.publishExpectation fulfill];
    }];
    [self.client publish:@"message1" toChannel:kPNChannelTestName withMetadata:nil completion:^(PNPublishStatus *status) {
        NSLog(@"status: %@", status.debugDescription);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        secondPublishTimeToken = status.data.timetoken;
        [secondPublishExpectation fulfill];
//        secondPublishExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    self.publishExpectation = nil;
    secondPublishExpectation = nil;
    NSNumber *finalTimeToken = nil;
    if ([firstPublishTimeToken compare:secondPublishTimeToken] == NSOrderedAscending) {
        finalTimeToken = firstPublishTimeToken;
    } else if ([firstPublishTimeToken compare:secondPublishTimeToken] == NSOrderedDescending) {
        finalTimeToken = secondPublishTimeToken;
    } else {
        finalTimeToken = firstPublishTimeToken;
    }
    [self PNTest_subscribeToChannels:@[kPNChannelTestName] withPresence:NO usingTimeToken:finalTimeToken];
}

- (void)testPublishWithMetadataAndReceiveMultipleMessagesForSubscribeWithMatchingFiltering {
    PNWeakify(self);
    __block XCTestExpectation *secondPublishExpectation = [self expectationWithDescription:@"secondPublishExpectation"];
    __block NSInteger messageNumber = 0;
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannels.count, 1);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
//        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertNotNil(message.data);
        switch (messageNumber) {
            case 0:
            {
                XCTAssertEqualObjects(message.data.message, @"message");
                XCTAssertNil(message.data.actualChannel);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14521919071550816);
            }
                break;
            case 1:
            {
                XCTAssertEqualObjects(message.data.message, @"message1");
                XCTAssertNil(message.data.actualChannel);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14521919072760992);
                [self.subscribeExpectation fulfill];
                self.subscribeExpectation = nil;
            }
                break;
            default:
            {
                XCTFail(@"shouldn't be here!. Should only receive two messages.");
            }
                break;
        }
        messageNumber++;
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    __block NSNumber *firstPublishTimeToken = nil;
    __block NSNumber *secondPublishTimeToken = nil;
    [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"bar"} 
              completion:^(PNPublishStatus *status) {
        NSLog(@"status: %@", status.debugDescription);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        firstPublishTimeToken = status.data.timetoken;
//        [self fulfillSubscribeExpectationAfterDelay:10];
        [self.publishExpectation fulfill];
    }];
    [self.client publish:@"message1" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"bar"} 
              completion:^(PNPublishStatus *status) {
        NSLog(@"status: %@", status.debugDescription);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        secondPublishTimeToken = status.data.timetoken;
        [secondPublishExpectation fulfill];
//        secondPublishExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    self.publishExpectation = nil;
    secondPublishExpectation = nil;
    NSNumber *finalTimeToken = nil;
    if ([firstPublishTimeToken compare:secondPublishTimeToken] == NSOrderedAscending) {
        finalTimeToken = firstPublishTimeToken;
    } else if ([firstPublishTimeToken compare:secondPublishTimeToken] == NSOrderedDescending) {
        finalTimeToken = secondPublishTimeToken;
    } else {
        finalTimeToken = firstPublishTimeToken;
    }
    [self PNTest_subscribeToChannels:@[kPNChannelTestName] withPresence:NO usingTimeToken:finalTimeToken];
}

- (void)testPublishWithDifferentMetadataAndReceiveEachMessagesForSubscribeWithMatchingFilteringChangedBetweenPublishes {
    PNWeakify(self);
    __block NSInteger messageNumber = 0;
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannels.count, 1); // no presence
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        //        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertNotNil(message.data);
        switch (messageNumber) {
            case 0:
            {
                XCTAssertEqualObjects(message.data.message, @"message");
                XCTAssertNil(message.data.actualChannel);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14570385560170716);
            }
                break;
            case 1:
            {
                XCTAssertEqualObjects(message.data.message, @"message1");
                XCTAssertNil(message.data.actualChannel);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14570385561462085);
            }
                break;
            default:
            {
                XCTFail(@"shouldn't be here!. Should only receive two messages.");
            }
                break;
        }
        [self.subscribeExpectation fulfill];
        self.subscribeExpectation = nil;
        messageNumber++;
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    __block NSNumber *firstPublishTimeToken = nil;
    __block NSNumber *secondPublishTimeToken = nil;
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    [self.client subscribeToChannels:@[kPNChannelTestName] withPresence:NO];
    [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"bar"}
              completion:^(PNPublishStatus *status) {
                  NSLog(@"status: %@", status.debugDescription);
                  PNStrongify(self);
                  XCTAssertNotNil(status);
                  XCTAssertFalse(status.isError);
                  XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                  XCTAssertEqual(status.operation, PNPublishOperation);
                  firstPublishTimeToken = status.data.timetoken;
                  // before fulfilling, change the filter
                  
                  [self.publishExpectation fulfill];
              }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    __block XCTestExpectation *secondPublishExpectation = [self expectationWithDescription:@"secondPublishExpectation"];
    [self.client setFilterExpression:@"(foo=='baz')"];
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    [self.client publish:@"message1" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"baz"}
              completion:^(PNPublishStatus *status) {
                  NSLog(@"status: %@", status.debugDescription);
                  XCTAssertNotNil(status);
                  XCTAssertFalse(status.isError);
                  XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                  XCTAssertEqual(status.operation, PNPublishOperation);
                  secondPublishTimeToken = status.data.timetoken;
                  [secondPublishExpectation fulfill];
              }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testPublishWithNoMetadataAndReceivedMessageForSubscribeWithNoFiltering {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = nil;
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14513346572989885;
    self.testData.expectedPublishTimetoken = @14513346572989885;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishWithMetadataAndNoReceivedMessageForSubscribeWithDifferentFiltering {
    self.testData.shouldReceiveMessage = NO;
    self.testData.publishMetadata = @{@"foo":@"bar"};
    self.testData.expectedPublishTimetoken = @14508292456923915;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSameKeyAndDifferentValue {
    self.testData.shouldReceiveMessage = NO;
    self.testData.publishMetadata = @{@"foo":@"bar"};
    self.testData.expectedPublishTimetoken = @14508292569630117;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishWithNoMetadataAndNoReceivedMessageForSubscribeWithFiltering {
    self.testData.shouldReceiveMessage = NO;
    self.testData.publishMetadata = nil;
    self.testData.expectedPublishTimetoken = @14508292796804876;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSwitchedKeysAndValues {
    self.testData.shouldReceiveMessage = NO;
    self.testData.publishMetadata = @{@"foo":@"bar"};
    self.testData.expectedPublishTimetoken = @14508292679788748;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishWithMetadataAndReceiveMessageForSubscribeWithMatchingFiltering {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"foo":@"bar"};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14508292791980402;
    self.testData.expectedPublishTimetoken = @14508292791980402;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

@end