/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNPushContractTestSteps.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface

@interface PNPushContractTestSteps ()


#pragma mark - Helpers

/**
 * @brief Convert string matched from When description to proper push type value.
 *
 * @param match String matched with scenario step name regular expression.
 *
 * @return One of \c PNPushType enum fields corresponding to matched value.
 */
- (PNPushType)pushTypeFromWhenMatch:(NSString *)match;

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPushContractTestSteps


#pragma mark - Initialization & Configuration

- (void)setup {
    [self startCucumberHookEventsListening];
    
    When(@"^I list (.*) push channels(.*)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        PNPushType pushType = [self pushTypeFromWhenMatch:args.firstObject];
        id token = pushType == PNFCMPush ? @"my-token" : [@"my-token" dataUsingEncoding:NSUTF8StringEncoding];
        self.testedFeatureType = PNPushNotificationEnabledChannelsOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            PNAPNSAuditAPICallBuilder *builder = self.client.push().audit()
                .pushType(pushType)
                .token(token);
            
            if (pushType == PNAPNS2Push && [args indexOfObject:@" with topic"] != NSNotFound) {
                self.testedFeatureType = PNPushNotificationEnabledChannelsV2Operation;
                builder.topic(@"com.contract.test");
            }
            
            builder.performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                [self storeRequestResult:result];
                [self storeRequestStatus:status];
                completion();
            });
        }];
    });
    
    When(@"^I add (.*) push channels(.*)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        PNPushType pushType = [self pushTypeFromWhenMatch:args.firstObject];
        id token = pushType == PNFCMPush ? @"my-token" : [@"my-token" dataUsingEncoding:NSUTF8StringEncoding];
        self.testedFeatureType = PNAddPushNotificationsOnChannelsOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            PNAPNSModificationAPICallBuilder *builder = self.client.push().enable()
                .pushType(pushType)
                .token(token)
                .channels(@[@"channel1", @"channel2"]);
            
            if (pushType == PNAPNS2Push && [args indexOfObject:@" with topic"] != NSNotFound) {
                self.testedFeatureType = PNAddPushNotificationsOnChannelsV2Operation;
                builder.topic(@"com.contract.test");
            }
            
            builder.performWithCompletion(^(PNAcknowledgmentStatus *status) {
                [self storeRequestStatus:status];
                completion();
            });
        }];
    });
    
    When(@"^I remove (.*) push channels(.*)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        PNPushType pushType = [self pushTypeFromWhenMatch:args.firstObject];
        id token = pushType == PNFCMPush ? @"my-token" : [@"my-token" dataUsingEncoding:NSUTF8StringEncoding];
        self.testedFeatureType = PNRemovePushNotificationsFromChannelsOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            PNAPNSModificationAPICallBuilder *builder = self.client.push().disable()
                .pushType([self pushTypeFromWhenMatch:args.lastObject])
                .token(token)
                .channels(@[@"channel1", @"channel2"]);
            
            if (pushType == PNAPNS2Push && [args indexOfObject:@" with topic"] != NSNotFound) {
                self.testedFeatureType = PNRemovePushNotificationsFromChannelsV2Operation;
                builder.topic(@"com.contract.test");
            }
            
            builder.performWithCompletion(^(PNAcknowledgmentStatus *status) {
                [self storeRequestStatus:status];
                completion();
            });
        }];
    });
    
    When(@"^I remove (.*) device(.*)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        PNPushType pushType = [self pushTypeFromWhenMatch:args.firstObject];
        id token = pushType == PNFCMPush ? @"my-token" : [@"my-token" dataUsingEncoding:NSUTF8StringEncoding];
        self.testedFeatureType = PNRemoveAllPushNotificationsOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            PNAPNSModificationAPICallBuilder *builder = self.client.push().disableAll()
                .pushType([self pushTypeFromWhenMatch:args.lastObject])
                .token(token);
            
            if (pushType == PNAPNS2Push && [args indexOfObject:@" with topic"] != NSNotFound) {
                self.testedFeatureType = PNRemoveAllPushNotificationsV2Operation;
                builder.topic(@"com.contract.test");
            }
            
            builder.performWithCompletion(^(PNAcknowledgmentStatus *status) {
                [self storeRequestStatus:status];
                completion();
            });
        }];
    });
}


#pragma mark - Helpers

- (PNPushType)pushTypeFromWhenMatch:(NSString *)match {
    PNPushType pushType = [@[@"GCM", @"FCM"] indexOfObject:match] != NSNotFound ? PNFCMPush : PNAPNSPush;
    if (pushType == PNAPNSPush && [match isEqualToString:@"APNS2"]) {
        pushType = PNAPNS2Push;
    }
    
    return pushType;
}

#pragma mark -


@end
