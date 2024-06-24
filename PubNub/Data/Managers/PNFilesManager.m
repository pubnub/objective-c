#import "PNAcknowledgmentStatus.h"
#import "NSInputStream+PNCrypto.h"
#import "PNSequenceInputStream.h"
#import "PNCryptorInputStream.h"
#import "NSInputStream+PNURL.h"
#import "PubNub+CorePrivate.h"
#import "PNConfiguration.h"
#import "PNFilesManager.h"
#import "PNCryptoModule.h"
#import "PNErrorParser.h"
#import "PNAES+Private.h"
#import "PubNub+Core.h"
#import "PNXMLParser.h"
#import "PNError.h"

#if !TARGET_OS_OSX
#import <MobileCoreServices/MobileCoreServices.h>
#endif // !TARGET_OS_OSX


#pragma mark Constants

/// How many simultaneous connections can be opened to single host.
static NSUInteger const kPNFilesManagerSessionMaximumConnections = 2;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

/// Files manager private extension.
@interface PNFilesManager () <NSURLSessionTaskDelegate, NSURLSessionDelegate>


#pragma mark - Information

/// Queue which should be used by session to call callbacks and completion blocks on `PNFilesManager` instance.
@property (nonatomic, strong) NSOperationQueue *delegateQueue;

/// Session which is used to send network requests.
@property (nonatomic, strong, nullable) NSURLSession *session;

/// Maximum simultaneous requests.
@property (nonatomic, assign) NSInteger maximumConnections;

/// Crypto module for data processing.
///
/// **PubNub** client uses this instance to _encrypt_ and _decrypt_ data that has been sent and received from the
/// **PubNub** network.
@property(nonatomic, nullable, strong) id<PNCryptoProvider> cryptoModule;


#pragma mark - Initialization and configuration

/// Initialize files manager.
///
/// - Parameter client: **PubNub** client for which files manager should be created.
/// - Returns: Initialized files manager instance.
- (instancetype)initWithClient:(PubNub *)client;


#pragma mark - Session constructor

/// Complete `NSURLSession` instantiation and configuration.
///
/// - Parameter maximumConnections: Maximum simultaneously connections (requests) which can be opened.
- (void)prepareSessionWithMaximumConnections:(NSInteger)maximumConnections;

/// Create base `NSURLSession` configuration.
///
/// - Parameter maximumConnections: Maximum simultaneously connections (requests) which can be opened.
/// - Returns: Initialized `NSURLSession` configuration instance.
- (NSURLSessionConfiguration *)configurationWithMaximumConnections:(NSInteger)maximumConnections;

/// Create queue on which session will call delegate callbacks and completion blocks.
///
/// - Parameter configuration: Session configuration which should be used to complete queue configuration.
/// - Returns: Initialized operation queue instance.
- (NSOperationQueue *)operationQueueWithConfiguration:(NSURLSessionConfiguration *)configuration;

/// Create `NSURLSession` manager used to communicate with **PubNub** network.
///
/// - Parameter configuration: Complete configuration which should be applied to `NSURL` session.
/// - Returns: Initialized `NSURLSession` manager instance.
- (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;


#pragma mark - Helpers

/// Create data upload error using information received from the service.
///
/// - Parameters:
///   - task: Task which has been used to upload data.
///   - response: Service's HTTP response on data upload request.
///   - data: Service's response body.
///   - error: Upload request processing error.
/// - Returns: `Error` object with detailed information about file upload error.
- (NSError *)uploadErrorForTask:(nullable NSURLSessionDataTask *)task
                   httpResponse:(nullable NSHTTPURLResponse *)response
                   responseData:(nullable NSData *)data
                          error:(nullable NSError *)error;

/// Create data download error using information received from the service.
///
/// - Parameters:
///   - task: Task which has been used to download data.
///   - response: Service's HTTP response on data download request.
///   - location: Location where requested data has been downloaded (can be error JSON / XML file).
///   - error: Download request processing error.
/// - Returns: `Error` object with detailed information about file download error.
- (NSError *)downloadErrorForTask:(nullable NSURLSessionDownloadTask *)task
                     httpResponse:(nullable NSHTTPURLResponse *)response
                     fileLocation:(nullable NSURL *)location
                            error:(nullable NSError *)error;

/// Create input stream with `multipart/form-data` stream-based data.
///
/// - Parameters:
///   - boundary: Boundary which should be used to separate `multipart/form-data` fields in POST body.
///   - stream: Input stream with data which should be uploaded.
///   - filename: Name which should be used to store uploaded data.
///   - cryptoModule: Crypto module for data _encryption_.
///   - fields: List of multipart/form-data fields which should be processed.
///   - streamsTotalSize: Pointer which is used to store overall input streams size.
/// - Returns: Initialized input stream with `multipart/form-data` stream-based data.
- (nullable NSInputStream *)multipartFormDataStreamWithBoundary:(NSString *)boundary
                                                dataInputStream:(NSInputStream *)stream
                                                       filename:(NSString *)filename
                                                   cryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
                                                     fromFields:(NSArray<NSDictionary *> *)fields
                                                    streamsSize:(NSUInteger *)streamsTotalSize;

/// Prepare provided multipart/form-data fields to be sent with request POST body.
///
/// - Parameters:
///   - boundary: Separator for key/value pairs.
///   - fields: List of multipart/form-data fields which should be processed.
/// - Returns: Data object which can be sent with request post body or \c nil in case if there is no `fields` provided.
- (nullable NSData *)multipartFormDataWithBoundary:(NSString *)boundary fromFields:(NSArray<NSDictionary *> *)fields;

/// Prepare multipart/form-data file data to be sent with request POST body.
///
/// - Parameters:
///   - filename: Name under which uploaded data should be stored.
///   - boundary: Separator for key/value pairs.
/// - Returns: Data object which can be sent with request post body.
- (NSData *)multipartFormFile:(NSString *)filename dataWithBoundary:(NSString *)boundary;

/// Multipart form data end data.
///
/// - Parameter boundary: Separator for key/value pairs.
/// - Returns: Data object which should be send at the end of multipart/form-data HTTP body stream.
- (NSData *)multipartFormEndDataWithBoundary:(NSString *)boundary;

/// Identify file MIME type using file extension.
///
/// - Parameter filename: Name from which extension should be examined.
/// - Returns: Actual file MIME type or `application/octet-stream` if type can't be identified.
- (NSString *)mimeTypeFromFilename:(NSString *)filename;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFilesManager


#pragma mark - Initialization and Configuration

+ (instancetype)filesManagerForClient:(PubNub *)client {
    return [[self alloc] initWithClient:client];
}

- (instancetype)initWithClient:(PubNub *)client {
    if ((self = [super init])) {
        _cryptoModule = client.configuration.cryptoModule;
        [self prepareSessionWithMaximumConnections:kPNFilesManagerSessionMaximumConnections];
    }
    
    return self;
}


#pragma mark - Upload data

- (void)uploadWithRequest:(NSURLRequest *)request
                 formData:(NSArray<NSDictionary *> *)formData
                 filename:(NSString *)filename
                 dataSize:(NSUInteger)dataSize
         withCryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
               completion:(void(^)(NSError *error))block {
    NSInputStream *httpBodyInputStream = request.HTTPBodyStream;
    NSMutableURLRequest *uploadRequest = [request mutableCopy];
    cryptoModule = cryptoModule ?: self.cryptoModule;

    if (formData.count) {
        NSString *boundary = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *contentType = [@"multipart/form-data; boundary=" stringByAppendingString:boundary];
        [uploadRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
        httpBodyInputStream = [self multipartFormDataStreamWithBoundary:boundary
                                                        dataInputStream:httpBodyInputStream
                                                               filename:filename
                                                           cryptoModule:cryptoModule
                                                             fromFields:formData
                                                            streamsSize:&dataSize];
        
        [uploadRequest setValue:@(dataSize).stringValue forHTTPHeaderField:@"Content-Length"];
        
        if (!httpBodyInputStream) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"Unable to create HTTP body stream",
                NSLocalizedFailureReasonErrorKey: @"Provided data streams opened or file is missing",
                @"statusCode": @400
            };
            
            NSError *uploadError = [NSError errorWithDomain:PNAPIErrorDomain
                                                       code:PNAPIErrorUnacceptableParameters
                                                   userInfo:userInfo];
            
            block(uploadError);
            return;
        }
    }
    
    uploadRequest.HTTPBodyStream = httpBodyInputStream;
    
    __block NSURLSessionDataTask *task = nil;
    task = [self.session dataTaskWithRequest:uploadRequest
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSError *uploadError = nil;
        
        if (httpResponse.statusCode >= 400 || error) {
            uploadError = [self uploadErrorForTask:task httpResponse:httpResponse responseData:data error:error];
        }
        
        block(uploadError);
    }];
    
    [task resume];
}


#pragma mark - Download data

- (void)downloadFileAtURL:(NSURL *)remoteURL
                    toURL:(NSURL *)localURL
         withCryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
               completion:(void(^)(NSURLRequest *request, NSURL *location, NSError *error))block {
    cryptoModule = cryptoModule ?: self.cryptoModule;
    __block NSURLSessionDownloadTask *task = nil;
    BOOL temporary = !localURL;

    if (!localURL) {
        localURL = [NSURL URLWithString:[NSString pathWithComponents:@[NSTemporaryDirectory(), [NSUUID UUID].UUIDString]]];
    }

    if (!localURL.isFileURL) localURL = [NSURL fileURLWithPath:localURL.path];
    
    if (!remoteURL) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Unable complete request",
            NSLocalizedFailureReasonErrorKey: @"Remote resource URL is missing"
        };
        
        NSError *error = [NSError errorWithDomain:PNAPIErrorDomain
                                             code:PNAPIErrorUnacceptableParameters
                                         userInfo:userInfo];
        
        block(nil, nil, error);
        return;
    }
    
    task = [self.session downloadTaskWithURL:remoteURL
                           completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSURLRequest *downloadRequest = task.originalRequest;
        
        if (httpResponse.statusCode >= 400 || error) {
            NSError *requestError = [self downloadErrorForTask:task
                                                  httpResponse:httpResponse
                                                  fileLocation:location
                                                         error:error];
            block(downloadRequest, location, requestError);
        } else {

            NSFileManager *fileManager = NSFileManager.defaultManager;
            NSURL *storeURL = temporary ? location : localURL;
            NSError *fileMoveError = nil;

            if (!temporary && [storeURL checkResourceIsReachableAndReturnError:nil]) {
                [fileManager removeItemAtURL:storeURL error:&fileMoveError];
            }

            if (cryptoModule) {
                if (temporary) storeURL = [storeURL URLByAppendingPathExtension:@"dec"];
            } else if (!fileMoveError && !temporary) {
                [fileManager moveItemAtURL:location toURL:storeURL error:&fileMoveError];
            }
            
            if (fileMoveError) {
                NSError *error = [self downloadErrorForTask:nil httpResponse:nil fileLocation:nil error:fileMoveError];
                block(downloadRequest, location, error);
            } else if(cryptoModule) {
                NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:location.path error:&error];
                NSUInteger fileSize = ((NSNumber *)[fileAttributes objectForKey:NSFileSize]).unsignedIntegerValue;
                NSInputStream *sourceStream = [NSInputStream inputStreamWithURL:location];

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    PNResult<NSInputStream *> *decryptResult = [cryptoModule decryptStream:sourceStream
                                                                                dataLength:fileSize];
                    NSError *decryptError = decryptResult.error;

                    if (!decryptResult.isError) {
                        [decryptResult.data pn_writeToFileAtURL:storeURL withBufferSize:1024 * 1024 error:&decryptError];
                    }

                    block(downloadRequest, !decryptResult.isError ? storeURL : nil, decryptError);

                    if (temporary && !decryptError && ![fileManager removeItemAtURL:location error:&decryptError]) {
                        NSLog(@"<PubNub::FilesManager> Encrypted file clean up error: %@", decryptError);
                    }
                });
            } else {
                NSError *tempRemoveError = nil;
                block(downloadRequest, storeURL, tempRemoveError);

                if (temporary && ![fileManager removeItemAtURL:location error:&tempRemoveError]) {
                    NSLog(@"<PubNub::FilesManager> Temporary file clean up error: %@", tempRemoveError);
                }
            }
        }
    }];
    
    [task resume];
}

- (void)handleDownloadedFileAtURL:(NSURL *)location withStoreURL:(NSURL *)localURL cryptoModule:(nullable id<PNCryptoProvider>)cryptoModule completion:(void(^)( NSURL *location, NSError *error))block {
    if (!location) block(nil, nil);
    
    cryptoModule = cryptoModule ?: self.cryptoModule;
    BOOL temporary = !localURL;

    if (temporary) {
        localURL = [NSURL URLWithString:[NSString pathWithComponents:@[NSTemporaryDirectory(), [NSUUID UUID].UUIDString]]];
    }

    if (!localURL.isFileURL) localURL = [NSURL fileURLWithPath:localURL.path];

    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSURL *storeURL = temporary ? location : localURL;
    NSError *fileMoveError = nil;

    if (!temporary && [storeURL checkResourceIsReachableAndReturnError:nil]) {
        [fileManager removeItemAtURL:storeURL error:&fileMoveError];
    }

    if (cryptoModule) {
        if (temporary) storeURL = [storeURL URLByAppendingPathExtension:@"dec"];
    } else if (!fileMoveError && !temporary) [fileManager moveItemAtURL:location toURL:storeURL error:&fileMoveError];

    if (fileMoveError) {
        NSError *error = [self downloadErrorForTask:nil httpResponse:nil fileLocation:nil error:fileMoveError];
        block(location, error);
    } else if(cryptoModule) {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:location.path error:nil];
        NSUInteger fileSize = ((NSNumber *)[fileAttributes objectForKey:NSFileSize]).unsignedIntegerValue;
        NSInputStream *sourceStream = [NSInputStream inputStreamWithURL:location];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNResult<NSInputStream *> *decryptResult = [cryptoModule decryptStream:sourceStream dataLength:fileSize];
            NSError *decryptError = decryptResult.error;

            if (!decryptResult.isError) {
                [decryptResult.data pn_writeToFileAtURL:storeURL withBufferSize:1024 * 1024 error:&decryptError];
            }

            block(!decryptResult.isError ? storeURL : nil, decryptError);
#ifndef PUBNUB_DISABLE_LOGGER
            if (temporary && !decryptError && ![fileManager removeItemAtURL:location error:&decryptError]) {
                NSLog(@"<PubNub::FilesManager> Encrypted file clean up error: %@", decryptError);
            }
#endif // PUBNUB_DISABLE_LOGGER
        });
    } else {
        NSError *tempRemoveError = nil;
        block(storeURL, tempRemoveError);
#ifndef PUBNUB_DISABLE_LOGGER
        if (temporary && ![fileManager removeItemAtURL:location error:&tempRemoveError]) {
            NSLog(@"<PubNub::FilesManager> Temporary file clean up error: %@", tempRemoveError);
        }
#endif // PUBNUB_DISABLE_LOGGER
    }
}

#pragma mark - Session constructor

- (void)prepareSessionWithMaximumConnections:(NSInteger)maximumConnections {
    self.maximumConnections = maximumConnections;
    NSURLSessionConfiguration *configuration = [self configurationWithMaximumConnections:maximumConnections];
    self.delegateQueue = [self operationQueueWithConfiguration:configuration];
    self.session = [self sessionWithConfiguration:configuration];
}

- (NSURLSessionConfiguration *)configurationWithMaximumConnections:(NSInteger)maximumConnections {
    NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
    configuration.HTTPMaximumConnectionsPerHost = maximumConnections;
    
    return configuration;
}

- (NSOperationQueue *)operationQueueWithConfiguration:(NSURLSessionConfiguration *)configuration {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = configuration.HTTPMaximumConnectionsPerHost;
    
    return queue;
}

- (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration {
    return [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.delegateQueue];
}


#pragma mark - URLSession & Tasks delegate callbacks

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (!error) return;
    [self prepareSessionWithMaximumConnections:self.maximumConnections];
}


#pragma mark - Misc

- (void)invalidate {
    [self.session finishTasksAndInvalidate];
}

- (NSError *)uploadErrorForTask:(NSURLSessionDataTask *)task
                   httpResponse:(NSHTTPURLResponse *)response
                   responseData:(NSData *)data
                          error:(NSError *)error {
    NSError *uploadError = nil;
    NSDictionary *userInfo = [self errorUserInfoForFailedRequest:task.currentRequest
                                                withHTTPResponse:response
                                                    responseData:data
                                                    fileLocation:nil
                                                           error:error];

    if (response) {
        NSNumber *statusCode = userInfo[@"statusCode"];
        uploadError = [NSError errorWithDomain:PNStorageErrorDomain
                                          code:statusCode.integerValue
                                      userInfo:userInfo];
    } else {
        uploadError = error;
    }

    return uploadError;
}

- (NSError *)downloadErrorForTask:(NSURLSessionDownloadTask *)task
                     httpResponse:(NSHTTPURLResponse *)response
                     fileLocation:(NSURL *)location
                            error:(NSError *)error {
    NSError *downloadError = nil;
    NSDictionary *userInfo = [self errorUserInfoForFailedRequest:task.currentRequest
                                                withHTTPResponse:response
                                                    responseData:nil
                                                    fileLocation:location
                                                           error:error];

    if (response) {
        NSNumber *statusCode = userInfo[@"statusCode"];
        downloadError = [NSError errorWithDomain:PNStorageErrorDomain
                                            code:statusCode.integerValue
                                        userInfo:userInfo];
    } else {
        downloadError = error;
    }

    return downloadError;
}

- (NSDictionary *)errorUserInfoForFailedRequest:(NSURLRequest *)request
                               withHTTPResponse:(NSHTTPURLResponse *)response
                                   responseData:(NSData *)data
                                   fileLocation:(NSURL *)location
                                          error:(NSError *)error {
    NSString *failureDescription = error.localizedDescription ?: @"Unable to complete request";
    NSUInteger statusCode = response ? response.statusCode : 400;
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    NSString *failureReason = error.localizedFailureReason;
    NSDictionary *serviceResponse = nil;
    
    if (location) data = [NSData dataWithContentsOfURL:location];
    if ([request.URL.absoluteString rangeOfString:@".s3."].location != NSNotFound) {
        if (data.length) {
            PNXMLParser *parser = [PNXMLParser parserWithData:data];
            PNXML *parsedXML = [parser parse];
            NSString *errorMessage = [parsedXML valueForKeyPath:@"Error.Message"];
            NSString *errorCode = [parsedXML valueForKeyPath:@"Error.Code"];
            
            if (errorMessage) failureReason = errorMessage;
            else if (!failureReason) {
                failureReason = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            
            if (errorCode) {
                static NSArray<NSString *> *_s3AccessDeniedCodes;
                static NSArray<NSString *> *_s3NotAvailableCodes;
                static NSArray<NSString *> *_s3NotFoundCodes;
                static dispatch_once_t onceToken;
                
                dispatch_once(&onceToken, ^{
                    _s3AccessDeniedCodes = @[
                        @"AccessDenied", @"AccountProblem", @"AllAccessDisabled",
                        @"InvalidAccessKeyId", @"InvalidObjectState", @"InvalidPayer",
                        @"InvalidSecurity", @"NotSignedUp", @"RequestTimeTooSkewed",
                        @"SignatureDoesNotMatch"
                    ];
                    
                    _s3NotAvailableCodes = @[@"ServiceUnavailable", @"SlowDown"];
                    _s3NotFoundCodes = @[
                        @"NoSuchBucket", @"NoSuchBucketPolicy", @"NoSuchKey",
                        @"NoSuchLifecycleConfiguration", @"NoSuchUpload", @"NoSuchVersion"
                    ];
                });
                
                if ([_s3AccessDeniedCodes containsObject:errorCode]) statusCode = 403;
                else if ([errorCode isEqualToString:@"MethodNotAllowed"]) statusCode = 405;
                else if ([errorCode isEqualToString:@"InvalidBucketState"]) statusCode = 409;
                else if ([errorCode isEqualToString:@"MissingContentLength"]) statusCode = 411;
                else if ([_s3NotFoundCodes containsObject:errorCode]) statusCode = 404;
                else if ([errorCode isEqualToString:@"InternalError"]) statusCode = 500;
                else if ([errorCode isEqualToString:@"NotImplemented"]) statusCode = 501;
                else if ([_s3NotAvailableCodes containsObject:errorCode]) statusCode = 503;
            }
        }
    } else {
        serviceResponse = [PNErrorParser parsedServiceResponse:data];
        
        if (serviceResponse) {
            failureReason = serviceResponse[@"information"];
            if (serviceResponse[@"status"]) statusCode = ((NSNumber *)serviceResponse[@"status"]).unsignedIntegerValue;
        }
    }
    
    if (error) userInfo[NSUnderlyingErrorKey] = error;
    userInfo[NSLocalizedFailureReasonErrorKey] = failureReason ?: @"Unknown error reason";
    userInfo[NSLocalizedDescriptionKey] = failureDescription ?: @"Unknown error";
    userInfo[@"statusCode"] = @(statusCode);
    if (serviceResponse) userInfo[@"pn_serviceResponse"] = serviceResponse;
    
    return userInfo;
}

- (NSInputStream *)multipartFormDataStreamWithBoundary:(NSString *)boundary
                                       dataInputStream:(NSInputStream *)stream
                                              filename:(NSString *)filename
                                          cryptoModule:(id<PNCryptoProvider>)cryptoModule
                                            fromFields:(NSArray<NSDictionary *> *)fields
                                           streamsSize:(NSUInteger *)streamsTotalSize {
    NSString *fileMIMEType = [self mimeTypeFromFilename:filename];
    
    if (fileMIMEType.length) {
        NSMutableArray<NSDictionary *> *mutableFields = [fields mutableCopy];
        
        for (NSUInteger fieldIdx = 0; fieldIdx < fields.count; fieldIdx++) {
            if (![fields[fieldIdx][@"key"] isEqualToString:@"Content-Type"]) continue;
            NSMutableDictionary *mutableField = [fields[fieldIdx] mutableCopy];
            NSString *fieldValue = mutableField[@"value"];
            
            if (fieldValue.length == 0 || [fieldValue rangeOfString:@"octet-stream"].location != NSNotFound) {
                mutableField[@"value"] = fileMIMEType;
                mutableFields[fieldIdx] = mutableField;
                fields = [mutableFields copy];
            }
            
            break;
        }
    }
    
    NSData *multipartFormData = [self multipartFormDataWithBoundary:boundary fromFields:fields];
    NSData *fileFormData = [self multipartFormFile:filename dataWithBoundary:boundary];
    NSMutableArray<NSInputStream *> *inputStreams = [NSMutableArray new];
    NSMutableArray<NSNumber *> *streamLengths = [NSMutableArray new];
    NSInputStream *formDataStream = nil;
    
    if (multipartFormData) {
        [streamLengths addObject:@(multipartFormData.length)];
        [inputStreams addObject:[NSInputStream inputStreamWithData:multipartFormData]];
    }
    
    if (fileFormData) {
        [streamLengths addObject:@(fileFormData.length)];
        [inputStreams addObject:[NSInputStream inputStreamWithData:fileFormData]];
    }

    NSNumber *fileStreamSize = @(*streamsTotalSize);
    if (cryptoModule) {
        PNResult<NSInputStream *> *encryptResult = [cryptoModule encryptStream:stream dataLength:*streamsTotalSize];
        if (!encryptResult.isError) {
            stream = encryptResult.data;
            fileStreamSize = @(stream.pn_dataLength);
        }
    }
    [streamLengths addObject:fileStreamSize];
    [inputStreams addObject:stream];
    
    NSData *multipartFormEndData = [self multipartFormEndDataWithBoundary:boundary];
    [streamLengths addObject:@(multipartFormEndData.length)];
    [inputStreams addObject:[NSInputStream inputStreamWithData:multipartFormEndData]];
    
    if (inputStreams.count == 4) {
        formDataStream = [PNSequenceInputStream inputStreamWithInputStreams:inputStreams lengths:streamLengths];
        *streamsTotalSize = ((PNSequenceInputStream *)formDataStream).length;
    } else {
        *streamsTotalSize = 0;
    }
    
    return formDataStream;
}

- (NSData *)multipartFormDataWithBoundary:(NSString *)boundary fromFields:(NSArray<NSDictionary *> *)fields {
    NSMutableData *multipartFormData = [NSMutableData new];
    
    [fields enumerateObjectsUsingBlock:^(NSDictionary *fieldData, NSUInteger fieldDataIdx, BOOL *stop) {
       NSString *fieldValue = fieldData[@"value"];
       NSString *fieldName = fieldData[@"key"];

       [multipartFormData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                                      dataUsingEncoding:NSUTF8StringEncoding]];
       [multipartFormData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                                       fieldName]
                                      dataUsingEncoding:NSUTF8StringEncoding]];
       [multipartFormData appendData:[[NSString stringWithFormat:@"%@\r\n", fieldValue]
                                      dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    return multipartFormData;
}

- (NSData *)multipartFormFile:(NSString *)filename dataWithBoundary:(NSString *)boundary {
    NSMutableData *multipartFormFileData = [NSMutableData new];

    [multipartFormFileData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                                   dataUsingEncoding:NSUTF8StringEncoding]];
    [multipartFormFileData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n\r\n", filename]
                                   dataUsingEncoding:NSUTF8StringEncoding]];
    
    return multipartFormFileData;
}

- (NSData *)multipartFormEndDataWithBoundary:(NSString *)boundary {
    return [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)mimeTypeFromFilename:(NSString *)filename {
    CFStringRef extension = (__bridge CFStringRef _Nonnull)filename.pathExtension;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    NSString *mimeType = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType));
    if (uti != NULL) CFRelease(uti);
    
    return mimeType ?: @"application/octet-stream";
}

#pragma mark -


@end
