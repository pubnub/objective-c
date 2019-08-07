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

- (void)testEnable_ShouldFallbackToAPNSToken_WhenCalledWithTokenParameter {
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013092";
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
        .enable()
        .channels(@[@"channel1"])
        .token(pushToken)
        .performWithCompletion(^(PNAcknowledgmentStatus *status) {
            NSString *url = status.clientRequest.URL.absoluteString;
            
            XCTAssertFalse(status.isError);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            handler();
        });
    }];
}

- (void)testEnable_ShouldCallWithAPNSToken_WhenCalledExplicitlyWithAPNSTokenParameter {
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013092";
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
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
    }];
}

- (void)testEnable_ShouldCallWithFCMToken_WhenCalledExplicitlyWithFCMTokenParameter {
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013093";
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
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
    }];
}


#pragma mark - Tests :: disable

- (void)testDisable_ShouldFallbackToAPNSToken_WhenCalledWithTokenParameter {
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013092";
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .token(pushToken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                self.client.push()
                    .disable()
                    .token(pushToken)
                    .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                        NSString *url = status.clientRequest.URL.absoluteString;
                        
                        XCTAssertFalse(status.isError);
                        XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
                        handler();
                    });
            });
    }];
}

- (void)testDisable_ShouldCallWithAPNSToken_WhenCalledExplicitlyWithAPNSTokenParameter {
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013092";
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .apnsToken(pushToken)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                self.client.push()
                    .disable()
                    .apnsToken(pushToken)
                    .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                        self.client.push()
                            .audit()
                            .token(pushToken)
                            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                                NSString *url = result.clientRequest.URL.absoluteString;
                                
                                XCTAssertNil(status);
                                XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
                                XCTAssertEqual(result.data.channels.count, 0);
                                handler();
                            });
                    });
            });
    }];
}

- (void)testDisable_ShouldCallWithFCMToken_WhenCalledExplicitlyWithFCMTokenParameter {
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013093";
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[@"channel1"])
            .fcmToken(pushKey)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                self.client.push()
                    .disable()
                    .fcmToken(pushKey)
                    .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                        self.client.push()
                            .audit()
                            .fcmToken(pushKey)
                            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                                NSString *url = result.clientRequest.URL.absoluteString;
                                
                                XCTAssertNil(status);
                                XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
                                XCTAssertEqual(result.data.channels.count, 0);
                                handler();
                            });
                    });
            });
    }];
}


#pragma mark - Tests :: audit

- (void)testAudit_ShouldFallbackToAPNSToken_WhenCalledWithTokenParameter {
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013092";
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .token(pushToken)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            NSString *url = result.clientRequest.URL.absoluteString;
            
            XCTAssertNil(status);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            handler();
        });
    }];
}

- (void)testAudit_ShouldCallWithAPNSToken_WhenCalledExplicitlyWithAPNSTokenParameter {
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013092";
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .audit()
            .apnsToken(pushToken)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                NSString *url = result.clientRequest.URL.absoluteString;
                
                XCTAssertNil(status);
                XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
                handler();
            });
    }];
}

- (void)testAudit_ShouldCallWithFCMToken_WhenCalledExplicitlyWithFCMTokenParameter {
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013093";
    NSString *channel = NSUUID.UUID.UUIDString;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.push()
            .enable()
            .channels(@[channel])
            .fcmToken(pushKey)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                self.client.push()
                    .audit()
                    .fcmToken(pushKey)
                    .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                        NSString *url = result.clientRequest.URL.absoluteString;
                        
                        XCTAssertNil(status);
                        XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
                        XCTAssertTrue([result.data.channels containsObject:channel]);
                        handler();
                    });
            });
    }];
}

#pragma mark -


@end
