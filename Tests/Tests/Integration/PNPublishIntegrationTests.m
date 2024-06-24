/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/PNDefines.h>
#import "NSString+PNTest.h"


#pragma mark Interface declaration

@interface PNPublishIntegrationTests : PNRecordableTestCase


#pragma mark - Information

/**
 * @brief Message encryption / decryption key.
 */
@property (nonatomic, copy) NSString *cipherKey;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNPublishIntegrationTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    BOOL shouldSetupVCR = [super shouldSetupVCR];
    
    if ([self.name pnt_includesString:@"Size"] || [self.name pnt_includesString:@"RandomIV"]) {
        shouldSetupVCR = NO;
    }
    
    return shouldSetupVCR;
}

#pragma mark - Setup / Tear down

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    configuration.useRandomInitializationVector = [self.name rangeOfString:@"RandomIV"].location != NSNotFound;
    
    if ([self.name pnt_includesString:@"Encrypt"]) {
        configuration.cipherKey = self.cipherKey;
    }
#pragma clang diagnostic pop

    return configuration;
}

- (void)setUp {
    [super setUp];
    
    self.cipherKey = @"enigma";
}


#pragma mark - Tests :: Regular publish

- (void)testItShouldPublishWithRequestAndReceivePublishTimetokenWhenDefaultsUsed {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertEqual(status.statusCode, 200);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishWithRequestAndReceivePublishTimetokenWhenReplicationDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        request.replicate = NO;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertEqual(status.statusCode, 200);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishWithRequestAndReceivePublishTimetokenWhenStoreDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        request.store = NO;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertEqual(status.statusCode, 200);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishAndReceivePublishTimetoken {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertEqual(status.statusCode, 200);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNPublishOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishAndNotCrashWhenCompletionBlockIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [client publish:expectedMessage toChannel:channel withCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldNotPublishAndReceiveBadRequestStatusWhenMessageIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotNil(status.errorData.information);
            XCTAssertEqual(status.operation, PNPublishOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldNotPublishAndReceiveBadRequestStatusWhenChannelIsNil {
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    NSString *channel = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotNil(status.errorData.information);
            XCTAssertEqual(status.operation, PNPublishOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertEqual(status.statusCode, 400);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishWithTTL {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.publish()
            .message(expectedMessage)
            .channel(channel)
            .ttl(120)
            .performWithCompletion(^(PNPublishStatus *status) {
                NSString *url = status.clientRequest.URL.absoluteString;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(url);
                XCTAssertTrue([url pnt_includesString:@"ttl=120"]);
                
                handler();
            });
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishWithOutTTLWhenStoreInHistoryDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.publish()
            .message(expectedMessage)
            .channel(channel)
            .ttl(120)
            .shouldStore(NO)
            .performWithCompletion(^(PNPublishStatus *status) {
                NSString *url = status.clientRequest.URL.absoluteString;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(url);
                XCTAssertTrue([url pnt_includesString:@"store=0"]);
                XCTAssertFalse([url pnt_includesString:@"ttl=120"]);
                
                handler();
            });
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishWithNoReplicationPolicy {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.publish()
            .message(expectedMessage)
            .channel(channel)
            .replicate(NO)
            .performWithCompletion(^(PNPublishStatus *status) {
                NSString *url = status.clientRequest.URL.absoluteString;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(url);
                XCTAssertTrue([url pnt_includesString:@"norep=true"]);
                
                handler();
            });
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishNSString {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSString *expectedMessage = @"Hello there";
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSNumber {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSNumber *expectedMessage = @2010;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSDictionary {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *expectedMessage = @{ @"hello": @"there" };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSDictionaryWithNestedCollections {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *expectedMessage = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSArray {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray *expectedMessage = @[@"hello", @"there"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSArrayWithNestedCollections {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray *expectedMessage = @[@"hello", @[@"there", @{ @"general": @"kenobi" }]];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublish1000CharactersLongNSString {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:1000];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        XCTAssertEqual(expectedMessage.length, 1000);
        [client1 publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublish10000CharactersLongNSString {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:10000];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        XCTAssertEqual(expectedMessage.length, 10000);
        [client1 publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldNotPublishTooLongPublishMessage {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:100000];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    __block BOOL retried = NO;


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        XCTAssertEqual(expectedMessage.length, 100000);
        
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.statusCode, 414);
            XCTAssertNotNil(status.errorData.information);
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
#pragma clang diagnostic pop

    XCTAssertTrue(retried);
}

- (void)testItShouldPublishStringWithSpecialSymbols {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSString *expectedMessage = @"!@#$%^&*()_+|";
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark - Tests :: Publish with encryption

- (void)testItShouldPublishEncryptedMessage {
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *expectedMessage = @"xY6oQ3eZMfoY03b6UtjUih+3u63/VZQCcB1o3wavdJc+nabYNOLmZYdz2vuEEPup";
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    
    // Reset cipher key, so second subscriber will receive raw encrypted data.
    self.cipherKey = nil;
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *receivedMessage, BOOL *shouldRemove) {
            XCTAssertEqualObjects(receivedMessage.data.publisher, client1.currentConfiguration.userID);
            XCTAssertNotEqualObjects(receivedMessage.data.message, message);
            XCTAssertTrue([receivedMessage.data.message isKindOfClass:[NSString class]]);
            XCTAssertEqualObjects(receivedMessage.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishEncryptedMessageRandomIV {
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *notExpectedMessage = @"xY6oQ3eZMfoY03b6UtjUih+3u63/VZQCcB1o3wavdJc+nabYNOLmZYdz2vuEEPup";
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    
    // Reset cipher key, so second subscriber will receive raw encrypted data.
    self.cipherKey = nil;
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertTrue(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertTrue(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *receivedMessage, BOOL *shouldRemove) {
            XCTAssertEqualObjects(receivedMessage.data.publisher, client1.currentConfiguration.userID);
            XCTAssertNotEqualObjects(receivedMessage.data.message, message);
            XCTAssertTrue([receivedMessage.data.message isKindOfClass:[NSString class]]);
            XCTAssertNotEqualObjects(receivedMessage.data.message, notExpectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark - Tests :: Publish with metadata

- (void)testItShouldPublishWithFilterMetadata {
    NSDictionary *expectedMetadata = @{ @"access-level": @"editor" };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSString *expectedMessage = @"Hello there";
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            XCTAssertEqualObjects(message.data.userMetadata, expectedMetadata);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:expectedMessage toChannel:channel withMetadata:expectedMetadata
              completion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark - Tests :: Publish with storage option

- (void)testItShouldPublishAndFetchMessageFromHistory {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForStorage" completionFor:(YHVVCR.cassette.isNewCassette ? 6.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqual(result.data.messages.count, 1);
            XCTAssertEqualObjects(result.data.messages.firstObject, expectedMessage);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishAndFetchEmptyHistoryWhenStoreInHistoryDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel storeInHistory:NO
         withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForStorage" completionFor:(YHVVCR.cassette.isNewCassette ? 6.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqual(result.data.messages.count, 0);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}


#pragma mark - Tests :: Publish with mobile payloads

- (void)testItShouldPublishMobilePayloadWithWrappedKeys {
    NSDictionary *mobilePayload = @{
        @"apns": @{ @"aps": @{ @"alert": @"Hello there" } },
        @"gcm": @{ @"data": @{ @"hello": @"there" } }
    };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSString *message = @"Hello there";
    NSDictionary *expectedMessage = @{
        @"pn_other": message,
        @"pn_apns": mobilePayload[@"apns"],
        @"pn_gcm": mobilePayload[@"gcm"]
    };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel mobilePushPayload:mobilePayload
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishMobilePayloadWithWrappedAPSKey {
    NSDictionary *mobilePayload = @{ @"aps": @{ @"alert": @"Hello there" } };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSString *message = @"Hello there";
    NSDictionary *expectedMessage = @{ @"pn_other": message, @"pn_apns": mobilePayload };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel mobilePushPayload:mobilePayload
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSStringWithMobilePayload {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSString *message = @"Hello there";
    NSDictionary *expectedMessage = @{ @"pn_other": message, @"pn_apns": mobilePayload[@"apns"] };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel mobilePushPayload:mobilePayload
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSNumberWithMobilePayload {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSNumber *message = @2010;
    NSDictionary *expectedMessage = @{ @"pn_other": message, @"pn_apns": mobilePayload[@"apns"] };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel mobilePushPayload:mobilePayload
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSArrayWithMobilePayload {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray *message = @[@"hello", @[@"there", @{ @"general": @"kenobi" }]];
    NSDictionary *expectedMessage = @{ @"pn_other": message, @"pn_apns": mobilePayload[@"apns"] };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel mobilePushPayload:mobilePayload
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSDictionaryWithMobilePayload {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSMutableDictionary *expectedMessage = [@{ @"pn_apns": mobilePayload[@"apns"] } mutableCopy];
    [expectedMessage addEntriesFromDictionary:message];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel mobilePushPayload:mobilePayload
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishEncryptedMessageWithNotEncryptedMobilePayload {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    NSDictionary *expectedMessage = @{
        @"pn_apns": mobilePayload[@"apns"],
        @"pn_other": @"\"xY6oQ3eZMfoY03b6UtjUih+3u63/VZQCcB1o3wavdJc+nabYNOLmZYdz2vuEEPup\""
    };
    
    // Reset cipher key, so second subscriber will receive raw encrypted data.
    self.cipherKey = nil;
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel mobilePushPayload:mobilePayload
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishEncryptedMessageWithNotEncryptedMobilePayloadRandomIV {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    NSDictionary *notExpectedMessage = @{
        @"pn_apns": mobilePayload[@"apns"],
        @"pn_other": @"\"xY6oQ3eZMfoY03b6UtjUih+3u63/VZQCcB1o3wavdJc+nabYNOLmZYdz2vuEEPup\""
    };
    
    // Reset cipher key, so second subscriber will receive raw encrypted data.
    self.cipherKey = nil;
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertTrue(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertTrue(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertNotEqualObjects(message.data.message, notExpectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel mobilePushPayload:mobilePayload
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishCompressedMessageWithMobilePayload {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSMutableDictionary *expectedMessage = [@{ @"pn_apns": mobilePayload[@"apns"] } mutableCopy];
    [expectedMessage addEntriesFromDictionary:message];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:message toChannel:channel mobilePushPayload:mobilePayload compressed:YES
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishMessageWithMobilePayloadAndFetchEmptyHistoryWhenStoreInHistoryDisabled {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:message toChannel:channel mobilePushPayload:mobilePayload storeInHistory:NO
         withCompletion:^(PNPublishStatus *status) {
            
             XCTAssertFalse(status.isError);
             handler();
        }];
    }];
    
    [self waitTask:@"waitForStorage" completionFor:(YHVVCR.cassette.isNewCassette ? 6.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqual(result.data.messages.count, 0);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishCompressedMessageWithMobilePayloadAndFetchMessageFromHistory {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSMutableDictionary *expectedMessage = [@{ @"pn_apns": mobilePayload[@"apns"] } mutableCopy];
    [expectedMessage addEntriesFromDictionary:message];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:message toChannel:channel mobilePushPayload:mobilePayload storeInHistory:YES
             compressed:YES withCompletion:^(PNPublishStatus *status) {
            
             XCTAssertFalse(status.isError);
             handler();
        }];
    }];
    
    [self waitTask:@"waitForStorage" completionFor:(YHVVCR.cassette.isNewCassette ? 6.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqual(result.data.messages.count, 1);
            XCTAssertEqualObjects(result.data.messages.firstObject, expectedMessage);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishOnlyWithMobilePayload {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSDictionary *expectedMessage = @{ @"pn_apns": mobilePayload[@"apns"] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 publish:nil toChannel:channel mobilePushPayload:mobilePayload
          withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

#pragma mark - Tests :: Publish with compression

- (void)testItShouldPublishCompressedMessageUsingPOST {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:10000];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        XCTAssertEqual(expectedMessage.length, 10000);
        
        [client publish:expectedMessage toChannel:channel compressed:YES withCompletion:^(PNPublishStatus *status) {
            NSURLRequest *request = status.clientRequest;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(request);
            XCTAssertEqualObjects(request.HTTPMethod.lowercaseString, @"post");
            XCTAssertEqualObjects(request.allHTTPHeaderFields[@"Content-Encoding"], @"gzip");
            XCTAssertLessThan(request.allHTTPHeaderFields[@"Content-Length"].intValue, expectedMessage.length);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldPublishCompressedAndFetchEmptyHistoryWhenStoreInHistoryDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel storeInHistory:NO compressed:YES
         withCompletion:^(PNPublishStatus *status) {
            
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForStorage" completionFor:(YHVVCR.cassette.isNewCassette ? 6.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqual(result.data.messages.count, 0);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}


#pragma mark - Tests :: Builder pattern-based publish

- (void)testItShouldPublishNSDictionaryUsingBuilderPatternInterface {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *expectedMessage = @{ @"hello": @"there" };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client1.currentConfiguration.shouldUseRandomInitializationVector);
    XCTAssertFalse(client2.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:client2 withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
            XCTAssertEqualObjects(message.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(message.data.message, expectedMessage);
            *shouldRemove = YES;
            
            handler();
        }];
        
        client1.publish().channel(channel).message(expectedMessage).performWithCompletion(^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
        });
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark - Tests :: Builder pattern-based fire

- (void)testItShouldFireMessageAndFetchEmptyHistory {
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.fire()
            .message(message)
            .channel(channel)
            .performWithCompletion(^(PNPublishStatus *status) {
                 XCTAssertFalse(status.isError);
                 handler();
            });
    }];
    
    [self waitTask:@"waitForStorage" completionFor:(YHVVCR.cassette.isNewCassette ? 6.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client historyForChannel:channel withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertEqual(result.data.messages.count, 0);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}


#pragma mark - Tests :: Signal

- (void)testItShouldSendSignalAndReceivePublishTimetoken {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedSignal = @"Hello there";
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client signal:expectedSignal channel:channel withCompletion:^(PNSignalStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertEqual(status.statusCode, 200);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldSendSignalAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSNumber *expectedSignal = @2010;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client signal:expectedSignal channel:channel withCompletion:^(PNSignalStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNSignalOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldNotSendTooLongSignalMessage {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedSignal = [@"hello-there" pnt_stringWithLength:200];
    __block BOOL retried = NO;
    

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client signal:expectedSignal channel:channel withCompletion:^(PNSignalStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNSignalOperation);
            XCTAssertEqual(status.category, PNMalformedResponseCategory);
            XCTAssertNotNil(status.errorData.information);
            XCTAssertEqualObjects(status.errorData.information, @"Signal size too large");
            
            if (!retried) {
                retried = YES;
                [status retry];
            } else {
                handler();
            }
        }];
    }];
#pragma clang diagnostic pop

    XCTAssertTrue(retried);
}


#pragma mark - Tests :: Builder pattern-based signal

- (void)testItShouldSendSignalUsingBuilderPatternInterface {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *expectedSignal = @{ @"hello": @"there" };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addSignalHandlerForClient:client2 withBlock:^(PubNub *client, PNSignalResult *signal, BOOL *shouldRemove) {
            XCTAssertEqualObjects(signal.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(signal.data.message, expectedSignal);
            *shouldRemove = YES;
            
            handler();
        }];
        
        client1.signal().channel(channel).message(expectedSignal).performWithCompletion(^(PNSignalStatus *status) {
            XCTAssertFalse(status.isError);
        });
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark - Tests :: Signal with encryption

- (void)testItShouldSendSignalWithNotEncryptedMessageWhenCipherKeyIsSet {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *message = @{ @"hello": @"there" };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    
   
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addSignalHandlerForClient:client2 withBlock:^(PubNub *client, PNSignalResult *signal, BOOL *shouldRemove) {
            XCTAssertEqualObjects(signal.data.publisher, client1.currentConfiguration.userID);
            XCTAssertEqualObjects(signal.data.message, message);
            *shouldRemove = YES;
            
            handler();
        }];
        
        [client1 signal:message channel:channel withCompletion:^(PNSignalStatus *status) {
            XCTAssertFalse(status.isError);
        }];
    }];
#pragma clang diagnostic pop

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark - Tests :: Publish size

- (void)testItShouldHaveNegativeSizeWhenMessageIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = nil;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel withCompletion:^(NSInteger size) {
            XCTAssertEqual(size, -1);
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldHaveNegativeSizeWhenChannelIsNil {
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    NSString *channel = nil;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel withCompletion:^(NSInteger size) {
            XCTAssertEqual(size, -1);
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldCalculateNSStringMessageSize {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel withCompletion:^(NSInteger size) {
            XCTAssertEqualWithAccuracy(size, 526, 30);
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldCalculateNSNumberMessageSize {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSNumber *expectedMessage = @2010;


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel withCompletion:^(NSInteger size) {
            XCTAssertEqualWithAccuracy(size, 511, 30);
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldCalculateNSDictionaryMessageSize {
    NSString *channel = [self channelWithName:@"test-channel"];
    NSDictionary *expectedMessage = @{ @"hello": @"there" };
    PubNub *client = [self createPubNubForUser:@"serhii"];
    

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel withCompletion:^(NSInteger size) {
            XCTAssertEqualWithAccuracy(size, 538, 30);
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldCalculateNSDictionaryWithNestedCollectionsMessageSize {
    NSDictionary *expectedMessage = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel withCompletion:^(NSInteger size) {
            XCTAssertEqualWithAccuracy(size, 581, 30);
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldCalculateNSArrayMessageSize {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSArray *expectedMessage = @[@"hello", @"there"];
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel withCompletion:^(NSInteger size) {
            XCTAssertEqualWithAccuracy(size, 538, 30);
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldCalculateNSArrayWithNestedCollectionsMessageSize {
    NSArray *expectedMessage = @[@"hello", @[@"there", @{ @"general": @"kenobi" }]];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel withCompletion:^(NSInteger size) {
            XCTAssertEqualWithAccuracy(size, 581, 30);
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldCalculateCompressedMessageSize {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:1000];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    __block NSInteger compressedStorableMessageSize = 0;
    __block NSInteger compressedMessageSize = 0;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel compressed:YES
               withCompletion:^(NSInteger size) {
            
            compressedMessageSize = size;
            handler();
        }];
    }];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel compressed:YES storeInHistory:YES
               withCompletion:^(NSInteger size) {
            
            compressedStorableMessageSize = size;
            handler();
        }];
    }];
#pragma clang diagnostic pop

    
    XCTAssertEqualWithAccuracy(compressedMessageSize, 617, 30);
    XCTAssertEqual(compressedStorableMessageSize, compressedMessageSize);
}

- (void)testItShouldCalculateNotStorableMessageSize {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel storeInHistory:YES
               withCompletion:^(NSInteger size) {
            
            XCTAssertEqualWithAccuracy(size, 526, 30);
            handler();
        }];
    }];
#pragma clang diagnostic pop
}

- (void)testItShouldCalculateSizeOfMessageWithMetadata {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:1000];
    NSDictionary *expectedMetadata = @{ @"access-level": @"editor" };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    __block NSInteger messageWithMetadataSize = 0;
    __block NSInteger notCompressedMessageWithMetadataSize = 0;
    

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel withMetadata:expectedMetadata
                   completion:^(NSInteger size) {
            
            messageWithMetadataSize = size;
            handler();
        }];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client sizeOfMessage:expectedMessage toChannel:channel compressed:NO
                 withMetadata:expectedMetadata completion:^(NSInteger size) {
            
            notCompressedMessageWithMetadataSize = size;
            handler();
        }];
    }];
#pragma clang diagnostic pop

    
    XCTAssertEqualWithAccuracy(messageWithMetadataSize, 1558, 30);
    XCTAssertEqual(notCompressedMessageWithMetadataSize, messageWithMetadataSize);
}


#pragma mark - Tests :: Builder pattern-based message size

- (void)testItShouldCalculateSizeUsingBuilderPatternInterface {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.size()
            .message(expectedMessage)
            .channel(channel)
            .shouldStore(NO)
            .ttl(120)
            .replicate(NO)
            .performWithCompletion(^(NSInteger size) {
                XCTAssertEqualWithAccuracy(size, 545, 30);
                handler();
            });
    }];
#pragma clang diagnostic pop
}

#pragma mark -

#pragma clang diagnostic pop

@end
