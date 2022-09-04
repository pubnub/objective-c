/**
 * @author Sergey Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNAcknowledgmentStatus.h"
#import "PNMultipartInputStream.h"
#import "PNConfiguration.h"
#import "PNFilesManager.h"
#import "PNErrorParser.h"
#import "PNErrorCodes.h"
#import "PubNub+Core.h"
#import "PNXMLParser.h"
#import "PNAES+Private.h"

#if !TARGET_OS_OSX
#import <MobileCoreServices/MobileCoreServices.h>
#endif // !TARGET_OS_OSX


#pragma mark Constants

/**
 * @brief How many simultaneous connections can be opened to single host.
 */
static NSUInteger const kPNFilesManagerSessionMaximumConnections = 2;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNFilesManager () <NSURLSessionTaskDelegate, NSURLSessionDelegate>


#pragma mark - Information

/**
 * @brief Queue which should be used by session to call callbacks and completion blocks on
 * \b PNFilesManager instance.
 */
@property (nonatomic, strong) NSOperationQueue *delegateQueue;

/**
 * @brief Session which is used to send network requests.
 */
@property (nonatomic, strong, nullable) NSURLSession *session;

/**
 * @brief Maximum simultaneous requests.
 */
@property (nonatomic, assign) NSInteger maximumConnections;

/**
 * @brief Cipher key which should be used for data encryption / decryption.
 */
@property (nonatomic, nullable, copy) NSString *cipherKey;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize and configure files manager.
 *
 * @param client \b PubNub client for which files manager should be created.
 *
 * @return Initialized and ready to use client files manager.
 */
- (instancetype)initWithClient:(PubNub *)client;


#pragma mark - Session constructor

/**
 * @brief Complete \a NSURLSession instantiation and configuration.
 *
 * @param maximumConnections Maximum simultaneously connections (requests) which can be opened.
 */
- (void)prepareSessionWithMaximumConnections:(NSInteger)maximumConnections;

/**
 * @brief Create base \a NSURLSession configuration.
 *
 * @param maximumConnections Maximum simultaneously connections (requests) which can be opened.
 *
 * @return Constructed and ready to use session configuration.
 */
- (NSURLSessionConfiguration *)configurationWithMaximumConnections:(NSInteger)maximumConnections;

/**
 * @brief Construct queue on which session will call delegate callbacks and completion blocks.
 *
 * @param configuration Session configuration which should be used to complete queue configuration.
 *
 * @return Initialized and ready to use operation queue.
 */
- (NSOperationQueue *)operationQueueWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 * @brief Construct \a NSURLSession manager used to communicate with \b PubNub network.
 *
 * @param configuration Complete configuration which should be applied to \a NSURL session.
 *
 * @return Constructed and ready to use \a NSURLSession manager instance.
 */
- (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;


#pragma mark - Misc

/**
 * @brief Create data upload error using information received from server.
 *
 * @param task Task which has been used to upload data.
 * @param response Server's HTTP response on data upload request.
 * @param data Server's response body.
 * @param error Upload request processing error.
 *
 * @return \a Error object with detailed information about file upload error.
 */
- (NSError *)uploadErrorForTask:(nullable NSURLSessionDataTask *)task
                   httpResponse:(nullable NSHTTPURLResponse *)response
                   responseData:(nullable NSData *)data
                          error:(nullable NSError *)error;

/**
 * @brief Create data download error using information received from server.
 *
 * @param task Task which has been used to download data.
 * @param response Server's HTTP response on data download request.
 * @param location Location where requested data has been downloaded (can be error JSON / XML file).
 * @param error Download request processing error.
 *
 * @return \a Error object with detailed information about file download error.
 */
- (NSError *)downloadErrorForTask:(nullable NSURLSessionDownloadTask *)task
                     httpResponse:(nullable NSHTTPURLResponse *)response
                     fileLocation:(nullable NSURL *)location
                            error:(nullable NSError *)error;

/**
 * @brief Create input stream which is able to provide stream-based data.
 *
 * @param boundary Boundary which should be used to separate \c multipart/form-data fields in POST body.
 * @param stream Input stream with data which should be uploaded.
 * @param filename Name which should be used to store uploaded data.
 * @param cipherKey Key which should be used to encrypt data before upload.
 * @param streamsTotalSize Pointer which is used to store overall input streams size.
 */
- (nullable NSInputStream *)multipartFormDataStreamWithBoundary:(NSString *)boundary
                                                dataInputStream:(NSInputStream *)stream
                                                       filename:(NSString *)filename
                                                      cipherKey:(nullable NSString *)cipherKey
                                                     fromFields:(NSArray<NSDictionary *> *)fields
                                                    streamsSize:(NSUInteger *)streamsTotalSize;

/**
 * @brief Prepare provided multipart/form-data fields to be sent with request POST body.
 *
 * @param boundary Separator for key/value pairs.
 * @param fields List of multipart/form-data fields which should be processed.
 *
 * @return Data object which can be sent with request post body or \c nil in case if there is no
 * \c fields provided.
 */
- (nullable NSData *)multipartFormDataWithBoundary:(NSString *)boundary
                                        fromFields:(NSArray<NSDictionary *> *)fields;

/**
 * @brief Prepare multipart/form-data file data to be sent with request POST body.
 *
 * @param filename Name under which uploaded data should be stored.
 * @param boundary Separator for key/value pairs.
 *
 * @return Data object which can be sent with request post body.
 */
- (NSData *)multipartFormFile:(NSString *)filename dataWithBoundary:(NSString *)boundary;

/**
 * @brief Multipart form data end data.
 *
 * @param boundary Separator for key/value pairs.
 *
 * @return Data object which should be send at the end of multipart/form-data HTTP body stream.
 */
- (NSData *)multipartFormEndDataWithBoundary:(NSString *)boundary;

/**
 * @brief Identify file MIME type using file extension.
 *
 * @param filename Name from which extension should be examined.
 *
 * @return Actual file MIME type or \c application/octet-stream if type can't be identified.
 */
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
        _cipherKey = [client.currentConfiguration.cipherKey copy];
        
        [self prepareSessionWithMaximumConnections:kPNFilesManagerSessionMaximumConnections];
    }
    
    return self;
}


#pragma mark - Upload data

- (void)uploadWithRequest:(NSURLRequest *)request
                 formData:(NSArray<NSDictionary *> *)formData
                 filename:(NSString *)filename
                 dataSize:(NSUInteger)dataSize
                cipherKey:(NSString *)cipherKey
               completion:(void(^)(NSError *error))block {
    
    NSInputStream *httpBodyInputStream = request.HTTPBodyStream;
    NSMutableURLRequest *uploadRequest = [request mutableCopy];
    cipherKey = cipherKey ?: self.cipherKey;
    
    if (formData.count) {
        NSString *boundary = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-"
                                                                                 withString:@""];
        NSString *contentType = [@"multipart/form-data; boundary=" stringByAppendingString:boundary];
        [uploadRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
        httpBodyInputStream = [self multipartFormDataStreamWithBoundary:boundary
                                                        dataInputStream:httpBodyInputStream
                                                               filename:filename
                                                              cipherKey:cipherKey
                                                             fromFields:formData
                                                            streamsSize:&dataSize];
        
        [uploadRequest setValue:@(dataSize).stringValue forHTTPHeaderField:@"Content-Length"];
        
        if (!httpBodyInputStream) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"Unable to create HTTP body stream",
                NSLocalizedFailureReasonErrorKey: @"Provided data streams opened or file is missing",
                @"statusCode": @400
            };
            
            NSError *uploadError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                       code:kPNAPIUnacceptableParameters
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
            uploadError = [self uploadErrorForTask:task
                                      httpResponse:httpResponse
                                      responseData:data
                                             error:error];
        }
        
        block(uploadError);
    }];
    
    [task resume];
}


#pragma mark - Download data

- (void)downloadFileAtURL:(NSURL *)remoteURL
                    toURL:(NSURL *)localURL
            withCipherKey:(NSString *)cipherKey
               completion:(void(^)(NSURLRequest *request, NSURL *location, NSError *error))block {
    
    __block NSURLSessionDownloadTask *task = nil;
    
    if (!remoteURL) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Unable complete request",
            NSLocalizedFailureReasonErrorKey: @"Remote resource URL is missing"
        };
        
        NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                             code:kPNAPIUnacceptableParameters
                                         userInfo:userInfo];
        
        block(nil, nil, error);
        return;
    }
    
    task = [self.session downloadTaskWithURL:remoteURL
                           completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSURLRequest *downloadRequest = task.originalRequest;
        NSURL *downloadedFileURL = localURL;
        BOOL temporary = NO;
        
        if (!downloadedFileURL) {
            NSString *tmpDirectory = [location.path stringByDeletingLastPathComponent];
            downloadedFileURL = [NSURL URLWithString:[tmpDirectory stringByAppendingPathComponent:[NSUUID UUID].UUIDString]];
            temporary = YES;
        }
        
        if (httpResponse.statusCode >= 400 || error) {
            NSError *requestError = [self downloadErrorForTask:task
                                                  httpResponse:httpResponse
                                                  fileLocation:location
                                                         error:error];
            block(downloadRequest, location, requestError);
        } else {
            NSURL *localFileURL = downloadedFileURL.isFileURL ? downloadedFileURL
                                                              : [NSURL fileURLWithPath:downloadedFileURL.path];
            NSURL *destinationURL = cipherKey.length ? [localFileURL URLByAppendingPathExtension:@"enc"]
                                                     : localFileURL;
            NSFileManager *fileManager = NSFileManager.defaultManager;
            NSError *fileMoveError = nil;

            if ([destinationURL checkResourceIsReachableAndReturnError:nil]) {
                [fileManager removeItemAtURL:destinationURL error:&fileMoveError];
            }
            
            if (!fileMoveError) {
                [fileManager moveItemAtURL:location toURL:destinationURL error:&fileMoveError];
            }
            
            if (fileMoveError) {
                NSError *error = [self downloadErrorForTask:nil
                                               httpResponse:nil
                                               fileLocation:nil
                                                      error:fileMoveError];
                
                block(downloadRequest, location, error);
            } else if(cipherKey.length) {
                [PNAES decryptFileAtURL:destinationURL
                                  toURL:localFileURL
                          withCipherKey:cipherKey
                             completion:^(NSURL *location, NSError *error) {
                    
                    block(downloadRequest, location, error);
                    
                    if (temporary && ![fileManager removeItemAtURL:location error:&error]) {
                        NSLog(@"<PubNub::FilesManager> Temporary file clean up error: %@",
                              error);
                    }
                    
                    if (![fileManager removeItemAtURL:destinationURL error:&error]) {
                        NSLog(@"<PubNub::FilesManager> Encrypted file clean up error: %@", error);
                    }
                }];
            } else {
                block(downloadRequest, destinationURL, nil);
                
                if (temporary && ![fileManager removeItemAtURL:destinationURL error:&error]) {
                    NSLog(@"<PubNub::FilesManager> Temporary file clean up error: %@",
                          error);
                }
            }
        }
    }];
    
    [task resume];
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
    return [NSURLSession sessionWithConfiguration:configuration
                                         delegate:self
                                    delegateQueue:self.delegateQueue];;
}


#pragma mark - URLSession & Tasks delegate callbacks

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (!error) {
        return;
    }
    
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
        uploadError = [NSError errorWithDomain:kPNStorageErrorDomain
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
        downloadError = [NSError errorWithDomain:kPNStorageErrorDomain
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
    
    if (location) {
        data = [NSData dataWithContentsOfURL:location];
    }
    
    if ([request.URL.absoluteString rangeOfString:@".s3."].location != NSNotFound) {
        if (data.length) {
            PNXMLParser *parser = [PNXMLParser parserWithData:data];
            PNXML *parsedXML = [parser parse];
            NSString *errorMessage = [parsedXML valueForKeyPath:@"Error.Message"];
            NSString *errorCode = [parsedXML valueForKeyPath:@"Error.Code"];
            
            if (errorMessage) {
                failureReason = errorMessage;
            } else if (!failureReason) {
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
                
                if ([_s3AccessDeniedCodes containsObject:errorCode]) {
                    statusCode = 403;
                } else if ([errorCode isEqualToString:@"MethodNotAllowed"]) {
                    statusCode = 405;
                } else if ([errorCode isEqualToString:@"InvalidBucketState"]) {
                    statusCode = 409;
                } else if ([errorCode isEqualToString:@"MissingContentLength"]) {
                    statusCode = 411;
                } else if ([_s3NotFoundCodes containsObject:errorCode]) {
                    statusCode = 404;
                } else if ([errorCode isEqualToString:@"InternalError"]) {
                    statusCode = 500;
                } else if ([errorCode isEqualToString:@"NotImplemented"]) {
                    statusCode = 501;
                } else if ([_s3NotAvailableCodes containsObject:errorCode]) {
                    statusCode = 503;
                }
            }
        }
    } else {
        serviceResponse = [PNErrorParser parsedServiceResponse:data];
        
        if (serviceResponse) {
            failureReason = serviceResponse[@"information"];
            
            if (serviceResponse[@"status"]) {
                statusCode = ((NSNumber *)serviceResponse[@"status"]).unsignedIntegerValue;
            }
        }
    }
    
    if (error) {
        userInfo[NSUnderlyingErrorKey] = error;
    }
    
    userInfo[NSLocalizedFailureReasonErrorKey] = failureReason ?: @"Unknown error reason";
    userInfo[NSLocalizedDescriptionKey] = failureDescription ?: @"Unknown error";
    userInfo[@"statusCode"] = @(statusCode);
    
    if (serviceResponse) {
        userInfo[@"pn_serviceResponse"] = serviceResponse;
    }
    
    return userInfo;
}

- (NSInputStream *)multipartFormDataStreamWithBoundary:(NSString *)boundary
                                       dataInputStream:(NSInputStream *)stream
                                              filename:(NSString *)filename
                                             cipherKey:(NSString *)cipherKey
                                            fromFields:(NSArray<NSDictionary *> *)fields
                                           streamsSize:(NSUInteger *)streamsTotalSize {
    
    NSString *fileMIMEType = [self mimeTypeFromFilename:filename];
    NSNumber *fileStreamSize = @(*streamsTotalSize);
    
    if (fileMIMEType.length) {
        NSMutableArray<NSDictionary *> *mutableFields = [fields mutableCopy];
        
        for (NSUInteger fieldIdx = 0; fieldIdx < fields.count; fieldIdx++) {
            if (![fields[fieldIdx][@"key"] isEqualToString:@"Content-Type"]) {
                continue;
            }

            NSMutableDictionary *mutableField = [fields[fieldIdx] mutableCopy];
            NSString *fieldValue = mutableField[@"value"];
            
            if (fieldValue.length == 0 ||
                [fieldValue rangeOfString:@"octet-stream"].location != NSNotFound) {
                
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
    NSMutableArray<NSNumber *> *streamSizes = [NSMutableArray new];
    NSInputStream *formDataStream = nil;
    
    if (multipartFormData) {
        [streamSizes addObject:@(multipartFormData.length)];
        [inputStreams addObject:[NSInputStream inputStreamWithData:multipartFormData]];
    }
    
    if (fileFormData) {
        [streamSizes addObject:@(fileFormData.length)];
        *streamsTotalSize += fileFormData.length;
        [inputStreams addObject:[NSInputStream inputStreamWithData:fileFormData]];
    }
    
    [streamSizes addObject:fileStreamSize];
    [inputStreams addObject:stream];
    
    NSData *multipartFormEndData = [self multipartFormEndDataWithBoundary:boundary];
    [streamSizes addObject:@(multipartFormEndData.length)];
    [inputStreams addObject:[NSInputStream inputStreamWithData:multipartFormEndData]];
    *streamsTotalSize += multipartFormEndData.length;
    
    if (inputStreams.count == 4) {
        formDataStream = [PNMultipartInputStream streamWithInputStreams:inputStreams
                                                                  sizes:streamSizes
                                                              cipherKey:cipherKey];
        
        *streamsTotalSize = ((PNMultipartInputStream *)formDataStream).size;
    } else {
        *streamsTotalSize = 0;
    }
    
    return formDataStream;
}

- (NSData *)multipartFormDataWithBoundary:(NSString *)boundary
                               fromFields:(NSArray<NSDictionary *> *)fields {
    
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
    
    if (uti != NULL) {
        CFRelease(uti);
    }
    
    return mimeType ?: @"application/octet-stream";
}

#pragma mark -


@end
