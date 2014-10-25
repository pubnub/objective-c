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
static NSString * const kPNCodebaseBranch = @"master";

/**
 SHA of the commit which stores actual changes in this codebase.
 */
static NSString * const kPNCodeCommitIdentifier = @"ae4915c457dc340f24e049268c68bfaf62983306";

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
@property (nonatomic, strong) NSTimer *heartbeatTimer;

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
+ (void)showVserionInfo;


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
- (BOOL)isResuming;

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
        [self showVserionInfo];
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

+ (void)resetClient {

    [PNLogger logGeneralMessageFrom:_sharedInstance withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.reset];
    }];
    
    // Mark that client is in resetting state, so it won't be affected by callbacks from transport classes
    _sharedInstance.state = PNPubNubClientStateReset;
    [_sharedInstance stopHeartbeatTimer];
    
    onceToken = 0;
    [PNObservationCenter resetCenter];
    [PNChannel purgeChannelsCache];
    _sharedInstance.cryptoHelper = nil;
    
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
    
	[[self sharedInstance] disconnectByUser:YES];
}


#pragma mark - Misc methods

+ (void)showVserionInfo {
    
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
        
        dispatch_queue_t targetQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t privateQueue = [self pn_serialQueueWithOwnerIdentifier:@"core" andTargetQueue:targetQueue];
        [PNDispatchHelper retain:privateQueue];
        [self pn_setPrivateDispatchQueue:privateQueue];

        self.state = PNPubNubClientStateCreated;
        self.cache = [PNCache new];
        self.pendingInvocations = [NSMutableArray array];
        self.reprioritizedPendingInvocations = [NSMutableArray array];
        self.observationCenter = [PNObservationCenter observationCenterWithDefaultObserver:self];
        
        // Adding PubNub services availability observer
        __block __pn_desired_weak PubNub *weakSelf = self;
        self.reachability = [PNReachability serviceReachability];
        self.reachability.reachabilityChangeHandleBlock = ^(BOOL connected) {
            
            [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.isConnected, @(connected), [weakSelf humanReadableStateFrom:weakSelf.state]];
            }];
            
            if (!connected) {
                
                [weakSelf stopHeartbeatTimer];
            }
            
            weakSelf.updatingClientIdentifier = NO;
            if (weakSelf.shouldConnectOnServiceReachabilityCheck) {
                
                [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.connectOnNetworkReachabilityCheck,
                             [weakSelf humanReadableStateFrom:weakSelf.state]];
                }];
                
                if (connected) {
                    
                    [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.networkAvailableProceedConnection,
                                 [weakSelf humanReadableStateFrom:weakSelf.state]];
                    }];
                    
                    weakSelf.asyncLockingOperationInProgress = NO;
                    
                    [weakSelf connect];
                }
                else {
                    
                    weakSelf.connectOnServiceReachabilityCheck = NO;
                    
                    [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.networkNotAvailableReportError,
                                 [weakSelf humanReadableStateFrom:weakSelf.state]];
                    }];
                    
                    weakSelf.connectOnServiceReachability = YES;
                    [weakSelf handleConnectionErrorOnNetworkFailure];
                    weakSelf.asyncLockingOperationInProgress = NO;
                }
            }
            else {
                
                if (connected) {
                    
                    [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.networkAvailable,
                                 [weakSelf humanReadableStateFrom:weakSelf.state]];
                    }];
                    
                    // In case if client is in 'disconnecting on network error' state when connection become available
                    // force client to change it state to "completed" stage of disconnection on network error
                    if (weakSelf.state == PNPubNubClientStateDisconnectingOnNetworkError) {
                        
                        [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.api.previouslyDisconnectedBecauseOfError,
                                     [weakSelf humanReadableStateFrom:weakSelf.state]];
                        }];
                        
                        weakSelf.state = PNPubNubClientStateDisconnectedOnNetworkError;
                        
                        [weakSelf.messagingChannel disconnectWithEvent:NO];
                        [weakSelf.serviceChannel disconnectWithEvent:NO];
                    }
                    
                    
                    // Check whether connection available message appeared while library tried to connect
                    // (to handle situation when library doesn't have enough time to accept callbacks and reset it
                    // state to 'disconnected'
                    if (weakSelf.state == PNPubNubClientStateConnecting) {
                        
                        [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.api.connectionStateImpossibleOnNetworkBecomeAvailable,
                                     [weakSelf humanReadableStateFrom:weakSelf.state]];
                        }];
                        
                        // Because all connection channels will be destroyed, it means that client currently disconnected
                        weakSelf.state = PNPubNubClientStateDisconnectedOnNetworkError;
                        
                        [weakSelf.messagingChannel disconnectWithEvent:NO];
                        [weakSelf.serviceChannel disconnectWithEvent:NO];
                    }
                    
                    BOOL isSuspended = weakSelf.state == PNPubNubClientStateSuspended;
                    
                    if (weakSelf.state == PNPubNubClientStateDisconnectedOnNetworkError ||
                        weakSelf.shouldConnectOnServiceReachability || isSuspended) {
                        
                        // Check whether should restore connection or not
                        if([weakSelf shouldRestoreConnection] || weakSelf.shouldConnectOnServiceReachability) {
                            
                            weakSelf.asyncLockingOperationInProgress = NO;
                            if(!weakSelf.shouldConnectOnServiceReachability){
                                
                                [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.shouldRestoreConnection,
                                             [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                                
                                weakSelf.restoringConnection = YES;
                            }
                            
                            if (isSuspended) {
                                
                                [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.shouldResumeConnection,
                                             [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                                
                                weakSelf.state = PNPubNubClientStateConnected;
                                
                                weakSelf.restoringConnection = NO;
                                [weakSelf.messagingChannel resume];
                                [weakSelf.serviceChannel resume];
                            }
                            else {
                                
                                [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.shouldConnect,
                                             [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                                
                                [weakSelf connect];
                            }
                        }
                    }
                    else {
                        
                        [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.api.noSuitableActionsForCurrentSituation,
                                     [weakSelf humanReadableStateFrom:weakSelf.state]];
                        }];
                    }
                }
                else {
                    
                    [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.networkNotAvailable, [weakSelf humanReadableStateFrom:weakSelf.state]];
                    }];
                    BOOL hasBeenSuspended = weakSelf.state == PNPubNubClientStateSuspended;
                    
                    // Check whether PubNub client was connected or connecting right now
                    if (weakSelf.state == PNPubNubClientStateConnected ||
                        weakSelf.state == PNPubNubClientStateConnecting || hasBeenSuspended) {
                        
                        if (weakSelf.state == PNPubNubClientStateConnecting) {
                            
                            [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                
                                return @[PNLoggerSymbols.api.triedToConnect, [weakSelf humanReadableStateFrom:weakSelf.state]];
                            }];
                            
                            weakSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;
                            
                            // Messaging channel will close second channel automatically.
                            [_sharedInstance.messagingChannel disconnectWithReset:NO];
                            
                            if (weakSelf.state == PNPubNubClientStateDisconnectingOnNetworkError ||
                                weakSelf.state == PNPubNubClientStateDisconnectedOnNetworkError) {
                                
                                [weakSelf handleConnectionErrorOnNetworkFailure];
                            }
                            else {
                                
                                [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.networkWentDownDuringConnectionRestoring,
                                             [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                            }
                            
                            [weakSelf flushPostponedMethods:YES];
                        }
                        else {
                            
                            if (weakSelf.state == PNPubNubClientStateSuspended) {
                                
                                [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.networkWentDownWhileSuspended,
                                             [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                            }
                            else {
                                
                                [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.networkWentDownWhileWasConnected,
                                             [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                            }
                            
                            
                            if (![weakSelf shouldRestoreConnection]) {
                                
                                [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.autoConnectionDisabled,
                                             [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                            }
                            else {
                                
                                [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.connectionWillBeRestoredOnNetworkConnectionRestore,
                                             [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                            }
                            
                            PNError *connectionError = [PNError errorWithCode:kPNClientConnectionClosedOnInternetFailureError];
                            [weakSelf notifyDelegateClientWillDisconnectWithError:connectionError];
                            
                            weakSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;
                            
                            // Check whether client was suspended or not.
                            if (hasBeenSuspended) {
                                
                                [weakSelf.messagingChannel disconnectWithReset:NO];
                                [weakSelf.serviceChannel disconnect];
                                
                                [weakSelf notifyDelegateClientDidDisconnectWithError:connectionError];
                            }
                            else {
                                
                                [weakSelf flushPostponedMethods:YES];
                                
                                // Disconnect communication channels because of network issues
                                // Messaging channel will close second channel automatically.
                                [weakSelf.messagingChannel disconnectWithReset:NO];
                            }
                        }
                    }
                    else {
                        
                        [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.api.networkWentDownBeforeConnectionCompletion,
                                     [weakSelf humanReadableStateFrom:weakSelf.state]];
                        }];
                    }
                }
            }
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
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        // Check whether
        if (![self.messagingChannel willRestoreSubscription]) {
            
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
}


#pragma mark - Client configuration

- (PNConfiguration *)configuration {
    
    __block PNConfiguration *configuration = nil;
    [self pn_dispatchSynchronouslyBlock:^{
        
        configuration = [self.clientConfiguration copy];
    }];
    
    
    return configuration;
}

- (void)setConfiguration:(PNConfiguration *)configuration {
    
    [self setupWithConfiguration:configuration andDelegate:self.clientDelegate];
}

- (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {
    
    [self pn_dispatchAsynchronouslyBlock:^{
    
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.configurationUpdateAttempt, [self humanReadableStateFrom:self.state]];
        }];
        
        // Ensure that configuration is valid before update/set client configuration to it
        if ([configuration isValid]) {
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
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
                
                BOOL canUpdateConfiguration = YES;
                BOOL isInitialConfiguration = self.clientConfiguration == nil;
                
                // Check whether PubNub client is connected to remote PubNub services or not
                if ([self isConnected]) {
                    
                    // Check whether new configuration changed critical properties of client configuration or not
                    if([self.clientConfiguration requiresConnectionResetWithConfiguration:configuration]) {
                        
                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.api.configurationUpdateRequireReconnection,
                                     [self humanReadableStateFrom:self.state]];
                        }];
                        
                        // Store new configuration while client is disconnecting
                        self.temporaryConfiguration = configuration;
                        
                        // Disconnect before client configuration update
                        [self disconnectForConfigurationChange];
                    }
                    else {
                        
                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.api.configurationUpdateDoesntRequireReconnection,
                                     [self humanReadableStateFrom:self.state]];
                        }];
                        
                        updateConfigurationBlock();
                        reachabilityConfigurationBlock(isInitialConfiguration);
                    }
                }
                else if ([self isRestoringConnection] || [self isResuming] ||
                         self.state == PNPubNubClientStateConnecting) {
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                        
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
                else if (canUpdateConfiguration) {
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.configurationUpdateDoesntRequireReconnection,
                                 [self humanReadableStateFrom:self.state]];
                    }];
                    
                    updateConfigurationBlock();
                    
                    reachabilityConfigurationBlock(isInitialConfiguration);
                }
            }
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
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
    
    [self pn_dispatchSynchronouslyBlock:^{
        
        self.clientDelegate = delegate;
    }];
}


#pragma mark - Client identification methods

- (void)setClientIdentifier:(NSString *)identifier {
    
    [self setClientIdentifier:identifier shouldCatchup:NO];
}

- (void)setClientIdentifier:(NSString *)identifier shouldCatchup:(BOOL)shouldCatchup {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.clientIdentifierUpdateAttempt, [self humanReadableStateFrom:self.state]];
    }];
    
    __block BOOL isDifferentClientIdentifier = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        isDifferentClientIdentifier = ![self.uniqueClientIdentifier isEqualToString:identifier];
    }];
        
    if (isDifferentClientIdentifier) {
        
        [self performAsyncLockingBlock:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.updatingClientIdentifier, [self humanReadableStateFrom:self.state]];
            }];
            
            [self pn_dispatchAsynchronouslyBlock:^{
                
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
                            
                            if (resubscribeRetryCount < kPNClientIdentifierUpdateRetryCount) {
                                
                                resubscribeRetryCount++;
                                block();
                            }
                            else {
                                
                                weakSelf.updatingClientIdentifier = NO;
                                [allChannels makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];
                                
                                [weakSelf notifyDelegateAboutSubscriptionFailWithError:resubscriptionError
                                                              completeLockingOperation:YES];
                            }
                        };
                        
                        void(^subscribeBlock)(void) = ^{
                            
                            weakSelf.asyncLockingOperationInProgress = NO;
                            [self subscribeOn:allChannels withCatchUp:shouldCatchup clientState:nil
                   andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *subscribedChannels,
                                                PNError *subscribeError) {
                               
                               if (subscribeError == nil) {
                                   
                                   weakSelf.updatingClientIdentifier = NO;
                                   [allChannels makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];
                                   
                                   [weakSelf handleLockingOperationComplete:YES];
                               }
                               else {
                                   
                                   retrySubscription(subscribeError);
                               }
                               
                           }];
                        };
                        
                        retrySubscription = ^(PNError *error){
                            
                            resubscribeErrorBlock(error, subscribeBlock);
                        };
                        
                        void(^unsubscribeBlock)(void) = ^{
                            
                            weakSelf.asyncLockingOperationInProgress = NO;
                            [self unsubscribeFrom:allChannels
                      withCompletionHandlingBlock:^(NSArray *leavedChannels, PNError *leaveError) {

                          if (leaveError == nil) {

                              // Check whether user identifier was provided by user or not
                              if (identifier == nil) {

                                  // Change user identifier before connect to the PubNub services
                                  weakSelf.uniqueClientIdentifier = [PNHelper UUID];
                              }
                              else {

                                  weakSelf.uniqueClientIdentifier = identifier;
                              }

                              resubscribeRetryCount = 0;
                              subscribeBlock();
                          }
                          else {

                              retryUnsubscription(leaveError);
                          }
                      }];
                        };
                        
                        retryUnsubscription = ^(PNError *error){
                            
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
            }];
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
}


#pragma mark - Client connection management methods

- (BOOL)isConnected {
    
    __block BOOL isConnected = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        isConnected = (self.state == PNPubNubClientStateConnected);
    }];
    
    
    return isConnected;
}

- (void)connect {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.connectionAttemptWithOutHandlerBlock, [self humanReadableStateFrom:self.state]];
    }];
    
    [self connectWithSuccessBlock:nil errorBlock:nil];
}

- (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                     errorBlock:(PNClientConnectionFailureBlock)failure {
    
    if (success || failure) {
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.connectionAttemptHandlerBlock, [self humanReadableStateFrom:self.state]];
        }];
    }
    
    [self performAsyncLockingBlock:^{
        
        [self pn_dispatchAsynchronouslyBlock:^{
            
            __block BOOL shouldAddStateObservation = NO;
            
            // Stores whether flags for connection postpone due to network check / availability has been enabled
            // during connection process.
            __block BOOL postponeConnectionTillNetworkCheck = NO;
            self.updatingClientIdentifier = NO;
            
            // Check whether instance already connected or not
            if (self.state == PNPubNubClientStateConnected ||
                self.state == PNPubNubClientStateConnecting) {
                
                NSString *symbolCode = PNLoggerSymbols.api.alreadyConnected;
                if (self.state == PNPubNubClientStateConnecting) {
                    
                    symbolCode = PNLoggerSymbols.api.alreadyConnecting;
                }
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[symbolCode, [self humanReadableStateFrom:self.state]];
                }];
                
                
                PNError *connectionError = [PNError errorWithCode:kPNClientTriedConnectWhileConnectedError];
                [self notifyDelegateClientConnectionFailedWithError:connectionError];
                
                if (failure) {
                    
                    failure(connectionError);
                }
                
                // In case if developer tried to initiate connection when client already was connected, procedural lock
                // should be released
                if (self.state == PNPubNubClientStateConnected) {
                    
                    [self handleLockingOperationComplete:YES];
                }
            }
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.prepareCommunicationComponents, [self humanReadableStateFrom:self.state]];
                }];
                
                // Check whether client configuration was provided or not
                if (self.clientConfiguration == nil) {
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.connectionImpossibleWithOutConfiguration,
                                 [self humanReadableStateFrom:self.state]];
                    }];
                    
                    PNError *connectionError = [PNError errorWithCode:kPNClientConfigurationError];
                    [self notifyDelegateAboutError:connectionError];
                    
                    
                    if (failure) {
                        
                        failure(connectionError);
                    }
                    
                    [self handleLockingOperationComplete:YES];
                }
                else {
                    
                    // Check whether user has been faster to call connect than library was able to resume connection
                    if (self.state == PNPubNubClientStateSuspended || [self isResuming]) {
                        
                        NSString *symbolCode = PNLoggerSymbols.api.connectionAttemptDuringSuspension;
                        if ([self isResuming]) {
                            
                            symbolCode = PNLoggerSymbols.api.connectionAttemptDuringResume;
                        }
                        
                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                            
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
                    if ([self.reachability isServiceReachabilityChecked]) {
                        
                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.api.reachabilityChecked, [self humanReadableStateFrom:self.state]];
                        }];
                        
                        // Forcibly refresh reachability information
                        [self.reachability refreshReachabilityState];
                        
                        // Checking whether remote PubNub services is reachable or not (if they are not reachable,
                        // this mean that probably there is no connection)
                        if ([self.reachability isServiceAvailable]) {
                            
                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                
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
                            
                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                
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
                                
                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.createNewCommunicationComponents,
                                             [self humanReadableStateFrom:self.state]];
                                }];
                                
                                if (!channelsShouldBeCreated && channelsDestroyed) {
                                    
                                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                        
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
                                
                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.resourceLinkage, (self.observationCenter ? [NSString stringWithFormat:@"%p", self.observationCenter] : [NSNull null]),
                                             (self.reachability ? [NSString stringWithFormat:@"%p", self.reachability] : [NSNull null]),
                                             (self.cryptoHelper ? [NSString stringWithFormat:@"%p", self.cryptoHelper] : [NSNull null]),
                                             (self.messagingChannel ? [NSString stringWithFormat:@"%p", self.messagingChannel] : [NSNull null]),
                                             (self.serviceChannel ? [NSString stringWithFormat:@"%p", self.serviceChannel] : [NSNull null])];
                                }];
                            }
                            else {
                                
                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.reuseExistingCommunicationComponents,
                                             [self humanReadableStateFrom:self.state]];
                                }];
                                
                                self.state = PNPubNubClientStateConnecting;
                                
                                // Reuse existing communication channels and reconnect them to remote origin server
                                [self.messagingChannel connect];
                                [self.serviceChannel connect];
                            }
                            
                            shouldAddStateObservation = YES;
                        }
                        else {
                            
                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                
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
                            
                            if (![self.observationCenter isSubscribedOnClientStateChange:self]) {
                                
                                if (failure) {
                                    
                                    failure(nil);
                                }
                                
                                shouldAddStateObservation = YES;
                            }
                        }
                    }
                    // Looks like reachability manager was unable to check services reachability (user still not
                    // configured client or just not enough time to check passed since client configuration)
                    else {
                        
                        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.api.internetConnectionAvailabilityNotCheckedYet,
                                     [self humanReadableStateFrom:self.state]];
                        }];
                        
                        self.asyncLockingOperationInProgress = YES;
                        self.connectOnServiceReachabilityCheck = YES;
                        self.connectOnServiceReachability = NO;
                        
                        postponeConnectionTillNetworkCheck = YES;
                        shouldAddStateObservation = YES;
                    }
                }
            }
            
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
        }];
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
    
    [self postponeSelector:@selector(connectWithSuccessBlock:errorBlock:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:success], [PNHelper nilifyIfNotSet:failure]]
                outOfOrder:self.isRestoringConnection];
}

- (void)disconnect {
    
	[self disconnectByUser:YES];
}

- (void)disconnectByUser:(BOOL)isDisconnectedByUser {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[(isDisconnectedByUser ? PNLoggerSymbols.api.disconnectionAttemptByUserRequest :
                  PNLoggerSymbols.api.disconnectionAttemptByInternalRequest),
                 [self humanReadableStateFrom:self.state]];
    }];
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        [self stopHeartbeatTimer];
        
        if ([self.reachability isSuspended]) {
            
            [self.reachability resume];
        }
    }];
    
    [self performAsyncLockingBlock:^{
        
        [self pn_dispatchAsynchronouslyBlock:^{
        
            if (isDisconnectedByUser) {
                
                self.state = PNPubNubClientStateConnected;
            }
            
            BOOL isDisconnectForConfigurationChange = self.state == PNPubNubClientStateDisconnectingOnConfigurationChange;
            
            // Remove PubNub client from list which help to observe various events
            [self.observationCenter removeClientConnectionStateObserver:self oneTimeEvent:YES];
            if (self.state != PNPubNubClientStateDisconnectingOnConfigurationChange) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.disconnecting, [self humanReadableStateFrom:self.state]];
                }];
                
                [self.cache purgeAllState];
                
                [self.observationCenter removeClientAsPushNotificationsEnabledChannelsObserver];
                [self.observationCenter removeClientAsParticipantChannelsListDownloadObserver];
                [self.observationCenter removeClientAsPushNotificationsDisableObserver];
                [self.observationCenter removeClientAsParticipantsListDownloadObserver];
                [self.observationCenter removeClientAsPushNotificationsRemoveObserver];
                [self.observationCenter removeClientAsPushNotificationsEnableObserver];
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
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.disconnectingForConfigurationChange,
                             [self humanReadableStateFrom:self.state]];
                }];
            }
            
            [self.clientConfiguration shouldKillDNSCache:NO];
            
            
            
            // Check whether application has been suspended or not
            if (self.state == PNPubNubClientStateSuspended || [self isResuming]) {
                
                self.state = PNPubNubClientStateConnected;
            }
            
            
            // Check whether should update state to 'disconnecting'
            if ([self isConnected]) {
                
                // Mark that client is disconnecting from remote PubNub services on user request (or by internal client
                // request when updating configuration)
                self.state = PNPubNubClientStateDisconnecting;
            }
            
            // Reset client runtime flags and properties
            self.connectOnServiceReachabilityCheck = NO;
            self.connectOnServiceReachability = NO;
            self.updatingClientIdentifier = NO;
            self.restoringConnection = NO;
            
            
            void(^connectionsTerminationBlock)(BOOL) = ^(BOOL allowGenerateEvents){
                
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
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.disconnectedByUserRequest, [self humanReadableStateFrom:self.state]];
                }];
                
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                        [self.clientDelegate pubnubClient:self didDisconnectFromOrigin:self.clientConfiguration.origin];
                    });
                }
                
                [self sendNotification:kPNClientDidDisconnectFromOriginNotification withObject:self.clientConfiguration.origin];
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.disconnected, (self.clientConfiguration.origin ? self.clientConfiguration.origin : [NSNull null]),
                             [self humanReadableStateFrom:self.state]];
                }];
                
                [self flushPostponedMethods:YES];
                
                [self handleLockingOperationComplete:YES];
            }
            else {
                
                // Empty connection pool after connection will be closed
                [self.messagingChannel disconnectOnInternalRequest];
                [self.serviceChannel disconnectOnInternalRequest];
                [[self subscribedObjectsList] makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];
                
                connectionsTerminationBlock(YES);
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.disconnected, (self.clientConfiguration.origin ? self.clientConfiguration.origin : [NSNull null]),
                             [self humanReadableStateFrom:self.state]];
                }];
            }
            
            
            if (isDisconnectForConfigurationChange) {
                
                __block __pn_desired_weak __typeof(self) weakSelf = self;
                
                // Delay connection restore to give some time internal components to complete their tasks
                int64_t delayInSeconds = 1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    
                    weakSelf.asyncLockingOperationInProgress = NO;
                    
                    weakSelf.state = PNPubNubClientStateCreated;
                    [weakSelf.clientConfiguration migrateConfigurationFrom:self.temporaryConfiguration];
                    weakSelf.temporaryConfiguration = nil;
                    
                    [self showConfigurationInfo];
                    [weakSelf prepareCryptoHelper];
                    
                    weakSelf.reachability.serviceOrigin = weakSelf.configuration.origin;
                    // Refresh reachability configuration
                    [weakSelf.reachability startServiceReachabilityMonitoring];
                    
                    
                    // Restore connection which will use new configuration
                    [self connect];
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
    
    __block BOOL outOfOrder = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        outOfOrder = self.state == PNPubNubClientStateDisconnectingOnConfigurationChange;
    }];
    
    [self postponeSelector:@selector(disconnectByUser:) forObject:self withParameters:@[@(isDisconnectedByUser)]
                outOfOrder:outOfOrder];
}

- (void)disconnectForConfigurationChange {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.disconnectionAttemptForConfigurationChange,
                 [self humanReadableStateFrom:self.state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.disconnectingForConfigurationChange, [self humanReadableStateFrom:self.state]];
        }];
        
        [self pn_dispatchAsynchronouslyBlock:^{
            
            [self stopHeartbeatTimer];
            
            // Mark that client is closing connection because of settings update
            self.state = PNPubNubClientStateDisconnectingOnConfigurationChange;
            
            [self.messagingChannel disconnectWithEvent:NO];
            [self.serviceChannel disconnectWithEvent:NO];
            
            // Empty connection pool after connection will be closed
            [self.messagingChannel disconnectOnInternalRequest];
            [self.serviceChannel disconnectOnInternalRequest];
            
            // Sumulate disconnection, because streams not capable for it at this moment
            [self connectionChannel:nil didDisconnectFromOrigin:self.clientConfiguration.origin];
        }];
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
    
    [self postponeSelector:@selector(disconnectForConfigurationChange) forObject:self withParameters:nil outOfOrder:NO];
}

- (void)setClientConnectionObservationWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                                          failureBlock:(PNClientConnectionFailureBlock)failure {
    
    [self pn_dispatchSynchronouslyBlock:^{
        
        // Check whether at least one of blocks has been provided and whether
        // PubNub client already subscribed on state change event or not
        if(![self.observationCenter isSubscribedOnClientStateChange:self] && (success || failure)) {
            
            // Subscribing PubNub client for connection state observation
            // (as soon as event will occur PubNub client will be removed
            // from observers list)
            __pn_desired_weak __typeof__(self) weakSelf = self;
            [self.observationCenter addClientConnectionStateObserver:weakSelf oneTimeEvent:YES
                                                   withCallbackBlock:^(NSString *origin, BOOL connected,
                                                                       PNError *connectionError) {
                                                       
                                                       // Notify subscriber via blocks
                                                       if (connected && success) {
                                                           
                                                           success(origin);
                                                       }
                                                       else if (!connected && failure){
                                                           
                                                           failure(connectionError);
                                                       }
                                                       
                                                       if (weakSelf.shouldConnectOnServiceReachability) {
                                                           
                                                           [weakSelf setClientConnectionObservationWithSuccessBlock:success failureBlock:failure];
                                                       }
                                                   }];
        }
    }];
}

- (void)warmUpConnections {
    
    [self warmUpConnection:self.messagingChannel];
    [self warmUpConnection:self.serviceChannel];
}

- (void)warmUpConnection:(PNConnectionChannel *)connectionChannel {
    
    PNTimeTokenRequest *request = [PNTimeTokenRequest new];
    request.sendingByUserRequest = NO;
    
    [self sendRequest:request onChannel:connectionChannel shouldObserveProcessing:NO];
}

- (void)postponeSetClientIdentifier:(NSString *)identifier {
    
    [self postponeSelector:@selector(setClientIdentifier:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:identifier]] outOfOrder:NO];
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
    
    
    [self     sendRequest:request onChannel:(shouldSendOnMessageChannel ? self.messagingChannel : self.serviceChannel)
  shouldObserveProcessing:shouldObserveProcessing];
}

- (void)      sendRequest:(PNBaseRequest *)request onChannel:(PNConnectionChannel *)channel
  shouldObserveProcessing:(BOOL)shouldObserveProcessing {
    
    [channel scheduleRequest:request shouldObserveProcessing:shouldObserveProcessing];
}


#pragma mark - Connection channel delegate methods

- (void)connectionChannelConfigurationDidFail:(PNConnectionChannel *)channel {
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        [self disconnectByUser:NO];
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel didConnectToHost:(NSString *)host {
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.connectionChannelConnected, (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                    (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        BOOL isChannelsConnected = [self.messagingChannel isConnected] && [self.serviceChannel isConnected];
        BOOL isCorrectRemoteHost = [self.clientConfiguration.origin isEqualToString:host];
        
        // Check whether all communication channels connected and whether client in corresponding state or not
        if (isChannelsConnected && isCorrectRemoteHost && self.state == PNPubNubClientStateConnecting) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

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
}

- (void)connectionChannel:(PNConnectionChannel *)channel didReconnectToHost:(NSString *)host {
    
    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.connectionChannelReconnected,
                     (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                     (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];

        // Check whether received event from same host on which client is configured or not and client connected at this
        // moment
        if ([self.clientConfiguration.origin isEqualToString:host]) {
            
            if (self.state == PNPubNubClientStateConnecting) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

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
    
    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.connectionChannelConnectionFailed,
                     (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                     (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether client in corresponding state and all communication channels not connected to the server
        if(self.state == PNPubNubClientStateConnecting && [self.clientConfiguration.origin isEqualToString:host] &&
           ![self.messagingChannel isConnected] && ![self.serviceChannel isConnected]) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.api.connectionFailed, (host ? host : [NSNull null]),
                        [self humanReadableStateFrom:self.state]];
            }];
            
            self.state = PNPubNubClientStateDisconnectedOnNetworkError;
            self.connectOnServiceReachabilityCheck = NO;
            self.connectOnServiceReachability = NO;
            
            [self.messagingChannel disconnectWithEvent:NO];
            [self.serviceChannel disconnectWithEvent:NO];
            
            if (![self.clientConfiguration shouldKillDNSCache]) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

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

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.api.notifyDelegateConnectionCantBeEstablished, (host ? host : [NSNull null]),
                            [self humanReadableStateFrom:self.state]];
                }];
                
                [self.clientConfiguration shouldKillDNSCache:NO];
                
                // Send notification to all who is interested in it (observation center will track it as well)
                [self notifyDelegateClientConnectionFailedWithError:error];
            }
        }
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel didDisconnectFromOrigin:(NSString *)host {
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        NSString *connectedToHost = host;
        
        // Check whether notification arrived from channels on which PubNub library is looking at this moment
        BOOL shouldHandleChannelEvent = ([channel isEqual:self.messagingChannel] || [channel isEqual:self.serviceChannel] ||
                                         self.state == PNPubNubClientStateDisconnectingOnConfigurationChange);
        
        [self stopHeartbeatTimer];
        
        if (shouldHandleChannelEvent) {
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.connectionChannelDisconnected,
                         (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                         (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                         [self humanReadableStateFrom:self.state]];
            }];
        }
        else {
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
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
        
        BOOL isForceClosingSecondChannel = NO;
        if (self.state != PNPubNubClientStateDisconnecting && self.state != PNPubNubClientStateDisconnectingOnConfigurationChange &&
            shouldHandleChannelEvent) {
            
            self.state = PNPubNubClientStateDisconnectingOnNetworkError;
            if ([channel isEqual:self.messagingChannel] &&
                (![self.serviceChannel isDisconnected] || [self.serviceChannel isConnected])) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.disconnectingServiceChannel,
                             (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                             (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                             [self humanReadableStateFrom:self.state]];
                }];
                
                isForceClosingSecondChannel = YES;
                [self.serviceChannel disconnect];
            }
            else if ([channel isEqual:self.serviceChannel] &&
                     (![self.messagingChannel isDisconnected] || [self.messagingChannel isConnected])) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.disconnectingMessagingChannel,
                             (channel ? (channel.name ? channel.name : channel) : [NSNull null]),
                             (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]),
                             [self humanReadableStateFrom:self.state]];
                }];
                
                isForceClosingSecondChannel = YES;
                [self.messagingChannel disconnectWithReset:NO];
            }
        }
        
        
        // Check whether received event from same host on which client is configured or not and all communication
        // channels are closed
        if(shouldHandleChannelEvent && !isForceClosingSecondChannel && [self.clientConfiguration.origin isEqualToString:connectedToHost] &&
           [self.messagingChannel isDisconnected] && [self.serviceChannel isDisconnected]  &&
           self.state != PNPubNubClientStateDisconnected && self.state != PNPubNubClientStateDisconnectedOnNetworkError) {
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.allConnectionChannelsDisconnected, (connectedToHost ? connectedToHost : [NSNull null]),
                         [self humanReadableStateFrom:self.state]];
            }];
            
            // Check whether all communication channels disconnected and whether client in corresponding state or not
            if (self.state == PNPubNubClientStateDisconnecting || self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
                (channel == nil && self.state != PNPubNubClientStateDisconnectingOnConfigurationChange)) {
                
                PNError *connectionError;
                PNPubNubClientState state = PNPubNubClientStateDisconnected;
                if (self.state == PNPubNubClientStateDisconnectingOnNetworkError) {
                    
                    state = PNPubNubClientStateDisconnectedOnNetworkError;
                    connectionError = [PNError errorWithCode:kPNClientConnectionClosedOnInternetFailureError];
                }
                self.state = state;
                
                BOOL reachabilityWillSimulateAction = NO;
                
                // Check whether error is caused by network error or not
                switch (connectionError.code) {
                    case kPNClientConnectionFailedOnInternetFailureError:
                    case kPNClientConnectionClosedOnInternetFailureError:
                        
                        // Check whether should restore connection or not
                        if ([self shouldRestoreConnection] && state == PNPubNubClientStateDisconnectedOnNetworkError) {
                            
                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                
                                return @[PNLoggerSymbols.api.connectionShouldBeRestoredOnReacabilityCheck,
                                         [self humanReadableStateFrom:self.state]];
                            }];
                            
                            self.restoringConnection = YES;
                        }
                        
                        // Try to refresh reachability state (there is situation when reachability state changed within
                        // library to handle sockets timeout/error)
                        reachabilityWillSimulateAction = [self.reachability refreshReachabilityState];
                        
                        if (![self.reachability isServiceAvailable]) {
                            
                            self.restoringConnection = NO;
                        }
                        break;
                        
                    default:
                        break;
                }
                
                
                // Check whether client still in bad state or not (because of async operations it is possible that before
                // this moment client was in corresponding state
                if (self.state != PNPubNubClientStateConnecting) {
                    
                    if(state == PNPubNubClientStateDisconnected) {
                        
                        // Clean up cached data
                        [PNChannel purgeChannelsCache];
                        
                        // Delay disconnection notification to give client ability to perform clean up well
                        __block __pn_desired_weak __typeof__(self) weakSelf = self;
                        void(^disconnectionNotifyBlock)(void) = ^{
                            
                            self.messagingChannel.delegate = nil;
                            self.messagingChannel = nil;
                            self.serviceChannel.delegate = nil;
                            self.serviceChannel = nil;
                            
                            if ([weakSelf.clientDelegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                
                                    [weakSelf.clientDelegate pubnubClient:weakSelf didDisconnectFromOrigin:connectedToHost];
                                });
                            }
                            [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                
                                return @[PNLoggerSymbols.api.disconnected, (connectedToHost ? connectedToHost : [NSNull null]),
                                         [self humanReadableStateFrom:self.state]];
                            }];
                            
                            
                            [weakSelf sendNotification:kPNClientDidDisconnectFromOriginNotification withObject:connectedToHost];
                            [self handleLockingOperationComplete:YES];
                        };
                        if (channel == nil) {
                            
                            disconnectionNotifyBlock();
                        }
                        else {
                            
                            double delayInSeconds = 1.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
                            dispatch_after(popTime, dispatch_get_main_queue(), disconnectionNotifyBlock);
                        }
                    }
                    else {
                        
                        __block __pn_desired_weak __typeof__ (self) weakSelf = self;
                        void(^disconnectionNotifyBlock)(void) = ^{
                            
                            if (state == PNPubNubClientStateDisconnectedOnNetworkError) {
                                
                                [weakSelf handleLockingOperationBlockCompletion:^{
                                    
                                    if ([weakSelf.clientDelegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:withError:)]) {
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                            [weakSelf.clientDelegate pubnubClient:weakSelf didDisconnectFromOrigin:connectedToHost withError:connectionError];
                                        });
                                    }
                                    [PNLogger logGeneralMessageFrom:weakSelf withParametersFromBlock:^NSArray *{
                                        
                                        return @[PNLoggerSymbols.api.disconnectedBecauseOfError,
                                                 (connectionError ? connectionError : [NSNull null]),
                                                 [self humanReadableStateFrom:self.state]];
                                    }];
                                    
                                    connectionError.associatedObject = weakSelf.clientConfiguration.origin;
                                    [weakSelf sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:connectionError];
                                }
                                                                shouldStartNext:YES];
                            }
                        };
                        
                        // Check whether service is available (this event may arrive after device was unlocked so basically
                        // connection is available and only sockets closed by remote server or internal kernel layer)
                        if ([self.reachability isServiceReachabilityChecked]) {
                            
                            if ([self.reachability isServiceAvailable]) {
                                
                                // Check whether should restore connection or not
                                if ([self shouldRestoreConnection]) {
                                    
                                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                        
                                        return @[PNLoggerSymbols.api.connectionShouldBeRestoredOnReacabilityCheck,
                                                 [self humanReadableStateFrom:self.state]];
                                    }];
                                    
                                    self.asyncLockingOperationInProgress = NO;
                                    self.restoringConnection = YES;
                                    
                                    // Try to restore connection to remote PubNub services
                                    [self connect];
                                }
                                else {
                                    
                                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                        
                                        return @[PNLoggerSymbols.api.destroyCommunicationComponents,
                                                 [self humanReadableStateFrom:self.state]];
                                    }];
                                    
                                    disconnectionNotifyBlock();
                                }
                            }
                            // In case if there is no connection check whether clint should restore connection or not.
                            else if(![self shouldRestoreConnection]) {
                                
                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.destroyCommunicationComponents,
                                             [self humanReadableStateFrom:self.state]];
                                }];
                                
                                self.state = PNPubNubClientStateDisconnected;
                                disconnectionNotifyBlock();
                            }
                            else if ([self shouldRestoreConnection]) {
                                
                                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                    
                                    return @[PNLoggerSymbols.api.connectionWillBeRestoredOnNetworkConnectionRestore,
                                             [self humanReadableStateFrom:self.state]];
                                }];
                                
                                if (!reachabilityWillSimulateAction) {
                                    
                                    [self notifyDelegateClientDidDisconnectWithError:connectionError];
                                }
                            }
                        }
                    }
                }
                else {
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.alreadyRestoringConnection, [self humanReadableStateFrom:self.state]];
                    }];
                }
            }
            // Check whether server unexpectedly closed connection while client was active or not
            else if(self.state == PNPubNubClientStateConnected) {
                
                self.state = PNPubNubClientStateDisconnected;
                
                if([self shouldRestoreConnection]) {
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                        
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
}

- (void) connectionChannel:(PNConnectionChannel *)channel willDisconnectFromOrigin:(NSString *)host
                 withError:(PNError *)error {
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        if (self.state == PNPubNubClientStateConnected && [self.clientConfiguration.origin isEqualToString:host]) {
            
            self.state = PNPubNubClientStateDisconnecting;
            BOOL disconnectedOnNetworkError = ![self.reachability isServiceAvailable];
            if(!disconnectedOnNetworkError) {
                
                disconnectedOnNetworkError = error.code == kPNRequestExecutionFailedOnInternetFailureError ||
                error.code == kPNClientConnectionClosedOnInternetFailureError;
            }
            if (!disconnectedOnNetworkError) {
                
                disconnectedOnNetworkError = ![self.messagingChannel isConnected] || ![self.serviceChannel isConnected];
            }
            if (disconnectedOnNetworkError) {
                
                self.state = PNPubNubClientStateDisconnectingOnNetworkError;
            }
            
            [self.reachability updateReachabilityFromError:error];
            
            
            [self notifyDelegateClientWillDisconnectWithError:error];
        }
    }];
}


- (void)connectionChannelWillSuspend:(PNConnectionChannel *)channel {
    
    //
}

- (void)connectionChannelDidSuspend:(PNConnectionChannel *)channel {
    
    if ([self.messagingChannel isSuspended] && [self.serviceChannel isSuspended]) {
        
        [self stopHeartbeatTimer];
    }
}

- (void)connectionChannelWillResume:(PNConnectionChannel *)channel {
    
    //
}

- (void)connectionChannelDidResume:(PNConnectionChannel *)channel requireWarmUp:(BOOL)isWarmingUpRequired {
    
    // Checking whether connection should be 'warmed up' to keep it open or not.
    if (isWarmingUpRequired) {
        
        [self warmUpConnection:channel];
    }
    [self pn_dispatchAsynchronouslyBlock:^{
        
        // Check whether on resume there is no async locking operation is running
        if (!self.asyncLockingOperationInProgress) {
            
            [self handleLockingOperationComplete:YES];
        }
        
        // Checking whether all communication channels connected or not
        if ([self.messagingChannel isConnected] && [self.serviceChannel isConnected]) {
            
            [self notifyDelegateAboutConnectionToOrigin:self.clientConfiguration.origin];
            [self launchHeartbeatTimer];
        }
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel checkCanConnect:(void(^)(BOOL))checkCompletionBlock {
    
    [self pn_dispatchSynchronouslyBlock:^{
        
        // Help reachability instance update it's state our of schedule
        [self.reachability refreshReachabilityState];
        
        checkCompletionBlock([self.reachability isServiceAvailable]);
    }];
}

- (void)connectionChannel:(PNConnectionChannel *)channel checkShouldRestoreConnection:(void(^)(BOOL))checkCompletionBlock {
    
    [self pn_dispatchSynchronouslyBlock:^{
        
        // Help reachability instance update it's state our of schedule
        [self.reachability refreshReachabilityState];
        
        BOOL isSimulatingReachability = [self.reachability isSimulatingNetworkSwitchEvent];
        BOOL shouldRestoreConnection = (self.state == PNPubNubClientStateConnecting ||
                                        self.state == PNPubNubClientStateConnected ||
                                        self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
                                        self.state == PNPubNubClientStateDisconnectedOnNetworkError);
        
        // Ensure that there is connection available as well as permission to connect
        shouldRestoreConnection = (shouldRestoreConnection && [self.reachability isServiceAvailable] && !isSimulatingReachability);
        
        checkCompletionBlock(shouldRestoreConnection);
    }];
}

- (void)isPubNubServiceAvailable:(BOOL)shouldUpdateInformation checkCompletionBlock:(void(^)(BOOL))checkCompletionBlock; {
    
    if (shouldUpdateInformation) {
        
        [self pn_dispatchSynchronouslyBlock:^{
        
            // Help reachability instance update it's state our of schedule
            [self.reachability refreshReachabilityState];
            
            checkCompletionBlock([self.reachability isServiceAvailable]);
        }];
    }
    else {
        
        checkCompletionBlock([self.reachability isServiceAvailable]);
    }
}


#pragma mark - Handler methods

- (void)handleHeartbeatTimer {
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        // Checking whether we are still connected and there is some channels for which we can create this heartbeat
        // request.
        if ([self isConnected] && ![self isResuming] && [[self subscribedObjectsList] count] &&
            self.clientConfiguration.presenceHeartbeatTimeout > 0.0f) {
            
            // Prepare and send request w/o observation (it mean that any response for request will be ignored
            NSArray *channels = [self subscribedObjectsList];
            [self sendRequest:[PNHeartbeatRequest heartbeatRequestForChannels:channels
                                                              withClientState:[self.cache state]]
      shouldObserveProcessing:NO];
        }
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
                
                [self pn_dispatchSynchronouslyBlock:^{
                    
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
                }];
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
                                 
                                 [self pn_dispatchSynchronouslyBlock:^{
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
                                                         dispatch_async(dispatch_get_main_queue(), suspensionCompletionBlock);
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
                             }];
            });
        }
    }
}

- (void)handleApplicationDidEnterForegroundState:(NSNotification *)__unused notification  {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.handleEnterForeground, [self humanReadableStateFrom:self.state]];
    }];
    
    [self pn_dispatchSynchronouslyBlock:^{
        
        // Try to refresh reachability state (there is situation when reachability state changed within
        // library to handle sockets timeout/error)
        BOOL reachabilityWillSimulateAction = [self.reachability refreshReachabilityState];
        
        if ([self.reachability isServiceAvailable]) {
            
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
}
#else
- (void)handleWorkspaceWillSleep:(NSNotification *)notification {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.handleWorkspaceSleep, [self humanReadableStateFrom:self.state]];
    }];
    
    [self pn_dispatchSynchronouslyBlock:^{
        
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
    }];
}

- (void)handleWorkspaceDidWake:(NSNotification *)notification {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.handleWorkspaceWake, [self humanReadableStateFrom:self.state]];
    }];
    
    [self pn_dispatchSynchronouslyBlock:^{
    
        // Try to refresh reachability state (there is situation when reachability state changed within
        // library to handle sockets timeout/error)
        BOOL reachabilityWillSimulateAction = [self.reachability refreshReachabilityState];
        
        if ([self.reachability isServiceAvailable]) {
            
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
}
#endif

- (void)handleConnectionErrorOnNetworkFailure {
    
    [self handleConnectionErrorOnNetworkFailureWithError:[PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]];
}

- (void)handleConnectionErrorOnNetworkFailureWithError:(PNError *)error {
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        // Check whether client is connecting currently or not
        if (self.state == PNPubNubClientStateConnecting || self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
            self.state == PNPubNubClientStateDisconnectedOnNetworkError || self.shouldConnectOnServiceReachability) {
            
            if (self.state != PNPubNubClientStateDisconnectingOnNetworkError &&
                self.state != PNPubNubClientStateDisconnectedOnNetworkError) {
                
                self.state = PNPubNubClientStateDisconnected;
            }
            [self notifyDelegateClientConnectionFailedWithError:error];
        }
    }];
}

- (void)handleLockingOperationComplete:(BOOL)shouldStartNext {
    
    [self handleLockingOperationBlockCompletion:NULL shouldStartNext:shouldStartNext];
}

- (void)handleLockingOperationBlockCompletion:(void(^)(void))operationPostBlock shouldStartNext:(BOOL)shouldStartNext {
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
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
}

- (void)postponeSelector:(SEL)calledMethodSelector forObject:(id)object withParameters:(NSArray *)parameters
              outOfOrder:(BOOL)placeOutOfOrder{
    
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
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
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
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        [self stopHeartbeatTimer];
    
        if ([self isConnected] && ![self isResuming] && [[self subscribedObjectsList] count] &&
            self.clientConfiguration.presenceHeartbeatTimeout > 0.0f) {
            
            self.heartbeatTimer = [NSTimer timerWithTimeInterval:self.clientConfiguration.presenceHeartbeatInterval target:self
                                                        selector:@selector(handleHeartbeatTimer) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.heartbeatTimer forMode:NSRunLoopCommonModes];
        }
    }];
}

- (void)stopHeartbeatTimer {
    
    [self pn_dispatchAsynchronouslyBlock:^{
    
        if ([self.heartbeatTimer isValid]) {
            
            [self.heartbeatTimer invalidate];
        }
        self.heartbeatTimer = nil;
    }];
}

- (BOOL)isResuming {
    
    __block BOOL isResuming = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        if (self.state == PNPubNubClientStateSuspended) {
            
            isResuming = [self.messagingChannel isResuming] || [self.serviceChannel isResuming];
        }
    }];
    
    
    return isResuming;
}

- (void)prepareCryptoHelper {
    
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
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        NSArray *invocationsForFlush = [NSArray arrayWithArray:self.pendingInvocations];
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
    
    __block BOOL shouldPostponeMethodCall = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        shouldPostponeMethodCall = (self.isAsyncLockingOperationInProgress || self.isAsyncOperationCompletionInProgress);
    }];
    
    
    return shouldPostponeMethodCall;
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
        
            [self.clientDelegate performSelector:@selector(pubnubClient:willDisconnectWithError:) withObject:self withObject:error];
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
    
    __block BOOL canRunInBackground = [PNApplicationHelper pn_canRunInBackground];
    
    if ([self.clientDelegate respondsToSelector:@selector(shouldRunClientInBackground)]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            canRunInBackground = [self.clientDelegate shouldRunClientInBackground];
        });
    }
    
    
    return canRunInBackground;
}
#endif

- (BOOL)shouldRestoreConnection {
    
    __block BOOL shouldRestoreConnection = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        shouldRestoreConnection = self.clientConfiguration.shouldAutoReconnectClient;
        if ([self.clientDelegate respondsToSelector:@selector(shouldReconnectPubNubClient:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                shouldRestoreConnection = [[self.clientDelegate performSelector:@selector(shouldReconnectPubNubClient:)
                                                                     withObject:self] boolValue];
            });
        }
    }];
    
    
    return shouldRestoreConnection;
}

- (BOOL)shouldKeepTimeTokenOnChannelsListChange {
    
    __block BOOL shouldKeepTimeTokenOnChannelsListChange = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        shouldKeepTimeTokenOnChannelsListChange = self.clientConfiguration.shouldKeepTimeTokenOnChannelsListChange;
        if ([self.clientDelegate respondsToSelector:@selector(shouldKeepTimeTokenOnChannelsListChange)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                shouldKeepTimeTokenOnChannelsListChange = [[self.clientDelegate shouldKeepTimeTokenOnChannelsListChange] boolValue];
            });
        }
    }];
    
    
    return shouldKeepTimeTokenOnChannelsListChange;
}

- (BOOL)shouldRestoreSubscription {
    
    __block BOOL shouldRestoreSubscription = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        shouldRestoreSubscription = self.clientConfiguration.shouldResubscribeOnConnectionRestore;
        if ([self.clientDelegate respondsToSelector:@selector(shouldResubscribeOnConnectionRestore)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                shouldRestoreSubscription = [[self.clientDelegate shouldResubscribeOnConnectionRestore] boolValue];
            });
        }
    }];
    
    
    return shouldRestoreSubscription;
}

- (BOOL)shouldChannelNotifyAboutEvent:(PNConnectionChannel *)channel {
    
    __block BOOL shouldChannelNotifyAboutEvent = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        if (self.state != PNPubNubClientStateCreated && self.state != PNPubNubClientStateDisconnecting &&
            self.state != PNPubNubClientStateDisconnected && self.state != PNPubNubClientStateReset &&
            (self.state == PNPubNubClientStateConnecting || self.state == PNPubNubClientStateConnected)) {
            
            shouldChannelNotifyAboutEvent = [channel isConnected] || [channel isConnecting];
        }
    }];

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.shouldCommunicationChannelNotifyDelegate, (channel.name ? channel.name : [NSNull null]),
                (channel ? [NSString stringWithFormat:@"%p", channel] : [NSNull null]), @(shouldChannelNotifyAboutEvent),
                [self humanReadableStateFrom:self.state]];
    }];
    
    
    return shouldChannelNotifyAboutEvent;
}

- (BOOL)shouldRestoreSubscriptionWithLastTimeToken {
    
    __block BOOL shouldRestoreFromLastTimeToken = NO;
    [self pn_dispatchSynchronouslyBlock:^{
        
        shouldRestoreFromLastTimeToken = self.clientConfiguration.shouldRestoreSubscriptionFromLastTimeToken;
        if ([self.clientDelegate respondsToSelector:@selector(shouldRestoreSubscriptionFromLastTimeToken)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                shouldRestoreFromLastTimeToken = [[self.clientDelegate shouldRestoreSubscriptionFromLastTimeToken] boolValue];
            });
        }
    }];
    
    
    return shouldRestoreFromLastTimeToken;
}

- (NSInteger)requestExecutionPossibilityStatusCode {
    
    __block NSInteger statusCode = 0;
    [self pn_dispatchSynchronouslyBlock:^{
    
        // Check whether library suspended or not
        if (self.state == PNPubNubClientStateSuspended) {
            
            statusCode = kPNRequestExecutionFailedClientSuspendedError;
        }
        else {
            
            statusCode = kPNRequestExecutionFailedOnInternetFailureError;
            
            if (![self isConnected]) {
                
                // Check whether client can subscribe for channels or not
                if ([self.reachability isServiceReachabilityChecked] && [self.reachability isServiceAvailable]) {
                    
                    statusCode = kPNRequestExecutionFailedClientNotReadyError;
                }
            }
            else {
                
                statusCode = 0;
            }
        }
    }];
    
    
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

- (BOOL)shouldKeepTimeTokenOnChannelsListChange:(PNMessagingChannel *)messagingChannel {
    
    return [self shouldKeepTimeTokenOnChannelsListChange];
}

- (BOOL)shouldMessagingChannelRestoreSubscription:(PNMessagingChannel *)messagingChannel {
    
    return [self shouldRestoreSubscription];
}

- (BOOL)shouldMessagingChannelRestoreWithLastTimeToken:(PNMessagingChannel *)messagingChannel {
    
    return [self shouldRestoreSubscriptionWithLastTimeToken];
}

- (NSDictionary *)clientStateInformationForChannels:(NSArray *)channels {
    
    return [self.cache stateForChannels:channels];
}

- (NSDictionary *)clientStateMergedWith:(NSDictionary *)updatedState {
    
    return [self.cache stateMergedWithState:updatedState];
}

- (NSDictionary *)clientStateInformation {
    
    return [self.cache state];
}

- (void)updateClientStateInformationWith:(NSDictionary *)state forChannels:(NSArray *)channels {
    
    [self.cache storeClientState:state forChannels:channels];
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
    
    [self.cache purgeAllState];
    self.cache = nil;

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.destroyed];
    }];
}

#pragma mark -


@end
