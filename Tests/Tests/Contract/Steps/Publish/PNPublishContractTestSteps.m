/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNPublishContractTestSteps.h"


#pragma mark Interface implementation

@implementation PNPublishContractTestSteps


#pragma mark - Initialization & Configuration

- (void)setup {
    When(@"I publish a message", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNPublishOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.publish()
                .message(@"hello")
                .channel(@"test")
                .performWithCompletion(^(PNPublishStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    When(@"^I publish a message with (.*) metadata$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNPublishOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            id meta = [args.lastObject isEqualToString:@"JSON"] ? @{@"test-user": @"bob"} : @"test-user=bob";
            self.client.publish()
                .message(@"hello")
                .channel(@"test")
                .metadata(meta)
                .performWithCompletion(^(PNPublishStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    When(@"I send a signal", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSignalOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.signal()
                .message(@"hello")
                .channel(@"test")
                .performWithCompletion(^(PNSignalStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
}

#pragma mark -


@end
