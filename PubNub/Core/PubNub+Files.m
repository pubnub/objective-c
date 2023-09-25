/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNGenerateFileUploadURLRequest.h"
#import "PNGenerateFileUploadURLStatus.h"
#import "PNDownloadFileRequest+Private.h"
#import "PNSendFileRequest+Private.h"
#import "PNOperationResult+Private.h"
#import "PNAPICallBuilder+Private.h"
#import "PNSendFileStatus+Private.h"
#import "PubNub+CorePrivate.h"
#import "PubNub+PAMPrivate.h"
#import "PNStatus+Private.h"
#import "PNPublishStatus.h"
#import "PNConfiguration.h"
#import "PubNub+Publish.h"
#import "PNCryptoModule.h"
#import "PNErrorStatus.h"
#import "PNURLBuilder.h"
#import "PubNub+Files.h"
#import "PNErrorCodes.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PubNub (FilesProtected)


#pragma mark - API Builder support

/**
 * @brief Process information provider by user with builder API call and use it to send request which will upload file.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)sendFileRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request which will fetch uploaded files list.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)listFilesRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and generate file download URL.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)downloadFileURLUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to download specific file.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)downloadFileRequestUsingBuilderParameters:(NSDictionary *)parameters;

/**
 * @brief Process information provider by user with builder API call and use it to send request which will delete specific file.
 *
 * @param parameters Dictionary with information passed to builder-based API.
 */
- (void)deleteFileRequestUsingBuilderParameters:(NSDictionary *)parameters;


#pragma mark - Handlers

/**
 * @brief Handle upload URL generation success.
 *
 * @param status Status object with information which can be used to upload data specified by \c sendFileRequest.
 * @param sendFileRequest Original \c send \c file request used to trigger upload URL generation.
 * @param block \c Send \c file request processing completion block.
 */
- (void)handleGenerateFileUploadURLSuccessWithStatus:(PNGenerateFileUploadURLStatus *)status
                                     sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                          completion:(PNSendFileCompletionBlock)block;

/**
 * @brief Handle upload URL generation failure.
 *
 * @param status Status object with information about what exactly went wrong during data upload.
 * @param sendFileRequest Original \c send \c file request used to trigger upload URL generation.
 * @param block \c Send \c file request processing completion block.
 */
- (void)handleGenerateFileUploadURLErrorWithStatus:(PNGenerateFileUploadURLStatus *)status
                                   sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                        completion:(PNSendFileCompletionBlock)block;

/**
 * @brief Handle \c file \c upload success.
 *
 * @param fileIdentifier Unique identifier which has been assigned to file during upload (upload URL generation).
 * @param fileName Actual file name which has been used to store uploaded data (can be different from what has been configured
 *   with \c sendFileRequest).
 * @param sendFileRequest Original \c send \c file request used to trigger \c file \c upload.
 * @param block \c Send \c file request processing completion block.
 */
- (void)handleUploadFileSuccessWithFileIdentifier:(NSString *)fileIdentifier
                                         fileName:(NSString *)fileName
                                  sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                       completion:(PNSendFileCompletionBlock)block;

/**
 * @brief Handle \c file \c upload failure.
 *
 * @param fileIdentifier Unique identifier which has been assigned to file during upload (upload URL generation).
 * @param fileName Actual file name which has been used to store uploaded data (can be different from what has been configured
 *   with \c sendFileRequest).
 * @param error Error instance with information about what exactly went wrong during data upload.
 * @param block \c Send \c file request processing completion block.
 */
- (void)handleUploadFileErrorWithFileIdentifier:(NSString *)fileIdentifier
                                           name:(NSString *)fileName
                                          error:(NSError *)error
                                     completion:(PNSendFileCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


@implementation PubNub (Files)


#pragma mark - API Builder support

- (PNFilesAPICallBuilder * (^)(void))files {
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
        request = [PNSendFileRequest requestWithChannel:channel
                                               fileName:name
                                                 stream:stream
                                                   size:size.unsignedIntegerValue];
    } else if (url) {
        request = [PNSendFileRequest requestWithChannel:channel fileURL:url];
        if (name) request.filename = name;
    } else {
        request = [PNSendFileRequest requestWithChannel:channel fileName:name data:data];
    }
    
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

- (void)sendFileWithRequest:(PNSendFileRequest *)request completion:(PNSendFileCompletionBlock)block {
    PNGenerateFileUploadURLRequest *urlRequest = nil;
    urlRequest = [PNGenerateFileUploadURLRequest requestWithChannel:request.channel filename:request.filename];
    urlRequest.parametersError = request.parametersError;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (!request.cryptoModule) {
        NSString *cipherKey = request.cipherKey ?: self.configuration.cipherKey;
        if (!cipherKey) request.cryptoModule = self.configuration.cryptoModule;
        else if (![cipherKey isEqualToString:self.configuration.cipherKey]) {
            // Construct backward-compatible crypto module.
            request.cryptoModule = [PNCryptoModule legacyCryptoModuleWithCipherKey:cipherKey
                                                        randomInitializationVector:YES];
        }
    }
#pragma clang diagnostic pop

    // Retrieving URL which should be used for data upload.
    [self performRequest:urlRequest withCompletion:^(PNGenerateFileUploadURLStatus *status) {
        if (!status.isError) {
            [self handleGenerateFileUploadURLSuccessWithStatus:status sendFileRequest:request completion:block];
        } else {
            [self handleGenerateFileUploadURLErrorWithStatus:status sendFileRequest:request completion:block];
        }
    }];
}

#pragma mark - List files

- (void)listFilesWithRequest:(PNListFilesRequest *)request completion:(PNListFilesCompletionBlock)block {
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNListFilesResult *result, PNErrorStatus *status) {
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf listFilesWithRequest:request completion:block];
            };
        } else {
            NSMutableDictionary *serviceData = [result.serviceData mutableCopy];
            NSMutableArray<NSDictionary *> *updatedFiles = [NSMutableArray new];
            NSArray<NSDictionary *> *files = serviceData[@"files"];
            
            for (NSDictionary *file in files) {
                NSMutableDictionary *updatedFile = [file mutableCopy];
                NSURL *downloadURL = [weakSelf downloadURLForFileWithName:file[@"name"]
                                                               identifier:file[@"id"]
                                                                inChannel:request.channel];
                updatedFile[@"downloadURL"] = downloadURL.absoluteString;
                [updatedFiles addObject:updatedFile];
            }
            
            serviceData[@"files"] = updatedFiles;
            [status updateData:serviceData];
        }
        
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}


#pragma mark - Download files

- (NSURL *)downloadURLForFileWithName:(NSString *)name identifier:(NSString *)identifier inChannel:(NSString *)channel {
    if (!name.length || !identifier.length || !channel.length) return nil;
    
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http%@://%@",
                                           (self.configuration.TLSEnabled ? @"s" : @""),
                                           self.configuration.origin]];
    PNRequestParameters *parameters = [PNRequestParameters new];
    [parameters addPathComponents:@{ @"{channel}": channel, @"{id}": identifier, @"{name}": name }];
    [parameters addPathComponents:self.defaultPathComponents];
    [parameters addQueryParameters:self.defaultQueryComponents];
    [self addAuthParameter:parameters];
    
    if (parameters.shouldIncludeTelemetry) {
        [parameters addQueryParameters:[self.telemetryManager operationsLatencyForRequest]];
    }
    
    [parameters addQueryParameter:[[NSUUID UUID] UUIDString] forFieldName:@"requestid"];

    NSURL *requestURL = [PNURLBuilder URLForOperation:PNDownloadFileOperation withParameters:parameters];
    
    return [NSURL URLWithString:requestURL.absoluteString relativeToURL:baseURL];
}

- (void)downloadFileWithRequest:(PNDownloadFileRequest *)request completion:(PNDownloadFileCompletionBlock)block {
    NSURL *downloadURL = [self downloadURLForFileWithName:request.name
                                               identifier:request.identifier
                                                inChannel:request.channel];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (!request.cryptoModule) {
        NSString *cipherKey = request.cipherKey ?: self.configuration.cipherKey;
        if (!cipherKey) request.cryptoModule = self.configuration.cryptoModule;
        else if (![cipherKey isEqualToString:self.configuration.cipherKey]) {
            // Construct backward-compatible crypto module.
            request.cryptoModule = [PNCryptoModule legacyCryptoModuleWithCipherKey:cipherKey
                                                        randomInitializationVector:YES];
        }
    }
#pragma clang diagnostic pop
    BOOL temporary = request.targetURL == nil;
    __weak __typeof(self) weakSelf = self;
    
    [self.filesManager downloadFileAtURL:downloadURL
                                   toURL:request.targetURL
                        withCryptoModule:request.cryptoModule
                              completion:^(NSURLRequest *downloadRequest, NSURL *location, NSError *error) {
        PNDownloadFileResult *result = nil;
        PNErrorStatus *errorStatus = nil;

        if (error) {
            NSDictionary *serviceData = error.userInfo[@"pn_serviceResponse"];
            errorStatus = [PNErrorStatus objectForOperation:request.operation
                                          completedWithTask:nil
                                              processedData:serviceData
                                            processingError:error];
            
            if ([error.domain isEqualToString:kPNStorageErrorDomain] && errorStatus.statusCode == -1) {
                errorStatus.statusCode = error.code;
            }
            
            if (errorStatus.category == PNUnknownCategory) [errorStatus setCategory:PNDownloadErrorCategory];
            
            [self appendClientInformation:errorStatus];
            errorStatus.error = YES;
            
            errorStatus.retryBlock = ^{
                [weakSelf downloadFileWithRequest:request completion:block];
            };
        } else {
            NSDictionary *serviceData = @{ @"temporary": @(temporary), @"location": location.absoluteString };
            result = [PNDownloadFileResult objectForOperation:request.operation
                                            completedWithTask:nil
                                                processedData:serviceData
                                              processingError:nil];
            result.clientRequest = downloadRequest;
        }
        
        if (!temporary) [weakSelf callBlock:block status:NO withResult:result andStatus:errorStatus];
        else if (block) block(result, errorStatus);
    }];
}


#pragma mark - Delete files

- (void)deleteFileWithRequest:(PNDeleteFileRequest *)request completion:(PNDeleteFileCompletionBlock)block {
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAcknowledgmentStatus *status) {
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf deleteFileWithRequest:request completion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}


#pragma mark - Handlers

- (void)handleGenerateFileUploadURLSuccessWithStatus:(PNGenerateFileUploadURLStatus *)status
                                     sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                          completion:(PNSendFileCompletionBlock)block {
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:status.data.requestURL];
    uploadRequest.HTTPMethod = status.data.httpMethod.uppercaseString;
    uploadRequest.HTTPBodyStream = sendFileRequest.stream;
    
    [self.filesManager uploadWithRequest:uploadRequest
                                formData:status.data.formFields
                                filename:status.data.filename
                                dataSize:sendFileRequest.size
                        withCryptoModule:sendFileRequest.cryptoModule
                              completion:^(NSError *uploadError) {
        if (uploadError) {
            [self handleUploadFileErrorWithFileIdentifier:status.data.fileIdentifier
                                                     name:status.data.filename
                                                    error:uploadError
                                               completion:block];
        } else {
            [self handleUploadFileSuccessWithFileIdentifier:status.data.fileIdentifier
                                                   fileName:status.data.filename
                                            sendFileRequest:sendFileRequest
                                                 completion:block];
        }
    }];
}

- (void)handleGenerateFileUploadURLErrorWithStatus:(PNGenerateFileUploadURLStatus *)status
                                   sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                        completion:(PNSendFileCompletionBlock)block {
    PNStatusCategory category = status.category != PNUnknownCategory ? status.category : PNSendFileErrorCategory;
    NSMutableDictionary *serviceData = [(status.serviceData ?: @{}) mutableCopy];
    serviceData[@"status"] = @(status.statusCode);
    if (!serviceData[@"information"]) serviceData[@"information"] = @"Unknown error";

    PNSendFileStatus *sendStatus = [PNSendFileStatus objectForOperation:sendFileRequest.operation
                                                      completedWithTask:nil
                                                          processedData:serviceData
                                                        processingError:nil];
    sendStatus.retryBlock = ^{};

    [sendStatus setCategory:category];
    [self appendClientInformation:sendStatus];
    sendStatus.error = YES;
    
    [self callBlock:block status:YES withResult:nil andStatus:sendStatus];
}

- (void)handleUploadFileSuccessWithFileIdentifier:(NSString *)fileIdentifier
                                         fileName:(NSString *)fileName
                                  sendFileRequest:(PNSendFileRequest *)sendFileRequest
                                       completion:(PNSendFileCompletionBlock)block {
    NSUInteger fileMessagePublishRetryLimit = self.configuration.fileMessagePublishRetryLimit;
    PNPublishFileMessageRequest *request = nil;
    __weak __typeof(self) weakSelf = self;
    
    request = [PNPublishFileMessageRequest requestWithChannel:sendFileRequest.channel
                                               fileIdentifier:fileIdentifier
                                                         name:fileName];
    
    request.arbitraryQueryParameters = sendFileRequest.arbitraryQueryParameters;
    request.metadata = sendFileRequest.fileMessageMetadata;
    request.store = sendFileRequest.fileMessageStore;
    request.message = sendFileRequest.message;
    if (request.store) request.ttl = sendFileRequest.fileMessageTTL;
    
    __block NSUInteger publishAttemptsCount = 1;
    
    [self publishFileMessageWithRequest:request completion:^(PNPublishStatus *status) {
        if (!status.isError || publishAttemptsCount >= fileMessagePublishRetryLimit) {
            PNSendFileStatus *sendFileStatus = nil;
            NSMutableDictionary *serviceData = [@{ @"id": fileIdentifier, @"name": fileName } mutableCopy];
            if (status.data.timetoken) serviceData[@"timetoken"] = status.data.timetoken;

            if (status.isError) {
                serviceData[@"information"] = status.serviceData[@"information"];
                serviceData[@"status"] = @(status.statusCode) ?: @(400);
            }

            sendFileStatus = [PNSendFileStatus objectForOperation:sendFileRequest.operation
                                                completedWithTask:nil
                                                    processedData:serviceData
                                                  processingError:nil];
            sendFileStatus.data.fileUploaded = YES;

            [weakSelf appendClientInformation:sendFileStatus];
            sendFileStatus.error = status.isError;
            sendFileStatus.retryBlock = ^{};
            
            [weakSelf callBlock:block status:YES withResult:nil andStatus:sendFileStatus];
        } else {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            int64_t delayInNanoseconds = (int64_t)(1 * NSEC_PER_SEC);
            publishAttemptsCount++;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInNanoseconds), queue, ^{
                [status retry];
            });
        }
    }];
}

- (void)handleUploadFileErrorWithFileIdentifier:(NSString *)fileIdentifier
                                           name:(NSString *)fileName
                                          error:(NSError *)error
                                     completion:(PNSendFileCompletionBlock)block {
    NSDictionary *serviceData = error.userInfo[@"pn_serviceResponse"];
    PNSendFileStatus *sendStatus = [PNSendFileStatus objectForOperation:PNSendFileOperation
                                                      completedWithTask:nil
                                                          processedData:serviceData
                                                        processingError:error];
    sendStatus.data.fileUploaded = YES;
    sendStatus.retryBlock = ^{};
    
    if ([error.domain isEqualToString:kPNStorageErrorDomain] && sendStatus.statusCode == -1) {
        sendStatus.statusCode = error.code;
    }
 
    NSMutableDictionary *updatedServiceData = [NSMutableDictionary dictionaryWithDictionary:sendStatus.serviceData];
    [updatedServiceData addEntriesFromDictionary:@{ @"id": fileIdentifier, @"name": fileName }];
    [sendStatus updateData:updatedServiceData];
    
    if (sendStatus.category == PNUnknownCategory) [sendStatus setCategory:PNSendFileErrorCategory];
    [self appendClientInformation:sendStatus];
    sendStatus.error = YES;
    
    [self callBlock:block status:YES withResult:nil andStatus:sendStatus];
}

#pragma mark -


@end
