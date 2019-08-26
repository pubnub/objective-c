/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PubNub+CorePrivate.h"
#define PN_CORE_PROTOCOLS PNObjectEventListener

// Fabric
#ifdef FABRIC_SUPPORT
    #import "FABKitProtocol.h"
    #undef PN_CORE_PROTOCOLS
    #define PN_CORE_PROTOCOLS PNObjectEventListener, FABKit
#endif

#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
    #import <AppKit/AppKit.h>
#endif // TARGET_OS_OSX
#import "PubNub+SubscribePrivate.h"
#import "PNObjectEventListener.h"
#import "PNPrivateStructures.h"
#import "PNClientInformation.h"
#import "PNRequestParameters.h"
#import "PNSubscribeStatus.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PNReachability.h"
#import "PNConstants.h"
#import "PNKeychain.h"
#import "PNLogMacro.h"
#import "PNNetwork.h"
#import "PNHelpers.h"


#pragma mark - Externs

void pn_dispatch_async(dispatch_queue_t queue, dispatch_block_t block) {
    
    if (queue && block) {
        dispatch_async(queue, block);
    }
}

void pn_safe_property_read(dispatch_queue_t queue, dispatch_block_t block) {
    
    if (queue && block) {
        dispatch_sync(queue, block);
    }
}

void pn_safe_property_write(dispatch_queue_t queue, dispatch_block_t block) {
    
    if (queue && block) {
        dispatch_barrier_async(queue, block);
    }
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

#pragma mark - Protected interface declaration

@interface PubNub () <PN_CORE_PROTOCOLS>


#pragma mark - Properties

@property (nonatomic, strong) PNLLogger *logger;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;
@property (nonatomic, copy) PNConfiguration *configuration;
@property (nonatomic, copy) NSString *instanceID;
@property (nonatomic, strong) PNSubscriber *subscriberManager;
@property (nonatomic, strong) PNPublishSequence *sequenceManager;
@property (nonatomic, strong) PNClientState *clientStateManager;
@property (nonatomic, strong) PNStateListener *listenersManager;
@property (nonatomic, strong) PNHeartbeat *heartbeatManager;
@property (nonatomic, strong) PNTelemetry *telemetryManager;
@property (nonatomic, assign) PNStatusCategory recentClientStatus;
@property (nonatomic, strong) PNNetwork *subscriptionNetwork;
@property (nonatomic, strong) PNNetwork *serviceNetwork;

/**
 * @brief Reachability helper.
 *
 * @discussion Helper used by client to know about when something happened with network and when it
 * is safe to issue requests to \b PubNub network.
 */
@property (nonatomic, strong) PNReachability *reachability;


#pragma mark - Initialization

/**
 * @brief Initialize \b PubNub client instance with pre-defined configuration.
 *
 * @discussion If all keys will be specified, client will be able to read and modify data on
 * \b PubNub service.
 *
 * @param configuration Reference on instance which store all user-provided information about how
 *     client should operate and handle events.
 * @param callbackQueue Reference on queue which should be used by client fot completion block and
 *     delegate calls.
 *
 * @return Initialized and ready to use \b PubNub client.
*/
- (instancetype)initWithConfiguration:(PNConfiguration *)configuration
                        callbackQueue:(nullable dispatch_queue_t)callbackQueue;

/**
 * @brief Update current client state.
 *
 * @discussion Use subscription status to translate it to proper client state and launch service
 * reachability check if will be required.
 *
 * @param recentClientStatus Recent subscriber state which should be used to set proper client
 *     state.
 * @param shouldCheckReachability Whether service reachability check should be started or not.
 */
- (void)setRecentClientStatus:(PNStatusCategory)recentClientStatus
        withReachabilityCheck:(BOOL)shouldCheckReachability;


#pragma mark - Reachability

/**
 * @brief Complete reachability helper configuration.
 */
- (void)prepareReachability;


#pragma mark - PubNub Network managers

/**
 * @brief Initialize and configure required \b PubNub network managers.
 */
- (void)prepareNetworkManagers;


#pragma mark - Handlers

/**
 * @brief Handle application with active client transition between foreground and background
 * execution contexts.
 *
 * @param notification Notification which will provide information about to which context
 *     application has been pushed.
 */
- (void)handleContextTransition:(NSNotification *)notification;


#pragma mark - Misc

/**
 * @brief Status class which should be used to represent request error.
 *
 * @param request Request with information which should be used to decide on class.
 *
 * @return Class for error status presentation.
 */
- (Class)errorStatusClassForRequest:(PNRequest *)request;

/**
 * @brief Store provided unique user identifier in keychain.
 *
 * @param uuid Unique user identifier which has been provided with \b PNConfiguration instance.
 *
 * @since 4.5.15
 */
- (void)storeUUID:(NSString *)uuid;

/**
 * @brief Create and configure \b PubNub client logger instance.
 *
 * @since 4.5.0
 */
- (void)setupClientLogger;

/**
 * @brief Print out logger's verbosity configuration information.
 *
 * @since 4.5.0
 */
- (void)printLogVerbosityInformation;

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
    
    return self.configuration.uuid;
}


#pragma mark - Initialization

+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration {
    
    return [self clientWithConfiguration:configuration callbackQueue:nil];
}

+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration
                          callbackQueue:(dispatch_queue_t)callbackQueue {
    
    dispatch_queue_t queue = (callbackQueue ?: dispatch_get_main_queue());

    if (@available(macOS 10.10, iOS 8.0, *)) {
        if (configuration.applicationExtensionSharedGroupIdentifier) {
            queue = dispatch_get_main_queue();
        }
    }
    
    return [[self alloc] initWithConfiguration:configuration callbackQueue:queue];
}

- (instancetype)initWithConfiguration:(PNConfiguration *)configuration
                        callbackQueue:(dispatch_queue_t)callbackQueue {

    if ((self = [super init])) {
        [self storeUUID:configuration.uuid];
        [self setupClientLogger];
        
        PNLogClientInfo(self.logger, @"<PubNub> PubNub SDK %@ (%@)", kPNLibraryVersion, kPNCommit);
        
        _configuration = [configuration copy];
        _callbackQueue = callbackQueue;
        _instanceID = [[[NSUUID UUID] UUIDString] copy];

        if (NSClassFromString(@"XCTestExpectation")) {
            _instanceID = [@"58EB05C9-9DE4-4118-B5D7-EE059FBF19A9" copy];
        }

        [self prepareNetworkManagers];
        
        _subscriberManager = [PNSubscriber subscriberForClient:self];
        _sequenceManager = [PNPublishSequence sequenceForClient:self];
        _clientStateManager = [PNClientState stateForClient:self];
        _listenersManager = [PNStateListener stateListenerForClient:self];
        _heartbeatManager = [PNHeartbeat heartbeatForClient:self];
        _telemetryManager = [PNTelemetry new];

        [self addListener:self];
        [self prepareReachability];
#if TARGET_OS_IOS
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(handleContextTransition:)
                                   name:UIApplicationWillEnterForegroundNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleContextTransition:)
                                   name:UIApplicationDidEnterBackgroundNotification
                                 object:nil];
#elif TARGET_OS_WATCH
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:NSExtensionHostWillEnterForegroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:NSExtensionHostDidEnterBackgroundNotification object:nil];
#elif TARGET_OS_OSX
        NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:NSWorkspaceWillSleepNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:NSWorkspaceSessionDidResignActiveNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:NSWorkspaceDidWakeNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:NSWorkspaceSessionDidBecomeActiveNotification object:nil];
#endif
    }
    
    return self;
}

- (void)copyWithConfiguration:(PNConfiguration *)configuration
                   completion:(void(^)(PubNub *client))block {

    [self copyWithConfiguration:configuration callbackQueue:self.callbackQueue completion:block];
}

- (void)copyWithConfiguration:(PNConfiguration *)configuration
                callbackQueue:(dispatch_queue_t)callbackQueue
                   completion:(void(^)(PubNub *client))block {
    
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
        if (![configuration.uuid isEqualToString:self.configuration.uuid] ||
            ![configuration.authKey isEqualToString:self.configuration.authKey]) {
            
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

- (void)setRecentClientStatus:(PNStatusCategory)recentClientStatus
        withReachabilityCheck:(BOOL)shouldCheckReachability {
    
    PNStatusCategory previousState = self.recentClientStatus;
    PNStatusCategory currentState = recentClientStatus;
    
    if (currentState == PNReconnectedCategory) {
        currentState = PNConnectedCategory;
    }
    
    if (currentState == PNDisconnectedCategory && ([[self channels] count] ||
                                                   [[self channelGroups] count] ||
                                                   [[self presenceChannels] count])) {
        
        currentState = PNConnectedCategory;
    }
    
    self->_recentClientStatus = currentState;
    
    if (currentState == PNUnexpectedDisconnectCategory && shouldCheckReachability) {
        if (previousState == PNDisconnectedCategory) {
            return;
        }
        
        __weak __typeof(self) weakSelf = self;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(delay, self.callbackQueue, ^{
            [weakSelf.reachability startServicePing];
        });
    }
}


#pragma mark - Fabric support
#ifdef FABRIC_SUPPORT
+ (NSString *)bundleIdentifier {
    
    return kPNClientIdentifier;
}

+ (NSString *)kitDisplayVersion {
    
    return [self information].version;
}
#endif


#pragma mark - Reachability

- (void)prepareReachability {

    __weak __typeof(self) weakSelf = self;
    _reachability = [PNReachability reachabilityForClient:self withPingStatus:^(BOOL pingSuccessful) {
        
        if (pingSuccessful) {
            // Silence static analyzer warnings.
            // Code is aware about this case and at the end will simply call on 'nil' object method.
            // In most cases if referenced object become 'nil' it mean what there is no more need in
            // it and probably whole client instance has been deallocated.
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
            [weakSelf.reachability stopServicePing];
            [weakSelf cancelSubscribeOperations];
            [weakSelf.subscriberManager restoreSubscriptionCycleIfRequiredWithCompletion:nil];
            #pragma clang diagnostic pop
        }
    }];
}


#pragma mark - PubNub Network managers

- (void)prepareNetworkManagers {
    
    // Check whether application extension support enabled or not.
    // Long-poll tasks not supported in application extension context.
    BOOL shouldCreateSubscriptionNetwork = YES;
    NSInteger maximumConnections = 3;

    if (@available(macOS 10.10, iOS 8.0, *)) {
        NSString *sharedGroupIdentifier = _configuration.applicationExtensionSharedGroupIdentifier;
        shouldCreateSubscriptionNetwork = sharedGroupIdentifier == nil;
        maximumConnections = shouldCreateSubscriptionNetwork ? maximumConnections : 1;
    }

    if (shouldCreateSubscriptionNetwork) {
        _subscriptionNetwork = [PNNetwork networkForClient:self
                                            requestTimeout:_configuration.subscribeMaximumIdleTime
                                        maximumConnections:1 longPoll:YES];
    }

    _serviceNetwork = [PNNetwork networkForClient:self
                                   requestTimeout:_configuration.nonSubscribeRequestTimeout
                               maximumConnections:maximumConnections
                                         longPoll:NO];
}


#pragma mark - Requests helper

- (void)performRequest:(PNRequest *)request withCompletion:(id)block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak __typeof(self) weakSelf = self;
    
    if (@available(macOS 10.10, iOS 8.0, *)) {
        if (self.configuration.applicationExtensionSharedGroupIdentifier) {
            queue = dispatch_get_main_queue();
        }
    }
    
    dispatch_async(queue, ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        NSString *httpMethod = request.httpMethod.lowercaseString;
        BOOL hasBody = [@[@"post", @"patch"] indexOfObject:httpMethod] != NSNotFound;
        PNRequestParameters *parameters = request.requestParameters;
        parameters.HTTPMethod = request.httpMethod;
        NSData *data = hasBody ? request.bodyData : nil;
        
        NSError *error = request.parametersError;
        id requestCompletionBlock = nil;
        id errorStatus = nil;
        
        if (error) {
            Class errorStatusClass = [self errorStatusClassForRequest:request];
            errorStatus = [errorStatusClass objectForOperation:request.operation
                                             completedWithTask:nil
                                                 processedData:nil
                                               processingError:error];
            [(PNStatus *)errorStatus updateCategory:PNBadRequestCategory];
        }
        
        if ([request.httpMethod isEqualToString:@"GET"]) {
            requestCompletionBlock = ^(PNResult *result, PNStatus *status) {
                [strongSelf callBlock:block status:NO withResult:result andStatus:status];
            };
        } else {
            requestCompletionBlock = ^(PNStatus *status) {
                [strongSelf callBlock:block status:YES withResult:nil andStatus:status];
            };
        }
        
        if (errorStatus) {
            if ([request.httpMethod isEqualToString:@"GET"]) {
                [strongSelf callBlock:block status:NO withResult:nil andStatus:errorStatus];
            } else {
                [strongSelf callBlock:block status:YES withResult:nil andStatus:errorStatus];
            }
            
            return;
        }
        
        [self processOperation:request.operation
                withParameters:parameters
                          data:data
               completionBlock:requestCompletionBlock];
    });
}


#pragma mark - Operation processing

- (void)processOperation:(PNOperationType)operationType
          withParameters:(PNRequestParameters *)parameters
         completionBlock:(id)block {

    [self processOperation:operationType withParameters:parameters data:nil completionBlock:block];
}

- (void)processOperation:(PNOperationType)operationType
          withParameters:(PNRequestParameters *)parameters
                    data:(NSData *)data completionBlock:(id)block {
    
    if (operationType == PNSubscribeOperation || operationType == PNUnsubscribeOperation) {
        [self.subscriptionNetwork processOperation:operationType
                                    withParameters:parameters
                                              data:data
                                   completionBlock:block];
    } else {
        [self.serviceNetwork processOperation:operationType
                               withParameters:parameters
                                         data:data
                              completionBlock:block];
    }
}


#pragma mark - Operation information

- (NSInteger)packetSizeForOperation:(PNOperationType)operationType
                     withParameters:(PNRequestParameters *)parameters
                               data:(NSData *)data {
    
    PNNetwork *network = self.subscriptionNetwork;

    if (operationType != PNSubscribeOperation && operationType != PNUnsubscribeOperation) {
        network = self.serviceNetwork;
    }
    
    return [network packetSizeForOperation:operationType withParameters:parameters data:data];
}

- (void)appendClientInformation:(PNResult *)result {
    
    result.TLSEnabled = self.configuration.isTLSEnabled;
    result.uuid = self.configuration.uuid;
    result.authKey = self.configuration.authKey;
    result.origin = self.configuration.origin;
}


#pragma mark - Events notification

- (void)callBlock:(id)block
           status:(BOOL)callingStatusBlock
       withResult:(PNResult *)result
        andStatus:(PNStatus *)status {
    
    if (result) {
        PNLogResult(self.logger, @"<PubNub> %@", [result stringifiedRepresentation]);
    }
    
    if (status) {
        if (status.isError) {
            PNLogFailureStatus(self.logger, @"<PubNub> %@", [status stringifiedRepresentation]);
        } else {
            PNLogStatus(self.logger, @"<PubNub> %@", [status stringifiedRepresentation]);
        }
    }

    if (block) {
        pn_dispatch_async(self.callbackQueue, ^{
            if (!callingStatusBlock) {
                ((PNCompletionBlock)block)(result, status);
            } else {
                ((PNStatusBlock)block)(status);
            }
        });
    }
}

- (void)client:(PubNub *)__unused client didReceiveStatus:(PNSubscribeStatus *)status {
    
    if (status.category == PNConnectedCategory || status.category == PNReconnectedCategory ||
        status.category == PNDisconnectedCategory ||
        status.category == PNUnexpectedDisconnectCategory) {
        
        [self setRecentClientStatus:status.category
              withReachabilityCheck:status.requireNetworkAvailabilityCheck];
    }
}


#pragma mark - Handlers

- (void)handleContextTransition:(NSNotification *)notification {
    
#if TARGET_OS_IOS
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        PNLogClientInfo(self.logger, @"<PubNub> Did enter background execution context.");

        if (self.configuration.shouldCompleteRequestsBeforeSuspension) {
            [self.subscriptionNetwork handleClientWillResignActive];
            [self.serviceNetwork handleClientWillResignActive];
        }
    } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        PNLogClientInfo(self.logger, @"<PubNub> Will enter foreground execution context.");

        if (self.configuration.shouldCompleteRequestsBeforeSuspension) {
            [self.subscriptionNetwork handleClientDidBecomeActive];
            [self.serviceNetwork handleClientDidBecomeActive];
        }
    }
#elif TARGET_OS_WATCH
    if ([notification.name isEqualToString:NSExtensionHostDidEnterBackgroundNotification]) {
        PNLogClientInfo(self.logger, @"<PubNub> Did enter background execution context.");
    } else if ([notification.name isEqualToString:NSExtensionHostWillEnterForegroundNotification]) {
        PNLogClientInfo(self.logger, @"<PubNub> Will enter foreground execution context.");
    }
#elif TARGET_OS_OSX
    if ([notification.name isEqualToString:NSWorkspaceWillSleepNotification] ||
        [notification.name isEqualToString:NSWorkspaceSessionDidResignActiveNotification]) {

        PNLogClientInfo(self.logger, @"<PubNub> Workspace became inactive.");
    } else if ([notification.name isEqualToString:NSWorkspaceDidWakeNotification] ||
               [notification.name isEqualToString:NSWorkspaceSessionDidBecomeActiveNotification]) {
        
        PNLogClientInfo(self.logger, @"<PubNub> Workspace became active.");
    }
#endif // TARGET_OS_OSX
}


#pragma mark - Misc

- (Class)errorStatusClassForRequest:(PNRequest *)request {
    Class class = [PNErrorStatus class];
    
    if (PNOperationStatusClasses[request.operation]) {
        class = NSClassFromString(PNOperationStatusClasses[request.operation]);
    }
    
    return class;
}

- (void)storeUUID:(NSString *)uuid {
    
    [PNKeychain storeValue:uuid forKey:kPNConfigurationUUIDKey withCompletionBlock:NULL];
}

- (void)setupClientLogger {

#if TARGET_OS_TV && !TARGET_OS_SIMULATOR
    NSSearchPathDirectory searchPath = NSCachesDirectory;
#else 
    NSSearchPathDirectory searchPath = (TARGET_OS_IPHONE ? NSDocumentDirectory
                                                         : NSApplicationSupportDirectory);
#endif // TARGET_OS_TV && !TARGET_OS_SIMULATOR
    NSArray *documents = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
    NSString *logsPath = documents.lastObject;
#if TARGET_OS_OSX || TARGET_OS_SIMULATOR
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (NSClassFromString(@"XCTestExpectation")) { bundleIdentifier = @"com.pubnub.objc-tests"; }
    logsPath = [logsPath stringByAppendingPathComponent:bundleIdentifier];
#endif // TARGET_OS_OSX || TARGET_OS_SIMULATOR
    logsPath = [logsPath stringByAppendingPathComponent:@"Logs"];
    
    __weak __typeof__(self) weakSelf = self;
    self.logger = [PNLLogger loggerWithIdentifier:kPNClientIdentifier directory:logsPath 
                                     logExtension:@"log"];
    self.logger.enabled = NO;
    self.logger.writeToConsole = YES;
    self.logger.writeToFile = YES;
    [self.logger setLogLevel:(PNInfoLogLevel | PNFailureStatusLogLevel | PNAPICallLogLevel)];
    self.logger.logFilesDiskQuota = (50 * 1024 * 1024);
    self.logger.maximumLogFileSize = (5 * 1024 * 1024);
    self.logger.maximumNumberOfLogFiles = 5;

    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        weakSelf.logger.logLevelChangeHandler = ^{
            [weakSelf printLogVerbosityInformation];
        };

        [weakSelf printLogVerbosityInformation];
    });
}

- (void)printLogVerbosityInformation {
    
    NSUInteger verbosityFlags = self.logger.logLevel;
    NSMutableArray *enabledFlags = [NSMutableArray new];

    if (verbosityFlags & PNReachabilityLogLevel) {
        [enabledFlags addObject:@"Reachability"];
    }

    if (verbosityFlags & PNRequestLogLevel) {
        [enabledFlags addObject:@"Network Request"];
    }

    if (verbosityFlags & PNResultLogLevel) {
        [enabledFlags addObject:@"Result instance"];
    }

    if (verbosityFlags & PNStatusLogLevel) {
        [enabledFlags addObject:@"Status instance"];
    }

    if (verbosityFlags & PNFailureStatusLogLevel) {
        [enabledFlags addObject:@"Failed status instance"];
    }

    if (verbosityFlags & PNAESErrorLogLevel) {
        [enabledFlags addObject:@"AES error"];
    }

    if (verbosityFlags & PNAPICallLogLevel) {
        [enabledFlags addObject:@"API Call"];
    }
    
    PNLogClientInfo(self.logger, @"<PubNub::Logger> Enabled verbosity level flags: %@",
        [enabledFlags componentsJoinedByString:@", "]);
}

- (void)dealloc {
    
#if TARGET_OS_IOS
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:UIApplicationWillEnterForegroundNotification
                                object:nil];
    [notificationCenter removeObserver:self
                                  name:UIApplicationDidEnterBackgroundNotification
                                object:nil];
#elif TARGET_OS_WATCH
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:NSExtensionHostDidEnterBackgroundNotification
                                object:nil];
    [notificationCenter removeObserver:self
                                  name:NSExtensionHostWillEnterForegroundNotification
                                object:nil];
#elif TARGET_OS_OSX
    NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [notificationCenter removeObserver:self name:NSWorkspaceWillSleepNotification object:nil];
    [notificationCenter removeObserver:self
                                  name:NSWorkspaceSessionDidResignActiveNotification
                                object:nil];
    [notificationCenter removeObserver:self name:NSWorkspaceDidWakeNotification object:nil];
    [notificationCenter removeObserver:self
                                  name:NSWorkspaceSessionDidBecomeActiveNotification
                                object:nil];
#endif // TARGET_OS_OSX

    [_subscriptionNetwork invalidate];
    _subscriptionNetwork = nil;
    [_serviceNetwork invalidate];
    _serviceNetwork = nil;
    [_telemetryManager invalidate];
}

#pragma mark -


@end
