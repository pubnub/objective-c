/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
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
#import "PNClientInformation.h"
#import "PNRequestParameters.h"
#import "PNSubscribeStatus.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PNReachability.h"
#import "PNConstants.h"
#import "PNLogMacro.h"
#import "PNNetwork.h"
#import "PNHelpers.h"


#pragma mark - Externs

void pn_dispatch_async(dispatch_queue_t queue, dispatch_block_t block) {
    
    if (queue && block) { dispatch_async(queue, block); }
}

void pn_safe_property_read(dispatch_queue_t queue, dispatch_block_t block) {
    
    if (queue && block) { dispatch_sync(queue, block); }
}

void pn_safe_property_write(dispatch_queue_t queue, dispatch_block_t block) {
    
    if (queue && block) { dispatch_barrier_async(queue, block); }
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
@property (nonatomic, assign) PNStatusCategory recentClientStatus;

/**
 @brief Stores reference on \b PubNub network manager configured to be used for 'subscription' API 
        group with long-polling.
 
 @since 4.0
 */
@property (nonatomic, strong) PNNetwork *subscriptionNetwork;

/**
 @brief Stores reference on \b PubNub network manager configured to be used for 'non-subscription'
        API group.
 
 @since 4.0
 */
@property (nonatomic, strong) PNNetwork *serviceNetwork;

/**
 @brief  Stores reference on reachability helper.
 @discussion Helper used by client to know about when something happened with network and when it is
             safe to issue requests to \b PubNub network.
 
 @since 4.0
 */
@property (nonatomic, strong) PNReachability *reachability;


#pragma mark - Initialization

/**
 @brief      Initialize \b PubNub client instance with pre-defined configuration.
 @discussion If all keys will be specified, client will be able to read and modify data on 
             \b PubNub service.

 @param configuration Reference on instance which store all user-provided information about how
                      client should operate and handle events.
 @param callbackQueue Reference on queue which should be used by client fot comletion block and 
                      delegate calls.

 @return Initialized and ready to use \b PubNub client.
 
 @since 4.0
*/
- (instancetype)initWithConfiguration:(PNConfiguration *)configuration
                        callbackQueue:(nullable dispatch_queue_t)callbackQueue;


#pragma mark - Reachability

/**
 @brief  Complete reachability helper configuration.
 
 @since 4.0
 */
- (void)prepareReachability;


#pragma mark - PubNub Network managers

/**
 @brief  Initialize and configure required \b PubNub network managers.
 
 @since 4.0
 */
- (void)prepareNetworkManagers;


#pragma mark - Handlers

/**
 @brief  Handle application with active client transition between foreground and background 
         execution contexts.
 
 @param notification Reference on notification which will provide information about to which context
                     application has been pushed.
 */
- (void)handleContextTransition:(NSNotification *)notification;


#pragma mark - Misc

/**
 @brief  Create and configure \b PubNub client logger instance.
 
 @since 4.5.0
 */
- (void)setupClientLogger;

/**
 @brief  Print out logger's verbosity configuration information.
 
 @since 4.5.0
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
    dispatch_once(&onceToken, ^{ _sharedClientInformation = [PNClientInformation new]; });
    
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
    
    dispatch_queue_t queue = (callbackQueue?: dispatch_get_main_queue());
    if (configuration.applicationExtensionSharedGroupIdentifier != nil) { queue = dispatch_get_main_queue(); }
    
    return [[self alloc] initWithConfiguration:configuration callbackQueue:queue];
}

- (instancetype)initWithConfiguration:(PNConfiguration *)configuration
                        callbackQueue:(dispatch_queue_t)callbackQueue {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        [self setupClientLogger];
        DDLogClientInfo(self.logger, @"<PubNub> PubNub SDK %@ (%@)", kPNLibraryVersion, kPNCommit);
        
        _configuration = [configuration copy];
        _callbackQueue = callbackQueue;
        _instanceID = [[[NSUUID UUID] UUIDString] copy];
        // In case if we client used from tests environment configuration should use specified
        // device and instance identifier.
        if (NSClassFromString(@"XCTestExpectation")) {
            
            _instanceID = [@"58EB05C9-9DE4-4118-B5D7-EE059FBF19A9" copy];
        }
        [self prepareNetworkManagers];
        
        _subscriberManager = [PNSubscriber subscriberForClient:self];
        _sequenceManager = [PNPublishSequence sequenceForClient:self];
        _clientStateManager = [PNClientState stateForClient:self];
        _listenersManager = [PNStateListener stateListenerForClient:self];
        _heartbeatManager = [PNHeartbeat heartbeatForClient:self];
        [self addListener:self];
        [self prepareReachability];
#if TARGET_OS_IOS
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:UIApplicationWillEnterForegroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:UIApplicationDidEnterBackgroundNotification object:nil];
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
    
    dispatch_block_t subscriptionRestoreBlock = ^{
        
        [client.subscriberManager continueSubscriptionCycleIfRequiredWithCompletion:^(__unused PNSubscribeStatus *status) {
            
            if (block) { pn_dispatch_async(client.callbackQueue, ^{ block(client); }); }
        }];
    };
    if ([self.subscriberManager allObjects].count) {
        
        if (![configuration.uuid isEqualToString:self.configuration.uuid] ||
            ![configuration.authKey isEqualToString:self.configuration.authKey]) {
            __weak __typeof(self) weakSelf = self;
            [self unsubscribeFromChannels:self.subscriberManager.channels withPresence:YES
                               completion:^(__unused PNSubscribeStatus *status1) {
                   
                 __strong __typeof(self) strongSelf = weakSelf;
                [strongSelf unsubscribeFromChannelGroups:strongSelf.subscriberManager.channelGroups
                                            withPresence:YES
                                              completion:^(__unused PNSubscribeStatus *status2) {
                                          
                    subscriptionRestoreBlock();
                }];
            }];
        }
        else { subscriptionRestoreBlock(); }
    }
    else if (block) { pn_dispatch_async(client.callbackQueue, ^{ block(client); }); }
}

- (void)setRecentClientStatus:(PNStatusCategory)recentClientStatus {
    
    // Check whether previous client state reported unexpected disconnection from remote data objects live 
    // feed or not.
    PNStatusCategory previousState = self.recentClientStatus;
    PNStatusCategory currentState = recentClientStatus;
    if (currentState == PNReconnectedCategory) { currentState = PNConnectedCategory; }
    
    // In case if client disconnected only from one of it's channels it should keep 'connected' state.
    if (currentState == PNDisconnectedCategory &&
        ([[self channels] count] || [[self channelGroups] count] || [[self presenceChannels] count])) {
        
        currentState = PNConnectedCategory;
    }
    self->_recentClientStatus = currentState;
    
    // Check whether client reported unexpected disconnection.
    if (currentState == PNUnexpectedDisconnectCategory) {
        
        // Check whether client unexpectedly disconnected while tried to subscribe or not.
        if (previousState != PNDisconnectedCategory) {
            
            // Dispatching check block with small delay, which will allow to fire reachability
            // change event.
            __weak __typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               
                // Silence static analyzer warnings.
                // Code is aware about this case and at the end will simply call on 'nil' object
                // method. In most cases if referenced object become 'nil' it mean what there is no
                // more need in it and probably whole client instance has been deallocated.
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wreceiver-is-weak"
                [weakSelf.reachability startServicePing];
                #pragma clang diagnostic pop
            });
        }
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
            #pragma clang diagnostic ignored "-Wreceiver-is-weak"
            #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
            [weakSelf.reachability stopServicePing];
            [weakSelf.subscriberManager restoreSubscriptionCycleIfRequiredWithCompletion:nil];
            #pragma clang diagnostic pop
        }
    }];
}


#pragma mark - PubNub Network managers

- (void)prepareNetworkManagers {
    
    // Check whether application extension support enabled or not.
    // Long-poll tasks not supported in application extension context.
    if (_configuration.applicationExtensionSharedGroupIdentifier == nil) {
        
        _subscriptionNetwork = [PNNetwork networkForClient:self
                                            requestTimeout:_configuration.subscribeMaximumIdleTime
                                        maximumConnections:1 longPoll:YES];
    }
    
    _serviceNetwork = [PNNetwork networkForClient:self
                                   requestTimeout:_configuration.nonSubscribeRequestTimeout
                               maximumConnections:(_configuration.applicationExtensionSharedGroupIdentifier != nil ? 1 : 3)
                                         longPoll:NO];
}


#pragma mark - Operation processing

- (void)processOperation:(PNOperationType)operationType withParameters:(PNRequestParameters *)parameters
         completionBlock:(id)block {

    [self processOperation:operationType withParameters:parameters data:nil completionBlock:block];
}

- (void)processOperation:(PNOperationType)operationType withParameters:(PNRequestParameters *)parameters 
                    data:(NSData *)data completionBlock:(id)block {
    
    if (operationType == PNSubscribeOperation || operationType == PNUnsubscribeOperation) {
        
        [self.subscriptionNetwork processOperation:operationType withParameters:parameters
                                              data:data completionBlock:block];
    }
    else {
        
        [self.serviceNetwork processOperation:operationType withParameters:parameters
                                         data:data completionBlock:block];
    }
}

- (void)cancelAllLongPollingOperations {
    
    [self.subscriptionNetwork cancelAllRequests];
}


#pragma mark - Operation information

- (NSInteger)packetSizeForOperation:(PNOperationType)operationType
                     withParameters:(PNRequestParameters *)parameters data:(NSData *)data {
    
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

- (void)callBlock:(id)block status:(BOOL)callingStatusBlock withResult:(PNResult *)result 
        andStatus:(PNStatus *)status {
    
    if (result) { DDLogResult(self.logger, @"<PubNub> %@", [result stringifiedRepresentation]); }
    
    if (status) {
        
        if (status.isError) {
            
            DDLogFailureStatus(self.logger, @"<PubNub> %@", [status stringifiedRepresentation]);
        }
        else { DDLogStatus(self.logger, @"<PubNub> %@", [status stringifiedRepresentation]); }
    }

    if (block) {

        pn_dispatch_async(self.callbackQueue, ^{

            if (!callingStatusBlock) { ((PNCompletionBlock)block)(result, status); }
            else { ((PNStatusBlock)block)(status); }
        });
    }
}

- (void)client:(PubNub *)__unused client didReceiveStatus:(PNSubscribeStatus *)status {
    
    if (status.category == PNConnectedCategory || status.category == PNReconnectedCategory ||
        status.category == PNDisconnectedCategory || status.category == PNUnexpectedDisconnectCategory) {
        
        self.recentClientStatus = status.category;
    }
}


#pragma mark - Handlers

- (void)handleContextTransition:(NSNotification *)notification {
    
#if TARGET_OS_IOS
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        
        DDLogClientInfo(self.logger, @"<PubNub> Did enter background execution context.");
        if (self.configuration.shouldCompleteRequestsBeforeSuspension) {
            
            [self.subscriptionNetwork handleClientWillResignActive];
            [self.serviceNetwork handleClientWillResignActive];
        }
    }
    else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        
        DDLogClientInfo(self.logger, @"<PubNub> Will enter foreground execution context.");
        if (self.configuration.shouldCompleteRequestsBeforeSuspension) {
            
            [self.subscriptionNetwork handleClientDidBecomeActive];
            [self.serviceNetwork handleClientDidBecomeActive];
        }
    }
#elif TARGET_OS_WATCH
    if ([notification.name isEqualToString:NSExtensionHostDidEnterBackgroundNotification]) {
        
        DDLogClientInfo(self.logger, @"<PubNub> Did enter background execution context.");
    }
    else if ([notification.name isEqualToString:NSExtensionHostWillEnterForegroundNotification]) {
        
        DDLogClientInfo(self.logger, @"<PubNub> Will enter foreground execution context.");
    }
#elif TARGET_OS_OSX
    if ([notification.name isEqualToString:NSWorkspaceWillSleepNotification] ||
        [notification.name isEqualToString:NSWorkspaceSessionDidResignActiveNotification]) {
        
        DDLogClientInfo(self.logger, @"<PubNub> Workspace became inactive.");
    }
    else if ([notification.name isEqualToString:NSWorkspaceDidWakeNotification] ||
             [notification.name isEqualToString:NSWorkspaceSessionDidBecomeActiveNotification]) {
        
        DDLogClientInfo(self.logger, @"<PubNub> Workspace became active.");
    }
#endif // TARGET_OS_OSX
}


#pragma mark - Misc

- (void)setupClientLogger {
    
    // Configure file manager with default storage in application's Documents folder.
#if TARGET_OS_TV && !TARGET_OS_SIMULATOR
    NSSearchPathDirectory searchPath = NSCachesDirectory;
#else 
    NSSearchPathDirectory searchPath = (TARGET_OS_IPHONE ? NSDocumentDirectory : NSApplicationSupportDirectory);
#endif // TARGET_OS_TV && !TARGET_OS_SIMULATOR
    NSArray<NSString *> *documents = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
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
    [self.logger setLogLevel:(PNInfoLogLevel|PNFailureStatusLogLevel|PNAPICallLogLevel)];
    self.logger.logFilesDiskQuota = (50 * 1024 * 1024);
    self.logger.maximumLogFileSize = (5 * 1024 * 1024);
    self.logger.maximumNumberOfLogFiles = 5;
    
    // Give some time for components to setup loggers verbosity level (this avoid spam on log level change).
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        weakSelf.logger.logLevelChangeHandler = ^{ [weakSelf printLogVerbosityInformation]; };
        [weakSelf printLogVerbosityInformation];
    });
}

- (void)printLogVerbosityInformation {
    
    NSUInteger verbosityFlags = self.logger.logLevel;
    NSMutableArray *enabledFlags = [NSMutableArray new];
    if (verbosityFlags & PNReachabilityLogLevel) { [enabledFlags addObject:@"Reachability"]; }
    if (verbosityFlags & PNRequestLogLevel) { [enabledFlags addObject:@"Network Request"]; }
    if (verbosityFlags & PNResultLogLevel) { [enabledFlags addObject:@"Result instance"]; }
    if (verbosityFlags & PNStatusLogLevel) { [enabledFlags addObject:@"Status instance"]; }
    if (verbosityFlags & PNFailureStatusLogLevel) { [enabledFlags addObject:@"Failed status instance"]; }
    if (verbosityFlags & PNAESErrorLogLevel) { [enabledFlags addObject:@"AES error"]; }
    if (verbosityFlags & PNAPICallLogLevel) { [enabledFlags addObject:@"API Call"]; }
    
    DDLogClientInfo(self.logger, @"<PubNub::Logger> Enabled verbosity level flags: %@",
                    [enabledFlags componentsJoinedByString:@", "]);
}

- (void)dealloc {
    
#if TARGET_OS_IOS
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
#elif TARGET_OS_WATCH
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:NSExtensionHostDidEnterBackgroundNotification object:nil];
    [notificationCenter removeObserver:self name:NSExtensionHostWillEnterForegroundNotification object:nil];
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
}

#pragma mark -


@end
