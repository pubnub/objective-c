/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import "PubNub+CorePrivate.h"
#import "PNBaseRequest+Private.h"
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
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


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
    configuration.useRandomInitializationVector = [self.name rangeOfString:@"RandomIV"].location != NSNotFound;
    
    if ([self.name pnt_includesString:@"Encrypt"]) configuration.cipherKey = self.cipherKey;
    
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

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishWithRequestAndReceivePublishTimetokenWhenReplicationDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        request.replicate = NO;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishWithRequestAndReceivePublishTimetokenWhenStoreDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        request.store = NO;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishAndReceivePublishTimetoken {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNPublishOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishAndNotCrashWhenCompletionBlockIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        @try {
            [client publish:expectedMessage toChannel:channel withCompletion:nil];
        } @catch (NSException *exception) {
            handler();
        }
    }];
}

- (void)testItShouldNotPublishAndReceiveBadRequestStatusWhenMessageIsNil {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = nil;

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotNil(status.errorData.information);

            XCTAssertEqual(status.operation, PNPublishOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotPublishAndReceiveBadRequestStatusWhenChannelIsNil {
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";
    NSString *channel = nil;

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client publish:expectedMessage toChannel:channel withCompletion:^(PNPublishStatus *status) {
            XCTAssertTrue(status.isError);
            XCTAssertNotNil(status.errorData.information);
            XCTAssertEqual(status.operation, PNPublishOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishWithTTL {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        request.ttl = 120;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertEqualObjects(request.request.query[@"ttl"], @"120");
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishWithOutTTLWhenStoreInHistoryDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        request.store = NO;
        request.ttl = 120;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertEqualObjects(request.request.query[@"store"], @"0");
            XCTAssertNil(request.request.query[@"ttl"]);
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishWithNoReplicationPolicy {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        request.replicate = NO;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertEqualObjects(request.request.query[@"norep"], @"true");
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishNSString {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSString *expectedMessage = @"Hello there";
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSNumber {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSNumber *expectedMessage = @2010;
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSDictionary {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *expectedMessage = @{ @"hello": @"there" };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSDictionaryWithNestedCollections {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *expectedMessage = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSArray {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray *expectedMessage = @[@"hello", @"there"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishNSArrayWithNestedCollections {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSArray *expectedMessage = @[@"hello", @[@"there", @{ @"general": @"kenobi" }]];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublish1000CharactersLongNSString {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:1000];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublish10000CharactersLongNSString {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:10000];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldNotPublishTooLongPublishMessage {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:100000];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    __block BOOL retried = NO;

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        XCTAssertEqual(expectedMessage.length, 100000);
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        __block __weak PNPublishCompletionBlock weakBlock;
        __block PNPublishCompletionBlock block;
        
        block = ^(PNPublishStatus *status) {
            __strong PNPublishCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.category, PNRequestURITooLongCategory);
            XCTAssertNotNil(status.errorData.information);
            
            if (!retried) {
                retried = YES;
                [client publishWithRequest:request completion:strongBlock];
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        [client publishWithRequest:request completion:block];
    }];

    XCTAssertTrue(retried);
}

- (void)testItShouldPublishStringWithSpecialSymbols {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSString *expectedMessage = @"!@#$%^&*()_+|";
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark - Tests :: Publish with storage option

- (void)testItShouldPublishAndFetchMessageFromHistory {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

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
}

- (void)testItShouldPublishAndFetchEmptyHistoryWhenStoreInHistoryDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

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
}


#pragma mark - Tests :: Publish with mobile payloads

- (void)testItShouldPublishMobilePayloadWithWrappedKeys {
    NSDictionary *mobilePayload = @{
        @"apns": @{ @"aps": @{ @"alert": @"Hello there" } },
        @"fcm": @{ @"data": @{ @"hello": @"there" } }
    };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSString *message = @"Hello there";
    NSDictionary *expectedMessage = @{
        @"pn_other": message,
        @"pn_apns": mobilePayload[@"apns"],
        @"pn_fcm": mobilePayload[@"fcm"]
    };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

- (void)testItShouldPublishMessageWithMobilePayloadAndFetchEmptyHistoryWhenStoreInHistoryDisabled {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];

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
}

- (void)testItShouldPublishCompressedMessageWithMobilePayloadAndFetchMessageFromHistory {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSMutableDictionary *expectedMessage = [@{ @"pn_apns": mobilePayload[@"apns"] } mutableCopy];
    [expectedMessage addEntriesFromDictionary:message];

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
}

- (void)testItShouldPublishOnlyWithMobilePayload {
    NSDictionary *mobilePayload = @{ @"apns": @{ @"aps": @{ @"alert": @"Hello there" } } };
    NSDictionary *expectedMessage = @{ @"pn_apns": mobilePayload[@"apns"] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];


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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}

#pragma mark - Tests :: Publish with compression

- (void)testItShouldPublishCompressedMessageUsingPOST {
    NSString *expectedMessage = [@"hello-there" pnt_stringWithLength:10000];
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];

    XCTAssertFalse(client.currentConfiguration.shouldUseRandomInitializationVector);

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        XCTAssertEqual(expectedMessage.length, 10000);
        PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
        request.message = expectedMessage;
        request.compress = YES;
        
        [client publishWithRequest:request completion:^(PNPublishStatus *status) {
            PNTransportRequest *transportRequest = [client.serviceNetwork transportRequestFromTransportRequest:request.request];
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(transportRequest);
            XCTAssertEqual(transportRequest.method, TransportPOSTMethod);
            XCTAssertEqualObjects(transportRequest.headers[@"content-encoding"], @"gzip");
            XCTAssertLessThan(((NSString *)transportRequest.headers[@"content-length"]).intValue, expectedMessage.length);
            
            handler();
        }];
    }];
}

- (void)testItShouldPublishCompressedAndFetchEmptyHistoryWhenStoreInHistoryDisabled {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedMessage = @"Hello there";

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
}


#pragma mark - Tests :: Builder pattern-based publish

- (void)testItShouldPublishNSDictionaryUsingBuilderPatternInterface {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *expectedMessage = @{ @"hello": @"there" };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark - Tests :: Builder pattern-based fire

- (void)testItShouldFireMessageAndFetchEmptyHistory {
    NSDictionary *message = @{ @"hello": @[@"there", @{ @"general": @"kenobi" }] };
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];

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
}


#pragma mark - Tests :: Signal

- (void)testItShouldSendSignalAndReceivePublishTimetoken {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedSignal = @"Hello there";
    

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client signal:expectedSignal channel:channel withCompletion:^(PNSignalStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(status.data.timetoken);
            
            handler();
        }];
    }];
}

- (void)testItShouldSendSignalAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSNumber *expectedSignal = @2010;
    

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client signal:expectedSignal channel:channel withCompletion:^(PNSignalStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.operation, PNSignalOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            
            handler();
        }];
    }];
}

- (void)testItShouldNotSendTooLongSignalMessage {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client = [self createPubNubForUser:@"serhii"];
    NSString *expectedSignal = [@"hello-there" pnt_stringWithLength:200];
    __block BOOL retried = NO;
    

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNSignalRequest *request = [PNSignalRequest requestWithChannel:channel signal:expectedSignal];
        __block __weak PNSignalCompletionBlock weakBlock;
        __block PNSignalCompletionBlock block;
        
        
        block = ^(PNSignalStatus *status) {
            __strong PNSignalCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            XCTAssertTrue(status.isError);
            XCTAssertEqual(status.operation, PNSignalOperation);
            XCTAssertEqual(status.category, PNBadRequestCategory);
            XCTAssertNotNil(status.errorData.information);
            XCTAssertEqualObjects(status.errorData.information, @"Signal size too large");
            
            if (!retried) {
                retried = YES;
                [client sendSignalWithRequest:request completion:strongBlock];
            } else {
                handler();
            }
        };
        
        weakBlock = block;
        [client sendSignalWithRequest:request completion:block];
    }];

    XCTAssertTrue(retried);
}


#pragma mark - Tests :: Builder pattern-based signal

- (void)testItShouldSendSignalUsingBuilderPatternInterface {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *expectedSignal = @{ @"hello": @"there" };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark - Tests :: Signal with encryption

- (void)testItShouldSendSignalWithNotEncryptedMessageWhenCipherKeyIsSet {
    NSString *channel = [self channelWithName:@"test-channel"];
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    NSDictionary *message = @{ @"hello": @"there" };
    
    [self subscribeClient:client2 toChannels:@[channel] withPresence:NO];
    

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

    [self unsubscribeClient:client2 fromChannels:@[channel] withPresence:NO];
}


#pragma mark -

#pragma clang diagnostic pop

@end
