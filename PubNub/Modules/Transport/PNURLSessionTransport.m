#import "PNURLSessionTransport.h"
#if TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)
#import <UIKit/UIKit.h>
#endif // TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)
#import <PubNub/PNRequestRetryConfiguration+Private.h>
#import <PubNub/PNTransportRequest+Private.h>
#import <PubNub/NSError+PNTransport.h>
#import <PubNub/PNFunctions.h>
#import <PubNub/PNLogMacro.h>
#import <PubNub/PNHelpers.h>
#import <PubNub/PNGZIP.h>
#import <PubNub/PNLock.h>

#import "NSURLSessionConfiguration+PNConfigurationPrivate.h"
#import "PNURLSessionTransportResponse.h"


#pragma mark Static


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `NSURLSession`-based transport module private extension.
@interface PNURLSessionTransport () <NSURLSessionDelegate, NSURLSessionDataDelegate>


#pragma mark - Properties

#if TARGET_OS_OSX
/// Identifier which has been used to request from system more time to complete pending tasks when client resign
/// active.
@property(strong, nullable, nonatomic) id<NSObject> tasksCompletionIdentifier;
#endif // TARGET_OS_OSX
#if TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)
/// Identifier which has been used to request from system more time to complete pending tasks when client resign
/// active.
@property(assign, nonatomic) UIBackgroundTaskIdentifier tasksCompletionIdentifier;
#endif // TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)

/// List of the currently active requests.
@property(strong, nonatomic) NSMutableArray<PNTransportRequest *> *requests;

/// Transport module configuration.
@property(copy, nonatomic) PNTransportConfiguration *configuration;

/// Default request caching policy.
@property(assign, nonatomic) NSURLRequestCachePolicy cachePolicy;

/// List of headers which should be added to each request.
@property(copy, nonatomic) NSDictionary *HTTPAdditionalHeaders;

/// Session which should be used to create requests to remote origin endpoints.
@property(strong, nullable, nonatomic) NSURLSession *session;

/// Cancelled requests filter predicate.
@property(strong, nonatomic) NSPredicate *cancelledPredicate;

/// Unique `PubNub` transport instance identifier.
@property(strong, nonatomic) NSString *identifier;

/// Resources access lock.
@property(strong, nonatomic) PNLock *lock;


#pragma mark - URL Session

/// Configure transport's URL session for requests processing.
- (void)setupURLSession;

/// Retrieve platform-specific `NSURLSession` instance configuration.
///
/// - Returns: Suitable `NSURLSessionConfiguration` instance.
- (NSURLSessionConfiguration *)urlSessionConfiguration;


#pragma mark - Request

/// Create `NSURLRequest` from transport-independent request object.
///
/// - Parameter transportRequest: Request object with all required information to send it using `NSURLSession`.
/// - Returns: Configured and ready to use `request` instance.
- (NSURLRequest *)requestFromTransportRequest:(PNTransportRequest *)transportRequest;

/// Handle `NSURLRequest` processing results.
///
/// - Parameters:
///   - request: Transport request object which has been used to create `NSURLSessionTask`.
///   - task: Processed `NSURLSession` task (data or download).
///   - response: Remote service response information object.
///   - data: Remote service response payload.
/// - Returns: Pre-processed transport-independent service response object.
- (id<PNTransportResponse>)handleRequest:(PNTransportRequest *)request
                          taskCompletion:(NSURLSessionTask *)task
                            withResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data;


#pragma mark - State

/// Complere background task (if any).
///
/// Free up system resources when background execution context not rrquired anymore.
- (void)endBackgroundTasksCompletionIfRequired;


#pragma mark - Misc

/// Create request porcessing error (if required).
///
/// - Parameters:
///   - request: Transport request object which has been used to create `NSURLSessionTask`.
///   - requestUrl: Final URL which has been used to access resource on remote origin.
///   - transportError: Error generated by NSURLSession task while processed `request`.
- (nullable PNError *)errorForRequest:(PNTransportRequest *)request
                              withURL:(nullable NSURL *)requestUrl
                                error:(nullable NSError *)transportError;

#ifndef PUBNUB_DISABLE_LOGGER
/// Print out any session configuration instance customizations which have been done by developer.
- (void)printIfRequiredSessionCustomizationInformation;
#endif // PUBNUB_DISABLE_LOGGER

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNURLSessionTransport


#pragma mark - Initialization and Configuration

- (void)setupWithConfiguration:(PNTransportConfiguration *)configuration {
    self.configuration = configuration;
    
    _cancelledPredicate = [NSPredicate predicateWithBlock:^BOOL(PNTransportRequest *request, __unused id bindings) {
        return !request.cancelled;
    }];
    
#if TARGET_OS_IOS
    _tasksCompletionIdentifier = UIBackgroundTaskInvalid;
#endif // TARGET_OS_IOS
    
    _lock = [PNLock lockWithIsolationQueueName:@"transport" subsystemQueueIdentifier:@"com.pubnub.transport"];
    _configuration = [configuration copy];
    _requests = [NSMutableArray new];
    
    // Finalyze transport configuration.
    [self setupURLSession];

#ifndef PUBNUB_DISABLE_LOGGER
    [self printIfRequiredSessionCustomizationInformation];
#endif // PUBNUB_DISABLE_LOGGER
}


#pragma mark - Information

- (void)requestsWithBlock:(void (^)(NSArray<PNTransportRequest *> *))block {
    if (!block) return;
    
    [self.lock syncWriteAccessWithBlock:^{
        block(self.requests);
        // Filter out potentially cancelled requests after block has been called.
        [self.requests filterUsingPredicate:self.cancelledPredicate];
    }];
}


#pragma mark - Request processing

- (void)sendRequest:(PNTransportRequest *)request withCompletionBlock:(PNRequestCompletionBlock)block {
    NSURLRequest *urlRequest = [self requestFromTransportRequest:request];
    block = [block copy];
    
    PNWeakify(self);
    __block NSURLSessionTask *task;
    task = [self.session dataTaskWithRequest:urlRequest
                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        PNStrongify(self);
        BOOL retriableError = error && error.code != NSURLErrorCancelled;
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        BOOL retriableStatusCode = statusCode >= 400 && statusCode != 403;
        NSTimeInterval delay = 0.f;

        if ((retriableError || retriableStatusCode) && request.retriable) {
            PNRequestRetryConfiguration *retry = self.configuration.retryConfiguration;
            NSUInteger retryAttempt = request.retryAttempt + 1;
            delay = [retry retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:retryAttempt];
        }
        
        if (delay > 0.f) {
            request.retryAttempt += 1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self sendRequest:request withCompletionBlock:block];
            });
        } else {
            block(request,
                  [self handleRequest:request taskCompletion:task withResponse:response data:data],
                  [self errorForRequest:request withURL:task.originalRequest.URL error:error]
            );
        }
    }];
    
    [self sendRequest:request withSessionTask:task];
}

- (void)sendDownloadRequest:(PNTransportRequest *)request withCompletionBlock:(PNDownloadRequestCompletionBlock)block {
    NSURLRequest *urlRequest = [self requestFromTransportRequest:request];
    block = [block copy];
    
    PNWeakify(self);
    __block NSURLSessionTask *task;
    task = [self.session downloadTaskWithRequest:urlRequest
                               completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        PNStrongify(self);
        BOOL retriableError = error && error.code != NSURLErrorCancelled;
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        BOOL retriableStatusCode = statusCode >= 400 && statusCode != 403;
        NSTimeInterval delay = 0.f;
        
        if ((retriableError || retriableStatusCode) && request.retriable) {
            PNRequestRetryConfiguration *retry = self.configuration.retryConfiguration;
            NSUInteger retryAttempt = request.retryAttempt + 1;
            delay = [retry retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:retryAttempt];
        }
        
        if (delay > 0.f) {
            request.retryAttempt += 1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self sendDownloadRequest:request withCompletionBlock:block];
            });
        } else {
            block(request,
                  [self handleRequest:request taskCompletion:task withResponse:nil data:nil],
                  location,
                  [self errorForRequest:request withURL:task.originalRequest.URL error:error]
            );
        }
    }];
    
    [self sendRequest:request withSessionTask:task];
}

- (void)sendRequest:(PNTransportRequest *)request withSessionTask:(NSURLSessionTask *)task {
    [self.lock asyncWriteAccessWithBlock:^{
        [self.requests addObject:request];

        PNLogRequest(self.configuration.logger, @"<PubNub::Network> %@ %@",
                     request.stringifiedMethod, task.originalRequest.URL.absoluteString);
        
        if (request.cancellable) {
            __weak __typeof(request) weakRequest = request;
            PNWeakify(self);
            
            request.cancel = ^{
                PNStrongify(self);
                
                weakRequest.cancelled = YES;
                weakRequest.cancel = nil;
                [task cancel];

                [self.lock asyncWriteAccessWithBlock:^{
                    [self.requests removeObject:weakRequest];
                }];
            };
        }

        [task resume];
    }];
}

- (PNTransportRequest *)transportRequestFromTransportRequest:(PNTransportRequest *)request {
    // Usually pre-defined origins set for non-REST API endpoints (outside of PubNub network).
    if (request.origin.length > 0) return request;

    NSMutableDictionary *headers = [(self.HTTPAdditionalHeaders ?: @{}) mutableCopy];
    [headers addEntriesFromDictionary:request.headers];

    if ((request.method == TransportPOSTMethod || request.method == TransportPATCHMethod) &&
        !request.bodyStreamAvailable && request.shouldCompressBody) {
        request.body = [PNGZIP GZIPDeflatedData:request.body] ?: [NSData new];
        headers[@"content-encoding"] = @"gzip";
        headers[@"content-length"] = @(request.body.length).stringValue;
    }

    request.headers = headers;

    return request;
}

- (id<PNTransportResponse>)handleRequest:(PNTransportRequest *)request
                          taskCompletion:(NSURLSessionTask *)task
                            withResponse:(NSURLResponse *)response
                                    data:(NSData *)data {
    [self.lock syncWriteAccessWithBlock:^{
        request.cancel = nil;
        [self.requests removeObject:request];
        NSUInteger activeRequestsCount = self.requests.count;

        if (activeRequestsCount == 0) [self endBackgroundTasksCompletionIfRequired];
    }];

    return [PNURLSessionTransportResponse responseWithNSURLResponse:response data:data];
}


#pragma mark - State

- (void)suspend {
    [self.lock syncWriteAccessWithBlock:^{
        if (self.requests.count == 0) return;
#if TARGET_OS_OSX
        if (self.tasksCompletionIdentifier != nil) return;
        
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        NSActivityOptions options = NSActivityIdleSystemSleepDisabled | NSActivityBackground;
        self.tasksCompletionIdentifier = [processInfo beginActivityWithOptions:options reason:@"Finish requests"];
#endif // TARGET_OS_OSX
#if TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)
        if (self.tasksCompletionIdentifier != UIBackgroundTaskInvalid) return;
        
        __weak __typeof__(self) weakSelf = self;
        UIApplication *application = [UIApplication performSelector:NSSelectorFromString(@"sharedApplication")];
        self.tasksCompletionIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
            [self.lock syncWriteAccessWithBlock:^{
                [weakSelf endBackgroundTasksCompletionIfRequired];
            }];
        }];
#endif // TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)
    }];
}

- (void)resume {
    [self endBackgroundTasksCompletionIfRequired];
}

- (void)endBackgroundTasksCompletionIfRequired {
#if TARGET_OS_OSX
    if (self.tasksCompletionIdentifier == nil) return;
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo endActivity:self.tasksCompletionIdentifier];
    self.tasksCompletionIdentifier = nil;
#endif // TARGET_OS_OSX
#if TARGET_OS_IOS && !TARGET_IS_EXTENSION
    if (self.tasksCompletionIdentifier == UIBackgroundTaskInvalid) return;

    UIApplication *application = [UIApplication performSelector:NSSelectorFromString(@"sharedApplication")];
    [application endBackgroundTask:self.tasksCompletionIdentifier];
    self.tasksCompletionIdentifier = UIBackgroundTaskInvalid;
#endif // TARGET_OS_IOS && !TARGET_IS_EXTENSION
}

- (void)invalidate {
    [self.lock syncWriteAccessWithBlock:^{
        [self endBackgroundTasksCompletionIfRequired];
        [self.session invalidateAndCancel];
        self->_session = nil;
    }];
}


#pragma mark - URL Session

- (void)setupURLSession {
    NSURLSessionConfiguration *configuration = [self urlSessionConfiguration];
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = configuration.HTTPMaximumConnectionsPerHost;
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
}

- (NSURLSessionConfiguration *)urlSessionConfiguration {
    NSString *identifier = [NSString stringWithFormat:@"com.pubnub.network.%p", self];
    NSURLSessionConfiguration *configuration = nil;
    
    configuration = [NSURLSessionConfiguration pn_ephemeralSessionConfigurationWithIdentifier:identifier];
    configuration.HTTPMaximumConnectionsPerHost = self.configuration.maximumConnections;
    _HTTPAdditionalHeaders = [configuration.HTTPAdditionalHeaders copy];
    _cachePolicy = configuration.requestCachePolicy;
    
    return configuration;
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (!error) return;
    
    [self.lock syncWriteAccessWithBlock:^{
        [self setupURLSession];
    }];
}


#pragma mark - Request

- (NSURLRequest *)requestFromTransportRequest:(PNTransportRequest *)transportRequest {
    NSDictionary *query = transportRequest.query;
    NSString *path = transportRequest.path;
    
    if (query.count > 0) {
        NSMutableArray *keyValuePairs = [NSMutableArray arrayWithCapacity:query.count];
        [query enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, __unused BOOL *stop) {
            value = [value isKindOfClass:[NSString class]] ? [PNString percentEscapedString:value] : value;
            [keyValuePairs addObject:PNStringFormat(@"%@=%@", key, value)];
        }];
        
        path = PNStringFormat(@"%@?%@", path, [keyValuePairs componentsJoinedByString:@"&"]);
    }
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:transportRequest.origin]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = transportRequest.stringifiedMethod;
    request.timeoutInterval = transportRequest.timeout;
    request.cachePolicy = self.cachePolicy;

    if (transportRequest.method == TransportPOSTMethod || transportRequest.method == TransportPATCHMethod) {
        if (transportRequest.bodyStreamAvailable) request.HTTPBodyStream = transportRequest.bodyStream;
        else request.HTTPBody = transportRequest.body;
    }
    
    request.allHTTPHeaderFields = transportRequest.headers;

    return request;
}


#pragma mark - Misc

- (PNError *)errorForRequest:(PNTransportRequest *)request withURL:(NSURL *)requestUrl error:(NSError *)transportError {
    PNError *error = nil;
    
    if (request.cancelled || transportError.code == NSURLErrorCancelled) {
        NSMutableDictionary *userInfo = [PNErrorUserInfo(@"The request has been cancelled.",
                                                         @"Request explicitly has been cancelled.",
                                                         nil,
                                                         transportError)
                                         mutableCopy];
        userInfo[NSURLErrorFailingURLErrorKey] = [requestUrl copy];
        error = [PNError errorWithDomain:PNTransportErrorDomain code:PNTransportErrorRequestCancelled userInfo:userInfo];
    } else if (transportError.code == NSURLErrorTimedOut) {
        NSMutableDictionary *userInfo = [PNErrorUserInfo(@"The request time out.",
                                                         @"The server didn't respond with data in time.",
                                                         @"Check network status or change request timeout parameter.",
                                                         transportError)
                                         mutableCopy];
        userInfo[NSURLErrorFailingURLErrorKey] = [requestUrl copy];
        error = [PNError errorWithDomain:PNTransportErrorDomain code:PNTransportErrorRequestTimeout userInfo:userInfo];
    }
    
    return error;
}

#ifndef PUBNUB_DISABLE_LOGGER
- (void)printIfRequiredSessionCustomizationInformation {
    PNLLogger *logger = self.configuration.logger;
    
    if ([NSURLSessionConfiguration pn_HTTPAdditionalHeaders].count) {
        PNLogClientInfo(logger, @"<PubNub::Network> Custom HTTP headers is set by user: %@",
                        [NSURLSessionConfiguration pn_HTTPAdditionalHeaders]);
    }
    
    if ([NSURLSessionConfiguration pn_networkServiceType] != NSURLNetworkServiceTypeDefault) {
        PNLogClientInfo(logger, @"<PubNub::Network> Custom network service type is set by user: %@",
                        @([NSURLSessionConfiguration pn_networkServiceType]));
    }
    
    if (![NSURLSessionConfiguration pn_allowsCellularAccess]) {
        PNLogClientInfo(logger, @"<PubNub::Network> User limited access to cellular data and only WiFi connection can "
                        "be used.");
    }
    
    if ([NSURLSessionConfiguration pn_protocolClasses].count) {
        PNLogClientInfo(logger, @"<PubNub::Network> Extra requests handling protocols defined by user: %@",
                        [NSURLSessionConfiguration pn_protocolClasses]);
    }
    
    if ([NSURLSessionConfiguration pn_connectionProxyDictionary].count) {
        PNLogClientInfo(logger, @"<PubNub::Network> Connection proxy has been set by user: %@",
                        [NSURLSessionConfiguration pn_connectionProxyDictionary]);
    }
}
#endif // PUBNUB_DISABLE_LOGGER

#pragma mark -


@end