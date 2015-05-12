/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+CorePrivate.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "PubNub+SubscribePrivate.h"
#import "PubNub+PresencePrivate.h"
#import "PNRequest+Private.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PubNub+Presence.h"
#import "PubNub+Time.h"
#import "PNConstants.h"
#import "PNHelpers.h"
#import "PNLog.h"


#pragma mark Static 

/**
 @brief  Cocoa Lumberjack logging level configuration for \b PubNub client class and categories.
 
 @since 4.0
 */
static DDLogLevel ddLogLevel = (DDLogLevel)(PNReachabilityLogLevel|PNRequestLogLevel);


#pragma mark - Private interface declaration

@interface PubNub ()


#pragma mark - Properties

@property (nonatomic, strong) dispatch_queue_t configurationAccessQueue;
@property (nonatomic, strong) dispatch_queue_t subscribeQueue;
@property (nonatomic, strong) dispatch_queue_t serviceQueue;

/**
 @brief Stores reference on unique device identifier based on bundle identifier used by software
        vendor.
 
 @since 4.0
 */
@property (nonatomic, copy) NSString *deviceID;

@property (nonatomic, assign) PNStatusCategory recentClientStatus;

/**
 @brief Stores reference on session with pre-configured options useful for 'subscription' API group
        with long-polling.
 
 @since 4.0
 */
@property (nonatomic, strong) AFHTTPSessionManager *subscriptionSession;

/**
 @brief Stores reference on session with pre-configured options useful for 'non-subscription' API 
        group.
 
 @since 4.0
 */
@property (nonatomic, strong) AFHTTPSessionManager *serviceSession;

/**
 @brief  Stores reference on queue which is used by \a AFNetworking to issue tasks completion.
 @discussion Queue is targetting configuration queue to serialize access to shared resources.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t sessionTaskCompletionQueue;

/**
 @brief      Stores reference on list of sessions which has been issues with invalidate and waiting 
             for their tasts completion.
 @discussion This array temporally store reference on previous sessions to allow them complete tasks
             and report back before complete invalidation.
 
 @since 4.0
 */
@property (nonatomic, strong) NSMutableArray *sessions;

/**
 @brief  Stores reference on reachability monitor used to track state of network connection.
 
 @since 4.0
 */
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@property (nonatomic, assign) AFNetworkReachabilityStatus reachabilityStatus;


#pragma mark - Initialization

/**
 @brief      Initialize \b PubNub client instance with pre-defined publish and subscribe keys.
 @discussion If all keys will be specified, client will be able to read and modify data on
             \b PubNub service.

 @param publishKey   Key which allow client to use data push API.
 @param subscribeKey Key which allow client to subscribe on live feeds pushed from \b PubNub
                     service.

 @return Initialized and ready to use \b PubNub client.
 @since 4.0
*/
- (instancetype)initWithPublishKey:(NSString *)publishKey andSubscribeKey:(NSString *)subscribeKey;


#pragma mark - Reachability

/**
 @brief  Launch \a AFNetworking based reachability monitor.
 @discussion Monitor launched every time when clien state switch from disconnected to connected.
 
 @since 4.0
 */
- (void)startReachability;

/**
 @brief  Terminate any active reachability monitors and reset state.
 
 @since 4.0
 */
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


#pragma mark - Synthesize

@synthesize uuid = _uuid;


#pragma mark - Logger

/**
 @brief  Called by Cocoa Lumberjack during initalization.
 
 @return Desired logger level for \b PubNub client main class.
 
 @since 4.0
 */
+ (DDLogLevel)ddLogLevel {
    
    return ddLogLevel;
}

/**
 @brief  Allow modify logger level used by Cocoa Lumberjack with logging macros.
 
 @param logLevel New log level which should be used by logger.
 
 @since 4.0
 */
+ (void)ddSetLogLevel:(DDLogLevel)logLevel {
    
    // Force add reachability flag to current logger level.
    ddLogLevel = (logLevel & PNReachabilityLogLevel ? logLevel : (logLevel|PNReachabilityLogLevel));
}


#pragma mark - Information and configuration

- (void)commitConfiguration:(dispatch_block_t)block {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        
        // Store current configuration value to identify what part of client will require for
        // changes basing on updates information.
        NSString *origin = [strongSelf.origin copy];
        NSString *subscribeKey = [strongSelf.subscribeKey copy];
        NSString *authorizationKey = [strongSelf.authorizationKey copy];
        NSString *uuid = [_uuid copy];
        BOOL isSSLEnabled = strongSelf.isSSLEnabled;
        NSTimeInterval subscribeMaximumIdleTime = strongSelf.subscribeMaximumIdleTime;
        NSTimeInterval nonSubscribeRequestTimeout = strongSelf.nonSubscribeRequestTimeout;
        NSInteger presenceHeartbeatValue = strongSelf.presenceHeartbeatValue;
        NSInteger presenceHeartbeatInterval = strongSelf.presenceHeartbeatInterval;
        
        // Performing client configuration change committed by user.
        if (block) {

            block();
        }

        // Check whether base URL has been changed or not
        if ([origin isEqualToString:strongSelf.origin] && isSSLEnabled == strongSelf.isSSLEnabled) {

            if (![subscribeKey isEqualToString:strongSelf.subscribeKey] ||
                ![authorizationKey isEqualToString:strongSelf.authorizationKey] ||
                ![uuid isEqualToString:_uuid] ||
                (subscribeMaximumIdleTime != strongSelf.subscribeMaximumIdleTime)){

                // Check whether request or session related information has been changed.
                if (subscribeMaximumIdleTime != strongSelf.subscribeMaximumIdleTime) {

                    // Recreate subscription URL session with new configuration.
                    [strongSelf invalidateSession:strongSelf.subscriptionSession
                              afterTaskCompletion:NO];
                    strongSelf.subscriptionSession = [strongSelf sessionForLongPollingRequests];
                }
                else {

                    // Terminate all active tasks on long-polling URL session.
                    NSArray *tasks = [strongSelf.subscriptionSession tasks];
                    for (NSURLSessionDataTask *task in tasks) {

                        [task cancel];
                    }
                }

                // Resume subscription cycle.
                [self continueSubscriptionCycleIfRequired];
            }
            if (nonSubscribeRequestTimeout != strongSelf.nonSubscribeRequestTimeout) {

                // Recreate service URL session with new configuration allowing exising operations
                // to be completed.
                [strongSelf invalidateSession:strongSelf.serviceSession afterTaskCompletion:YES];
                strongSelf.serviceSession = [strongSelf sessionForImmediateRequests];
            }
            if (presenceHeartbeatInterval != strongSelf.presenceHeartbeatInterval ||
                presenceHeartbeatValue != strongSelf.presenceHeartbeatValue) {

                // Check whether heartbeat value important for service has been changed or not.
                if (presenceHeartbeatValue != strongSelf.presenceHeartbeatValue) {
                    
                    // Terminate all active tasks on long-polling URL session.
                    NSArray *tasks = [strongSelf.subscriptionSession tasks];
                    for (NSURLSessionDataTask *task in tasks) {
                        
                        [task cancel];
                    }

                    // Resume subscription cycle.
                    [strongSelf continueSubscriptionCycleIfRequired];
                }
                else {

                    [strongSelf startHeartbeatIfRequired];
                }
            }
        }
        else {
            
            [strongSelf invalidateSession:strongSelf.subscriptionSession afterTaskCompletion:NO];
            strongSelf.subscriptionSession = [strongSelf sessionForLongPollingRequests];
            [strongSelf invalidateSession:strongSelf.serviceSession afterTaskCompletion:YES];
            strongSelf.serviceSession = [strongSelf sessionForImmediateRequests];

            // Resume subscription cycle.
            [strongSelf continueSubscriptionCycleIfRequired];
        }
    });
}


#pragma mark - Initialization

+ (instancetype)clientWithPublishKey:(NSString *)publishKey
                     andSubscribeKey:(NSString *)subscribeKey {
    
    PubNub *client = nil;
    if ([publishKey length] && [subscribeKey length]) {

        client = [[self alloc] initWithPublishKey:publishKey andSubscribeKey:subscribeKey];
    }

    return client;
}

- (instancetype)init {

    @throw [NSException exceptionWithName:@"InitializerNotAllowed"
                       reason:@"+new and -init methods can't be used with PubNub for instantiation."
                               "Use +clientWithPublishKey:andSubscribeKey: for this purposes."
                     userInfo:nil];

    return nil;
}

- (instancetype)initWithPublishKey:(NSString *)publishKey andSubscribeKey:(NSString *)subscribeKey {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        [PNLog prepare];
        _deviceID = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] copy];
        self.origin = kPNDefaultOrigin;
        self.publishKey = publishKey;
        self.subscribeKey = subscribeKey;
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

        // Create queue which will be used by AFNetwork session managers to report about tasks
        // processing results.
        self.sessionTaskCompletionQueue = dispatch_queue_create("com.pubnub.task.completion",
                                                                DISPATCH_QUEUE_CONCURRENT);

        // Synchronize blocks call on completion block queue with configuration access queue to
        // serialize access to shared resources (client configuration).
        dispatch_set_target_queue(self.sessionTaskCompletionQueue, self.configurationAccessQueue);

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

    if (![publishKey length]) {

        @throw [NSException exceptionWithName:@"UnacceptableValue"
                                       reason:@"Publish key required property and can't be nil"
                                     userInfo:nil];
    }
  
    _publishKey = [publishKey copy];
}

- (void)setSubscribeKey:(NSString *)subscribeKey {

    if (![subscribeKey length]) {

        @throw [NSException exceptionWithName:@"UnacceptableValue"
                                       reason:@"Subscribe key required property and can't be nil"
                                     userInfo:nil];
    }
    
    _subscribeKey = [subscribeKey copy];
}

- (void)setUUID:(NSString *)uuid {
    
    static NSString *_lifetimeUUID;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _lifetimeUUID = [uuid copy];
    });
    _uuid = [(uuid?: _lifetimeUUID) copy];
}

- (void)setRecentClientStatus:(PNStatusCategory)recentClientStatus {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        // Check whether previous client state reported unexpected disconnection from remote data
        // objects live feed or not.
        __strong __typeof(self) strongSelf = weakSelf;
        PNStatusCategory previousState = _recentClientStatus;
        PNStatusCategory currentState = recentClientStatus;
        
        // In case if client disconnected only from one of it's channels it should keep 'connected'
        // state.
        if (currentState == PNDisconnectedCategory &&
            ([[strongSelf channels] count] || [[strongSelf channelGroups] count] ||
             [[strongSelf presenceChannels] count])) {
            
            currentState = PNConnectedCategory;
        }
        strongSelf->_recentClientStatus = currentState;
        
        // Check whether client currently connected or not.
        if (currentState == PNConnectedCategory) {
            
            // In case if previous client state was unexpected disconnection (because of network
            // issues for example) connection should be restored if possible.
            if (previousState == PNUnexpectedDisconnectCategory) {
                
                // Try to recover subscription to old channels set.
                [strongSelf continueSubscriptionCycleIfRequired];
                [strongSelf startReachability];
            }
            // In case if client just connected (for first time) it need to launch reachability
            // monitor.
            else if (previousState == PNUnknownCategory ||
                     previousState == PNDisconnectedCategory) {
                
                [strongSelf startReachability];
            }
        }
        // Looks like client completelly disconnected from all remote data objects live feed and
        // reachability should be turned off.
        else if (currentState == PNDisconnectedCategory) {
            
            [strongSelf stopReachability];
        }
    });
}

- (void)setCallbackQueue:(dispatch_queue_t)callbackQueue {
    
    _callbackQueue = (callbackQueue?: dispatch_get_main_queue());
}

- (void)setPresenceHeartbeatValue:(NSInteger)presenceHeartbeatValue {
    
    _presenceHeartbeatValue = MAX(5, presenceHeartbeatValue);
    _presenceHeartbeatInterval = (_presenceHeartbeatValue - 3);
}

- (void)setPresenceHeartbeatInterval:(NSInteger)presenceHeartbeatInterval {
    
    _presenceHeartbeatValue = (presenceHeartbeatInterval > _presenceHeartbeatValue ?
                               _presenceHeartbeatValue - 3: presenceHeartbeatInterval);
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

    __weak __typeof(self) weakSelf = self;
    [self stopReachability];
    dispatch_barrier_async(self.configurationAccessQueue, ^{

        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.reachabilityStatus = AFNetworkReachabilityStatusUnknown;
        strongSelf.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:strongSelf.origin];
        [strongSelf.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                
                DDLogReachability(@"<PubNub> Network available via WiFi");
            } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
                
                DDLogReachability(@"<PubNub> Network available via WWAN");
            } else if (status == AFNetworkReachabilityStatusNotReachable) {
                
                DDLogReachability(@"<PubNub> Network not available");
            }
            
            __strong __typeof(self) strongSelfForHandler = weakSelf;
            AFNetworkReachabilityStatus previousStatus = strongSelfForHandler.reachabilityStatus;
            strongSelfForHandler.reachabilityStatus = status;
            if (previousStatus == AFNetworkReachabilityStatusNotReachable &&
                status != AFNetworkReachabilityStatusNotReachable &&
                status != AFNetworkReachabilityStatusUnknown) {
                
                DDLogReachability(@"<PubNub> Connection restored");
                
                // Try to request 'time' API to ensure what network really available.
                [strongSelfForHandler timeWithCompletion:^(PNResult *result, PNStatus *requestStatus) {
                    
                    __strong __typeof(self) strongSelfForResponse = weakSelf;
                    if (result) {
                        
                        [strongSelfForResponse continueSubscriptionCycleIfRequired];
                    }
                }];
            }
            else if (status == AFNetworkReachabilityStatusNotReachable &&
                     previousStatus != AFNetworkReachabilityStatusNotReachable &&
                     previousStatus != AFNetworkReachabilityStatusUnknown) {
                
                DDLogReachability(@"<PubNub> Connection went down");
            }
        }];
        
        DDLogReachability(@"<PubNub> Start reachability monitor for: %@", strongSelf.origin);
        [strongSelf.reachabilityManager startMonitoring];
    });
}

- (void)stopReachability {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async(self.configurationAccessQueue, ^{

        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.reachabilityStatus = AFNetworkReachabilityStatusUnknown;
        if (strongSelf.reachabilityManager) {
            
            DDLogReachability(@"<PubNub> Stop reachability monitor for: %@", strongSelf.origin);
            [strongSelf.reachabilityManager stopMonitoring];
            strongSelf.reachabilityManager = nil;
        }
    });
}


#pragma mark - Sessions

- (NSURLSessionConfiguration *)baseConfiguration {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    configuration.HTTPShouldUsePipelining = YES;
    configuration.HTTPAdditionalHeaders = @{@"Accept":@"*/*",
                                            @"Accept-Encoding":@"gzip,deflate",
                                            @"Connection":@"keep-alive"};
    
    return configuration;
}

- (AFHTTPSessionManager *)sessionForLongPollingRequests {
    
    __block NSURLSessionConfiguration *configuration = [self baseConfiguration];
    configuration.timeoutIntervalForRequest = self.subscribeMaximumIdleTime;
    configuration.HTTPMaximumConnectionsPerHost = 1;
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseServiceURL]
                                                             sessionConfiguration:configuration];
    [session setCompletionQueue:self.sessionTaskCompletionQueue];

    return session;
}

- (AFHTTPSessionManager *)sessionForImmediateRequests {
    
    __block NSURLSessionConfiguration *configuration = [self baseConfiguration];
    configuration.timeoutIntervalForRequest = self.nonSubscribeRequestTimeout;
    configuration.HTTPMaximumConnectionsPerHost = 3;
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseServiceURL]
                                                             sessionConfiguration:configuration];
    [session setCompletionQueue:self.sessionTaskCompletionQueue];

    return session;
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

        // Check whether passed operation is from long-polling dependant operations or not
        if (request.operation == PNSubscribeOperation ||
            request.operation == PNUnsubscribeOperation) {

            // Previous long-poll operation should be terminated.
            [[[session tasks] copy] enumerateObjectsUsingBlock:^(NSURLSessionTask *task,
                                                                 NSUInteger taskIdx,
                                                                 BOOL *tasksEnumeratorStop) {

                // Cancel task w/o waiting for it's processing results.
                [task cancel];
            }];
        }
        
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

        if (ddLogLevel & PNRequestLogLevel) {
            
            NSString *queryString = [PNDictionary queryStringFrom:query];
            DDLogRequest(@"<PubNub> %@ %@%@%@%@", (request.body ? @"POST" : @"GET"),
                         [session.baseURL absoluteString], request.resourcePath,
                         (queryString ? @"?" : @""), (queryString?: @""));
        }
        if (!request.body) {

            [session GET:request.resourcePath parameters:query success:success failure:failure];
        }
        else {

            __strong __typeof(self) strongSelf = weakSelf;
            
            // AFNetwork has it's own route on composing requests for POST with body.
            // Build own request with pre-defined header fields and body before passing to
            // AFNetwork session manager.
            NSURL *url = [strongSelf requestURLWithPath:request.resourcePath andParameters:query];
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
        // level to control commands execution.
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
        NSDictionary *userInfo = @{NSURLErrorFailingURLErrorKey:task.currentRequest.URL,
                                   NSLocalizedDescriptionKey:[NSHTTPURLResponse localizedStringForStatusCode:400],
                                   AFNetworkingOperationFailingURLResponseErrorKey:data};
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:errorCode
                                         userInfo:userInfo];
        [self handleRequestFailure:request withTask:task andError:error];
    }
}

- (void)handleRequestFailure:(PNRequest *)request withError:(NSError *)error {

    [self handleRequestFailure:request withTask:nil andError:error];
}

- (void)handleRequestFailure:(PNRequest *)request withTask:(NSURLSessionDataTask *)task
                    andError:(NSError *)error {

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
        
        // Check whether JSON de-serialization failed and try to pull regular string
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
    
    // Configure operation status instance before sending it to completion block.
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    request.request = task.currentRequest;
    PNStatus *status = [PNStatus statusForRequest:request withResponse:response
                                            error:processingError
                                          andData:errorDetails];

    // Check whether status created for request which doesn't rely on long-polling.
    if (request.operation != PNSubscribeOperation && request.operation != PNUnsubscribeOperation) {

        // Configure request retry block which can be triggered with -retry method call.
        __strong __typeof(self) strongSelf = weakSelf;
        status.retryBlock = ^{

            [strongSelf processRequest:request];
        };
    }

    status.uuid = self.uuid;
    status.SSLEnabled = self.isSSLEnabled;
    status.currentTimetoken = [self currentTimeToken];
    status.previousTimetoken = [self previousTimeToken];
    status.channels = [[self channels] arrayByAddingObjectsFromArray:[self presenceChannels]];
    status.groups = [self channelGroups];
    status.authorizationKey = self.authorizationKey;
    request.completionBlock(nil, status);
}

- (void)cancelAllLongPollRequests {

    __weak __typeof(self) weakSelf = self;
    dispatch_barrier_async(self.configurationAccessQueue, ^{

        // Previous long-poll operation should be terminated.
        __strong __typeof(self) strongSelf = weakSelf;
        NSArray *tasks = [[strongSelf.subscriptionSession tasks] copy];
        [tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger taskIdx,
                                            BOOL *tasksEnumeratorStop) {

            // Cancel task w/o waiting for it's processing results.
            [task cancel];
        }];
    });
}


#pragma mark - Events notification

- (void)callBlock:(PNCompletionBlock)block withResult:(PNResult *)result
        andStatus:(PNStatus *)status {

    PNStatus *clientStatus = nil;
    // Check whether result information should be post-processed or not.
    if (result || status) {

        // Check whether result or status related to subscription process or not.
        PNOperationType operation = (result?: status).operation;
        if (operation == PNSubscribeOperation || operation == PNUnsubscribeOperation) {

            clientStatus = (status?: [PNStatus statusFromResult:result]);
            if (!status) {

                clientStatus.uuid = self.uuid;
                clientStatus.SSLEnabled = self.isSSLEnabled;
                clientStatus.currentTimetoken = [self currentTimeToken];
                clientStatus.previousTimetoken = [self previousTimeToken];
                clientStatus.channels = [[self channels] arrayByAddingObjectsFromArray:[self presenceChannels]];
                clientStatus.groups = [self channelGroups];
                clientStatus.authorizationKey = self.authorizationKey;
            }
        }
        
        if (result) {
            
            if (!clientStatus) {
                
                DDLogResult(@"%@", [result stringifiedRepresentation]);
            }
            else {
                
                DDLogStatus(@"%@", [clientStatus stringifiedRepresentation]);
            }
        }
        
        if (clientStatus) {
            
            DDLogStatus(@"%@", [clientStatus stringifiedRepresentation]);
        }
        else if (status) {
            
            DDLogFailureStatus(@"%@", [status stringifiedRepresentation]);
        }
    }

    if (clientStatus) {

        self.recentClientStatus = clientStatus.category;
        if (self.statusHandler) {

            __weak __typeof(self) weakSelf = self;
            dispatch_async(self.callbackQueue, ^{

                __strong __typeof(self) strongSelf = weakSelf;
                strongSelf.statusHandler(clientStatus);
            });
        }
    }

    if (block) {

        dispatch_async(self.callbackQueue, ^{

            block(result, status);
        });
    }
}

#pragma mark -


@end
