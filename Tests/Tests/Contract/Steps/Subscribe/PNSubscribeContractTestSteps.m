/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNSubscribeContractTestSteps.h"


#pragma mark Interface implementation

@implementation PNSubscribeContractTestSteps


#pragma mark - Initialization & Configuration

- (void)setup {
    [self startCucumberHookEventsListening];
    
    Given(@"the crypto keyset", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.configuration.cipherKey = @"enigma";
    });
    
    Given(@"the invalid-crypto keyset", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.configuration.cipherKey = @"secret";
    });

    When(@"^I subscribe$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSubscribeOperation;

        [self subscribeClient:nil synchronouslyToChannels:@[@"test"] groups:nil withPresence:NO timetoken:nil];

        // Give some time to rotate received timetokens.
        [self pauseMainQueueFor:0.5f];
    });

    When(@"^I subscribe to '(.*)' channel$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSubscribeOperation;
        XCTAssertGreaterThan(args.count, 0);

        [self subscribeClient:nil synchronouslyToChannels:args groups:nil withPresence:NO timetoken:nil];

        // Give some time to rotate received timetokens.
        [self pauseMainQueueFor:0.5f];
    });
    
    Then(@"^I receive (the|[0-9]+) message(s)? in my subscribe response$",
         ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSubscribeOperation;
        XCTAssertGreaterThan(args.count, 0);
        NSUInteger expectedCount = ![args.firstObject isEqual:@"the"] ? args.firstObject.intValue : 1;
        
        NSArray<PNMessageResult *> *messages = [self waitClient:nil
                                     toReceiveSignalsOrMessages:expectedCount
                                                      onChannel:nil];
        XCTAssertNotNil(messages);
        XCTAssertEqual(messages.count, expectedCount);
        if ([self checkInUserInfo:userInfo testingFeature:@"Message encryption"]) {
            XCTAssertEqualObjects(messages.lastObject.data.message, @"hello world");
        } else if ([self checkInUserInfo:userInfo testingFeature:@"Subscribe Loop"]) {
            // Give some time to rotate received timetokens.
            [self pauseMainQueueFor:0.5f];
        }
    });
    
    Then(@"an error is thrown", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSubscribeOperation;
        
        NSArray<PNStatus *> *statuses = [self waitClient:nil toReceiveStatuses:2];
        XCTAssertNotNil(statuses);
        XCTAssertEqual(statuses.lastObject.operation, PNSubscribeOperation);
        XCTAssertEqual(statuses.lastObject.category, PNDecryptionErrorCategory);

        [self pauseMainQueueFor:0.5f];
    });

    Match(@[@"And"], @"^response contains messages with '(.*)' and '(.*)' types$",
          ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertEqual(args.count, 2);

        NSArray *messages = [self waitClient:nil toReceiveSignalsOrMessages:2 onChannel:nil];
        XCTAssertNotNil(messages);
        XCTAssertEqual(messages.count, 2);

        SEL compare = @selector(caseInsensitiveCompare:);
        NSArray *expectedMessageTypes = [args sortedArrayUsingSelector:compare];
        NSArray *receivedMessageTypes = [[messages valueForKeyPath:@"data.type"] sortedArrayUsingSelector:compare];
        XCTAssertEqualObjects(receivedMessageTypes, expectedMessageTypes);
    });

    Match(@[@"And"], @"^response contains messages (with|without) space ids$",
          ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertEqual(args.count, 1);

        NSArray *messages = [self waitClient:nil toReceiveSignalsOrMessages:2 onChannel:nil];
        XCTAssertNotNil(messages);
        XCTAssertEqual(messages.count, 2);

        NSArray *receivedSpaceIds = [messages valueForKeyPath:@"data.spaceId.value"];
        NSMutableArray *filteredReceivedSpaceIds = [NSMutableArray arrayWithArray:receivedSpaceIds];
        [filteredReceivedSpaceIds removeObjectIdenticalTo:[NSNull null]];

        XCTAssertFalse([args.firstObject isEqual:@"with"] && filteredReceivedSpaceIds.count == 0);
        XCTAssertFalse([args.firstObject isEqual:@"without"] && filteredReceivedSpaceIds.count > 0);
        XCTAssertEqual([args.firstObject isEqual:@"with"] ? messages.count : 0, filteredReceivedSpaceIds.count);
    });
}

#pragma mark -


@end
