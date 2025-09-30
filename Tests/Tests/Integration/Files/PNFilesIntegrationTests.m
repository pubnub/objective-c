/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNBaseRequest+Private.h>
#import <PubNub/PNHelpers.h>
#import "NSString+PNTest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration


@interface PNFilesIntegrationTests : PNRecordableTestCase


#pragma mark - Information

/**
 * @brief Directory which is used for generated / downloaded files storage.
 */
@property (nonatomic, copy) NSString *workingDirectory;

/**
 * @brief Message encryption / decryption key.
 */
@property (nonatomic, copy) NSString *cipherKey;

/**
 * @brief Name of channel with which Files API should be tested.
 */
@property (nonatomic, copy) NSString *channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNFilesIntegrationTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    return NO;
}

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    configuration.cipherKey = self.cipherKey;
    
    if ([self.name pnt_includesString:@"Encrypt"] && ![self.name pnt_includesString:@"DontDecrypt"]) {
        configuration.cipherKey = self.cipherKey;
    }
#pragma clang diagnostic pop

    if ([self.name pnt_includesString:@"AuthKeyIsSet"]) {
        configuration.authKey = [self authForUser:@"serhii"];
    }
    
    return configuration;
}

- (void)setUp {
    [super setUp];
    
    NSSearchPathDirectory searchPath = (TARGET_OS_IPHONE ? NSCachesDirectory : NSLibraryDirectory);
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
    self.workingDirectory = paths.count > 0 ? paths.firstObject : NSTemporaryDirectory();
    self.channel = [self channelWithName:@"files-upload"];
    self.cipherKey = @"enigma";
    
    [self completePubNubConfiguration:self.client];
}

- (void)tearDown {
    
    [self removeAllFilesForChannel:self.channel];
    
    [super tearDown];
}


#pragma mark - Tests :: Builder pattern-based send file

- (void)testItShouldSendFileFromDataAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().sendFile(self.channel, fileName)
            .data(data)
            .performWithCompletion(^(PNSendFileStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertTrue(status.data.fileUploaded);
                XCTAssertNotNil(status.data.fileIdentifier);
                XCTAssertNotNil(status.data.timetoken);
                XCTAssertNotNil(status.data.fileName);
                XCTAssertEqualObjects(status.data.fileName, fileName);
                XCTAssertEqual(status.operation, PNSendFileOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            });

            handler();
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:1.f];
}

- (void)testItShouldSendFileFromDataAndNotCrashWhenCompletionBlockIsNil {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [self waitToNotCompleteIn:5.f codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.files().sendFile(self.channel, fileName).data(data).performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:1.f];
}

- (void)testItShouldSendFileFromDataAndReceiveFromHistory {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().sendFile(self.channel, fileName)
            .data(data)
            .performWithCompletion(^(PNSendFileStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertTrue(status.data.fileUploaded);
                XCTAssertNotNil(status.data.fileIdentifier);
                XCTAssertNotNil(status.data.timetoken);
                XCTAssertNotNil(status.data.fileName);
                XCTAssertEqualObjects(status.data.fileName, fileName);
                XCTAssertEqual(status.operation, PNSendFileOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:2.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.history()
            .channels(@[self.channel])
            .performWithCompletion(^(PNHistoryResult *result, PNErrorStatus *status) {
                NSArray<NSDictionary *> *messages = result.data.messages;
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(messages);
                XCTAssertEqual(messages.count, 1);
                XCTAssertNotNil(messages.firstObject[@"uuid"]);
                XCTAssertNotNil(messages.firstObject[@"messageType"]);
                XCTAssertEqualObjects(messages.firstObject[@"messageType"], @4);
                
                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:1.f];
}

- (void)testItShouldSendFileFromDataWithCustomMessageTypeAndReceiveFromHistory {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *excpectedMessageType = @"profile-image";


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:self.channel fileName:fileName data:data];
        request.customMessageType = excpectedMessageType;
        [self.client sendFileWithRequest:request completion:^(PNSendFileStatus *status) {
            XCTAssertFalse(status.isError);
            XCTAssertTrue(status.data.fileUploaded);
            XCTAssertNotNil(status.data.fileIdentifier);
            XCTAssertNotNil(status.data.timetoken);
            XCTAssertNotNil(status.data.fileName);
            XCTAssertEqualObjects(status.data.fileName, fileName);
            XCTAssertEqual(status.operation, PNSendFileOperation);
            XCTAssertEqual(status.category, PNAcknowledgmentCategory);

            handler();
        }];
    }];

    [self waitTask:@"waitForDistribution" completionFor:2.f];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:@[self.channel]];
        request.includeCustomMessageType = YES;

        [self.client fetchHistoryWithRequest:request completion:^(PNHistoryResult *result, PNErrorStatus *status) {
            NSArray<NSDictionary *> *messages = result.data.messages;
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(messages);
            XCTAssertEqual(messages.count, 1);
            XCTAssertNotNil(messages.firstObject[@"uuid"]);
            XCTAssertNotNil(messages.firstObject[@"messageType"]);
            XCTAssertEqualObjects(messages.firstObject[@"messageType"], @4);
            XCTAssertEqualObjects(messages.firstObject[@"customMessageType"], excpectedMessageType);

            handler();
        }];
    }];

    [self waitTask:@"waitForDistribution" completionFor:1.f];
}

- (void)testItShouldSendFileFromFileAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSURL *fileURL = [NSURL URLWithString:[self.workingDirectory stringByAppendingPathComponent:fileName]];
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([data writeToURL:[NSURL fileURLWithPath:fileURL.absoluteString] atomically:YES]);
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().sendFile(self.channel, fileName)
            .url(fileURL)
            .performWithCompletion(^(PNSendFileStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertTrue(status.data.fileUploaded);
                XCTAssertNotNil(status.data.fileIdentifier);
                XCTAssertNotNil(status.data.timetoken);
                XCTAssertNotNil(status.data.fileName);
                XCTAssertEqualObjects(status.data.fileName, fileName);
                XCTAssertEqual(status.operation, PNSendFileOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            });

            handler();
    }];
    
    [NSFileManager.defaultManager removeItemAtURL:fileURL error:nil];
    [self waitTask:@"waitForDistribution" completionFor:1.f];
}

- (void)testItShouldSendFileFromStreamAndReceiveStatusWithExpectedOperationAndCategory {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSURL *fileURL = [NSURL URLWithString:[self.workingDirectory stringByAppendingPathComponent:fileName]];
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([data writeToURL:[NSURL fileURLWithPath:fileURL.absoluteString] atomically:YES]);
    
    NSInputStream *stream = [NSInputStream inputStreamWithURL:[NSURL fileURLWithPath:fileURL.absoluteString]];
    XCTAssertNotNil(stream);
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().sendFile(self.channel, fileName)
            .stream(stream, data.length)
            .performWithCompletion(^(PNSendFileStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertTrue(status.data.fileUploaded);
                XCTAssertNotNil(status.data.fileIdentifier);
                XCTAssertNotNil(status.data.timetoken);
                XCTAssertNotNil(status.data.fileName);
                XCTAssertEqualObjects(status.data.fileName, fileName);
                XCTAssertEqual(status.operation, PNSendFileOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);
            });

            handler();
    }];
    
    
    [NSFileManager.defaultManager removeItemAtURL:fileURL error:nil];
    [self waitTask:@"waitForDistribution" completionFor:1.f];
}

- (void)testItShouldSendEncryptedFileAndTriggerFileEventOnChannel {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *expectedMessage = @{ @"text": [NSUUID UUID].UUIDString };
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    __block NSString *uploadedFileIdentifier = nil;
    __block NSString *uploadedFileName = nil;
    
    [self subscribeClient:client2 toChannels:@[self.channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addFileHandlerForClient:client2 withBlock:^(PubNub *client, PNFileEventResult *event, BOOL *remove) {
            PNFile *file = event.data.file;
            XCTAssertNotNil(file);
            XCTAssertNotNil(file.identifier);
            XCTAssertNotNil(file.name);
            XCTAssertEqualObjects(event.data.message, expectedMessage);
            uploadedFileIdentifier = file.identifier;
            uploadedFileName = file.name;
            
            *remove = YES;
            handler();
        }];
        
        client1.files().sendFile(self.channel, fileName)
            .data(data)
            .message(expectedMessage)
            .performWithCompletion(^(PNSendFileStatus *status) {
                XCTAssertTrue(status.data.fileUploaded);
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[self.channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:1.f];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client2.files().downloadFile(self.channel, uploadedFileIdentifier, uploadedFileName)
            .performWithCompletion(^(PNDownloadFileResult *result, PNErrorStatus *status) {
                NSError *downloadError = nil;
                NSData *downloadedFile = [NSData dataWithContentsOfURL:result.data.location
                                                               options:NSDataReadingUncached
                                                                 error:&downloadError];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(result.data.location);
                
                XCTAssertNil(downloadError);
                XCTAssertNotNil(downloadedFile);
                XCTAssertEqualObjects(downloadedFile, data);
                
                handler();
            });
    }];
    
    
    [self verifyUploadedFilesCountInChannel:self.channel shouldEqualTo:1 usingClient:client1];
}

- (void)testItShouldSendFileAndTriggerFileEventOnChannel {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *expectedMessage = @{ @"text": [NSUUID UUID].UUIDString };
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    
    [self subscribeClient:client2 toChannels:@[self.channel] withPresence:NO];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addFileHandlerForClient:client2 withBlock:^(PubNub *client, PNFileEventResult *event, BOOL *remove) {
            PNFile *file = event.data.file;
            XCTAssertNotNil(file);
            XCTAssertNotNil(file.identifier);
            XCTAssertNotNil(file.name);
            XCTAssertEqualObjects(event.data.message, expectedMessage);
             
            NSURL *expectedURL = [self.client downloadURLForFileWithName:file.name
                                                              identifier:file.identifier
                                                               inChannel:self.channel];
            XCTAssertEqualObjects(file.downloadURL.path, expectedURL.path);
            
            *remove = YES;
            handler();
        }];
        
        client1.files().sendFile(self.channel, fileName)
            .data(data)
            .message(expectedMessage)
            .performWithCompletion(^(PNSendFileStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[self.channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:1.f];
    
    
    [self verifyUploadedFilesCountInChannel:self.channel shouldEqualTo:1 usingClient:client1];
}

- (void)testItShouldSendFileAndIgnoreFileEventOnChannelWhenFilterExpressionIsSet {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *expectedMessage = @{ @"text": [NSUUID UUID].UUIDString };
    PubNub *client1 = [self createPubNubForUser:@"serhii"];
    PubNub *client2 = [self createPubNubForUser:@"david"];
    client2.filterExpression = [NSString stringWithFormat:@"uuid == '%@'",
                                client2.currentConfiguration.userID];

    [self subscribeClient:client2 toChannels:@[self.channel] withPresence:NO];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addFileHandlerForClient:client2 withBlock:^(PubNub *client, PNFileEventResult *event, BOOL *remove) {
            PNFile *file = event.data.file;
            XCTAssertNotNil(file);
            XCTAssertNotNil(file.identifier);
            XCTAssertNotNil(file.name);
            XCTAssertNotNil(file.created);
            XCTAssertEqual(file.size, data.length);
            
            *remove = YES;
            handler();
        }];
        
        client1.files().sendFile(self.channel, fileName)
            .data(data)
            .message(expectedMessage)
            .fileMessageMetadata(@{ @"uuid": client1.currentConfiguration.userID })
            .performWithCompletion(^(PNSendFileStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];

    [self unsubscribeClient:client2 fromChannels:@[self.channel] withPresence:NO];
    [self waitTask:@"waitForDistribution" completionFor:1.f];
    
    
    [self verifyUploadedFilesCountInChannel:self.channel shouldEqualTo:1 usingClient:client1];
}


#pragma mark - Tests :: Generate file download URL

- (void)testItShouldReturnFileDownloadURL {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSString *expectedUserId = [@"uuid=" stringByAppendingString:[PNString percentEscapedString:self.client.userID]];
    NSString *identifier = [NSUUID UUID].UUIDString;
    
    
    NSURL *downloadURL = [self.client downloadURLForFileWithName:fileName identifier:identifier inChannel:self.channel];
    
    
    XCTAssertNotNil(downloadURL);
    XCTAssertTrue([downloadURL.absoluteString containsString:expectedUserId]);
    XCTAssertTrue([downloadURL.absoluteString containsString:identifier]);
    XCTAssertTrue([downloadURL.absoluteString containsString:fileName]);
}

- (void)testItShouldReturnFileDownloadURLWhenAuthKeyIsSet {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSString *expectedUserId = [@"uuid=" stringByAppendingString:[PNString percentEscapedString:self.client.userID]];
    NSString *expectedAuth = @"auth=file-access-token";
    NSString *identifier = [NSUUID UUID].UUIDString;
    [self.client setAuthToken:@"file-access-token"];
    
    
    NSURL *downloadURL = [self.client downloadURLForFileWithName:fileName identifier:identifier inChannel:self.channel];
    
    
    XCTAssertNotNil(downloadURL);
    XCTAssertTrue([downloadURL.absoluteString containsString:expectedUserId]);
    XCTAssertTrue([downloadURL.absoluteString containsString:expectedAuth],
                  @"'%@' doesn't have '%@'",
                  downloadURL.absoluteString,
                  expectedAuth);
    XCTAssertTrue([downloadURL.absoluteString containsString:identifier]);
    XCTAssertTrue([downloadURL.absoluteString containsString:fileName]);
}

- (void)testItShouldNotReturnFileDownloadURLWhenChannelNameIsNil {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSString *identifier = [NSUUID UUID].UUIDString;
    NSString *expectedChannel = nil;
    
    
    NSURL *downloadURL = [self.client downloadURLForFileWithName:fileName identifier:identifier inChannel:expectedChannel];
    
    
    XCTAssertNil(downloadURL);
}

- (void)testItShouldNotReturnFileDownloadURLWhenFileIdentifierIsNil {
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"txt"];
    NSString *identifier = nil;
    
    
    NSURL *downloadURL = [self.client downloadURLForFileWithName:fileName identifier:identifier inChannel:self.channel];
    
    
    XCTAssertNil(downloadURL);
}

- (void)testItShouldNotReturnFileDownloadURLWhenFileNameIsNil {
    NSString *identifier = [NSUUID UUID].UUIDString;
    NSString *fileName = nil;
    
    
    NSURL *downloadURL = [self.client downloadURLForFileWithName:fileName identifier:identifier inChannel:self.channel];
    
    
    XCTAssertNil(downloadURL);
}


#pragma mark - Tests :: Builder pattern-based download files

- (void)testItShouldDownloadFileAndReceiveResultWithExpectedOperation {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:1 toChannel:self.channel usingClient:nil];
    NSString *expectedUUID = self.client.currentConfiguration.userID;

    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:self.channel
                                                                        identifier:uploadedFiles.firstObject[@"id"]
                                                                              name:uploadedFiles.firstObject[@"name"]];
        PNTransportRequest *transportRequest = [self.client.serviceNetwork transportRequestFromTransportRequest:request.request];
        
        [self.client downloadFileWithRequest:request completion:^(PNDownloadFileResult *result, PNErrorStatus *status) {
            NSError *downloadError = nil;
            NSData *downloadedFile = [NSData dataWithContentsOfURL:result.data.location
                                                           options:NSDataReadingUncached
                                                             error:&downloadError];
            
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(request);
            XCTAssertNotNil(result.data.location);
            XCTAssertEqual(result.operation, PNDownloadFileOperation);
            
            XCTAssertNil(downloadError);
            XCTAssertNotNil(downloadedFile);
            XCTAssertEqualObjects(downloadedFile, uploadedFiles.firstObject[@"data"]);
            XCTAssertEqualObjects(transportRequest.query[@"uuid"], expectedUUID);
            
            handler();
        }];
    }];
    
    
    [self removeFiles:uploadedFiles forChannel:self.channel];
}

- (void)testItShouldDownloadFilesWhenFileEncrypted {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:3 toChannel:self.channel usingClient:nil];
    
    
    for (NSDictionary *fileData in uploadedFiles) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client.files().downloadFile(self.channel, fileData[@"id"], fileData[@"name"])
                .performWithCompletion(^(PNDownloadFileResult *result, PNErrorStatus *status) {
                    NSError *downloadError = nil;
                    NSData *downloadedFile = [NSData dataWithContentsOfURL:result.data.location
                                                                   options:NSDataReadingUncached
                                                                     error:&downloadError];
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(result.data.location);
                    
                    XCTAssertNil(downloadError);
                    XCTAssertNotNil(downloadedFile);
                    XCTAssertEqualObjects(downloadedFile, fileData[@"data"]);
                    
                    handler();
                });
        }];
    }
    
    
    [self removeFiles:uploadedFiles forChannel:self.channel];
}

- (void)testItShouldDownloadFileWhenAuthKeyIsSet {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:1 toChannel:self.channel usingClient:nil];
    NSString *expectedAuth = self.client.currentConfiguration.authKey;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:self.channel
                                                                        identifier:uploadedFiles.firstObject[@"id"]
                                                                              name:uploadedFiles.firstObject[@"name"]];
        PNTransportRequest *transportRequest = [self.client.serviceNetwork transportRequestFromTransportRequest:request.request];
        
        [self.client downloadFileWithRequest:request completion:^(PNDownloadFileResult *result, PNErrorStatus *status) {
            NSError *downloadError = nil;
            NSData *downloadedFile = [NSData dataWithContentsOfURL:result.data.location
                                                           options:NSDataReadingUncached
                                                             error:&downloadError];
            XCTAssertFalse(status.isError);
            XCTAssertNotNil(request);
            XCTAssertNotNil(result.data.location);
            XCTAssertEqual(result.operation, PNDownloadFileOperation);
            
            XCTAssertNil(downloadError);
            XCTAssertNotNil(downloadedFile);
            XCTAssertEqualObjects(downloadedFile, uploadedFiles.firstObject[@"data"]);
            XCTAssertEqualObjects(transportRequest.query[@"auth"], expectedAuth);
            
            handler();
        }];
    }];
    
    
    [self removeFiles:uploadedFiles forChannel:self.channel];
}

- (void)testItShouldDownloadEncryptedFileAndDontDecrypt {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:1 toChannel:self.channel withCipherKey:@"secret" usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().downloadFile(self.channel, uploadedFiles.firstObject[@"id"], uploadedFiles.firstObject[@"name"])
            .performWithCompletion(^(PNDownloadFileResult *result, PNErrorStatus *status) {
                NSError *downloadError = nil;
                NSData *downloadedFile = [NSData dataWithContentsOfURL:result.data.location
                                                               options:NSDataReadingUncached
                                                                 error:&downloadError];
                XCTAssertFalse(status.isError);
                XCTAssertNotNil(result.data.location);
                
                XCTAssertNil(downloadError);
                XCTAssertNotNil(downloadedFile);
                XCTAssertNotEqualObjects(downloadedFile, uploadedFiles.firstObject[@"data"]);
                
                handler();
            });
    }];
    
    
    [self removeFiles:uploadedFiles forChannel:self.channel];
}


#pragma mark - Tests :: Builder pattern-based list files

- (void)testItShouldFetchFilesListAndReceiveResultWithExpectedOperation {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:2 toChannel:self.channel usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().listFiles(self.channel)
            .performWithCompletion(^(PNListFilesResult *result, PNErrorStatus *status) {
                NSArray<PNFile *> *files = result.data.files;
                NSUInteger verifiedFilesCount = 0;
                XCTAssertFalse(status.isError);
                XCTAssertGreaterThan(files.count, 0);
                XCTAssertEqual(result.data.count, uploadedFiles.count);
                XCTAssertEqual(result.operation, PNListFilesOperation);
                
                for (NSDictionary *uploadedFile in uploadedFiles) {
                    for (PNFile *file in files) {
                        if ([uploadedFile[@"id"] isEqual:file.identifier]) {
                            verifiedFilesCount++;
                            break;
                        }
                    }
                }
                
                XCTAssertEqual(verifiedFilesCount, uploadedFiles.count);
                
                handler();
            });
    }];
    
    
    [self removeFiles:uploadedFiles forChannel:self.channel];
}

- (void)testItShouldFetchFilesListWhenLimitIsSet {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:4 toChannel:self.channel usingClient:nil];
    NSUInteger limit = uploadedFiles.count * 0.5f;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().listFiles(self.channel)
            .limit(limit)
            .performWithCompletion(^(PNListFilesResult *result, PNErrorStatus *status) {
                NSArray<PNFile *> *files = result.data.files;
                XCTAssertFalse(status.isError);
                XCTAssertEqual(files.count, limit);
                XCTAssertEqual(result.data.count, limit);
                
                handler();
            });
    }];
    
    
    [self removeFiles:uploadedFiles forChannel:self.channel];
}

- (void)testItShouldFetchFilesListWhenAuthKeyIsSet {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:1 toChannel:self.channel usingClient:nil];
    NSString *expectedAuth = self.client.currentConfiguration.authKey;
    NSString *expectedUUID = self.client.currentConfiguration.userID;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:self.channel];
        PNTransportRequest *transportRequest = [self.client.serviceNetwork transportRequestFromTransportRequest:request.request];
        
        [self.client listFilesWithRequest:request completion:^(PNListFilesResult *result, PNErrorStatus *status) {
            XCTAssertEqualObjects(transportRequest.query[@"uuid"], expectedUUID);
            XCTAssertEqualObjects(transportRequest.query[@"auth"], expectedAuth);
            
            handler();
        }];
    }];
    
    
    [self removeFiles:uploadedFiles forChannel:self.channel];
}

- (void)testItShouldFetchNextMembershipPageWhenStartAndLimitIsSet {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:4 toChannel:self.channel usingClient:nil];
    NSMutableArray<NSString *> *fetchedFilesIdentifiers = [NSMutableArray new];
    NSUInteger limit = uploadedFiles.count * 0.5f;
    __block NSString *next = nil;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().listFiles(self.channel)
            .limit(limit)
            .performWithCompletion(^(PNListFilesResult *result, PNErrorStatus *status) {
                NSArray<PNFile *> *files = result.data.files;
                XCTAssertFalse(status.isError);
                XCTAssertEqual(result.data.files.count, limit);
                XCTAssertEqual(result.data.count, limit);
                XCTAssertNotNil(result.data.next);
                
                for (PNFile *file in files) {
                    [fetchedFilesIdentifiers addObject:file.identifier];
                }
                
                next = result.data.next;
                handler();
            });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().listFiles(self.channel)
            .limit(limit)
            .next(next)
            .performWithCompletion(^(PNListFilesResult *result, PNErrorStatus *status) {
                NSArray<PNFile *> *files = result.data.files;
                XCTAssertFalse(status.isError);
                XCTAssertEqual(result.data.files.count, limit);
                XCTAssertEqual(result.data.count, limit);
                XCTAssertNil(result.data.next);
                
                for (PNFile *file in files) {
                    XCTAssertFalse([fetchedFilesIdentifiers containsObject:file.identifier]);
                }
                
                handler();
            });
    }];
    
    
    [self removeFiles:uploadedFiles forChannel:self.channel];
}


#pragma mark - Tests :: Builder pattern-based delete files

- (void)testItShouldDeleteFileAndReceiveStatusWithExpectedOperationAndCategory {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:2 toChannel:self.channel usingClient:nil];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.files().deleteFile(self.channel, uploadedFiles.firstObject[@"id"], uploadedFiles.firstObject[@"name"])
            .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(status.operation, PNDeleteFileOperation);
                XCTAssertEqual(status.category, PNAcknowledgmentCategory);

                handler();
            });
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:1.f];
    [self verifyUploadedFilesCountInChannel:self.channel shouldEqualTo:1 usingClient:nil];
}

- (void)testItShouldDeleteFileAndNotCrashWhenCompletionBlockIsNil {
    NSArray<NSDictionary *> *uploadedFiles = [self uploadFiles:2 toChannel:self.channel usingClient:nil];
    
    
    [self waitToNotCompleteIn:5.f codeBlock:^(dispatch_block_t handler) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            self.client.files().deleteFile(self.channel, uploadedFiles.firstObject[@"id"], uploadedFiles.firstObject[@"name"])
                .performWithCompletion(nil);
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            handler();
        }
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:1.f];
    [self verifyUploadedFilesCountInChannel:self.channel shouldEqualTo:1 usingClient:nil];
}

#pragma mark -


@end
