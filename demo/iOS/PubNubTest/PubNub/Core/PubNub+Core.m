/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+CorePrivate.h"
#import "PubNub+SubscribePrivate.h"
#import "PubNub+PresencePrivate.h"
#import "PNRequest+Private.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PubNub+Presence.h"
#import "PNConstants.h"

#import "PNHelpers.h"


#pragma mark Private interface declaration

@interface PubNub ()


#pragma mark - Properties

@property (nonatomic, strong) dispatch_queue_t configurationAccessQueue;
@property (nonatomic, strong) dispatch_queue_t subscribeQueue;
@property (nonatomic, strong) dispatch_queue_t serviceQueue;
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, strong) AFHTTPSessionManager *subscriptionSession;
@property (nonatomic, strong) AFHTTPSessionManager *serviceSession;
@property (nonatomic, strong) NSMutableArray *sessions;

/**
 @brief  Stores reference on reachability monitor used to track state of network connection.
 
 @since 4.0
 */
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@property (nonatomic, assign) AFNetworkReachabilityStatus reachabilityStatus;


#pragma mark - Reachability

- (void)startReachability;
- (void)stopReachability;


#pragma mark - Sessions

/**
 @brief  Construct basic URL session configuration which can be extended.
 
 @return Basic URL session configuration.
 
 @since 4.0
 */
- (NSURLSessionConfiguration *)baseConfiguration;

/**
 @brief  Construct reference on URL session for long-polling non-concurrent requests.
 
 @return Pre-configured session manager.
 
 @since 4.0
 */
- (AFHTTPSessionManager *)sessionForLongPollingRequests;

/**
 @brief  Construct reference on URL session for immediate concurrent requests.
 
 @return Pre-configured session manager.
 
 @since 4.0
 */
- (AFHTTPSessionManager *)sessionForImmediateRequests;

/**
 @brief  Invalidate specified session.
 @discussion Depending on whether \c waitForTaskCompletion is set to \c YES or not, session will 
             wait for tasks completion before reporting invalidation.
             This method required to store session which is about to invalidate (so it won't release
             with incompleted tasks).
 
 @param sessionManager        Reference on HTTP manager which wotk with URL session and should be 
                              invalidated.
 @param waitForTaskCompletion Whether manager should let session to complete all tasks or not.
 
 @since 4.0
 */
- (void)invalidateSession:(AFHTTPSessionManager *)sessionManager
      afterTaskCompletion:(BOOL)waitForTaskCompletion;


#pragma mark - URL composition

/**
 @brief  Construct base NSURL using \c origin provided during client configuration.
 
 @return Base URL which can be used as request path prefixes.
 
 @since 4.0
 */
- (NSURL *)baseServiceURL;

/**
 @brief      Construct complete NSURL for request.
 @discussion NSURL built using output of \a -baseServiceURL concat with resource relative path and
             encoded query string.
 
 @param resourcePath Reference on relative to base service URL resource path.
 @param parameters   Reference on list of query parameters which should be appended to request.
 
 @return Complete NSURL instance which can be used for request.
 
 @since 4.0
 */
- (NSURL *)requestURLWithPath:(NSString *)resourcePath andParameters:(NSDictionary *)parameters;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub


#pragma mark - Information and configuration

- (void)commitConfiguration:(dispatch_block_t)block {

    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        // Store current configuration value to identify what part of client will require for
        // changes basing on updates information.
        NSString *origin = self.origin;
        NSString *subscribeKey = self.subscribeKey;
        NSString *authorizationKey = self.authorizationKey;
        NSString *uuid = self.uuid;
        BOOL isSSLEnabled = self.isSSLEnabled;
        NSTimeInterval subscribeMaximumIdleTime = self.subscribeMaximumIdleTime;
        NSTimeInterval nonSubscribeRequestTimeout = self.nonSubscribeRequestTimeout;
        NSInteger presenceHeartbeatValue = self.presenceHeartbeatValue;
        NSInteger presenceHeartbeatInterval = self.presenceHeartbeatInterval;
        
        // Performing client configuration change committed by user.
        if (block) {

            block();
        }

        // Check whether base URL has been changed or not
        if ([origin isEqualToString:self.origin] && isSSLEnabled == self.isSSLEnabled) {

            if (![subscribeKey isEqualToString:self.subscribeKey] ||
                ![authorizationKey isEqualToString:self.authorizationKey] ||
                ![uuid isEqualToString:self.uuid] ||
                (subscribeMaximumIdleTime != self.subscribeMaximumIdleTime)){

                [self invalidateSession:self.subscriptionSession afterTaskCompletion:NO];
                self.subscriptionSession = [self sessionForLongPollingRequests];
            }
            if (nonSubscribeRequestTimeout != self.nonSubscribeRequestTimeout) {

                [self invalidateSession:self.serviceSession afterTaskCompletion:YES];
                self.serviceSession = [self sessionForImmediateRequests];
            }
            if (presenceHeartbeatInterval != self.presenceHeartbeatInterval ||
                presenceHeartbeatValue != self.presenceHeartbeatValue) {

                if (presenceHeartbeatValue != self.presenceHeartbeatValue) {
                    
                    // Terminate all active tasks on long-polling URL session.
                    NSArray *tasks = [self.subscriptionSession tasks];
                    for (NSURLSessionDataTask *task in tasks) {
                        
                        [task cancel];
                    }
                    // TODO: Issue subscribe restore method call
                }
                [self startHeartbeatIfRequired];
            }
        }
        else {
            
            [self invalidateSession:self.subscriptionSession afterTaskCompletion:NO];
            self.subscriptionSession = [self sessionForLongPollingRequests];
            [self invalidateSession:self.serviceSession afterTaskCompletion:YES];
            self.serviceSession = [self sessionForImmediateRequests];
        }
    });
}


#pragma mark - Initialization

+ (instancetype)clientWithPublishKey:(NSString *)publishKey
                     andSubscribeKey:(NSString *)subscribeKey {
    
    PubNub *client = [self new];
    client.publishKey = publishKey;
    client.subscribeKey = subscribeKey;
    
    
    return client;
}

- (instancetype)init {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        _deviceID = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] copy];
        self.origin = kPNDefaultOrigin;
        self.publishKey = kPNDefaultPublishKey;
        self.subscribeKey = kPNDefaultSubscribeKey;
        self.uuid = [[NSUUID UUID] UUIDString];
        self.subscribeRequestTimeout = kPNDefaultSubscribeRequestTimeout;
        self.subscribeMaximumIdleTime = kPNDefaultSubscribeMaximumIdleTime;
        self.nonSubscribeRequestTimeout = kPNDefaultNonSubscribeRequestTimeout;
        self.SSLEnabled = kPNDefaultIsSSLEnabled;
        self.keepTimeTokenOnListChange = kPNDefaultShouldKeepTimeTokenOnListChange;
        self.restoreSubscription = kPNDefaultShouldRestoreSubscription;
        self.catchUpOnSubscriptionRestore = kPNDefaultShouldTryCatchUpOnSubscriptionRestore;
        self.callbackQueue = dispatch_get_main_queue();
        
        // Create queue which will be used to syncronize shared resources modification (client
        // configuration) and other queue which would like to use them.
        self.configurationAccessQueue = dispatch_queue_create("com.pubnub.configuration",
                                                              DISPATCH_QUEUE_CONCURRENT);
        
        // Create queue which will be used to issue calls from subscription API group.
        self.subscribeQueue = dispatch_queue_create("com.pubnub.subscription",
                                                    DISPATCH_QUEUE_SERIAL);
        
        // Synchronize blocks call on subscribe queue with configuration access queue to serialize
        // access to shared resources (client configuration).
        dispatch_set_target_queue(self.subscribeQueue, self.configurationAccessQueue);
        
        // Create queue which will be used to issue calls from non-subscription API group.
        self.serviceQueue = dispatch_queue_create("com.pubnub.service", DISPATCH_QUEUE_CONCURRENT);
        
        // Synchronize blocks call on service queue with configuration access queue to serialize
        // access to shared resources (client configuration).
        dispatch_set_target_queue(self.serviceQueue, self.configurationAccessQueue);

        __weak __typeof(self) weakSelf = self;
        self.sessions = [NSMutableArray new];
        self.subscriptionSession = [self sessionForLongPollingRequests];
        self.serviceSession = [self sessionForImmediateRequests];

        // Configure sessions to re-initialize after it has been invalidated.
        void(^invalidateSessionCleanBlock)(NSURLSession *) = ^(NSURLSession *session){
            
            __strong __typeof(self) strongSelf = weakSelf;
            for (AFHTTPSessionManager *sessionManager in strongSelf.sessions) {
                
                if ([sessionManager.session isEqual:session]) {
                    
                    [strongSelf.sessions removeObject:sessionManager];
                    break;
                }
            }
        };
        [self.subscriptionSession setSessionDidBecomeInvalidBlock:^(NSURLSession *session,
                                                                    NSError *error) {
            
            dispatch_barrier_async(weakSelf.configurationAccessQueue, ^{

                invalidateSessionCleanBlock(session);
            });
        }];
        [self.serviceSession setSessionDidBecomeInvalidBlock:^(NSURLSession *session,
                                                               NSError *error) {
            
            dispatch_barrier_async(weakSelf.configurationAccessQueue, ^{
                
                invalidateSessionCleanBlock(session);
            });
        }];
    }
    
    
    return self;
}

- (void)setOrigin:(NSString *)origin {
    
    _origin = [(origin?: kPNDefaultOrigin) copy];
}

- (void)setPublishKey:(NSString *)publishKey {
  
    _publishKey = [(publishKey?: kPNDefaultPublishKey) copy];
}

- (void)setSubscribeKey:(NSString *)subscribeKey {
    
    _subscribeKey = [(subscribeKey?: kPNDefaultSubscribeKey) copy];
}

- (void)setUUID:(NSString *)uuid {
    
    static NSString *_lifetimeUUID;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _lifetimeUUID = [uuid copy];
    });
    _uuid = [(uuid?: _lifetimeUUID) copy];
}

- (void)setCallbackQueue:(dispatch_queue_t)callbackQueue {
    
    _callbackQueue = (callbackQueue?: dispatch_get_main_queue());
}

- (void)setPresenceHeartbeatValue:(NSInteger)presenceHeartbeatValue {
    
    _presenceHeartbeatValue = MIN(5, presenceHeartbeatValue);
    _presenceHeartbeatInterval = (_presenceHeartbeatValue - 3);
}

- (void)setPresenceHeartbeatInterval:(NSInteger)presenceHeartbeatInterval {
    
    _presenceHeartbeatValue = (presenceHeartbeatInterval > _presenceHeartbeatValue ?
                               _presenceHeartbeatValue - 3: presenceHeartbeatInterval);
}

- (void)setMessageHandlingBlock:(PNEventHandlingBlock)messageHandlingBlock {
    
    _messageHandlingBlock = [(messageHandlingBlock?: nil) copy];
}

- (void)setPresenceEventHandlingBlock:(PNEventHandlingBlock)presenceEventHandlingBlock {
    
    _presenceEventHandlingBlock = [(presenceEventHandlingBlock?: nil) copy];
}


#pragma mark - URL composition

- (NSURL *)baseServiceURL {
    
    NSString *scheme = (self.isSSLEnabled ? @"https://" : @"http://");
    
    return [NSURL URLWithString:[scheme stringByAppendingString:self.origin]];;
}

- (NSURL *)requestURLWithPath:(NSString *)resourcePath andParameters:(NSDictionary *)parameters {
    
    NSURL *url = [[self baseServiceURL] URLByAppendingPathComponent:resourcePath];
    if (parameters) {
        
        NSArray *pairs = [PNArray mapObjects:[parameters allKeys] usingBlock:^id(id fieldName){
            
            return [NSString stringWithFormat:@"%@=%@", fieldName,
                    [PNString percentEscapedString:parameters[fieldName]]];
        }];
        NSString *path = [[url absoluteString] stringByAppendingFormat:@"?%@",
                          [pairs componentsJoinedByString:@"&"]];
        url = [NSURL URLWithString:path];
    }
    
    return url;
}


#pragma mark - Reachability

- (void)startReachability {
    
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        self.reachabilityStatus = AFNetworkReachabilityStatusUnknown;
        self.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:self.origin];
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
        }];
        [self.reachabilityManager startMonitoring];
    });
}

- (void)stopReachability {
    
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        [self.reachabilityManager stopMonitoring];
        self.reachabilityManager = nil;
    });
}


#pragma mark - Sessions

- (NSURLSessionConfiguration *)baseConfiguration {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    configuration.HTTPShouldUsePipelining = YES;
    configuration.HTTPAdditionalHeaders = @{@"Accept":@"*/*",
                                            @"Accept-Encoding":@"gzip,deflate"};
    
    return configuration;
}

- (AFHTTPSessionManager *)sessionForLongPollingRequests {
    
    __block NSURLSessionConfiguration *configuration = [self baseConfiguration];
    configuration.timeoutIntervalForRequest = self.subscribeMaximumIdleTime;
    configuration.HTTPMaximumConnectionsPerHost = 1;

    return [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseServiceURL]
                                    sessionConfiguration:configuration];
}

- (AFHTTPSessionManager *)sessionForImmediateRequests {
    
    __block NSURLSessionConfiguration *configuration = [self baseConfiguration];
    configuration.timeoutIntervalForRequest = self.nonSubscribeRequestTimeout;
    configuration.HTTPMaximumConnectionsPerHost = 3;
    
    return [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseServiceURL]
                                    sessionConfiguration:configuration];
}

- (void)invalidateSession:(AFHTTPSessionManager *)sessionManager
      afterTaskCompletion:(BOOL)waitForTaskCompletion {
    
    [self.sessions addObject:sessionManager];
    [sessionManager invalidateSessionCancelingTasks:!waitForTaskCompletion];
}


#pragma mark - Operation processing

- (void)processRequest:(PNRequest *)request {
    
    __weak __typeof(self) weakSelf = self;
    void(^processingBlock)(AFHTTPSessionManager *) = ^(AFHTTPSessionManager *session){
        
        // Add parameters required 
        NSMutableDictionary *query = [request.parameters mutableCopy];
        [query addEntriesFromDictionary:@{@"uuid":self.uuid,@"deviceid":self.deviceID,
                                          @"pnsdk":[NSString stringWithFormat:@"PubNub-%@/%@",
                                                    kPNClientName, kPNLibraryVersion]}];
        void(^success)(id,id) = ^(id task, id responseObject) {
            
            __strong __typeof(self) strongSelf = weakSelf;
            [strongSelf handleRequestSuccess:request withTask:task andData:responseObject];
        };
        void(^failure)(id, id) = ^(id task, id error) {

            __strong __typeof(self) strongSelf = weakSelf;
            [strongSelf handleRequestFailure:request withTask:task andError:error];
        };

        if (!request.body) {

            [session GET:request.resourcePath parameters:query success:success failure:failure];
        }
        else {
            
            // AFNetwork has it's own route on composing requests for POST with body.
            // Build own request with pre-defined header fields and body before passing to
            // AFNetwork session manager.
            NSURL *url = [self requestURLWithPath:request.resourcePath andParameters:query];
            NSMutableURLRequest *httpRequest = [session.requestSerializer requestWithMethod:@"POST"
                                                 URLString:[url absoluteString] parameters:nil
                                                                                     error:nil];
            httpRequest.allHTTPHeaderFields = @{@"Content-Encoding":@"gzip",
                                                @"Content-Type":@"application/json;charset=UTF-8",
                                                @"Content-Length":[NSString stringWithFormat:@"%@",
                                                                   @([request.body length])]};
            [httpRequest setHTTPBody:request.body];
            
            // Create request data task which will send our request with specified body to PubNub
            // service.
            NSURLSessionDataTask *task = [session dataTaskWithRequest:httpRequest
                                                    completionHandler:^(NSURLResponse *response,
                                                                        id responseObject,
                                                                        NSError *error) {
                        
                (!error ? success : failure)(task, (error?: responseObject));
            }];
            [task resume];
        }
    };
    
    if (request.operation == PNSubscribeOperation || request.operation == PNUnsubscribeOperation) {

        // Block executed w/o switching to queue because switching done on 'subscribe' API group
        // level to constrol commands execution.
        processingBlock(self.subscriptionSession);
    }
    else {
        
        dispatch_async(self.serviceQueue, ^{
            
            __strong __typeof(self) strongSelf = weakSelf;
            processingBlock(strongSelf.serviceSession);
        });
    }
    
}

- (void)handleRequestSuccess:(PNRequest *)request withTask:(NSURLSessionDataTask *)task
                     andData:(id)data {
    
    BOOL isErrorResponse = NO;
    if ([data isKindOfClass:[NSDictionary class]]) {
        
        isErrorResponse = ([data[@"error"] isKindOfClass:[NSNumber class]] &&
                           ([data[@"error"] integerValue] == 1));
    }
    
    if (!isErrorResponse) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        request.request = task.currentRequest;
        PNResult *result = [PNResult resultForRequest:request withResponse:response andData:data];
        request.completionBlock(result, nil);
    }
    else {
        
        NSInteger errorCode = NSURLErrorBadURL;
        NSDictionary *userInfor = @{NSURLErrorFailingURLErrorKey:task.currentRequest.URL,
                                    NSLocalizedDescriptionKey:[NSHTTPURLResponse localizedStringForStatusCode:400],
                                    AFNetworkingOperationFailingURLResponseErrorKey:data};
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:errorCode
                                         userInfo:userInfor];
        [self handleRequestFailure:request withTask:task andError:error];
    }
}

- (void)handleRequestFailure:(PNRequest *)request withTask:(NSURLSessionDataTask *)task
                    andError:(NSError *)error {
    // NSURLErrorDomain
    //// NSURLErrorCancelled
    
    __weak __typeof(self) weakSelf = self;
    NSError *processingError = error;
    id errorDetails = nil;
    
    // Try to fetch server response if available.
    if (error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]) {
        
        // In most cases service provide JSON error response. Try de-serialize it.
        NSError *deSerializationError;
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        errorDetails = [NSJSONSerialization JSONObjectWithData:errorData
                                                       options:(NSJSONReadingOptions)0
                                                         error:&deSerializationError];
        
        // Check whether JSON deserialization failed and try to pull regular string
        // from response.
        if (!errorDetails) {
            
            errorDetails = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        }
        if (deSerializationError) {
            
            processingError = deSerializationError;
        }
    }
    else if (error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]) {
        
        errorDetails = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    }
    
    // Configure operation status instance before sending it to compeltion block.
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    request.request = task.currentRequest;
    PNStatus *status = [PNStatus statusForRequest:request withResponse:response
                                            error:processingError
                                          andData:errorDetails];
    dispatch_async(self.configurationAccessQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        status.SSLEnabled = strongSelf.isSSLEnabled;
        status.currentTimetoken = [strongSelf currentTimeToken];
        status.previousTimetoken = [strongSelf previousTimeToken];
        status.channels = [self channels];
        status.groups = [self channelGroups];
        status.uuid = strongSelf.uuid;
        status.authorizationKey = strongSelf.authorizationKey;
        request.completionBlock(nil, status);
    });
}

#pragma mark -


@end
