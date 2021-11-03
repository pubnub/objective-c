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
    
    When(@"^I fetch message history for (.*) channel(s)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
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
    
    Then(@"the response contains pagination info", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        PNHistoryResult *result = (PNHistoryResult *)[self lastResult];
        XCTAssertNotNil(result.data.start);
        XCTAssertNotNil(result.data.end);
    });
    
    When(@"I fetch message history with message actions", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
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
}

#pragma mark -


@end
