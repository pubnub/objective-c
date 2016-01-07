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
    return YES;
}

- (PNConfiguration *)overrideClientConfiguration:(PNConfiguration *)configuration {
//    if (self.invocation.selector == @selector(testPublishWithMetadataAndNoReceivedMessageForSubscribeWithDifferentFiltering)) {
//        configuration.filterExpression = @"(a == 'b')";
//    } else if (self.invocation.selector == @selector(testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSameKeyAndDifferentValue)) {
//        configuration.filterExpression = @"(foo == 'b')";
//    } else if (self.invocation.selector == @selector(testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSwitchedKeysAndValues)) {
//        configuration.filterExpression = @"(bar == 'foo')";
//    } else {
//        configuration.filterExpression = @"(foo=='bar')";
//    }
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
    
}

- (void)testPublishAndReceiveMessageWithAttributesArithmetic {
    
}

- (void)testPublishAndReceiveMessageWithMetaArithmetic {
    
}

- (void)testPublishAndReceiveMessageWithDataArithmetic {
    
}

- (void)testPublishAndReceiveMessageWithLargerThanOrEqualMatch {
    
}

- (void)testPublishAndNoReceivedMessageWithSmallerThanMismatch {
    
}

- (void)testPublishAndNoReceivedMessageWithMissingVariableMismatch {
    
}

- (void)testPublishAndReceiveMessageWithExactStringMatch {
    
}

- (void)testPublishAndNoReceivedMessageForStringMismatchWithEqualEquals {
    
}

- (void)testPublishAndReceiveMessageWithStringMatchAgainstListOfMatches {
    
}

- (void)testPublishAndReceiveMessageWithArrayMatchAgainstString {
    
}

- (void)testPublishAndReceiveMessageWithNegatedArrayMismatchAgainstString {
    
}

- (void)testPublishAndNoReceivedMessageForCaseMismatchInArrayMatch {
    
}

- (void)testPublishAndReceiveMessageWithArrayLIKEMatch {
    
}

- (void)testPublishAndReceiveMessageWithSimpleArrayLIKEMatchWithWildcard {
    
}

- (void)testPublishAndReceiveMessageWithArrayLIKEMatchWithWildcardAtEnd {
    
}

- (void)testPublishAndReceiveMessageWithArrayLIKEMatchWithWildcardAtBeginning {
    
}

- (void)testPublishAndReceiveMessageWithArrayLIKEMatchWithWildcardAtBeginningAndEnd {
    
}

//- (void)testPublishWithNoMetadataAndReceivedMessageForSubscribeWithNoFiltering {
//    self.testData.shouldReceiveMessage = YES;
//    self.testData.publishMetadata = nil;
//    self.testData.expectedMessageActualChannel = kPNChannelTestName;
//    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
//    self.testData.expectedMessageRegion = @56;
//    self.testData.expectedMessageTimetoken = @14513346572990987;
//    self.testData.expectedPublishTimetoken = @14513346572989885;
//    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
//}
//
//- (void)testPublishWithMetadataAndNoReceivedMessageForSubscribeWithDifferentFiltering {
//    self.testData.shouldReceiveMessage = NO;
//    self.testData.publishMetadata = @{@"foo":@"bar"};
//    self.testData.expectedPublishTimetoken = @14508292456923915;
//    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
//}
//
//- (void)testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSameKeyAndDifferentValue {
//    self.testData.shouldReceiveMessage = NO;
//    self.testData.publishMetadata = @{@"foo":@"bar"};
//    self.testData.expectedPublishTimetoken = @14508292569630117;
//    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
//}
//
//- (void)testPublishWithNoMetadataAndNoReceivedMessageForSubscribeWithFiltering {
//    self.testData.shouldReceiveMessage = NO;
//    self.testData.publishMetadata = nil;
//    self.testData.expectedPublishTimetoken = @14508292796804876;
//    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
//}
//
//- (void)testPublishWithMetadataAndNoReceivedMessageForSubscribeWithFilteringWithSwitchedKeysAndValues {
//    self.testData.shouldReceiveMessage = NO;
//    self.testData.publishMetadata = @{@"foo":@"bar"};
//    self.testData.expectedPublishTimetoken = @14508292679788748;
//    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
//}
//
//- (void)testPublishWithMetadataAndReceiveMessageForSubscribeWithMatchingFiltering {
//    self.testData.shouldReceiveMessage = YES;
//    self.testData.publishMetadata = @{@"foo":@"bar"};
//    self.testData.expectedMessageActualChannel = kPNChannelTestName;
//    self.testData.expectedMessageSubscribedChannel = kPNChannelTestName;
//    self.testData.expectedMessageRegion = @56;
//    self.testData.expectedMessageTimetoken = @14508292791981634;
//    self.testData.expectedPublishTimetoken = @14508292791980402;
//    [self PNTest_sendAndReceiveMessageWithTestData:self.testData];
//}

@end
