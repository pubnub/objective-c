//
//  PubNub.m
//  pubnub
//
//  This is base and main class which is
//  responsible for communication with
//  PubNub services and handle all events
//  and notifications.
//
//
//  Created by Sergey Mamontov.
//
//

#import "PubNub+Protected.h"
#import "PNConnectionChannel+Protected.h"
#import "PNPresenceEvent+Protected.h"
#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import "UIApplication+PNAdditions.h"
#endif
#import "PNServiceChannelDelegate.h"
#import "PNConnection+Protected.h"
#import "PNMessagingChannel.h"
#import "PNServiceChannel.h"
#import "PNRequestsImport.h"
#import "PNHereNowRequest.h"
#import "PNCryptoHelper.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

// Stores reference on singleton PubNub instance
static PubNub *_sharedInstance = nil;
static dispatch_once_t onceToken;

// Stores reference on list of invocation instances which is used to support synchronous library methods call
// (connect/disconnect/subscribe/unsubscribe)
static NSMutableArray *pendingInvocations = nil;


#pragma mark - Private interface methods

@interface PubNub () <PNConnectionChannelDelegate, PNMessageChannelDelegate, PNServiceChannelDelegate>


#pragma mark - Properties

// Stores reference on flag which specify whether client identifier was passed by user or generated on demand
@property (nonatomic, assign, getter = isUserProvidedClientIdentifier) BOOL userProvidedClientIdentifier;

// Stores whether client should connect as soon as services will be checked for reachability
@property (nonatomic, assign, getter = shouldConnectOnServiceReachabilityCheck) BOOL connectOnServiceReachabilityCheck;

// Stores whether client should perform initial connection (connection which is initialized after client configuration)
@property (nonatomic, assign, getter = shouldConnectOnServiceReachability) BOOL connectOnServiceReachability;

// Stores whether client is restoring connection after network failure or not
@property (nonatomic, assign, getter = isRestoringConnection) BOOL restoringConnection;

// Stores reference on configuration which was used to perform initial PubNub client initialization
@property (nonatomic, strong) PNConfiguration *temporaryConfiguration;

// Reference on channels which is used to communicate with PubNub service
@property (nonatomic, strong) PNMessagingChannel *messagingChannel;

// Reference on channels which is used to send service messages to PubNub service
@property (nonatomic, strong) PNServiceChannel *serviceChannel;

// Stores reference on client delegate
@property (nonatomic, pn_desired_weak) id<PNDelegate> delegate;

// Stores unique client initialization session identifier (created each time when PubNub stack is configured
// after application launch)
@property (nonatomic, strong) NSString *launchSessionIdentifier;

// Stores reference on configuration which was used to perform initial PubNub client initialization
@property (nonatomic, strong) PNConfiguration *configuration;

// Stores reference on service reachability monitoring instance
@property (nonatomic, strong) PNReachability *reachability;

// Stores reference on current client identifier
@property (nonatomic, strong) NSString *clientIdentifier;

// Stores current client state
@property (nonatomic, assign) PNPubNubClientState state;

// Stores whether library is performing one of async locking methods or not (if yes, other calls will be placed
// into pending set)
@property (nonatomic, assign, getter = isAsyncLockingOperationInProgress) BOOL asyncLockingOperationInProgress;


#pragma mark - Class methods

#pragma mark - Client connection management methods

+ (void)postponeConnectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                             errorBlock:(PNClientConnectionFailureBlock)failure;
+ (void)disconnectByUser:(BOOL)isDisconnectedByUser;
+ (void)postponeDisconnectByUser:(BOOL)isDisconnectedByUser;
+ (void)disconnectForConfigurationChange;
+ (void)postponeDisconnectForConfigurationChange;


#pragma mark - Client identification

+ (void)postponeSetClientIdentifier:(NSString *)identifier;


#pragma mark - Channels subscription management

+ (void)postponeSubscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent
         andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

+ (void)postponeUnsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent
             andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;


#pragma mark - APNS management

+ (void)postponeEnablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                       andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

+ (void)postponeDisablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                        andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

+ (void)postponeRemoveAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                                 withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;

+ (void)postponeRequestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                             withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;

#pragma mark - Presence management

+ (void)postponeEnablePresenceObservationForChannels:(NSArray *)channels
                         withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;
+ (void)postponeDisablePresenceObservationForChannels:(NSArray *)channels
                          withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;


#pragma mark - Time token

+ (void)postponeRequestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;


#pragma mark - Messages processing methods

+ (void)postponeSendMessage:(id)message toChannel:(PNChannel *)channel
        withCompletionBlock:(PNClientMessageProcessingBlock)success;


#pragma mark - History methods

+ (void)postponeRequestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                                   limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory
                     withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;


#pragma mark - Participant methods

+ (void)postponeRequestParticipantsListForChannel:(PNChannel *)channel
                              withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;


#pragma mark - Misc methods

/**
 * Allow to perform code which should lock asynchronous methods execution till it ends and in case if code itself
 * should be postponed, corresponding block is passed.
 */
+ (void)performAsyncLockingBlock:(void(^)(void))codeBlock postponedExecutionBlock:(void(^)(void))postponedCodeBlock;


#pragma mark - Instance methods

#pragma mark - Client connection management methods

/**
 * Configure client connection state observer with handling blocks
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
 * Sends message over corresponding communication channel
 */
- (void)sendRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing;;

/**
 * Send message over specified communication channel
 */
- (void)    sendRequest:(PNBaseRequest *)request onChannel:(PNConnectionChannel *)channel
shouldObserveProcessing:(BOOL)shouldObserveProcessing;


#pragma mark - Handler methods

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

/**
 * Handle locking operation completion and pop new one from pending invocations list.
 */
- (void)handleLockingOperationComplete:(BOOL)shouldStartNext;
- (void)handleLockingOperationBlockCompletion:(void(^)(void))operationPostBlock shouldStartNext:(BOOL)shouldStartNext;


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
 * Check whether whether call to specific method should be postponed or not. This will allot to perform synchronous
 * call on specific library methods.
 */
- (BOOL)shouldPostponeMethodCall;

/**
 * Place selector into list of postponed calls with corresponding parameters If 'placeOutOfOrder' is specified,
 * selector will be placed first in FIFO queue and will be executed as soon as it will be possible.
 */
- (void)postponeSelector:(SEL)calledMethodSelector
               forObject:(id)object
          withParameters:(NSArray *)parameters
              outOfOrder:(BOOL)placeOutOfOrder;

/**
 * This method will notify delegate about that connection to the PubNub service is established and send notification
 * about it
 */
- (void)notifyDelegateAboutConnectionToOrigin:(NSString *)originHostName;

/**
 * This method will notify delegate that client is about to restore subscription to specified set of channels
 * and send notification about it.
 */
- (void)notifyDelegateAboutResubscribeWillStartOnChannels:(NSArray *)channels;

/**
 * This method will notify delegate about that subscription failed with error
 */
- (void)notifyDelegateAboutSubscriptionFailWithError:(PNError *)error;

/**
 * This method will notify delegate about that unsubscription failed with error
 */
- (void)notifyDelegateAboutUnsubscriptionFailWithError:(PNError *)error;

/**
 * This method will notify delegate about that presence enabling failed with error
 */
- (void)notifyDelegateAboutPresenceEnablingFailWithError:(PNError *)error;

/**
 * This method will notify delegate about that presence disabling failed with error
 */
- (void)notifyDelegateAboutPresenceDisablingFailWithError:(PNError *)error;

/**
 * This method will notify delegate about that push notification enabling failed with error
 */
- (void)notifyDelegateAboutPushNotificationsEnableFailedWithError:(PNError *)error;

/**
 * This method will notify delegate about that push notification disabling failed with error
 */
- (void)notifyDelegateAboutPushNotificationsDisableFailedWithError:(PNError *)error;

/**
 * This method will notify delegate about that push notification removal from all channels failed because of error
 */
- (void)notifyDelegateAboutPushNotificationsRemoveFailedWithError:(PNError *)error;

/**
 * This method will notify delegate about that push notification enabled channels list retrieval request failed with error
 */
- (void)notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:(PNError *)error;

/**
 * This method will notify delegate about that time token retrieval failed because of error
 */
- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error;

/**
 * This method will notify delegate about that message sending failed because of error
 */
- (void)notifyDelegateAboutMessageSendingFailedWithError:(PNError *)error;

/**
 * This method will notify delegate about that history loading error occurred
 */
- (void)notifyDelegateAboutHistoryDownloadFailedWithError:(PNError *)error;

/**
 * This method will notify delegate about that participants list download error occurred
 */
- (void)notifyDelegateAboutParticipantsListDownloadFailedWithError:(PNError *)error;

/**
 * This method allow to ensure that delegate can process errors and will send error to the delegate
 */
- (void)notifyDelegateAboutError:(PNError *)error;

/**
 * This method allow notify delegate that client is about to close connection because of specified error
 */
- (void)notifyDelegateClientWillDisconnectWithError:(PNError *)error;
- (void)notifyDelegateClientConnectionFailedWithError:(PNError *)error;

- (void)sendNotification:(NSString *)notificationName withObject:(id)object;

/**
 * Check whether client should restore connection after network went down and restored now
 */
- (BOOL)shouldRestoreConnection;

/**
 * Check whether delegate should be notified about some runtime event (errors will be notified w/o regard to this flag)
 */
- (BOOL)shouldNotifyAboutEvent;

/**
 * Check whether client should restore subscription to previous channels or not
 */
- (BOOL)shouldRestoreSubscription;

/**
 * Check whether client should restore subscription with last time token or not
 */
- (BOOL)shouldRestoreSubscriptionWithLastTimeToken;

/**
 * Retrieve request execution possibility code. If everything is fine, than 0 will be returned, in other case it will
 * be treated as error and mean that request execution is impossible
 */
- (NSInteger)requestExecutionPossibilityStatusCode;


@end


#pragma mark - Public interface methods

@implementation PubNub


#pragma mark - Class methods

+ (PubNub *)sharedInstance {
    
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[[self class] alloc] init];
    });
    

    return _sharedInstance;
}

+ (void)resetClient {

    PNLog(PNLogGeneralLevel, _sharedInstance, @"CLIENT RESET.");
    
    // Mark that client is in resetting state, so it won't be affected by callbacks from transport classes
    _sharedInstance.state = PNPubNubClientStateReset;
    
    onceToken = 0;
    [PNObservationCenter resetCenter];
    [PNConnection resetConnectionsPool];
    [PNChannel purgeChannelsCache];
    [PNCryptoHelper resetHelper];
    
    [_sharedInstance.messagingChannel terminate];
    [_sharedInstance.serviceChannel terminate];
    _sharedInstance.messagingChannel = nil;
    _sharedInstance.serviceChannel = nil;
    [_sharedInstance.reachability stopServiceReachabilityMonitoring];
    _sharedInstance.reachability = nil;
    
    pendingInvocations = nil;

    [_sharedInstance unsubscribeFromNotifications];
    _sharedInstance = nil;
}


#pragma mark - Client connection management methods

+ (void)connect {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO CONNECT W/O SUCCESS AND/OR ERROR BLOCK... (STATE: %d)",
          [self sharedInstance].state);
    
    [self connectWithSuccessBlock:nil errorBlock:nil];
}

+ (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                     errorBlock:(PNClientConnectionFailureBlock)failure {

    if (success || failure) {

        PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO CONNECT W/ SUCCESS AND/OR ERROR BLOCK... (STATE: %d)",
              [self sharedInstance].state);
    }

    [self performAsyncLockingBlock:^{

        __block BOOL shouldAddStateObservation = NO;

        // Check whether instance already connected or not
        if ([self sharedInstance].state == PNPubNubClientStateConnected ||
            [self sharedInstance].state == PNPubNubClientStateConnecting) {

            NSString *state = @"CONNECTED";
            if ([self sharedInstance].state == PNPubNubClientStateConnecting) {

                state = @"CONNECTING...";
            }
            PNLog(PNLogGeneralLevel, [self sharedInstance], @"PUBNUB CLIENT ALREDY %@ (STATE: %d)",
                  state, [self sharedInstance].state);


            PNError *connectionError = [PNError errorWithCode:kPNClientTriedConnectWhileConnectedError];
            [[self sharedInstance] notifyDelegateClientConnectionFailedWithError:connectionError];

            if (failure) {

                failure(connectionError);
            }
        }
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"PREPARE COMPONENTS FOR CONNECTION... (STATE: %d)",
                  [self sharedInstance].state);

            // Check whether client configuration was provided or not
            if ([self sharedInstance].configuration == nil) {

                PNLog(PNLogGeneralLevel, [self sharedInstance], @"{ERROR} TRYING TO CONNECT W/O CONFIGURATION (STATE: %d)",
                      [self sharedInstance].state);

                PNError *connectionError = [PNError errorWithCode:kPNClientConfigurationError];
                [[self sharedInstance] notifyDelegateAboutError:connectionError];


                if (failure) {

                    failure(connectionError);
                }
            }
            else {

                // Check whether user has been faster to call connect than library was able to resume connection
                if ([self sharedInstance].state == PNPubNubClientStateSuspended || [[self sharedInstance] isResuming]) {

                    NSString *state = @"WAS SUSPENDED";
                    if ([[self sharedInstance] isResuming]) {

                        state = @"TRYING TO RESUME AFTER SLEEP";
                    }
                    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRIED TO CONNECT WHILE %@ (LIBRARY DOESN'T HAVE"
                          " ENOUGH TIME TO RESTORE) (STATE: %d)", state, [self sharedInstance].state);

                    // Because all connection channels will be destroyed, it means that client currently disconnected
                    [self sharedInstance].state = PNPubNubClientStateDisconnected;

                    [_sharedInstance.messagingChannel terminate];
                    [_sharedInstance.serviceChannel terminate];
                    _sharedInstance.messagingChannel = nil;
                    _sharedInstance.serviceChannel = nil;
                }

                // Check whether user identifier was provided by user or not
                if (![self sharedInstance].isUserProvidedClientIdentifier) {

                    // Change user identifier before connect to the PubNub services
                    [self sharedInstance].clientIdentifier = PNUniqueIdentifier();
                }

                // Check whether services are available or not
                if ([[self sharedInstance].reachability isServiceReachabilityChecked]) {

                    PNLog(PNLogGeneralLevel, [self sharedInstance], @"REACHABILITY CHECKED (STATE: %d)",
                          [self sharedInstance].state);

                    // Forcibly refresh reachability information
                    [[self sharedInstance].reachability refreshReachabilityState];

                    // Checking whether remote PubNub services is reachable or not (if they are not reachable,
                    // this mean that probably there is no connection)
                    if ([[self sharedInstance].reachability isServiceAvailable]) {

                        PNLog(PNLogGeneralLevel, [self sharedInstance], @"INTERNET CONNECTION AVAILABLE (STATE: %d)",
                              [self sharedInstance].state);

                        // Notify PubNub delegate about that it will try to establish connection with remote PubNub
                        // origin (notify if delegate implements this method)
                        if ([[self sharedInstance].delegate respondsToSelector:@selector(pubnubClient:willConnectToOrigin:)]) {

                            [[self sharedInstance].delegate performSelector:@selector(pubnubClient:willConnectToOrigin:)
                                                                 withObject:[self sharedInstance]
                                                                 withObject:[self sharedInstance].configuration.origin];
                        }

                        [[self sharedInstance] sendNotification:kPNClientWillConnectToOriginNotification
                                                     withObject:[self sharedInstance].configuration.origin];

                        PNLog(PNLogDelegateLevel, [self sharedInstance], @" PubNub will connect to origin: %@)",
                              [self sharedInstance].configuration.origin);


                        // Check whether PubNub client was just created and there is no resources for reuse or not
                        if ([self sharedInstance].state == PNPubNubClientStateCreated ||
                            [self sharedInstance].state == PNPubNubClientStateDisconnected ||
                            [self sharedInstance].state == PNPubNubClientStateReset) {

                            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CREATE NEW COMPONNENTS TO POWER UP "
                                  "LIBRARY OPERATION WITH ORIGIN (STATE: %d)", [self sharedInstance].state);

                            [self sharedInstance].state = PNPubNubClientStateConnecting;

                            // Initialize communication channels
                            [self sharedInstance].messagingChannel = [PNMessagingChannel messageChannelWithDelegate:[self sharedInstance]];
                            [self sharedInstance].messagingChannel.messagingDelegate = [self sharedInstance];
                            [self sharedInstance].serviceChannel = [PNServiceChannel serviceChannelWithDelegate:[self sharedInstance]];
                            [self sharedInstance].serviceChannel.serviceDelegate = [self sharedInstance];
                        }
                        else {

                            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CONNECTION CAN BE INITATED USING "
                                    "EXISTING COMPONENTS (STATE: %d)", [self sharedInstance].state);

                            [self sharedInstance].state = PNPubNubClientStateConnecting;

                            // Reuse existing communication channels and reconnect them to remote origin server
                            [[self sharedInstance].messagingChannel connect];
                            [[self sharedInstance].serviceChannel connect];
                        }

                        shouldAddStateObservation = YES;
                    }
                    else {

                        PNLog(PNLogGeneralLevel, [self sharedInstance], @"INTERNET CONNECTION NOT AVAILABLE. LIBRARY"
                                " WILL CONNECT AS SOON AS CONNECTION BECOME AVAILABLE. (STATE: %d)",
                              [self sharedInstance].state);

                        // Mark that client should try to connect when network will be available again
                        [self sharedInstance].connectOnServiceReachabilityCheck = NO;
                        [self sharedInstance].asyncLockingOperationInProgress = YES;
                        [self sharedInstance].connectOnServiceReachability = YES;

                        [[self sharedInstance] handleConnectionErrorOnNetworkFailureWithError:nil];
                        [self sharedInstance].asyncLockingOperationInProgress = YES;

                        if (![[PNObservationCenter defaultCenter] isSubscribedOnClientStateChange:[self sharedInstance]]) {

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

                    PNLog(PNLogGeneralLevel, [self sharedInstance], @"REACHABILITY NOT CHECKED YET. LIBRARY WILL "
                            "CONTINUE CONNECTION IF REACHABILITY WILL REPORT NETWORK AVAILABILITY (STATE: %d)",
                          [self sharedInstance].state);

                    [self sharedInstance].asyncLockingOperationInProgress = YES;
                    [self sharedInstance].connectOnServiceReachabilityCheck = YES;
                    [self sharedInstance].connectOnServiceReachability = NO;

                    shouldAddStateObservation = YES;
                }
            }
        }

        if (![self sharedInstance].shouldConnectOnServiceReachabilityCheck || ![self sharedInstance].shouldConnectOnServiceReachability) {

            // Remove PubNub client from connection state observers list
            [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self oneTimeEvent:YES];
        }


        if (shouldAddStateObservation) {

            // Subscribe and wait for client connection state change notification
            [[self sharedInstance] setClientConnectionObservationWithSuccessBlock:(success ? [success copy] : nil)
                                                                     failureBlock:(failure ? [failure copy] : nil)];
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE CONNECTION (STATE: %d)",
                     [self sharedInstance].state);

               [self postponeConnectWithSuccessBlock:success errorBlock:failure];
           }];
}

+ (void)postponeConnectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                             errorBlock:(PNClientConnectionFailureBlock)failure {
    
    [[self sharedInstance] postponeSelector:@selector(connectWithSuccessBlock:errorBlock:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(success), PNNillIfNotSet(failure)]
                                 outOfOrder:[self sharedInstance].isRestoringConnection];
}

+ (void)disconnect {
    
	[self disconnectByUser:YES];
}

+ (void)disconnectByUser:(BOOL)isDisconnectedByUser {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO DISCONNECT%@ (STATE: %d)",
          isDisconnectedByUser ? @" BY USER RWQUEST." : @" BY INTERNAL REQUEST", [self sharedInstance].state);

    if ([[self sharedInstance].reachability isSuspended]) {

        [[self sharedInstance].reachability resume];
    }
    
    [self performAsyncLockingBlock:^{
        
        BOOL isDisconnectForConfigurationChange = [self sharedInstance].state == PNPubNubClientStateDisconnectingOnConfigurationChange;
        
        // Remove PubNub client from list which help to observe various events
        [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self oneTimeEvent:YES];
        if ([self sharedInstance].state != PNPubNubClientStateDisconnectingOnConfigurationChange) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"DISCONNECTING... (STATE: %d)",
                  [self sharedInstance].state);
            
            [[PNObservationCenter defaultCenter] removeClientAsParticipantsListDownloadObserver];
            [[PNObservationCenter defaultCenter] removeClientAsTimeTokenReceivingObserver];
            [[PNObservationCenter defaultCenter] removeClientAsMessageProcessingObserver];
            [[PNObservationCenter defaultCenter] removeClientAsHistoryDownloadObserver];
            [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
            [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];
            
            [[self sharedInstance].configuration shouldKillDNSCache:NO];
        }
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"DISCONNECTING TO CHANGE CONFIGURATION (STATE: %d)",
                  [self sharedInstance].state);
        }

        // Check whether application has been suspended or not
        if ([self sharedInstance].state == PNPubNubClientStateSuspended || [[self sharedInstance] isResuming]) {

            [self sharedInstance].state = PNPubNubClientStateConnected;
        }
        
        // Check whether client disconnected at this moment (maybe previously was disconnected because connection loss)
        BOOL isDisconnected = ![[self sharedInstance] isConnected];
        
        // Check whether should update state to 'disconnecting'
        if (!isDisconnected) {
            
            // Mark that client is disconnecting from remote PubNub services on user request (or by internal client
            // request when updating configuration)
            [self sharedInstance].state = PNPubNubClientStateDisconnecting;
        }
        
        // Reset client runtime flags and properties
        [self sharedInstance].connectOnServiceReachabilityCheck = NO;
        [self sharedInstance].connectOnServiceReachability = NO;
        [self sharedInstance].restoringConnection = NO;
        
        
        void(^connectionsTerminationBlock)(void) = ^{
            
            [_sharedInstance.messagingChannel terminate];
            [_sharedInstance.serviceChannel terminate];
            _sharedInstance.messagingChannel = nil;
            _sharedInstance.serviceChannel = nil;
        };
        
        if (isDisconnectedByUser) {
            
            [PNConnection resetConnectionsPool];

            connectionsTerminationBlock();

            if ([self sharedInstance].state != PNPubNubClientStateDisconnected) {

                // Mark that client completely disconnected from origin server (synchronous disconnection was made to
                // prevent asynchronous disconnect event from overlapping on connection event)
                [self sharedInstance].state = PNPubNubClientStateDisconnected;
            }

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"DISCONNECTED (BASICALLY TERMINATED, "
                  "BECAUSE REQUEST WAS ISSUED BY USER) (STATE: %d)", [self sharedInstance].state);


            if ([[self sharedInstance].delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {

                [[self sharedInstance].delegate pubnubClient:[self sharedInstance]
                                     didDisconnectFromOrigin:[self sharedInstance].configuration.origin];
            }

            [[self sharedInstance] sendNotification:kPNClientDidDisconnectFromOriginNotification
                                         withObject:[self sharedInstance].configuration.origin];

            PNLog(PNLogDelegateLevel, [self sharedInstance], @" PubNub disconnected from origin: %@)",
                  [self sharedInstance].configuration.origin);


            [[self sharedInstance] handleLockingOperationComplete:YES];
        }
        else {
            
            // Empty connection pool after connection will be closed
            [PNConnection closeAllConnections];
            
            connectionsTerminationBlock();

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"DISCONNECTED (STATE: %d)", [self sharedInstance].state);
        }
        
        
        
        if (isDisconnectForConfigurationChange) {
            
            // Delay connection restore to give some time internal components to complete their tasks
            int64_t delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

                [self sharedInstance].asyncLockingOperationInProgress = NO;
                
                [self sharedInstance].state = PNPubNubClientStateCreated;
                [self sharedInstance].configuration =  [self sharedInstance].temporaryConfiguration;
                [self sharedInstance].temporaryConfiguration = nil;
                
                [[self sharedInstance] prepareCryptoHelper];
                
                
                // Restore connection which will use new configuration
                [self connect];
            });
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE DISCONNECTION (STATE: %d)",
                     [self sharedInstance].state);
               
               [self postponeDisconnectByUser:isDisconnectedByUser];
           }];
}

+ (void)postponeDisconnectByUser:(BOOL)isDisconnectedByUser {
    
	BOOL outOfOrder = [self sharedInstance].state == PNPubNubClientStateDisconnectingOnConfigurationChange;
    
    [[self sharedInstance] postponeSelector:@selector(disconnectByUser:)
                                  forObject:self withParameters:@[@(isDisconnectedByUser)]
                                 outOfOrder:outOfOrder];
}

+ (void)disconnectForConfigurationChange {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO DISCONNECT FOR CONFIGURATION CHANGE (STATE: %d)",
          [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{

        PNLog(PNLogGeneralLevel, [self sharedInstance], @"DISCONNECTING FOR CONFIGURATION CHANGE "
              "(STATE: %d)", [self sharedInstance].state);

        // Mark that client is closing connection because of settings update
        [self sharedInstance].state = PNPubNubClientStateDisconnectingOnConfigurationChange;
        
        
        // Empty connection pool after connection will be closed
        [PNConnection closeAllConnections];
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE DISCONNECTION FOR CONFIGURATION CHANGE "
                     "(STATE: %d)", [self sharedInstance].state);
               
               [self postponeDisconnectForConfigurationChange];
           }];
}

+ (void)postponeDisconnectForConfigurationChange {
    
    [[self sharedInstance] postponeSelector:@selector(disconnectForConfigurationChange)
                                  forObject:self
                             withParameters:nil
                                 outOfOrder:NO];
}


#pragma mark - Client configuration methods

+ (void)setConfiguration:(PNConfiguration *)configuration {
    
    [self setupWithConfiguration:configuration andDelegate:[self sharedInstance].delegate];
}

+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {
    
    // Ensure that configuration is valid before update/set client configuration to it
    if ([configuration isValid]) {
        
        [self setDelegate:delegate];
        
        
        BOOL canUpdateConfiguration = YES;
        
        // Check whether PubNub client is connected to remote PubNub services or not
        if ([[self sharedInstance] isConnected]) {
            
            // Check whether new configuration changed critical properties of client configuration or not
            if([[self sharedInstance].configuration requiresConnectionResetWithConfiguration:configuration]) {
                
                canUpdateConfiguration = NO;
                
                // Store new configuration while client is disconnecting
                [self sharedInstance].temporaryConfiguration = configuration;
                
                
                // Disconnect before client configuration update
                [self disconnectForConfigurationChange];
            }
        }
        
        if (canUpdateConfiguration) {
            
            [self sharedInstance].configuration = configuration;
            
            [[self sharedInstance] prepareCryptoHelper];
        }
        
        
        // Restart reachability monitor
        [[self sharedInstance].reachability startServiceReachabilityMonitoring];
    }
    else {
        
        // Notify delegate about client configuration error
        [[self sharedInstance] notifyDelegateAboutError:[PNError errorWithCode:kPNClientConfigurationError]];
    }
}

+ (void)setDelegate:(id<PNDelegate>)delegate {
    
    [self sharedInstance].delegate = delegate;
}


#pragma mark - Client identification methods

+ (void)setClientIdentifier:(NSString *)identifier {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO UPDATE CLIENT IDENTIFIER (STATE: %d)",
          [self sharedInstance].state);

    [self performAsyncLockingBlock:^{

        PNLog(PNLogGeneralLevel, [self sharedInstance], @"UPDATE CLIENT IDENTIFIER (STATE: %d)",
              [self sharedInstance].state);

        // Check whether identifier has been changed since last method call or not
        if ([[self sharedInstance] isConnected]) {

            // Checking whether new identifier was provided or not
            NSString *clientIdentifier = [self sharedInstance].clientIdentifier;
            if (![clientIdentifier isEqualToString:identifier]) {

                [self sharedInstance].userProvidedClientIdentifier = identifier != nil;


                NSArray *allChannels = [[self sharedInstance].messagingChannel fullSubscribedChannelsList];
                [self unsubscribeFromChannels:allChannels withPresenceEvent:YES
                   andCompletionHandlingBlock:^(NSArray *leavedChannels, PNError *leaveError) {

                       if (leaveError == nil) {

                           // Check whether user identifier was provided by
                           // user or not
                           if (identifier == nil) {

                               // Change user identifier before connect to the
                               // PubNub services
                               [self sharedInstance].clientIdentifier = PNUniqueIdentifier();
                           }
                           else {

                               [self sharedInstance].clientIdentifier = identifier;
                           }

                           [self sharedInstance].asyncLockingOperationInProgress = NO;
                           [self subscribeOnChannels:allChannels
                                   withPresenceEvent:YES
                          andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *subscribedChannels,
                                                       PNError *subscribeError) {

                              [[self sharedInstance] handleLockingOperationComplete:YES];
                          }];
                       }
                       else {

                           [self sharedInstance].asyncLockingOperationInProgress = NO;
                           [self subscribeOnChannels:allChannels withPresenceEvent:NO];
                       }
                   }];
            }
        }
        else {

            [self sharedInstance].clientIdentifier = identifier;
            [self sharedInstance].userProvidedClientIdentifier = identifier != nil;
            [[self sharedInstance] handleLockingOperationComplete:YES];
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE CLIENT IDENTIFIER CHANGE (STATE: %d)",
                     [self sharedInstance].state);

               [self postponeSetClientIdentifier:identifier];
           }];
}

+ (void)postponeSetClientIdentifier:(NSString *)identifier {
    
    [[self sharedInstance] postponeSelector:@selector(setClientIdentifier:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(identifier)]
                                 outOfOrder:NO];
}

+ (NSString *)clientIdentifier {
    
    NSString *identifier = [self sharedInstance].clientIdentifier;
    if (identifier == nil) {
        
        [self sharedInstance].userProvidedClientIdentifier = NO;
    }
    
    
    return [self sharedInstance].clientIdentifier;
}

+ (NSString *)escapedClientIdentifier {
    
    return [[self clientIdentifier] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - Channels subscription management

+ (NSArray *)subscribedChannels {
    
    return [[self sharedInstance].messagingChannel subscribedChannels];
}

+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel {
    
    BOOL isSubscribed = NO;
    
    // Ensure that PubNub client currently connected to remote PubNub services
    if([[self sharedInstance] isConnected]) {
        
        isSubscribed = [[self sharedInstance].messagingChannel isSubscribedForChannel:channel];
    }
    
    
    return isSubscribed;
}

+ (void)subscribeOnChannel:(PNChannel *)channel {
    
    [self subscribeOnChannels:@[channel]];
}

+ (void) subscribeOnChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOnChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent {
    
    [self subscribeOnChannels:@[channel] withPresenceEvent:withPresenceEvent];
}

+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent
andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOnChannels:@[channel] withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels {
    
    [self subscribeOnChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)subscribeOnChannels:(NSArray *)channels
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOnChannels:channels withPresenceEvent:YES andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {
    
    [self subscribeOnChannels:channels withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:nil];
}

+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO SUBSCRIBE ON CHANNELS: %@ (STATE: %d)",
          channels, [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
        [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"SUBSCRIBE ON CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            if (handlerBlock != nil) {
                
                [[PNObservationCenter defaultCenter] addClientAsSubscriptionObserverWithBlock:[handlerBlock copy]];
            }
            
            
            [[self sharedInstance].messagingChannel subscribeOnChannels:channels withPresenceEvent:withPresenceEvent];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T SUBSCRIBE ON CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            PNError *subscriptionError = [PNError errorWithCode:statusCode];
            subscriptionError.associatedObject = channels;
            
            [[self sharedInstance] notifyDelegateAboutSubscriptionFailWithError:subscriptionError];
            
            
            if (handlerBlock) {
                
                handlerBlock(PNSubscriptionProcessNotSubscribedState, channels, subscriptionError);
            }
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE SUBSCRIBE ON CHANNELS (STATE: %d)",
                     [self sharedInstance].state);
               
               [self postponeSubscribeOnChannels:channels
                               withPresenceEvent:withPresenceEvent
                      andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeSubscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent
         andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [[self sharedInstance] postponeSelector:@selector(subscribeOnChannels:withPresenceEvent:andCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(channels), @(withPresenceEvent), PNNillIfNotSet(handlerBlock)]
                                 outOfOrder:NO];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel {
    
    [self unsubscribeFromChannels:@[channel]];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent {
    
    [self unsubscribeFromChannel:channel withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    
    [self unsubscribeFromChannel:channel withPresenceEvent:YES andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent
    andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    
    [self unsubscribeFromChannels:@[channel]
                withPresenceEvent:withPresenceEvent
       andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels {
    
    [self unsubscribeFromChannels:channels withPresenceEvent:YES];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {
    
    [self unsubscribeFromChannels:channels withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    
    [self unsubscribeFromChannels:channels withPresenceEvent:YES andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent
     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO UNSUBSCRIBE FROM CHANNELS: %@ (STATE: %d)",
          channels, [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
        [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"UNSUBSCRIBE FROM CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            if (handlerBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsUnsubscribeObserverWithBlock:[handlerBlock copy]];
            }
            
            
            [[self sharedInstance].messagingChannel unsubscribeFromChannels:channels withPresenceEvent:withPresenceEvent];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T UNSUBSCRIBE FROM CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            PNError *unsubscriptionError = [PNError errorWithCode:statusCode];
            unsubscriptionError.associatedObject = channels;
            
            [[self sharedInstance] notifyDelegateAboutUnsubscriptionFailWithError:unsubscriptionError];
            
            
            if (handlerBlock) {
                
                handlerBlock(channels, unsubscriptionError);
            }
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE UNSUBSCRIBE FROM CHANNELS (STATE: %d)",
                     [self sharedInstance].state);
               
               [self postponeUnsubscribeFromChannels:channels
                                   withPresenceEvent:withPresenceEvent
                          andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeUnsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent
             andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    
    [[self sharedInstance] postponeSelector:@selector(unsubscribeFromChannels:withPresenceEvent:andCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(channels), @(withPresenceEvent), PNNillIfNotSet(handlerBlock)]
                                 outOfOrder:NO];
}


#pragma mark - APNS management

+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken {
    
    [self enablePushNotificationsOnChannel:channel withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {
    
    [self enablePushNotificationsOnChannels:@[channel] withDevicePushToken:pushToken andCompletionHandlingBlock:handlerBlock];
}

+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {
    
    [self enablePushNotificationsOnChannels:channels withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO ENABLE PUSH NOTIFICATIONS ON CHANNELS: %@ (STATE: "
            "%d)", channels, [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnableObserver];
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsDisableObserver];
        
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && pushToken != nil) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"ENABLE PUSH NOTIFICATIONS ON CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            if (handlerBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsEnableObserverWithBlock:[handlerBlock copy]];
            }
            
            PNPushNotificationsStateChangeRequest *request;
            request = [PNPushNotificationsStateChangeRequest reqauestWithDevicePushToken:pushToken
                                                                                 toState:PNPushNotificationsState.enable
                                                                             forChannels:channels];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T ENABLE PUSH NOTIFICATIONS FOR CHANNELS: %@ "
                    "(STATE: %d)", channels, [self sharedInstance].state);
            
            if (pushToken == nil) {
                
                statusCode = kPNDevicePushTokenIsEmptyError;
            }
            PNError *stateChangeError = [PNError errorWithCode:statusCode];
            stateChangeError.associatedObject = channels;
            
            [[self sharedInstance] notifyDelegateAboutPushNotificationsEnableFailedWithError:stateChangeError];
            
            
            if (handlerBlock) {
                
                handlerBlock(channels, stateChangeError);
            }
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE ENABLE PUSH NOTIFICATIONS FOR CHANNELS "
                     "(STATE: %d)", [self sharedInstance].state);
               
               [self postponeEnablePushNotificationsOnChannels:channels
                                           withDevicePushToken:pushToken
                                    andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeEnablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                       andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {
    
    SEL selector = @selector(enablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector
                                  forObject:self
                             withParameters:@[channels, PNNillIfNotSet(pushToken), PNNillIfNotSet(handlerBlock)]
                                 outOfOrder:NO];
}

+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken {
    
    [self disablePushNotificationsOnChannel:channel withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {
    
    [self disablePushNotificationsOnChannels:@[channel] withDevicePushToken:pushToken andCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {
    
    [self disablePushNotificationsOnChannels:channels withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO DISABLE PUSH NOTIFICATIONS ON CHANNELS: %@ (STATE: "
            "%d)", channels, [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnableObserver];
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsDisableObserver];
        
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"DISABLE PUSH NOTIFICATIONS ON CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            if (handlerBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsDisableObserverWithBlock:[handlerBlock copy]];
            }
            
            PNPushNotificationsStateChangeRequest *request;
            request = [PNPushNotificationsStateChangeRequest reqauestWithDevicePushToken:pushToken
                                                                                 toState:PNPushNotificationsState.disable
                                                                             forChannels:channels];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T DISABLE PUSH NOTIFICATIONS FOR CHANNELS: %@ "
                    "(STATE: %d)", channels, [self sharedInstance].state);
            
            PNError *stateChangeError = [PNError errorWithCode:statusCode];
            stateChangeError.associatedObject = channels;
            
            [[self sharedInstance] notifyDelegateAboutPushNotificationsDisableFailedWithError:stateChangeError];
            
            
            if (handlerBlock) {
                
                handlerBlock(channels, stateChangeError);
            }
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE DISABLE PUSH NOTIFICATIONS FOR CHANNELS "
                     "(STATE: %d)", [self sharedInstance].state);
               
               [self postponeDisablePushNotificationsOnChannels:channels
                                            withDevicePushToken:pushToken
                                     andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeDisablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                        andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {
    
    SEL selector = @selector(disablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector
                                  forObject:self
                             withParameters:@[channels, pushToken, PNNillIfNotSet(handlerBlock)]
                                 outOfOrder:NO];
}

+ (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO DISABLE PUSH NOTIFICATIONS FROM ALL CHANNELS (STATE: "
            "%d)", [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsRemoveObserver];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"DISABLE PUSH NOTIFICATIONS FROM ALL CHANNELS (STATE: %d)",
                  [self sharedInstance].state);
            
            if (handlerBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsRemoveObserverWithBlock:[handlerBlock copy]];
            }
            
            [[self sharedInstance] sendRequest:[PNPushNotificationsRemoveRequest requestWithDevicePushToken:pushToken]
                       shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T DISABLE PUSH NOTIFICATIONS FROM ALL CHANNELS "
                    "(STATE: %d)", [self sharedInstance].state);
            
            PNError *removalError = [PNError errorWithCode:statusCode];
            [[self sharedInstance] notifyDelegateAboutPushNotificationsRemoveFailedWithError:removalError];
            
            
            if (handlerBlock) {
                
                handlerBlock(removalError);
            }
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE PUSH NOTIFICATIONS DISABLE FROM ALL "
                       "CHANNELS (STATE: %d)", [self sharedInstance].state);
               
               [self postponeRemoveAllPushNotificationsForDevicePushToken:pushToken
                                              withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeRemoveAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                                 withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {
    
    SEL selector = @selector(removeAllPushNotificationsForDevicePushToken:withCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector
                                  forObject:self
                             withParameters:@[pushToken, PNNillIfNotSet(handlerBlock)]
                                 outOfOrder:NO];
}

+ (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO FETCH PUSH NOTIFICATION ENABLED CHANNELS (STATE: %d)",
          [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnabledChannelsObserver];
        
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"FETCH PUSH NOTIFICATION ENABLED CHANNELS (STATE: %d)",
                  [self sharedInstance].state);
            
            if (handlerBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsEnabledChannelsObserverWithBlock:[handlerBlock copy]];
            }
            
            [[self sharedInstance] sendRequest:[PNPushNotificationsEnabledChannelsRequest requestWithDevicePushToken:pushToken]
                       shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T FETCH PUSH NOTIFICATION ENABLED CHANNELS (STATE: %d)",
                  [self sharedInstance].state);
            
            PNError *listRetrieveError = [PNError errorWithCode:statusCode];
            
            [[self sharedInstance] notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:listRetrieveError];
            
            
            if (handlerBlock) {
                
                handlerBlock(nil, listRetrieveError);
            }
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE PUSH NOTIFICATION ENABLED CHANNELS FETCH "
                     "(STATE: %d)", [self sharedInstance].state);
               
               [self postponeRequestPushNotificationEnabledChannelsForDevicePushToken:pushToken
                                                          withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeRequestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                             withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {
    
    SEL selector = @selector(requestPushNotificationEnabledChannelsForDevicePushToken:withCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector
                                  forObject:self
                             withParameters:@[pushToken, PNNillIfNotSet(handlerBlock)]
                                 outOfOrder:NO];
}


#pragma mark - Presence management

+ (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel {
    
    BOOL observingPresence = NO;
    
    // Ensure that PubNub client currently connected to
    // remote PubNub services
    if ([[self sharedInstance] isConnected]) {
        
        observingPresence = [[self sharedInstance].messagingChannel isPresenceObservationEnabledForChannel:channel];
    }
    
    
    return observingPresence;
}

+ (void)enablePresenceObservationForChannel:(PNChannel *)channel {
    
    [self enablePresenceObservationForChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)enablePresenceObservationForChannel:(PNChannel *)channel
                withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {
    
    [self enablePresenceObservationForChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)enablePresenceObservationForChannels:(NSArray *)channels {
    
    [self enablePresenceObservationForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)enablePresenceObservationForChannels:(NSArray *)channels
                 withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO ENABLE PRESENCE ON CHANNELS: %@ (STATE: %d)",
          channels, [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsPresenceEnabling];
        [[PNObservationCenter defaultCenter] removeClientAsPresenceDisabling];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"ENABLING PRESENCE ON CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            if (handlerBlock != nil) {
                
                [[PNObservationCenter defaultCenter] addClientAsPresenceEnablingObserverWithBlock:[handlerBlock copy]];
            }
            
            // Enumerate over the list of channels and mark that it should observe for presence
            [channels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx, BOOL *channelEnumeratorStop) {
                
                channel.observePresence = YES;
                channel.userDefinedPresenceObservation = YES;
            }];
            
            [[self sharedInstance].messagingChannel enablePresenceObservationForChannels:channels];
        }
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T ENABLE PRESENCE ON CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            PNError *presenceEnableError = [PNError errorWithCode:statusCode];
            presenceEnableError.associatedObject = channels;
            
            
            [[self sharedInstance] notifyDelegateAboutPresenceEnablingFailWithError:presenceEnableError];
            
            if (handlerBlock != nil) {
                
                handlerBlock(channels, presenceEnableError);
            }
        }
        
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE PRESENCE ENABLING ON CHANNELS (STATE: %d)",
                     [self sharedInstance].state);
               
               [self postponeEnablePresenceObservationForChannels:channels
                                      withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeEnablePresenceObservationForChannels:(NSArray *)channels
                         withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {
    
    [[self sharedInstance] postponeSelector:@selector(enablePresenceObservationForChannels:withCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(channels), PNNillIfNotSet(handlerBlock)]
                                 outOfOrder:NO];
}

+ (void)disablePresenceObservationForChannel:(PNChannel *)channel {
    
    [self disablePresenceObservationForChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)disablePresenceObservationForChannel:(PNChannel *)channel
                 withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {
    
    [self disablePresenceObservationForChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePresenceObservationForChannels:(NSArray *)channels {
    
    [self disablePresenceObservationForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)disablePresenceObservationForChannels:(NSArray *)channels
                  withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO DISABLE PRESENCE ON CHANNELS: %@ (STATE: %d)",
          channels, [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsPresenceEnabling];
        [[PNObservationCenter defaultCenter] removeClientAsPresenceDisabling];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"DISABLING PRESENCE ON CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            if (handlerBlock != nil) {
                
                [[PNObservationCenter defaultCenter] addClientAsPresenceDisablingObserverWithBlock:[handlerBlock copy]];
            }
            
            [[self sharedInstance].messagingChannel disablePresenceObservationForChannels:channels];
        }
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T DISABLE PRESENCE ON CHANNELS: %@ (STATE: %d)",
                  channels, [self sharedInstance].state);
            
            PNError *presencedisableError = [PNError errorWithCode:statusCode];
            presencedisableError.associatedObject = channels;
            
            
            [[self sharedInstance] notifyDelegateAboutPresenceDisablingFailWithError:presencedisableError];
            
            if (handlerBlock != nil) {
                
                handlerBlock(channels, presencedisableError);
            }
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE PRESENCE DISABLING ON CHANNELS (STATE: %d)",
                     [self sharedInstance].state);
               
               [self postponeDisablePresenceObservationForChannels:channels
                                       withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeDisablePresenceObservationForChannels:(NSArray *)channels
                          withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {
    
    [[self sharedInstance] postponeSelector:@selector(disablePresenceObservationForChannels:withCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(channels), PNNillIfNotSet(handlerBlock)]
                                 outOfOrder:NO];
}


#pragma mark - Time token

+ (void)requestServerTimeToken {
    
    [self requestServerTimeTokenWithCompletionBlock:nil];
}

+ (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING REQUEST SERVER TIME TOKEN (STATE: %d)",
          [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"REQUEST SERVER TIME TOKEN (STATE: %d)",
                  [self sharedInstance].state);
            
            [[PNObservationCenter defaultCenter] removeClientAsTimeTokenReceivingObserver];
            if (success) {
                [[PNObservationCenter defaultCenter] addClientAsTimeTokenReceivingObserverWithCallbackBlock:[success copy]];
            }
            
            
            [[self sharedInstance] sendRequest:[PNTimeTokenRequest new] shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T REQUEST SERVER TIME TOKEN (STATE: %d)",
                  [self sharedInstance].state);
            
            PNError *timeTokenError = [PNError errorWithCode:statusCode];
            
            [[self sharedInstance] notifyDelegateAboutTimeTokenRetrievalFailWithError:timeTokenError];
            
            
            if (success) {
                
                success(nil, timeTokenError);
            }
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE SERVER TIME TOKEN REQUEST (STATE: %d)",
                     [self sharedInstance].state);
               
               [self postponeRequestServerTimeTokenWithCompletionBlock:(success ? [success copy] : nil)];
           }];
}

+ (void)postponeRequestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success {
    
    [[self sharedInstance] postponeSelector:@selector(requestServerTimeTokenWithCompletionBlock:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(success)]
                                 outOfOrder:NO];
}


#pragma mark - Messages processing methods

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message toChannel:channel withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO SEND MESSAGE: %@ ON CHANNEL: %@ (STATE: %d)",
          message, channel, [self sharedInstance].state);
    
    // Create object instance
    PNError *error = nil;
    PNMessage *messageObject = [PNMessage messageWithObject:message forChannel:channel error:&error];
    
    [self performAsyncLockingBlock:^{
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && error == nil) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"SEND MESSAGE: %@ ON CHANNEL: %@ (STATE: %d)",
                  message, channel, [self sharedInstance].state);
            
            [[PNObservationCenter defaultCenter] removeClientAsMessageProcessingObserver];
            if (success) {
                
                [[PNObservationCenter defaultCenter] addClientAsMessageProcessingObserverWithBlock:[success copy]];
            }
            
            [[self sharedInstance].serviceChannel sendMessage:messageObject];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T SEND MESSAGE: %@ ON CHANNEL: %@ (STATE: %d)",
                  message, channel, [self sharedInstance].state);
            
            PNError *sendingError = error?error:[PNError errorWithCode:statusCode];
            sendingError.associatedObject = messageObject;
            
            [[self sharedInstance] notifyDelegateAboutMessageSendingFailedWithError:sendingError];
            
            
            if (success) {
                
                success(PNMessageSendingError, sendingError);
            }
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE MESSAGE SENDING (STATE: %d)",
                     [self sharedInstance].state);
               
               [self postponeSendMessage:message toChannel:channel withCompletionBlock:(success ? [success copy] : nil)];
           }];
    
    
    return messageObject;
}

+ (void)postponeSendMessage:(id)message toChannel:(PNChannel *)channel
        withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [[self sharedInstance] postponeSelector:@selector(sendMessage:toChannel:withCompletionBlock:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(message), PNNillIfNotSet(channel), PNNillIfNotSet((id)success)]
                                 outOfOrder:NO];
}

+ (void)sendMessage:(PNMessage *)message {
    
    [self sendMessage:message withCompletionBlock:nil];
}

+ (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message.message toChannel:message.channel withCompletionBlock:success];
}


#pragma mark - History methods

+ (void)requestFullHistoryForChannel:(PNChannel *)channel {
    
    [self requestFullHistoryForChannel:channel withCompletionBlock:nil];
}

+ (void)requestFullHistoryForChannel:(PNChannel *)channel
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:nil to:nil withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate {
    
    [self requestHistoryForChannel:channel from:startDate to:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:0 withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                           limit:(NSUInteger)limit {
    
    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
                           limit:(NSUInteger)limit {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                           limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
                           limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel
                              from:startDate
                                to:endDate
                             limit:limit
                    reverseHistory:NO
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory {
    
    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit reverseHistory:shouldReverseMessageHistory];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory {
    
    [self requestHistoryForChannel:channel
                              from:startDate
                                to:endDate
                             limit:limit
                    reverseHistory:shouldReverseMessageHistory
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel
                              from:startDate
                                to:nil
                             limit:limit
                    reverseHistory:shouldReverseMessageHistory
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO REQUEST HISTORY FOR CHANNEL: %@ (STATE: %d)",
          channel, [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"REQUEST HISTORY FOR CHANNEL: %@ (STATE: %d)",
                  channel, [self sharedInstance].state);
            
            [[PNObservationCenter defaultCenter] removeClientAsHistoryDownloadObserver];
            if (handleBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsHistoryDownloadObserverWithBlock:[handleBlock copy]];
            }
            
            PNMessageHistoryRequest *request = [PNMessageHistoryRequest messageHistoryRequestForChannel:channel
                                                                                                   from:startDate
                                                                                                     to:endDate
                                                                                                  limit:limit
                                                                                         reverseHistory:shouldReverseMessageHistory];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T REQUEST HISTORY FOR CHANNEL: %@ (STATE: %d)",
                  channel, [self sharedInstance].state);
            
            PNError *sendingError = [PNError errorWithCode:statusCode];
            sendingError.associatedObject = channel;
            
            [[self sharedInstance] notifyDelegateAboutHistoryDownloadFailedWithError:sendingError];
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE HISTORY REQUEST FOR CHANNEL: %@ (STATE: %d)",
                     channel, [self sharedInstance].state);

               [self postponeRequestHistoryForChannel:channel from:startDate to:endDate limit:limit
                                       reverseHistory:shouldReverseMessageHistory
                                  withCompletionBlock:(handleBlock ? [handleBlock copy] : nil)];
           }];
}

+ (void)postponeRequestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                                   limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory
                     withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [[self sharedInstance] postponeSelector:@selector(requestHistoryForChannel:from:to:limit:reverseHistory:withCompletionBlock:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(channel),
                                              PNNillIfNotSet(startDate),
                                              PNNillIfNotSet(endDate),
                                              @(limit),
                                              @(shouldReverseMessageHistory),
                                              PNNillIfNotSet(handleBlock)]
                                 outOfOrder:NO];
}


#pragma mark - Participant methods

+ (void)requestParticipantsListForChannel:(PNChannel *)channel {
    
    [self requestParticipantsListForChannel:channel withCompletionBlock:nil];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO REQUEST PARTICIPANTS LIST FOR CHANNEL: %@ (STATE: %d)",
          channel, [self sharedInstance].state);
    
    [self performAsyncLockingBlock:^{
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"REQUEST PARTICIPANTS LIST FOR CHANNEL: %@ (STATE: %d)",
                  channel, [self sharedInstance].state);
            
            [[PNObservationCenter defaultCenter] removeClientAsParticipantsListDownloadObserver];
            if (handleBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsParticipantsListDownloadObserverWithBlock:[handleBlock copy]];
            }
            
            
            PNHereNowRequest *request = [PNHereNowRequest whoNowRequestForChannel:channel];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            PNLog(PNLogGeneralLevel, [self sharedInstance], @"CAN'T REQUEST PARTICIPANTS LIST FOR CHANNEL: %@ "
                  "(STATE: %d)", channel, [self sharedInstance].state);
            
            PNError *sendingError = [PNError errorWithCode:statusCode];
            sendingError.associatedObject = channel;
            
            [[self sharedInstance] notifyDelegateAboutParticipantsListDownloadFailedWithError:sendingError];
        }
    }
           postponedExecutionBlock:^{

               PNLog(PNLogGeneralLevel, [self sharedInstance], @"POSTPONE PARTICIPANTS LIST REQUEST FOR CHANNEL  "
                     "(STATE: %d)", [self sharedInstance].state);
               
               [self postponeRequestParticipantsListForChannel:channel
                                           withCompletionBlock:(handleBlock ? [handleBlock copy] : nil)];
           }];
}

+ (void)postponeRequestParticipantsListForChannel:(PNChannel *)channel
                              withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [[self sharedInstance] postponeSelector:@selector(requestParticipantsListForChannel:withCompletionBlock:)
                                  forObject:self
                             withParameters:@[PNNillIfNotSet(channel), PNNillIfNotSet(handleBlock)]
                                 outOfOrder:NO];
}


#pragma mark - Misc methods

+ (void)performAsyncLockingBlock:(void(^)(void))codeBlock postponedExecutionBlock:(void(^)(void))postponedCodeBlock {
    
    // Checking whether code can be executed right now or should be postponed
    if ([[self sharedInstance] shouldPostponeMethodCall]) {

        if (postponedCodeBlock) {
            
            postponedCodeBlock();
        }
    }
    else {

        if (codeBlock) {
            
            [self sharedInstance].asyncLockingOperationInProgress = YES;
            
            codeBlock();
        }
    }
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        self.state = PNPubNubClientStateCreated;
        self.launchSessionIdentifier = PNUniqueIdentifier();
        self.reachability = [PNReachability serviceReachability];
        pendingInvocations = [NSMutableArray array];
        
        // Adding PubNub services availability observer
        __block __pn_desired_weak PubNub *weakSelf = self;
        self.reachability.reachabilityChangeHandleBlock = ^(BOOL connected) {
            
            PNLog(PNLogGeneralLevel, weakSelf, @"IS CONNECTED? %@ (STATE: %i)", connected?@"YES":@"NO", weakSelf.state);

            if (weakSelf.shouldConnectOnServiceReachabilityCheck) {

                PNLog(PNLogGeneralLevel, weakSelf, @"CLIENT SHOULD TRY CONNECT ON SERVICE REACHABILITY CHECK (STATE:"
                      " %d)", weakSelf.state);
                
                weakSelf.connectOnServiceReachabilityCheck = NO;
                if (connected) {

                    PNLog(PNLogGeneralLevel, weakSelf, @"INTERNET CONNECITON AVAILABLE. TRY TO CONNECT (STATE: %d)",
                          weakSelf.state);

                    weakSelf.asyncLockingOperationInProgress = NO;
                    
                    [[weakSelf class] connect];
                }
                else {

                    PNLog(PNLogGeneralLevel, weakSelf, @"INTERNET CONNECITON NOT AVAILABLE. REPORT ERROR (STATE: %d)",
                          weakSelf.state);

                    weakSelf.connectOnServiceReachability = YES;
                    [weakSelf handleConnectionErrorOnNetworkFailure];
                    weakSelf.asyncLockingOperationInProgress = YES;
                }
            }
            else {
                
                if (connected) {

                    PNLog(PNLogGeneralLevel, weakSelf, @"INTERNET CONNECITON AVAILABLE (STATE: %d)", weakSelf.state);
                    
                    // In case if client is in 'disconnecting on network error' state when connection become available
                    // force client to change it state to "completed" stage of disconnection on network error
                    if (weakSelf.state == PNPubNubClientStateDisconnectingOnNetworkError) {

                        PNLog(PNLogGeneralLevel, weakSelf, @"DISCONNECTED ON ERROR (STATE: %d)", weakSelf.state);
                        
                        weakSelf.state = PNPubNubClientStateDisconnectedOnNetworkError;
                    }


                    // Check whether connection available message appeared while library tried to connect
                    // (to handle situation when library doesn't have enough time to accept callbacks and reset it
                    // state to 'disconnected'
                    if (weakSelf.state == PNPubNubClientStateConnecting) {

                        PNLog(PNLogGeneralLevel, weakSelf, @"LIBRARY OUT OF SYNC. CONNECTION STATE IS IMPOSSIBLE IF "
                              "'NETWORK AVAILABLE' ARRIVE (STATE: %d)", weakSelf.state);

                        // Because all connection channels will be destroyed, it means that client currently disconnected
                        weakSelf.state = PNPubNubClientStateDisconnectedOnNetworkError;

                        [_sharedInstance.messagingChannel disconnectWithReset:NO];
                        [_sharedInstance.serviceChannel disconnect];
                        _sharedInstance.messagingChannel = nil;
                        _sharedInstance.serviceChannel = nil;
                    }

                    BOOL isSuspended = weakSelf.state == PNPubNubClientStateSuspended;

                    if (weakSelf.state == PNPubNubClientStateDisconnectedOnNetworkError ||
                        weakSelf.shouldConnectOnServiceReachability || isSuspended) {
                        
                        // Check whether should restore connection or not
                        if([weakSelf shouldRestoreConnection] || weakSelf.shouldConnectOnServiceReachability) {

                            weakSelf.asyncLockingOperationInProgress = NO;
                            if(!weakSelf.shouldConnectOnServiceReachability){

                                PNLog(PNLogGeneralLevel, weakSelf, @"SHOULD RESTORE CONNECTION (STATE: %d)",
                                      weakSelf.state);
                                
                                weakSelf.restoringConnection = YES;
                            }

                            if (isSuspended) {

                                PNLog(PNLogGeneralLevel, weakSelf, @"SHOULD RESUME CONNECTION (STATE: %d)",
                                      weakSelf.state);

                                weakSelf.state = PNPubNubClientStateConnected;

                                weakSelf.restoringConnection = NO;
                                [weakSelf.messagingChannel resume];
                                [weakSelf.serviceChannel resume];
                            }
                            else {

                                PNLog(PNLogGeneralLevel, weakSelf, @"SHOULD CONNECT (STATE: %d)",
                                      weakSelf.state);

                                [[weakSelf class] connect];
                            }
                        }
                    }
                }
                else {

                    PNLog(PNLogGeneralLevel, weakSelf, @"INTERNET CONNECITON NOT AVAILABLE (STATE: %d)",
                          weakSelf.state);
                    
                    // Check whether PubNub client was connected or connecting right now
                    if (weakSelf.state == PNPubNubClientStateConnected || weakSelf.state == PNPubNubClientStateConnecting) {
                        
                        if (weakSelf.state == PNPubNubClientStateConnecting) {

                            PNLog(PNLogGeneralLevel, weakSelf, @"CLIENT TRIED TO CONNECT (STATE: %d)",
                                  weakSelf.state);

                            weakSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;
                            [_sharedInstance.messagingChannel disconnectWithReset:NO];
                            [_sharedInstance.serviceChannel disconnect];

                            [weakSelf handleConnectionErrorOnNetworkFailure];
                        }
                        else {

                            PNLog(PNLogGeneralLevel, weakSelf, @"CLIENT WAS CONNECTED (STATE: %d)",
                                  weakSelf.state);


                            if (![weakSelf shouldRestoreConnection]) {

                                PNLog(PNLogGeneralLevel, weakSelf, @"AUTO CONNECTION TURNED OFF (STATE: %d)",
                                      weakSelf.state);

                                PNError *connectionError = [PNError errorWithCode:kPNClientConnectionClosedOnInternetFailureError];
                                [weakSelf notifyDelegateClientWillDisconnectWithError:connectionError];
                            }
                            else {

                                PNLog(PNLogGeneralLevel, weakSelf, @"CLIENT WILL CONNECT AS SOON AS INTERNET BECOME "
                                        "AVAILABLE (STATE: %d)", weakSelf.state);
                            }
                            
                            weakSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;
                            
                            // Disconnect communication channels because of network issues
                            [weakSelf.messagingChannel disconnectWithReset:NO];
                            [weakSelf.serviceChannel disconnect];
                        }
                    }
                }
            }
        };

        [self subscribeForNotifications];
    }
    
    
    return self;
}


#pragma mark - Client connection management methods

- (BOOL)isConnected {
    
    return self.state == PNPubNubClientStateConnected;
}

- (void)setClientConnectionObservationWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                                          failureBlock:(PNClientConnectionFailureBlock)failure {
    
    // Check whether at least one of blocks has been provided and whether
    // PubNub client already subscribed on state change event or not
    if(![[PNObservationCenter defaultCenter] isSubscribedOnClientStateChange:self] && (success || failure)) {
        
        // Subscribing PubNub client for connection state observation
        // (as soon as event will occur PubNub client will be removed
        // from observers list)
        __pn_desired_weak __typeof__(self) weakSelf = self;
        [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:weakSelf
                                                                 oneTimeEvent:YES
                                                            withCallbackBlock:[^(NSString *origin,
                                                                                 BOOL connected,
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
        } copy]];
    }
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

- (void)sendRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing {
    
    BOOL shouldSendOnMessageChannel = YES;
    
    
    // Checking whether request should be sent on service
    // connection channel or not
    if ([request isKindOfClass:[PNLeaveRequest class]] ||
        [request isKindOfClass:[PNTimeTokenRequest class]] ||
        [request isKindOfClass:[PNMessageHistoryRequest class]] ||
        [request isKindOfClass:[PNHereNowRequest class]] ||
        [request isKindOfClass:[PNLatencyMeasureRequest class]] ||
        [request isKindOfClass:[PNPushNotificationsStateChangeRequest class]] ||
        [request isKindOfClass:[PNPushNotificationsEnabledChannelsRequest class]] ||
        [request isKindOfClass:[PNPushNotificationsRemoveRequest class]]) {
        
        shouldSendOnMessageChannel = NO;
    }
    
    
    [self     sendRequest:request
                onChannel:(shouldSendOnMessageChannel ? self.messagingChannel : self.serviceChannel)
  shouldObserveProcessing:shouldObserveProcessing];
}

- (void)      sendRequest:(PNBaseRequest *)request
                onChannel:(PNConnectionChannel *)channel
  shouldObserveProcessing:(BOOL)shouldObserveProcessing {
    
    [channel scheduleRequest:request shouldObserveProcessing:shouldObserveProcessing];
}


#pragma mark - Connection channel delegate methods

- (void)connectionChannelConfigurationDidFail:(PNConnectionChannel *)channel {

    [[self class] disconnectByUser:NO];
}

- (void)connectionChannel:(PNConnectionChannel *)channel didConnectToHost:(NSString *)host {

    PNLog(PNLogGeneralLevel, self, @"CHANNEL CONNECTED: %@ (STATE: %d)", channel, self.state);

    BOOL isChannelsConnected = [self.messagingChannel isConnected] && [self.serviceChannel isConnected];
    BOOL isCorrectRemoteHost = [self.configuration.origin isEqualToString:host];
    
    // Check whether all communication channels connected and whether client in corresponding state or not
    if (isChannelsConnected && isCorrectRemoteHost && self.state == PNPubNubClientStateConnecting) {

        PNLog(PNLogGeneralLevel, self, @"BOTH CHANNELS CONNECTED TO THE ORIGIN: %@ (STATE: %d)", host, self.state);
        
        self.connectOnServiceReachabilityCheck = NO;
        self.connectOnServiceReachability = NO;
        
        // Mark that PubNub client established connection to PubNub
        // services
        self.state = PNPubNubClientStateConnected;
        
        
        [self warmUpConnections];
        
        [self notifyDelegateAboutConnectionToOrigin:host];
        
        if (!self.isRestoringConnection) {
            
            [self handleLockingOperationComplete:YES];
        }
        
        self.restoringConnection = NO;
    }
}

- (void)connectionChannel:(PNConnectionChannel *)channel didReconnectToHost:(NSString *)host {

    PNLog(PNLogGeneralLevel, self, @"CHANNEL RECONNECTED: %@ (STATE: %d)", channel, self.state);
    
    // Check whether received event from same host on which client is configured or not and client connected at this
    // moment
    if ([self.configuration.origin isEqualToString:host] && self.state == PNPubNubClientStateConnected) {
        
        [self warmUpConnection:channel];
    }
}

- (void)  connectionChannel:(PNConnectionChannel *)channel connectionDidFailToOrigin:(NSString *)host
                  withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"CHANNEL FAILED TO CONNECT: %@ (STATE: %d)", channel, self.state);
    
    // Check whether client in corresponding state and all communication channels not connected to the server
    if(self.state == PNPubNubClientStateConnecting && [self.configuration.origin isEqualToString:host] &&
       ![self.messagingChannel isConnected] && ![self.serviceChannel isConnected]) {

        PNLog(PNLogGeneralLevel, self, @"CLIENT FAILED TO CONNECT TO ORIGIN: %@ (STATE: %d)", host, self.state);
        
        self.connectOnServiceReachabilityCheck = NO;
        self.connectOnServiceReachability = NO;
        
        
        [self.configuration shouldKillDNSCache:YES];
        
        // Send notification to all who is interested in it (observation center will track it as well)
        [self notifyDelegateClientConnectionFailedWithError:error];
    }
}

- (void)connectionChannel:(PNConnectionChannel *)channel didDisconnectFromOrigin:(NSString *)host {

    PNLog(PNLogGeneralLevel, self, @"CHANNEL DISCONNECTED: %@ (STATE: %d)", channel, self.state);
    
    // Check whether host name arrived or not (it may not arrive if event sending instance was dismissed/deallocated)
    if (host == nil) {
        
        host = self.configuration.origin;
    }

    BOOL isForceClosingSecondChannel = NO;
    if (self.state != PNPubNubClientStateDisconnecting) {

        self.state = PNPubNubClientStateDisconnectingOnNetworkError;
        if ([channel isEqual:self.messagingChannel] &&
            (![self.serviceChannel isDisconnected] || [self.serviceChannel isConnected])) {

            PNLog(PNLogGeneralLevel, self, @"DISCONNECTING SERVICE CONNECTION CHANNEL: %@ (STATE: %d)",
                  channel, self.state);

            isForceClosingSecondChannel = YES;
            [self.serviceChannel disconnect];
        }
        else if ([channel isEqual:self.serviceChannel] &&
                 (![self.messagingChannel isDisconnected] || [self.messagingChannel isConnected])) {

            PNLog(PNLogGeneralLevel, self, @"DISCONNECTING MESSAGING CONNECTION CHANNEL: %@ (STATE: %d)",
                  channel, self.state);

            isForceClosingSecondChannel = YES;
            [self.messagingChannel disconnectWithReset:NO];
        }
    }

    
    // Check whether received event from same host on which client is configured or not and all communication
    // channels are closed
    if(!isForceClosingSecondChannel && [self.configuration.origin isEqualToString:host] &&
       ![self.messagingChannel isConnected] && ![self.serviceChannel isConnected]  &&
       self.state != PNPubNubClientStateDisconnected && self.state != PNPubNubClientStateDisconnectedOnNetworkError) {

        PNLog(PNLogGeneralLevel, self, @"CLIENT DISCONNECTED FROM ORIGIN: %@ (STATE: %d)", host, self.state);
        
        // Check whether all communication channels disconnected and whether client in corresponding state or not
        if (self.state == PNPubNubClientStateDisconnecting ||
            self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
            channel == nil) {
            
            PNError *connectionError;
            PNPubNubClientState state = PNPubNubClientStateDisconnected;
            if (self.state == PNPubNubClientStateDisconnectingOnNetworkError) {
                
                state = PNPubNubClientStateDisconnectedOnNetworkError;
                connectionError = [PNError errorWithCode:kPNClientConnectionClosedOnInternetFailureError];
            }
            self.state = state;
            
            
            // Check whether error is caused by network error or not
            switch (connectionError.code) {
                case kPNClientConnectionFailedOnInternetFailureError:
                case kPNClientConnectionClosedOnInternetFailureError:
                    
                    // Try to refresh reachability state (there is situation when reachability state changed within
                    // library to handle sockets timeout/error)
                    [self.reachability refreshReachabilityState];
                    break;
                    
                default:
                    break;
            }
            
            
            if(state == PNPubNubClientStateDisconnected) {
                
                // Clean up cached data
                [PNChannel purgeChannelsCache];

                // Delay disconnection notification to give client ability to perform clean up well
                __block __pn_desired_weak __typeof__(self) weakSelf = self;
                void(^disconnectionNotifyBlock)(void) = ^{

                    if ([weakSelf.delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {

                        [weakSelf.delegate pubnubClient:weakSelf didDisconnectFromOrigin:host];
                    }
                    PNLog(PNLogDelegateLevel, weakSelf, @" PubNub client disconnected from PubNub origin at: %@",
                          host);


                    [weakSelf sendNotification:kPNClientDidDisconnectFromOriginNotification withObject:host];
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

                            if ([weakSelf.delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:withError:)]) {

                                [weakSelf.delegate pubnubClient:weakSelf didDisconnectFromOrigin:host withError:connectionError];
                            }
                            PNLog(PNLogDelegateLevel, weakSelf, @" PubNub client closed connection because of error: "
                                    "%@", connectionError);


                            [weakSelf sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:connectionError];
                        }
                                                    shouldStartNext:YES];
                    }
                };

                // Check whether service is available (this event may arrive after device was unlocked so basically
                // connection is available and only sockets closed by remote server or internal kernel layer)
                if ([self.reachability isServiceReachabilityChecked]) {

                    [self.reachability refreshReachabilityState];

                    if ([self.reachability isServiceAvailable]) {
                        
                        // Check whether should restore connection or not
                        if ([self shouldRestoreConnection]) {

                            PNLog(PNLogGeneralLevel, self, @"CLIENT SHOULD RESTORE CONNECTION (STATE: %d)", self.state);

                            self.asyncLockingOperationInProgress = NO;
                            self.restoringConnection = YES;
                            
                            // Try to restore connection to remote PubNub services
                            [[self class] connect];
                        }
                        else {

                            PNLog(PNLogGeneralLevel, self, @"DESTROY COMPONENTS (STATE: %d)", self.state);

                            disconnectionNotifyBlock();
                        }
                    }
                    // In case if there is no connection check whether clint should restore connection or not.
                    else if(![self shouldRestoreConnection]) {

                        PNLog(PNLogGeneralLevel, self, @"DESTROY COMPONENTS (STATE: %d)", self.state);
                        
                        self.state = PNPubNubClientStateDisconnected;
                        disconnectionNotifyBlock();
                    }
                    else if ([self shouldRestoreConnection]) {

                        PNLog(PNLogGeneralLevel, self, @"CONNECTION WILL BE RESTORED AS SOON AS INTERNET CONNECTION "
                              "WILL GO UP (STATE: %d)", self.state);
                    }
                }
            }
        }
        // Check whether server unexpectedly closed connection while client was active or not
        else if(self.state == PNPubNubClientStateConnected) {
            
            self.state = PNPubNubClientStateDisconnected;
            
            if([self shouldRestoreConnection]) {

                PNLog(PNLogGeneralLevel, self, @"CLIENT SHOULD RESTORE CONNECTION (STATE: %d)", self.state);

                self.asyncLockingOperationInProgress = NO;
                self.restoringConnection = YES;
                
                // Try to restore connection to remote PubNub services
                [[self class] connect];
            }
        }
        // Check whether connection has been closed because PubNub client updates it's configuration
        else if (self.state == PNPubNubClientStateDisconnectingOnConfigurationChange) {

            self.asyncLockingOperationInProgress = NO;
            
            // Close connection to PubNub services
            [[self class] disconnectByUser:NO];
        }
    }
}

- (void) connectionChannel:(PNConnectionChannel *)channel willDisconnectFromOrigin:(NSString *)host
                 withError:(PNError *)error {
    
    if (self.state == PNPubNubClientStateConnected && [self.configuration.origin isEqualToString:host]) {

        self.state = PNPubNubClientStateDisconnecting;
        BOOL disconnectedOnNetworkError = ![self.reachability isServiceAvailable];
        if(!disconnectedOnNetworkError) {
            
            disconnectedOnNetworkError = error.code == kPNRequestExecutionFailedOnInternetFailureError;
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
}


- (void)connectionChannelWillSuspend:(PNConnectionChannel *)channel {

    //
}

- (void)connectionChannelDidSuspend:(PNConnectionChannel *)channel {

    //
}

- (void)connectionChannelWillResume:(PNConnectionChannel *)channel {

    //
}

- (void)connectionChannelDidResume:(PNConnectionChannel *)channel {

    [self warmUpConnection:channel];
}

- (BOOL)connectionChannelCanConnect:(PNConnectionChannel *)channel {

    // Help reachability instance update it's state our of schedule
    [self.reachability refreshReachabilityState];


    return [self.reachability isServiceAvailable];
}

- (BOOL)connectionChannelShouldRestoreConnection:(PNConnectionChannel *)channel {

    // Help reachability instance update it's state our of schedule
    [self.reachability refreshReachabilityState];

    BOOL shouldRestoreConnection = self.state == PNPubNubClientStateConnecting ||
                                   self.state == PNPubNubClientStateConnected ||
                                   self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
                                   self.state == PNPubNubClientStateDisconnectedOnNetworkError;

    // Ensure that there is connection available as well as permission to connect
    shouldRestoreConnection = shouldRestoreConnection && [self.reachability isServiceAvailable];


    return shouldRestoreConnection;
}


#pragma mark - Handler methods

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)handleApplicationDidEnterBackgroundState:(NSNotification *)__unused notification {

    PNLog(PNLogGeneralLevel, self, @"HANDLE APPLICATION ENTERED BACKGROUND");

    BOOL canRunInBackground = [self canRunInBackground];
    if (!canRunInBackground) {

        // Check whether application connected or not
        if ([self isConnected]) {

            PNLog(PNLogGeneralLevel, self, @"SUSPENDING...");


            self.state = PNPubNubClientStateSuspended;

            self.asyncLockingOperationInProgress = NO;
            [self.messagingChannel suspend];
            [self.serviceChannel suspend];
        }
    }
}

- (void)handleApplicationDidEnterForegroundState:(NSNotification *)__unused notification  {

    PNLog(PNLogGeneralLevel, self, @"HANDLE APPLICATION ENTERED FOREGROUND");

    [self.reachability refreshReachabilityState];

    if ([self.reachability isServiceAvailable]) {

        // Check whether application is suspended
        if (self.state == PNPubNubClientStateSuspended) {

            PNLog(PNLogGeneralLevel, self, @"RESUMING...");

            self.state = PNPubNubClientStateConnected;

            self.asyncLockingOperationInProgress = NO;
            [self.messagingChannel resume];
            [self.serviceChannel resume];
        }
    }
}
#else
- (void)handleWorkspaceWillSleep:(NSNotification *)notification {

    PNLog(PNLogGeneralLevel, self, @"HANDLE WORKSPACE SLEEP");
    [self.reachability suspend];

        // Check whether application connected or not
        if ([self isConnected]) {

            PNLog(PNLogGeneralLevel, self, @"SUSPENDING...");

            self.state = PNPubNubClientStateSuspended;

            self.asyncLockingOperationInProgress = NO;
            [self.messagingChannel suspend];
            [self.serviceChannel suspend];
        }
}

- (void)handleWorkspaceDidWake:(NSNotification *)notification {

    PNLog(PNLogGeneralLevel, self, @"HANDLE WORKSPACE WAKE");

    [self.reachability refreshReachabilityState];

    if ([self.reachability isServiceAvailable]) {

        // Check whether application is suspended
        if (self.state == PNPubNubClientStateSuspended) {

            PNLog(PNLogGeneralLevel, self, @"RESUMING...");

            self.state = PNPubNubClientStateConnected;

            self.asyncLockingOperationInProgress = NO;
            [self.messagingChannel resume];
            [self.serviceChannel resume];
        }
    }
}
#endif

- (void)handleConnectionErrorOnNetworkFailure {

    [self handleConnectionErrorOnNetworkFailureWithError:[PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]];
}

- (void)handleConnectionErrorOnNetworkFailureWithError:(PNError *)error {

    // Check whether client is connecting currently or not
    if (self.state == PNPubNubClientStateConnecting || self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
        self.shouldConnectOnServiceReachability) {

        if (self.state != PNPubNubClientStateDisconnectingOnNetworkError) {

            self.state = PNPubNubClientStateDisconnected;
        }
        [self notifyDelegateClientConnectionFailedWithError:error];
    }
}

- (void)handleLockingOperationComplete:(BOOL)shouldStartNext {
    
    [self handleLockingOperationBlockCompletion:NULL shouldStartNext:shouldStartNext];
}

- (void)handleLockingOperationBlockCompletion:(void(^)(void))operationPostBlock shouldStartNext:(BOOL)shouldStartNext {

    self.asyncLockingOperationInProgress = NO;


    // Perform post completion block
    // INFO: This is done to handle situation when some block may launch locking operation
    //       and this handling block will release another one
    if (operationPostBlock) {

        operationPostBlock();
    }


    if (shouldStartNext && !self.isAsyncLockingOperationInProgress) {

        NSInvocation *methodInvocation = nil;
        if ([pendingInvocations count] > 0) {

            // Retrieve reference on invocation instance at the start of the list
            // (oldest scheduled instance)
            methodInvocation = [pendingInvocations objectAtIndex:0];
            [pendingInvocations removeObjectAtIndex:0];
        }

        if (methodInvocation) {

            [methodInvocation invoke];
        }
    }
}


#pragma mark - Misc methods

- (BOOL)isResuming {

    BOOL isResuming = NO;

    if (self.state == PNPubNubClientStateSuspended) {

        isResuming = [self.messagingChannel isResuming] || [self.serviceChannel isResuming];
    }


    return isResuming;
}

- (void)prepareCryptoHelper {
    
    if ([self.configuration.cipherKey length] > 0) {
        
        PNError *helperInitializationError = nil;
        [[PNCryptoHelper sharedInstance] updateWithConfiguration:self.configuration
                                                       withError:&helperInitializationError];
        if (helperInitializationError != nil) {
            
            PNLog(PNLogGeneralLevel, self, @"[INFO] Crypto helper initialization failed because of error: %@",
                  helperInitializationError);
        }
    }
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

- (BOOL)shouldPostponeMethodCall {
    
    return self.isAsyncLockingOperationInProgress;
}

- (void)postponeSelector:(SEL)calledMethodSelector
               forObject:(id)object
          withParameters:(NSArray *)parameters
              outOfOrder:(BOOL)placeOutOfOrder{
    
    // Initialze variables required to perform postponed method call
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
        }
        else {
            
            if (parameter != nil) {
                
                [methodInvocation setArgument:&parameter atIndex:parameterIndex];
            }
        }
    }];
    methodInvocation.target = object;
    [methodInvocation retainArguments];
    
    
    // Place invocation instance into mending invocations set for future usage
    if (placeOutOfOrder) {
        
        // Placing method invocation at first index, so it will be called as soon
        // as possible
        [pendingInvocations insertObject:methodInvocation atIndex:0];
    }
    else {
        
        [pendingInvocations addObject:methodInvocation];
    }
}

- (void)notifyDelegateAboutConnectionToOrigin:(NSString *)originHostName {
    
    // Check whether delegate able to handle connection completion
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didConnectToOrigin:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:didConnectToOrigin:)
                            withObject:self
                            withObject:self.configuration.origin];
    }
    PNLog(PNLogDelegateLevel, self, @" PubNub client successfully connected to PubNub origin at: %@", originHostName);

    
    [self sendNotification:kPNClientDidConnectToOriginNotification withObject:originHostName];
}

- (void)notifyDelegateAboutResubscribeWillStartOnChannels:(NSArray *)channels {

    if ([channels count] > 0) {

        // Notify delegate that client is about to restore subscription
        // on previously subscribed channels
        if ([self.delegate respondsToSelector:@selector(pubnubClient:willRestoreSubscriptionOnChannels:)]) {

            [self.delegate performSelector:@selector(pubnubClient:willRestoreSubscriptionOnChannels:)
                                withObject:self
                                withObject:channels];
        }
        PNLog(PNLogDelegateLevel, self, @" PubNub client resuming subscription on: %@", channels);


        [self sendNotification:kPNClientSubscriptionWillRestoreNotification withObject:channels];
    }
}

- (void)notifyDelegateAboutSubscriptionFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO SUBSCRIBE (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle subscription error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:subscriptionDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:subscriptionDidFailWithError:)
                                    withObject:self
                                    withObject:(id) error];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to subscribe because of error: %@", error);

            
            [self sendNotification:kPNClientSubscriptionDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutUnsubscriptionFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO UNSUBSCRIBE (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle unsubscription error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)
                                    withObject:self
                                    withObject:(id) error];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to unsubscribe because of error: %@", error);

            
            [self sendNotification:kPNClientUnsubscriptionDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPresenceEnablingFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO ENABLE PRESENCE (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle unsubscription error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:presenceObservationEnablingDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:presenceObservationEnablingDidFailWithError:)
                                    withObject:self
                                    withObject:(id) error];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to enable presence observation because of error: "
                    "%@", error);

            
            [self sendNotification:kPNClientPresenceEnablingDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPresenceDisablingFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO DISABLE PRESENCE (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle unsubscription error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:presenceObservationDisablingDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:presenceObservationDisablingDidFailWithError:)
                                    withObject:self
                                    withObject:(id) error];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to disable presence observation because of error:"
                    " %@", error);

            
            [self sendNotification:kPNClientPresenceDisablingDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsEnableFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO ENABLED PUSH NOTIFICATION ON CHANNEL (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle push notification enabling error
            // or not
            SEL selector = @selector(pubnubClient:pushNotificationEnableDidFailWithError:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:error];
                #pragma clang diagnostic pop
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed push notification enable because of error: %@",
                  error);

            
            [self sendNotification:kPNClientPushNotificationEnableDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsDisableFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO DISABLE PUSH NOTIFICATIONS ON CHANNELS (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle push notification enabling error
            // or not
            SEL selector = @selector(pubnubClient:pushNotificationDisableDidFailWithError:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:error];
                #pragma clang diagnostic pop
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to disable push notifications because of error: "
                    "%@", error);

            
            [self sendNotification:kPNClientPushNotificationDisableDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsRemoveFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO REMOVE REMOVE PUSH NOTIFICATIONS FROM ALL CHANNELS (STATE: %d)",
              self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle push notifications removal error
            // or not
            SEL selector = @selector(pubnubClient:pushNotificationsRemoveFromChannelsDidFailWithError:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:error];
                #pragma clang diagnostic pop
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed remove push notifications from channels because "
                    "of error: %@", error);

            
            [self sendNotification:kPNClientPushNotificationRemoveDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO REQUEST PUSH NOTIFICATION ENABLED CHANNELS (STATE: %d)",
              self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle push notifications removal error
            // or not
            SEL selector = @selector(pubnubClient:pushNotificationEnabledChannelsReceiveDidFailWithError:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:error];
                #pragma clang diagnostic pop
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to receive list of channels because of error: "
                    "%@", error);

            
            [self sendNotification:kPNClientPushNotificationChannelsRetrieveDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO RETRIEVE TIME TOKEN (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle time token retrieval
            // error or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)
                                    withObject:self
                                    withObject:error];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to receive time token because of error: %@",
                  error);

            
            [self sendNotification:kPNClientDidFailTimeTokenReceiveNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutMessageSendingFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO SEND MESSAGE (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle message sending error or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailMessageSend:withError:)]) {
                
                [self.delegate pubnubClient:self didFailMessageSend:error.associatedObject withError:error];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to send message '%@' because of error: %@",
                  error.associatedObject, error);

            
            [self sendNotification:kPNClientMessageSendingDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutHistoryDownloadFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO DOWNLOAD HISTORY (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate us able to handle message history download error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailHistoryDownloadForChannel:withError:)]) {
                
                [self.delegate pubnubClient:self didFailHistoryDownloadForChannel:error.associatedObject withError:error];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to download history for %@ because of error: %@",
                  error.associatedObject, error);


            [self sendNotification:kPNClientHistoryDownloadFailedWithErrorNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutParticipantsListDownloadFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"FAILED TO DOWNLOAD PARTICIPANTS LIST (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate us able to handle participants list
            // download error or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailParticipantsListDownloadForChannel:withError:)]) {
                
                [self.delegate   pubnubClient:self
    didFailParticipantsListDownloadForChannel:error.associatedObject
                                    withError:error];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client failed to download participants list for channel %@ "
                    "because of error: %@",
                  error.associatedObject, error);

            
            [self sendNotification:kPNClientParticipantsListDownloadFailedWithErrorNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutError:(PNError *)error {
    
    if ([self.delegate respondsToSelector:@selector(pubnubClient:error:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:error:)
                            withObject:self
                            withObject:error];
    }
    PNLog(PNLogDelegateLevel, self, @" PubNub client report that error occurred: %@", error);

    
    [self sendNotification:kPNClientErrorNotification withObject:error];
}

- (void)notifyDelegateClientWillDisconnectWithError:(PNError *)error {
    
    if ([self.delegate respondsToSelector:@selector(pubnubClient:willDisconnectWithError:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:willDisconnectWithError:)
                            withObject:self
                            withObject:error];
    }
    PNLog(PNLogDelegateLevel, self, @" PubNub clinet will close connection because of error: %@", error);
    
    [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
}

- (void)notifyDelegateClientConnectionFailedWithError:(PNError *)error {
    
    BOOL shouldStartNextPostponedOperation = !self.shouldConnectOnServiceReachability;
    
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self.delegate respondsToSelector:@selector(pubnubClient:connectionDidFailWithError:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:connectionDidFailWithError:)
                                withObject:self
                                withObject:error];
        }
        PNLog(PNLogDelegateLevel, self, @" PubNub client was unable to connect because of error: %@", error);

        
        [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:shouldStartNextPostponedOperation];
}

- (void)sendNotification:(NSString *)notificationName withObject:(id)object {
    
    // Send notification to all who is interested in it
    // (observation center will track it as well)
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:object];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (BOOL)canRunInBackground {

    BOOL canRunInBackground = [UIApplication canRunInBackground];

    if ([self.delegate respondsToSelector:@selector(shouldRunClientInBackground)]) {

        canRunInBackground = [self.delegate shouldRunClientInBackground];
    }


    return canRunInBackground;
}
#endif

- (BOOL)shouldRestoreConnection {
    
    BOOL shouldRestoreConnection = self.configuration.shouldAutoReconnectClient;
    if ([self.delegate respondsToSelector:@selector(shouldReconnectPubNubClient:)]) {
        
        shouldRestoreConnection = [[self.delegate performSelector:@selector(shouldReconnectPubNubClient:)
                                                       withObject:self] boolValue];
    }
    
    
    return shouldRestoreConnection;
}

- (BOOL)shouldRestoreSubscription {
    
    BOOL shouldRestoreSubscription = self.configuration.shouldResubscribeOnConnectionRestore;
    if ([self.delegate respondsToSelector:@selector(shouldResubscribeOnConnectionRestore)]) {
        
        shouldRestoreSubscription = [[self.delegate shouldResubscribeOnConnectionRestore] boolValue];
    }
    
    
    return shouldRestoreSubscription;
}

- (BOOL)shouldNotifyAboutEvent {

    BOOL shouldNotifyAboutEvent = (self.state != PNPubNubClientStateCreated) &&
                                  (self.state != PNPubNubClientStateConnecting) &&
                                  (self.state != PNPubNubClientStateDisconnecting) &&
                                  (self.state != PNPubNubClientStateDisconnected) &&
                                  (self.state != PNPubNubClientStateReset);

    PNLog(PNLogGeneralLevel, self, @"SHOULD NOTIFY DELEGATE? %@ (STATE: %d)", shouldNotifyAboutEvent ? @"YES" : @"NO",
          self.state);

    
    return shouldNotifyAboutEvent;
}

- (BOOL)shouldRestoreSubscriptionWithLastTimeToken {
    
    BOOL shouldRestoreFromLastTimeToken = self.configuration.shouldRestoreSubscriptionFromLastTimeToken;
    if ([self.delegate respondsToSelector:@selector(shouldRestoreSubscriptionFromLastTimeToken)]) {
        
        shouldRestoreFromLastTimeToken = [[self.delegate shouldRestoreSubscriptionFromLastTimeToken] boolValue];
    }
    
    
    return shouldRestoreFromLastTimeToken;
}

- (NSInteger)requestExecutionPossibilityStatusCode {
    
    NSInteger statusCode = 0;
    
    // Check whether client can subscribe for channels or not
    if ([self.reachability isServiceReachabilityChecked] && [self.reachability isServiceAvailable]) {
        
        if (![self isConnected]) {
            
            statusCode = kPNRequestExecutionFailedClientNotReadyError;
        }
    }
    else {
        
        statusCode = kPNRequestExecutionFailedOnInternetFailureError;
    }
    
    
    return statusCode;
}


#pragma mark - Message channel delegate methods

- (BOOL)shouldMessagingChannelRestoreSubscription:(PNMessagingChannel *)messagingChannel {

    return [self shouldRestoreSubscription];
}

- (BOOL)shouldMessagingChannelRestoreWithLastTimeToken:(PNMessagingChannel *)messagingChannel {

    return [self shouldRestoreSubscriptionWithLastTimeToken];
}

- (void)messagingChannelDidReset:(PNMessagingChannel *)messagingChannel {

    [self handleLockingOperationComplete:YES];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willSubscribeOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"WILL SUBSCRIBE ON: %@", channels);

    if ([self isConnected]) {

        self.asyncLockingOperationInProgress = YES;
    }
}

- (void)messagingChannel:(PNMessagingChannel *)channel didSubscribeOnChannels:(NSArray *)channels {

    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"SUBSCRIBED ON CHANNELS (STATE: %d)", self.state);

        if ([self shouldNotifyAboutEvent]) {

            // Check whether delegate can handle subscription on channel or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didSubscribeOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:didSubscribeOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client successfully subscribed on channels: %@", channels);


        	[self sendNotification:kPNClientSubscriptionDidCompleteNotification withObject:channels];
    	}
    }
                                shouldStartNext:YES];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willRestoreSubscriptionOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"WILL RESTORE SUBSCRIPTION ON: %@", channels);

    if ([self isConnected]) {
        
        self.asyncLockingOperationInProgress = YES;
    }

    [self notifyDelegateAboutResubscribeWillStartOnChannels:channels];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didRestoreSubscriptionOnChannels:(NSArray *)channels {

    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"RESTORED SUBSCRIPTION ON CHANNELS (STATE: %d)", self.state);

        if ([self shouldNotifyAboutEvent]) {

            // Check whether delegate can handle subscription restore on channels or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didRestoreSubscriptionOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:didRestoreSubscriptionOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client successfully restored subscription on channels: %@",
                  channels);


            [self sendNotification:kPNClientSubscriptionDidRestoreNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)  messagingChannel:(PNMessagingChannel *)channel
didFailSubscribeOnChannels:(NSArray *)channels
                 withError:(PNError *)error {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutSubscriptionFailWithError:error];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willUnsubscribeFromChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"WILL UNSUBSCRIBE FROM: %@", channels);

    if ([self isConnected]) {

        self.asyncLockingOperationInProgress = YES;
    }
}

- (void)messagingChannel:(PNMessagingChannel *)channel didUnsubscribeFromChannels:(NSArray *)channels {

    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"UNSUBSCRIBED FROM CHANNELS (STATE: %d)", self.state);

        if ([self shouldNotifyAboutEvent]) {

            // Check whether delegate can handle unsubscription event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client successfully unsubscribed from channels: %@", channels);


            [self sendNotification:kPNClientUnsubscriptionDidCompleteNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)    messagingChannel:(PNMessagingChannel *)channel
didFailUnsubscribeOnChannels:(NSArray *)channels
                   withError:(PNError *)error {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutUnsubscriptionFailWithError:error];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willEnablePresenceObservationOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"WILL ENABLE PRESENCE ON: %@", channels);

    if ([self isConnected]) {

        self.asyncLockingOperationInProgress = YES;
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didEnablePresenceObservationOnChannels:(NSArray *)channels {

    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"DID ENABLE PRESENCE ON CHANNELS (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can handle new message arrival or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didEnablePresenceObservationOnChannels:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didEnablePresenceObservationOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client successfully enabled presence observation on channels: "
                    "%@", channels);


            [self sendNotification:kPNClientPresenceEnablingDidCompleteNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)         messagingChannel:(PNMessagingChannel *)messagingChannel
didFailPresenceEnablingOnChannels:(NSArray *)channels
                        withError:(PNError *)error {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutPresenceEnablingFailWithError:error];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willDisablePresenceObservationOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"WILL DISABLE PRESENCE ON: %@", channels);

    if ([self isConnected]) {

        self.asyncLockingOperationInProgress = YES;
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didDisablePresenceObservationOnChannels:(NSArray *)channels {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"DID DISABLE PRESENCE ON CHANNELS (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can handle new message arrival or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didDisablePresenceObservationOnChannels:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didDisablePresenceObservationOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client successfully disabled presence observation on channels: "
                    "%@", channels);

            
            [self sendNotification:kPNClientPresenceDisablingDidCompleteNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)          messagingChannel:(PNMessagingChannel *)messagingChannel
didFailPresenceDisablingOnChannels:(NSArray *)channels
                         withError:(PNError *)error {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutPresenceDisablingFailWithError:error];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"RECEIVED MESSAGE (STATE: %d)", self.state);
    
    if ([self shouldNotifyAboutEvent]) {
        
        // Check whether delegate can handle new message arrival or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessage:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:didReceiveMessage:)
                                withObject:self
                                withObject:message];
        }
        PNLog(PNLogDelegateLevel, self, @" PubNub client received message: %@", message);

        
        [self sendNotification:kPNClientDidReceiveMessageNotification withObject:message];
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveEvent:(PNPresenceEvent *)event {
    
    // Try to update cached channel data
    PNChannel *channel = event.channel;
    if (channel) {
        
        [channel updateWithEvent:event];
    }

    PNLog(PNLogGeneralLevel, self, @"RECEIVED EVENT (STATE: %d)", self.state);
    
    if ([self shouldNotifyAboutEvent]) {
        
        // Check whether delegate can handle presence event arrival or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceivePresenceEvent:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:didReceivePresenceEvent:)
                                withObject:self
                                withObject:event];
        }
        PNLog(PNLogDelegateLevel, self, @" PubNub client received presence event: %@", event);

        
        [self sendNotification:kPNClientDidReceivePresenceEventNotification withObject:event];
    }
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveTimeToken:(NSNumber *)timeToken {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"RECEIVED TIME TOKEN (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can handle time token retrieval or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveTimeToken:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didReceiveTimeToken:)
                                    withObject:self
                                    withObject:timeToken];
            }
            PNLog(PNLogDelegateLevel, self, @"PubNub client recieved time token: %@", timeToken);
            
            
            [self sendNotification:kPNClientDidReceiveTimeTokenNotification withObject:timeToken];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel receiveTimeTokenDidFailWithError:(PNError *)error {
    
    [self notifyDelegateAboutTimeTokenRetrievalFailWithError:error];
}

- (void)serviceChannel:(PNServiceChannel *)channel didEnablePushNotificationsOnChannels:(NSArray *)channels {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"ENABLED PUSH NOTIFICATIONS ON CHANNELS (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle push notification enabled event or not
            SEL selector = @selector(pubnubClient:didEnablePushNotificationsOnChannels:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:channels];
                #pragma clang diagnostic pop
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client enabled push notifications on channels: %@", channels);

            
            [self sendNotification:kPNClientPushNotificationEnableDidCompleteNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)                  serviceChannel:(PNServiceChannel *)channel
didFailPushNotificationEnableForChannels:(NSArray *)channels
                               withError:(PNError *)error {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutPushNotificationsEnableFailedWithError:error];
}

- (void)serviceChannel:(PNServiceChannel *)channel didDisablePushNotificationsOnChannels:(NSArray *)channels {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"DISABLED PUSH NOTIFICATIONS ON CHANNELS (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle push notification disable event or not
            SEL selector = @selector(pubnubClient:didDisablePushNotificationsOnChannels:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:channels];
                #pragma clang diagnostic pop
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client disabled push notifications on channels: %@", channels);

            
            [self sendNotification:kPNClientPushNotificationDisableDidCompleteNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)                   serviceChannel:(PNServiceChannel *)channel
didFailPushNotificationDisableForChannels:(NSArray *)channels
                                withError:(PNError *)error {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutPushNotificationsDisableFailedWithError:error];
}

- (void)serviceChannelDidRemovePushNotifications:(PNServiceChannel *)channel {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"REMOVED PUSH NOTIFICATIONS FROM ALL CHANNELS (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check wheter delegate is able to handle successful push notification removal from
            // all channels or not
            SEL selector = @selector(pubnubClientDidRemovePushNotifications:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self];
                #pragma clang diagnostic pop
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client removed push notifications from all channels");


            [self sendNotification:kPNClientPushNotificationRemoveDidCompleteNotification withObject:nil];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationsRemoveWithError:(PNError *)error {
    
    [self notifyDelegateAboutPushNotificationsRemoveFailedWithError:error];
}

- (void)serviceChannel:(PNServiceChannel *)channel didReceivePushNotificationsEnabledChannels:(NSArray *)channels {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"DID RECEIVE PUSH NOTIFICATINO ENABLED CHANNELS (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle push notification enabled
            // channels retrieval or not
            SEL selector = @selector(pubnubClient:didReceivePushNotificationEnabledChannels:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:channels];
                #pragma clang diagnostic pop
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client received push notificatino enabled channels: %@",
                  channels);

            
            [self sendNotification:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationEnabledChannelsReceiveWithError:(PNError *)error {
    
    [self notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:error];
}

- (void)  serviceChannel:(PNServiceChannel *)channel
didReceiveNetworkLatency:(double)latency
     andNetworkBandwidth:(double)bandwidth {
    
    // TODO: NOTIFY NETWORK METER INSTANCE ABOUT ARRIVED DATA
}

- (void)serviceChannel:(PNServiceChannel *)channel willSendMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"WILL SEND MESSAGE (STATE: %d)", self.state);
    
    if ([self shouldNotifyAboutEvent]) {
        
        // Check whether delegate can handle message sending event or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:willSendMessage:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:willSendMessage:)
                                withObject:self
                                withObject:message];
        }
        PNLog(PNLogDelegateLevel, self, @" PubNub client is about to send message: %@", message);

        
        [self sendNotification:kPNClientWillSendMessageNotification withObject:message];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didSendMessage:(PNMessage *)message {

    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"DID SEND MESSAGE (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can handle message sent event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didSendMessage:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didSendMessage:)
                                    withObject:self
                                    withObject:message];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client sent message: %@", message);

            
            [self sendNotification:kPNClientDidSendMessageNotification withObject:message];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel
    didFailMessageSend:(PNMessage *)message
             withError:(PNError *)error {
    
    error.associatedObject = message;
    [self notifyDelegateAboutMessageSendingFailedWithError:error];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveMessagesHistory:(PNMessagesHistory *)history {
    
    [self handleLockingOperationBlockCompletion:^{

        PNLog(PNLogGeneralLevel, self, @"DID RECEIVE HISTORY ON CHANNEL (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can response on history download event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessageHistory:forChannel:startingFrom:to:)]) {
                
                [self.delegate pubnubClient:self
                   didReceiveMessageHistory:history.messages
                                 forChannel:history.channel
                               startingFrom:history.startDate
                                         to:history.endDate];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client received history for %@ starting from %@ to %@: %@",
                  history.channel, history.startDate, history.endDate, history.messages);

            
            [self sendNotification:kPNClientDidReceiveMessagesHistoryNotification withObject:history];
        }
    }
                                shouldStartNext:YES];
}

- (void)           serviceChannel:(PNServiceChannel *)serviceChannel
  didFailHisoryDownloadForChannel:(PNChannel *)channel
                        withError:(PNError *)error {
    
    error.associatedObject = channel;
    [self notifyDelegateAboutHistoryDownloadFailedWithError:error];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantsList:(PNHereNow *)participants {
    
    [self handleLockingOperationBlockCompletion:^{
        PNLog(PNLogGeneralLevel, self, @"DID RECEIVE PARTICIPANTS LIST (STATE: %d)", self.state);
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can response on participants list download event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveParticipantsList:forChannel:)]) {
                
                [self.delegate pubnubClient:self
                 didReceiveParticipantsList:participants.participants
                                 forChannel:participants.channel];
            }
            PNLog(PNLogDelegateLevel, self, @" PubNub client received participants list for channel %@: %@",
                  participants.participants, participants.channel);

            
            [self sendNotification:kPNClientDidReceiveParticipantsListNotification withObject:participants];
        }
    }
                                shouldStartNext:YES];
}

- (void)               serviceChannel:(PNServiceChannel *)serviceChannel
didFailParticipantsListLoadForChannel:(PNChannel *)channel
                            withError:(PNError *)error {
    
    error.associatedObject = channel;
    [self notifyDelegateAboutParticipantsListDownloadFailedWithError:error];
    
}


#pragma mark - Memory management

- (void)dealloc {
    
    PNLog(PNLogGeneralLevel, self, @"Destroyed");
}

#pragma mark -


@end
