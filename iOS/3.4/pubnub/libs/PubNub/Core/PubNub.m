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
#import "PNObservationCenter+Protected.h"
#import "PNConnectionChannel+Protected.h"
#import "PNConnectionChannelDelegate.h"
#import "PNPresenceEvent+Protected.h"
#import "PNConfiguration+Protected.h"
#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import "UIApplication+PNAdditions.h"
#endif
#import "PNServiceChannelDelegate.h"
#import "PNConnection+Protected.h"
#import "PNHereNow+Protected.h"
#import "PNMessage+Protected.h"
#import "PNChannel+Protected.h"
#import "PNMessagingChannel.h"
#import "PNError+Protected.h"
#import "PNServiceChannel.h"
#import "PNRequestsImport.h"
#import "PNHereNowRequest.h"
#import "PNCryptoHelper.h"


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

+ (void)postponeSubscribeOnChannels:(NSArray *)channels
                  withPresenceEvent:(BOOL)withPresenceEvent
         andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

+ (void)postponeUnsubscribeFromChannels:(NSArray *)channels
                      withPresenceEvent:(BOOL)withPresenceEvent
             andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;


#pragma mark - APNS management

+ (void)postponeEnablePushNotificationsOnChannels:(NSArray *)channels
                              withDevicePushToken:(NSData *)pushToken
                       andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

+ (void)postponeDisablePushNotificationsOnChannels:(NSArray *)channels
                               withDevicePushToken:(NSData *)pushToken
                        andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

+ (void)postponeRemoveAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                                 withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;

+ (void)postponeRequestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                             withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;

#pragma mark - Presence management

+ (void)postponeEnablePresenceObservationForChannels:(NSArray *)channels withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;
+ (void)postponeDisablePresenceObservationForChannels:(NSArray *)channels withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;


#pragma mark - Time token

+ (void)postponeRequestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;


#pragma mark - Messages processing methods

+ (void)postponeSendMessage:(id)message
                  toChannel:(PNChannel *)channel
        withCompletionBlock:(PNClientMessageProcessingBlock)success;


#pragma mark - History methods

+ (void)postponeRequestHistoryForChannel:(PNChannel *)channel
                                    from:(PNDate *)startDate
                                      to:(PNDate *)endDate
                                   limit:(NSUInteger)limit
                          reverseHistory:(BOOL)shouldReverseMessageHistory
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
 * This method allow to schedule initial requests on connections to tell server that we are really
 * interested in persistent connection
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
- (void)    sendRequest:(PNBaseRequest *)request
              onChannel:(PNConnectionChannel *)channel
shouldObserveProcessing:(BOOL)shouldObserveProcessing;


#pragma mark - Handler methods

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)handleApplicationDidEnterBackgroundState:(NSNotification *)notification;
- (void)handleApplicationDidEnterForegroundState:(NSNotification *)notification;
#endif

/**
 * Handling error which occurred while PubNub client tried establish connection and lost internet connection
 */
- (void)handleConnectionErrorOnNetworkFailure;

/**
 * Handle locking operation completion and pop new one from pending invocations list.
 */
- (void)handleLockingOperationComplete:(BOOL)shouldStartNext;
- (void)handleLockingOperationBlockCompletion:(void(^)(void))operationPostBlock shouldStartNext:(BOOL)shouldStartNext;


#pragma mark - Misc methods

/**
 * Will prepare crypto helper it is possible
 */
- (void)prepareCryptoHelper;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
/**
 * Will help to subscribe/unsubscribe on/from all critical application-wide notifications which may affect
 * client operation
 */
- (void)subscribeForNotifications;
- (void)unsubscribeFromNotifications;
#endif


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
    
    // Mark that client is in resetting state, so it won't be affected by
    // callbacks from transport classes
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
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    [_sharedInstance unsubscribeFromNotifications];
#endif
    _sharedInstance = nil;
}


#pragma mark - Client connection management methods

+ (void)connect {
    
    [self connectWithSuccessBlock:nil errorBlock:nil];
}

+ (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                     errorBlock:(PNClientConnectionFailureBlock)failure {

    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#20} TURN ON (%s)", __PRETTY_FUNCTION__);

        __block BOOL shouldAddStateObservation = NO;

        // Check whether instance already connected or not
        if ([self sharedInstance].state == PNPubNubClientStateConnected ||
            [self sharedInstance].state == PNPubNubClientStateConnecting) {

            PNError *connectionError = [PNError errorWithCode:kPNClientTriedConnectWhileConnectedError];
            [[self sharedInstance] notifyDelegateClientConnectionFailedWithError:connectionError];

            if (failure) {

                failure(connectionError);
            }
        }
        else {

            // Check whether client configuration was provided
            // or not
            if ([self sharedInstance].configuration == nil) {

                PNError *connectionError = [PNError errorWithCode:kPNClientConfigurationError];
                [[self sharedInstance] notifyDelegateAboutError:connectionError];


                if (failure) {

                    failure(connectionError);
                }
            }
            else {

                // Check whether user identifier was provided by
                // user or not
                if (![self sharedInstance].isUserProvidedClientIdentifier) {

                    // Change user identifier before connect to the
                    // PubNub services
                    [self sharedInstance].clientIdentifier = PNUniqueIdentifier();
                }

                // Check whether services are available or not
                if ([[self sharedInstance].reachability isServiceReachabilityChecked]) {

                    // Checking whether remote PubNub services is reachable or not
                    // (if they are not reachable, this mean that probably there is no
                    // connection)
                    if ([[self sharedInstance].reachability isServiceAvailable]) {

                        // Notify PubNub delegate about that it will try to
                        // establish connection with remote PubNub origin
                        // (notify if delegate implements this method)
                        if ([[self sharedInstance].delegate respondsToSelector:@selector(pubnubClient:willConnectToOrigin:)]) {

                            [[self sharedInstance].delegate performSelector:@selector(pubnubClient:willConnectToOrigin:)
                                                                 withObject:[self sharedInstance]
                                                                 withObject:[self sharedInstance].configuration.origin];
                        }

                        [[self sharedInstance] sendNotification:kPNClientWillConnectToOriginNotification
                                                     withObject:[self sharedInstance].configuration.origin];


                        // Check whether PubNub client was just created and there
                        // is no resources for reuse or not
                        if ([self sharedInstance].state == PNPubNubClientStateCreated ||
                            [self sharedInstance].state == PNPubNubClientStateDisconnected) {

                            [self sharedInstance].state = PNPubNubClientStateConnecting;

                            // Initialize communication channels
                            [self sharedInstance].messagingChannel = [PNMessagingChannel messageChannelWithDelegate:[self sharedInstance]];
                            [self sharedInstance].messagingChannel.messagingDelegate = [self sharedInstance];
                            [self sharedInstance].serviceChannel = [PNServiceChannel serviceChannelWithDelegate:[self sharedInstance]];
                            [self sharedInstance].serviceChannel.serviceDelegate = [self sharedInstance];
                        }
                        else {

                            [self sharedInstance].state = PNPubNubClientStateConnecting;

                            // Reuse existing communication channels and reconnect
                            // them to remote origin server
                            [[self sharedInstance].messagingChannel connect];
                            [[self sharedInstance].serviceChannel connect];
                        }

                        shouldAddStateObservation = YES;
                    }
                    else {

                        // Mark that client should try to connect when network will be available
                        // again
                        [self sharedInstance].connectOnServiceReachabilityCheck = YES;
                        [self sharedInstance].asyncLockingOperationInProgress = YES;

                        NSLog(@">>>>>> {LOCK}{#1} TURN ON (%s)", __PRETTY_FUNCTION__);
                        [[self sharedInstance] handleConnectionErrorOnNetworkFailure];
                        [self sharedInstance].asyncLockingOperationInProgress = YES;
                        NSLog(@">>>>>> {LOCK}{#2} TURN ON (%s)", __PRETTY_FUNCTION__);

                        if (![[PNObservationCenter defaultCenter] isSubscribedOnClientStateChange:[self sharedInstance]]) {

                            if (failure) {

                                failure([PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]);
                            }
                        }
                    }
                }
                // Looks like reachability manager was unable to check services reachability
                // (user still not configured client or just not enough time to check passed
                // since client configuration)
                else {

                    [self sharedInstance].asyncLockingOperationInProgress = YES;
                    [self sharedInstance].connectOnServiceReachabilityCheck = YES;
                    [self sharedInstance].connectOnServiceReachability = NO;
                    NSLog(@">>>>>> {LOCK}{#3} TURN ON (%s)", __PRETTY_FUNCTION__);

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
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#23} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        BOOL isDisconnectForConfigurationChange = [self sharedInstance].state == PNPubNubClientStateDisconnectingOnConfigurationChange;
        
        // Remove PubNub client from list which help to observe various events
        [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self oneTimeEvent:YES];
        if ([self sharedInstance].state != PNPubNubClientStateDisconnectingOnConfigurationChange) {
            
            [[PNObservationCenter defaultCenter] removeClientAsParticipantsListDownloadObserver];
            [[PNObservationCenter defaultCenter] removeClientAsTimeTokenReceivingObserver];
            [[PNObservationCenter defaultCenter] removeClientAsMessageProcessingObserver];
            [[PNObservationCenter defaultCenter] removeClientAsHistoryDownloadObserver];
            [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
            [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];
            
            [[self sharedInstance].configuration shouldKillDNSCache:NO];
        }
        
        // Check whether client disconnected at this moment (maybe previously was
        // disconnected because connection loss)
        BOOL isDisconnected = ![[self sharedInstance] isConnected];
        
        // Check whether should update state to 'disconnecting'
        if (!isDisconnected) {
            
            // Mark that client is disconnecting from remote PubNub services on
            // user request (or by internal client request when updating configuration)
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

                // Mark that client completely disconnected from origin server
                // (synchronous disconnection was made to prevent asynchronous disconnect event
                // from overlapping on connection event)
                [self sharedInstance].state = PNPubNubClientStateDisconnected;

                [[self sharedInstance] connectionChannel:nil didDisconnectFromOrigin:[self sharedInstance].configuration.origin];
            }
            else {

                NSLog(@">>>>>> {LOCK}{#38} TURN OFF (%s)", __PRETTY_FUNCTION__);
                [[self sharedInstance] handleLockingOperationComplete:YES];
            }
        }
        else {
            
            // Empty connection pool after connection will
            // be closed
            [PNConnection closeAllConnections];
            
            connectionsTerminationBlock();
        }
        
        
        
        if (isDisconnectForConfigurationChange) {
            
            // Delay connection restore to give some time internal
            // components to complete their tasks
            int64_t delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

                [self sharedInstance].asyncLockingOperationInProgress = NO;
                NSLog(@">>>>>> {LOCK}{#4} TURN OFF (%s)", __PRETTY_FUNCTION__);
                
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
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#24} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        // Mark that client is closing connection because of settings update
        [self sharedInstance].state = PNPubNubClientStateDisconnectingOnConfigurationChange;
        
        
        // Empty connection pool after connection will
        // be closed
        [PNConnection closeAllConnections];
    }
           postponedExecutionBlock:^{
               
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
    
    // Ensure that configuration is valid before update/set
    // client configuration to it
    if ([configuration isValid]) {
        
        [self setDelegate:delegate];
        
        
        BOOL canUpdateConfiguration = YES;
        
        // Check whether PubNub client is connected to remote
        // PubNub services or not
        if ([[self sharedInstance] isConnected]) {
            
            // Check whether new configuration changed critical properties
            // of client configuration or not
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

    // Check whether identifier has been changed since last
    // method call or not
    if ([[self sharedInstance] isConnected]) {
        
        // Checking whether new identifier was provided or not
        NSString *clientIdentifier = [self sharedInstance].clientIdentifier;
        if (![clientIdentifier isEqualToString:identifier]) {
            
            [self performAsyncLockingBlock:^{
                NSLog(@">>>>>> {LOCK}{#33} TURN ON (%s)", __PRETTY_FUNCTION__);
                
                [self sharedInstance].userProvidedClientIdentifier = identifier != nil;
                
                
                NSArray *allChannels = [[self sharedInstance].messagingChannel fullSubscribedChannelsList];
                [self unsubscribeFromChannels:allChannels
                            withPresenceEvent:YES
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
                           NSLog(@">>>>>> {LOCK}{#5} TURN OFF (%s)", __PRETTY_FUNCTION__);
                           [self subscribeOnChannels:allChannels
                                   withPresenceEvent:YES
                          andCompletionHandlingBlock:^(PNSubscriptionProcessState state,
                                                       NSArray *subscribedChannels,
                                                       PNError *subscribeError) {

                              NSLog(@">>>>>> {LOCK}{#40} TURN OFF (%s)", __PRETTY_FUNCTION__);
                              [[self sharedInstance] handleLockingOperationComplete:YES];
                          }];
                       }
                       else {

                           [self sharedInstance].asyncLockingOperationInProgress = NO;
                           NSLog(@">>>>>> {LOCK}{#6} TURN OFF (%s)", __PRETTY_FUNCTION__);
                           [self subscribeOnChannels:allChannels withPresenceEvent:NO];
                       }
                   }];
            }
                   postponedExecutionBlock:^{
                       
                       [self postponeSetClientIdentifier:identifier];
                   }];
        }
    }
    else {
        
        [self sharedInstance].clientIdentifier = identifier;
        [self sharedInstance].userProvidedClientIdentifier = identifier != nil;
    }
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
    
    // Ensure that PubNub client currently connected to
    // remote PubNub services
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

+ (void)subscribeOnChannel:(PNChannel *)channel
         withPresenceEvent:(BOOL)withPresenceEvent
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

+ (void)subscribeOnChannels:(NSArray *)channels
          withPresenceEvent:(BOOL)withPresenceEvent
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#34} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
        [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
            if (handlerBlock != nil) {
                
                [[PNObservationCenter defaultCenter] addClientAsSubscriptionObserverWithBlock:[handlerBlock copy]];
            }
            
            
            [[self sharedInstance].messagingChannel subscribeOnChannels:channels withPresenceEvent:withPresenceEvent];
        }
        // Looks like client can't send request because of some reasons
        else {
            
            PNError *subscriptionError = [PNError errorWithCode:statusCode];
            subscriptionError.associatedObject = channels;
            
            [[self sharedInstance] notifyDelegateAboutSubscriptionFailWithError:subscriptionError];
            
            
            if (handlerBlock) {
                
                handlerBlock(PNSubscriptionProcessNotSubscribedState, channels, subscriptionError);
            }
        }
    }
           postponedExecutionBlock:^{
               
               [self postponeSubscribeOnChannels:channels
                               withPresenceEvent:withPresenceEvent
                      andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeSubscribeOnChannels:(NSArray *)channels
                  withPresenceEvent:(BOOL)withPresenceEvent
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

+ (void)unsubscribeFromChannel:(PNChannel *)channel
             withPresenceEvent:(BOOL)withPresenceEvent
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

+ (void)unsubscribeFromChannels:(NSArray *)channels
              withPresenceEvent:(BOOL)withPresenceEvent
     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

        [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#35} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
        [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
            if (handlerBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsUnsubscribeObserverWithBlock:[handlerBlock copy]];
            }
            
            
            [[self sharedInstance].messagingChannel unsubscribeFromChannels:channels withPresenceEvent:withPresenceEvent];
        }
        // Looks like client can't send request because of some reasons
        else {
            
            PNError *unsubscriptionError = [PNError errorWithCode:statusCode];
            unsubscriptionError.associatedObject = channels;
            
            [[self sharedInstance] notifyDelegateAboutUnsubscriptionFailWithError:unsubscriptionError];
            
            
            if (handlerBlock) {
                
                handlerBlock(channels, unsubscriptionError);
            }
        }
    }
           postponedExecutionBlock:^{
               
               [self postponeUnsubscribeFromChannels:channels
                                   withPresenceEvent:withPresenceEvent
                          andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeUnsubscribeFromChannels:(NSArray *)channels
                      withPresenceEvent:(BOOL)withPresenceEvent
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

+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel
                     withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {
    
    [self enablePushNotificationsOnChannels:@[channel] withDevicePushToken:pushToken andCompletionHandlingBlock:handlerBlock];
}

+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {
    
    [self enablePushNotificationsOnChannels:channels withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)enablePushNotificationsOnChannels:(NSArray *)channels
                      withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#26} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnableObserver];
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsDisableObserver];
        
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && pushToken != nil) {
            
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
               
               [self postponeEnablePushNotificationsOnChannels:channels
                                           withDevicePushToken:pushToken
                                    andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeEnablePushNotificationsOnChannels:(NSArray *)channels
                              withDevicePushToken:(NSData *)pushToken
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

+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel
                      withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {
    
    [self disablePushNotificationsOnChannels:@[channel] withDevicePushToken:pushToken andCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {
    
    [self disablePushNotificationsOnChannels:channels withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)disablePushNotificationsOnChannels:(NSArray *)channels
                       withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#22} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnableObserver];
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsDisableObserver];
        
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
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
            
            PNError *stateChangeError = [PNError errorWithCode:statusCode];
            stateChangeError.associatedObject = channels;
            
            [[self sharedInstance] notifyDelegateAboutPushNotificationsDisableFailedWithError:stateChangeError];
            
            
            if (handlerBlock) {
                
                handlerBlock(channels, stateChangeError);
            }
        }
    }
           postponedExecutionBlock:^{
               
               [self postponeDisablePushNotificationsOnChannels:channels
                                            withDevicePushToken:pushToken
                                     andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeDisablePushNotificationsOnChannels:(NSArray *)channels
                               withDevicePushToken:(NSData *)pushToken
                        andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {
    
    SEL selector = @selector(disablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector
                                  forObject:self
                             withParameters:@[channels, pushToken, PNNillIfNotSet(handlerBlock)]
                                 outOfOrder:NO];
}

+ (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#27} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsRemoveObserver];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
            if (handlerBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsRemoveObserverWithBlock:[handlerBlock copy]];
            }
            
            [[self sharedInstance] sendRequest:[PNPushNotificationsRemoveRequest requestWithDevicePushToken:pushToken]
                       shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {
            
            PNError *removalError = [PNError errorWithCode:statusCode];
            [[self sharedInstance] notifyDelegateAboutPushNotificationsRemoveFailedWithError:removalError];
            
            
            if (handlerBlock) {
                
                handlerBlock(removalError);
            }
        }
    }
           postponedExecutionBlock:^{
               
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
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#30} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnabledChannelsObserver];
        
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
            if (handlerBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsEnabledChannelsObserverWithBlock:[handlerBlock copy]];
            }
            
            [[self sharedInstance] sendRequest:[PNPushNotificationsEnabledChannelsRequest requestWithDevicePushToken:pushToken]
                       shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {
            
            PNError *listRetrieveError = [PNError errorWithCode:statusCode];
            
            [[self sharedInstance] notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:listRetrieveError];
            
            
            if (handlerBlock) {
                
                handlerBlock(nil, listRetrieveError);
            }
        }
    }
           postponedExecutionBlock:^{
               
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
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#25} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        [[PNObservationCenter defaultCenter] removeClientAsPresenceEnabling];
        [[PNObservationCenter defaultCenter] removeClientAsPresenceDisabling];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
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
            
            PNError *presenceEnableError = [PNError errorWithCode:statusCode];
            presenceEnableError.associatedObject = channels;
            PNLog(PNLogGeneralLevel, self, @" Presence enabling failed because of error: %@", presenceEnableError);
            
            
            [[self sharedInstance] notifyDelegateAboutPresenceEnablingFailWithError:presenceEnableError];
            
            if (handlerBlock != nil) {
                
                handlerBlock(channels, presenceEnableError);
            }
        }
        
    }
           postponedExecutionBlock:^{
               
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
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#21} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        [[PNObservationCenter defaultCenter] removeClientAsPresenceEnabling];
        [[PNObservationCenter defaultCenter] removeClientAsPresenceDisabling];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
            if (handlerBlock != nil) {
                
                [[PNObservationCenter defaultCenter] addClientAsPresenceDisablingObserverWithBlock:[handlerBlock copy]];
            }
            
            [[self sharedInstance].messagingChannel disablePresenceObservationForChannels:channels];
        }
        else {
            
            PNError *presencedisableError = [PNError errorWithCode:statusCode];
            presencedisableError.associatedObject = channels;
            PNLog(PNLogGeneralLevel, self, @" Presence disabling failed because of error: %@", presencedisableError);
            
            
            [[self sharedInstance] notifyDelegateAboutPresenceDisablingFailWithError:presencedisableError];
            
            if (handlerBlock != nil) {
                
                handlerBlock(channels, presencedisableError);
            }
        }
    }
           postponedExecutionBlock:^{
               
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
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#31} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
            [[PNObservationCenter defaultCenter] removeClientAsTimeTokenReceivingObserver];
            if (success) {
                [[PNObservationCenter defaultCenter] addClientAsTimeTokenReceivingObserverWithCallbackBlock:[success copy]];
            }
            
            
            [[self sharedInstance] sendRequest:[PNTimeTokenRequest new] shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {
            
            PNError *timeTokenError = [PNError errorWithCode:statusCode];
            
            [[self sharedInstance] notifyDelegateAboutTimeTokenRetrievalFailWithError:timeTokenError];
            
            
            if (success) {
                
                success(nil, timeTokenError);
            }
        }
    }
           postponedExecutionBlock:^{
               
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

+ (PNMessage *)sendMessage:(id)message
                 toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    // Create object instance
    PNError *error = nil;
    PNMessage *messageObject = [PNMessage messageWithObject:message forChannel:channel error:&error];
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#32} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && error == nil) {
            
            [[PNObservationCenter defaultCenter] removeClientAsMessageProcessingObserver];
            if (success) {
                
                [[PNObservationCenter defaultCenter] addClientAsMessageProcessingObserverWithBlock:[success copy]];
            }
            
            [[self sharedInstance].serviceChannel sendMessage:messageObject];
        }
        // Looks like client can't send request because of some reasons
        else {
            
            PNError *sendingError = error?error:[PNError errorWithCode:statusCode];
            sendingError.associatedObject = messageObject;
            
            [[self sharedInstance] notifyDelegateAboutMessageSendingFailedWithError:sendingError];
            
            
            if (success) {
                
                success(PNMessageSendingError, sendingError);
            }
        }
    }
           postponedExecutionBlock:^{
               
               [self postponeSendMessage:message toChannel:channel withCompletionBlock:(success ? [success copy] : nil)];
           }];
    
    
    return messageObject;
}

+ (void)postponeSendMessage:(id)message
                  toChannel:(PNChannel *)channel
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
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#28} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
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
            
            PNError *sendingError = [PNError errorWithCode:statusCode];
            sendingError.associatedObject = channel;
            
            [[self sharedInstance] notifyDelegateAboutHistoryDownloadFailedWithError:sendingError];
        }
    }
           postponedExecutionBlock:^{
               
               [self postponeRequestHistoryForChannel:channel
                                                 from:startDate
                                                   to:endDate
                                                limit:limit
                                       reverseHistory:shouldReverseMessageHistory
                                  withCompletionBlock:(handleBlock ? [handleBlock copy] : nil)];
           }];
}

+ (void)postponeRequestHistoryForChannel:(PNChannel *)channel
                                    from:(PNDate *)startDate
                                      to:(PNDate *)endDate
                                   limit:(NSUInteger)limit
                          reverseHistory:(BOOL)shouldReverseMessageHistory
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
    
    [self performAsyncLockingBlock:^{
        NSLog(@">>>>>> {LOCK}{#29} TURN ON (%s)", __PRETTY_FUNCTION__);
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {
            
            [[PNObservationCenter defaultCenter] removeClientAsParticipantsListDownloadObserver];
            if (handleBlock) {
                
                [[PNObservationCenter defaultCenter] addClientAsParticipantsListDownloadObserverWithBlock:[handleBlock copy]];
            }
            
            
            PNHereNowRequest *request = [PNHereNowRequest whoNowRequestForChannel:channel];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {
            
            PNError *sendingError = [PNError errorWithCode:statusCode];
            sendingError.associatedObject = channel;
            
            [[self sharedInstance] notifyDelegateAboutParticipantsListDownloadFailedWithError:sendingError];
        }
    }
           postponedExecutionBlock:^{
               
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
            NSLog(@">>>>>> {LOCK}{#7} TURN ON (%s)", __PRETTY_FUNCTION__);
            
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
                
                weakSelf.connectOnServiceReachabilityCheck = NO;
                if (connected) {

                    weakSelf.asyncLockingOperationInProgress = NO;
                    NSLog(@">>>>>> {LOCK}{#8} TURN OFF (%s)", __PRETTY_FUNCTION__);
                    
                    [[weakSelf class] connect];
                }
                else {

                    weakSelf.connectOnServiceReachability = YES;
                    [weakSelf handleConnectionErrorOnNetworkFailure];
                    weakSelf.asyncLockingOperationInProgress = YES;
                    NSLog(@">>>>>> {LOCK}{#9} TURN ON (%s)", __PRETTY_FUNCTION__);
                }
            }
            else {
                
                if (connected) {
                    
                    // In case if client is in 'disconnecting on network error' state when connection become available
                    // force client to change it state to "completed" stage of disconnection on network error
                    if (weakSelf.state == PNPubNubClientStateDisconnectingOnNetworkError) {
                        
                        weakSelf.state = PNPubNubClientStateDisconnectedOnNetworkError;
                    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED
                    BOOL isSuspended = weakSelf.state == PNPubNubClientStateSuspended;
#else
                    BOOL isSuspended = NO;
#endif

                    
                    if (weakSelf.state == PNPubNubClientStateDisconnectedOnNetworkError ||
                        weakSelf.shouldConnectOnServiceReachability || isSuspended) {
                        
                        // Check whether should restore connection or not
                        if([weakSelf shouldRestoreConnection] || weakSelf.shouldConnectOnServiceReachability) {

                            weakSelf.asyncLockingOperationInProgress = NO;
                            NSLog(@">>>>>> {LOCK}{#10} TURN OFF (%s)", __PRETTY_FUNCTION__);
                            if(!weakSelf.shouldConnectOnServiceReachability){
                                
                                weakSelf.restoringConnection = YES;
                            }

                            if (isSuspended) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
                                weakSelf.state = PNPubNubClientStateConnected;

                                [weakSelf.messagingChannel resume];
                                [weakSelf.serviceChannel resume];
#endif
                            }
                            else {

                                [[weakSelf class] connect];
                            }
                        }
                    }
                }
                else {
                    
                    // Check whether PubNub client was connected or connecting right now
                    if (weakSelf.state == PNPubNubClientStateConnected || weakSelf.state == PNPubNubClientStateConnecting) {
                        
                        if (weakSelf.state == PNPubNubClientStateConnecting) {
                            
                            [weakSelf handleConnectionErrorOnNetworkFailure];
                        }
                        else {

                            if (![weakSelf shouldRestoreConnection]) {

                                PNError *connectionError = [PNError errorWithCode:kPNClientConnectionClosedOnInternetFailureError];
                                [weakSelf notifyDelegateClientWillDisconnectWithError:connectionError];
                            }
                            
                            weakSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;
                            
                            // Disconnect communication channels because of
                            // network issues
                            [weakSelf.messagingChannel disconnectWithReset:NO];
                            [weakSelf.serviceChannel disconnect];
                        }
                    }
                }
            }
        };
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        [self subscribeForNotifications];
#endif
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

    BOOL isChannelsConnected = [self.messagingChannel isConnected] && [self.serviceChannel isConnected];
    BOOL isCorrectRemoteHost = [self.configuration.origin isEqualToString:host];
    
    // Check whether all communication channels connected and whether client in corresponding state or not
    if (isChannelsConnected && isCorrectRemoteHost && self.state == PNPubNubClientStateConnecting) {
        
        self.connectOnServiceReachabilityCheck = NO;
        self.connectOnServiceReachability = NO;
        
        // Mark that PubNub client established connection to PubNub
        // services
        self.state = PNPubNubClientStateConnected;
        
        
        [self warmUpConnections];
        
        [self notifyDelegateAboutConnectionToOrigin:host];
        
        if (!self.isRestoringConnection) {
            NSLog(@">>>>>> {LOCK}{#36} TURN OFF (%s)", __PRETTY_FUNCTION__);
            
            [self handleLockingOperationComplete:YES];
        }
        
        self.restoringConnection = NO;
    }
}

- (void)connectionChannel:(PNConnectionChannel *)channel didReconnectToHost:(NSString *)host {
    
    // Check whether received event from same host on which client
    // is configured or not and client connected at this moment
    if ([self.configuration.origin isEqualToString:host] && self.state == PNPubNubClientStateConnected) {
        
        [self warmUpConnection:channel];
    }
}

- (void)  connectionChannel:(PNConnectionChannel *)channel
  connectionDidFailToOrigin:(NSString *)host
                  withError:(PNError *)error {
    
    // Check whether client in corresponding state and all
    // communication channels not connected to the server
    if(self.state == PNPubNubClientStateConnecting && [self.configuration.origin isEqualToString:host] &&
       ![self.messagingChannel isConnected] && ![self.serviceChannel isConnected]) {
        
        self.connectOnServiceReachabilityCheck = NO;
        self.connectOnServiceReachability = NO;
        
        
        [self.configuration shouldKillDNSCache:YES];
        
        // Send notification to all who is interested in it
        // (observation center will track it as well)
        [self notifyDelegateClientConnectionFailedWithError:error];
    }
}

- (void)connectionChannel:(PNConnectionChannel *)channel didDisconnectFromOrigin:(NSString *)host {
    
    // Check whether host name arrived or not
    // (it may not arrive if event sending instance
    // was dismissed/deallocated)
    if (host == nil) {
        
        host = self.configuration.origin;
    }
    
    
    // Check whether received event from same host on which client
    // is configured or not and all communication channels are closed
    if([self.configuration.origin isEqualToString:host] &&
       ![self.messagingChannel isConnected] && ![self.serviceChannel isConnected]  &&
       self.state != PNPubNubClientStateDisconnected && self.state != PNPubNubClientStateDisconnectedOnNetworkError) {
        
        // Check whether all communication channels disconnected and whether
        // client in corresponding state or not
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
                    
                    // Try to refresh reachability state (there is situation whem reachability state
                    // changed within library to handle sockets timeout/error)
                    [self.reachability refreshReachabilityState];
                    break;
                    
                default:
                    break;
            }
            
            
            if(state == PNPubNubClientStateDisconnected) {
                
                // Clean up cached data
                [PNChannel purgeChannelsCache];

                // Delay disconnection notification to give client ability
                // to perform clean up well
                __block __pn_desired_weak __typeof__(self) weakSelf = self;
                void(^disconnectionNotifyBlock)(void) = ^{

                    if ([weakSelf.delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {

                        [weakSelf.delegate pubnubClient:weakSelf didDisconnectFromOrigin:host];
                    }

                    NSLog(@">>>>>> {LOCK}{#37} TURN OFF (%s)", __PRETTY_FUNCTION__);
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

                        NSLog(@">>>>>> {LOCK}{#41} TURN OFF (%s)", __PRETTY_FUNCTION__);
                        [weakSelf handleLockingOperationBlockCompletion:^{

                            if ([weakSelf.delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:withError:)]) {

                                [weakSelf.delegate pubnubClient:weakSelf didDisconnectFromOrigin:host withError:connectionError];
                            }

                            [weakSelf sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:connectionError];
                        }
                                                    shouldStartNext:YES];
                    }
                };

                // Check whether service is available
                // (this event may arrive after device was unlocked
                // so basically connection is available and only
                // sockets closed by remote server or internal kernel
                // layer)
                if ([self.reachability isServiceReachabilityChecked]) {
                    
                    if ([self.reachability isServiceAvailable]) {
                        
                        // Check whether should restore connection or not
                        if ([self shouldRestoreConnection]) {

                            self.asyncLockingOperationInProgress = NO;
                            NSLog(@">>>>>> {LOCK}{#11} TURN OFF (%s)", __PRETTY_FUNCTION__);
                            self.restoringConnection = YES;
                            
                            // Try to restore connection to remote PubNub services
                            [[self class] connect];
                        }
                        else {

                            disconnectionNotifyBlock();
                        }
                    }
                    // In case if there is no connection check whether clint
                    // should restore connection or not.
                    else if(![self shouldRestoreConnection]) {
                        
                        self.state = PNPubNubClientStateDisconnected;
                        disconnectionNotifyBlock();
                    }
                }
            }
        }
        // Check whether server unexpectedly closed connection
        // while client was active or not
        else if(self.state == PNPubNubClientStateConnected) {
            
            self.state = PNPubNubClientStateDisconnected;
            
            if([self shouldRestoreConnection]) {

                self.asyncLockingOperationInProgress = NO;
                NSLog(@">>>>>> {LOCK}{#12} TURN OFF (%s)", __PRETTY_FUNCTION__);
                self.restoringConnection = YES;
                
                // Try to restore connection to remote PubNub services
                [[self class] connect];
            }
        }
        // Check whether connection has been closed because
        // PubNub client updates it's configuration
        else if (self.state == PNPubNubClientStateDisconnectingOnConfigurationChange) {

            self.asyncLockingOperationInProgress = NO;
            NSLog(@">>>>>> {LOCK}{#13} TURN OFF (%s)", __PRETTY_FUNCTION__);
            
            // Close connection to PubNub services
            [[self class] disconnectByUser:NO];
        }
    }
}

- (void) connectionChannel:(PNConnectionChannel *)channel
  willDisconnectFromOrigin:(NSString *)host
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

#if __IPHONE_OS_VERSION_MIN_REQUIRED
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
#endif


#pragma mark - Handler methods

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)handleApplicationDidEnterBackgroundState:(NSNotification *)__unused notification {

    BOOL canRunInBackground = [self canRunInBackground];
    if (!canRunInBackground) {

        PNLog(PNLogGeneralLevel, self, @" HANDLE APPLICATION ENTERED BACKGROUND. SUSPEND.");

        [self.messagingChannel suspend];
        [self.serviceChannel suspend];

        self.state = PNPubNubClientStateSuspended;
    }
}

- (void)handleApplicationDidEnterForegroundState:(NSNotification *)__unused notification  {

    [self.reachability refreshReachabilityState];

    if ([self.reachability isServiceAvailable]) {

        PNLog(PNLogGeneralLevel, self, @" HANDLE APPLICATION ENTERED FOREGROUND. RESUME.");
        self.state = PNPubNubClientStateConnected;

        [self.messagingChannel resume];
        [self.serviceChannel resume];
    }
}
#endif

- (void)handleConnectionErrorOnNetworkFailure {

    // Check whether client is connecting currently or not
    if (self.state == PNPubNubClientStateConnecting || self.shouldConnectOnServiceReachability) {
        
        PNError *networkError = [PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError];
        [self notifyDelegateClientConnectionFailedWithError:networkError];
    }
}

- (void)handleLockingOperationComplete:(BOOL)shouldStartNext {

    NSLog(@">>>>>> {LOCK}{#42} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:NULL shouldStartNext:shouldStartNext];
}

- (void)handleLockingOperationBlockCompletion:(void(^)(void))operationPostBlock shouldStartNext:(BOOL)shouldStartNext {

    self.asyncLockingOperationInProgress = NO;
    NSLog(@">>>>>> {LOCK}{#14} TURN OFF (%s)", __PRETTY_FUNCTION__);


    // Perform post completion block
    // INFO: This is done to handle situation when some block may launch locking operation
    //       and this handling block will release another one
    if (operationPostBlock) {

        operationPostBlock();
    }


    if (shouldStartNext) {

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

- (void)prepareCryptoHelper {
    
    if ([self.configuration.cipherKey length] > 0) {
        
        PNError *helperInitializationError = nil;
        [[PNCryptoHelper sharedInstance] updateWithConfiguration:self.configuration
                                                       withError:&helperInitializationError];
        if (helperInitializationError != nil) {
            
            PNLog(PNLogGeneralLevel, self, @" [INFO] Crypto helper initialization failed because of error: %@",
                  helperInitializationError);
        }
    }
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)subscribeForNotifications {

    [self unsubscribeFromNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterBackgroundState:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterForegroundState:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)unsubscribeFromNotifications {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
#endif

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

        [self sendNotification:kPNClientSubscriptionWillRestoreNotification withObject:channels];
    }
}

- (void)notifyDelegateAboutSubscriptionFailWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#57} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle subscription error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:subscriptionDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:subscriptionDidFailWithError:)
                                    withObject:self
                                    withObject:(id) error];
            }
            
            [self sendNotification:kPNClientSubscriptionDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutUnsubscriptionFailWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#59} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle unsubscription error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)
                                    withObject:self
                                    withObject:(id) error];
            }
            
            [self sendNotification:kPNClientUnsubscriptionDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPresenceEnablingFailWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#52} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle unsubscription error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:presenceObservationEnablingDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:presenceObservationEnablingDidFailWithError:)
                                    withObject:self
                                    withObject:(id) error];
            }
            
            [self sendNotification:kPNClientPresenceEnablingDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPresenceDisablingFailWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#51} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle unsubscription error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:presenceObservationDisablingDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:presenceObservationDisablingDidFailWithError:)
                                    withObject:self
                                    withObject:(id) error];
            }
            
            [self sendNotification:kPNClientPresenceDisablingDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsEnableFailedWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#55} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
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
            
            [self sendNotification:kPNClientPushNotificationEnableDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsDisableFailedWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#53} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
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
            
            [self sendNotification:kPNClientPushNotificationDisableDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsRemoveFailedWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#56} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
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
            
            [self sendNotification:kPNClientPushNotificationRemoveDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#54} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
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
            
            [self sendNotification:kPNClientPushNotificationChannelsRetrieveDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#58} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle time token retriaval
            // error or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)
                                    withObject:self
                                    withObject:error];
            }
            
            [self sendNotification:kPNClientDidFailTimeTokenReceiveNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutMessageSendingFailedWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#49} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle message sendinf error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailMessageSend:withError:)]) {
                
                [self.delegate pubnubClient:self didFailMessageSend:error.associatedObject withError:error];
            }
            
            [self sendNotification:kPNClientMessageSendingDidFailNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutHistoryDownloadFailedWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#48} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate us able to handle message history download error
            // or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailHistoryDownloadForChannel:withError:)]) {
                
                [self.delegate pubnubClient:self
           didFailHistoryDownloadForChannel:error.associatedObject
                                  withError:error];
            }
            
            [self sendNotification:kPNClientHistoryDownloadFailedWithErrorNotification withObject:error];
        }
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutParticipantsListDownloadFailedWithError:(PNError *)error {

    NSLog(@">>>>>> {LOCK}{#50} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate us able to handle participants list
            // download error or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailParticipantsListDownloadForChannel:withError:)]) {
                
                [self.delegate   pubnubClient:self
    didFailParticipantsListDownloadForChannel:error.associatedObject
                                    withError:error];
            }
            
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
    
    [self sendNotification:kPNClientErrorNotification withObject:error];
}

- (void)notifyDelegateClientWillDisconnectWithError:(PNError *)error {
    
    if ([self.delegate respondsToSelector:@selector(pubnubClient:willDisconnectWithError:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:willDisconnectWithError:)
                            withObject:self
                            withObject:error];
    }
    
    [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
}

- (void)notifyDelegateClientConnectionFailedWithError:(PNError *)error {
    
    BOOL shouldStartNextPostponedOperation = !self.shouldConnectOnServiceReachability;

    NSLog(@">>>>>> {LOCK}{#60} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self.delegate respondsToSelector:@selector(pubnubClient:connectionDidFailWithError:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:connectionDidFailWithError:)
                                withObject:self
                                withObject:error];
        }
        
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
    
    return (self.state != PNPubNubClientStateCreated) && (self.state != PNPubNubClientStateConnecting) &&
           (self.state != PNPubNubClientStateDisconnecting) && (self.state != PNPubNubClientStateDisconnected) &&
           (self.state != PNPubNubClientStateReset);
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

    NSLog(@">>>>>> {LOCK}{#39} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationComplete:YES];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willSubscribeOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @" WILL SUBSCRIBE ON: %@", channels);
    self.asyncLockingOperationInProgress = YES;
    NSLog(@">>>>>> {LOCK}{#15} TURN ON (%s)", __PRETTY_FUNCTION__);
}

- (void)messagingChannel:(PNMessagingChannel *)channel didSubscribeOnChannels:(NSArray *)channels {

    NSLog(@">>>>>> {LOCK}{#46} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{

        if ([self shouldNotifyAboutEvent]) {

            // Check whether delegate can handle subscription on channel or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didSubscribeOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:didSubscribeOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }

        	[self sendNotification:kPNClientSubscriptionDidCompleteNotification withObject:channels];
    	}
    }
                                shouldStartNext:YES];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willRestoreSubscriptionOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @" WILL RESTORE SUBSCRIPTION ON: %@", channels);
    self.asyncLockingOperationInProgress = YES;
    NSLog(@">>>>>> {LOCK}{#16} TURN ON (%s)", __PRETTY_FUNCTION__);

    [self notifyDelegateAboutResubscribeWillStartOnChannels:channels];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didRestoreSubscriptionOnChannels:(NSArray *)channels {

    NSLog(@">>>>>> {LOCK}{#45} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{

        if ([self shouldNotifyAboutEvent]) {

            // Check whether delegate can handle subscription restore on channels or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didRestoreSubscriptionOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:didRestoreSubscriptionOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }


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

    PNLog(PNLogGeneralLevel, self, @" WILL UNSUBSCRIBE FROM: %@", channels);
    self.asyncLockingOperationInProgress = YES;
    NSLog(@">>>>>> {LOCK}{#17} TURN ON (%s)", __PRETTY_FUNCTION__);
}

- (void)messagingChannel:(PNMessagingChannel *)channel didUnsubscribeFromChannels:(NSArray *)channels {

    NSLog(@">>>>>> {LOCK}{#47} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{

        if ([self shouldNotifyAboutEvent]) {

            // Check whether delegate can handle unsubscription event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }

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

    PNLog(PNLogGeneralLevel, self, @" WILL ENABLE PRESENCE ON: %@", channels);
    self.asyncLockingOperationInProgress = YES;
    NSLog(@">>>>>> {LOCK}{#18} TURN ON (%s)", __PRETTY_FUNCTION__);
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didEnablePresenceObservationOnChannels:(NSArray *)channels {

    NSLog(@">>>>>> {LOCK}{#44} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can handle new message arrival or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didEnablePresenceObservationOnChannels:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didEnablePresenceObservationOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }
            
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

    PNLog(PNLogGeneralLevel, self, @" WILL DISABLE PRESENCE ON: %@", channels);
    self.asyncLockingOperationInProgress = YES;
    NSLog(@">>>>>> {LOCK}{#19} TURN ON (%s)", __PRETTY_FUNCTION__);
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didDisablePresenceObservationOnChannels:(NSArray *)channels {

    NSLog(@">>>>>> {LOCK}{#43} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can handle new message arrival or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didDisablePresenceObservationOnChannels:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didDisablePresenceObservationOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }
            
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
    
    if ([self shouldNotifyAboutEvent]) {
        
        // Check whether delegate can handle new message arrival or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessage:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:didReceiveMessage:)
                                withObject:self
                                withObject:message];
        }
        
        [self sendNotification:kPNClientDidReceiveMessageNotification withObject:message];
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveEvent:(PNPresenceEvent *)event {
    
    // Try to update cached channel data
    PNChannel *channel = event.channel;
    if (channel) {
        
        [channel updateWithEvent:event];
    }
    
    if ([self shouldNotifyAboutEvent]) {
        
        // Check whether delegate can handle presence event arrival or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceivePresenceEvent:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:didReceivePresenceEvent:)
                                withObject:self
                                withObject:event];
        }
        
        [self sendNotification:kPNClientDidReceivePresenceEventNotification withObject:event];
    }
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveTimeToken:(NSNumber *)timeToken {

    NSLog(@">>>>>> {LOCK}{#66} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can handle time token retrieval or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveTimeToken:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didReceiveTimeToken:)
                                    withObject:self
                                    withObject:timeToken];
            }
            
            
            [self sendNotification:kPNClientDidReceiveTimeTokenNotification withObject:timeToken];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel receiveTimeTokenDidFailWithError:(PNError *)error {
    
    [self notifyDelegateAboutTimeTokenRetrievalFailWithError:error];
}

- (void)serviceChannel:(PNServiceChannel *)channel didEnablePushNotificationsOnChannels:(NSArray *)channels {

    NSLog(@">>>>>> {LOCK}{#62} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle push notification enabled event or not
            SEL selector = @selector(pubnubClient:didEnablePushNotificationsOnChannels:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:channels];
                #pragma clang diagnostic pop
            }
            
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

    NSLog(@">>>>>> {LOCK}{#61} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate is able to handle push notification disable event or not
            SEL selector = @selector(pubnubClient:didDisablePushNotificationsOnChannels:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:channels];
                #pragma clang diagnostic pop
            }
            
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

    NSLog(@">>>>>> {LOCK}{#68} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check wheter delegate is able to handle successfull push notification removal from
            // all channels or not
            SEL selector = @selector(pubnubClientDidRemovePushNotifications:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self];
                #pragma clang diagnostic pop
            }
            
            [self sendNotification:kPNClientPushNotificationRemoveDidCompleteNotification withObject:nil];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationsRemoveWithError:(PNError *)error {
    
    [self notifyDelegateAboutPushNotificationsRemoveFailedWithError:error];
}

- (void)serviceChannel:(PNServiceChannel *)channel didReceivePushNotificationsEnabledChannels:(NSArray *)channels {

    NSLog(@">>>>>> {LOCK}{#65} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
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
    
    if ([self shouldNotifyAboutEvent]) {
        
        // Check whether delegate can handle message sending event or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:willSendMessage:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:willSendMessage:)
                                withObject:self
                                withObject:message];
        }
        
        [self sendNotification:kPNClientWillSendMessageNotification withObject:message];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didSendMessage:(PNMessage *)message {

    NSLog(@">>>>>> {LOCK}{#67} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can handle message sent event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didSendMessage:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didSendMessage:)
                                    withObject:self
                                    withObject:message];
            }
            
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

    NSLog(@">>>>>> {LOCK}{#63} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can response on history download event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessageHistory:forChannel:startingFrom:to:)]) {
                
                [self.delegate pubnubClient:self
                   didReceiveMessageHistory:history.messages
                                 forChannel:history.channel
                               startingFrom:history.startDate
                                         to:history.endDate];
            }
            
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

    NSLog(@">>>>>> {LOCK}{#64} TURN OFF (%s)", __PRETTY_FUNCTION__);
    [self handleLockingOperationBlockCompletion:^{
        
        if ([self shouldNotifyAboutEvent]) {
            
            // Check whether delegate can response on participants list download event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveParticipantsList:forChannel:)]) {
                
                [self.delegate pubnubClient:self
                 didReceiveParticipantsList:participants.participants
                                 forChannel:participants.channel];
            }
            
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
