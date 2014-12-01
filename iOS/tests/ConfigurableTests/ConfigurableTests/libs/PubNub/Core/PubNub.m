/**
 
 @author Sergey Mamontov
 @version 3.6.2
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+Protected.h"

#import "PubNub+SubscriptionProtected.h"
#import "PubNub+PresenceEvents.h"
#import "PubNub+Messaging.h"
#import "PubNub+Presence.h"
#import "PubNub+History.h"
#import "PubNub+State.h"
#import "PubNub+Time.h"
#import "PubNub+APNS.h"
#import "PubNub+PAM.h"


#import "PNConnectionChannel+Protected.h"
#import "PNPresenceEvent+Protected.h"
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    #import <UIKit/UIKit.h>
#else
    #import <AppKit/AppKit.h>
#endif
#import "PNServiceChannelDelegate.h"
#import "PNConnection+Protected.h"
#import "NSObject+PNAdditions.h"
#import "PNMessagingChannel.h"
#import "PNServiceChannel.h"
#import "PNRequestsImport.h"
#import "PNLoggerSymbols.h"
#import "PNNotifications.h"
#import "PNReachability.h"
#import "PNCryptoHelper.h"
#import "PNConstants.h"
#import "PNHelper.h"
#import "PNCache.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

/**
 Name of the branch which is used to store current codebase.
 */
static NSString * const kPNCodebaseBranch = @"develop";

/**
 SHA of the commit which stores actual changes in this codebase.
 */
static NSString * const kPNCodeCommitIdentifier = @"8d6cb267c30bacd9c491a1ddc2ecdfbbf366ea0b";

/**
 Stores reference on singleton PubNub instance and dispatch once token.
 
 @note Reference on dispatch once token allow to perform singleton reset.
 */
static PubNub *_sharedInstance = nil;
static dispatch_once_t onceToken;


#pragma mark - Private interface methods

@interface PubNub () <PNConnectionChannelDelegate, PNMessageChannelDelegate, PNServiceChannelDelegate>


#pragma mark - Properties

/**
 Stores current client state.
 */
@property (nonatomic, assign) PNPubNubClientState state;

/**
 Stores reference on current client identifier.
 */
@property (nonatomic, strong) NSString *uniqueClientIdentifier;

/**
 Stores reference on service reachability monitoring instance
 */
@property (nonatomic, strong) PNReachability *reachability;

/**
 Stores reference on configuration which was used to perform initial PubNub client initialization.
 */
@property (nonatomic, strong) PNConfiguration *clientConfiguration;

/**
 Stores reference on configuration which was used to perform initial PubNub client initialization
 */
@property (nonatomic, strong) PNConfiguration *temporaryConfiguration;

/**
 Stores reference on observation center which has been configured for this \b PubNub client.
 */
@property (nonatomic, strong) PNObservationCenter *observationCenter;

/**
 Reference on channels which is used to communicate with \b PubNub service
 */
@property (nonatomic, strong) PNMessagingChannel *messagingChannel;

/**
 Reference on channels which is used to send service messages to \b PubNub service
 */
@property (nonatomic, strong) PNServiceChannel *serviceChannel;

/**
 Stores reference on crypto helper tool which is used on message encryption/descryption.
 */
@property (nonatomic, strong) PNCryptoHelper *cryptoHelper;

/**
 Stores reference on local \b PubNub cache instance which will cache some portion of data.
 */
@property (nonatomic, strong) PNCache *cache;

/**
 Stores reference on last rescheduled method call date. This date is used to preven too frequent methods execution. Only
 one method will be executed, all other possible method calls will be postponed.
 */
@property (nonatomic, strong) NSDate *methodCallRescheduleDate;

/**
 Stores reference on timer which is used with heartbeat logic
 */
@property (nonatomic, pn_dispatch_property_ownership) dispatch_source_t heartbeatTimer;

/**
 Stores reference on client delegate
 */
@property (nonatomic, pn_desired_weak) id<PNDelegate> clientDelegate;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
/**
 Stores whether application is able to work in background or not.
 */
@property (nonatomic, readonly, getter = canRunInBackground) BOOL runInBackground;
#endif

/**
 Stores whether client should connect as soon as services will be checked for reachability
 */
@property (nonatomic, assign, getter = shouldConnectOnServiceReachabilityCheck) BOOL connectOnServiceReachabilityCheck;

/**
 Stores whether library is performing lock operation completion block or not (if yes, all further PubNub method calls
 will be placed into separate methods list and appended at the end of block execution).
 */
@property (nonatomic, assign, getter = isAsyncOperationCompletionInProgress) BOOL asyncOperationCompletionInProgress;

/**
 Stores whether client should perform initial connection (connection which is initialized after client configuration)
 */
@property (nonatomic, assign, getter = shouldConnectOnServiceReachability) BOOL connectOnServiceReachability;

/**
 Stores whether library is performing one of async locking methods or not (if yes, other calls will be placed
 into pending set)
 */
@property (nonatomic, assign, getter = isAsyncLockingOperationInProgress) BOOL asyncLockingOperationInProgress;

/**
 Stores reference on flag which specify whether client identifier was passed by user or generated on demand
 */
@property (nonatomic, assign, getter = isUserProvidedClientIdentifier) BOOL userProvidedClientIdentifier;

/**
 Stores whether client updating client identifier or not
 */
@property (nonatomic, assign, getter = isUpdatingClientIdentifier) BOOL updatingClientIdentifier;

/**
 Stores whether client is restoring connection after network failure or not
 */
@property (nonatomic, assign, getter = isRestoringConnection) BOOL restoringConnection;

/**
 Stores reference on list of invocation instances which is used to support synchronous library methods call
 (connect/disconnect/subscribe/unsubscribe)
 */
@property (nonatomic, strong) NSMutableArray *pendingInvocations;

/**
 Stores reference on list of invocations which has been created during async locking operation completion time (at completion
 time user provided few more methods which require to be placed next in queue).
 */
@property (nonatomic, strong) NSMutableArray *reprioritizedPendingInvocations;


#pragma mark - Misc methods

/**
 * Print out PubNub library information
 */
+ (void)showVersionInfo;


#pragma mark - Instance methods

#pragma mark - Client identification

- (void)postponeSetClientIdentifier:(NSString *)identifier;


#pragma mark - Client connection management methods

/**
 Postpone client connection user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param success
 The block which will be called by \b PubNub client as soon as it will complete handshake and all preparations. The block takes one argument:
 \c origin - name of the origin to which \b PubNub client connected.
 
 @param failure
 The block which will be called by \b PubNub client in case of any errors which occurred during connection. The block takes one argument:
 \c connectionError - error which describes what exactly went wrong. Always check \a connectionError.code to find out what caused error
 (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to
 get human readable description for error).
 */
- (void)postponeConnectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                             errorBlock:(PNClientConnectionFailureBlock)failure;

/**
 Perform client disconnection process which will terminate all pending requests and ubsubscribe from observation of all events.
 
 @param isDisconnectedByUser
 Depending on whether it is on or off, different types of clean up will be used.
 */
- (void)disconnectByUser:(BOOL)isDisconnectedByUser;

/**
 Postpone client disconnection so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param isDisconnectedByUser
 Depending on whether it is on or off, different types of clean up will be used.
 */
- (void)postponeDisconnectByUser:(BOOL)isDisconnectedByUser;

/**
 Temporary disconnect client for configuration update. After disconnection, new \b PNConfiguration will be applied with
 further reconnection.
 */
- (void)disconnectForConfigurationChange;

/**
 Postpone client disconnection for configuration change so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 */
- (void)postponeDisconnectForConfigurationChange;

/**
 * Configure client connection state observer with handling blocks
 
 @param success
 The block which will be called by \b PubNub client as soon as it will complete handshake and all preparations. The block takes one argument:
 \c origin - name of the origin to which \b PubNub client connected.
 
 @param failure
 The block which will be called by \b PubNub client in case of any errors which occurred during connection. The block takes one argument:
 \c connectionError - error which describes what exactly went wrong. Always check \a connectionError.code to find out what caused error
 (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to
 get human readable description for error).
 */
- (void)setClientConnectionObservationWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                                          failureBlock:(PNClientConnectionFailureBlock)failure;

/**
 * This method allow to schedule initial requests on connections to tell server that we are really interested in
 * persistent connection
 */
- (void)warmUpConnections;
- (void)warmUpConnection:(PNConnectionChannel *)connectionChannel;


#pragma mark - Requests management methods

/**
 * Send message over specified communication channel
 */
- (void)    sendRequest:(PNBaseRequest *)request onChannel:(PNConnectionChannel *)channel
shouldObserveProcessing:(BOOL)shouldObserveProcessing;


#pragma mark - Handler methods

- (void)handleHeartbeatTimer;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)handleApplicationDidEnterBackgroundState:(NSNotification *)notification;
- (void)handleApplicationDidEnterForegroundState:(NSNotification *)notification;
#else
- (void)handleWorkspaceWillSleep:(NSNotification *)notification;
- (void)handleWorkspaceDidWake:(NSNotification *)notification;
#endif

/**
 * Handling error which occurred while PubNub client tried establish connection and lost internet connection
 */
- (void)handleConnectionErrorOnNetworkFailure;
- (void)handleConnectionErrorOnNetworkFailureWithError:(PNError *)error;


#pragma mark - Misc methods

/**
 * Return whether library tries to resume operation at this moment or not
 */
- (void)checkResuming:(void (^)(BOOL resuming))checkCompletionBlock;

- (void)checkConnectionChannelsConnectionState:(void (^)(BOOL messageChannelConnected, BOOL serviceChannelConnected))checkCompletionBlock;
- (void)checkConnectionChannelsDisconnectionState:(void (^)(BOOL messageChannelDisconnected, BOOL serviceChannelDisconnected))checkCompletionBlock;
- (void)checkConnectionChannelsSuspendedState:(void (^)(BOOL messageChannelSuspended, BOOL serviceChannelSuspended))checkCompletionBlock;
- (void)checkConnectionChannelsResumeState:(void (^)(BOOL messageChannelResuming, BOOL serviceChannelResuming))checkCompletionBlock;

/**
 * Will prepare crypto helper it is possible
 */
- (void)prepareCryptoHelper;

/**
 * Will help to subscribe/unsubscribe on/from all critical application-wide notifications which may affect
 * client operation
 */
- (void)subscribeForNotifications;
- (void)unsubscribeFromNotifications;

/**
 * Flush postponed methods call queue. If 'shouldExecute' is set to 'YES', than they will be not just removed but also
 * their code will be called (procedural lock will be always 'OFF').
 */
- (void)flushPostponedMethods:(BOOL)shouldExecute;

/**
 * Check whether whether call to specific method should be postponed or not. This will allot to perform synchronous
 * call on specific library methods.
 */
- (BOOL)shouldPostponeMethodCall;

/**
 * This method will notify delegate about that connection to the PubNub service is established and send notification
 * about it
 */
- (void)notifyDelegateAboutConnectionToOrigin:(NSString *)originHostName;

/**
 * This method allow to ensure that delegate can process errors and will send error to the delegate
 */
- (void)notifyDelegateAboutError:(PNError *)error;

/**
 * This method allow notify delegate that client is about to close connection because of specified error
 */
- (void)notifyDelegateClientWillDisconnectWithError:(PNError *)error;
- (void)notifyDelegateClientDidDisconnectWithError:(PNError *)error;
- (void)notifyDelegateClientConnectionFailedWithError:(PNError *)error;

/**
 * Check whether client should restore connection after network went down and restored now
 */
- (BOOL)shouldRestoreConnection;

/**
 Check whether client should use latest time token during channels list change or not
 */
- (BOOL)shouldKeepTimeTokenOnChannelsListChange;

/**
 * Check whether client should restore subscription to previous channels or not
 */
- (BOOL)shouldRestoreSubscription;

/**
 * Check whether client should restore subscription with last time token or not
 */
- (BOOL)shouldRestoreSubscriptionWithLastTimeToken;

/**
 Print out PubNub client configuration information
 */
- (void)showConfigurationInfo;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PubNub


#pragma mark - Class methods

+ (void)initialize {
    
    if(self == [PubNub class]) {
        
        [PNLogger prepare];
        [self showVersionInfo];
    }

    [super initialize];
}

+ (PubNub *)sharedInstance {
    
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[self alloc] init];
    });
    
    
    return _sharedInstance;
}

+ (PubNub *)clientWithConfiguration:(PNConfiguration *)configuration {
    
    return [self clientWithConfiguration:configuration andDelegate:nil];
}

+ (PubNub *)clientWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {
    
    return [[self alloc] initWithConfiguration:configuration andDelegate:delegate];
}

+ (PubNub *)connectingClientWithConfiguration:(PNConfiguration *)configuration {
    
    return [self connectingClientWithConfiguration:configuration andSuccessBlock:nil errorBlock:nil];
}

+ (PubNub *)connectingClientWithConfiguration:(PNConfiguration *)configuration
                              andSuccessBlock:(PNClientConnectionSuccessBlock)success
                                   errorBlock:(PNClientConnectionFailureBlock)failure {
    
    return [self connectingClientWithConfiguration:configuration delegate:nil andSuccessBlock:success errorBlock:failure];
}

+ (PubNub *)connectingClientWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {
    
    return [self connectingClientWithConfiguration:configuration delegate:delegate andSuccessBlock:nil errorBlock:nil];
}

+ (PubNub *)connectingClientWithConfiguration:(PNConfiguration *)configuration delegate:(id<PNDelegate>)delegate
                              andSuccessBlock:(PNClientConnectionSuccessBlock)success
                                   errorBlock:(PNClientConnectionFailureBlock)failure {
    
    PubNub *pubNub = [[self alloc] initWithConfiguration:configuration andDelegate:delegate];
    [pubNub connectWithSuccessBlock:success errorBlock:failure];
    
    
    return pubNub;
}


+ (void)resetClient {

    [PNLogger logGeneralMessageFrom:_sharedInstance withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.reset];
    }];

    if (_sharedInstance) {

        [_sharedInstance pn_dispatchBlock:^{

            // Mark that client is in resetting state, so it won't be affected by callbacks from transport classes
            _sharedInstance.state = PNPubNubClientStateReset;
            [_sharedInstance stopHeartbeatTimer];

            onceToken = 0;
            [PNObservationCenter resetCenter];
            [PNChannel purgeChannelsCache];
            _sharedInstance.cryptoHelper = nil;
            
            _sharedInstance.clientConfiguration = nil;
            _sharedInstance.temporaryConfiguration = nil;

            _sharedInstance.updatingClientIdentifier = NO;
            _sharedInstance.messagingChannel.delegate = nil;
            [_sharedInstance.messagingChannel terminate];
            _sharedInstance.serviceChannel.delegate = nil;
            [_sharedInstance.serviceChannel terminate];
            _sharedInstance.messagingChannel = nil;
            _sharedInstance.serviceChannel = nil;
            [_sharedInstance.reachability stopServiceReachabilityMonitoring];
            _sharedInstance.reachability = nil;

            _sharedInstance.reprioritizedPendingInvocations = nil;
            _sharedInstance.pendingInvocations = nil;

            [_sharedInstance unsubscribeFromNotifications];
            _sharedInstance = nil;
        }];
    }
}


#pragma mark - Client configuration methods

+ (PNConfiguration *)configuration {
    
    return [[self sharedInstance] configuration];
}

+ (void)setConfiguration:(PNConfiguration *)configuration {
    
    [self setupWithConfiguration:configuration andDelegate:[self sharedInstance].clientDelegate];
}

+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {
    
    [[self sharedInstance] setupWithConfiguration:configuration andDelegate:delegate];
}

+ (void)setDelegate:(id<PNDelegate>)delegate {
    
    [[self sharedInstance] setDelegate:delegate];
}


#pragma mark - Client identification methods

+ (void)setClientIdentifier:(NSString *)identifier {
    
    [self setClientIdentifier:identifier shouldCatchup:NO];
}

+ (void)setClientIdentifier:(NSString *)identifier shouldCatchup:(BOOL)shouldCatchup {
    
    [[self sharedInstance] setClientIdentifier:identifier shouldCatchup:shouldCatchup];
}

+ (NSString *)clientIdentifier {
    
    return [[self sharedInstance] clientIdentifier];
}


#pragma mark - Client connection management methods

+ (void)connect {
    
    [[self sharedInstance] connect];
}

+ (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                     errorBlock:(PNClientConnectionFailureBlock)failure {
    
    [[self sharedInstance] connectWithSuccessBlock:success errorBlock:failure];
}

+ (void)disconnect {
    
	[[self sharedInstance] disconnect];
}


#pragma mark - Misc methods

+ (void)showVersionInfo {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
       
        return @[PNLoggerSymbols.api.clientInformation, kPNLibraryVersion, kPNCodebaseBranch, kPNCodeCommitIdentifier];
    }];
}


#pragma mark - Instance methods

- (id)init {
    
    return [self initWithConfiguration:nil andDelegate:nil];
}

- (id)initWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        [self pn_setupPrivateSerialQueueWithIdentifier:@"core" andPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];

        self.state = PNPubNubClientStateCreated;
        self.cache = [PNCache new];
        self.pendingInvocations = [NSMutableArray array];
        self.reprioritizedPendingInvocations = [NSMutableArray array];
        self.observationCenter = [PNObservationCenter observationCenterWithDefaultObserver:self];
        
        // Adding PubNub services availability observer
        __block __pn_desired_weak PubNub *weakSelf = self;
        self.reachability = [PNReachability serviceReachability];
        self.reachability.reachabilityChangeHandleBlock = ^(BOOL connected) {
            
            __strong __typeof__(self) strongSelf = weakSelf;

            [strongSelf pn_dispatchBlock:^{

                [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.api.isConnected, @(connected),
                             [strongSelf humanReadableStateFrom:strongSelf.state]];
                }];

                if (!connected) {

                    [strongSelf stopHeartbeatTimer];
                }

                strongSelf.updatingClientIdentifier = NO;
                if (strongSelf.shouldConnectOnServiceReachabilityCheck) {

                    [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                        return @[PNLoggerSymbols.api.connectOnNetworkReachabilityCheck,
                                [strongSelf humanReadableStateFrom:strongSelf.state]];
                    }];

                    if (connected) {

                        [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.networkAvailableProceedConnection,
                                    [strongSelf humanReadableStateFrom:strongSelf.state]];
                        }];

                        strongSelf.asyncLockingOperationInProgress = NO;

                        [strongSelf connect];
                    }
                    else {

                        strongSelf.connectOnServiceReachabilityCheck = NO;

                        [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.networkNotAvailableReportError,
                                    [strongSelf humanReadableStateFrom:strongSelf.state]];
                        }];

                        strongSelf.connectOnServiceReachability = YES;
                        [strongSelf handleConnectionErrorOnNetworkFailure];
                        strongSelf.asyncLockingOperationInProgress = NO;
                    }
                }
                else {

                    if (connected) {

                        [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.networkAvailable,
                                    [strongSelf humanReadableStateFrom:strongSelf.state]];
                        }];

                        // In case if client is in 'disconnecting on network error' state when connection become available
                        // force client to change it state to "completed" stage of disconnection on network error
                        if (strongSelf.state == PNPubNubClientStateDisconnectingOnNetworkError) {

                            [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                return @[PNLoggerSymbols.api.previouslyDisconnectedBecauseOfError,
                                        [strongSelf humanReadableStateFrom:strongSelf.state]];
                            }];

                            strongSelf.state = PNPubNubClientStateDisconnectedOnNetworkError;

                            [strongSelf.messagingChannel disconnectWithEvent:NO];
                            [strongSelf.serviceChannel disconnectWithEvent:NO];
                        }


                        // Check whether connection available message appeared while library tried to connect
                        // (to handle situation when library doesn't have enough time to accept callbacks and reset it
                        // state to 'disconnected'
                        if (strongSelf.state == PNPubNubClientStateConnecting) {

                            [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                return @[PNLoggerSymbols.api.connectionStateImpossibleOnNetworkBecomeAvailable,
                                        [strongSelf humanReadableStateFrom:strongSelf.state]];
                            }];

                            // Because all connection channels will be destroyed, it means that client currently disconnected
                            strongSelf.state = PNPubNubClientStateDisconnectedOnNetworkError;

                            [strongSelf.messagingChannel disconnectWithEvent:NO];
                            [strongSelf.serviceChannel disconnectWithEvent:NO];
                        }

                        BOOL isSuspended = strongSelf.state == PNPubNubClientStateSuspended;

                        if (strongSelf.state == PNPubNubClientStateDisconnectedOnNetworkError ||
                            strongSelf.shouldConnectOnServiceReachability || isSuspended) {

                            // Check whether should restore connection or not
                            if([strongSelf shouldRestoreConnection] || strongSelf.shouldConnectOnServiceReachability) {

                                strongSelf.asyncLockingOperationInProgress = NO;
                                if(!strongSelf.shouldConnectOnServiceReachability){

                                    [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                        return @[PNLoggerSymbols.api.shouldRestoreConnection,
                                                [strongSelf humanReadableStateFrom:strongSelf.state]];
                                    }];

                                    strongSelf.restoringConnection = YES;
                                }

                                if (isSuspended) {

                                    [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                        return @[PNLoggerSymbols.api.shouldResumeConnection,
                                                [strongSelf humanReadableStateFrom:strongSelf.state]];
                                    }];

                                    strongSelf.state = PNPubNubClientStateConnected;

                                    strongSelf.restoringConnection = NO;
                                    [strongSelf.messagingChannel resume];
                                    [strongSelf.serviceChannel resume];
                                }
                                else {

                                    [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                        return @[PNLoggerSymbols.api.shouldConnect,
                                                [strongSelf humanReadableStateFrom:strongSelf.state]];
                                    }];

                                    [strongSelf connect];
                                }
                            }
                        }
                        else {

                            [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                return @[PNLoggerSymbols.api.noSuitableActionsForCurrentSituation,
                                        [strongSelf humanReadableStateFrom:strongSelf.state]];
                            }];
                        }
                    }
                    else {

                        [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.networkNotAvailable,
                                     [strongSelf humanReadableStateFrom:strongSelf.state]];
                        }];
                        BOOL hasBeenSuspended = strongSelf.state == PNPubNubClientStateSuspended;

                        // Check whether PubNub client was connected or connecting right now
                        if (strongSelf.state == PNPubNubClientStateConnected ||
                            strongSelf.state == PNPubNubClientStateConnecting || hasBeenSuspended) {

                            if (strongSelf.state == PNPubNubClientStateConnecting) {

                                [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                    return @[PNLoggerSymbols.api.triedToConnect,
                                             [strongSelf humanReadableStateFrom:strongSelf.state]];
                                }];

                                strongSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;

                                // Messaging channel will close second channel automatically.
                                [strongSelf.messagingChannel disconnectWithReset:NO];

                                if (strongSelf.state == PNPubNubClientStateDisconnectingOnNetworkError ||
                                    strongSelf.state == PNPubNubClientStateDisconnectedOnNetworkError) {

                                    [strongSelf handleConnectionErrorOnNetworkFailure];
                                }
                                else {

                                    [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                        return @[PNLoggerSymbols.api.networkWentDownDuringConnectionRestoring,
                                                [strongSelf humanReadableStateFrom:strongSelf.state]];
                                    }];
                                }

                                [strongSelf flushPostponedMethods:YES];
                            }
                            else {

                                if (strongSelf.state == PNPubNubClientStateSuspended) {

                                    [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                        return @[PNLoggerSymbols.api.networkWentDownWhileSuspended,
                                                [strongSelf humanReadableStateFrom:strongSelf.state]];
                                    }];
                                }
                                else {

                                    [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                        return @[PNLoggerSymbols.api.networkWentDownWhileWasConnected,
                                                [strongSelf humanReadableStateFrom:strongSelf.state]];
                                    }];
                                }


                                if (![strongSelf shouldRestoreConnection]) {

                                    [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                        return @[PNLoggerSymbols.api.autoConnectionDisabled,
                                                [strongSelf humanReadableStateFrom:strongSelf.state]];
                                    }];
                                }
                                else {

                                    [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                        return @[PNLoggerSymbols.api.connectionWillBeRestoredOnNetworkConnectionRestore,
                                                [strongSelf humanReadableStateFrom:strongSelf.state]];
                                    }];
                                }

                                PNError *connectionError = [PNError errorWithCode:kPNClientConnectionClosedOnInternetFailureError];
                                [strongSelf notifyDelegateClientWillDisconnectWithError:connectionError];

                                strongSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;

                                // Check whether client was suspended or not.
                                if (hasBeenSuspended) {

                                    [strongSelf.messagingChannel disconnectWithReset:NO];
                                    [strongSelf.serviceChannel disconnect];

                                    [strongSelf notifyDelegateClientDidDisconnectWithError:connectionError];
                                }
                                else {

                                    [strongSelf flushPostponedMethods:YES];

                                    // Disconnect communication channels because of network issues
                                    // Messaging channel will close second channel automatically.
                                    [strongSelf.messagingChannel disconnectWithReset:NO];
                                }
                            }
                        }
                        else {

                            [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray *{

                                return @[PNLoggerSymbols.api.networkWentDownBeforeConnectionCompletion,
                                        [strongSelf humanReadableStateFrom:strongSelf.state]];
                            }];
                        }
                    }
                }
            }];
        };
        if (configuration) {
            
            [self setupWithConfiguration:configuration andDelegate:delegate];
        }
        
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.resourceLinkage, (self.observationCenter ? [NSString stringWithFormat:@"%p", self.observationCenter] : [NSNull null]),
                     (self.reachability ? [NSString stringWithFormat:@"%p", self.reachability] : [NSNull null]),
                     (self.cryptoHelper ? [NSString stringWithFormat:@"%p", self.cryptoHelper] : [NSNull null]),
                     (self.messagingChannel ? [NSString stringWithFormat:@"%p", self.messagingChannel] : [NSNull null]),
                     (self.serviceChannel ? [NSString stringWithFormat:@"%p", self.serviceChannel] : [NSNull null])];
        }];
        
        [self subscribeForNotifications];
    }
    
    
    return self;
}

- (NSArray *)presenceEnabledChannels {
    
    return [self.messagingChannel presenceEnabledChannels];
}

- (void)rescheduleMethodCall:(void(^)(void))methodBlock {

    void(^checkCompletionBlock)(BOOL) = ^(BOOL willRestore) {

        [self pn_dispatchBlock:^{

            if (!willRestore) {

                // Checking whether previous rescheduled method call was more than a second ago.
                // This limitation allow to prevent set of postponed methods performed at once w/o procedural lock.
                if (!self.methodCallRescheduleDate || ABS([self.methodCallRescheduleDate timeIntervalSinceNow]) > 1.0f) {

                    self.asyncLockingOperationInProgress = NO;
                }
            }

            self.methodCallRescheduleDate = [NSDate new];

            if (methodBlock) {

                methodBlock();
            }
        }];
    };

    if (self.messagingChannel) {

        [self.messagingChannel checkWillRestoreSubscription:checkCompletionBlock];
    }
    else {

        checkCompletionBlock(NO);
    }
}


#pragma mark - Client configuration

- (PNConfiguration *)configuration {
    
    return [self.clientConfiguration copy];
}

- (void)setConfiguration:(PNConfiguration *)configuration {
    
    [self setupWithConfiguration:configuration andDelegate:self.clientDelegate];
}

- (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {

    [self pn_dispatchBlock:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.configurationUpdateAttempt, [self humanReadableStateFrom:self.state]];
        }];

        // Ensure that configuration is valid before update/set client configuration to it
        if ([configuration isValid]) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.validConfigurationProvided, [self humanReadableStateFrom:self.state]];
            }];

            // Ensure that this is updated configuration (or new)
            if (![configuration isEqual:self.clientConfiguration]) {

                void(^updateConfigurationBlock)(void) = ^{

                    if (self.clientConfiguration == nil) {

                        self.clientConfiguration = configuration;
                    }
                    else {

                        [self.clientConfiguration migrateConfigurationFrom:configuration];
                    }
                    self.reachability.serviceOrigin = self.clientConfiguration.origin;
                    [self showConfigurationInfo];

                    [self prepareCryptoHelper];
                };

                void(^reachabilityConfigurationBlock)(BOOL) = ^(BOOL isInitialConfiguration) {

                    self.reachability.serviceOrigin = self.clientConfiguration.origin;
                    if (isInitialConfiguration) {

                        // Restart reachability monitor
                        [self.reachability startServiceReachabilityMonitoring];
                    }
                    else {

                        // Refresh reachability configuration
                        [self.reachability restartServiceReachabilityMonitoring];
                    }
                };

                [self setDelegate:delegate];

                BOOL isInitialConfiguration = self.clientConfiguration == nil;

                // Check whether PubNub client is connected to remote PubNub services or not
                if ([self isConnected]) {

                    // Check whether new configuration changed critical properties of client configuration or not
                    if ([self.clientConfiguration requiresConnectionResetWithConfiguration:configuration]) {

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                            return @[PNLoggerSymbols.api.configurationUpdateRequireReconnection,
                                    [self humanReadableStateFrom:self.state]];
                        }];

                        // Store new configuration while client is disconnecting
                        self.temporaryConfiguration = configuration;

                        // Disconnect before client configuration update
                        [self disconnectForConfigurationChange];
                    }
                    else {

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                            return @[PNLoggerSymbols.api.configurationUpdateDoesntRequireReconnection,
                                    [self humanReadableStateFrom:self.state]];
                        }];

                        updateConfigurationBlock();
                        reachabilityConfigurationBlock(isInitialConfiguration);
                    }
                }
                else {

                    [self checkResuming:^(BOOL resuming) {

                        if ([self isRestoringConnection] || resuming || self.state == PNPubNubClientStateConnecting) {

                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                return @[PNLoggerSymbols.api.triedUpdateConfigurationDuringConnection,
                                        [self humanReadableStateFrom:self.state]];
                            }];

                            // Disconnecting communication channels and preserve all issued requests which wasn't sent till
                            // this moment (they will be send as soon as connection will be restored)
                            [self.messagingChannel disconnectWithEvent:NO];
                            [self.serviceChannel disconnectWithEvent:NO];

                            self.state = PNPubNubClientStateDisconnected;

                            reachabilityConfigurationBlock(isInitialConfiguration);
                            self.asyncLockingOperationInProgress = NO;

                            [self connect];
                        }
                        else {

                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                return @[PNLoggerSymbols.api.configurationUpdateDoesntRequireReconnection,
                                        [self humanReadableStateFrom:self.state]];
                            }];

                            updateConfigurationBlock();

                            reachabilityConfigurationBlock(isInitialConfiguration);
                        }
                    }];
                }
            }
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.sameConfigurationHasBeenProvided,
                            [self humanReadableStateFrom:self.state]];
                }];
            }
        }
        else {

            // Notify delegate about client configuration error
            [self notifyDelegateAboutError:[PNError errorWithCode:kPNClientConfigurationError]];
        }
    }];
}

- (void)setDelegate:(id<PNDelegate>)delegate {

    self.clientDelegate = delegate;
}


#pragma mark - Client identification methods

- (void)setClientIdentifier:(NSString *)identifier {
    
    [self setClientIdentifier:identifier shouldCatchup:NO];
}

- (void)setClientIdentifier:(NSString *)identifier shouldCatchup:(BOOL)shouldCatchup {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.clientIdentifierUpdateAttempt, [self humanReadableStateFrom:self.state]];
        }];
        
        if (![self.uniqueClientIdentifier isEqualToString:identifier]) {
            
            [self performAsyncLockingBlock:^{
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.updatingClientIdentifier, [self humanReadableStateFrom:self.state]];
                }];
                
                // Check whether identifier has been changed since last method call or not
                if ([self isConnected]) {
                    
                    self.userProvidedClientIdentifier = identifier != nil;
                    
                    NSArray *allChannels = [self.messagingChannel fullSubscribedChannelsList];
                    if ([allChannels count]) {
                        
                        self.asyncLockingOperationInProgress = NO;
                        if (shouldCatchup) {
                            
                            [allChannels makeObjectsPerformSelector:@selector(lockTimeTokenChange)];
                        }
                        
                        __block NSUInteger resubscribeRetryCount = 0;
                        __block __pn_desired_weak PubNub *weakSelf = self;
                        __block void(^retrySubscription)(PNError *);
                        __block void(^retryUnsubscription)(PNError *);
                        
                        void(^resubscribeErrorBlock)(PNError *, void(^)(void)) = ^(PNError *resubscriptionError, void(^block)(void)) {
                            
                            __strong __typeof__(self) strongSelf = weakSelf;
                            
                            if (resubscribeRetryCount < kPNClientIdentifierUpdateRetryCount) {
                                
                                resubscribeRetryCount++;
                                block();
                            }
                            else {
                                
                                strongSelf.updatingClientIdentifier = NO;
                                [allChannels makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];
                                
                                [strongSelf notifyDelegateAboutSubscriptionFailWithError:resubscriptionError
                                                              completeLockingOperation:YES];
                            }
                        };
                        
                        void(^subscribeBlock)(void) = ^{
                            
                            __strong __typeof__(self) strongSelf = weakSelf;
                            
                            strongSelf.asyncLockingOperationInProgress = NO;
                            [strongSelf subscribeOn:allChannels withCatchUp:shouldCatchup clientState:nil
                       andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *subscribedChannels,
                                                    PNError *subscribeError) {
                           
                           if (subscribeError == nil) {
                               
                               strongSelf.updatingClientIdentifier = NO;
                               [allChannels makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];
                               
                               [strongSelf handleLockingOperationComplete:YES];
                           }
                           else {
                               
                               retrySubscription(subscribeError);
                           }
                       }];
                        };
                        
                        retrySubscription = ^(PNError *error) {
                            
                            resubscribeErrorBlock(error, subscribeBlock);
                        };
                        
                        void(^unsubscribeBlock)(void) = ^{
                            
                            __strong __typeof__(self) strongSelf = weakSelf;
                            
                            strongSelf.asyncLockingOperationInProgress = NO;
                            [strongSelf unsubscribeFrom:allChannels
                          withCompletionHandlingBlock:^(NSArray *leavedChannels, PNError *leaveError) {
                              
                              if (leaveError == nil) {
                                  
                                  // Check whether user identifier was provided by user or not
                                  if (identifier == nil) {
                                      
                                      // Change user identifier before connect to the PubNub services
                                      strongSelf.uniqueClientIdentifier = [PNHelper UUID];
                                  }
                                  else {
                                      
                                      strongSelf.uniqueClientIdentifier = identifier;
                                  }
                                  
                                  resubscribeRetryCount = 0;
                                  subscribeBlock();
                              }
                              else {
                                  
                                  retryUnsubscription(leaveError);
                              }
                          }];
                        };
                        
                        retryUnsubscription = ^(PNError *error) {
                            
                            resubscribeErrorBlock(error, unsubscribeBlock);
                        };
                        
                        unsubscribeBlock();
                    }
                    else {
                        
                        self.uniqueClientIdentifier = identifier;
                        self.userProvidedClientIdentifier = identifier != nil;
                        [self handleLockingOperationComplete:YES];
                    }
                }
                else {
                    
                    self.uniqueClientIdentifier = identifier;
                    self.userProvidedClientIdentifier = identifier != nil;
                    [self handleLockingOperationComplete:YES];
                }
            }
                   postponedExecutionBlock:^{
                       
                       [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                           
                           return @[PNLoggerSymbols.api.postponeClientIdentifierUpdate,
                                    [self humanReadableStateFrom:self.state]];
                       }];
                       
                       [self postponeSetClientIdentifier:identifier];
                   }];
        }
        else {
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.sameClientIdentifierProvided, [self humanReadableStateFrom:self.state]];
            }];
        }
    }];
}

- (void)postponeSetClientIdentifier:(NSString *)identifier {

    [self postponeSelector:@selector(setClientIdentifier:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:identifier]] outOfOrder:NO];
}


#pragma mark - Client connection management methods

- (BOOL)isConnected {
    
    return (self.state == PNPubNubClientStateConnected);
}

- (void)connect {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.connectionAttemptWithOutHandlerBlock, [self humanReadableStateFrom:self.state]];
        }];
        
        [self connectWithSuccessBlock:nil errorBlock:nil];
    }];
}

- (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                     errorBlock:(PNClientConnectionFailureBlock)failure {
    
    [self performAsyncLockingBlock:^{
        
        if (success || failure) {
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.connectionAttemptHandlerBlock, [self humanReadableStateFrom:self.state]];
            }];
        }

        __block BOOL shouldAddStateObservation = NO;

        // Stores whether flags for connection postpone due to network check / availability has been enabled
        // during connection process.
        __block BOOL postponeConnectionTillNetworkCheck = NO;
        self.updatingClientIdentifier = NO;

        dispatch_block_t completionBlock = ^{

            if (!self.shouldConnectOnServiceReachabilityCheck && !self.shouldConnectOnServiceReachability) {

                // Remove PubNub client from connection state observers list
                [self.observationCenter removeClientConnectionStateObserver:self oneTimeEvent:YES];
            }

            if (!postponeConnectionTillNetworkCheck) {

                self.connectOnServiceReachabilityCheck = NO;
                self.connectOnServiceReachability = NO;
            }


            if (shouldAddStateObservation) {

                // Subscribe and wait for client connection state change notification
                [self setClientConnectionObservationWithSuccessBlock:(success ? [success copy] : nil)
                                                        failureBlock:(failure ? [failure copy] : nil)];
            }
        };

        // Check whether instance already connected or not
        if (self.state == PNPubNubClientStateConnected ||
            self.state == PNPubNubClientStateConnecting) {

            NSString *symbolCode = PNLoggerSymbols.api.alreadyConnected;
            if (self.state == PNPubNubClientStateConnecting) {

                symbolCode = PNLoggerSymbols.api.alreadyConnecting;
            }

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[symbolCode, [self humanReadableStateFrom:self.state]];
            }];


            PNError *connectionError = [PNError errorWithCode:kPNClientTriedConnectWhileConnectedError];
            [self notifyDelegateClientConnectionFailedWithError:connectionError];

            if (failure) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    failure(connectionError);
                });
            }

            // In case if developer tried to initiate connection when client already was connected, procedural lock
            // should be released
            if (self.state == PNPubNubClientStateConnected) {

                [self handleLockingOperationComplete:YES];
            }
            completionBlock();
        }
        else {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.prepareCommunicationComponents, [self humanReadableStateFrom:self.state]];
            }];

            // Check whether client configuration was provided or not
            if (self.clientConfiguration == nil) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.connectionImpossibleWithOutConfiguration,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *connectionError = [PNError errorWithCode:kPNClientConfigurationError];
                [self notifyDelegateAboutError:connectionError];


                if (failure) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        failure(connectionError);
                    });
                }

                [self handleLockingOperationComplete:YES];
                completionBlock();
            }
            else {

                [self checkResuming:^(BOOL resuming) {

                    // Check whether user has been faster to call connect than library was able to resume connection
                    if (self.state == PNPubNubClientStateSuspended || resuming) {

                        NSString *symbolCode = PNLoggerSymbols.api.connectionAttemptDuringSuspension;
                        if (resuming) {

                            symbolCode = PNLoggerSymbols.api.connectionAttemptDuringResume;
                        }

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                            return @[symbolCode, [self humanReadableStateFrom:self.state]];
                        }];

                        // Because all connection channels will be destroyed, it means that client currently disconnected
                        self.state = PNPubNubClientStateDisconnected;


                        // Disconnecting communication channels and preserve all issued requests which wasn't sent till
                        // this moment (they will be send as soon as connection will be restored)
                        [_sharedInstance.messagingChannel disconnectWithEvent:NO];
                        [_sharedInstance.serviceChannel disconnectWithEvent:NO];
                    }

                    // Check whether user identifier was provided by user or not
                    if (self.uniqueClientIdentifier == nil) {

                        // Change user identifier before connect to the PubNub services
                        self.uniqueClientIdentifier = [PNHelper UUID];
                    }

                    // Check whether services are available or not
                    [self.reachability checkServiceReachabilityChecked:^(BOOL checked) {

                        [self pn_dispatchBlock:^{

                            if (checked) {

                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                    return @[PNLoggerSymbols.api.reachabilityChecked, [self humanReadableStateFrom:self.state]];
                                }];

                                // Forcibly refresh reachability information
                                [self.reachability refreshReachabilityState:^(BOOL willGenerateReachabilityChangeEvent) {

                                    // Checking whether remote PubNub services is reachable or not (if they are not reachable,
                                    // this mean that probably there is no connection)
                                    [self.reachability checkServiceAvailable:^(BOOL available) {

                                        [self pn_dispatchBlock:^{

                                            if (available) {

                                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                                    return @[PNLoggerSymbols.api.internetConnectionAvailable,
                                                            [self humanReadableStateFrom:self.state]];
                                                }];

                                                // Notify PubNub delegate about that it will try to establish connection with remote PubNub
                                                // origin (notify if delegate implements this method)
                                                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:willConnectToOrigin:)]) {

                                                    dispatch_async(dispatch_get_main_queue(), ^{

                                                        [self.clientDelegate performSelector:@selector(pubnubClient:willConnectToOrigin:)
                                                                                  withObject:self withObject:self.clientConfiguration.origin];
                                                    });
                                                }

                                                [self sendNotification:kPNClientWillConnectToOriginNotification withObject:self.clientConfiguration.origin];

                                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                                    return @[PNLoggerSymbols.api.willConnect,
                                                            (self.clientConfiguration.origin ? self.clientConfiguration.origin : [NSNull null]),
                                                            [self humanReadableStateFrom:self.state]];
                                                }];

                                                BOOL channelsDestroyed = (self.messagingChannel == nil && self.serviceChannel == nil);
                                                BOOL channelsShouldBeCreated = (self.state == PNPubNubClientStateCreated ||
                                                        self.state == PNPubNubClientStateDisconnected ||
                                                        self.state == PNPubNubClientStateReset);

                                                // Check whether PubNub client was just created and there is no resources for reuse or not
                                                if (channelsShouldBeCreated || channelsDestroyed) {

                                                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                                        return @[PNLoggerSymbols.api.createNewCommunicationComponents,
                                                                [self humanReadableStateFrom:self.state]];
                                                    }];

                                                    if (!channelsShouldBeCreated && channelsDestroyed) {

                                                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                                            return @[PNLoggerSymbols.api.previousCommunicationComponentsHasBeenDestroyed,
                                                                    [self humanReadableStateFrom:self.state]];
                                                        }];
                                                    }

                                                    self.state = PNPubNubClientStateConnecting;

                                                    // Initialize communication channels
                                                    self.messagingChannel = [PNMessagingChannel messageChannelWithConfiguration:self.clientConfiguration
                                                                                                                    andDelegate:self];
                                                    self.messagingChannel.messagingDelegate = self;
                                                    self.serviceChannel = [PNServiceChannel serviceChannelWithConfiguration:self.clientConfiguration
                                                                                                                andDelegate:self];
                                                    self.serviceChannel.serviceDelegate = self;

                                                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                                        return @[PNLoggerSymbols.api.resourceLinkage, (self.observationCenter ? [NSString stringWithFormat:@"%p", self.observationCenter] : [NSNull null]),
                                                                (self.reachability ? [NSString stringWithFormat:@"%p", self.reachability] : [NSNull null]),
                                                                (self.cryptoHelper ? [NSString stringWithFormat:@"%p", self.cryptoHelper] : [NSNull null]),
                                                                (self.messagingChannel ? [NSString stringWithFormat:@"%p", self.messagingChannel] : [NSNull null]),
                                                                (self.serviceChannel ? [NSString stringWithFormat:@"%p", self.serviceChannel] : [NSNull null])];
                                                    }];
                                                }
                                                else {

                                                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                                        return @[PNLoggerSymbols.api.reuseExistingCommunicationComponents,
                                                                [self humanReadableStateFrom:self.state]];
                                                    }];

                                                    self.state = PNPubNubClientStateConnecting;

                                                    // Reuse existing communication channels and reconnect them to remote origin server
                                                    [self.messagingChannel connect];
                                                    [self.serviceChannel connect];
                                                }

                                                shouldAddStateObservation = YES;
                                                completionBlock();
                                            }
                                            else {

                                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                                    return @[PNLoggerSymbols.api.internetConnectionNotAvailableAtThisMoment,
                                                            [self humanReadableStateFrom:self.state]];
                                                }];

                                                // Mark that client should try to connect when network will be available again
                                                self.connectOnServiceReachabilityCheck = NO;
                                                self.asyncLockingOperationInProgress = YES;
                                                self.connectOnServiceReachability = YES;

                                                postponeConnectionTillNetworkCheck = YES;

                                                [self handleConnectionErrorOnNetworkFailureWithError:nil];
                                                self.asyncLockingOperationInProgress = NO;

                                                [self.observationCenter checkSubscribedOnClientStateChange:self
                                                                                                 withBlock:^(BOOL observing) {

                                                     if (!observing) {

                                                         if (failure) {

                                                             dispatch_async(dispatch_get_main_queue(), ^{

                                                                 failure(nil);
                                                             });
                                                         }

                                                         shouldAddStateObservation = YES;
                                                     }

                                                     // Returning execution flow back on private queue
                                                     [self pn_dispatchBlock:^{

                                                         completionBlock();
                                                     }];
                                                 }];
                                            }
                                        }];
                                    }];
                                }];
                            }
                            // Looks like reachability manager was unable to check services reachability (user still not
                            // configured client or just not enough time to check passed since client configuration)
                            else {

                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                    return @[PNLoggerSymbols.api.internetConnectionAvailabilityNotCheckedYet,
                                            [self humanReadableStateFrom:self.state]];
                                }];

                                self.asyncLockingOperationInProgress = YES;
                                self.connectOnServiceReachabilityCheck = YES;
                                self.connectOnServiceReachability = NO;

                                postponeConnectionTillNetworkCheck = YES;
                                shouldAddStateObservation = YES;
                                completionBlock();
                            }
                        }];
                    }];
                }];
            }
        }
    }
           postponedExecutionBlock:^{
               
               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                   
                   return @[PNLoggerSymbols.api.postponeConnection, [self humanReadableStateFrom:self.state]];
               }];
               
               [self postponeConnectWithSuccessBlock:success errorBlock:failure];
           }];
}

- (void)postponeConnectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                             errorBlock:(PNClientConnectionFailureBlock)failure {

    [self pn_dispatchBlock:^{

        [self postponeSelector:@selector(connectWithSuccessBlock:errorBlock:) forObject:self
                withParameters:@[[PNHelper nilifyIfNotSet:success], [PNHelper nilifyIfNotSet:failure]]
                    outOfOrder:self.isRestoringConnection];
    }];
}

- (void)disconnect {

    [self pn_dispatchBlock:^{

        [self disconnectByUser:YES];
    }];
}

- (void)disconnectByUser:(BOOL)isDisconnectedByUser {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[(isDisconnectedByUser ? PNLoggerSymbols.api.disconnectionAttemptByUserRequest :
                  PNLoggerSymbols.api.disconnectionAttemptByInternalRequest),
                 [self humanReadableStateFrom:self.state]];
    }];
    
    [self performAsyncLockingBlock:^{

        [self stopHeartbeatTimer];

        [self.reachability checkSuspended:^(BOOL suspended) {

            if (suspended) {

                [self.reachability resume];
            }
        }];

        if (isDisconnectedByUser) {

            self.state = PNPubNubClientStateConnected;
        }

        BOOL isDisconnectForConfigurationChange = (self.state == PNPubNubClientStateDisconnectingOnConfigurationChange);

        // Remove PubNub client from list which help to observe various events
        [self.observationCenter removeClientConnectionStateObserver:self oneTimeEvent:YES];
        if (!isDisconnectForConfigurationChange) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.disconnecting, [self humanReadableStateFrom:self.state]];
            }];

            [self.cache purgeAllState];

            [self.observationCenter removeClientAsPushNotificationsEnabledChannelsObserver];
            [self.observationCenter removeClientAsParticipantChannelsListDownloadObserver];
            [self.observationCenter removeClientAsChannelGroupNamespaceRemovalObserver];
            [self.observationCenter removeClientAsPushNotificationsDisableObserver];
            [self.observationCenter removeClientAsParticipantsListDownloadObserver];
            [self.observationCenter removeClientAsChannelsRemovalFromGroupObserver];
            [self.observationCenter removeClientAsPushNotificationsRemoveObserver];
            [self.observationCenter removeClientAsPushNotificationsEnableObserver];
            [self.observationCenter removeClientAsChannelsAdditionToGroupObserver];
            [self.observationCenter removeClientAsChannelsForGroupRequestObserver];
            [self.observationCenter removeClientAsChannelGroupsRequestObserver];
            [self.observationCenter removeClientAsChannelGroupRemovalObserver];
            [self.observationCenter removeClientAsTimeTokenReceivingObserver];
            [self.observationCenter removeClientAsAccessRightsChangeObserver];
            [self.observationCenter removeClientAsAccessRightsAuditObserver];
            [self.observationCenter removeClientAsMessageProcessingObserver];
            [self.observationCenter removeClientAsHistoryDownloadObserver];
            [self.observationCenter removeClientAsStateRequestObserver];
            [self.observationCenter removeClientAsSubscriptionObserver];
            [self.observationCenter removeClientAsStateUpdateObserver];
            [self.observationCenter removeClientAsUnsubscribeObserver];
            [self.observationCenter removeClientAsPresenceDisabling];
            [self.observationCenter removeClientAsPresenceEnabling];
        }
        else {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.disconnectingForConfigurationChange,
                        [self humanReadableStateFrom:self.state]];
            }];
        }

        [self.clientConfiguration shouldKillDNSCache:NO];


        // Check whether application has been suspended or not
        [self checkResuming:^(BOOL resuming) {

            if (self.state == PNPubNubClientStateSuspended || resuming) {

                self.state = PNPubNubClientStateConnected;
            }


            // Check whether should update state to 'disconnecting'
            if ([self isConnected]) {

                // Mark that client is disconnecting from remote PubNub services on user request
                // (or by internal client request when updating configuration)
                self.state = PNPubNubClientStateDisconnecting;
            }

            // Reset client runtime flags and properties
            self.connectOnServiceReachabilityCheck = NO;
            self.connectOnServiceReachability = NO;
            self.updatingClientIdentifier = NO;
            self.restoringConnection = NO;


            void(^connectionsTerminationBlock)(BOOL) = ^(BOOL allowGenerateEvents) {

                if (allowGenerateEvents) {

                    [_sharedInstance.messagingChannel terminate];
                    [_sharedInstance.serviceChannel terminate];
                }
                else {

                    [_sharedInstance.messagingChannel disconnectWithEvent:NO];
                    [_sharedInstance.serviceChannel disconnectWithEvent:NO];
                }
                _sharedInstance.messagingChannel = nil;
                _sharedInstance.serviceChannel = nil;
            };

            if (isDisconnectedByUser) {

                connectionsTerminationBlock(NO);

                if (self.state != PNPubNubClientStateDisconnected) {

                    // Mark that client completely disconnected from origin server (synchronous disconnection was made to
                    // prevent asynchronous disconnect event from overlapping on connection event)
                    self.state = PNPubNubClientStateDisconnected;
                }

                // Clean up cached data
                [PNChannel purgeChannelsCache];

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.disconnectedByUserRequest, [self humanReadableStateFrom:self.state]];
                }];

                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate pubnubClient:self didDisconnectFromOrigin:self.clientConfiguration.origin];
                    });
                }

                [self sendNotification:kPNClientDidDisconnectFromOriginNotification withObject:self.clientConfiguration.origin];

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.disconnected, (self.clientConfiguration.origin ? self.clientConfiguration.origin : [NSNull null]),
                            [self humanReadableStateFrom:self.state]];
                }];

                [self flushPostponedMethods:YES];
                [self handleLockingOperationComplete:YES];
            }
            else {

                // Empty connection pool after connection will be closed
                [self.messagingChannel terminateConnection];
                [self.serviceChannel terminateConnection];
                [[self subscribedObjectsList] makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];

                connectionsTerminationBlock(YES);

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.disconnected, (self.clientConfiguration.origin ? self.clientConfiguration.origin : [NSNull null]),
                            [self humanReadableStateFrom:self.state]];
                }];
            }


            if (isDisconnectForConfigurationChange) {

                __block __pn_desired_weak __typeof(self) weakSelf = self;

                // Delay connection restore to give some time internal components to complete their tasks
                int64_t delayInSeconds = 1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, [self pn_privateQueue], ^(void) {
                    
                    __strong __typeof__(self) strongSelf = weakSelf;

                    strongSelf.asyncLockingOperationInProgress = NO;

                    strongSelf.state = PNPubNubClientStateCreated;
                    [strongSelf.clientConfiguration migrateConfigurationFrom:strongSelf.temporaryConfiguration];
                    strongSelf.temporaryConfiguration = nil;

                    [strongSelf showConfigurationInfo];
                    [strongSelf prepareCryptoHelper];

                    strongSelf.reachability.serviceOrigin = strongSelf.configuration.origin;

                    // Refresh reachability configuration
                    [strongSelf.reachability startServiceReachabilityMonitoring];


                    // Restore connection which will use new configuration
                    [strongSelf connect];
                });
            }
        }];
    }
           postponedExecutionBlock:^{
               
               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                   
                   return @[PNLoggerSymbols.api.postponeDisconnected, [self humanReadableStateFrom:self.state]];
               }];
               
               [self postponeDisconnectByUser:isDisconnectedByUser];
           }];
}

- (void)postponeDisconnectByUser:(BOOL)isDisconnectedByUser {

    [self pn_dispatchBlock:^{

        [self postponeSelector:@selector(disconnectByUser:) forObject:self
                withParameters:@[@(isDisconnectedByUser)]
                    outOfOrder:(self.state == PNPubNubClientStateDisconnectingOnConfigurationChange)];
    }];
}

- (void)disconnectForConfigurationChange {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.disconnectionAttemptForConfigurationChange,
                 [self humanReadableStateFrom:self.state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.disconnectingForConfigurationChange,
                    [self humanReadableStateFrom:self.state]];
        }];

        [self stopHeartbeatTimer];

        // Mark that client is closing connection because of settings update
        self.state = PNPubNubClientStateDisconnectingOnConfigurationChange;

        [self.messagingChannel disconnectWithEvent:NO];
        [self.serviceChannel disconnectWithEvent:NO];

        // Empty connection pool after connection will be closed
        [self.messagingChannel terminateConnection];
        [self.serviceChannel terminateConnection];

        // Sumulate disconnection, because streams not capable for it at this moment
        [self connectionChannel:nil didDisconnectFromOrigin:self.clientConfiguration.origin];
    }
           postponedExecutionBlock:^{
               
               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                   
                   return @[PNLoggerSymbols.api.postponeDisconnectionForConfigurationChange,
                            [self humanReadableStateFrom:self.state]];
               }];
               
               [self postponeDisconnectForConfigurationChange];
           }];
}

- (void)postponeDisconnectForConfigurationChange {
    
    [self postponeSelector:@selector(disconnectForConfigurationChange) forObject:self
            withParameters:nil outOfOrder:NO];
}

- (void)setClientConnectionObservationWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                                          failureBlock:(PNClientConnectionFailureBlock)failure {

    // Check whether at least one of blocks has been provided and whether
    // PubNub client already subscribed on state change event or not
    [self.observationCenter checkSubscribedOnClientStateChange:self withBlock:^(BOOL observing) {

        // Returning execution flow back on private queue
        [self pn_dispatchBlock:^{

            if (!observing && (success || failure)) {

                // Subscribing PubNub client for connection state observation
                // (as soon as event will occur PubNub client will be removed
                // from observers list)
                __pn_desired_weak __typeof__(self) weakSelf = self;
                [self.observationCenter addClientConnectionStateObserver:self oneTimeEvent:YES
                                                       withCallbackBlock:^(NSString *origin, BOOL connected,
                                                                           PNError *connectionError) {
                                                           
                    __strong __typeof__(self) strongSelf = weakSelf;

                    // Notify subscriber via blocks
                    if (connected && success) {

                        dispatch_async(dispatch_get_main_queue(), ^{

                            success(origin);
                        });
                    }
                    else if (!connected && failure) {

                        dispatch_async(dispatch_get_main_queue(), ^{

                            failure(connectionError);
                        });
                    }

                    // Returning execution flow back on private queue
                    [strongSelf pn_dispatchBlock:^{

                        if (strongSelf.shouldConnectOnServiceReachability) {

                            [strongSelf setClientConnectionObservationWithSuccessBlock:success
                                                                          failureBlock:failure];
                        }
                    }];
                }];
            }
        }];
    }];
}

- (void)warmUpConnections {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];
    
    [self warmUpConnection:self.messagingChannel];
    [self warmUpConnection:self.serviceChannel];
}

- (void)warmUpConnection:(PNConnectionChannel *)connectionChannel {
    
    PNTimeTokenRequest *request = [PNTimeTokenRequest new];
    request.sendingByUserRequest = NO;
    
    [self sendRequest:request onChannel:connectionChannel shouldObserveProcessing:NO];
}

- (NSString *)clientIdentifier {
    
    self.userProvidedClientIdentifier = (self.uniqueClientIdentifier != nil);
    
    
    return self.uniqueClientIdentifier;
}


#pragma mark - Requests management methods

- (void)sendRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing {
    
    BOOL shouldSendOnMessageChannel = YES;
    
    
    // Checking whether request should be sent on service
    // connection channel or not
    if ([request isKindOfClass:[PNLeaveRequest class]] ||
        [request isKindOfClass:[PNTimeTokenRequest class]] ||
        [request isKindOfClass:[PNClientStateRequest class]] ||
        [request isKindOfClass:[PNClientStateUpdateRequest class]] ||
        [request isKindOfClass:[PNChannelGroupsRequest class]] ||
        [request isKindOfClass:[PNChannelGroupNamespacesRequest class]] ||
        [request isKindOfClass:[PNChannelGroupNamespaceRemoveRequest class]] ||
        [request isKindOfClass:[PNChannelGroupRemoveRequest class]] ||
        [request isKindOfClass:[PNChannelsForGroupRequest class]] ||
        [request isKindOfClass:[PNChannelsListUpdateForChannelGroupRequest class]] ||
        [request isKindOfClass:[PNMessageHistoryRequest class]] ||
        [request isKindOfClass:[PNHereNowRequest class]] ||
        [request isKindOfClass:[PNWhereNowRequest class]] ||
        [request isKindOfClass:[PNLatencyMeasureRequest class]] ||
        [request isKindOfClass:[PNPushNotificationsStateChangeRequest class]] ||
        [request isKindOfClass:[PNPushNotificationsEnabledChannelsRequest class]] ||
        [request isKindOfClass:[PNPushNotificationsRemoveRequest class]] ||
        [request isKindOfClass:[PNHeartbeatRequest class]]) {
        
        shouldSendOnMessageChannel = NO;
    }
    
    [self pn_dispatchBlock:^{

        [self     sendRequest:request onChannel:(shouldSendOnMessageChannel ? self.messagingChannel : self.serviceChannel)
      shouldObserveProcessing:shouldObserveProcessing];
    }];
}

- (void)      sendRequest:(PNBaseRequest *)request onChannel:(PNConnectionChannel *)channel
  shouldObserveProcessing:(BOOL)shouldObserveProcessing {
    
    [channel scheduleRequest:request shouldObserveProcessing:shouldObserveProcessing];
}


#pragma mark - Connection channel delegate methods

- (void)connectionChannelConfigurationDidFail:(PNConnectionChannel *)channel {

    [self pn_dispatchBlock:^{

        [self disconnectByUser:NO];
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel didConnectToHost:(NSString *)host {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

        return @[PNLoggerSymbols.api.connectionChannelConnected, (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]), [self humanReadableStateFrom:self.state]];
    }];

    [self checkConnectionChannelsConnectionState:^(BOOL messageChannelConnected, BOOL serviceChannelConnected) {

        [self pn_dispatchBlock:^{

            BOOL isChannelsConnected = (messageChannelConnected && serviceChannelConnected);
            BOOL isCorrectRemoteHost = [self.clientConfiguration.origin isEqualToString:host];

            // Check whether all communication channels connected and whether client in corresponding state or not
            if (isChannelsConnected && isCorrectRemoteHost && self.state == PNPubNubClientStateConnecting) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.allConnectionChannelsConnected, (host ? host : [NSNull null]),
                            [self humanReadableStateFrom:self.state]];
                }];

                self.connectOnServiceReachabilityCheck = NO;
                self.connectOnServiceReachability = NO;

                // Mark that PubNub client established connection to PubNub
                // services
                self.state = PNPubNubClientStateConnected;


                [self warmUpConnections];

                [self notifyDelegateAboutConnectionToOrigin:host];
                self.restoringConnection = NO;

                [self handleLockingOperationComplete:YES];
            }
        }];
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel didReconnectToHost:(NSString *)host {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

        return @[PNLoggerSymbols.api.connectionChannelReconnected,
                (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                [self humanReadableStateFrom:self.state]];
    }];

    [self pn_dispatchBlock:^{

        // Check whether received event from same host on which client is configured or not and
        // client connected at this moment
        if ([self.clientConfiguration.origin isEqualToString:host]) {

            if (self.state == PNPubNubClientStateConnecting) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.anotherConnectionChannelNotReconnectedYet,
                            (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                            (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                            [self humanReadableStateFrom:self.state]];
                }];

                [self connectionChannel:channel didConnectToHost:host];
            }
            else if (self.state == PNPubNubClientStateConnected) {

                [self warmUpConnection:channel];
            }
        }
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel connectionDidFailToOrigin:(NSString *)host
                withError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

        return @[PNLoggerSymbols.api.connectionChannelConnectionFailed,
                (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                [self humanReadableStateFrom:self.state]];
    }];

    // Check whether client in corresponding state and all communication channels not connected to the server
    [self checkConnectionChannelsConnectionState:^(BOOL messageChannelConnected, BOOL serviceChannelConnected) {

        [self pn_dispatchBlock:^{

            if (self.state == PNPubNubClientStateConnecting &&
                    [self.clientConfiguration.origin isEqualToString:host] &&
                    !messageChannelConnected && !serviceChannelConnected) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.connectionFailed, (host ? host : [NSNull null]),
                            [self humanReadableStateFrom:self.state]];
                }];

                self.state = PNPubNubClientStateDisconnectedOnNetworkError;
                self.connectOnServiceReachabilityCheck = NO;
                self.connectOnServiceReachability = NO;

                [self.messagingChannel disconnectWithEvent:NO];
                [self.serviceChannel disconnectWithEvent:NO];

                if (![self.clientConfiguration shouldKillDNSCache]) {

                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                        return @[PNLoggerSymbols.api.DNSCacheKillAttempt, (host ? host : [NSNull null]),
                                [self humanReadableStateFrom:self.state]];
                    }];
                    self.asyncLockingOperationInProgress = NO;

                    [self.clientConfiguration shouldKillDNSCache:YES];
                    [self.messagingChannel disconnectWithEvent:NO];
                    [self.serviceChannel disconnectWithEvent:NO];

                    [self connect];
                }
                else {

                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                        return @[PNLoggerSymbols.api.notifyDelegateConnectionCantBeEstablished, (host ? host : [NSNull null]),
                                [self humanReadableStateFrom:self.state]];
                    }];

                    [self.clientConfiguration shouldKillDNSCache:NO];

                    // Send notification to all who is interested in it (observation center will track it as well)
                    [self notifyDelegateClientConnectionFailedWithError:error];
                }
            }
        }];
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel didDisconnectFromOrigin:(NSString *)host {

    [self pn_dispatchBlock:^{

        NSString *connectedToHost = host;

        // Check whether notification arrived from channels on which PubNub library is looking at this moment
        BOOL shouldHandleChannelEvent = ([channel isEqual:self.messagingChannel] ||
                                         [channel isEqual:self.serviceChannel] ||
                                         self.state == PNPubNubClientStateDisconnectingOnConfigurationChange);

        [self stopHeartbeatTimer];

        if (shouldHandleChannelEvent) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.connectionChannelDisconnected,
                        (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                        (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                        [self humanReadableStateFrom:self.state]];
            }];
        }
        else {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.connectionChannelDisconnectedOnReleaseWithOutEvent,
                        (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                        (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                        [self humanReadableStateFrom:self.state]];
            }];
        }

        // Check whether host name arrived or not (it may not arrive if event sending instance was dismissed/deallocated)
        if (connectedToHost == nil) {

            connectedToHost = self.clientConfiguration.origin;
        }

        __block BOOL isForceClosingSecondChannel = NO;
        dispatch_block_t completionBlock = ^{

            // Check whether received event from same host on which client is configured or not and
            // all communication channels are closed
            [self checkConnectionChannelsDisconnectionState:^(BOOL messageChannelDisconnected, BOOL serviceChannelDisconnected) {

                [self pn_dispatchBlock:^{

                    if (shouldHandleChannelEvent && !isForceClosingSecondChannel &&
                        [self.clientConfiguration.origin isEqualToString:connectedToHost] &&
                        messageChannelDisconnected && serviceChannelDisconnected &&
                        self.state != PNPubNubClientStateDisconnected &&
                        self.state != PNPubNubClientStateDisconnectedOnNetworkError) {

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                            return @[PNLoggerSymbols.api.allConnectionChannelsDisconnected,
                                    (connectedToHost ? connectedToHost : [NSNull null]),
                                    [self humanReadableStateFrom:self.state]];
                        }];

                        // Check whether all communication channels disconnected and whether client in corresponding state or not
                        if (self.state == PNPubNubClientStateDisconnecting ||
                            self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
                            (channel == nil && self.state != PNPubNubClientStateDisconnectingOnConfigurationChange)) {

                            PNError *connectionError;
                            PNPubNubClientState state = PNPubNubClientStateDisconnected;
                            if (self.state == PNPubNubClientStateDisconnectingOnNetworkError) {

                                state = PNPubNubClientStateDisconnectedOnNetworkError;
                                connectionError = [PNError errorWithCode:kPNClientConnectionClosedOnInternetFailureError];
                            }
                            self.state = state;

                            __block BOOL reachabilityWillSimulateAction = NO;
                            dispatch_block_t disconnectionProceedBlock = ^{

                                // Check whether client still in bad state or not (because of async operations it is possible that before
                                // this moment client was in corresponding state
                                if (self.state != PNPubNubClientStateConnecting) {

                                    if (state == PNPubNubClientStateDisconnected) {

                                        // Clean up cached data
                                        [PNChannel purgeChannelsCache];

                                        // Delay disconnection notification to give client ability to perform clean up well
                                        __block __pn_desired_weak __typeof__(self) weakSelf = self;
                                        void(^disconnectionNotifyBlock)(void) = ^{
                                            
                                            __strong __typeof__(self) strongSelf = weakSelf;

                                            strongSelf.messagingChannel.delegate = nil;
                                            strongSelf.messagingChannel = nil;
                                            strongSelf.serviceChannel.delegate = nil;
                                            strongSelf.serviceChannel = nil;

                                            if ([strongSelf.clientDelegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {

                                                dispatch_async(dispatch_get_main_queue(), ^{

                                                    [strongSelf.clientDelegate pubnubClient:strongSelf didDisconnectFromOrigin:connectedToHost];
                                                });
                                            }
                                            [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray * {

                                                return @[PNLoggerSymbols.api.disconnected, (connectedToHost ? connectedToHost : [NSNull null]),
                                                        [self humanReadableStateFrom:self.state]];
                                            }];


                                            [strongSelf sendNotification:kPNClientDidDisconnectFromOriginNotification withObject:connectedToHost];
                                            [self handleLockingOperationComplete:YES];
                                        };
                                        if (channel == nil) {

                                            disconnectionNotifyBlock();
                                        }
                                        else {

                                            double delayInSeconds = 1.0;
                                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
                                            dispatch_after(popTime, [self pn_privateQueue], disconnectionNotifyBlock);
                                        }
                                    }
                                    else {

                                        __block __pn_desired_weak __typeof__(self) weakSelf = self;
                                        void(^disconnectionNotifyBlock)(void) = ^{
                                            
                                            __strong __typeof__(self) strongSelf = weakSelf;

                                            if (state == PNPubNubClientStateDisconnectedOnNetworkError) {

                                                [strongSelf handleLockingOperationBlockCompletion:^{

                                                            if ([strongSelf.clientDelegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:withError:)]) {

                                                                dispatch_async(dispatch_get_main_queue(), ^{

                                                                    [strongSelf.clientDelegate pubnubClient:strongSelf didDisconnectFromOrigin:connectedToHost withError:connectionError];
                                                                });
                                                            }
                                                            [PNLogger logGeneralMessageFrom:strongSelf withParametersFromBlock:^NSArray * {

                                                                return @[PNLoggerSymbols.api.disconnectedBecauseOfError,
                                                                        (connectionError ? connectionError : [NSNull null]),
                                                                        [self humanReadableStateFrom:self.state]];
                                                            }];

                                                            connectionError.associatedObject = strongSelf.clientConfiguration.origin;
                                                            [strongSelf sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:connectionError];
                                                        }
                                                                                shouldStartNext:YES];
                                            }
                                        };

                                        // Check whether service is available (this event may arrive after device was unlocked so basically
                                        // connection is available and only sockets closed by remote server or internal kernel layer)
                                        [self.reachability checkServiceReachabilityChecked:^(BOOL checked) {

                                            if (checked) {

                                                [self.reachability checkServiceAvailable:^(BOOL available) {
                                                    
                                                    [self pn_dispatchBlock:^{
                                                        
                                                        if (available) {
                                                            
                                                            // Check whether should restore connection or not
                                                            if ([self shouldRestoreConnection]) {
                                                                
                                                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                                                                    
                                                                    return @[PNLoggerSymbols.api.connectionShouldBeRestoredOnReacabilityCheck,
                                                                             [self humanReadableStateFrom:self.state]];
                                                                }];
                                                                
                                                                self.asyncLockingOperationInProgress = NO;
                                                                self.restoringConnection = YES;
                                                                
                                                                // Try to restore connection to remote PubNub services
                                                                [self connect];
                                                            }
                                                            else {
                                                                
                                                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                                                                    
                                                                    return @[PNLoggerSymbols.api.destroyCommunicationComponents,
                                                                             [self humanReadableStateFrom:self.state]];
                                                                }];
                                                                
                                                                disconnectionNotifyBlock();
                                                            }
                                                        }
                                                        // In case if there is no connection check whether clint should restore connection or not.
                                                        else if (![self shouldRestoreConnection]) {
                                                            
                                                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                                                                
                                                                return @[PNLoggerSymbols.api.destroyCommunicationComponents,
                                                                         [self humanReadableStateFrom:self.state]];
                                                            }];
                                                            
                                                            self.state = PNPubNubClientStateDisconnected;
                                                            disconnectionNotifyBlock();
                                                        }
                                                        else if ([self shouldRestoreConnection]) {
                                                            
                                                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                                                                
                                                                return @[PNLoggerSymbols.api.connectionWillBeRestoredOnNetworkConnectionRestore,
                                                                         [self humanReadableStateFrom:self.state]];
                                                            }];
                                                            
                                                            if (!reachabilityWillSimulateAction) {
                                                                
                                                                [self notifyDelegateClientDidDisconnectWithError:connectionError];
                                                            }
                                                        }
                                                    }];
                                                }];
                                            }
                                        }];
                                    }
                                }
                                else {

                                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                        return @[PNLoggerSymbols.api.alreadyRestoringConnection, [self humanReadableStateFrom:self.state]];
                                    }];
                                }
                            };

                            // Check whether error is caused by network error or not
                            switch (connectionError.code) {
                                case kPNClientConnectionFailedOnInternetFailureError:
                                case kPNClientConnectionClosedOnInternetFailureError:
                                    {
                                        // Check whether should restore connection or not
                                        if ([self shouldRestoreConnection] && state == PNPubNubClientStateDisconnectedOnNetworkError) {
                                            
                                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                                                
                                                return @[PNLoggerSymbols.api.connectionShouldBeRestoredOnReacabilityCheck,
                                                         [self humanReadableStateFrom:self.state]];
                                            }];
                                            
                                            self.restoringConnection = YES;
                                        }
                                        
                                        // Try to refresh reachability state (there is situation when reachability state changed within
                                        // library to handle sockets timeout/error)
                                        [self.reachability refreshReachabilityState:^(BOOL willGenerateReachabilityChangeEvent) {
                                            
                                            reachabilityWillSimulateAction = willGenerateReachabilityChangeEvent;
                                            
                                            [self.reachability checkServiceAvailable:^(BOOL available) {
                                                
                                                [self pn_dispatchBlock:^{
                                                    
                                                    if (!available) {
                                                        
                                                        self.restoringConnection = NO;
                                                    }
                                                    disconnectionProceedBlock();
                                                }];
                                            }];
                                        }];
                                    }
                                    break;

                                default:
                                    {
                                        disconnectionProceedBlock();
                                    }
                                    break;
                            }
                        }
                        // Check whether server unexpectedly closed connection while client was active or not
                        else if (self.state == PNPubNubClientStateConnected) {

                            self.state = PNPubNubClientStateDisconnected;

                            if ([self shouldRestoreConnection]) {

                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                    return @[PNLoggerSymbols.api.shouldRestoreConnection, [self humanReadableStateFrom:self.state]];
                                }];

                                self.asyncLockingOperationInProgress = NO;
                                self.restoringConnection = YES;

                                // Try to restore connection to remote PubNub services
                                [self connect];
                            }
                        }
                            // Check whether connection has been closed because PubNub client updates it's configuration
                        else if (self.state == PNPubNubClientStateDisconnectingOnConfigurationChange) {

                            self.asyncLockingOperationInProgress = NO;

                            // Close connection to PubNub services
                            [self disconnectByUser:NO];
                        }
                    }
                }];
            }];
        };

        if (self.state != PNPubNubClientStateDisconnecting &&
            self.state != PNPubNubClientStateDisconnectingOnConfigurationChange &&
            shouldHandleChannelEvent) {

            self.state = PNPubNubClientStateDisconnectingOnNetworkError;
            if ([channel isEqual:self.messagingChannel]){

                if (self.serviceChannel) {

                    [self.serviceChannel checkConnected:^(BOOL connected) {

                        [self.serviceChannel checkDisconnected:^(BOOL disconnected) {

                            [self pn_dispatchBlock:^{

                                if (!disconnected || connected) {

                                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                        return @[PNLoggerSymbols.api.disconnectingServiceChannel,
                                                (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                                                (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                                                [self humanReadableStateFrom:self.state]];
                                    }];

                                    isForceClosingSecondChannel = YES;
                                    [self.serviceChannel disconnect];
                                }

                                completionBlock();
                            }];
                        }];
                    }];
                }
                else {

                    completionBlock();
                }
            }
            else if ([channel isEqual:self.serviceChannel]) {

                if (self.messagingChannel) {

                    [self.messagingChannel checkConnected:^(BOOL connected) {

                        [self.messagingChannel checkDisconnected:^(BOOL disconnected) {

                            [self pn_dispatchBlock:^{

                                if (!disconnected || connected) {

                                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                                        return @[PNLoggerSymbols.api.disconnectingMessagingChannel,
                                                (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                                                (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                                                [self humanReadableStateFrom:self.state]];
                                    }];

                                    isForceClosingSecondChannel = YES;
                                    [self.messagingChannel disconnectWithReset:NO];
                                }

                                completionBlock();
                            }];
                        }];
                    }];
                }
                else {

                    completionBlock();
                }
            }
            else {

                completionBlock();
            }
        }
        else {

            completionBlock();
        }
    }];
}

- (void) connectionChannel:(PNConnectionChannel *)channel willDisconnectFromOrigin:(NSString *)host
                 withError:(PNError *)error {

    [self pn_dispatchBlock:^{

        if (self.state == PNPubNubClientStateConnected && [self.clientConfiguration.origin isEqualToString:host]) {

            self.state = PNPubNubClientStateDisconnecting;
            __block BOOL disconnectedOnNetworkError = NO;
            dispatch_block_t completionBlock = ^{

                if (disconnectedOnNetworkError) {

                    self.state = PNPubNubClientStateDisconnectingOnNetworkError;
                }

                [self.reachability updateReachabilityFromError:error];
                [self notifyDelegateClientWillDisconnectWithError:error];
            };
            [self.reachability checkServiceAvailable:^(BOOL available) {

                disconnectedOnNetworkError = !available;
                if (!disconnectedOnNetworkError) {

                    disconnectedOnNetworkError = (error.code == kPNRequestExecutionFailedOnInternetFailureError ||
                                                  error.code == kPNClientConnectionClosedOnInternetFailureError);
                }

                if (!disconnectedOnNetworkError) {

                    [self checkConnectionChannelsConnectionState:^(BOOL messageChannelConnected, BOOL serviceChannelConnected) {

                        [self pn_dispatchBlock:^{

                            disconnectedOnNetworkError = (!messageChannelConnected || !serviceChannelConnected);
                            completionBlock();
                        }];
                    }];
                }
                else {

                    completionBlock();
                }
            }];
        }
    }];
}

- (void)connectionChannelWillReschedulePendingRequests:(PNConnectionChannel *)channel {
    
    [self pn_dispatchBlock:^{
        
        if ([channel isEqual:self.serviceChannel]) {
            
            self.methodCallRescheduleDate = nil;
        }
    }];
}

- (void)connectionChannelWillSuspend:(PNConnectionChannel *)channel {
    
    //
}

- (void)connectionChannelDidSuspend:(PNConnectionChannel *)channel {

    [self checkConnectionChannelsSuspendedState:^(BOOL messageChannelSuspended, BOOL serviceChannelSuspended) {

        [self pn_dispatchBlock:^{

            if (messageChannelSuspended && serviceChannelSuspended) {

                [self stopHeartbeatTimer];
            }
        }];
    }];
}

- (void)connectionChannelWillResume:(PNConnectionChannel *)channel {
    
    //
}

- (void)connectionChannelDidResume:(PNConnectionChannel *)channel requireWarmUp:(BOOL)isWarmingUpRequired {
    
    // Checking whether connection should be 'warmed up' to keep it open or not.
    if (isWarmingUpRequired) {
        
        [self warmUpConnection:channel];
    }

    [self pn_dispatchBlock:^{

        // Check whether on resume there is no async locking operation is running
        if (!self.asyncLockingOperationInProgress) {

            [self handleLockingOperationComplete:YES];
        }

        // Checking whether all communication channels connected or not
        [self checkConnectionChannelsConnectionState:^(BOOL messageChannelConnected, BOOL serviceChannelConnected) {

            [self pn_dispatchBlock:^{

                if (messageChannelConnected && serviceChannelConnected) {

                    [self notifyDelegateAboutConnectionToOrigin:self.clientConfiguration.origin];
                    [self launchHeartbeatTimer];
                }
            }];
        }];
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel checkCanConnect:(void(^)(BOOL))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        // Help reachability instance update it's state our of schedule
        [self.reachability refreshReachabilityState:^(BOOL willGenerateReachabilityChangeEvent) {

            [self.reachability checkServiceAvailable:checkCompletionBlock];
        }];
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel checkShouldRestoreConnection:(void(^)(BOOL))checkCompletionBlock {

    [self pn_dispatchBlock:^{
        
        // Help reachability instance update it's state our of schedule
        [self.reachability refreshReachabilityState:^(BOOL willGenerateReachabilityChangeEvent) {

            BOOL isSimulatingReachability = [self.reachability isSimulatingNetworkSwitchEvent];
            BOOL shouldRestoreConnection = (self.state == PNPubNubClientStateConnecting ||
                    self.state == PNPubNubClientStateConnected ||
                    self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
                    self.state == PNPubNubClientStateDisconnectedOnNetworkError);

            // Ensure that there is connection available as well as permission to connect
            shouldRestoreConnection = (shouldRestoreConnection && !isSimulatingReachability);
            [self.reachability checkServiceAvailable:^(BOOL available) {

                checkCompletionBlock(shouldRestoreConnection && available);
            }];
        }];
    }];
}

- (void)isPubNubServiceAvailable:(BOOL)shouldUpdateInformation checkCompletionBlock:(void(^)(BOOL))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        dispatch_block_t completionBlock = ^{

            [self.reachability checkServiceAvailable:^(BOOL available) {

                checkCompletionBlock(available);
            }];
        };
        if (shouldUpdateInformation) {

            // Help reachability instance update it's state our of schedule
            [self.reachability refreshReachabilityState:^(BOOL willGenerateReachabilityChangeEvent) {

                completionBlock();
            }];
        }
        else {

            completionBlock();
        }
    }];
}


#pragma mark - Handler methods

- (void)handleHeartbeatTimer {

    // Checking whether we are still connected and there is some channels for which we can create
    // this heartbeat request.
    [self checkResuming:^(BOOL resuming) {

        [self pn_dispatchBlock:^{

            if ([self isConnected] && !resuming && [[self subscribedObjectsList] count] &&
                self.clientConfiguration.presenceHeartbeatTimeout > 0.0f) {

                [self.cache clientState:^(NSDictionary *clientState) {

                    [self pn_dispatchBlock:^{

                        // Prepare and send request w/o observation (it mean that any response for request will be ignored
                        NSArray *channels = [self subscribedObjectsList];
                        [self sendRequest:[PNHeartbeatRequest heartbeatRequestForChannels:channels
                                                                          withClientState:clientState]
                  shouldObserveProcessing:NO];
                    }];
                }];
            }
        }];
    }];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)handleApplicationDidEnterBackgroundState:(NSNotification *)__unused notification {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.handleEnteredBackground, [self humanReadableStateFrom:self.state]];
    }];
    
	if (![self canRunInBackground]) {
        
        BOOL canInformAboutSuspension = [self.clientDelegate respondsToSelector:@selector(pubnubClient:willSuspendWithBlock:)];
        void(^suspensionCompletionBlock)(void) = ^{
            
            // Ensure that application is still in background execution context.
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                
                if (!canInformAboutSuspension) {

                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                        return @[PNLoggerSymbols.api.unableToRunInBackground, [self humanReadableStateFrom:self.state]];
                    }];
                }
                else {

                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                        return @[PNLoggerSymbols.api.completeTasksBeforeCompleteTransitionToBackground,
                                [self humanReadableStateFrom:self.state]];
                    }];
                }

                    
                [self.reachability suspend];

                // Check whether application connected or not
                if ([self isConnected]) {

                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                        return @[PNLoggerSymbols.api.suspendingOnTransitionToBackground,
                                 [self humanReadableStateFrom:self.state]];
                    }];

                    self.state = PNPubNubClientStateSuspended;

                    self.asyncLockingOperationInProgress = NO;
                    [self.messagingChannel suspend];
                    [self.serviceChannel suspend];
                }
                else if (self.state == PNPubNubClientStateConnecting ||
                         self.state == PNPubNubClientStateDisconnecting ||
                         self.state == PNPubNubClientStateDisconnectingOnNetworkError) {

                    if (self.state == PNPubNubClientStateConnecting) {

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.connectionAttemptWhileTransitToBackground,
                                     [self humanReadableStateFrom:self.state]];
                        }];

                        self.state = PNPubNubClientStateDisconnectedOnNetworkError;
                    }
                    else if (self.state == PNPubNubClientStateDisconnecting){

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.disconnectionAttemptWhileTransitToBackground,
                                     [self humanReadableStateFrom:self.state]];
                        }];

                        self.state = PNPubNubClientStateDisconnected;
                    }
                    else if (self.state == PNPubNubClientStateDisconnectingOnNetworkError){

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.disconnectionAttemptBecauseOfErrorWhileTransitToBackground,
                                     [self humanReadableStateFrom:self.state]];
                        }];

                        self.state = PNPubNubClientStateDisconnectedOnNetworkError;
                    }

                    [self.messagingChannel disconnectWithEvent:NO];
                    [self.serviceChannel disconnectWithEvent:NO];
                }
            }
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.api.notInBackground, [self humanReadableStateFrom:self.state]];
                }];
            }
        };
        
        if (!canInformAboutSuspension) {
            
            suspensionCompletionBlock();
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Informing delegate that PubNub client will suspend soon.
                [self.clientDelegate pubnubClient:self
                             willSuspendWithBlock:^(void(^actionsBlock)(void (^)())) {

                     if (actionsBlock) {

                         [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                             return @[PNLoggerSymbols.api.postponeSuspensionOnTransitionToBackground,
                                      [self humanReadableStateFrom:self.state]];
                         }];

                         // This variable is used to provide enough time to complete suspension process.
                         __block NSUInteger suspensionDelay = 3;
                         __block UIBackgroundTaskIdentifier identifier = UIBackgroundTaskInvalid;
                         __block BOOL shouldKeepAliveInBackground = YES;
                         __block BOOL isFirstWhileCycle = YES;
                         __block BOOL isSuspending = NO;

                         void(^backgroundTaskCompletionBlock)(void) = ^{

                             if (identifier != UIBackgroundTaskInvalid) {

                                 [[UIApplication sharedApplication] endBackgroundTask:identifier];
                             }
                             identifier = UIBackgroundTaskInvalid;
                         };

                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                             while (shouldKeepAliveInBackground || suspensionDelay > 0) {

                                 if (!shouldKeepAliveInBackground) {

                                     suspensionDelay--;
                                 }
                                 if ([UIApplication sharedApplication].backgroundTimeRemaining <= 15.0 && !isSuspending && !isFirstWhileCycle) {

                                     [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                                         return @[PNLoggerSymbols.api.userDidntCallSuspensionOperationCompletionBlock,
                                                  [self humanReadableStateFrom:self.state]];
                                     }];

                                     if (!isSuspending) {

                                         isSuspending = YES;
                                         dispatch_async([self pn_privateQueue], suspensionCompletionBlock);
                                     }
                                     shouldKeepAliveInBackground = NO;
                                 }
                                 isFirstWhileCycle = NO;
                                 [NSThread sleepForTimeInterval:1];
                             }

                             dispatch_async(dispatch_get_main_queue(), backgroundTaskCompletionBlock);
                         });

                         // Requesting additional time for execution in background
                         identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:backgroundTaskCompletionBlock];

                         actionsBlock(^{

                             if (!isSuspending) {

                                 isSuspending = YES;
                                 suspensionCompletionBlock();
                             }
                             shouldKeepAliveInBackground = NO;
                         });
                     }
                     else {

                         suspensionCompletionBlock();
                     }
                 }];
            });
        }
    }
}

- (void)handleApplicationDidEnterForegroundState:(NSNotification *)__unused notification  {

    [self pn_dispatchBlock:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.handleEnterForeground, [self humanReadableStateFrom:self.state]];
        }];
        
        // Try to refresh reachability state (there is situation when reachability state changed within
        // library to handle sockets timeout/error)
        [self.reachability refreshReachabilityState:^(BOOL reachabilityWillSimulateAction) {

            [self.reachability checkServiceAvailable:^(BOOL available) {

                [self pn_dispatchBlock:^{

                    if (available) {

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.internetConnectionAvailable, [self humanReadableStateFrom:self.state]];
                        }];

                        // Check whether application is suspended
                        if (self.state == PNPubNubClientStateSuspended) {

                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                                return @[PNLoggerSymbols.api.resumingConnection, [self humanReadableStateFrom:self.state]];
                            }];

                            self.state = PNPubNubClientStateConnected;

                            self.asyncLockingOperationInProgress = NO;
                            [self.messagingChannel resume];
                            [self.serviceChannel resume];
                        }
                        else if (self.state == PNPubNubClientStateDisconnectedOnNetworkError) {

                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                                return @[PNLoggerSymbols.api.previousConnectionWasTerminatedBecauseOfErrorOnTransitionToForeground,
                                        [self humanReadableStateFrom:self.state]];
                            }];

                            if ([self shouldRestoreConnection]) {

                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                                    return @[PNLoggerSymbols.api.shouldRestoreConnection, [self humanReadableStateFrom:self.state]];
                                }];


                                self.asyncLockingOperationInProgress = NO;
                                self.restoringConnection = YES;

                                // Try to restore connection to remote PubNub services
                                [self connect];
                            }
                        }
                    }
                    else {

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.networkConnectionWentDownWhileWasInBackgroundOnTransitionToForeground,
                                    [self humanReadableStateFrom:self.state]];
                        }];

                        if (self.state == PNPubNubClientStateDisconnectedOnNetworkError) {

                            if ([self shouldRestoreConnection]) {

                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                                    return @[PNLoggerSymbols.api.connectionWillRestoreOnNetworkAvailability,
                                            [self humanReadableStateFrom:self.state]];
                                }];

                                if (!reachabilityWillSimulateAction) {

                                    [self notifyDelegateClientDidDisconnectWithError:[PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]];
                                }
                            }
                        }
                    }
                }];
            }];
        }];
    }];
}
#else
- (void)handleWorkspaceWillSleep:(NSNotification *)notification {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.handleWorkspaceSleep, [self humanReadableStateFrom:self.state]];
    }];

    [self.reachability suspend];

    // Check whether application connected or not
    if ([self isConnected]) {

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.suspendingOnWorkspaceSleep, [self humanReadableStateFrom:self.state]];
        }];

        self.state = PNPubNubClientStateSuspended;

        self.asyncLockingOperationInProgress = NO;
        [self.messagingChannel suspend];
        [self.serviceChannel suspend];
    }
    else if (self.state == PNPubNubClientStateConnecting ||
             self.state == PNPubNubClientStateDisconnecting ||
             self.state == PNPubNubClientStateDisconnectingOnNetworkError) {

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.unableToSuspendOnWorkspaceSleep, [self humanReadableStateFrom:self.state]];
        }];

        if (self.state == PNPubNubClientStateConnecting) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.api.connectionAttemptDuringWorkspaceSleep, [self humanReadableStateFrom:self.state]];
            }];

            self.state = PNPubNubClientStateDisconnectedOnNetworkError;
        }
        else if (self.state == PNPubNubClientStateDisconnecting){

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.api.disconnectionAttemptDuringWorkspaceSleep,
                        [self humanReadableStateFrom:self.state]];
            }];

            self.state = PNPubNubClientStateDisconnected;
        }
        else if (self.state == PNPubNubClientStateDisconnectingOnNetworkError){

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.api.disconnectionAttemptBecauseOfErrorDuringWorkspaceSleep,
                        [self humanReadableStateFrom:self.state]];
            }];

            self.state = PNPubNubClientStateDisconnectedOnNetworkError;
        }

        [self.messagingChannel disconnectWithEvent:NO];
        [self.serviceChannel disconnectWithEvent:NO];
    }
}

- (void)handleWorkspaceDidWake:(NSNotification *)notification {

    [self pn_dispatchBlock:^{
    
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.handleWorkspaceWake, [self humanReadableStateFrom:self.state]];
        }];
    
        // Try to refresh reachability state (there is situation when reachability state changed within
        // library to handle sockets timeout/error)
        [self.reachability refreshReachabilityState:^(BOOL reachabilityWillSimulateAction) {

            [self.reachability checkServiceAvailable:^(BOOL available) {

                [self pn_dispatchBlock:^{

                    if (available) {

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.internetConnectionAvailable, [self humanReadableStateFrom:self.state]];
                        }];

                        // Check whether application is suspended
                        if (self.state == PNPubNubClientStateSuspended) {

                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                                return @[PNLoggerSymbols.api.resumingConnection, [self humanReadableStateFrom:self.state]];
                            }];

                            self.state = PNPubNubClientStateConnected;

                            self.asyncLockingOperationInProgress = NO;
                            [self.messagingChannel resume];
                            [self.serviceChannel resume];
                        }
                        else if (self.state == PNPubNubClientStateDisconnectedOnNetworkError) {

                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                                return @[PNLoggerSymbols.api.previousConnectionWasTerminatedBecauseOfErrorOnWorkspaceWeak,
                                        [self humanReadableStateFrom:self.state]];
                            }];

                            if ([self shouldRestoreConnection]) {

                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                                    return @[PNLoggerSymbols.api.shouldRestoreConnection, [self humanReadableStateFrom:self.state]];
                                }];


                                self.asyncLockingOperationInProgress = NO;
                                self.restoringConnection = YES;

                                // Try to restore connection to remote PubNub services
                                [self connect];
                            }
                        }
                    }
                    else {

                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                            return @[PNLoggerSymbols.api.networkConnectionWentDownWhileWasInBackgroundOnWorkspaceWeak, [self humanReadableStateFrom:self.state]];
                        }];

                        if (self.state == PNPubNubClientStateDisconnectedOnNetworkError) {

                            if ([self shouldRestoreConnection]) {

                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                                    return @[PNLoggerSymbols.api.connectionWillRestoreOnNetworkAvailability,
                                            [self humanReadableStateFrom:self.state]];
                                }];

                                if (!reachabilityWillSimulateAction) {

                                    [self notifyDelegateClientDidDisconnectWithError:[PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]];
                                }
                            }
                        }
                    }
                }];
            }];
        }];
    }];
}
#endif

- (void)handleConnectionErrorOnNetworkFailure {
    
    [self handleConnectionErrorOnNetworkFailureWithError:[PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]];
}

- (void)handleConnectionErrorOnNetworkFailureWithError:(PNError *)error {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];

    // Check whether client is connecting currently or not
    if (self.state == PNPubNubClientStateConnecting || self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
        self.state == PNPubNubClientStateDisconnectedOnNetworkError || self.shouldConnectOnServiceReachability) {

        if (self.state != PNPubNubClientStateDisconnectingOnNetworkError &&
            self.state != PNPubNubClientStateDisconnectedOnNetworkError) {

            self.state = PNPubNubClientStateDisconnected;
        }
        [self notifyDelegateClientConnectionFailedWithError:error];
    }
}

- (void)handleLockingOperationComplete:(BOOL)shouldStartNext {
    
    [self handleLockingOperationBlockCompletion:NULL shouldStartNext:shouldStartNext];
}

- (void)handleLockingOperationBlockCompletion:(void(^)(void))operationPostBlock shouldStartNext:(BOOL)shouldStartNext {

    [self pn_dispatchBlock:^{

        self.asyncLockingOperationInProgress = NO;
        self.asyncOperationCompletionInProgress = YES;
        // Perform post completion block
        // INFO: This is done to handle situation when some block may launch locking operation
        //       and this handling block will release another one
        if (operationPostBlock) {

            operationPostBlock();
        }

        self.asyncOperationCompletionInProgress = NO;

        // In case if during locking operation completion block execution user submitted new methods they should be placed
        // into pending invocation list.
        if ([self.reprioritizedPendingInvocations count] > 0) {

            [self.reprioritizedPendingInvocations enumerateObjectsWithOptions:NSEnumerationReverse
                                                                   usingBlock:^(id pendingInvocation, NSUInteger pendingInvocationIdx,
                                                                           BOOL *pendingInvocationEnumeratorStop) {

                                                                       [self.pendingInvocations insertObject:pendingInvocation atIndex:0];
                                                                   }];

            [self.reprioritizedPendingInvocations removeAllObjects];
        }

        if (shouldStartNext) {

            NSInvocation *methodInvocation = nil;
            if ([self.pendingInvocations count] > 0) {

                // Retrieve reference on invocation instance at the start of the list
                // (oldest scheduled instance)
                methodInvocation = [self.pendingInvocations objectAtIndex:0];
                [self.pendingInvocations removeObjectAtIndex:0];
            }

            if (methodInvocation) {

                [methodInvocation invoke];
            }
        }
    }];
}

#pragma mark - Misc methods

- (void)performAsyncLockingBlock:(void(^)(void))codeBlock postponedExecutionBlock:(void(^)(void))postponedCodeBlock {

    [self pn_dispatchBlock:^{

        // Checking whether code can be executed right now or should be postponed
        if ([self shouldPostponeMethodCall]) {

            if (postponedCodeBlock) {

                postponedCodeBlock();
            }
        }
        else {

            if (codeBlock) {

                self.asyncLockingOperationInProgress = YES;

                codeBlock();
            }
        }
    }];
}

- (void)postponeSelector:(SEL)calledMethodSelector forObject:(id)object withParameters:(NSArray *)parameters
              outOfOrder:(BOOL)placeOutOfOrder {
    
    // Initialize variables required to perform postponed method call
    int signatureParameterOffset = 2;
    NSMethodSignature *methodSignature = [object methodSignatureForSelector:calledMethodSelector];
    NSInvocation *methodInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    // Configure invocation instance
    methodInvocation.selector = calledMethodSelector;
    [parameters enumerateObjectsUsingBlock:^(id parameter, NSUInteger parameterIdx, BOOL *parametersEnumeratorStop) {
        
        NSUInteger parameterIndex = (parameterIdx + signatureParameterOffset);
        parameter = [parameter isKindOfClass:[NSNull class]] ? nil : parameter;
        const char *parameterType = [methodSignature getArgumentTypeAtIndex:parameterIndex];
        if ([parameter isKindOfClass:[NSNumber class]]) {
            
            if (strcmp(parameterType, @encode(BOOL)) == 0) {
                
                BOOL flagValue = [(NSNumber *) parameter boolValue];
                [methodInvocation setArgument:&flagValue atIndex:parameterIndex];
            }
            else if (strcmp(parameterType, @encode(NSUInteger)) == 0) {
                
                NSUInteger unsignedInteger = [(NSNumber *) parameter unsignedIntegerValue];
                [methodInvocation setArgument:&unsignedInteger atIndex:parameterIndex];
            }
            else if (strcmp(parameterType, @encode(unsigned long)) == 0) {
                
                NSUInteger unsignedInteger = [(NSNumber *) parameter unsignedLongValue];
                [methodInvocation setArgument:&unsignedInteger atIndex:parameterIndex];
            }
            else if (strcmp(parameterType, @encode(NSInteger)) == 0) {
                
                NSInteger signedInteger = [(NSNumber *)parameter integerValue];
                [methodInvocation setArgument:&
                 signedInteger atIndex:parameterIndex];
            }
            else if (strcmp(parameterType, @encode(id)) == 0) {
                
                [methodInvocation setArgument:&parameter atIndex:parameterIndex];
            }
        }
        else {
            
            if (parameter != nil) {
                
                [methodInvocation setArgument:&parameter atIndex:parameterIndex];
            }
        }
    }];
    methodInvocation.target = object;
    [methodInvocation retainArguments];

    [self pn_dispatchBlock:^{

        // Place invocation instance into mending invocations set for future usage
        if (placeOutOfOrder) {

            // Placing method invocation at first index, so it will be called as soon
            // as possible.
            if (self.isAsyncOperationCompletionInProgress) {

                [self.reprioritizedPendingInvocations insertObject:methodInvocation atIndex:0];
            }
            else {

                [self.pendingInvocations insertObject:methodInvocation atIndex:0];
            }
        }
        else {

            if (self.isAsyncOperationCompletionInProgress) {

                [self.reprioritizedPendingInvocations addObject:methodInvocation];
            }
            else {

                [self.pendingInvocations addObject:methodInvocation];
            }
        }
    }];
}

- (NSString *)humanReadableStateFrom:(PNPubNubClientState)state {
    
    NSString *humanReadableState = @"'unknown'";
    
    switch (state) {
            
        case PNPubNubClientStateReset:
            
            humanReadableState = @"'reset'";
            break;
            
        case PNPubNubClientStateCreated:
            
            humanReadableState = @"'created'";
            break;
            
        case PNPubNubClientStateConnecting:
            
            humanReadableState = @"'connecting'";
            break;
            
        case PNPubNubClientStateConnected:
            
            humanReadableState = @"'connected'";
            break;
            
        case PNPubNubClientStateDisconnecting:
            
            humanReadableState = @"'disconnecting'";
            break;
            
        case PNPubNubClientStateDisconnectingOnConfigurationChange:
            
            humanReadableState = @"'disconnecting on configuration change'";
            break;
            
        case PNPubNubClientStateDisconnectingOnNetworkError:
            
            humanReadableState = @"'disconnecting on network error'";
            break;
            
        case PNPubNubClientStateDisconnected:
            
            humanReadableState = @"'disconnected'";
            break;
            
        case PNPubNubClientStateDisconnectedOnNetworkError:
            
            humanReadableState = @"'disconnected on error'";
            break;
            
        case PNPubNubClientStateSuspended:
            
            humanReadableState = @"'suspended'";
            break;
    }
    
    
    return humanReadableState;
}

- (void)launchHeartbeatTimer {

    [self checkResuming:^(BOOL resuming) {

        if ([self isConnected] && !resuming && [[self subscribedObjectsList] count] &&
            self.clientConfiguration.presenceHeartbeatTimeout > 0.0f) {

            [self stopHeartbeatTimer];

            if (self.heartbeatTimer == NULL) {

                dispatch_source_t timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                        [self pn_privateQueue]);
                [PNDispatchHelper retain:timerSource];
                self.heartbeatTimer = timerSource;

                __pn_desired_weak __typeof__(self) weakSelf = self;
                dispatch_source_set_event_handler(self.heartbeatTimer, ^{
                    
                    __strong __typeof__(self) strongSelf = weakSelf;

                    [strongSelf handleHeartbeatTimer];
                });
                dispatch_source_set_cancel_handler(self.heartbeatTimer, ^{
                    
                    __strong __typeof__(self) strongSelf = weakSelf;

                    [PNDispatchHelper release:timerSource];
                    strongSelf.heartbeatTimer = NULL;
                });

                dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.clientConfiguration.presenceHeartbeatInterval * NSEC_PER_SEC));
                dispatch_source_set_timer(self.heartbeatTimer, start, (uint64_t)(self.clientConfiguration.presenceHeartbeatInterval * NSEC_PER_SEC), NSEC_PER_SEC);
                dispatch_resume(self.heartbeatTimer);
            }
        }
    }];
}

- (void)stopHeartbeatTimer {

    [self pn_dispatchBlock:^{

        if (self.heartbeatTimer != NULL) {

            dispatch_source_cancel(self.heartbeatTimer);
        }
    }];
}

- (void)checkResuming:(void (^)(BOOL resuming))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        BOOL isResuming = NO;
        if (self.state == PNPubNubClientStateSuspended) {

            [self checkConnectionChannelsResumeState:^(BOOL messageChannelResuming, BOOL serviceChannelResuming) {

                [self pn_dispatchBlock:^{

                    checkCompletionBlock(messageChannelResuming || serviceChannelResuming);
                }];
            }];
        }
        else {

            checkCompletionBlock(isResuming);
        }
    }];
}

- (void)checkConnectionChannelsConnectionState:(void (^)(BOOL messageChannelConnected, BOOL serviceChannelConnected))checkCompletionBlock {

    if (self.messagingChannel) {

        [self.messagingChannel checkConnected:^(BOOL messageChannelConnected) {

            if (self.serviceChannel) {

                [self.serviceChannel checkConnected:^(BOOL serviceChannelConnected) {

                    checkCompletionBlock(messageChannelConnected, serviceChannelConnected);
                }];
            }
            else {

                checkCompletionBlock(messageChannelConnected, NO);
            }
        }];
    }
    else if (self.serviceChannel) {

        [self.serviceChannel checkConnected:^(BOOL serviceChannelConnected) {

            checkCompletionBlock(NO, serviceChannelConnected);
        }];
    }
    else {

        checkCompletionBlock(NO, NO);
    }
}

- (void)checkConnectionChannelsDisconnectionState:(void (^)(BOOL messageChannelDisconnected, BOOL serviceChannelDisconnected))checkCompletionBlock {

    if (self.messagingChannel) {

        [self.messagingChannel checkDisconnected:^(BOOL messageChannelDisconnected) {

            if (self.serviceChannel) {

                [self.serviceChannel checkDisconnected:^(BOOL serviceChannelDisconnected) {

                    checkCompletionBlock(messageChannelDisconnected, serviceChannelDisconnected);
                }];
            }
            else {

                checkCompletionBlock(messageChannelDisconnected, NO);
            }
        }];
    }
    else if (self.serviceChannel) {

        [self.serviceChannel checkDisconnected:^(BOOL serviceChannelDisconnected) {

            checkCompletionBlock(NO, serviceChannelDisconnected);
        }];
    }
    else {

        checkCompletionBlock(NO, NO);
    }
}

- (void)checkConnectionChannelsSuspendedState:(void (^)(BOOL messageChannelSuspended, BOOL serviceChannelSuspended))checkCompletionBlock {

    if (self.messagingChannel) {

        [self.messagingChannel checkSuspended:^(BOOL messageChannelSuspended) {

            if (self.serviceChannel) {

                [self.serviceChannel checkSuspended:^(BOOL serviceChannelSuspended) {

                    checkCompletionBlock(messageChannelSuspended, serviceChannelSuspended);
                }];
            }
            else {

                checkCompletionBlock(messageChannelSuspended, NO);
            }
        }];
    }
    else if (self.serviceChannel) {

        [self.serviceChannel checkSuspended:^(BOOL serviceChannelSuspended) {

            checkCompletionBlock(NO, serviceChannelSuspended);
        }];
    }
    else {

        checkCompletionBlock(NO, NO);
    }
}

- (void)checkConnectionChannelsResumeState:(void (^)(BOOL messageChannelResuming, BOOL serviceChannelResuming))checkCompletionBlock {

    if (self.messagingChannel) {

        [self.messagingChannel checkResuming:^(BOOL messageChannelResuming) {

            if (self.serviceChannel) {

                [self.serviceChannel checkResuming:^(BOOL serviceChannelResuming) {

                    checkCompletionBlock(messageChannelResuming, serviceChannelResuming);
                }];
            }
            else {

                checkCompletionBlock(messageChannelResuming, NO);
            }
        }];
    }
    else if (self.serviceChannel) {

        [self.serviceChannel checkResuming:^(BOOL serviceChannelResuming) {

            checkCompletionBlock(NO, serviceChannelResuming);
        }];
    }
    else {

        checkCompletionBlock(NO, NO);
    }
}

- (void)prepareCryptoHelper {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];
    
    if ([self.clientConfiguration.cipherKey length] > 0) {
        
        PNError *helperInitializationError = nil;
        if (!self.cryptoHelper) {
            
            self.cryptoHelper = [PNCryptoHelper helperWithConfiguration:self.clientConfiguration
                                                                  error:&helperInitializationError];
        }
        else {
            
            [self.cryptoHelper updateWithConfiguration:self.clientConfiguration withError:&helperInitializationError];
        }
        
        if (helperInitializationError != nil) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.api.cryptoInitializationFailed,
                        (helperInitializationError ? helperInitializationError : [NSNull null]),
                        [self humanReadableStateFrom:self.state]];
            }];
        }
        
        if (!self.cryptoHelper.ready) {
            
            self.cryptoHelper = nil;
        }
    }
    else {
        
        self.cryptoHelper = nil;
    }
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.resourceLinkage, [NSString stringWithFormat:@"%p", self.observationCenter],
                 [NSString stringWithFormat:@"%p", self.reachability],
                 (self.cryptoHelper ? [NSString stringWithFormat:@"%p", self.cryptoHelper] : [NSNull null]),
                 (self.messagingChannel ? [NSString stringWithFormat:@"%p", self.messagingChannel] : [NSNull null]),
                 (self.serviceChannel ? [NSString stringWithFormat:@"%p", self.serviceChannel] : [NSNull null])];
    }];
}


- (void)subscribeForNotifications {
    
    [self unsubscribeFromNotifications];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterBackgroundState:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterForegroundState:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
#else
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(handleWorkspaceWillSleep:)
                                                               name:NSWorkspaceWillSleepNotification
                                                             object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(handleWorkspaceWillSleep:)
                                                               name:NSWorkspaceSessionDidResignActiveNotification
                                                             object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(handleWorkspaceDidWake:)
                                                               name:NSWorkspaceDidWakeNotification
                                                             object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(handleWorkspaceDidWake:)
                                                               name:NSWorkspaceSessionDidBecomeActiveNotification
                                                             object:nil];
#endif
}

- (void)unsubscribeFromNotifications {
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
#else
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWorkspaceWillSleepNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWorkspaceSessionDidResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWorkspaceDidWakeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWorkspaceSessionDidBecomeActiveNotification object:nil];
#endif
}

- (void)flushPostponedMethods:(BOOL)shouldExecute {

    [self pn_dispatchBlock:^{

        NSMutableArray *invocationsForFlush = [NSMutableArray arrayWithArray:self.pendingInvocations];
        if (self.reprioritizedPendingInvocations) {

            [invocationsForFlush addObjectsFromArray:self.reprioritizedPendingInvocations];
            [self.reprioritizedPendingInvocations removeAllObjects];
        }
        [self.pendingInvocations removeAllObjects];

        [invocationsForFlush enumerateObjectsUsingBlock:^(NSInvocation *postponedInvocation, NSUInteger postponedInvocationIdx,
                BOOL *postponedInvocationEnumeratorStop) {

            self.asyncLockingOperationInProgress = NO;
            if (postponedInvocation && shouldExecute) {

                [postponedInvocation invoke];
            }
        }];
    }];
}

- (BOOL)shouldPostponeMethodCall {
    
    return (self.isAsyncLockingOperationInProgress || self.isAsyncOperationCompletionInProgress);
}

- (void)notifyDelegateAboutConnectionToOrigin:(NSString *)originHostName {
        
    // Check whether delegate able to handle connection completion
    if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didConnectToOrigin:)]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.clientDelegate performSelector:@selector(pubnubClient:didConnectToOrigin:) withObject:self
                                      withObject:self.clientConfiguration.origin];
        });
    }
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.connected, (originHostName ? originHostName : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];
    
    
    [self sendNotification:kPNClientDidConnectToOriginNotification withObject:originHostName];
}

- (void)notifyDelegateAboutError:(PNError *)error {
    
    if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:error:)]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.clientDelegate performSelector:@selector(pubnubClient:error:) withObject:self withObject:error];
        });
    }

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.generalError, (error ? error : [NSNull null]), [self humanReadableStateFrom:self.state]];
    }];
    
    
    [self sendNotification:kPNClientErrorNotification withObject:error];
}

- (void)notifyDelegateClientWillDisconnectWithError:(PNError *)error {
    
    error.associatedObject = self.clientConfiguration.origin;
    if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:willDisconnectWithError:)]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.clientDelegate performSelector:@selector(pubnubClient:willDisconnectWithError:)
                                      withObject:self withObject:error];
        });
    }

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.disconnectingBecauseOfError, (error ? error : [NSNull null]),
                [self humanReadableStateFrom:self.state]];
    }];
    
    [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
}

- (void)notifyDelegateClientDidDisconnectWithError:(PNError *)error {
    
    error.associatedObject = self.clientConfiguration.origin;
    if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:withError:)]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.clientDelegate pubnubClient:self didDisconnectFromOrigin:self.clientConfiguration.origin withError:error];
        });
    }

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.disconnectedBecauseOfError, (error ? error : [NSNull null]),
                [self humanReadableStateFrom:self.state]];
    }];
    
    [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
}

- (void)notifyDelegateClientConnectionFailedWithError:(PNError *)error {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];
    
    BOOL shouldStartNextPostponedOperation = !self.shouldConnectOnServiceReachability;
    error.associatedObject = self.clientConfiguration.origin;
    
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:connectionDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate performSelector:@selector(pubnubClient:connectionDidFailWithError:) withObject:self
                                          withObject:error];
            });
        }

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.connectedFailedBecauseOfError, (error ? error : [NSNull null]),
                    [self humanReadableStateFrom:self.state]];
        }];

        [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
        if (error.code != kPNClientTriedConnectWhileConnectedError) {
            
            [self flushPostponedMethods:YES];
        }
    }
                                shouldStartNext:shouldStartNextPostponedOperation];
}

- (void)sendNotification:(NSString *)notificationName withObject:(id)object {
    
    // Send notification to all who is interested in it (observation center will track it as well)
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:object];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (BOOL)canRunInBackground {
    
    BOOL canRunInBackground = [PNApplicationHelper pn_canRunInBackground];
    if ([self.clientDelegate respondsToSelector:@selector(shouldRunClientInBackground)]) {

        canRunInBackground = [self.clientDelegate shouldRunClientInBackground];
    }
    
    
    return canRunInBackground;
}
#endif

- (BOOL)shouldRestoreConnection {
    
    BOOL shouldRestoreConnection = self.clientConfiguration.shouldAutoReconnectClient;
    if ([self.clientDelegate respondsToSelector:@selector(shouldReconnectPubNubClient:)]) {

        shouldRestoreConnection = [[self.clientDelegate performSelector:@selector(shouldReconnectPubNubClient:)
                                                             withObject:self] boolValue];
    }
    
    
    return shouldRestoreConnection;
}

- (BOOL)shouldKeepTimeTokenOnChannelsListChange {
    
    BOOL shouldKeepTimeTokenOnChannelsListChange = self.clientConfiguration.shouldKeepTimeTokenOnChannelsListChange;
    if ([self.clientDelegate respondsToSelector:@selector(shouldKeepTimeTokenOnChannelsListChange)]) {

        shouldKeepTimeTokenOnChannelsListChange = [[self.clientDelegate shouldKeepTimeTokenOnChannelsListChange] boolValue];
    }
    
    
    return shouldKeepTimeTokenOnChannelsListChange;
}

- (BOOL)shouldRestoreSubscription {
    
    BOOL shouldRestoreSubscription = self.clientConfiguration.shouldResubscribeOnConnectionRestore;
    if ([self.clientDelegate respondsToSelector:@selector(shouldResubscribeOnConnectionRestore)]) {

        shouldRestoreSubscription = [[self.clientDelegate shouldResubscribeOnConnectionRestore] boolValue];
    }
    
    
    return shouldRestoreSubscription;
}

- (void)checkShouldChannelNotifyAboutEvent:(PNConnectionChannel *)channel withBlock:(void (^)(BOOL shouldNotify))checkCompletionBlock {
    
    __block BOOL shouldChannelNotifyAboutEvent = NO;
    dispatch_block_t completionBlock = ^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.shouldCommunicationChannelNotifyDelegate, (channel.name ? channel.name : [NSNull null]),
                    (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]), @(shouldChannelNotifyAboutEvent),
                    [self humanReadableStateFrom:self.state]];
        }];
    };

    [self pn_dispatchBlock:^{

        if (self.state != PNPubNubClientStateCreated && self.state != PNPubNubClientStateDisconnecting &&
            self.state != PNPubNubClientStateDisconnected && self.state != PNPubNubClientStateReset &&
            (self.state == PNPubNubClientStateConnecting || self.state == PNPubNubClientStateConnected)) {

            if (channel) {

                [channel checkConnected:^(BOOL connected) {

                    [channel checkConnecting:^(BOOL connecting) {

                        [channel checkReconnecting:^(BOOL reconnecting) {

                            [self pn_dispatchBlock:^{

                                shouldChannelNotifyAboutEvent = (connected || connecting || reconnecting);
                                completionBlock();
                                checkCompletionBlock(shouldChannelNotifyAboutEvent);
                            }];
                        }];
                    }];
                }];
            }
            else {

                completionBlock();
                checkCompletionBlock(shouldChannelNotifyAboutEvent);
            }
        }
        else {

            [self pn_dispatchBlock:^{

                completionBlock();
                checkCompletionBlock(shouldChannelNotifyAboutEvent);
            }];
        }
    }];
}

- (BOOL)shouldRestoreSubscriptionWithLastTimeToken {
    
    BOOL shouldRestoreFromLastTimeToken = self.clientConfiguration.shouldRestoreSubscriptionFromLastTimeToken;
    if ([self.clientDelegate respondsToSelector:@selector(shouldRestoreSubscriptionFromLastTimeToken)]) {

        shouldRestoreFromLastTimeToken = [[self.clientDelegate shouldRestoreSubscriptionFromLastTimeToken] boolValue];
    }
    
    
    return shouldRestoreFromLastTimeToken;
}

- (NSInteger)requestExecutionPossibilityStatusCode {
    
    __block NSInteger statusCode = 0;
    
    // Check whether library suspended or not
    if (self.state == PNPubNubClientStateSuspended) {

        statusCode = kPNRequestExecutionFailedClientSuspendedError;
    }
    else {

        statusCode = kPNRequestExecutionFailedOnInternetFailureError;

        if (![self isConnected]) {

            // Check whether client can subscribe for channels or not
            [self.reachability checkServiceReachabilityChecked:^(BOOL checked) {

                [self.reachability checkServiceAvailable:^(BOOL available) {

                    if (checked && available) {

                        statusCode = kPNRequestExecutionFailedClientNotReadyError;
                    }
                }];
            }];
        }
        else {

            statusCode = 0;
        }
    }
    
    
    return statusCode;
}

- (void)showConfigurationInfo {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.configurationInformation, (self.clientConfiguration.origin ? self.clientConfiguration.origin : [NSNull null]),
                 (self.clientConfiguration.publishKey ? PNObfuscateString(self.clientConfiguration.publishKey) : [NSNull null]),
                 (self.clientConfiguration.subscriptionKey ? PNObfuscateString(self.clientConfiguration.subscriptionKey) : [NSNull null]),
                 (self.clientConfiguration.secretKey ? PNObfuscateString(self.clientConfiguration.secretKey) : [NSNull null]),
                 ([self.clientConfiguration.cipherKey length] ? @"specified" : @"not specified"), @(self.clientConfiguration.subscriptionRequestTimeout),
                 @(self.clientConfiguration.nonSubscriptionRequestTimeout), @(self.clientConfiguration.shouldAutoReconnectClient),
                 @(self.clientConfiguration.shouldKeepTimeTokenOnChannelsListChange), @(self.clientConfiguration.shouldResubscribeOnConnectionRestore),
                 @(self.clientConfiguration.shouldRestoreSubscriptionFromLastTimeToken), @(self.clientConfiguration.shouldUseSecureConnection),
                 @(self.clientConfiguration.shouldReduceSecurityLevelOnError), @(self.clientConfiguration.canIgnoreSecureConnectionRequirement),
                 @(self.clientConfiguration.shouldAcceptCompressedResponse), @(self.clientConfiguration.presenceHeartbeatTimeout),
                 @(self.clientConfiguration.presenceHeartbeatInterval)];
    }];
}


#pragma mark - Message channel delegate methods

- (void)checkShouldKeepTimeTokenOnChannelsListChange:(PNMessagingChannel *)messagingChannel
                                           withBlock:(void (^)(BOOL shouldKeepTimeToken))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        checkCompletionBlock([self shouldKeepTimeTokenOnChannelsListChange]);
    }];
}

- (void)checkShouldMessagingChannelRestoreSubscription:(PNMessagingChannel *)messagingChannel
                                             withBlock:(void (^)(BOOL restoreSubscription))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        checkCompletionBlock([self shouldRestoreSubscription]);
    }];
}

- (void)checkShouldMessagingChannelRestoreWithLastTimeToken:(PNMessagingChannel *)messagingChannel
                                                  withBlock:(void (^)(BOOL restoreWithLastTimeToken))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        checkCompletionBlock([self shouldRestoreSubscriptionWithLastTimeToken]);
    }];
}

- (void)clientStateInformationForChannels:(NSArray *)channels
                                withBlock:(void (^)(NSDictionary *stateOnChannel))stateFetchCompletionBlock {

    [self pn_dispatchBlock:^{

        [self.cache stateForChannels:channels withBlock:^(NSDictionary *stateOnChannel) {

            stateFetchCompletionBlock(stateOnChannel);
        }];
    }];
}

- (void)clientStateMergedWith:(NSDictionary *)updatedState andBlock:(void (^)(NSDictionary *mergedState))mergeCompletionBlock {

    [self pn_dispatchBlock:^{

        [self.cache stateMergedWithState:updatedState withBlock:^(NSDictionary *mergedState) {

            mergeCompletionBlock(mergedState);
        }];
    }];
}

- (void)clientStateInformation:(void (^)(NSDictionary *clientState))stateFetchCompletionBlock {

    [self pn_dispatchBlock:^{

        [self.cache clientState:^(NSDictionary *clientState) {

            stateFetchCompletionBlock(clientState);
        }];
    }];
}

- (void)updateClientStateInformationWith:(NSDictionary *)state forChannels:(NSArray *)channels
                               withBlock:(dispatch_block_t)updateCompletionBlock {

    [self pn_dispatchBlock:^{

        [self.cache storeClientState:state forChannels:channels];
        updateCompletionBlock();
    }];
}

- (void)messagingChannelDidReset:(PNMessagingChannel *)messagingChannel {
    
    [self handleLockingOperationComplete:YES];
}


#pragma mark - Service channel delegate methods

- (void)  serviceChannel:(PNServiceChannel *)channel didReceiveNetworkLatency:(double)latency
     andNetworkBandwidth:(double)bandwidth {
    
    // TODO: NOTIFY NETWORK METER INSTANCE ABOUT ARRIVED DATA
}


#pragma mark - Memory management

- (void)dealloc {
    
    [self pn_destroyPrivateDispatchQueue];
    
    [self.cache purgeAllState];
    self.cache = nil;

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.destroyed];
    }];
}

#pragma mark -


@end
