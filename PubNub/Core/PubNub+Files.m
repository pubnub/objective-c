#import "PubNub+Files.h"
#import "PNPublishFileMessageRequest+Private.h"
#import "PNGenerateFileDownloadURLRequest.h"
#import "PNGenerateFileUploadURLRequest.h"
#import "PNGenerateFileUploadURLStatus.h"
#import "PNDownloadFileRequest+Private.h"
#import "PNBaseOperationData+Private.h"
#import "PNFileListFetchData+Private.h"
#import "PNFileDownloadData+Private.h"
#import "PNSendFileRequest+Private.h"
#import "PNOperationResult+Private.h"
#import "PNFileSendData+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFileUploadRequest.h"
#import "PNErrorData+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNPublishStatus.h"
#import "PubNub+Publish.h"
#import "PNCryptoModule.h"
#import "PubNub+PAM.h"
#import "PNHelpers.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// **PubNub** `File Share` APIs private extension.
@interface PubNub (FilesProtected)


#pragma mark - Files API builder interface (deprecated)

/// Process information provider by user with builder API call and use it to send request which will upload file.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)sendFileRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will fetch uploaded 
/// files list.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)listFilesRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and generate file download URL.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)downloadFileURLUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to download specific file.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)downloadFileRequestUsingBuilderParameters:(NSDictionary *)parameters;

/// Process information provider by user with builder API call and use it to send request which will delete specific 
/// file.
///
/// - Parameter parameters: Dictionary with information passed to builder-based API.
- (void)deleteFileRequestUsingBuilderParameters:(NSDictionary *)parameters;


#pragma mark - Handlers

/// Handle upload URL generation success.
///
/// - Parameters:
///   - status: Status object with information which can be used to upload data specified by ``sendFileRequest``.
///   - sendFileRequest: Original `send file` request used to trigger upload URL generation.
///   - block: `Send file` request processing completion block.
- (void)handleGenerateFileUploadURLSuccessWithStatus:(PNGenerateFileUploadURLStatus *)status
                                     sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                          completion:(PNSendFileCompletionBlock)block;

/// Handle upload URL generation failure.
///
/// - Parameters:
///   - status: Status object with information about what exactly went wrong during data upload.
///   - sendFileRequest: Original `send file` request used to trigger upload URL generation.
///   - block: `Send file` request processing completion block.
- (void)handleGenerateFileUploadURLErrorWithStatus:(PNGenerateFileUploadURLStatus *)status
                                   sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                        completion:(PNSendFileCompletionBlock)block;

/// Handle `file upload` success.
///
/// - Parameters:
///   - fileIdentifier: Unique identifier which has been assigned to file during upload (upload URL generation).
///   - fileName: Actual file name which has been used to store uploaded data (can be different from what has been
///   configured with ``sendFileRequest``).
///   - sendFileRequest: Original `send file` request used to trigger `file upload`.
///   - block: `Send file` request processing completion block.
- (void)handleUploadFileSuccessWithFileIdentifier:(NSString *)fileIdentifier
                                         fileName:(NSString *)fileName
                                  sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                       completion:(PNSendFileCompletionBlock)block;

/// Handle `file upload` failure.
///
/// - Parameters:
///   - fileIdentifier: Unique identifier which has been assigned to file during upload (upload URL generation).
///   - fileName: Actual file name which has been used to store uploaded data (can be different from what has been 
///   configured with ``sendFileRequest``).
///   - category: File upload request processing error category.
///   - block: `Send file` request processing completion block.
- (void)handleUploadFileErrorWithFileIdentifier:(NSString *)fileIdentifier
                                           name:(NSString *)fileName
                                       category:(PNStatusCategory)category
                                     completion:(PNSendFileCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Files)


#pragma mark - Files API builder interface (deprecated)

- (PNFilesAPICallBuilder * (^)(void))files {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"Builder-based interface deprecated. Please use corresponding "
                "request-based interfaces."];
    }];
    
    PNFilesAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;

    builder = [PNFilesAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, NSDictionary *parameters) {
        if ([flags containsObject:NSStringFromSelector(@selector(sendFile))]) {
            [weakSelf sendFileRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(listFiles))]) {
            [weakSelf listFilesRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(fileURL))]) {
            [weakSelf downloadFileURLUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(downloadFile))]) {
            [weakSelf downloadFileRequestUsingBuilderParameters:parameters];
        } else if ([flags containsObject:NSStringFromSelector(@selector(deleteFile))]) {
            [weakSelf deleteFileRequestUsingBuilderParameters:parameters];
        }
    }];

    return ^PNFilesAPICallBuilder * {
        return builder;
    };
}

- (void)sendFileRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSNumber *store = parameters[NSStringFromSelector(@selector(fileMessageStore))];
    NSString *cipherKey = parameters[NSStringFromSelector(@selector(cipherKey))];
    NSInputStream *stream = parameters[NSStringFromSelector(@selector(stream))];
    NSNumber *ttl = parameters[NSStringFromSelector(@selector(fileMessageTTL))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSString *name = parameters[NSStringFromSelector(@selector(name))];
    NSNumber *size = parameters[NSStringFromSelector(@selector(size))];
    NSData *data = parameters[NSStringFromSelector(@selector(data))];
    NSURL *url = parameters[NSStringFromSelector(@selector(url))];
    PNSendFileRequest *request = nil;
    
    if (stream) {
        NSUInteger streamSize = size.unsignedIntegerValue;
        request = [PNSendFileRequest requestWithChannel:channel fileName:name stream:stream size:streamSize];
    } else if (url) {
        request = [PNSendFileRequest requestWithChannel:channel fileURL:url];
        if (name) request.filename = name;
    } else request = [PNSendFileRequest requestWithChannel:channel fileName:name data:data];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    request.cipherKey = cipherKey ?: self.configuration.cipherKey;
#pragma clang diagnostic pop
    request.fileMessageMetadata = parameters[NSStringFromSelector(@selector(fileMessageMetadata))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    request.message = parameters[NSStringFromSelector(@selector(message))];
    
    if (store) request.fileMessageStore = store.boolValue;
    if (store && store.boolValue && ttl) request.fileMessageTTL = ttl.unsignedIntegerValue;
    
    [self sendFileWithRequest:request completion:parameters[@"block"]];
}

- (void)listFilesRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSNumber *limit = parameters[NSStringFromSelector(@selector(limit))];

    PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:channel];
    request.next = parameters[NSStringFromSelector(@selector(next))];
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    if (limit) request.limit = limit.unsignedIntegerValue;
    
    [self listFilesWithRequest:request completion:parameters[@"block"]];
}

- (void)downloadFileURLUsingBuilderParameters:(NSDictionary *)parameters {
    NSString *identifier = parameters[NSStringFromSelector(@selector(identifier))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSString *name = parameters[NSStringFromSelector(@selector(name))];
    PNFileDownloadURLCompletionBlock completion = parameters[@"block"];
    
    completion([self downloadURLForFileWithName:name identifier:identifier inChannel:channel]);
}

- (void)downloadFileRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSString *identifier = parameters[NSStringFromSelector(@selector(identifier))];
    NSString *cipherKey = parameters[NSStringFromSelector(@selector(cipherKey))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSString *name = parameters[NSStringFromSelector(@selector(name))];
    
    PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:channel identifier:identifier name:name];
    request.targetURL = parameters[NSStringFromSelector(@selector(url))];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    request.cipherKey = cipherKey ?: self.configuration.cipherKey;
#pragma clang diagnostic pop
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    
    [self downloadFileWithRequest:request completion:parameters[@"block"]];
}

- (void)deleteFileRequestUsingBuilderParameters:(NSDictionary *)parameters {
    NSString *identifier = parameters[NSStringFromSelector(@selector(identifier))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSString *name = parameters[NSStringFromSelector(@selector(name))];
    
    PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:channel identifier:identifier name:name];
    request.arbitraryQueryParameters = parameters[@"queryParam"];
    
    [self deleteFileWithRequest:request completion:parameters[@"block"]];
}


#pragma mark - File upload

- (void)sendFileWithRequest:(PNSendFileRequest *)userRequest completion:(PNSendFileCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNGenerateFileUploadURLStatus class]];
    PNSendFileCompletionBlock block = [handlerBlock copy];

    PNGenerateFileUploadURLRequest *urlRequest = nil;
    urlRequest = [PNGenerateFileUploadURLRequest requestWithChannel:userRequest.channel filename:userRequest.filename];
    urlRequest.arbitraryQueryParameters = userRequest.arbitraryQueryParameters;
    [urlRequest setupWithClientConfiguration:self.configuration];
    PNParsedRequestCompletionBlock handler;

    if (!userRequest.cryptoModule) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSString *cipherKey = userRequest.cipherKey ?: self.configuration.cipherKey;
        if (!cipherKey) userRequest.cryptoModule = self.configuration.cryptoModule;
        else if (![cipherKey isEqualToString:self.configuration.cipherKey]) {
            // Construct backward-compatible crypto module.
            userRequest.cryptoModule = [PNCryptoModule legacyCryptoModuleWithCipherKey:cipherKey
                                                            randomInitializationVector:YES];
        } else userRequest.cryptoModule = self.configuration.cryptoModule;
#pragma clang diagnostic pop
    }

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNGenerateFileUploadURLStatus *, PNGenerateFileUploadURLStatus *> *result) {
        PNStrongify(self);
        
        PNGenerateFileUploadURLStatus *status = result.status;

        if (!status.isError) {
            [self handleGenerateFileUploadURLSuccessWithStatus:status sendFileRequest:userRequest completion:block];
        } else [self handleGenerateFileUploadURLErrorWithStatus:status sendFileRequest:userRequest completion:block];
    };
    
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Send file with parameters:"];
    }];

    [self performRequest:urlRequest withParser:responseParser completion:handler];
}


#pragma mark - List files

- (void)listFilesWithRequest:(PNListFilesRequest *)userRequest completion:(PNListFilesCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNListFilesResult class]
                                                            status:[PNErrorStatus class]];
    PNListFilesCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler;

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNListFilesResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.result) {
            [result.result.data setFilesDownloadURLWithBlock:^NSURL *(NSString *identifier, NSString *name) {
                return [self downloadURLForFileWithName:name identifier:identifier inChannel:userRequest.channel];
            }];
            
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"List files success. There are %@ uploaded "
                                                                         "files.", @(result.result.data.files.count))];
            }];
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };
    
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"List files with parameters:"];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}


#pragma mark - Download files

- (NSURL *)downloadURLForFileWithName:(NSString *)name identifier:(NSString *)identifier inChannel:(NSString *)channel {
    if (!name.length || !identifier.length || !channel.length) return nil;
    
    PNGenerateFileDownloadURLRequest *request;
    request = [PNGenerateFileDownloadURLRequest requestWithChannel:channel fileIdentifier:identifier fileName:name];
    [request setupWithClientConfiguration:self.configuration];

    if ([request validate]) return nil;

    PNTransportRequest *transportRequest = [self.serviceNetwork transportRequestFromTransportRequest:request.request];
    NSMutableString *path = [transportRequest.path mutableCopy];
    NSDictionary *query = transportRequest.query;

    if (query.count > 0) {
        NSMutableArray *keyValuePairs = [NSMutableArray arrayWithCapacity:query.count];
        [query enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, __unused BOOL *stop) {
            value = [value isKindOfClass:[NSString class]] ? [PNString percentEscapedString:value] : value;
            [keyValuePairs addObject:PNStringFormat(@"%@=%@", key, value)];
        }];

        [path appendFormat:@"?%@", [keyValuePairs componentsJoinedByString:@"&"]];
    }

    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:transportRequest.origin]];
}

- (void)downloadFileWithRequest:(PNDownloadFileRequest *)userRequest completion:(PNDownloadFileCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNErrorStatus class]];
    responseParser.errorOnly = YES;
    PNDownloadFileCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler;

    if (!userRequest.cryptoModule) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSString *cipherKey = userRequest.cipherKey ?: self.configuration.cipherKey;
        if (!cipherKey) userRequest.cryptoModule = self.configuration.cryptoModule;
        else if (![cipherKey isEqualToString:self.configuration.cipherKey]) {
            // Construct backward-compatible crypto module.
            userRequest.cryptoModule = [PNCryptoModule legacyCryptoModuleWithCipherKey:cipherKey
                                                            randomInitializationVector:YES];
        } else userRequest.cryptoModule = self.configuration.cryptoModule;
#pragma clang diagnostic pop
    }

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, NSURL *url,
                PNOperationDataParseResult<PNErrorStatus *, PNErrorStatus*> *result) {
        PNStrongify(self);
        BOOL temporary = userRequest.targetURL == nil;

        [self.filesManager handleDownloadedFileAtURL:url 
                                        withStoreURL:userRequest.targetURL
                                        cryptoModule:userRequest.cryptoModule
                                          completion:^(NSURL *location, NSError *error) {
            PNErrorStatus *status = result.status;
            PNDownloadFileResult *downloadResult;

            if (error && !status) {
                PNErrorData *data = [PNErrorData dataWithError:error];
                status = [PNErrorStatus objectWithOperation:userRequest.operation
                                                   category:PNUnknownCategory
                                                   response:data];
            }

            if (status && status.isError && status.category == PNUnknownCategory)
                status.category = PNDownloadErrorCategory;

            if (!status.isError) {
                PNFileDownloadData *data = [PNFileDownloadData dataForFileAtLocation:location temporarily:temporary];
                downloadResult = [PNDownloadFileResult objectWithOperation:userRequest.operation response:data];
                
                [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                    return [PNStringLogEntry entryWithMessage:@"Download file success."];
                }];
            }

            if (!temporary) [self callBlock:block status:NO withResult:downloadResult andStatus:status];
            else if (block) block(downloadResult, status);
        }];
    };
    
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Download file with parameters:"];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}


#pragma mark - Delete files

- (void)deleteFileWithRequest:(PNDeleteFileRequest *)userRequest completion:(PNDeleteFileCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAcknowledgmentStatus class]];
    PNDeleteFileCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAcknowledgmentStatus *, PNAcknowledgmentStatus *> *result) {
        PNStrongify(self);

        if (!result.status.isError) {
            [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Delete file success. Deleted file with "
                                                                         "%@ ID.", userRequest.identifier)];
            }];
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
    
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Delete file with parameters:"];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}


#pragma mark - Handlers

- (void)handleGenerateFileUploadURLSuccessWithStatus:(PNGenerateFileUploadURLStatus *)generateStatus
                                     sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                          completion:(PNSendFileCompletionBlock)block {
    PNFileUploadRequest *userRequest = [PNFileUploadRequest requestWithURL:generateStatus.data.requestURL
                                                                httpMethod:generateStatus.data.httpMethod
                                                                  formData:generateStatus.data.formFields];
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAcknowledgmentStatus class]
                                                      cryptoModule:sendFileRequest.cryptoModule];
    responseParser.errorOnly = YES;
    userRequest.cryptoModule = sendFileRequest.cryptoModule;
    userRequest.filename = generateStatus.data.filename;
    userRequest.bodyStream = sendFileRequest.stream;
    userRequest.dataSize = sendFileRequest.size;
    PNParsedRequestCompletionBlock handler;
    
    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNErrorStatus *, PNErrorStatus *> *result) {
        PNStrongify(self);
        PNErrorStatus *status = result.status;

        if (status.isError) {
            [self handleUploadFileErrorWithFileIdentifier:generateStatus.data.fileIdentifier
                                                     name:generateStatus.data.filename
                                                 category:result.status.category
                                               completion:block];
        } else {
            [self handleUploadFileSuccessWithFileIdentifier:generateStatus.data.fileIdentifier
                                                   fileName:generateStatus.data.filename
                                            sendFileRequest:sendFileRequest
                                                 completion:block];
        }
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)handleGenerateFileUploadURLErrorWithStatus:(PNGenerateFileUploadURLStatus *)status
                                   sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                        completion:(PNSendFileCompletionBlock)block {
    PNStatusCategory category = status.category != PNUnknownCategory ? status.category : PNSendFileErrorCategory;
    PNFileSendData *fileData = [PNFileSendData fileDataWithId:status.data.fileIdentifier name:status.data.filename];
    PNSendFileStatus *sendStatus = [PNSendFileStatus objectWithOperation:sendFileRequest.operation
                                                                category:category
                                                                response:fileData];
    sendStatus.error = YES;

    [self callBlock:block status:YES withResult:nil andStatus:sendStatus];
}

- (void)handleUploadFileSuccessWithFileIdentifier:(NSString *)fileIdentifier
                                         fileName:(NSString *)fileName
                                  sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                       completion:(PNSendFileCompletionBlock)handlerBlock {
    NSUInteger fileMessagePublishRetryLimit = self.configuration.fileMessagePublishRetryLimit;
    PNSendFileCompletionBlock block = [handlerBlock copy];
    PNPublishFileMessageRequest *request = nil;

    request = [PNPublishFileMessageRequest requestWithChannel:sendFileRequest.channel
                                               fileIdentifier:fileIdentifier
                                                         name:fileName];
    request.arbitraryQueryParameters = sendFileRequest.arbitraryQueryParameters;
    request.customMessageType = sendFileRequest.customMessageType;
    request.metadata = sendFileRequest.fileMessageMetadata;
    request.store = sendFileRequest.fileMessageStore;
    request.message = sendFileRequest.message;
    request.publishOnFileSharing = YES;
    if (request.store) request.ttl = sendFileRequest.fileMessageTTL;
    
    __block __weak PNPublishCompletionBlock weakPublishCompletion = nil;
    __block PNPublishCompletionBlock publishCompletion = nil;
    __block NSUInteger publishAttemptsCount = 1;
    PNWeakify(self);
                                           
    publishCompletion = ^(PNPublishStatus *status) {
        __strong PNPublishCompletionBlock strongPublishCompletion = weakPublishCompletion;
        PNStrongify(self);
        
        if (!status.isError || !strongPublishCompletion || publishAttemptsCount >= fileMessagePublishRetryLimit) {
            PNFileSendData *data = [PNFileSendData fileDataWithId:fileIdentifier name:fileName];
            PNSendFileStatus *sendFileStatus = nil;
            
            if (!status.isError) {
                data.timetoken = status.data.timetoken;
                sendFileStatus = [PNSendFileStatus objectWithOperation:sendFileRequest.operation response:data];
                sendFileStatus.category = PNAcknowledgmentCategory;
            } else {
                [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
                    return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Send file success. File shared with "
                                                                             "%@ ID.", fileIdentifier)];
                }];
                
                data.category = status.category;
                sendFileStatus = [PNSendFileStatus objectWithOperation:sendFileRequest.operation
                                                              category:status.category
                                                              response:data];
            }
            
            sendFileStatus.data.fileUploaded = YES;
            sendFileStatus.error = status.isError;
            
            [self callBlock:block status:YES withResult:nil andStatus:sendFileStatus];
        } else {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            int64_t delayInNanoseconds = (int64_t)(1 * NSEC_PER_SEC);
            publishAttemptsCount++;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInNanoseconds), queue, ^{
                [self publishFileMessageWithRequest:request completion:strongPublishCompletion];
            });
        }
    };
    weakPublishCompletion = publishCompletion;

    [self publishFileMessageWithRequest:request completion:publishCompletion];
}

- (void)handleUploadFileErrorWithFileIdentifier:(NSString *)fileIdentifier
                                           name:(NSString *)fileName
                                       category:(PNStatusCategory)category
                                     completion:(PNSendFileCompletionBlock)block {
    PNFileSendData *data = [PNFileSendData fileDataWithId:fileIdentifier name:fileName];
    category = category != PNUnknownCategory ? category : PNSendFileErrorCategory;
    PNSendFileStatus *status = [PNSendFileStatus objectWithOperation:PNSendFileOperation category:category response:data];
    status.error = YES;

    [self callBlock:block status:YES withResult:nil andStatus:status];
}

#pragma mark -


@end
