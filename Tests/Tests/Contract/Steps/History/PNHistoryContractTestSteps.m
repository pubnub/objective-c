/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNHistoryContractTestSteps.h"


#pragma mark Interface implementation

@implementation PNHistoryContractTestSteps


#pragma mark - Initialization & Configuration

- (void)setup {
    [self startCucumberHookEventsListening];

    When(@"^I fetch message history for '(.*)' channel$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertEqual(args.count, 1);
        self.testedFeatureType = PNHistoryForChannelsOperation;

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.history()
                .channels(args)
                .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                    [self storeRequestResult:result];
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });

    Match(@[@"And"], @"^history response contains messages (with|without) ('(.*)' and '(.*)' )?message types$",
          ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertGreaterThan(args.count, 0);
        NSString *inclusionFlag = args.firstObject;
        PNHistoryResult *result = (PNHistoryResult *)[self lastResult];
        XCTAssertNotNil(result);

        NSArray *messages = result.data.channels.allValues.firstObject;
        XCTAssertGreaterThan(messages.count, 0);
        NSArray *receivedMessageTypes = [messages valueForKeyPath:@"messageType.value"];
        NSMutableArray *filteredReceivedMessageTypes = [NSMutableArray arrayWithArray:receivedMessageTypes];
        [filteredReceivedMessageTypes removeObjectIdenticalTo:[NSNull null]];

        XCTAssertFalse([inclusionFlag isEqual:@"with"] && filteredReceivedMessageTypes.count == 0);
        XCTAssertFalse([inclusionFlag isEqual:@"without"] && filteredReceivedMessageTypes.count > 0);

        if (args.count > 1) {
            SEL compare = @selector(caseInsensitiveCompare:);
            NSArray *expectedMessageTypes = [[args subarrayWithRange:NSMakeRange(2, 2)] sortedArrayUsingSelector:compare];
            NSArray *receivedMessageTypes = [filteredReceivedMessageTypes sortedArrayUsingSelector:compare];
            XCTAssertEqualObjects(receivedMessageTypes, expectedMessageTypes);
        } else {
            XCTAssertEqual([inclusionFlag isEqual:@"with"] ? messages.count : 0,
                           filteredReceivedMessageTypes.count);
        }
    });

    Match(@[@"And"], @"^history response contains messages (with|without) space ids$",
          ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertGreaterThan(args.count, 0);
        NSString *inclusionFlag = args.firstObject;
        PNHistoryResult *result = (PNHistoryResult *)[self lastResult];
        XCTAssertNotNil(result);

        NSArray *messages = result.data.channels.allValues.firstObject;
        XCTAssertGreaterThan(messages.count, 0);
        NSArray *receivedSpaceIds = [messages valueForKeyPath:@"spaceId.value"];
        NSMutableArray *filteredReceivedSpaceIds = [NSMutableArray arrayWithArray:receivedSpaceIds];
        [filteredReceivedSpaceIds removeObjectIdenticalTo:[NSNull null]];
        
        XCTAssertFalse([inclusionFlag isEqual:@"with"] && filteredReceivedSpaceIds.count == 0);
        XCTAssertFalse([inclusionFlag isEqual:@"without"] && filteredReceivedSpaceIds.count > 0);
        XCTAssertEqual([inclusionFlag isEqual:@"with"] ? messages.count : 0, filteredReceivedSpaceIds.count);
    });
    
    When(@"^I fetch message history for (single|multiple) channel(s)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        NSArray *channels = [args.firstObject isEqualToString:@"multiple"] ? @[@"test1", @"test2"] : @[@"test"];
        self.testedFeatureType = PNHistoryForChannelsOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.history()
                .channels(channels)
                .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                    [self storeRequestResult:result];
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    Then(@"^the response contains pagination info$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        PNHistoryResult *result = (PNHistoryResult *)[self lastResult];
        XCTAssertNotNil(result.data.start);
        XCTAssertNotNil(result.data.end);
    });

    When(@"^I fetch message history with message actions$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNHistoryWithActionsOperation;

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.history()
                .channel(@"test")
                .includeMessageActions(YES)
                .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                    [self storeRequestResult:result];
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });

    When(@"^I fetch message history with '(.*)' set to '(.*)' for '(.*)' channel$",
         ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertEqual(args.count, 3);
        self.testedFeatureType = PNHistoryWithActionsOperation;
        BOOL includeMessageType = YES;
        BOOL includeSpaceId = NO;

        if ([args.firstObject isEqual:@"includeMessageType"]) {
            includeMessageType = [args[1] isEqual:@"true"];
        } else if ([args.firstObject isEqual:@"includeSpaceId"]) {
            includeSpaceId = [args[1] isEqual:@"true"];
        }

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.history()
                .channels(@[args[2]])
                .includeMessageType(includeMessageType)
                .includeSpaceId(includeSpaceId)
                .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                    [self storeRequestResult:result];
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
}

#pragma mark -


@end
