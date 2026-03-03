#import "PNMockTransport.h"
#import "PNTransportRequest+Private.h"
#import <PubNub/PNError.h>


#pragma mark - PNMockTransportRequestRecord implementation

@implementation PNMockTransportRequestRecord

- (instancetype)initWithRequest:(PNTransportRequest *)request {
    if ((self = [super init])) {
        _request = request;
        _timestamp = [NSDate date];
    }
    return self;
}

@end


#pragma mark - PNMockTransportResponse implementation

@interface PNMockTransportResponse ()

/// Internal mutable headers storage.
@property(strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *mutableHeaders;

@end


@implementation PNMockTransportResponse

- (instancetype)init {
    if ((self = [super init])) {
        _statusCode = 200;
        _mutableHeaders = [NSMutableDictionary new];
    }
    return self;
}

- (NSDictionary<NSString *, NSString *> *)headers {
    return [self.mutableHeaders copy];
}

- (void)setHeaders:(NSDictionary<NSString *, NSString *> *)headers {
    [self.mutableHeaders removeAllObjects];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        self.mutableHeaders[key.lowercaseString] = value;
    }];
}

+ (instancetype)responseWithStatusCode:(NSUInteger)statusCode body:(NSData *)body {
    PNMockTransportResponse *response = [[self alloc] init];
    response.statusCode = statusCode;
    response.body = body;
    return response;
}

+ (instancetype)responseWithStatusCode:(NSUInteger)statusCode json:(NSDictionary *)json {
    PNMockTransportResponse *response = [[self alloc] init];
    response.statusCode = statusCode;
    response.mutableHeaders[@"content-type"] = @"application/json";

    if (json) {
        response.body = [NSJSONSerialization dataWithJSONObject:json options:(NSJSONWritingOptions)0 error:nil];
    }

    return response;
}

+ (instancetype)responseWithError:(NSError *)error {
    PNMockTransportResponse *response = [[self alloc] init];
    response.error = error;
    return response;
}

@end


#pragma mark - PNMockTransportInternalResponse

/// Internal response object that conforms to PNTransportResponse protocol.
@interface PNMockTransportInternalResponse : NSObject <PNTransportResponse>

@property(strong, nullable, nonatomic) NSDictionary<NSString *, NSString *> *headers;
@property(strong, nullable, nonatomic) NSData *body;
@property(assign, nonatomic) NSUInteger statusCode;
@property(strong, nonatomic) NSString *url;
@property(strong, nullable, nonatomic) NSString *MIMEType;

+ (instancetype)responseFromMockResponse:(PNMockTransportResponse *)mockResponse requestURL:(NSString *)url;

@end


@implementation PNMockTransportInternalResponse

- (NSInputStream *)bodyStream {
    return nil;
}

- (BOOL)bodyStreamAvailable {
    return NO;
}

+ (instancetype)responseFromMockResponse:(PNMockTransportResponse *)mockResponse requestURL:(NSString *)url {
    PNMockTransportInternalResponse *response = [[self alloc] init];
    response.statusCode = mockResponse.statusCode;
    response.headers = mockResponse.headers;
    response.body = mockResponse.body;
    response.url = url ?: @"";
    response.MIMEType = mockResponse.headers[@"content-type"];
    return response;
}

@end


#pragma mark - PNMockTransport private interface

@interface PNMockTransport ()

/// Queue of responses to return in FIFO order.
@property(strong, nonatomic) NSMutableArray<PNMockTransportResponse *> *responseQueue;

/// Default response when queue is empty.
@property(strong, nullable, nonatomic) PNMockTransportResponse *defaultMockResponse;

/// Mutable array of recorded requests.
@property(strong, nonatomic) NSMutableArray<PNMockTransportRequestRecord *> *mutableRecordedRequests;

/// Serial queue for thread-safe access to transport state.
@property(strong, nonatomic) dispatch_queue_t syncQueue;

/// Active transport requests.
@property(strong, nonatomic) NSMutableArray<PNTransportRequest *> *activeRequests;

/// Transport configuration (stored from setupWithConfiguration:).
@property(strong, nullable, nonatomic) PNTransportConfiguration *configuration;

/// Whether the transport has been invalidated.
@property(assign, nonatomic) BOOL invalidated;

/// Whether the transport is suspended.
@property(assign, nonatomic) BOOL suspended;

@end


#pragma mark - PNMockTransport implementation

@implementation PNMockTransport


#pragma mark - Initialisation

- (instancetype)init {
    if ((self = [super init])) {
        _networkState = PNMockTransportConnected;
        _responseQueue = [NSMutableArray new];
        _mutableRecordedRequests = [NSMutableArray new];
        _activeRequests = [NSMutableArray new];
        _syncQueue = dispatch_queue_create("com.pubnub.test.mock-transport", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


#pragma mark - Properties

- (NSArray<PNMockTransportRequestRecord *> *)recordedRequests {
    __block NSArray *copy;
    dispatch_sync(self.syncQueue, ^{
        copy = [self.mutableRecordedRequests copy];
    });
    return copy;
}

- (NSUInteger)recordedRequestCount {
    __block NSUInteger count;
    dispatch_sync(self.syncQueue, ^{
        count = self.mutableRecordedRequests.count;
    });
    return count;
}


#pragma mark - Configuration

- (void)enqueueResponse:(PNMockTransportResponse *)response {
    dispatch_sync(self.syncQueue, ^{
        [self.responseQueue addObject:response];
    });
}

- (void)enqueueResponses:(NSArray<PNMockTransportResponse *> *)responses {
    dispatch_sync(self.syncQueue, ^{
        [self.responseQueue addObjectsFromArray:responses];
    });
}

- (void)setDefaultResponse:(PNMockTransportResponse *)response {
    dispatch_sync(self.syncQueue, ^{
        self.defaultMockResponse = response;
    });
}

- (void)resetResponses {
    dispatch_sync(self.syncQueue, ^{
        [self.responseQueue removeAllObjects];
        self.defaultMockResponse = nil;
    });
}

- (void)resetRecordedRequests {
    dispatch_sync(self.syncQueue, ^{
        [self.mutableRecordedRequests removeAllObjects];
    });
}

- (void)reset {
    dispatch_sync(self.syncQueue, ^{
        [self.responseQueue removeAllObjects];
        [self.mutableRecordedRequests removeAllObjects];
        [self.activeRequests removeAllObjects];
        self.defaultMockResponse = nil;
        self.networkState = PNMockTransportConnected;
        self.invalidated = NO;
        self.suspended = NO;
    });
}


#pragma mark - PNTransport :: Initialization and Configuration

- (void)setupWithConfiguration:(PNTransportConfiguration *)configuration {
    dispatch_sync(self.syncQueue, ^{
        self.configuration = configuration;
    });
}


#pragma mark - PNTransport :: Information

- (void)requestsWithBlock:(void (^)(NSArray<PNTransportRequest *> *))block {
    if (!block) return;

    dispatch_sync(self.syncQueue, ^{
        block(self.activeRequests);
    });
}


#pragma mark - PNTransport :: Request processing

- (void)sendRequest:(PNTransportRequest *)request withCompletionBlock:(PNRequestCompletionBlock)block {
    block = [block copy];

    dispatch_sync(self.syncQueue, ^{
        [self.mutableRecordedRequests addObject:[[PNMockTransportRequestRecord alloc] initWithRequest:request]];

        if (request.cancellable) {
            [self.activeRequests addObject:request];
        }
    });

    __block PNMockTransportResponse *mockResponse = nil;
    __block PNMockTransportNetworkState state;

    dispatch_sync(self.syncQueue, ^{
        state = self.networkState;

        if (state == PNMockTransportConnected) {
            if (self.responseQueue.count > 0) {
                mockResponse = self.responseQueue.firstObject;
                [self.responseQueue removeObjectAtIndex:0];
            } else {
                mockResponse = self.defaultMockResponse ?: [PNMockTransportResponse responseWithStatusCode:200 body:nil];
            }
        }
    });

    dispatch_block_t deliveryBlock = ^{
        dispatch_sync(self.syncQueue, ^{
            [self.activeRequests removeObject:request];
        });

        if (state == PNMockTransportDisconnected) {
            NSError *networkError = [NSError errorWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorNotConnectedToInternet
                                                    userInfo:@{
                NSLocalizedDescriptionKey: @"The Internet connection appears to be offline."
            }];
            PNError *error = [PNError errorWithDomain:PNTransportErrorDomain
                                                 code:PNTransportErrorNetworkIssues
                                             userInfo:@{
                NSLocalizedDescriptionKey: @"Network issues.",
                NSLocalizedFailureReasonErrorKey: @"Request processing failed because of network issues.",
                NSUnderlyingErrorKey: networkError
            }];
            block(request, nil, error);
            return;
        }

        if (state == PNMockTransportTimingOut) {
            NSError *timeoutError = [NSError errorWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorTimedOut
                                                    userInfo:@{
                NSLocalizedDescriptionKey: @"The request timed out."
            }];
            PNError *error = [PNError errorWithDomain:PNTransportErrorDomain
                                                 code:PNTransportErrorRequestTimeout
                                             userInfo:@{
                NSLocalizedDescriptionKey: @"The request time out.",
                NSLocalizedFailureReasonErrorKey: @"The server didn't respond with data in time.",
                NSUnderlyingErrorKey: timeoutError
            }];
            block(request, nil, error);
            return;
        }

        // Connected state: deliver the mock response.
        if (mockResponse.error) {
            PNError *error = [PNError errorWithDomain:PNTransportErrorDomain
                                                 code:PNTransportErrorNetworkIssues
                                             userInfo:@{
                NSLocalizedDescriptionKey: @"Network issues.",
                NSLocalizedFailureReasonErrorKey: @"Request processing failed because of network issues.",
                NSUnderlyingErrorKey: mockResponse.error
            }];
            block(request, nil, error);
            return;
        }

        NSString *requestURL = [self urlStringFromRequest:request];
        id<PNTransportResponse> response = [PNMockTransportInternalResponse responseFromMockResponse:mockResponse
                                                                                          requestURL:requestURL];
        block(request, response, nil);
    };

    NSTimeInterval delay = mockResponse.delay;
    if (delay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       deliveryBlock);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), deliveryBlock);
    }
}

- (void)sendDownloadRequest:(PNTransportRequest *)request
        withCompletionBlock:(PNDownloadRequestCompletionBlock)block {
    block = [block copy];

    // Reuse the same response resolution logic via sendRequest, then adapt the callback.
    [self sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                     id<PNTransportResponse> response,
                                                     PNError *error) {
        block(req, response, nil, error);
    }];
}

- (PNTransportRequest *)transportRequestFromTransportRequest:(PNTransportRequest *)request {
    // Return the request as-is; no transformations needed for mock transport.
    return request;
}


#pragma mark - PNTransport :: State

- (void)suspend {
    dispatch_sync(self.syncQueue, ^{
        self.suspended = YES;
    });
}

- (void)resume {
    dispatch_sync(self.syncQueue, ^{
        self.suspended = NO;
    });
}

- (void)invalidate {
    dispatch_sync(self.syncQueue, ^{
        self.invalidated = YES;
        [self.activeRequests removeAllObjects];
    });
}


#pragma mark - Helpers

- (NSString *)urlStringFromRequest:(PNTransportRequest *)request {
    NSMutableArray *queryPairs = [NSMutableArray new];
    [request.query enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [queryPairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }];

    NSString *queryString = queryPairs.count > 0
        ? [NSString stringWithFormat:@"?%@", [queryPairs componentsJoinedByString:@"&"]]
        : @"";
    NSString *scheme = request.secure ? @"https" : @"http";

    return [NSString stringWithFormat:@"%@://%@%@%@", scheme, request.origin ?: @"", request.path ?: @"", queryString];
}

#pragma mark -


@end
