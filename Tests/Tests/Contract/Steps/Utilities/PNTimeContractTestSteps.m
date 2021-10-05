/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNTimeContractTestSteps.h"


#pragma mark Interface implementation

@implementation PNTimeContractTestSteps


#pragma mark - Initialization & Configuration

- (void)setup {
    When(@"I request current time", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNTimeOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.time().performWithCompletion(^(PNTimeResult *result, PNErrorStatus *status) {
                [self storeRequestResult:result];
                [self storeRequestStatus:status];
                completion();
            });
        }];
    });
}

#pragma mark -


@end
