#import "PNTransportMiddleware.h"
#import "PNNetworkResponseLogEntry+Private.h"
#import "PNNetworkRequestLogEntry+Private.h"
#import "PNTransportConfiguration+Private.h"
#import "PNTransportRequest+Private.h"
#import "PNConfiguration+Private.h"
#import "PNConstants.h"
#import "PNFunctions.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Transport middelware module private extension.
@interface PNTransportMiddleware ()


#pragma mark - Properties

/// Transport middleware module configuration.
@property(copy, nonatomic) PNTransportMiddlewareConfiguration *configuration;

/// SDK information query value.
@property(copy, nonatomic) NSString *pnsdk;


#pragma mark - Initialization and Configuration

/// Initialize transport middleware with `configuration`.
///
/// - Parameter configuration: Transport middleware module configuration object.
/// - Returns: Initialized transport middleware.
- (instancetype)initWithConfiguration:(PNTransportMiddlewareConfiguration *)configuration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END




@implementation PNTransportMiddleware


#pragma mark - Initialization and Configuration

+ (instancetype)middlewareWithConfiguration:(PNTransportMiddlewareConfiguration *)configuration {
    return [[self alloc] initWithConfiguration:configuration];
}

- (instancetype)initWithConfiguration:(PNTransportMiddlewareConfiguration *)configuration {
    if ((self = [super init])) {
        _pnsdk = PNStringFormat(@"PubNub-%@/%@", kPNClientName, kPNLibraryVersion);
        PNLoggerManager *logger = configuration.transportConfiguration.logger;
        _configuration = configuration;
        
        [logger debugWithLocation:@"PNTransportMiddleware" andMessageFactory:^PNLogEntry * {
            return [PNDictionaryLogEntry entryWithMessage:[configuration.transportConfiguration dictionaryRepresentation]
                                                  details:@"Create with configuration:"];
        }];
        [_configuration.transport setupWithConfiguration:configuration.transportConfiguration];
        
    }
    
    return self;
}

- (void)setupWithConfiguration:(PNTransportConfiguration *)configuration {
    [self.configuration.transport setupWithConfiguration:configuration];
}


#pragma mark - Information

- (void)requestsWithBlock:(nonnull void (^)(NSArray<PNTransportRequest *> *))block {
    [self.configuration.transport requestsWithBlock:block];
}


#pragma mark - Request processing

- (void)sendRequest:(PNTransportRequest *)request withCompletionBlock:(PNRequestCompletionBlock)block {
    PNTransportRequest *transportRequest = [self transportRequestFromTransportRequest:request];
    PNLoggerManager *logger = self.configuration.transportConfiguration.logger;
    PNRequestCompletionBlock userBlock = [block copy];

    [logger debugWithLocation:@"PNTransportMiddleware" andMessageFactory:^PNLogEntry * {
        return [PNNetworkRequestLogEntry entryWithMessage:transportRequest details:nil];
    }];
    
    [self.configuration.transport sendRequest:transportRequest
                          withCompletionBlock:^(PNTransportRequest *request,
                                                id<PNTransportResponse> response,
                                                PNError * error) {
        if (response.url) {
            [logger debugWithLocation:@"PNTransportMiddleware" andMessageFactory:^PNLogEntry * {
                return [PNNetworkResponseLogEntry entryWithMessage:response];
            }];
        }
        if (error) {
            if (error.code == PNTransportErrorRequestCancelled) {
                [logger debugWithLocation:@"PNTransportMiddleware" andMessageFactory:^PNLogEntry * {
                    return [PNErrorLogEntry entryWithMessage:error];
                }];
            } else {
                [logger warnWithLocation:@"PNTransportMiddleware" andMessageFactory:^PNLogEntry * {
                    return [PNErrorLogEntry entryWithMessage:error];
                }];
            }
        }
        
        userBlock(request, response, error);
    }];
}

- (void)sendDownloadRequest:(PNTransportRequest *)request withCompletionBlock:(PNDownloadRequestCompletionBlock)block {
    PNTransportRequest *transportRequest = [self transportRequestFromTransportRequest:request];
    PNLoggerManager *logger = self.configuration.transportConfiguration.logger;
    PNDownloadRequestCompletionBlock userBlock = [block copy];
    
    [logger debugWithLocation:@"PNTransportMiddleware" andMessageFactory:^PNLogEntry * {
        return [PNNetworkRequestLogEntry entryWithMessage:transportRequest details:nil];
    }];
    
    [self.configuration.transport sendDownloadRequest:transportRequest
                                  withCompletionBlock:^(PNTransportRequest *request,
                                                        id<PNTransportResponse> response,
                                                        NSURL *path,
                                                        PNError *error) {
        if (response) {
            [logger debugWithLocation:@"PNTransportMiddleware" andMessageFactory:^PNLogEntry * {
                return [PNNetworkResponseLogEntry entryWithMessage:response];
            }];
        }
        if (error) {
            if (error.code == PNTransportErrorRequestCancelled) {
                [logger debugWithLocation:@"PNTransportMiddleware" andMessageFactory:^PNLogEntry * {
                    return [PNErrorLogEntry entryWithMessage:error];
                }];
            } else {
                [logger warnWithLocation:@"PNTransportMiddleware" andMessageFactory:^PNLogEntry * {
                    return [PNErrorLogEntry entryWithMessage:error];
                }];
            }
        }
        
        userBlock(request, response, path, error);
    }];
}

- (PNTransportRequest *)transportRequestFromTransportRequest:(PNTransportRequest *)request {
    request = [self.configuration.transport transportRequestFromTransportRequest:request];
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:request.query ?: @{}];
    PNConfiguration *configuration = self.configuration.configuration;
    
    if (request.origin.length == 0) {
        request.origin = PNStringFormat(@"http%@://%@", configuration.isTLSEnabled ? @"s" : @"", configuration.origin);
    } else if ([request.origin rangeOfString:configuration.origin].location == NSNotFound) return request;
    
    if (!query[@"auth"]) {
        if (configuration.authToken.length) query[@"auth"] = configuration.authToken;
        else if (configuration.authKey.length) query[@"auth"] = configuration.authKey;
    }
    
    if (!query[@"uuid"]) query[@"uuid"] = configuration.userID;
    if (!query[@"instanceid"]) query[@"instanceid"] = self.configuration.clientInstanceId;
    if (!query[@"requestid"]) query[@"requestid"] = request.identifier;
    query[@"pnsdk"] = self.pnsdk;
    
    // Update query parameters list.
    request.query = query;
    
    return request;
}


#pragma mark - State

- (void)suspend {
    [self.configuration.transport suspend];
}

- (void)resume {
    [self.configuration.transport resume];
}

- (void)invalidate {
    [self.configuration.transport invalidate];
}

#pragma mark -


@end
