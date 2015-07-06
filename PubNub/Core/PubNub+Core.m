/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+CorePrivate.h"
#import "PubNub+SubscribePrivate.h"
#import "PNObjectEventListener.h"
#import "PNRequestParameters.h"
#import "PNSubscribeStatus.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PNReachability.h"
#import "PNConstants.h"
#import "PNNetwork.h"
#import "PNHelpers.h"


#pragma mark Static

/**
 @brief  Cocoa Lumberjack logging level configuration for \b PubNub client class and categories.
 
 @since 4.0
 */
static DDLogLevel ddLogLevel = (DDLogLevel)(PNInfoLogLevel|PNFailureStatusLogLevel|
                                            PNAPICallLogLevel);


#pragma mark - Externs

void pn_dispatch_async(dispatch_queue_t queue, dispatch_block_t block) {
    
    if (queue && block) {
        
        dispatch_async(queue, block);
    }
}


#pragma mark - Protected interface declaration

@interface PubNub () <PNObjectEventListener>


#pragma mark - Properties

@property (nonatomic, strong) dispatch_queue_t callbackQueue;
@property (nonatomic, copy) PNConfiguration *configuration;
@property (nonatomic, strong) PNSubscriber *subscriberManager;
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
                        callbackQueue:(dispatch_queue_t)callbackQueue NS_DESIGNATED_INITIALIZER;


#pragma mark - Reachability

/**
 @brief      Complete reachability helper configuration.
 
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

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub


#pragma mark - Logger

+ (DDLogLevel)ddLogLevel {
    
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(DDLogLevel)logLevel {
    
    ddLogLevel = logLevel;
}


#pragma mark - Information

- (PNConfiguration *)currentConfiguration {
    
    return [self.configuration copy];
}

- (NSString *)uuid {
    
    return self.configuration.uuid;
}


#pragma mark - Initialization

+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration {
    
    return [[self alloc] initWithConfiguration:configuration
                                 callbackQueue:dispatch_get_main_queue()];
}

+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration
                          callbackQueue:(dispatch_queue_t)callbackQueue {
    
    return [[self alloc] initWithConfiguration:configuration callbackQueue:callbackQueue];
}

- (instancetype)initWithConfiguration:(PNConfiguration *)configuration
                        callbackQueue:(dispatch_queue_t)callbackQueue {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
#if DEBUG
        [PNLog dumpToFile:YES];
#else
        [PNLog dumpToFile:NO];
#endif
        
        DDLogClientInfo([[self class] ddLogLevel], @"<PubNub> PubNub SDK %@ (%@ %@)",
                        kPNLibraryVersion, kPNBranchName, kPNCommit);
        
        _configuration = [configuration copy];
        _callbackQueue = callbackQueue;
        [self prepareNetworkManagers];
        
        _subscriberManager = [PNSubscriber subscriberForClient:self];
        _clientStateManager = [PNClientState stateForClient:self];
        _listenersManager = [PNStateListener stateListenerForClient:self];
        _heartbeatManager = [PNHeartbeat heartbeatForClient:self];
        [self addListener:self];
        [self prepareReachability];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:UIApplicationWillEnterForegroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleContextTransition:)
                                   name:UIApplicationDidEnterBackgroundNotification object:nil];
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
            
            if (block) {
                
                pn_dispatch_async(client.callbackQueue, ^{
                    
                    block(client);
                });
            }
        }];
    };
    if ([[self.subscriberManager allObjects] count]) {
        
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
        else {
            
            subscriptionRestoreBlock();
        }
    }
    else if (block) {
        
        pn_dispatch_async(client.callbackQueue, ^{
            
            block(client);
        });
    }
}

- (void)setRecentClientStatus:(PNStatusCategory)recentClientStatus {
    
    // Check whether previous client state reported unexpected disconnection from remote data
    // objects live feed or not.
    PNStatusCategory previousState = self.recentClientStatus;
    PNStatusCategory currentState = recentClientStatus;
    
    // In case if client disconnected only from one of it's channels it should keep 'connected'
    // state.
    if (currentState == PNDisconnectedCategory &&
        ([[self channels] count] || [[self channelGroups] count] || [[self presenceChannels] count])) {
        
        currentState = PNConnectedCategory;
    }
    self->_recentClientStatus = currentState;
    
    // Check whether client reported unexpected disconnection.
    if (currentState == PNUnexpectedDisconnectCategory) {
        
        // Check whether client unexpectedly disconnected while tried to subscribe or not.
        if (previousState != PNUnknownCategory && previousState != PNDisconnectedCategory) {
            
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


#pragma mark - Reachability

- (void)prepareReachability {

    __weak __typeof(self) weakSelf = self;
    _reachability = [PNReachability reachabilityForClient:self
                                           withPingStatus:^(BOOL pingSuccessful) {
        
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
    
    _subscriptionNetwork = [PNNetwork networkForClient:self
                                        requestTimeout:_configuration.subscribeMaximumIdleTime
                                    maximumConnections:1 longPoll:YES];
    _serviceNetwork = [PNNetwork networkForClient:self
                                   requestTimeout:_configuration.nonSubscribeRequestTimeout
                               maximumConnections:3 longPoll:NO];
}


#pragma mark - Operation processing

- (void)processOperation:(PNOperationType)operationType
          withParameters:(PNRequestParameters *)parameters
         completionBlock:(id)block {

    [self processOperation:operationType withParameters:parameters data:nil completionBlock:block];
}

- (void)processOperation:(PNOperationType)operationType
          withParameters:(PNRequestParameters *)parameters data:(NSData *)data
         completionBlock:(id)block {
    
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
    
    if (result) {

        DDLogResult([[self class] ddLogLevel], @"<PubNub> %@", [result stringifiedRepresentation]);
    }
    
    if (status) {
        
        if (status.isError) {
            
            DDLogFailureStatus([[self class] ddLogLevel], @"<PubNub> %@", [status stringifiedRepresentation]);
        }
        else {
            
            DDLogStatus([[self class] ddLogLevel], @"<PubNub> %@", [status stringifiedRepresentation]);
        }
    }

    if (block) {

        pn_dispatch_async(self.callbackQueue, ^{

            if (!callingStatusBlock) {
                
                ((PNCompletionBlock)block)(result, status);
            }
            else {

                ((PNStatusBlock)block)(status);
            }
        });
    }
}

- (void)client:(PubNub *)__unused client didReceiveStatus:(PNSubscribeStatus *)status {
    
    if (status.category == PNConnectedCategory || status.category == PNDisconnectedCategory ||
        status.category == PNUnexpectedDisconnectCategory) {
        
        self.recentClientStatus = status.category;
    }
}


#pragma mark - Handlers

- (void)handleContextTransition:(NSNotification *)notification {
    
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        
        DDLogClientInfo([[self class] ddLogLevel], @"<PubNub> Did enter background execution context.");
    }
    else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        
        DDLogClientInfo([[self class] ddLogLevel], @"<PubNub> Will enter foreground execution context.");
    }
}


#pragma mark - Misc

- (void)dealloc {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification
                                object:nil];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification
                                object:nil];
}

#pragma mark -


@end
