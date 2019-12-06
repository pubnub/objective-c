/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSString+PNTest.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>
#import "PNTestCase.h"


#pragma mark Test interface declaration

@interface PNAPNSIntegrationTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;


#pragma mark - Misc

/**
 * @brief Generate random string which can be used as device push token.
 */
- (NSString *)randomTokenString;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNAPNSIntegrationTest

#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}


#pragma mark - Tests :: enable

- (void)testEnable_ShouldFallbackToTokenAndPushType_WhenCalledWithAPNSTokenParameter {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.client.push()
        .enable()
        .channels(@[@"channel1"])
        .apnsToken(pushToken)
        .performWithCompletion(^(PNAcknowledgmentStatus *status) {
            NSString *url = status.clientRequest.URL.absoluteString;
            
            XCTAssertFalse(status.isError);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            handler();
        });
#pragma clang diagnostic pop
    }];
}

- (void)testEnable_ShouldFallbackToTokenAndPushType_WhenCalledWithFCMTokenParameter {
    NSString *pushKey = [self randomTokenString];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.client.push()
        .enable()
        .channels(@[@"channel1"])
        .fcmToken(pushKey)
        .performWithCompletion(^(PNAcknowledgmentStatus *status) {
            NSString *url = status.clientRequest.URL.absoluteString;
            
            XCTAssertFalse(status.isError);
            XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
            handler();
        });
#pragma clang diagnostic pop
    }];
}

- (void)testEnable_ShouldCallWithAPNSToken_WhenCalledExplicitlyWithAPNSPushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
        .enable()
        .channels(@[@"channel1"])
        .token(pushToken)
        .pushType(PNAPNSPush)
        .performWithCompletion(^(PNAcknowledgmentStatus *status) {
            NSString *url = status.clientRequest.URL.absoluteString;
            
            XCTAssertFalse(status.isError);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            handler();
        });
    }];
}

- (void)testEnable_ShouldCallWithAPNS2Token_WhenCalledExplicitlyWithAPNS2PushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
        .enable()
        .channels(@[@"channel1"])
        .token(pushToken)
        .pushType(PNAPNS2Push)
        .performWithCompletion(^(PNAcknowledgmentStatus *status) {
            NSString *url = status.clientRequest.URL.absoluteString;
            
            XCTAssertFalse(status.isError);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            XCTAssertNotEqual([url rangeOfString:@"devices-apns2"].location, NSNotFound);
            handler();
        });
    }];
}

- (void)testEnable_ShouldCallWithFCMToken_WhenCalledExplicitlyWithFCMPushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
        .enable()
        .channels(@[@"channel1"])
        .token(pushKey)
        .pushType(PNFCMPush)
        .performWithCompletion(^(PNAcknowledgmentStatus *status) {
            NSString *url = status.clientRequest.URL.absoluteString;
            
            XCTAssertFalse(status.isError);
            XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
            handler();
        });
    }];
}

- (void)testEnable_ShouldCallWithMPNSToken_WhenCalledExplicitlyWithMPNSPushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
        .enable()
        .channels(@[@"channel1"])
        .token(pushKey)
        .pushType(PNMPNSPush)
        .performWithCompletion(^(PNAcknowledgmentStatus *status) {
            NSString *url = status.clientRequest.URL.absoluteString;
            
            XCTAssertFalse(status.isError);
            XCTAssertNotEqual([url rangeOfString:@"type=mpns"].location, NSNotFound);
            handler();
        });
    }];
}

- (void)testEnable_ShouldFailCallAPNS_WhenCalledWithEmptyToken {
    NSData *pushToken = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testEnable_ShouldFailCallAPNS_WhenCalledWithNonNSDataToken {
    NSData *pushToken = (id)@"";
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testEnable_ShouldFailCallFCM_WhenCalledWithEmptyToken {
    NSString *pushToken = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testEnable_ShouldFailCallFCM_WhenCalledWithNonNSStringToken {
    NSString *pushToken = (id)@2010;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testEnable_ShouldFailCallMPNS_WhenCalledWithEmptyToken {
    NSString *pushToken = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"PNMPNSPush"])
            .token(pushToken)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testEnable_ShouldFailCallMPNS_WhenCalledWithNonNSStringToken {
    NSString *pushToken = (id)@2010;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNMPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}


#pragma mark - Tests :: disable

- (void)testDisable_ShouldFallbackToTokenAndPushType_WhenCalledWithAPNSTokenParameter {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .apnsToken(pushToken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disable()
            .channels(@[@"channel1"])
            .apnsToken(pushToken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                NSString *url = status.clientRequest.URL.absoluteString;
                
                XCTAssertFalse(status.isError);
                XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
                handler();
            });
    }];
#pragma clang diagnostic pop
}

- (void)testDisable_ShouldFallbackToTokenAndPushType_WhenCalledWithFCMTokenParameter {
    NSString *pushKey = [self randomTokenString];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .fcmToken(pushKey)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disable()
            .channels(@[@"channel1"])
            .fcmToken(pushKey)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                NSString *url = status.clientRequest.URL.absoluteString;
                
                XCTAssertFalse(status.isError);
                XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
                handler();
            });
    }];
#pragma clang diagnostic pop
}

- (void)testDisable_ShouldCallWithAPNSToken_WhenCalledExplicitlyWithAPNSPushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];

    [self waitTask:@"pushNotificationEnable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disableAll()
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];
    
    [self waitTask:@"pushNotificationDisable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                NSString *url = result.clientRequest.URL.absoluteString;
                
                XCTAssertNil(status);
                XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
                XCTAssertEqual(result.data.channels.count, 0);
                handler();
            });
    }];
}

- (void)testDisable_ShouldCallWithAPNS2Token_WhenCalledExplicitlyWithAPNS2PushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNAPNS2Push)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];
    
    [self waitTask:@"pushNotificationEnable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disableAll()
            .token(pushToken)
            .pushType(PNAPNS2Push)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];
    
    [self waitTask:@"pushNotificationDisable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNAPNS2Push)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                NSString *url = result.clientRequest.URL.absoluteString;
                
                XCTAssertNil(status);
                XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
                XCTAssertNotEqual([url rangeOfString:@"devices-apns2"].location, NSNotFound);
                XCTAssertEqual(result.data.channels.count, 0);
                handler();
            });
    }];
}

- (void)testDisable_ShouldCallWithFCMToken_WhenCalledExplicitlyWithFCMPushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushKey)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];

    [self waitTask:@"pushNotificationEnable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disableAll()
            .token(pushKey)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];
    
    [self waitTask:@"pushNotificationDisable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushKey)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                NSString *url = result.clientRequest.URL.absoluteString;
                
                XCTAssertNil(status);
                XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
                XCTAssertEqual(result.data.channels.count, 0);
                handler();
            });
    }];
}

- (void)testDisable_ShouldCallWithMPNSToken_WhenCalledExplicitlyWithMPNSPushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushKey)
            .pushType(PNMPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];

    [self waitTask:@"pushNotificationEnable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disableAll()
            .token(pushKey)
            .pushType(PNMPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];
    
    [self waitTask:@"pushNotificationDisable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushKey)
            .pushType(PNMPNSPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                NSString *url = result.clientRequest.URL.absoluteString;
                
                XCTAssertNil(status);
                XCTAssertNotEqual([url rangeOfString:@"type=mpns"].location, NSNotFound);
                XCTAssertEqual(result.data.channels.count, 0);
                handler();
            });
    }];
}

- (void)testDisable_ShouldFailCall_WhenCalledWithEmptyChannelsList {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disable()
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testDisable_ShouldFailCallAPNS_WhenCalledWithEmptyToken {
    NSData *pushToken = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testDisable_ShouldFailCallAPNS_WhenCalledWithNonNSDataToken {
    NSData *pushToken = (id)@"";
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testDisable_ShouldFailCallFCM_WhenCalledWithEmptyToken {
    NSString *pushToken = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testDisable_ShouldFailCallFCM_WhenCalledWithNonNSStringToken {
    NSString *pushToken = (id)@2010;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testDisable_ShouldFailCallMPNS_WhenCalledWithEmptyToken {
    NSString *pushToken = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disable()
            .channels(@[@"PNMPNSPush"])
            .token(pushToken)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testDisable_ShouldFailCallMPNS_WhenCalledWithNonNSStringToken {
    NSString *pushToken = (id)@2010;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .disable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .pushType(PNMPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}


#pragma mark - Tests :: audit

- (void)testAudit_ShouldFallbackToTokenAndPushType_WhenCalledWithAPNSTokenParameter {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.client.push()
            .audit()
            .apnsToken(pushToken)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            NSString *url = result.clientRequest.URL.absoluteString;
            
            XCTAssertNil(status);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            handler();
        });
#pragma clang diagnostic pop
    }];
}

- (void)testAudit_ShouldFallbackToTokenAndPushType_WhenCalledWithFCMTokenParameter {
    NSString *pushKey = [self randomTokenString];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.client.push()
            .audit()
            .fcmToken(pushKey)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            NSString *url = result.clientRequest.URL.absoluteString;
            
            XCTAssertNil(status);
            XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
            handler();
        });
#pragma clang diagnostic pop
    }];
}

- (void)testAudit_ShouldCallWithAPNSToken_WhenCalledExplicitlyWithAPNSPushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                NSString *url = result.clientRequest.URL.absoluteString;
                
                XCTAssertNil(status);
                XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
                handler();
            });
    }];
}

- (void)testAudit_ShouldCallWithAPNS2Token_WhenCalledExplicitlyWithAPNS2PushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNAPNS2Push)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                NSString *url = result.clientRequest.URL.absoluteString;
                
                XCTAssertNil(status);
                XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
                XCTAssertNotEqual([url rangeOfString:@"devices-apns2"].location, NSNotFound);
                handler();
            });
    }];
}

- (void)testAudit_ShouldCallWithFCMToken_WhenCalledExplicitlyWithFCMPushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    NSString *channel = NSUUID.UUID.UUIDString;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[channel])
            .token(pushKey)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];

    [self waitTask:@"pushNotificationEnable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushKey)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                NSString *url = result.clientRequest.URL.absoluteString;
                
                XCTAssertNil(status);
                XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
                XCTAssertTrue([result.data.channels containsObject:channel]);
                handler();
            });
    }];
}

- (void)testAudit_ShouldCallWithMPNSToken_WhenCalledExplicitlyWithMPNSPushTypeParameter {
    NSString *pushKey = [self randomTokenString];
    NSString *channel = NSUUID.UUID.UUIDString;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[channel])
            .token(pushKey)
            .pushType(PNMPNSPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
    }];

    [self waitTask:@"pushNotificationEnable" completionFor:0.5f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushKey)
            .pushType(PNMPNSPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                NSString *url = result.clientRequest.URL.absoluteString;
                
                XCTAssertNil(status);
                XCTAssertNotEqual([url rangeOfString:@"type=mpns"].location, NSNotFound);
                XCTAssertTrue([result.data.channels containsObject:channel]);
                handler();
            });
    }];
}

- (void)testAudit_ShouldFailCallAPNS_WhenCalledWithEmptyToken {
    NSData *pushToken = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testAudit_ShouldFailCallAPNS_WhenCalledWithNonNSDataToken {
    NSData *pushToken = (id)@"";
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNAPNSPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testAudit_ShouldFailCallFCM_WhenCalledWithEmptyToken {
    NSString *pushToken = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testAudit_ShouldFailCallFCM_WhenCalledWithNonNSStringToken {
    NSString *pushToken = (id)@2010;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testAudit_ShouldFailCallMPNS_WhenCalledWithEmptyToken {
    NSString *pushToken = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}

- (void)testAudit_ShouldFailCallMPNS_WhenCalledWithNonNSStringToken {
    NSString *pushToken = (id)@2010;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .pushType(PNMPNSPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}


#pragma mark - Misc

- (NSString *)randomTokenString {
    NSString *uuidString = [@[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString] componentsJoinedByString:@""];
    
    return [[uuidString componentsSeparatedByString:@"-"] componentsJoinedByString:@""].lowercaseString;
}

#pragma mark -


@end
