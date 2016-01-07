//
//  PNExtendedFilteringSubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 1/7/16.
//
//

#import "PNBasicSubscribeTestCase.h"

static NSString * const kPNChannelTestName = @"PNExtendedFilteringSubscribeTests";

@interface PNExtendedFilteringSubscribeTests : PNBasicSubscribeTestCase
@property (nonatomic, assign) BOOL hasPublished;
@property (nonatomic, strong) PNSubscribeTestData *testData;
@end

@implementation PNExtendedFilteringSubscribeTests

- (BOOL)isRecording {
    return NO;
}

- (PNConfiguration *)overrideClientConfiguration:(PNConfiguration *)configuration {
    NSString *filterExpression = nil;
    SEL testSelector = self.invocation.selector;
    if (testSelector == @selector(testPublishAndReceiveMessageWithLargerThanOrEqualMatch)) {
        filterExpression = @"(count == 42)";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithAttributesArithmetic)) {
        filterExpression = @"(attributes.var1 + attributes['var2'] == 30)";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithMetaArithmetic)) {
        filterExpression = @"(meta.data.var1 + data['var2'] == 30)";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithDataArithmetic)) {
        filterExpression = @"(data.var1 + data['var2'] == 20)";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithLargerThanOrEqualMatch)) {
        filterExpression = @"(regions.east.count >= 42)";
    } else if (testSelector == @selector(testPublishAndNoReceivedMessageWithSmallerThanMismatch)) {
        filterExpression = @"(regions.east.count < 42)";
    } else if (testSelector == @selector(testPublishAndNoReceivedMessageWithMissingVariableMismatch)) {
        filterExpression = @"(regions.east.volume > 0)";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithExactStringMatch)) {
        filterExpression = @"(region==\"east\")";
    } else if (testSelector == @selector(testPublishAndNoReceivedMessageForStringMismatchWithEqualEquals)) {
        filterExpression = @"(region==\"East\")";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithStringMatchAgainstListOfMatches)) {
        filterExpression = @"(region in (\"east\",\"west\"))";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithArrayMatchAgainstString)) {
        filterExpression = @"(\"east\" in region)";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithNegatedArrayMismatchAgainstString)) {
        filterExpression = @"(!(\"central\" in region))";
    } else if (testSelector == @selector(testPublishAndNoReceivedMessageForCaseMismatchInArrayMatch)) {
        filterExpression = @"(\"East\" in region)";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithArrayLIKEMatch)) {
        filterExpression = @"(region like \"EAST\")";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithSimpleArrayLIKEMatchWithWildcard)) {
        filterExpression = @"(region like \"EAST%\")";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithArrayLIKEMatchWithWildcardAtEnd)) {
        filterExpression = @"(region like \"EAST%\")";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithArrayLIKEMatchWithWildcardAtBeginning)) {
        filterExpression = @"(region like \"%east\")";
    } else if (testSelector == @selector(testPublishAndReceiveMessageWithArrayLIKEMatchWithWildcardAtBeginningAndEnd)) {
        filterExpression = @"(region like \"%est%\")";
    }
    configuration.filterExpression = filterExpression;
    return configuration;
}

- (void)setUp {
    [super setUp];
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

- (void)testPublishAndReceiveMessageWithExactNumberMatch {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"count": @42};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14522085423440590;
    self.testData.expectedPublishTimetoken = @14522085423439474;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithAttributesArithmetic {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"attributes": @{@"var1": @10, @"var2": @20}};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14522085304764375;
    self.testData.expectedPublishTimetoken = @14522085304763137;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithMetaArithmetic {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"data": @{@"var1": @10, @"var2": @20}};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14522085560102059;
    self.testData.expectedPublishTimetoken = @14522085560100894;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

#warning this is off
- (void)testPublishAndReceiveMessageWithDataArithmetic {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"regions": @{@"east": @{@"count": @42, @"other": @"something"}}};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14513346572990987;
    self.testData.expectedPublishTimetoken = @14513346572989885;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

#warning this is off
- (void)testPublishAndReceiveMessageWithLargerThanOrEqualMatch {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"regions":@{@"east":@{@"count":@42, @"other":@"something"}}};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @0;
    self.testData.expectedPublishTimetoken = @14522085447346767;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndNoReceivedMessageWithSmallerThanMismatch {
    self.testData.shouldReceiveMessage = NO;
    self.testData.publishMetadata = @{@"regions":@{@"east":@{@"count":@42, @"other":@"something"}}};
    self.testData.expectedPublishTimetoken = @14522085447346767;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndNoReceivedMessageWithMissingVariableMismatch {
    self.testData.shouldReceiveMessage = NO;
    self.testData.publishMetadata = @{@"regions":@{@"east":@{@"count":@42, @"other":@"something"}}};
    self.testData.expectedPublishTimetoken = @14522085025672043;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithExactStringMatch {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"region":@"east"};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14522085436379716;
    self.testData.expectedPublishTimetoken = @14522085436379014;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndNoReceivedMessageForStringMismatchWithEqualEquals {
    self.testData.shouldReceiveMessage = NO;
    self.testData.publishMetadata = @{@"region":@"east"};
    self.testData.expectedPublishTimetoken = @14522084909706151;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithStringMatchAgainstListOfMatches {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"region": @"east"};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14522085580062097;
    self.testData.expectedPublishTimetoken = @14522085580061368;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithArrayMatchAgainstString {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"region": @[@"east", @"west"]};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14522085299628133;
    self.testData.expectedPublishTimetoken = @14522085299627093;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithNegatedArrayMismatchAgainstString {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"region": @[@"east", @"west"]};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14522085568169168;
    self.testData.expectedPublishTimetoken = @14522085568168488;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndNoReceivedMessageForCaseMismatchInArrayMatch {
    self.testData.shouldReceiveMessage = NO;
    self.testData.publishMetadata = @{@"region": @[@"east", @"west"]};
    self.testData.expectedPublishTimetoken = @14522084788222407;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithArrayLIKEMatch {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"region": @[@"east", @"west"]};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14522085256027013;
    self.testData.expectedPublishTimetoken = @14522085256026292;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithSimpleArrayLIKEMatchWithWildcard {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"region": @[@"east", @"west"]};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14513346572990987;
    self.testData.expectedPublishTimetoken = @14513346572989885;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithArrayLIKEMatchWithWildcardAtEnd {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"region": @[@"east coast", @"west coast"]};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14513346572990987;
    self.testData.expectedPublishTimetoken = @14513346572989885;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithArrayLIKEMatchWithWildcardAtBeginning {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"region": @[@"north east", @"west"]};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14513346572990987;
    self.testData.expectedPublishTimetoken = @14513346572989885;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

- (void)testPublishAndReceiveMessageWithArrayLIKEMatchWithWildcardAtBeginningAndEnd {
    self.testData.shouldReceiveMessage = YES;
    self.testData.publishMetadata = @{@"region": @[@"east coast", @"west coast"]};
    self.testData.expectedMessageActualChannel = kPNChannelTestName;
    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
    self.testData.expectedMessageRegion = @56;
    self.testData.expectedMessageTimetoken = @14513346572990987;
    self.testData.expectedPublishTimetoken = @14513346572989885;
    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
}

@end
