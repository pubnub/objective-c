#import "PubNub+CorePrivate.h"
#define PN_CORE_PROTOCOLS PNEventsListener

#include <sys/sysctl.h>
#include <sys/types.h>

#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
    #import <AppKit/AppKit.h>
#endif // TARGET_OS_OSX
#import "PNOperationResult+Private.h"
#import "PNConfiguration+Private.h"
#import "PubNub+SubscribePrivate.h"
#import "NSError+PNTransport.h"
#import "PNPrivateStructures.h"
#import "PNClientInformation.h"
#import "PNSubscribeStatus.h"
#import "PNStatus+Private.h"
#import "PNEventsListener.h"
#import "PNConfiguration.h"
#import "PNConsoleLogger.h"
#import "PNReachability.h"
#import "PNConstants.h"
#import "PNHelpers.h"

#import "PNLoggerManager+Private.h"
#import "PNTransportMiddleware.h"
#import "PNURLSessionTransport.h"
#import "PNCryptoModule.h"
#import "PNRequest.h"


#pragma mark Externs

void pn_dispatch_async(dispatch_queue_t queue, dispatch_block_t block) {
    if (queue && block) {
        dispatch_async(queue, block);
    }
}

void pn_safe_property_read(dispatch_queue_t queue, dispatch_block_t block) {
    if (queue && block) dispatch_sync(queue, block);
}

void pn_safe_property_write(dispatch_queue_t queue, dispatch_block_t block) {
    if (queue && block) dispatch_barrier_async(queue, block);
}

NSString * pn_cpu_architecture(void) {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
  
    NSString *architecture = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    free(name);
  
    return architecture;
}

NSString * pn_operating_system_version(void) {
    NSOperatingSystemVersion ver = NSProcessInfo.processInfo.operatingSystemVersion;
    NSArray *versionComponents = @[@(ver.majorVersion), @(ver.minorVersion), @(ver.patchVersion)];

    return [versionComponents componentsJoinedByString:@"."];
}

BOOL pn_operating_system_version_is_greater_than(NSString *version) {
    NSString *osVersion = pn_operating_system_version();

    return [osVersion compare:version options:NSNumericSearch] == NSOrderedDescending;
}

BOOL pn_operating_system_version_is_same_as(NSString *version) {
    NSString *osVersion = pn_operating_system_version();

    return [osVersion compare:version options:NSNumericSearch] == NSOrderedSame;
}

BOOL pn_operating_system_version_is_lower_than(NSString *version) {
    NSString *osVersion = pn_operating_system_version();
    
    return [osVersion compare:version options:NSNumericSearch] == NSOrderedAscending;
}


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

/// **PubNub** client core class private extension.
@interface PubNub () <PN_CORE_PROTOCOLS>


#pragma mark - Properties

@property(strong, nonatomic) id<PNTransport> subscriptionNetwork;
@property(assign, nonatomic) PNStatusCategory recentClientStatus;
@property(strong, nonatomic) PNPublishSequence *sequenceManager;
@property(strong, nonatomic) PNClientState *clientStateManager;
@property(strong, nonatomic) PNStateListener *listenersManager;
@property(strong, nonatomic) PNSubscriber *subscriberManager;
@property(strong, nonatomic) id<PNTransport> serviceNetwork;
@property(strong, nonatomic) dispatch_queue_t callbackQueue;
@property(strong, nonatomic) PNJSONSerialization *serializer;
@property(strong, nonatomic) PNHeartbeat *heartbeatManager;
@property(strong, nonatomic) PNFilesManager *filesManager;
@property(copy, nonatomic) PNConfiguration *configuration;
@property(strong, nonatomic) PNLoggerManager *logger;
@property(copy, nonatomic) NSString *instanceID;
@property(strong, nonatomic) PNJSONCoder *coder;
/// Resources access lock.
@property(strong, nonatomic) PNLock *lock;

/// Reachability helper.
///
/// Helper used by client to know about when something happened with network and when it is safe to issue requests to
/// the **PubNub** network.
@property (nonatomic, strong) PNReachability *reachability;


#pragma mark - Initialization

/// Initialize **PubNub** client instance with pre-defined configuration.
///
/// If all keys will be specified, client will be able to read and modify data in **PubNub** network.
///
/// > Note: Client will make configuration deep copy and further changes in ``PNConfiguration`` after it has been passed
/// to the client won't take any effect on client.
/// > Note: If `queue` is nil, completion blocks and delegate callbacks will be called on the main queue.
/// > Note: All required keys can be found on https://admin.pubnub.com
///
/// - Parameters:
///   - configuration: User-provided information about how client should operate and handle events.
///   - callbackQueue: Queue which is used by client for completion block and delegate calls. By default set to
///   **main**.
/// - Returns: Initialized **PubNub** client instance.
- (instancetype)initWithConfiguration:(PNConfiguration *)configuration
                        callbackQueue:(nullable dispatch_queue_t)callbackQueue;

/// Update current client state.
///
/// Use subscription status to translate it to proper client state and launch service reachability check if will be
/// required.
///
/// - Parameters:
///   - recentClientStatus: Recent subscriber state which should be used to set proper client state.
///   - shouldCheckReachability: Whether service reachability check should be started or not.
- (void)setRecentClientStatus:(PNStatusCategory)recentClientStatus withReachabilityCheck:(BOOL)shouldCheckReachability;


#pragma mark - Crypto module

/// Initialize and configure crypto module.
- (void)prepareCryptoModule;


#pragma mark - Reachability

/// Complete reachability helper configuration.
- (void)prepareReachability;


#pragma mark - PubNub Network managers

/// Initialize and configure required **PubNub** network managers.
- (void)prepareNetworkManagers;

/// Create transport instance with limited concurrent connections.
///
/// - Parameter maximumConnections: Maximum number of concurrent connections (requests).
/// - Returns: Configured and ready to use requests transport instance.
- (id<PNTransport>)transportWithMaximumConnections:(NSUInteger)maximumConnections;


#if TARGET_OS_OSX || TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)
#pragma mark - Handlers

/// Handle application with active client transition between foreground and background execution contexts.
///
/// - Parameter notification: Notification which will provide information about to which context application has been
/// pushed.
- (void)handleContextTransition:(NSNotification *)notification;
#endif

#pragma mark - Misc

/// Create and configure **PubNub** client logger instance.
- (void)setupClientLogger;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub


#pragma mark - Information

+ (PNClientInformation *)information {
    static PNClientInformation *_sharedClientInformation;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedClientInformation = [PNClientInformation new];
    });
    
    return _sharedClientInformation;
}

- (PNConfiguration *)currentConfiguration {
    return [self.configuration copy];
}

- (NSString *)uuid {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"This method deprecated. Please use 'userID' method instead."];
    }];
    
    return [self userID];
}

- (NSString *)userID {
    return self.configuration.userID;
}


#pragma mark - Initialization

+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration {
    return [self clientWithConfiguration:configuration callbackQueue:nil];
}

+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration callbackQueue:(dispatch_queue_t)callbackQueue {
    return [[self alloc] initWithConfiguration:configuration callbackQueue:callbackQueue ?: dispatch_get_main_queue()];
}

- (instancetype)initWithConfiguration:(PNConfiguration *)configuration callbackQueue:(dispatch_queue_t)callbackQueue {
    if ((self = [super init])) {
        _lock = [PNLock lockWithIsolationQueueName:@"core" subsystemQueueIdentifier:@"com.pubnub.serializer"];
        _serializer = [PNJSONSerialization new];
        _coder = [PNJSONCoder coderWithJSONSerializer:_serializer];
        _instanceID = [[NSUUID UUID].UUIDString copy];
        _configuration = [configuration copy];
        _callbackQueue = callbackQueue;
        
        [self setupClientLogger];
        [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
            return [PNDictionaryLogEntry entryWithMessage:[self->_configuration dictionaryRepresentation]
                                                  details:@"Create with configuration:"];
        }];
        
        [self prepareNetworkManagers];
        [self prepareCryptoModule];
        
        _filesManager = [PNFilesManager filesManagerForClient:self];
        _subscriberManager = [PNSubscriber subscriberForClient:self];
        _sequenceManager = [PNPublishSequence sequenceForClient:self];
        _clientStateManager = [PNClientState stateForClient:self];
        _listenersManager = [PNStateListener stateListenerForClient:self];
        _heartbeatManager = [PNHeartbeat heartbeatForClient:self];

        [self addListener:self];
        [self prepareReachability];

#if TARGET_OS_OSX || TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)
        SEL selector = @selector(handleContextTransition:);
#if TARGET_OS_IOS
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:selector name:UIApplicationWillEnterForegroundNotification object:nil];
        [center addObserver:self selector:selector name:UIApplicationDidEnterBackgroundNotification object:nil];
#elif TARGET_OS_OSX
        NSNotificationCenter *center = [[NSWorkspace sharedWorkspace] notificationCenter];
        [center addObserver:self selector:selector name:NSWorkspaceWillSleepNotification object:nil];
        [center addObserver:self selector:selector name:NSWorkspaceSessionDidResignActiveNotification object:nil];
        [center addObserver:self selector:selector name:NSWorkspaceDidWakeNotification object:nil];
        [center addObserver:self selector:selector name:NSWorkspaceSessionDidBecomeActiveNotification object:nil];
#endif // TARGET_OS_OSX
#endif // TARGET_OS_OSX || TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)
    }
    
    return self;
}

- (void)copyWithConfiguration:(PNConfiguration *)configuration completion:(void(^)(PubNub *client))block {
    [self copyWithConfiguration:configuration callbackQueue:self.callbackQueue completion:block];
}

- (void)copyWithConfiguration:(PNConfiguration *)configuration
                callbackQueue:(dispatch_queue_t)callbackQueue
                   completion:(void(^)(PubNub *client))block {
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[configuration dictionaryRepresentation]
                                              details:@"Copy with new configuration:"];
    }];
                       
    PubNub *client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];

    [client.subscriberManager inheritStateFromSubscriber:self.subscriberManager];
    [client.clientStateManager inheritStateFromState:self.clientStateManager];
    [client.listenersManager inheritStateFromListener:self.listenersManager];
    [client removeListener:self];
    [self.listenersManager removeAllListeners];
    [client addListener:client];
    
    dispatch_block_t subscriptionRestoreBlock = ^{
        [client.subscriberManager continueSubscriptionCycleIfRequiredWithCompletion:^(__unused PNSubscribeStatus *status) {
            if (block) {
                pn_dispatch_async(client.callbackQueue, ^{
                    block(client);
                });
            }
        }];
    };

    if ([self.subscriberManager allObjects].count) {
        // Stop any interactions on subscription loop.
        [self cancelSubscribeOperations];

        BOOL uuidChanged = ![configuration.userID isEqualToString:self.configuration.userID];
        BOOL authKeyChanged = ((self.configuration.authKey && !configuration.authKey) ||
                               (!self.configuration.authKey && configuration.authKey) ||
                               (configuration.authKey && self.configuration.authKey &&
                                ![configuration.authKey isEqualToString:self.configuration.authKey]));
        
        if (uuidChanged || authKeyChanged) {
            [self unsubscribeFromChannels:self.subscriberManager.channels 
                                   groups:self.subscriberManager.channelGroups
                             withPresence:YES
                          queryParameters:nil
                               completion:^(__unused PNSubscribeStatus *status) {
                subscriptionRestoreBlock();
            }];
        } else {
            subscriptionRestoreBlock();
        }
    } else if (block) {
        pn_dispatch_async(client.callbackQueue, ^{
            block(client);
        });
    }
}

- (void)setRecentClientStatus:(PNStatusCategory)recentClientStatus withReachabilityCheck:(BOOL)shouldCheckReachability {
    PNStatusCategory previousState = self.recentClientStatus;
    PNStatusCategory currentState = recentClientStatus;
    
    if (currentState == PNReconnectedCategory) currentState = PNConnectedCategory;
    if (currentState == PNDisconnectedCategory && ([[self channels] count] ||
                                                   [[self channelGroups] count] ||
                                                   [[self presenceChannels] count])) {
        currentState = PNConnectedCategory;
    }
    
    self->_recentClientStatus = currentState;
    
    if (currentState == PNUnexpectedDisconnectCategory && shouldCheckReachability) {
        if (previousState == PNDisconnectedCategory) return;
        
        __weak __typeof(self) weakSelf = self;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(delay, self.callbackQueue, ^{
            [weakSelf.reachability startServicePing];
        });
    }
}


#pragma mark - Crypto module

- (void)prepareCryptoModule {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (!self.configuration.cipherKey.length || self.configuration.cryptoModule) return;
    if (self.configuration.cipherKey.length && self.configuration.cryptoModule) {
        [self.logger errorWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
            return [PNStringLogEntry entryWithMessage:@"It is expected that only cipherKey or cryptoModule will be "
                    "configured at once. PubNub client will use the configured cryptoModule."];
        }];
        return;
    }

    self.configuration.cryptoModule = [PNCryptoModule legacyCryptoModuleWithCipherKey:self.configuration.cipherKey
                                                           randomInitializationVector:self.configuration.useRandomInitializationVector];
#pragma clang diagnostic pop
}


#pragma mark - Reachability

- (void)prepareReachability {
    __weak __typeof(self) weakSelf = self;
    _reachability = [PNReachability reachabilityForClient:self withPingStatus:^(BOOL pingSuccessful) {
        if (pingSuccessful) {
            /**
             * Silence static analyzer warnings.
             * Code is aware about this case and at the end will simply call on 'nil' object method.
             * In most cases if referenced object become 'nil' it mean what there is no more need in
             * it and probably whole client instance has been deallocated.
             */
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
            [weakSelf.reachability stopServicePing];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_MSEC), queue, ^{
                [weakSelf cancelSubscribeOperations];
                [weakSelf.subscriberManager restoreSubscriptionCycleIfRequiredWithCompletion:nil];
            });
            #pragma clang diagnostic pop
        }
    }];
}


#pragma mark - PubNub Network managers

- (void)prepareNetworkManagers {
    _subscriptionNetwork = [self transportWithMaximumConnections:1];
    _serviceNetwork = [self transportWithMaximumConnections:3];
}

- (id<PNTransport>)transportWithMaximumConnections:(NSUInteger)maximumConnections {
    PNURLSessionTransport *transport = [PNURLSessionTransport new];
    PNTransportMiddlewareConfiguration *configuration;
    configuration = [PNTransportMiddlewareConfiguration configurationWithClientConfiguration:_configuration
                                                                            clientInstanceId:self.instanceID
                                                                                   transport:transport
                                                                          maximumConnections:maximumConnections
                                                                                      logger:_logger];
    
    return [PNTransportMiddleware middlewareWithConfiguration:configuration];
}


#pragma mark - Requests helper

- (void)performRequest:(PNBaseRequest *)userRequest 
            withParser:(PNOperationDataParser *)parser
            completion:(PNParsedRequestCompletionBlock)handlerBlock {
    PNParsedRequestCompletionBlock block = [handlerBlock copy];
    id handler;


    if (!userRequest.responseAsFile) {
        handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, PNError *error) {
            PNOperationDataParseResult *result = [parser parseOperation:userRequest.operation
                                                            withRequest:request
                                                               response:response
                                                                   data:response.body
                                                                  error:error];
            block(request, response, nil, result);
        };
    } else {
        handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, NSURL *location, PNError *error) {
            NSData *data = location ? [NSData dataWithContentsOfURL:location] : response.body;
            PNOperationDataParseResult *result = [parser parseOperation:userRequest.operation
                                                            withRequest:request
                                                               response:response
                                                                   data:data
                                                                  error:error];
            block(request, response, location, result);
        };
    }

    [self performRequest:userRequest withCompletion:handler];
}

- (void)performRequest:(PNBaseRequest *)userRequest withCompletion:(id)block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    block = [block copy];

    // Complete request configuration.
    [userRequest setupWithClientConfiguration:self.configuration];

    PNWeakify(self);
    dispatch_async(queue, ^{
        PNError *validationError = [userRequest validate];
        PNTransportRequest *transportRequest = userRequest.request;
        BOOL isDownload = transportRequest.responseAsFile;
        PNStrongify(self);
        
        if (validationError) {
            if (!isDownload) {
                ((void(^)(PNTransportRequest *, id, PNError *))block)(transportRequest, nil, validationError);
            } else {
                ((void(^)(PNTransportRequest *, id, NSURL *, PNError *))block)(transportRequest,
                                                                               nil,
                                                                               nil,
                                                                               validationError);
            }
        } else {
            id<PNTransport> transport;

            if (userRequest.operation == PNSubscribeOperation || userRequest.operation == PNUnsubscribeOperation) {
                transport = self.subscriptionNetwork;
            } else transport = self.serviceNetwork;
            
            if (!isDownload) {
                [transport sendRequest:transportRequest
                   withCompletionBlock:^(PNTransportRequest *request, 
                                         id<PNTransportResponse> response,
                                         PNError *error) {
                    ((void(^)(PNTransportRequest *, id, NSError *))block)(request, response, error);
                }];
            } else {
                [transport sendDownloadRequest:transportRequest
                           withCompletionBlock:^(PNTransportRequest *request,
                                                 id<PNTransportResponse> response,
                                                 NSURL *path,
                                                 PNError *error) {
                    ((void(^)(PNTransportRequest *, id, NSURL *, NSError *))block)(request, response, path, error);
                }];
            }
        }
    });
}

- (PNOperationDataParser *)parserWithResult:(Class)resultClass status:(Class)statusClass {
    return [self parserWithResult:resultClass status:statusClass cryptoModule:nil];
}

- (PNOperationDataParser *)parserWithStatus:(Class)statusClass {
    return [self parserWithStatus:statusClass cryptoModule:nil];
}

- (PNOperationDataParser *)parserWithResult:(Class)resultClass
                                     status:(Class)statusClass
                               cryptoModule:(id<PNCryptoProvider>)cryptoModule {
    NSDictionary *additionalData;
    if (cryptoModule || self.configuration.cryptoModule) {
        additionalData = @{ @"cryptoModule": cryptoModule ?: self.configuration.cryptoModule };
    }

    return [PNOperationDataParser parserWithSerializer:self.coder
                                                result:resultClass
                                                status:statusClass
                                    withAdditionalData:additionalData];
}

- (PNOperationDataParser *)parserWithStatus:(Class)statusClass cryptoModule:(id<PNCryptoProvider>)cryptoModule {
    NSDictionary *additionalData;
    if (cryptoModule || self.configuration.cryptoModule) {
        additionalData = @{ @"cryptoModule": cryptoModule ?: self.configuration.cryptoModule };
    }

    return [PNOperationDataParser parserWithSerializer:self.coder
                                                result:nil
                                                status:statusClass
                                    withAdditionalData:additionalData];
}


#pragma mark - Events notification

- (void)callBlock:(id)block
           status:(BOOL)callingStatusBlock
       withResult:(PNOperationResult *)result
        andStatus:(PNStatus *)status {
    if (!block) return;

    pn_dispatch_async(self.callbackQueue, ^{
        if (!callingStatusBlock) ((PNCompletionBlock)block)(result, status);
        else ((PNStatusBlock)block)(status);
    });
}

- (void)client:(PubNub *)__unused client didReceiveStatus:(PNSubscribeStatus *)status {
    if (status.category == PNConnectedCategory ||
        status.category == PNReconnectedCategory ||
        status.category == PNDisconnectedCategory ||
        status.category == PNUnexpectedDisconnectCategory) {
        [self setRecentClientStatus:status.category withReachabilityCheck:status.requireNetworkAvailabilityCheck];
    }
}


#pragma mark - Handlers

#if TARGET_OS_OSX || TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)
- (void)handleContextTransition:(NSNotification *)notification {
#if TARGET_OS_IOS
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
            return [PNStringLogEntry entryWithMessage:@"Did enter background execution context."];
        }];
        
        [self.subscriptionNetwork suspend];
        [self.serviceNetwork suspend];
    } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
            return [PNStringLogEntry entryWithMessage:@"Will enter foreground execution context."];
        }];
        
        [self.subscriptionNetwork resume];
        [self.serviceNetwork resume];
    }
#elif TARGET_OS_WATCH
    if ([notification.name isEqualToString:NSExtensionHostDidEnterBackgroundNotification]) {
        [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
            return [PNStringLogEntry entryWithMessage:@"Did enter background execution context."];
        }];

        [self.subscriptionNetwork suspend];
        [self.serviceNetwork suspend];
    } else if ([notification.name isEqualToString:NSExtensionHostWillEnterForegroundNotification]) {
        [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
            return [PNStringLogEntry entryWithMessage:@"Will enter foreground execution context."];
        }];

        [self.subscriptionNetwork resume];
        [self.serviceNetwork resume];
    }
#elif TARGET_OS_OSX
    if ([notification.name isEqualToString:NSWorkspaceWillSleepNotification] ||
        [notification.name isEqualToString:NSWorkspaceSessionDidResignActiveNotification]) {
        [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
            return [PNStringLogEntry entryWithMessage:@"Workspace became inactive."];
        }];

        [self.subscriptionNetwork suspend];
        [self.serviceNetwork suspend];
    } else if ([notification.name isEqualToString:NSWorkspaceDidWakeNotification] ||
               [notification.name isEqualToString:NSWorkspaceSessionDidBecomeActiveNotification]) {
        [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
            return [PNStringLogEntry entryWithMessage:@"Workspace became active."];
        }];

        [self.subscriptionNetwork resume];
        [self.serviceNetwork resume];
    }
#endif // TARGET_OS_OSX
}
#endif // TARGET_OS_OSX || TARGET_OS_IOS && !defined(TARGET_IS_EXTENSION)



#pragma mark - Helpers

- (void)setupClientLogger {
    if (_configuration.logLevel == PNNoneLogLevel) return;
    
    NSMutableArray<id<PNLogger>> *loggers = [NSMutableArray arrayWithObject:[PNConsoleLogger new]];
    if (_configuration.loggers.count) [loggers addObjectsFromArray:_configuration.loggers];
    
    self.logger = [PNLoggerManager managerWithClientIdentifier:[_instanceID substringToIndex:6]
                                                      logLevel:_configuration.logLevel
                                                    andLoggers:loggers];
}

- (void)dealloc {
#if TARGET_OS_IOS
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
#elif TARGET_OS_OSX
    NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [notificationCenter removeObserver:self name:NSWorkspaceWillSleepNotification object:nil];
    [notificationCenter removeObserver:self name:NSWorkspaceSessionDidResignActiveNotification object:nil];
    [notificationCenter removeObserver:self name:NSWorkspaceDidWakeNotification object:nil];
    [notificationCenter removeObserver:self name:NSWorkspaceSessionDidBecomeActiveNotification object:nil];
#endif // TARGET_OS_OSX

    [_subscriptionNetwork invalidate];
    _subscriptionNetwork = nil;
    [_serviceNetwork invalidate];
    _serviceNetwork = nil;
    _filesManager = nil;
}

#pragma mark -


@end
