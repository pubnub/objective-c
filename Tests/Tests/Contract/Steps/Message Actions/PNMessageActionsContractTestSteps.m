/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNMessageActionsContractTestSteps.h"


#pragma mark Interface implementation

@implementation PNMessageActionsContractTestSteps


#pragma mark - Initialization & Configuration

- (void)setup {
    When(@"I add a message action", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNAddMessageActionOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.addMessageAction()
                .messageTimetoken(@123456789)
                .type(@"test")
                .value(@"contract")
                .channel(@"test")
                .performWithCompletion(^(PNAddMessageActionStatus * _Nonnull status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    When(@"I fetch message actions", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNFetchMessagesActionsOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.fetchMessageActions()
                .channel(@"test")
                .limit(10)
                .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                    [self storeRequestResult:result];
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    When(@"I delete a message action", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNRemoveMessageActionOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.removeMessageAction()
                .messageTimetoken(@123456789)
                .actionTimetoken(@123456799)
                .channel(@"test")
                .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
}

#pragma mark -


@end
