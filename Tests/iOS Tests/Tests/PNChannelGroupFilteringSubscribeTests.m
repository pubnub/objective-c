//
//  PNChannelGroupFilteringSubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/19/15.
//
//

#import "PNBasicSubscribeTestCase.h"

static NSString * const kPNChannelTestName = @"PNFilterSubscribeTests";
static NSString * const kPNOtherTestChannelName = @"PNOtherTestChannelName";
static NSString * const kPNChannelGroupTestName = @"PNChannelGroupFilterSubscribeTests";

@interface PNChannelGroupFilteringSubscribeTests : PNBasicSubscribeTestCase
@property (nonatomic, assign) BOOL hasPublished;
@end

@implementation PNChannelGroupFilteringSubscribeTests

- (BOOL)isRecording{
    return NO;
}

- (PNConfiguration *)overrideClientConfiguration:(PNConfiguration *)configuration {
    if (
        (self.invocation.selector == @selector(testPublishWithNoMetadataAndReceivedMessageForSubscribeWithNoFiltering)) ||
        (self.invocation.selector == @selector(testPublishWithNoMetadataAndReceiveMultipleMessagesForSubscribeWithNoFiltering))
        ) {
        // No filter expression
    } else if (self.invocation.selector == @selector(testPublishWithMetadataAndNoReceivedMessageForSubscribeWithDifferentFiltering)) {
        configuration.filterExpression = @"(a == 'b')";
    } else if (self.invocation.selector == @selector(testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSameKeyAndDifferentValue)) {
        configuration.filterExpression = @"(foo == 'b')";
    } else if (self.invocation.selector == @selector(testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSwitchedKeysAndValues)) {
        configuration.filterExpression = @"(bar == 'foo')";
    } else {
        configuration.filterExpression = @"(foo=='bar')";
    }
    return configuration;
}

- (void)setUp {
    [super setUp];
    self.hasPublished = NO;
    self.subscribeExpectation = nil;
    self.channelGroupSubscribeExpectation = nil;
    self.channelGroupUnsubscribeExpectation = nil;
    // Put setup code here. This method is called before the invocation of each test method in the class.
    PNWeakify(self);
    [self performVerifiedAddChannels:@[kPNChannelTestName, kPNOtherTestChannelName] toGroup:kPNChannelGroupTestName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
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
        //        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        //        XCTAssertEqual(status.category, PNDisconnectedCategory);
        //        /   `/        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        //        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        NSLog(@"tearDown status: %@", status.debugDescription);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        //        XCTAssertEqualObjects(status.currentTimetoken, @14355626738514132);
        //        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.channelGroupUnsubscribeExpectation fulfill];
        self.channelGroupSubscribeExpectation = nil;
        
    };
    [self PNTest_unsubscribeFromChannelGroups:@[kPNChannelGroupTestName] withPresence:NO];
    [super tearDown];
}

- (void)testPublishWithNoMetadataAndReceivedMessageForSubscribeWithNoFiltering {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects(status.subscribedChannelGroups, @[kPNChannelGroupTestName]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        //        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        XCTAssertEqualObjects(status.data.region, @56);
        if (self.hasPublished) {
            return;
        }
        self.hasPublished = YES;
        [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:nil withCompletion:^(PNPublishStatus *status) {
            NSLog(@"status: %@", status.debugDescription);
            [self fulfillSubscribeExpectationAfterDelay:10];
            [self.publishExpectation fulfill];
        }];
        
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
        XCTAssertEqualObjects(message.data.message, @"message");
        XCTAssertEqualObjects(message.data.actualChannel, kPNChannelTestName);
        XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestName);
        XCTAssertEqualObjects(message.data.timetoken, @14513349814152676);
        XCTAssertEqualObjects(message.data.region, @56);
        [self.channelGroupSubscribeExpectation fulfill];
        self.channelGroupSubscribeExpectation = nil;
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    [self PNTest_subscribeToChannelGroups:@[kPNChannelGroupTestName] withPresence:NO];
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
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects(status.subscribedChannelGroups, @[kPNChannelGroupTestName]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        //        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        XCTAssertEqualObjects(status.data.region, @56);
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
                XCTAssertEqualObjects(message.data.actualChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14521907559876325);
                XCTAssertEqualObjects(message.data.region, @56);
            }
                break;
            case 1:
            {
                XCTAssertEqualObjects(message.data.message, @"message1");
                XCTAssertEqualObjects(message.data.actualChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14521907559876325);
                XCTAssertEqualObjects(message.data.region, @56);
                [self.channelGroupSubscribeExpectation fulfill];
                self.channelGroupSubscribeExpectation = nil;
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
    [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:nil withCompletion:^(PNPublishStatus *status) {
        NSLog(@"status: %@", status.debugDescription);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        firstPublishTimeToken = status.data.timetoken;
//        [self fulfillSubscribeExpectationAfterDelay:10];
        [self.publishExpectation fulfill];
    }];
    [self.client publish:@"message1" toChannel:kPNChannelTestName withMetadata:nil withCompletion:^(PNPublishStatus *status) {
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
    [self PNTest_subscribeToChannelGroups:@[kPNChannelGroupTestName] withPresence:NO usingTimeToken:finalTimeToken];
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
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects(status.subscribedChannelGroups, @[kPNChannelGroupTestName]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        //        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        XCTAssertEqualObjects(status.data.region, @56);
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
                XCTAssertEqualObjects(message.data.actualChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14521919904785891);
                XCTAssertEqualObjects(message.data.region, @56);
            }
                break;
            case 1:
            {
                XCTAssertEqualObjects(message.data.message, @"message1");
                XCTAssertEqualObjects(message.data.actualChannel, kPNChannelTestName);
                XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestName);
                XCTAssertEqualObjects(message.data.timetoken, @14521919904785891);
                XCTAssertEqualObjects(message.data.region, @56);
                [self.channelGroupSubscribeExpectation fulfill];
                self.channelGroupSubscribeExpectation = nil;
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
    [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"bar"} withCompletion:^(PNPublishStatus *status) {
        NSLog(@"status: %@", status.debugDescription);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        firstPublishTimeToken = status.data.timetoken;
        //        [self fulfillSubscribeExpectationAfterDelay:10];
        [self.publishExpectation fulfill];
    }];
    [self.client publish:@"message1" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"bar"} withCompletion:^(PNPublishStatus *status) {
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
    [self PNTest_subscribeToChannelGroups:@[kPNChannelGroupTestName] withPresence:NO usingTimeToken:finalTimeToken];
}

- (void)testPublishWithMetadataAndNoReceivedMessageForSubscribeWithDifferentFiltering {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects(status.subscribedChannelGroups, @[kPNChannelGroupTestName]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
//        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        XCTAssertEqualObjects(status.data.region, @56);
        if (self.hasPublished) {
            return;
        }
        self.hasPublished = YES;
        [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"bar"} withCompletion:^(PNPublishStatus *status) {
            NSLog(@"status: %@", status.debugDescription);
            [self fulfillSubscribeExpectationAfterDelay:10];
            [self.publishExpectation fulfill];
        }];
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        NSLog(@"message: %@", message.data.message);
        XCTFail(@"Should not receive a message");
        [self.channelGroupSubscribeExpectation fulfill];
        self.channelGroupSubscribeExpectation = nil;
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    [self PNTest_subscribeToChannelGroups:@[kPNChannelGroupTestName] withPresence:NO];
}

- (void)testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSameKeyAndDifferentValue {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqualObjects(status.subscribedChannelGroups, @[kPNChannelGroupTestName]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
//        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        XCTAssertEqualObjects(status.data.region, @56);
        if (self.hasPublished) {
            return;
        }
        self.hasPublished = YES;
        [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"bar"} withCompletion:^(PNPublishStatus *status) {
            NSLog(@"status: %@", status.debugDescription);
            [self fulfillSubscribeExpectationAfterDelay:10];
            [self.publishExpectation fulfill];
        }];
        
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        NSLog(@"message: %@", message.data.message);
        XCTFail(@"Should not receive a message");
        [self.channelGroupSubscribeExpectation fulfill];
        self.channelGroupSubscribeExpectation = nil;
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    [self PNTest_subscribeToChannelGroups:@[kPNChannelGroupTestName] withPresence:NO];
}

- (void)testPublishWithNoMetadataAndNoReceivedMessageForSubscribeWithFiltering {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqualObjects(status.subscribedChannelGroups, @[kPNChannelGroupTestName]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
//        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        XCTAssertEqualObjects(status.data.region, @56);
        if (self.hasPublished) {
            return;
        }
        self.hasPublished = YES;
        [self.client publish:@"message" toChannel:kPNChannelTestName withCompletion:^(PNPublishStatus *status) {
            NSLog(@"status: %@", status.debugDescription);
            PNStrongify(self);
            [self fulfillSubscribeExpectationAfterDelay:10];
            [self.publishExpectation fulfill];
        }];
        
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        NSLog(@"message: %@", message.data.message);
        XCTFail(@"Should not receive a message");
        [self.channelGroupSubscribeExpectation fulfill];
        self.channelGroupSubscribeExpectation = nil;
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    [self PNTest_subscribeToChannelGroups:@[kPNChannelGroupTestName] withPresence:NO];
}

- (void)testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSwitchedKeysAndValues {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqualObjects(status.subscribedChannelGroups, @[kPNChannelGroupTestName]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
//        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        XCTAssertEqualObjects(status.data.region, @56);
        if (self.hasPublished) {
            return;
        }
        self.hasPublished = YES;
        [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"bar"} withCompletion:^(PNPublishStatus *status) {
            NSLog(@"status: %@", status.debugDescription);
            [self fulfillSubscribeExpectationAfterDelay:10];
            [self.publishExpectation fulfill];
        }];
        
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        NSLog(@"message: %@", message.data.message);
        XCTFail(@"Should not receive a message");
        [self.channelGroupSubscribeExpectation fulfill];
        self.channelGroupSubscribeExpectation = nil;
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    [self PNTest_subscribeToChannelGroups:@[kPNChannelGroupTestName] withPresence:NO];
}

- (void)testPublishWithMetadataAndReceiveMessageForSubscribeWithMatchingFiltering {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqualObjects(status.subscribedChannelGroups, @[kPNChannelGroupTestName]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
//        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        XCTAssertEqualObjects(status.data.region, @56);
        if (self.hasPublished) {
            return;
        }
        self.hasPublished = YES;
        [self.client publish:@"message" toChannel:kPNChannelTestName withMetadata:@{@"foo":@"bar"} withCompletion:^(PNPublishStatus *status) {
            NSLog(@"status: %@", status.debugDescription);
            [self fulfillSubscribeExpectationAfterDelay:10];
            [self.publishExpectation fulfill];
        }];
        
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
        XCTAssertEqualObjects(message.data.message, @"message");
        XCTAssertEqualObjects(message.data.actualChannel, kPNChannelTestName);
        XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestName);
        XCTAssertEqualObjects(message.data.timetoken, @14508303357935433);
        XCTAssertEqualObjects(message.data.region, @56);
        [self.channelGroupSubscribeExpectation fulfill];
        self.channelGroupSubscribeExpectation = nil;
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    [self PNTest_subscribeToChannelGroups:@[kPNChannelGroupTestName] withPresence:NO];
}

@end
