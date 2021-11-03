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
    
    When(@"I subscribe", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSubscribeOperation;
        
        [self subscribeClient:nil synchronouslyToChannels:@[@"test"] groups:nil withPresence:NO timetoken:nil];
        
        // Give some time to rotate received timetokens.
        [self pauseMainQueueFor:0.5f];
    });
    
    Then(@"I receive the message in my subscribe response", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSubscribeOperation;
        
        NSArray<PNMessageResult *> *messages = [self waitClient:nil toReceiveMessages:1 onChannel:nil];
        XCTAssertNotNil(messages);
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
}

#pragma mark -


@end
