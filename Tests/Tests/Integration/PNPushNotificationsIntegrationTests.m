/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import "NSString+PNTest.h"


#pragma mark Interface declaration

@interface PNPushNotificationsIntegrationTests : PNRecordableTestCase


#pragma mark - Information

/**
 * @brief Target devices environment which has been used for test case.
 */
@property (nonatomic, assign) PNAPNSEnvironment apnsEnvironment;

/**
 * @brief String created from APNS provided device token.
 */
@property (nonatomic, copy) NSString *devicePushTokenString;

/**
 * @brief APNS provided device token.
 */
@property (nonatomic, strong) NSData *devicePushTokenData;

/**
 * @brief Push type which has been used during test case.
 */
@property (nonatomic, assign) PNPushType pushType;

/**
 * @brief Whether APNS over HTTP/2 REST API has been used during test case or not.
 */
@property (nonatomic, assign) BOOL testingV2API;

/**
 * @brief Topic for APNS over HTTP/2 endpoint which should be used in tests.
 */
@property (nonatomic, copy) NSString *apns2Topic;


#pragma mark - Misc

/**
 * @brief Enable notifications for list of channels
 *
 * @param channels List of channels on which notifications should be enabled.
 */
- (void)enabledPushNotificationsForChannels:(NSArray<NSString *> *)channels;

/**
 * @brief Ensure, that push notifications has been enabled on specified \c channels.
 *
 * @param channels List of channels which should be checked.
 */
- (void)verifyEnabledForPushNotificationsChannels:(NSArray<NSString *> *)channels;

/**
 * @brief Clean up after test case has been completed.
 */
- (void)disableAllPushNotificationsOnDevice;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNPushNotificationsIntegrationTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    BOOL shouldSetupVCR = [super shouldSetupVCR];
    
    if (!shouldSetupVCR) {
        NSArray<NSString *> *testNames = @[
            @"ShouldNotAddPushNotificationsAndReceiveBadRequestStatusWhenChannelsIsNil",
            @"ShouldNotAddPushNotificationsUsingV2APIAndReceiveBadRequestStatusWhenChannelsIsNil",
            @"ShouldNotRemovePushNotificationsAndReceiveBadRequestStatusWhenChannelsIsNil",
            @"ShouldNotRemovePushNotificationsUsingV2APIAndReceiveBadRequestStatusWhenChannelsIsNil"
        ];
        
        shouldSetupVCR = [self.name pnt_includesAnyString:testNames];
    }
    
    return shouldSetupVCR;
}

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
    
    self.devicePushTokenString = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013091";
    self.devicePushTokenData = [self.devicePushTokenString pnt_dataFromHex];
    self.apns2Topic = @"com.pubnub.test-topic";
    self.apnsEnvironment = PNAPNSDevelopment;
    self.pushType = PNAPNSPush;
}


#pragma mark - Tests :: add notifications on channels

- (void)testItShouldAddPushNotificationsAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    [self disableAllPushNotificationsOnDevice];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:self.devicePushTokenData
                                      andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:channels];
}

- (void)testItShouldAddPushNotificationsAndNotCrashWhenCompletionBlockIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    [self disableAllPushNotificationsOnDevice];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [self.client addPushNotificationsOnChannels:channels
                                    withDevicePushToken:self.devicePushTokenData
                                          andCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:channels];
}

- (void)testItShouldAddPushNotificationsWithDefaultToAPNSPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:self.devicePushTokenData
                                      andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            
            handler();
        }];
    }];
}

- (void)testItShouldAddPushNotificationsWithFCMPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.pushType = PNFCMPush;
    
    [self disableAllPushNotificationsOnDevice];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:self.devicePushTokenString
                                           pushType:self.pushType
                                      andCompletion:^(PNAcknowledgmentStatus *status) {

            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);

            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:channels];
}

- (void)testItShouldAddPushNotificationsWithMPNSPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.pushType = PNMPNSPush;
    
    [self disableAllPushNotificationsOnDevice];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:self.devicePushTokenString
                                           pushType:self.pushType andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=mpns"].location, NSNotFound);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:channels];
}

- (void)testItShouldNotAddPushNotificationsAndReceiveBadRequestStatusWhenChannelsIsNil {
    NSArray<NSString *> *channels = nil;
    __block BOOL retried = NO;
    
    [self disableAllPushNotificationsOnDevice];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:self.devicePushTokenData
                                      andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[]];
}

- (void)testItShouldNotAddPushNotificationsAndReceiveBadRequestStatusWhenAPNSDevicePushTokenIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSData *devicePushToken = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                                      andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAddPushNotificationsAndReceiveBadRequestStatusWhenAPNSDevicePushTokenIsNotNSData {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSData *devicePushToken = (id)@2010;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                                      andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAddPushNotificationsAndReceiveBadRequestStatusWhenFCMDevicePushTokenIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *devicePushToken = nil;
    self.pushType = PNFCMPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                                           pushType:self.pushType andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAddPushNotificationsAndReceiveBadRequestStatusWhenFCMDevicePushTokenIsNotNSString {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *devicePushToken = (id)@2010;
    self.pushType = PNFCMPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                                           pushType:self.pushType andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAddPushNotificationsAndReceiveBadRequestStatusWhenMPNSDevicePushTokenIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *devicePushToken = nil;
    self.pushType = PNMPNSPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                                           pushType:self.pushType andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAddPushNotificationsAndReceiveBadRequestStatusWhenMPNSDevicePushTokenIsNotNSString {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *devicePushToken = (id)@2010;
    self.pushType = PNMPNSPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                                           pushType:self.pushType andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldAddPushNotificationsUsingV2APIAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    [self disableAllPushNotificationsOnDevice];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:self.devicePushTokenData
                                           pushType:self.pushType environment:self.apnsEnvironment
                                              topic:self.apns2Topic andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsV2Operation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
        
    [self verifyEnabledForPushNotificationsChannels:channels];
}

- (void)testItShouldAddPushNotificationsUsingV2APIAndBundleIdentifierAsDefaultTopicWhenTopicIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.apns2Topic = NSBundle.mainBundle.bundleIdentifier;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    NSString *topic = nil;
    
    [self disableAllPushNotificationsOnDevice];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:self.devicePushTokenData
                                           pushType:self.pushType environment:self.apnsEnvironment
                                              topic:topic andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *topicQuery = [@[@"topic", self.apns2Topic] componentsJoinedByString:@"="];
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"devices-apns2"].location, NSNotFound);
            XCTAssertNotEqual([url rangeOfString:topicQuery].location, NSNotFound);
            
            handler();
        }];
    }];
    
        
    [self verifyEnabledForPushNotificationsChannels:channels];
}

- (void)testItShouldNotAddPushNotificationsUsingV2APIAndReceiveBadRequestStatusWhenChannelsIsNil {
    NSArray<NSString *> *channels = nil;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    [self disableAllPushNotificationsOnDevice];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:self.devicePushTokenData
                                           pushType:self.pushType environment:self.apnsEnvironment
                                              topic:self.apns2Topic andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsV2Operation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
    
        
    [self verifyEnabledForPushNotificationsChannels:@[]];
}

- (void)testItShouldNotAddPushNotificationsUsingV2APIAndReceiveBadRequestStatusWhenDevicePushTokenIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSData *devicePushToken = nil;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client addPushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                                           pushType:self.pushType environment:self.apnsEnvironment
                                              topic:self.apns2Topic andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsV2Operation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based add notifications on channels

- (void)testItShouldShouldAddPushNotificationsUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    self.pushType = PNFCMPush;
    
    [self disableAllPushNotificationsOnDevice];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.push().enable()
            .channels(channels)
            .token(self.devicePushTokenString)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {

                NSString *url = status.clientRequest.URL.absoluteString;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(url);
                XCTAssertEqual(status.operation, PNAddPushNotificationsOnChannelsOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
                
                handler();
            });
    }];
    
        
    [self verifyEnabledForPushNotificationsChannels:channels];
}


#pragma mark - Tests :: remove notifications from channels

- (void)testItShouldRemovePushNotificationsAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:@[channels.firstObject]
                                     withDevicePushToken:self.devicePushTokenData
                                           andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[channels.lastObject]];
}

- (void)testItShouldRemovePushNotificationsAndNotCrashWhenCompletionBlockIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [self.client removePushNotificationsFromChannels:@[channels.firstObject]
                                         withDevicePushToken:self.devicePushTokenData
                                               andCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[channels.lastObject]];
}

- (void)testItShouldRemovePushNotificationsWithDefaultToAPNSPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels withDevicePushToken:self.devicePushTokenData
                                           andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            
            handler();
        }];
    }];
}

- (void)testItShouldRemovePushNotificationsWithFCMPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.pushType = PNFCMPush;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:@[channels.firstObject]
                                     withDevicePushToken:self.devicePushTokenString pushType:self.pushType
                                           andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[channels.lastObject]];
}

- (void)testItShouldRemovePushNotificationsWithMPNSPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.pushType = PNMPNSPush;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:@[channels.firstObject]
                                     withDevicePushToken:self.devicePushTokenString pushType:self.pushType
                                           andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=mpns"].location, NSNotFound);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[channels.lastObject]];
}

- (void)testItShouldNotRemovePushNotificationsAndReceiveBadRequestStatusWhenChannelsIsNil {
    NSArray<NSString *> *channels1 = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSArray<NSString *> *channels2 = nil;
    __block BOOL retried = NO;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels1];
    
    [self verifyEnabledForPushNotificationsChannels:channels1];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels2 withDevicePushToken:self.devicePushTokenData
                                           andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:channels1];
}

- (void)testItShouldNotRemovePushNotificationsAndReceiveBadRequestStatusWhenAPNSDevicePushTokenIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSData *devicePushToken = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels withDevicePushToken:devicePushToken
                                           andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotRemovePushNotificationsAndReceiveBadRequestStatusWhenAPNSDevicePushTokenIsNotNSData {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSData *devicePushToken = (id)@2010;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels withDevicePushToken:devicePushToken
                                           andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotRemovePushNotificationsAndReceiveBadRequestStatusWhenFCMDevicePushTokenIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *devicePushToken = nil;
    self.pushType = PNFCMPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels withDevicePushToken:devicePushToken
                                                pushType:self.pushType andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotRemovePushNotificationsAndReceiveBadRequestStatusWhenFCMDevicePushTokenIsNotNSString {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *devicePushToken = (id)@2010;
    self.pushType = PNFCMPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels withDevicePushToken:devicePushToken
                                                pushType:self.pushType andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotRemovePushNotificationsAndReceiveBadRequestStatusWhenMPNSDevicePushTokenIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *devicePushToken = nil;
    self.pushType = PNMPNSPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels withDevicePushToken:devicePushToken
                                                pushType:self.pushType andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotRemovePushNotificationsAndReceiveBadRequestStatusWhenMPNSDevicePushTokenIsNotNSString {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSString *devicePushToken = (id)@2010;
    self.pushType = PNMPNSPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels withDevicePushToken:devicePushToken
                                                pushType:self.pushType andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldRemovePushNotificationsUsingV2APIAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:@[channels.firstObject]
                                     withDevicePushToken:self.devicePushTokenData
                                                pushType:self.pushType environment:self.apnsEnvironment
                                                   topic:self.apns2Topic andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsV2Operation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[channels.lastObject]];
}

- (void)testItShouldRemovePushNotificationsUsingV2APIAndBundleIdentifierAsDefaultTopicWhenTopicIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.apns2Topic = NSBundle.mainBundle.bundleIdentifier;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    NSString *topic = nil;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:@[channels.firstObject]
                                     withDevicePushToken:self.devicePushTokenData
                                                pushType:self.pushType environment:self.apnsEnvironment
                                                   topic:topic andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *topicQuery = [@[@"topic", self.apns2Topic] componentsJoinedByString:@"="];
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"devices-apns2"].location, NSNotFound);
            XCTAssertNotEqual([url rangeOfString:topicQuery].location, NSNotFound);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[channels.lastObject]];
}

- (void)testItShouldNotRemovePushNotificationsUsingV2APIAndReceiveBadRequestStatusWhenChannelsIsNil {
    NSArray<NSString *> *channels1 = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSArray<NSString *> *channels2 = nil;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels1];
    
    [self verifyEnabledForPushNotificationsChannels:channels1];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels2 withDevicePushToken:self.devicePushTokenData
                                                pushType:self.pushType environment:self.apnsEnvironment
                                                   topic:self.apns2Topic andCompletion:^(PNAcknowledgmentStatus
                                                                                         *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsV2Operation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:channels1];
}

- (void)testItShouldNotRemovePushNotificationsUsingV2APIAndReceiveBadRequestStatusWhenDevicePushTokenIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSData *devicePushToken = nil;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removePushNotificationsFromChannels:channels withDevicePushToken:devicePushToken
                                                pushType:self.pushType environment:self.apnsEnvironment
                                                   topic:self.apns2Topic andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsV2Operation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based remove notifications from channels

- (void)testItShouldRemovePushNotificationsUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    self.pushType = PNFCMPush;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.push().disable()
            .channels(@[channels.firstObject])
            .token(self.devicePushTokenString)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {

                NSString *url = status.clientRequest.URL.absoluteString;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(url);
                XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
                
                handler();
            });
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[channels.lastObject]];
}


#pragma mark - Tests :: remove all notifications for device

- (void)testItShouldRemoveAllPushNotificationsAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushTokenData
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[]];
}

- (void)testItShouldRemoveAllPushNotificationsAndNotCrashWhenCompletionBlockIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushTokenData
                                                             andCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[]];
}

- (void)testItShouldRemoveAllPushNotificationsWithDefaultToAPNSPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushTokenData
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[]];
}

- (void)testItShouldRemoveAllPushNotificationsWithFCMPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.pushType = PNFCMPush;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushTokenString
                                                              pushType:self.pushType
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[]];
}

- (void)testItShouldRemoveAllPushNotificationsWithMPNSPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.pushType = PNMPNSPush;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushTokenString
                                                              pushType:self.pushType
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=mpns"].location, NSNotFound);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[]];
}

- (void)testItShouldNotRemoveAllPushNotificationsAndReceiveBadRequestStatusWhenAPNSDevicePushTokenIsNil {
    NSData *devicePushToken = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:devicePushToken
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}

- (void)testItShouldNotRemoveAllPushNotificationsAndReceiveBadRequestStatusWhenAPNSDevicePushTokenIsNotNSData {
    NSData *devicePushToken = (id)@2010;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:devicePushToken
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotRemoveAllPushNotificationsAndReceiveBadRequestStatusWhenFCMDevicePushTokenIsNil {
    NSString *devicePushToken = nil;
    self.pushType = PNFCMPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:devicePushToken pushType:self.pushType
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotRemoveAllPushNotificationsAndReceiveBadRequestStatusWhenFCMDevicePushTokenIsNotNSString {
    NSString *devicePushToken = (id)@2010;
    self.pushType = PNFCMPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:devicePushToken pushType:self.pushType
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotRemoveAllPushNotificationsAndReceiveBadRequestStatusWhenMPNSDevicePushTokenIsNil {
    NSString *devicePushToken = nil;
    self.pushType = PNMPNSPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:devicePushToken pushType:self.pushType
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotRemoveAllPushNotificationsAndReceiveBadRequestStatusWhenMPNSDevicePushTokenIsNotNSString {
    NSString *devicePushToken = (id)@2010;
    self.pushType = PNMPNSPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:devicePushToken pushType:self.pushType
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldRemoveAllPushNotificationsUsingV2APIAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushTokenData
                                                              pushType:self.pushType environment:self.apnsEnvironment
                                                                 topic:self.apns2Topic
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsV2Operation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[]];
}

- (void)testItShouldRemoveAllPushNotificationsUsingV2APIAndBundleIdentifierAsDefaultTopicWhenTopicIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    self.apns2Topic = NSBundle.mainBundle.bundleIdentifier;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    NSString *topic = nil;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushTokenData
                                                              pushType:self.pushType environment:self.apnsEnvironment
                                                                 topic:topic
                                                         andCompletion:^(PNAcknowledgmentStatus *status) {
            
            NSString *topicQuery = [@[@"topic", self.apns2Topic] componentsJoinedByString:@"="];
            NSString *url = status.clientRequest.URL.absoluteString;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"devices-apns2"].location, NSNotFound);
            XCTAssertNotEqual([url rangeOfString:topicQuery].location, NSNotFound);
            
            handler();
        }];
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[]];
}

- (void)testItShouldNotRemoveAllPushNotificationsUsingV2APIAndReceiveBadRequestStatusWhenDevicePushTokenIsNil {
    NSData *devicePushToken = nil;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client removeAllPushNotificationsFromDeviceWithPushToken:devicePushToken pushType:self.pushType
           environment:self.apnsEnvironment topic:self.apns2Topic andCompletion:^(PNAcknowledgmentStatus *status) {
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsV2Operation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based remove all notifications for device

- (void)testItShouldRemoveAllPushNotificationsUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    self.pushType = PNFCMPush;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    [self verifyEnabledForPushNotificationsChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.push().disableAll()
            .token(self.devicePushTokenString)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {

                NSString *url = status.clientRequest.URL.absoluteString;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(url);
                XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
                
                handler();
            });
    }];
    
    
    [self verifyEnabledForPushNotificationsChannels:@[]];
}


#pragma mark - Tests :: audit notifications

- (void)testItShouldAuditPushNotificationsAndReceiveResultWithExpectedOperation {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *addedChannelsSet = [NSSet setWithArray:channels];
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushTokenData
                             andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannelsSet);
            XCTAssertEqual(result.operation, PNPushNotificationEnabledChannelsOperation);
            XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
            
            handler();
        }];
    }];
}

- (void)testItShouldAuditPushNotificationsWithDefaultToAPNSPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *addedChannelsSet = [NSSet setWithArray:channels];
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushTokenData
                             andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
            NSString *url = result.clientRequest.URL.absoluteString;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannelsSet);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=apns"].location, NSNotFound);
            XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
            
            handler();
        }];
    }];
}

- (void)testItShouldAuditPushNotificationsWithFCMPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *addedChannelsSet = [NSSet setWithArray:channels];
    self.pushType = PNFCMPush;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushTokenString
          pushType:self.pushType andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
            NSString *url = result.clientRequest.URL.absoluteString;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannelsSet);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
            XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
            
            handler();
        }];
    }];
}

- (void)testItShouldAuditPushNotificationsWithMPNSPushType {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *addedChannelsSet = [NSSet setWithArray:channels];
    self.pushType = PNMPNSPush;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushTokenString
          pushType:self.pushType andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
            NSString *url = result.clientRequest.URL.absoluteString;
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannelsSet);
            XCTAssertNotNil(url);
            XCTAssertNotEqual([url rangeOfString:@"type=mpns"].location, NSNotFound);
            XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAuditPushNotificationsAndReceiveBadRequestStatusWhenAPNSDevicePushTokenIsNil {
    NSData *devicePushToken = nil;
    __block BOOL retried = NO;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:devicePushToken
                         andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNPushNotificationEnabledChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
}

- (void)testItShouldNotAuditPushNotificationsAndReceiveBadRequestStatusWhenAPNSDevicePushTokenIsNotNSData {
    NSData *devicePushToken = (id)@2010;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:devicePushToken
                         andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNPushNotificationEnabledChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAuditPushNotificationsAndReceiveBadRequestStatusWhenFCMDevicePushTokenIsNil {
    NSString *devicePushToken = nil;
    self.pushType = PNFCMPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:devicePushToken pushType:self.pushType
                         andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNPushNotificationEnabledChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAuditPushNotificationsAndReceiveBadRequestStatusWhenFCMDevicePushTokenIsNotNSString {
    NSString *devicePushToken = (id)@2010;
    self.pushType = PNFCMPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:devicePushToken pushType:self.pushType
                         andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNPushNotificationEnabledChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAuditPushNotificationsAndReceiveBadRequestStatusWhenMPNSDevicePushTokenIsNil {
    NSString *devicePushToken = nil;
    self.pushType = PNMPNSPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:devicePushToken pushType:self.pushType
                         andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNPushNotificationEnabledChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAuditPushNotificationsAndReceiveBadRequestStatusWhenMPNSDevicePushTokenIsNotNSString {
    NSString *devicePushToken = (id)@2010;
    self.pushType = PNMPNSPush;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:devicePushToken pushType:self.pushType
                         andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNPushNotificationEnabledChannelsOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}

- (void)testItShouldAuditPushNotificationsUsingV2APIAndReceiveResultWithExpectedOperationAndCategory {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *addedChannelsSet = [NSSet setWithArray:channels];
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushTokenData
                                  pushType:self.pushType environment:self.apnsEnvironment topic:self.apns2Topic
                             andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
            XCTAssertNil(status);
            XCTAssertNotNil(result);
            XCTAssertNotNil(fetchedChannelsSet);
            XCTAssertEqual(result.operation, PNPushNotificationEnabledChannelsV2Operation);
            XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
            
            handler();
        }];
    }];
}

- (void)testItShouldAuditPushNotificationsUsingV2APIAndBundleIdentifierAsDefaultTopicWhenTopicIsNil {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *addedChannelsSet = [NSSet setWithArray:channels];
    self.apns2Topic = NSBundle.mainBundle.bundleIdentifier;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    NSString *topic = nil;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushTokenData
                                  pushType:self.pushType environment:self.apnsEnvironment topic:topic
                             andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            NSString *topicQuery = [@[@"topic", self.apns2Topic] componentsJoinedByString:@"="];
            NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
            NSString *url = result.clientRequest.URL.absoluteString;
            XCTAssertNil(status);
            XCTAssertNotNil(url);
            XCTAssertNotNil(fetchedChannelsSet);
            XCTAssertNotEqual([url rangeOfString:@"devices-apns2"].location, NSNotFound);
            XCTAssertNotEqual([url rangeOfString:topicQuery].location, NSNotFound);
            XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotAuditPushNotificationsUsingV2APIAndReceiveBadRequestStatusWhenDevicePushTokenIsNil {
    NSData *devicePushToken = nil;
    self.pushType = PNAPNS2Push;
    self.testingV2API = YES;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:devicePushToken
                                  pushType:self.pushType environment:self.apnsEnvironment topic:self.apns2Topic
                             andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            
            XCTAssertNil(result);
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNPushNotificationEnabledChannelsV2Operation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based audit notifications

- (void)testItShouldShouldAuditPushNotificationsUsingBuilderPatternInterface {
    NSArray<NSString *> *channels = [self channelsWithNames:@[@"test-channel1", @"test-channel2"]];
    NSSet *addedChannelsSet = [NSSet setWithArray:channels];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    self.pushType = PNFCMPush;
    
    [self disableAllPushNotificationsOnDevice];
    [self enabledPushNotificationsForChannels:channels];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.push().audit()
            .token(self.devicePushTokenString)
            .pushType(PNFCMPush)
            .performWithCompletion(^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {

                NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
                NSString *url = result.clientRequest.URL.absoluteString;
                XCTAssertNil(status);
                XCTAssertNotNil(result);
                XCTAssertNotNil(fetchedChannelsSet);
                XCTAssertNotNil(url);
                XCTAssertEqual(result.operation, PNPushNotificationEnabledChannelsOperation);
                XCTAssertNotEqual([url rangeOfString:@"type=gcm"].location, NSNotFound);
                XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
                
                handler();
            });
    }];
}


#pragma mark - Misc

- (void)enabledPushNotificationsForChannels:(NSArray<NSString *> *)channels {
    __block PNPushNotificationsStateModificationCompletionBlock addHandler = nil;
    id token = self.devicePushTokenData;
    
    if (self.pushType != PNAPNSPush && self.pushType != PNAPNS2Push) {
        token = self.devicePushTokenString;
    }
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        addHandler = ^(PNAcknowledgmentStatus *status) {
            XCTAssertFalse(status.isError);
            handler();
        };
        
        if (!self.testingV2API) {
            [self.client addPushNotificationsOnChannels:channels withDevicePushToken:token
                                               pushType:self.pushType andCompletion:addHandler];
        } else {
            [self.client addPushNotificationsOnChannels:channels withDevicePushToken:token
                                               pushType:self.pushType environment:self.apnsEnvironment
                                                  topic:self.apns2Topic andCompletion:addHandler];
        }
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
}

- (void)verifyEnabledForPushNotificationsChannels:(NSArray<NSString *> *)channels {
    __block PNPushNotificationsStateAuditCompletionBlock auditHandler = nil;
    NSSet *addedChannelsSet = [NSSet setWithArray:channels];
    id token = self.devicePushTokenData;
    
    if (self.pushType != PNAPNSPush && self.pushType != PNAPNS2Push) {
        token = self.devicePushTokenString;
    }
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        auditHandler = ^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
            NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannelsSet);
            XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
            
            handler();
        };
        
        if (!self.testingV2API) {
            [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:token pushType:self.pushType
                                                                 andCompletion:auditHandler];
        } else {
            [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:token
                                                                      pushType:self.pushType
                                                                   environment:self.apnsEnvironment
                                                                         topic:self.apns2Topic
                                                                 andCompletion:auditHandler];
        }
    }];
}

- (void)disableAllPushNotificationsOnDevice {
    __block PNPushNotificationsStateModificationCompletionBlock removeHandler = nil;
    id token = self.devicePushTokenData;
    
    if (self.pushType != PNAPNSPush && self.pushType != PNAPNS2Push) {
        token = self.devicePushTokenString;
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        removeHandler = ^(PNAcknowledgmentStatus *status) {
            XCTAssertFalse(status.isError);
            handler();
        };
        
        if (!self.testingV2API) {
            [self.client removeAllPushNotificationsFromDeviceWithPushToken:token pushType:self.pushType
                                                             andCompletion:removeHandler];
        } else {
            [self.client removeAllPushNotificationsFromDeviceWithPushToken:token
                                                                  pushType:self.pushType
                                                               environment:self.apnsEnvironment
                                                                     topic:self.apns2Topic
                                                             andCompletion:removeHandler];
        }
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
