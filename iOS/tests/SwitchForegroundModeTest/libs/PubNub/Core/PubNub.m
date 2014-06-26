/**

 @author Sergey Mamontov
 @version 3.6.2
 @copyright © 2009-14 PubNub Inc.

 */

#import "PubNub+Protected.h"
#import "PNConnectionChannel+Protected.h"
#import "PNPresenceEvent+Protected.h"
#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import "UIApplication+PNAdditions.h"
#endif
#import "PNAccessRightOptions+Protected.h"
#import "PNServiceChannelDelegate.h"
#import "NSDictionary+PNAdditions.h"
#import "PNConnection+Protected.h"
#import "PNWhereNow+Protected.h"
#import "PNMessagingChannel.h"
#import "PNServiceChannel.h"
#import "PNRequestsImport.h"
#import "PNHereNowRequest.h"
#import "PNNotifications.h"
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

static NSString * const kPNCodebaseBranch = @"master";
static NSString * const kPNCodeCommitIdentifier = @"d23e946d0be17dc9d486fc75b720d2fefd6a7e64";

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

/**
 Stores reference on local \b PubNub cache instance which will cache some portion of data.
 */
@property (nonatomic, strong) PNCache *cache;

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

/**
 Stores reference on timer which is used with heartbeat logic
 */
@property (nonatomic, strong) NSTimer *heartbeatTimer;

// Stores current client state
@property (nonatomic, assign) PNPubNubClientState state;

// Stores whether library is performing one of async locking methods or not (if yes, other calls will be placed
// into pending set)
@property (nonatomic, assign, getter = isAsyncLockingOperationInProgress) BOOL asyncLockingOperationInProgress;

// Stores whether client updating client identifier or not
@property (nonatomic, assign, getter = isUpdatingClientIdentifier) BOOL updatingClientIdentifier;


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


#pragma mark - Client state management

+ (void)postponeRequestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
        witCompletionHandlingBlock:(id)handlerBlock;

+ (void)postponeUpdateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState forChannel:(PNChannel *)channel
      withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Channels subscription management

+ (void)subscribeOnChannels:(NSArray *)channels withCatchUp:(BOOL)shouldCatchUp clientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;
+ (void)postponeSubscribeOnChannels:(NSArray *)channels withCatchUp:(BOOL)shouldCatchUp
                        clientState:(NSDictionary *)clientState
         andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;
+ (void)postponeUnsubscribeFromChannels:(NSArray *)channels
            withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;


#pragma mark - APNS management

+ (void)postponeEnablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                       andCompletionHandlingBlock:(id)handlerBlock;

+ (void)postponeDisablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                        andCompletionHandlingBlock:(id)handlerBlock;

+ (void)postponeRemoveAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                                 withCompletionHandlingBlock:(id)handlerBlock;

+ (void)postponeRequestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                             withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - PAM management

/**
 * Same as +changeAccessRightsForChannel:accessRights:forPeriod:withCompletionHandlingBlock: but allow to specify authorization
 * key for which access rights on specific channel should be set.
 *
 * Only last call of this method will call completion block. If you need to track push notification disabling process
 * from many places, use PNObservationCenter methods for this purpose.
 */
+ (void)changeAccessRightsForChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                              clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSInteger)accessPeriodDuration
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

+ (void)postponeChangeAccessRightsForChannels:(NSArray *)channels
                                 accessRights:(PNAccessRights)accessRights
                                      clients:(NSArray *)clientsAuthorizationKeys
                                    forPeriod:(NSInteger)accessPeriodDuration
                  withCompletionHandlingBlock:(id)handlerBlock;

+ (void)auditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

+ (void)postponeAuditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
                 withCompletionHandlingBlock:(id)handlerBlock;

#pragma mark - Presence management

+ (void)postponeEnablePresenceObservationForChannels:(NSArray *)channels
                         withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;
+ (void)postponeDisablePresenceObservationForChannels:(NSArray *)channels
                          withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;


#pragma mark - Time token

+ (void)postponeRequestServerTimeTokenWithCompletionBlock:(id)success;


#pragma mark - Messages processing methods

+ (void)postponeSendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
        withCompletionBlock:(id)success;


#pragma mark - History methods

+ (void)postponeRequestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                                   limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory
                      includingTimeToken:(BOOL)shouldIncludeTimeToken
                     withCompletionBlock:(id)handleBlock;


#pragma mark - Participant methods

+ (void)postponeRequestParticipantsListForChannel:(PNChannel *)channel
                       clientIdentifiersLRequired:(BOOL)isClientIdentifiersRequired
                                      clientState:(BOOL)shouldFetchClientState
                              withCompletionBlock:(id)handleBlock;

+ (void)postponeRequestParticipantChannelsList:(NSString *)clientIdentifier
                           withCompletionBlock:(id)handleBlock;


#pragma mark - Misc methods

/**
 * Print out PubNub library information
 */
+ (void)showVserionInfo;

+ (NSString *)humanReadableStateFrom:(PNPubNubClientState)state;

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

/**
 * Handle locking operation completion and pop new one from pending invocations list.
 */
- (void)handleLockingOperationComplete:(BOOL)shouldStartNext;
- (void)handleLockingOperationBlockCompletion:(void(^)(void))operationPostBlock shouldStartNext:(BOOL)shouldStartNext;


#pragma mark - Misc methods

- (NSString *)humanReadableStateFrom:(PNPubNubClientState)state;

/**
 Launch heartbeat timer if possible (if client connected and there is channels on which client subscribed at this
 moment).
 */
- (void)launchHeartbeatTimer;

/**
 Disable previously launched heartbeat timer.
 */
- (void)stopHeartbeatTimer;

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
 * Place selector into list of postponed calls with corresponding parameters If 'placeOutOfOrder' is specified,
 * selector will be placed first in FIFO queue and will be executed as soon as it will be possible.
 */
- (void)postponeSelector:(SEL)calledMethodSelector forObject:(id)object withParameters:(NSArray *)parameters
              outOfOrder:(BOOL)placeOutOfOrder;

/**
 * This method will notify delegate about that connection to the PubNub service is established and send notification
 * about it
 */
- (void)notifyDelegateAboutConnectionToOrigin:(NSString *)originHostName;

/**
 This method should notify delegate that \b PubNub client failed to retrieve state for client.
 */
- (void)notifyDelegateAboutStateRetrievalDidFailWithError:(PNError *)error;

/**
 This method should notify delegate that \b PubNub client failed to update state for client.
 */
- (void)notifyDelegateAboutStateUpdateDidFailWithError:(PNError *)error;

/**
 * This method will notify delegate that client is about to restore subscription to specified set of channels
 * and send notification about it.
 */
- (void)notifyDelegateAboutResubscribeWillStartOnChannels:(NSArray *)channels;

/**
 * This method will notify delegate about that subscription failed with error
 */
- (void)notifyDelegateAboutSubscriptionFailWithError:(PNError *)error
                            completeLockingOperation:(BOOL)shouldCompleteLockingOperation;

/**
 * This method will notify delegate about that unsubscription failed with error
 */
- (void)notifyDelegateAboutUnsubscriptionFailWithError:(PNError *)error
                              completeLockingOperation:(BOOL)shouldCompleteLockingOperation;

/**
 * This method will notify delegate about that presence enabling failed with error
 */
- (void)notifyDelegateAboutPresenceEnablingFailWithError:(PNError *)error
                                completeLockingOperation:(BOOL)shouldCompleteLockingOperation;

/**
 * This method will notify delegate about that presence disabling failed with error
 */
- (void)notifyDelegateAboutPresenceDisablingFailWithError:(PNError *)error
                                 completeLockingOperation:(BOOL)shouldCompleteLockingOperation;

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
 This method will notify delegate about that access rights change failed with error.

 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
  contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)notifyDelegateAboutAccessRightsChangeFailedWithError:(PNError *)error;

/**
 This method will notify delegate about that access rights audit failed with error.

 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
  contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)notifyDelegateAboutAccessRightsAuditFailedWithError:(PNError *)error;

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
 * This method will notify delegate about that participant channels list download error occurred.
 */
- (void)notifyDelegateAboutParticipantChannelsListDownloadFailedWithError:(PNError *)error;

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

- (void)sendNotification:(NSString *)notificationName withObject:(id)object;

/**
 * Check whether client should restore connection after network went down and restored now
 */
- (BOOL)shouldRestoreConnection;

/**
 * Check whether delegate should be notified about some runtime event (errors will be notified w/o regard to this flag)
 */
- (BOOL)shouldChannelNotifyAboutEvent:(PNConnectionChannel *)channel;

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

    [PNLogger logGeneralMessageFrom:_sharedInstance message:^NSString * { return @"CLIENT RESET."; }];
    
    // Mark that client is in resetting state, so it won't be affected by callbacks from transport classes
    _sharedInstance.state = PNPubNubClientStateReset;
    [_sharedInstance stopHeartbeatTimer];
    
    onceToken = 0;
    [PNObservationCenter resetCenter];
    [PNConnection resetConnectionsPool];
    [PNChannel purgeChannelsCache];
    [PNCryptoHelper resetHelper];

    _sharedInstance.updatingClientIdentifier = NO;
    _sharedInstance.messagingChannel.delegate = nil;
    [_sharedInstance.messagingChannel terminate];
    _sharedInstance.serviceChannel.delegate = nil;
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

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO CONNECT W/O SUCCESS AND ERROR BLOCK... (STATE: %@)",
                [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self connectWithSuccessBlock:nil errorBlock:nil];
}

+ (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                     errorBlock:(PNClientConnectionFailureBlock)failure {

    if (success || failure) {

        [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

            return [NSString stringWithFormat:@"TRYING TO CONNECT W/ SUCCESS AND/OR ERROR BLOCK... (STATE: %@)",
                    [self humanReadableStateFrom:[self sharedInstance].state]];
        }];
    }

    [self performAsyncLockingBlock:^{

        __block BOOL shouldAddStateObservation = NO;
        [self sharedInstance].updatingClientIdentifier = NO;

        // Check whether instance already connected or not
        if ([self sharedInstance].state == PNPubNubClientStateConnected ||
            [self sharedInstance].state == PNPubNubClientStateConnecting) {

            NSString *state = @"CONNECTED";
            if ([self sharedInstance].state == PNPubNubClientStateConnecting) {

                state = @"CONNECTING...";
            }

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"PUBNUB CLIENT ALREDY %@ (STATE: %@)",
                        state, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];


            PNError *connectionError = [PNError errorWithCode:kPNClientTriedConnectWhileConnectedError];
            [[self sharedInstance] notifyDelegateClientConnectionFailedWithError:connectionError];

            if (failure) {

                failure(connectionError);
            }

            // In case if developer tried to initiate connection when client already was connected, procedural lock
            // should be released
            if ([self sharedInstance].state == PNPubNubClientStateConnected) {

                [[self sharedInstance] handleLockingOperationComplete:YES];
            }
        }
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"PREPARE COMPONENTS FOR CONNECTION... (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            // Check whether client configuration was provided or not
            if ([self sharedInstance].configuration == nil) {

                [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                    return [NSString stringWithFormat:@"{ERROR} TRYING TO CONNECT W/O CONFIGURATION (STATE: %@)",
                            [self humanReadableStateFrom:[self sharedInstance].state]];
                }];

                PNError *connectionError = [PNError errorWithCode:kPNClientConfigurationError];
                [[self sharedInstance] notifyDelegateAboutError:connectionError];


                if (failure) {

                    failure(connectionError);
                }

                [[self sharedInstance] handleLockingOperationComplete:YES];
            }
            else {

                // Check whether user has been faster to call connect than library was able to resume connection
                if ([self sharedInstance].state == PNPubNubClientStateSuspended || [[self sharedInstance] isResuming]) {

                    NSString *state = @"WAS SUSPENDED";
                    if ([[self sharedInstance] isResuming]) {

                        state = @"TRYING TO RESUME AFTER SLEEP";
                    }

                    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                        return [NSString stringWithFormat:@"TRIED TO CONNECT WHILE %@ (LIBRARY DOESN'T HAVE"
                                " ENOUGH TIME TO RESTORE) (STATE: %@)", state, [self humanReadableStateFrom:[self sharedInstance].state]];
                    }];

                    // Because all connection channels will be destroyed, it means that client currently disconnected
                    [self sharedInstance].state = PNPubNubClientStateDisconnected;


                    // Disconnecting communication channels and preserve all issued requests which wasn't sent till
                    // this moment (they will be send as soon as connection will be restored)
                    [_sharedInstance.messagingChannel disconnectWithEvent:NO];
                    [_sharedInstance.serviceChannel disconnectWithEvent:NO];
                }

                // Check whether user identifier was provided by user or not
                if ([self sharedInstance].clientIdentifier == nil) {

                    // Change user identifier before connect to the PubNub services
                    [self sharedInstance].clientIdentifier = [PNHelper UUID];
                }

                // Check whether services are available or not
                if ([[self sharedInstance].reachability isServiceReachabilityChecked]) {

                    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                        return [NSString stringWithFormat:@"REACHABILITY CHECKED (STATE: %@)",
                                [self humanReadableStateFrom:[self sharedInstance].state]];
                    }];

                    // Forcibly refresh reachability information
                    [[self sharedInstance].reachability refreshReachabilityState];

                    // Checking whether remote PubNub services is reachable or not (if they are not reachable,
                    // this mean that probably there is no connection)
                    if ([[self sharedInstance].reachability isServiceAvailable]) {

                        [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                            return [NSString stringWithFormat:@"INTERNET CONNECTION AVAILABLE (STATE: %@)",
                                    [self humanReadableStateFrom:[self sharedInstance].state]];
                        }];

                        // Notify PubNub delegate about that it will try to establish connection with remote PubNub
                        // origin (notify if delegate implements this method)
                        if ([[self sharedInstance].delegate respondsToSelector:@selector(pubnubClient:willConnectToOrigin:)]) {

                            [[self sharedInstance].delegate performSelector:@selector(pubnubClient:willConnectToOrigin:)
                                                                 withObject:[self sharedInstance]
                                                                 withObject:[self sharedInstance].configuration.origin];
                        }

                        [[self sharedInstance] sendNotification:kPNClientWillConnectToOriginNotification
                                                     withObject:[self sharedInstance].configuration.origin];

                        [PNLogger logDelegateMessageFrom:[self sharedInstance] message:^NSString * {

                            return [NSString stringWithFormat:@"PubNub will connect to origin: %@)",
                                    [self sharedInstance].configuration.origin];
                        }];

                        BOOL channelsDestroyed = ([self sharedInstance].messagingChannel == nil &&
                                                  [self sharedInstance].serviceChannel == nil);
                        BOOL channelsShouldBeCreated = ([self sharedInstance].state == PNPubNubClientStateCreated ||
                                                        [self sharedInstance].state == PNPubNubClientStateDisconnected ||
                                                        [self sharedInstance].state == PNPubNubClientStateReset);

                        // Check whether PubNub client was just created and there is no resources for reuse or not
                        if (channelsShouldBeCreated || channelsDestroyed) {

                            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                                return [NSString stringWithFormat:@"CREATE NEW COMPONNENTS TO POWER UP "
                                        "LIBRARY OPERATION WITH ORIGIN (STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
                            }];

                            if (!channelsShouldBeCreated && channelsDestroyed) {

                                [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                                    return [NSString stringWithFormat:@"PREVIOUS CHANNELS HAS BEEN DESTROYED"
                                            "BECAUSE OF LIBRARY STATE SYNCHRONIZATION ISSUE (STATE: %@)",
                                            [self humanReadableStateFrom:[self sharedInstance].state]];
                                }];
                            }

                            [self sharedInstance].state = PNPubNubClientStateConnecting;

                            // Initialize communication channels
                            [self sharedInstance].messagingChannel = [PNMessagingChannel messageChannelWithDelegate:[self sharedInstance]];
                            [self sharedInstance].messagingChannel.messagingDelegate = [self sharedInstance];
                            [self sharedInstance].serviceChannel = [PNServiceChannel serviceChannelWithDelegate:[self sharedInstance]];
                            [self sharedInstance].serviceChannel.serviceDelegate = [self sharedInstance];
                        }
                        else {

                            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                                return [NSString stringWithFormat:@"CONNECTION CAN BE INITATED USING "
                                        "EXISTING COMPONENTS (STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
                            }];

                            [self sharedInstance].state = PNPubNubClientStateConnecting;

                            // Reuse existing communication channels and reconnect them to remote origin server
                            [[self sharedInstance].messagingChannel connect];
                            [[self sharedInstance].serviceChannel connect];
                        }

                        shouldAddStateObservation = YES;
                    }
                    else {

                        [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                            return [NSString stringWithFormat:@"INTERNET CONNECTION NOT AVAILABLE. LIBRARY"
                                    " WILL CONNECT AS SOON AS CONNECTION BECOME AVAILABLE. (STATE: %@)",
                                    [self humanReadableStateFrom:[self sharedInstance].state]];
                        }];

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

                    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                        return [NSString stringWithFormat:@"REACHABILITY NOT CHECKED YET. LIBRARY WILL "
                                "CONTINUE CONNECTION IF REACHABILITY WILL REPORT NETWORK AVAILABILITY (STATE: %@)",
                                [self humanReadableStateFrom:[self sharedInstance].state]];
                    }];
                    
                    [self sharedInstance].asyncLockingOperationInProgress = YES;
                    [self sharedInstance].connectOnServiceReachabilityCheck = YES;
                    [self sharedInstance].connectOnServiceReachability = NO;

                    shouldAddStateObservation = YES;
                }
            }
        }

        if (![self sharedInstance].shouldConnectOnServiceReachabilityCheck ||
            ![self sharedInstance].shouldConnectOnServiceReachability) {

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

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE CONNECTION (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];

               [self postponeConnectWithSuccessBlock:success errorBlock:failure];
           }];
}

+ (void)postponeConnectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                             errorBlock:(PNClientConnectionFailureBlock)failure {

    [[self sharedInstance] postponeSelector:@selector(connectWithSuccessBlock:errorBlock:)
                                  forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:success], [PNHelper nilifyIfNotSet:failure]]
                                 outOfOrder:[self sharedInstance].isRestoringConnection];
}

+ (void)disconnect {
    
	[self disconnectByUser:YES];
}

+ (void)disconnectByUser:(BOOL)isDisconnectedByUser {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO DISCONNECT%@ (STATE: %@)",
                isDisconnectedByUser ? @" BY USER RWQUEST." : @" BY INTERNAL REQUEST",
                [self humanReadableStateFrom:[self sharedInstance].state]];
    }];

    [[self sharedInstance] stopHeartbeatTimer];

    if ([[self sharedInstance].reachability isSuspended]) {

        [[self sharedInstance].reachability resume];
    }
    
    [self performAsyncLockingBlock:^{

        if (isDisconnectedByUser) {

            [self sharedInstance].state = PNPubNubClientStateConnected;
        }

        BOOL isDisconnectForConfigurationChange = [self sharedInstance].state == PNPubNubClientStateDisconnectingOnConfigurationChange;
        
        // Remove PubNub client from list which help to observe various events
        [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self oneTimeEvent:YES];
        if ([self sharedInstance].state != PNPubNubClientStateDisconnectingOnConfigurationChange) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"DISCONNECTING... (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            [[self sharedInstance].cache purgeAllState];

            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnabledChannelsObserver];
            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsDisableObserver];
            [[PNObservationCenter defaultCenter] removeClientAsParticipantsListDownloadObserver];
            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsRemoveObserver];
            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnableObserver];
            [[PNObservationCenter defaultCenter] removeClientAsTimeTokenReceivingObserver];
            [[PNObservationCenter defaultCenter] removeClientAsMessageProcessingObserver];
            [[PNObservationCenter defaultCenter] removeClientAsHistoryDownloadObserver];
            [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
            [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];
            [[PNObservationCenter defaultCenter] removeClientAsPresenceDisabling];
            [[PNObservationCenter defaultCenter] removeClientAsPresenceEnabling];
        }
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"DISCONNECTING TO CHANGE CONFIGURATION (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
        }

        [[self sharedInstance].configuration shouldKillDNSCache:NO];



        // Check whether application has been suspended or not
        if ([self sharedInstance].state == PNPubNubClientStateSuspended || [[self sharedInstance] isResuming]) {

            [self sharedInstance].state = PNPubNubClientStateConnected;
        }

        
        // Check whether should update state to 'disconnecting'
        if ([[self sharedInstance] isConnected]) {
            
            // Mark that client is disconnecting from remote PubNub services on user request (or by internal client
            // request when updating configuration)
            [self sharedInstance].state = PNPubNubClientStateDisconnecting;
        }
        
        // Reset client runtime flags and properties
        [self sharedInstance].connectOnServiceReachabilityCheck = NO;
        [self sharedInstance].connectOnServiceReachability = NO;
        [self sharedInstance].updatingClientIdentifier = NO;
        [self sharedInstance].restoringConnection = NO;
        
        
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

            if ([self sharedInstance].state != PNPubNubClientStateDisconnected) {

                // Mark that client completely disconnected from origin server (synchronous disconnection was made to
                // prevent asynchronous disconnect event from overlapping on connection event)
                [self sharedInstance].state = PNPubNubClientStateDisconnected;
            }

            // Clean up cached data
            [PNChannel purgeChannelsCache];

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"DISCONNECTED (BASICALLY TERMINATED, "
                         "BECAUSE REQUEST WAS ISSUED BY USER) (STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            if ([[self sharedInstance].delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {

                [[self sharedInstance].delegate pubnubClient:[self sharedInstance]
                                     didDisconnectFromOrigin:[self sharedInstance].configuration.origin];
            }

            [[self sharedInstance] sendNotification:kPNClientDidDisconnectFromOriginNotification
                                         withObject:[self sharedInstance].configuration.origin];

            [PNLogger logDelegateMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"PubNub disconnected from origin: %@)", [self sharedInstance].configuration.origin];
            }];

            [[self sharedInstance] flushPostponedMethods:YES];

            [[self sharedInstance] handleLockingOperationComplete:YES];
        }
        else {
            
            // Empty connection pool after connection will be closed
            [PNConnection closeAllConnections];
            [[self subscribedChannels] makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];
            
            connectionsTerminationBlock(YES);

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"DISCONNECTED (STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
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

                // Refresh reachability configuration
                [[self sharedInstance].reachability startServiceReachabilityMonitoring];
                
                
                // Restore connection which will use new configuration
                [self connect];
            });
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE DISCONNECTION (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
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

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO DISCONNECT FOR CONFIGURATION CHANGE (STATE: %@)",
                [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self performAsyncLockingBlock:^{

        [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

            return [NSString stringWithFormat:@"DISCONNECTING FOR CONFIGURATION CHANGE "
                    "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
        }];

        [[self sharedInstance] stopHeartbeatTimer];

        // Mark that client is closing connection because of settings update
        [self sharedInstance].state = PNPubNubClientStateDisconnectingOnConfigurationChange;

        [[self sharedInstance].messagingChannel disconnectWithEvent:NO];
        [[self sharedInstance].serviceChannel disconnectWithEvent:NO];

        // Empty connection pool after connection will be closed
        [PNConnection closeAllConnections];
        
        // Sumulate disconnection, because streams not capable for it at this moment
        [[self sharedInstance] connectionChannel:nil didDisconnectFromOrigin:[self sharedInstance].configuration.origin];
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE DISCONNECTION FOR CONFIGURATION CHANGE "
                           "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
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

+ (PNConfiguration *)configuration {
    
    return [[self sharedInstance].configuration copy];
}

+ (void)setConfiguration:(PNConfiguration *)configuration {
    
    [self setupWithConfiguration:configuration andDelegate:[self sharedInstance].delegate];
}

+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRY UPDATE CONFIGURATION (STATE: %@)",
                [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    // Ensure that configuration is valid before update/set client configuration to it
    if ([configuration isValid]) {

        [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

            return [NSString stringWithFormat:@"VALID CONFIGURATION HAS BEEN PROVIDED (STATE: %@)",
                    [self humanReadableStateFrom:[self sharedInstance].state]];
        }];

        // Ensure that this is updated configuration (or new)
        if (![configuration isEqual:[self sharedInstance].configuration]) {

            void(^updateConfigurationBlock)(void) = ^{

                [self sharedInstance].configuration = configuration;

                [[self sharedInstance] prepareCryptoHelper];
            };

            void(^reachabilityConfigurationBlock)(BOOL) = ^(BOOL isInitialConfiguration) {

                if (isInitialConfiguration) {

                    // Restart reachability monitor
                    [[self sharedInstance].reachability startServiceReachabilityMonitoring];
                }
                else {

                    // Refresh reachability configuration
                    [[self sharedInstance].reachability restartServiceReachabilityMonitoring];
                }
            };

            [self setDelegate:delegate];

            BOOL canUpdateConfiguration = YES;
            BOOL isInitialConfiguration = [self sharedInstance].configuration == nil;

            // Check whether PubNub client is connected to remote PubNub services or not
            if ([[self sharedInstance] isConnected]) {

                // Check whether new configuration changed critical properties of client configuration or not
                if([[self sharedInstance].configuration requiresConnectionResetWithConfiguration:configuration]) {

                    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                        return [NSString stringWithFormat:@"CONFIGURATION UPDATE REQUIRE RECONNECTION "
                                "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
                    }];

                    // Store new configuration while client is disconnecting
                    [self sharedInstance].temporaryConfiguration = configuration;

                    // Disconnect before client configuration update
                    [self disconnectForConfigurationChange];
                }
                else {

                    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                        return [NSString stringWithFormat:@"CONFIGURATION CAN BE APPLIED W/O RECONNECTION "
                                "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
                    }];

                    updateConfigurationBlock();
                    reachabilityConfigurationBlock(isInitialConfiguration);
                }
            }
            else if ([[self sharedInstance] isRestoringConnection] || [[self sharedInstance] isResuming] ||
                    [self sharedInstance].state == PNPubNubClientStateConnecting) {

                [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                    return [NSString stringWithFormat:@"CONFIGURATION UPDATE IN THE MIDDLE OF CONNECTION "
                            "SEQUENCE. CLOSE CHANNELS AND RECONNECT. (STATE: %@)",
                            [self humanReadableStateFrom:[self sharedInstance].state]];
                }];

                // Disconnecting communication channels and preserve all issued requests which wasn't sent till
                // this moment (they will be send as soon as connection will be restored)
                [[self sharedInstance].messagingChannel disconnectWithEvent:NO];
                [[self sharedInstance].serviceChannel disconnectWithEvent:NO];

                [self sharedInstance].state = PNPubNubClientStateDisconnected;

                reachabilityConfigurationBlock(isInitialConfiguration);

                [self connect];
            }
            else if (canUpdateConfiguration) {

                [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                    return [NSString stringWithFormat:@"CONFIGURATION CAN BE APPLIED W/O RECONNECTION "
                            "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
                }];

                updateConfigurationBlock();

                reachabilityConfigurationBlock(isInitialConfiguration);
            }
        }
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"IGNORE CONFIGURATION UPDATE. IT IS THE SAME AS WAS SET "
                        "BEFORE (STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
        }
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

    [self setClientIdentifier:identifier shouldCatchup:NO];
}

+ (void)setClientIdentifier:(NSString *)identifier shouldCatchup:(BOOL)shouldCatchup {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO UPDATE CLIENT IDENTIFIER (STATE: %@)",
                [self humanReadableStateFrom:[self sharedInstance].state]];
    }];

    if (![[self sharedInstance].clientIdentifier isEqualToString:identifier]) {

        [self performAsyncLockingBlock:^{

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"UPDATE CLIENT IDENTIFIER (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            // Check whether identifier has been changed since last method call or not
            if ([[self sharedInstance] isConnected]) {

                [self sharedInstance].userProvidedClientIdentifier = identifier != nil;

                NSArray *allChannels = [[self sharedInstance].messagingChannel fullSubscribedChannelsList];
                if ([allChannels count]) {
                    
                    [self sharedInstance].asyncLockingOperationInProgress = NO;
                    if (shouldCatchup) {

                        [allChannels makeObjectsPerformSelector:@selector(lockTimeTokenChange)];
                    }

                    __block NSUInteger resubscribeRetryCount = 0;
                    __block __pn_desired_weak PubNub *weakSharedInstance = [self sharedInstance];
                    __block void(^retrySubscription)(PNError *);
                    __block void(^retryUnsubscription)(PNError *);
                    
                    void(^resubscribeErrorBlock)(PNError *, void(^)(void)) = ^(PNError *resubscriptionError, void(^block)(void)) {

                        if (resubscribeRetryCount < kPNClientIdentifierUpdateRetryCount) {

                            resubscribeRetryCount++;
                            block();
                        }
                        else {

                            weakSharedInstance.updatingClientIdentifier = NO;
                            [allChannels makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];

                            [weakSharedInstance notifyDelegateAboutSubscriptionFailWithError:resubscriptionError
                                                                    completeLockingOperation:YES];
                        }
                    };

                    void(^subscribeBlock)(void) = ^{
                        
                        weakSharedInstance.asyncLockingOperationInProgress = NO;
                        [self subscribeOnChannels:allChannels withCatchUp:shouldCatchup clientState:nil
                       andCompletionHandlingBlock:^(PNSubscriptionProcessState state,
                                                    NSArray *subscribedChannels,
                                                    PNError *subscribeError) {

                           if (subscribeError == nil) {

                               weakSharedInstance.updatingClientIdentifier = NO;
                               [allChannels makeObjectsPerformSelector:@selector(unlockTimeTokenChange)];

                               [weakSharedInstance handleLockingOperationComplete:YES];
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
                        
                        weakSharedInstance.asyncLockingOperationInProgress = NO;
                        [self unsubscribeFromChannels:allChannels
                          withCompletionHandlingBlock:^(NSArray *leavedChannels, PNError *leaveError) {

                               if (leaveError == nil) {

                                   // Check whether user identifier was provided by user or not
                                   if (identifier == nil) {

                                       // Change user identifier before connect to the PubNub services
                                       weakSharedInstance.clientIdentifier = [PNHelper UUID];
                                   }
                                   else {

                                       weakSharedInstance.clientIdentifier = identifier;
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
                    
                    [self sharedInstance].clientIdentifier = identifier;
                    [self sharedInstance].userProvidedClientIdentifier = identifier != nil;
                    [[self sharedInstance] handleLockingOperationComplete:YES];
                }
            }
            else {

                [self sharedInstance].clientIdentifier = identifier;
                [self sharedInstance].userProvidedClientIdentifier = identifier != nil;
                [[self sharedInstance] handleLockingOperationComplete:YES];
            }
        }
               postponedExecutionBlock:^{

                   [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                       return [NSString stringWithFormat:@"POSTPONE CLIENT IDENTIFIER CHANGE (STATE: %@)",
                               [self humanReadableStateFrom:[self sharedInstance].state]];
                   }];

                   [self postponeSetClientIdentifier:identifier];
               }];
    }
    else {

        [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

            return [NSString stringWithFormat:@"IGNORE IDENTIFIER UPDATE. IT IS THE SAME AS WAS SET "
                    "BEFORE (STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
        }];
    }
}

+ (void)postponeSetClientIdentifier:(NSString *)identifier {
    
    [[self sharedInstance] postponeSelector:@selector(setClientIdentifier:) forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:identifier]] outOfOrder:NO];
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


#pragma mark - Client state management

+ (void)requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel {

    [self requestClientState:clientIdentifier forChannel:channel withCompletionHandlingBlock:nil];
}

+ (void) requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO REQUEST CLIENT STATE FOR IDENTIFIER %@ ON CHANNEL: %@ (STATE: %@)",
                clientIdentifier, channel, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];

    [self performAsyncLockingBlock:^{

        if (!handlerBlock || (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]])) {
            
            [[PNObservationCenter defaultCenter] removeClientAsStateRequestObserver];
        }

        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"REQUEST CLIENT STATE FOR IDENTIFIER %@ ON CHANNEL: %@ (STATE: %@)",
                        clientIdentifier, channel, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {

                [[PNObservationCenter defaultCenter] addClientAsStateRequestObserverWithBlock:[handlerBlock copy]];
            }

            PNClientStateRequest *request = [PNClientStateRequest clientStateRequestForIdentifier:clientIdentifier
                                                                                       andChannel:channel];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T REQUEST CLIENT STATE FOR IDENTIFIER %@ ON CHANNEL: %@ (STATE: %@)",
                        clientIdentifier, channel, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];


            PNError *requestError = [PNError errorWithCode:statusCode];
            requestError.associatedObject = [PNClient clientForIdentifier:clientIdentifier channel:channel andData:nil];

            [[self sharedInstance] notifyDelegateAboutStateRetrievalDidFailWithError:requestError];


            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {

                handlerBlock(requestError.associatedObject, requestError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE CLIENT STATE REQUEST (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];

               [self postponeRequestClientState:clientIdentifier forChannel:channel
                     witCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeRequestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
        witCompletionHandlingBlock:(id)handlerBlock {

    [[self sharedInstance] postponeSelector:@selector(requestClientState:forChannel:withCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:clientIdentifier], [PNHelper nilifyIfNotSet:channel],
                                              [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:[handlerBlock isKindOfClass:[NSString class]]];
}

+ (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState forChannel:(PNChannel *)channel {

    [self updateClientState:clientIdentifier state:clientState forChannel:channel
withCompletionHandlingBlock:nil];
}

+ (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState forChannel:(PNChannel *)channel
 withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO UPDATE CLIENT STATE FOR IDENTIFIER %@ ON CHANNEL %@ TO: %@ (STATE: %@)",
                clientIdentifier, channel, clientState, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];

    [self performAsyncLockingBlock:^{
        
        if (!handlerBlock || (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]])) {
            
            [[PNObservationCenter defaultCenter] removeClientAsStateUpdateObserver];
        }
        
        NSDictionary *mergedClientState = @{channel.name: clientState};
        
        // Only in case if client update it's own state, we can append cached data to it.
        if ([clientIdentifier isEqualToString:self.clientIdentifier]) {
            
            mergedClientState = [[self sharedInstance].cache stateMergedWithState:mergedClientState];
        }

        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && mergedClientState && (![mergedClientState isValidState] || ![[self subscribedChannels] containsObject:channel])) {

            statusCode = kPNInvalidStatePayloadError;
            if (![[self subscribedChannels] containsObject:channel]) {
                
                statusCode = kPNCantUpdateStateForNotSubscribedChannelsError;
            }
        }
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"UPDATE CLIENT STATE FOR IDENTIFIER %@ ON CHANNEL %@ TO: %@ (STATE: %@)",
                        clientIdentifier, channel, mergedClientState, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {

                [[PNObservationCenter defaultCenter] addClientAsStateUpdateObserverWithBlock:[handlerBlock copy]];
            }

            mergedClientState = [mergedClientState valueForKeyPath:channel.name];
            PNClientStateUpdateRequest *request = [PNClientStateUpdateRequest clientStateUpdateRequestWithIdentifier:clientIdentifier
                                                                                                             channel:channel
                                                                                                      andClientState:mergedClientState];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T UPDATE CLIENT STATE FOR IDENTIFIER %@ ON CHANNEL %@ TO: %@ (STATE: %@)",
                        clientIdentifier, channel, clientState, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            PNError *requestError = [PNError errorWithCode:statusCode];
            requestError.associatedObject = [PNClient clientForIdentifier:clientIdentifier channel:channel
                                                                  andData:clientState];

            [[self sharedInstance] notifyDelegateAboutStateUpdateDidFailWithError:requestError];


            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {

                handlerBlock(requestError.associatedObject, requestError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE CLIENT STATE UPDATE (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];

               [self postponeUpdateClientState:clientIdentifier state:clientState forChannel:channel
                   withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeUpdateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState forChannel:(PNChannel *)channel
      withCompletionHandlingBlock:(id)handlerBlock {

    [[self sharedInstance] postponeSelector:@selector(updateClientState:state:forChannel:withCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:clientIdentifier], [PNHelper nilifyIfNotSet:clientState],
                                              [PNHelper nilifyIfNotSet:channel],
                                              [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:[handlerBlock isKindOfClass:[NSString class]]];
}


#pragma mark - Channels subscription management

+ (NSArray *)subscribedChannels {
    
    return [[self sharedInstance].messagingChannel subscribedChannels];
}

+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel {
    
    return [[self sharedInstance].messagingChannel isSubscribedForChannel:channel];;
}

+ (void)subscribeOnChannel:(PNChannel *)channel {
    
    [self subscribeOnChannel:channel withCompletionHandlingBlock:nil];
}

+ (void) subscribeOnChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannel:channel withClientState:nil andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState {

    [self subscribeOnChannel:channel withClientState:clientState andCompletionHandlingBlock:nil];
}

+ (void) subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    // Checking whether client state for channel has been provided in correct format or not.
    if (clientState && ![[clientState valueForKey:channel.name] isKindOfClass:[NSDictionary class]]) {

        clientState = @{channel.name: clientState};
    }

    [self subscribeOnChannels:@[channel] withClientState:clientState andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent {

    [self subscribeOnChannel:channel];
}

+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent
andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannel:channel withCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels {
    
    [self subscribeOnChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)subscribeOnChannels:(NSArray *)channels
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannels:channels withClientState:nil andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState {

    [self subscribeOnChannels:channels withClientState:clientState andCompletionHandlingBlock:nil];
}

+ (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannels:channels withCatchUp:NO clientState:clientState andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels withCatchUp:(BOOL)shouldCatchUp clientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO SUBSCRIBE ON CHANNELS: %@ (SHOULD CATCH UP? %@)(STATE: %@)",
                channels, (shouldCatchUp ? @"YES" : @"NO"), [self humanReadableStateFrom:[self sharedInstance].state]];
    }];

    [self performAsyncLockingBlock:^{

        [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
        [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];

        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && clientState && ![clientState isValidState]) {

            statusCode = kPNInvalidStatePayloadError;
        }
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"SUBSCRIBE ON CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            if (handlerBlock != nil) {

                [[PNObservationCenter defaultCenter] addClientAsSubscriptionObserverWithBlock:[handlerBlock copy]];
            }


            [[self sharedInstance].messagingChannel subscribeOnChannels:channels withCatchUp:shouldCatchUp
                                                         andClientState:clientState];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T SUBSCRIBE ON CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            PNError *subscriptionError = [PNError errorWithCode:statusCode];
            subscriptionError.associatedObject = channels;

            [[self sharedInstance] notifyDelegateAboutSubscriptionFailWithError:subscriptionError
                                                       completeLockingOperation:YES];


            if (handlerBlock) {

                handlerBlock(PNSubscriptionProcessNotSubscribedState, channels, subscriptionError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE SUBSCRIBE ON CHANNELS (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];

               [self postponeSubscribeOnChannels:channels withCatchUp:shouldCatchUp clientState:clientState
                      andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeSubscribeOnChannels:(NSArray *)channels withCatchUp:(BOOL)shouldCatchUp
                        clientState:(NSDictionary *)clientState
         andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [[self sharedInstance] postponeSelector:@selector(subscribeOnChannels:withCatchUp:clientState:andCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:channels], @(shouldCatchUp), [PNHelper nilifyIfNotSet:clientState],
                                              [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:NO];
}

+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    [self subscribeOnChannels:channels];
}

+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannels:channels withCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel {
    
    [self unsubscribeFromChannels:@[channel]];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent {
    
    [self unsubscribeFromChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFromChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent
    andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFromChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels {

    [self unsubscribeFromChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    [self unsubscribeFromChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO UNSUBSCRIBE FROM CHANNELS: %@ (STATE: %@)",
                channels, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];

    [self performAsyncLockingBlock:^{

        [[PNObservationCenter defaultCenter] removeClientAsSubscriptionObserver];
        [[PNObservationCenter defaultCenter] removeClientAsUnsubscribeObserver];

        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"UNSUBSCRIBE FROM CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            if (handlerBlock) {

                [[PNObservationCenter defaultCenter] addClientAsUnsubscribeObserverWithBlock:[handlerBlock copy]];
            }


            [[self sharedInstance].messagingChannel unsubscribeFromChannels:channels];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T UNSUBSCRIBE FROM CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            PNError *unsubscriptionError = [PNError errorWithCode:statusCode];
            unsubscriptionError.associatedObject = channels;

            [[self sharedInstance] notifyDelegateAboutUnsubscriptionFailWithError:unsubscriptionError
                                                         completeLockingOperation:YES];


            if (handlerBlock) {

                handlerBlock(channels, unsubscriptionError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE UNSUBSCRIBE FROM CHANNELS (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];

               [self postponeUnsubscribeFromChannels:channels
                         withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeUnsubscribeFromChannels:(NSArray *)channels
            withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [[self sharedInstance] postponeSelector:@selector(unsubscribeFromChannels:withCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:channels], [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:NO];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent
     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFromChannels:channels withCompletionHandlingBlock:handlerBlock];
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

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO ENABLE PUSH NOTIFICATIONS ON CHANNELS: %@ (STATE: "
                "%@)", channels, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        if (!handlerBlock || (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]])) {
        
            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnableObserver];
            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsDisableObserver];
        }
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && pushToken != nil) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"ENABLE PUSH NOTIFICATIONS ON CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsEnableObserverWithBlock:[handlerBlock copy]];
            }
            
            PNPushNotificationsStateChangeRequest *request;
            request = [PNPushNotificationsStateChangeRequest requestWithDevicePushToken:pushToken
                                                                                toState:PNPushNotificationsState.enable
                                                                            forChannels:channels];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T ENABLE PUSH NOTIFICATIONS FOR CHANNELS: %@ "
                        "(STATE: %@)", channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (pushToken == nil) {
                
                statusCode = kPNDevicePushTokenIsEmptyError;
            }
            PNError *stateChangeError = [PNError errorWithCode:statusCode];
            stateChangeError.associatedObject = channels;
            
            [[self sharedInstance] notifyDelegateAboutPushNotificationsEnableFailedWithError:stateChangeError];
            
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {
                
                handlerBlock(channels, stateChangeError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE ENABLE PUSH NOTIFICATIONS FOR CHANNELS "
                           "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
               [self postponeEnablePushNotificationsOnChannels:channels
                                           withDevicePushToken:pushToken
                                    andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeEnablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                       andCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(enablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector forObject:self
                             withParameters:@[channels, [PNHelper nilifyIfNotSet:pushToken],
                                              [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:[handlerBlock isKindOfClass:[NSString class]]];
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

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO DISABLE PUSH NOTIFICATIONS ON CHANNELS: %@ (STATE: "
                "%@)", channels, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        if (!handlerBlock || (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]])) {
        
            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnableObserver];
            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsDisableObserver];
        }
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && pushToken != nil) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"DISABLE PUSH NOTIFICATIONS ON CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsDisableObserverWithBlock:[handlerBlock copy]];
            }
            
            PNPushNotificationsStateChangeRequest *request;
            request = [PNPushNotificationsStateChangeRequest requestWithDevicePushToken:pushToken
                                                                                toState:PNPushNotificationsState.disable
                                                                            forChannels:channels];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T DISABLE PUSH NOTIFICATIONS FOR CHANNELS: %@ "
                        "(STATE: %@)", channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            if (pushToken == nil) {

                statusCode = kPNDevicePushTokenIsEmptyError;
            }
            
            PNError *stateChangeError = [PNError errorWithCode:statusCode];
            stateChangeError.associatedObject = channels;
            
            [[self sharedInstance] notifyDelegateAboutPushNotificationsDisableFailedWithError:stateChangeError];
            
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {
                
                handlerBlock(channels, stateChangeError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE DISABLE PUSH NOTIFICATIONS FOR CHANNELS "
                           "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
               [self postponeDisablePushNotificationsOnChannels:channels
                                            withDevicePushToken:pushToken
                                     andCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeDisablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                        andCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(disablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector forObject:self withParameters:@[channels, pushToken,
                                              [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:[handlerBlock isKindOfClass:[NSString class]]];
}

+ (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO DISABLE PUSH NOTIFICATIONS FROM ALL CHANNELS (STATE: "
                "%@)", [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        if (!handlerBlock || (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]])) {
        
            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsRemoveObserver];
        }
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && pushToken != nil) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"DISABLE PUSH NOTIFICATIONS FROM ALL CHANNELS (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsRemoveObserverWithBlock:[handlerBlock copy]];
            }
            
            [[self sharedInstance] sendRequest:[PNPushNotificationsRemoveRequest requestWithDevicePushToken:pushToken]
                       shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T DISABLE PUSH NOTIFICATIONS FROM ALL CHANNELS "
                        "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            if (pushToken == nil) {

                statusCode = kPNDevicePushTokenIsEmptyError;
            }
            
            PNError *removalError = [PNError errorWithCode:statusCode];
            [[self sharedInstance] notifyDelegateAboutPushNotificationsRemoveFailedWithError:removalError];
            
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {
                
                handlerBlock(removalError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE PUSH NOTIFICATIONS DISABLE FROM ALL "
                                          "CHANNELS (STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
               [self postponeRemoveAllPushNotificationsForDevicePushToken:pushToken
                                              withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeRemoveAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                                 withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(removeAllPushNotificationsForDevicePushToken:withCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector forObject:self
                             withParameters:@[pushToken, [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:[handlerBlock isKindOfClass:[NSString class]]];
}

+ (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO FETCH PUSH NOTIFICATION ENABLED CHANNELS (STATE: %@)",
                [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        if (!handlerBlock || (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]])) {
        
            [[PNObservationCenter defaultCenter] removeClientAsPushNotificationsEnabledChannelsObserver];
        }
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && pushToken != nil) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"FETCH PUSH NOTIFICATION ENABLED CHANNELS (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {
                
                [[PNObservationCenter defaultCenter] addClientAsPushNotificationsEnabledChannelsObserverWithBlock:[handlerBlock copy]];
            }
            
            [[self sharedInstance] sendRequest:[PNPushNotificationsEnabledChannelsRequest requestWithDevicePushToken:pushToken]
                       shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T FETCH PUSH NOTIFICATION ENABLED CHANNELS (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (pushToken == nil) {

                statusCode = kPNDevicePushTokenIsEmptyError;
            }
            
            PNError *listRetrieveError = [PNError errorWithCode:statusCode];
            
            [[self sharedInstance] notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:listRetrieveError];
            
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {
                
                handlerBlock(nil, listRetrieveError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE PUSH NOTIFICATION ENABLED CHANNELS FETCH "
                           "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
               [self postponeRequestPushNotificationEnabledChannelsForDevicePushToken:pushToken
                                                          withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeRequestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                             withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(requestPushNotificationEnabledChannelsForDevicePushToken:withCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector forObject:self
                             withParameters:@[pushToken, [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:[handlerBlock isKindOfClass:[NSString class]]];
}


#pragma mark - PAM management

+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration {

    [self grantReadAccessRightForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:PNReadAccessRight clients:nil
                              forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration {

    [self grantWriteAccessRightForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                         andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:PNWriteAccessRight clients:nil
                              forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration {

    [self grantAllAccessRightsForApplicationAtPeriod:accessPeriodDuration andCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:(PNReadAccessRight | PNWriteAccessRight) clients:nil
                              forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForApplication {

    [self revokeAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:nil accessRights:PNNoAccessRights clients:nil forPeriod:0
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration {

    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self grantReadAccessRightForChannels:(channel ? @[channel] : nil) forPeriod:accessPeriodDuration
              withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey {

    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration client:clientAuthorizationKey
             withCompletionHandlingBlock:nil];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration
                                 clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
             withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration {

    [self grantReadAccessRightForChannels:channels forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
                                          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:channels accessRights:PNReadAccessRight clients:nil
                              forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys {

    [self grantReadAccessRightForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
             withCompletionHandlingBlock:nil];

}
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:PNReadAccessRight
                                clients:clientsAuthorizationKeys forPeriod:accessPeriodDuration
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration {

    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self grantWriteAccessRightForChannels:(channel ? @[channel] : nil) forPeriod:accessPeriodDuration
              withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                                                client:(NSString *)clientAuthorizationKey {

    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration client:clientAuthorizationKey
              withCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration
                                  clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
              withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration {

    [self grantWriteAccessRightForChannels:channels forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
             withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:channels accessRights:PNWriteAccessRight clients:nil
                              forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys {

    [self grantWriteAccessRightForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
              withCompletionHandlingBlock:nil];
}

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:PNWriteAccessRight
                                clients:clientsAuthorizationKeys forPeriod:accessPeriodDuration
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration {

    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self grantAllAccessRightsForChannels:(channel ? @[channel] : nil) forPeriod:accessPeriodDuration
              withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey {

    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration client:clientAuthorizationKey
             withCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration
                                 clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
             withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration {

    [self grantAllAccessRightsForChannels:channels forPeriod:accessPeriodDuration withCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:channels accessRights:(PNReadAccessRight | PNWriteAccessRight)
                                clients:nil forPeriod:accessPeriodDuration withCompletionHandlingBlock:handlerBlock];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys {

    [self grantAllAccessRightsForChannel:channel forPeriod:accessPeriodDuration clients:clientsAuthorizationKeys
             withCompletionHandlingBlock:nil];
}

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:(channel ? @[channel] : nil)
                           accessRights:(PNReadAccessRight | PNWriteAccessRight)
                                clients:clientsAuthorizationKeys
                              forPeriod:accessPeriodDuration
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel {

    [self revokeAccessRightsForChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self revokeAccessRightsForChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey {

    [self revokeAccessRightsForChannel:channel client:clientAuthorizationKey withCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self revokeAccessRightsForChannel:channel clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
           withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForChannels:(NSArray *)channels {

    [self revokeAccessRightsForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForChannels:(NSArray *)channels
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:channels accessRights:PNNoAccessRights clients:nil forPeriod:0
            withCompletionHandlingBlock:handlerBlock];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {

    [self revokeAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self changeAccessRightsForChannels:(channel ? @[channel] : nil) accessRights:PNNoAccessRights
                                clients:clientsAuthorizationKeys forPeriod:0 withCompletionHandlingBlock:handlerBlock];
}

+ (void)changeAccessRightsForChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                              clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSInteger)accessPeriodDuration
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO CHANGE ACCESS RIGHTS (STATE: %@)",
                [self humanReadableStateFrom:[self sharedInstance].state]];
    }];


    // Initialize arrays in case if used specified \a 'nil' for \a 'channels' and/or \a 'clientsAuthorizationKeys'
    channels = channels ? channels : @[];
    clientsAuthorizationKeys = clientsAuthorizationKeys ? clientsAuthorizationKeys : @[];


    [self performAsyncLockingBlock:^{
        
        if (!handlerBlock || (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]])) {
            
            [[PNObservationCenter defaultCenter] removeClientAsAccessRightsChangeObserver];
        }
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && [[self sharedInstance].configuration.secretKey length]) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CHANGE ACCESS RIGHTS (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {

                [[PNObservationCenter defaultCenter] addClientAsAccessRightsChangeObserverWithBlock:[handlerBlock copy]];
            }

            [[[self sharedInstance] serviceChannel] changeAccessRightsForChannels:channels accessRights:accessRights
                                                                authorizationKeys:clientsAuthorizationKeys
                                                                        forPeriod:accessPeriodDuration];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T CHANGE ACCESS RIGHTS (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication:[self sharedInstance].configuration.subscriptionKey
                                                                                        withRights:accessRights
                                                                                          channels:channels
                                                                                           clients:clientsAuthorizationKeys
                                                                                      accessPeriod:accessPeriodDuration];
            if (![[self sharedInstance].configuration.secretKey length]) {

                statusCode = kPNSecretKeyNotSpecifiedError;
            }
            PNError *accessRightChangeError = [PNError errorWithCode:statusCode];
            accessRightChangeError.associatedObject = options;

            [[self sharedInstance] notifyDelegateAboutAccessRightsChangeFailedWithError:accessRightChangeError];
            
            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {
                
                handlerBlock(nil, accessRightChangeError);
            }
            
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE ACCESS RIGHTS CHANGE (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];

               [self postponeChangeAccessRightsForChannels:channels accessRights:accessRights
                                                   clients:clientsAuthorizationKeys forPeriod:accessPeriodDuration
                               withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
               
    }];
    
}

+ (void)postponeChangeAccessRightsForChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                                      clients:(NSArray *)clientsAuthorizationKeys
                                    forPeriod:(NSInteger)accessPeriodDuration
                  withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL selector = @selector(changeAccessRightsForChannels:accessRights:clients:forPeriod:withCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector
                                  forObject:self
                             withParameters:@[channels, [NSNumber numberWithUnsignedLong:accessRights],
                                              clientsAuthorizationKeys, [NSNumber numberWithInteger:accessPeriodDuration],
                                              [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:[handlerBlock isKindOfClass:[NSString class]]];
}

+ (void)auditAccessRightsForApplication {

    [self auditAccessRightsForApplicationWithCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [self auditAccessRightsForChannel:nil withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel {

    [self auditAccessRightsForChannel:nil withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [self auditAccessRightsForChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey {

    [self auditAccessRightsForChannel:channel client:clientAuthorizationKey withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [self auditAccessRightsForChannel:channel clients:(clientAuthorizationKey ? @[clientAuthorizationKey] : nil)
          withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannels:(NSArray *)channels {

    [self auditAccessRightsForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannels:(NSArray *)channels
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [self auditAccessRightsForChannels:channels clients:nil withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys {

    [self auditAccessRightsForChannel:channel clients:clientsAuthorizationKeys withCompletionHandlingBlock:nil];
}

+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [self auditAccessRightsForChannels:(channel ? @[channel] : nil) clients:clientsAuthorizationKeys
           withCompletionHandlingBlock:handlerBlock];
}

+ (void)auditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO AUDIT ACCESS RIGHTS (STATE: %@)",
                [self humanReadableStateFrom:[self sharedInstance].state]];
    }];


    // Initialize arrays in case if used specified \a 'nil' for \a 'channels' and/or \a 'clientsAuthorizationKeys'
    channels = channels ? channels : @[];
    clientsAuthorizationKeys = clientsAuthorizationKeys ? clientsAuthorizationKeys : @[];


    [self performAsyncLockingBlock:^{
        
        if (!handlerBlock || (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]])) {
            
            [[PNObservationCenter defaultCenter] removeClientAsAccessRightsAuditObserver];
        }

        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && [[self sharedInstance].configuration.secretKey length]) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"ACCESS RIGHTS AUDIT (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {

                [[PNObservationCenter defaultCenter] addClientAsAccessRightsAuditObserverWithBlock:[handlerBlock copy]];
            }

            [[self sharedInstance].serviceChannel auditAccessRightsForChannels:channels
                                                                       clients:clientsAuthorizationKeys];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T AUDIT ACCESS RIGHTS (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            PNAccessRightOptions *options = [PNAccessRightOptions accessRightOptionsForApplication:[self sharedInstance].configuration.subscriptionKey
                                                                                        withRights:PNUnknownAccessRights
                                                                                          channels:channels
                                                                                           clients:clientsAuthorizationKeys
                                                                                      accessPeriod:0];
            if (![[self sharedInstance].configuration.secretKey length]) {

                statusCode = kPNSecretKeyNotSpecifiedError;
            }
            PNError *accessRightAuditError = [PNError errorWithCode:statusCode];
            accessRightAuditError.associatedObject = options;

            [[self sharedInstance] notifyDelegateAboutAccessRightsAuditFailedWithError:accessRightAuditError];


            if (handlerBlock && ![handlerBlock isKindOfClass:[NSString class]]) {

                handlerBlock(nil, accessRightAuditError);
            }

        }
    }
            postponedExecutionBlock:^{

                [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                    return [NSString stringWithFormat:@"POSTPONE ACCESS RIGHTS AUDIT (STATE: %@)",
                            [self humanReadableStateFrom:[self sharedInstance].state]];
                }];

                [self postponeAuditAccessRightsForChannels:channels clients:clientsAuthorizationKeys
                               withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
            }];
}

+ (void)postponeAuditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys
                 withCompletionHandlingBlock:(id)handlerBlock {

    SEL selector = @selector(auditAccessRightsForChannels:clients:withCompletionHandlingBlock:);
    [[self sharedInstance] postponeSelector:selector
                                  forObject:self
                             withParameters:@[channels, clientsAuthorizationKeys,
                                              [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:[handlerBlock isKindOfClass:[NSString class]]];
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

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO ENABLE PRESENCE ON CHANNELS: %@ (STATE: %@)",
                channels, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsPresenceEnabling];
        [[PNObservationCenter defaultCenter] removeClientAsPresenceDisabling];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"ENABLING PRESENCE ON CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (handlerBlock != nil) {
                
                [[PNObservationCenter defaultCenter] addClientAsPresenceEnablingObserverWithBlock:[handlerBlock copy]];
            }
            
            // Enumerate over the list of channels and mark that it should observe for presence
            [channels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx, BOOL *channelEnumeratorStop) {
                
                channel.observePresence = YES;
                channel.linkedWithPresenceObservationChannel = NO;
            }];
            
            [[self sharedInstance].messagingChannel enablePresenceObservationForChannels:channels];
        }
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T ENABLE PRESENCE ON CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            PNError *presenceEnableError = [PNError errorWithCode:statusCode];
            presenceEnableError.associatedObject = channels;
            
            
            [[self sharedInstance] notifyDelegateAboutPresenceEnablingFailWithError:presenceEnableError
                                                           completeLockingOperation:YES];
            
            if (handlerBlock != nil) {
                
                handlerBlock(channels, presenceEnableError);
            }
        }
        
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE PRESENCE ENABLING ON CHANNELS (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
               [self postponeEnablePresenceObservationForChannels:channels
                                      withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeEnablePresenceObservationForChannels:(NSArray *)channels
                         withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {
    
    [[self sharedInstance] postponeSelector:@selector(enablePresenceObservationForChannels:withCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:channels], [PNHelper nilifyIfNotSet:handlerBlock]]
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

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO DISABLE PRESENCE ON CHANNELS: %@ (STATE: %@)",
                channels, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        [[PNObservationCenter defaultCenter] removeClientAsPresenceEnabling];
        [[PNObservationCenter defaultCenter] removeClientAsPresenceDisabling];
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"DISABLING PRESENCE ON CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (handlerBlock != nil) {
                
                [[PNObservationCenter defaultCenter] addClientAsPresenceDisablingObserverWithBlock:[handlerBlock copy]];
            }
            
            [[self sharedInstance].messagingChannel disablePresenceObservationForChannels:channels];
        }
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T DISABLE PRESENCE ON CHANNELS: %@ (STATE: %@)",
                        channels, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            PNError *presencedisableError = [PNError errorWithCode:statusCode];
            presencedisableError.associatedObject = channels;
            
            
            [[self sharedInstance] notifyDelegateAboutPresenceDisablingFailWithError:presencedisableError
                                                            completeLockingOperation:YES];
            
            if (handlerBlock != nil) {
                
                handlerBlock(channels, presencedisableError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE PRESENCE DISABLING ON CHANNELS (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
               [self postponeDisablePresenceObservationForChannels:channels
                                       withCompletionHandlingBlock:(handlerBlock ? [handlerBlock copy] : nil)];
           }];
}

+ (void)postponeDisablePresenceObservationForChannels:(NSArray *)channels
                          withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {
    
    [[self sharedInstance] postponeSelector:@selector(disablePresenceObservationForChannels:withCompletionHandlingBlock:)
                                  forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:channels], [PNHelper nilifyIfNotSet:handlerBlock]]
                                 outOfOrder:NO];
}


#pragma mark - Time token

+ (void)requestServerTimeToken {
    
    [self requestServerTimeTokenWithCompletionBlock:nil];
}

+ (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING REQUEST SERVER TIME TOKEN (STATE: %@)",
                [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"REQUEST SERVER TIME TOKEN (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (!success || (success && ![success isKindOfClass:[NSString class]])) {
                
                [[PNObservationCenter defaultCenter] removeClientAsTimeTokenReceivingObserver];
            }
            if (success && ![success isKindOfClass:[NSString class]]) {
                
                [[PNObservationCenter defaultCenter] addClientAsTimeTokenReceivingObserverWithCallbackBlock:[success copy]];
            }
            
            
            [[self sharedInstance] sendRequest:[PNTimeTokenRequest new] shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T REQUEST SERVER TIME TOKEN (STATE: %@)",
                        [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            PNError *timeTokenError = [PNError errorWithCode:statusCode];
            
            [[self sharedInstance] notifyDelegateAboutTimeTokenRetrievalFailWithError:timeTokenError];
            
            
            if (success && ![success isKindOfClass:[NSString class]]) {
                
                success(nil, timeTokenError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE SERVER TIME TOKEN REQUEST (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
               [self postponeRequestServerTimeTokenWithCompletionBlock:(success ? [success copy] : nil)];
           }];
}

+ (void)postponeRequestServerTimeTokenWithCompletionBlock:(id)success {
    
    [[self sharedInstance] postponeSelector:@selector(requestServerTimeTokenWithCompletionBlock:)
                                  forObject:self withParameters:@[[PNHelper nilifyIfNotSet:success]]
                                 outOfOrder:[success isKindOfClass:[NSString class]]];
}


#pragma mark - Messages processing methods

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message toChannel:channel compressed:NO];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage {
    
    return [self sendMessage:message toChannel:channel compressed:shouldCompressMessage withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message toChannel:channel compressed:NO withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO SEND MESSAGE: %@ ON CHANNEL: %@ (STATE: %@)",
                message, channel, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    // Create object instance
    PNError *error = nil;
    PNMessage *messageObject = [PNMessage messageWithObject:message forChannel:channel compressed:shouldCompressMessage error:&error];
    
    [self performAsyncLockingBlock:^{
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && error == nil) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"SEND MESSAGE: %@ ON CHANNEL: %@ (STATE: %@)",
                        message, channel, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (!success || (success && ![success isKindOfClass:[NSString class]])) {
            
                [[PNObservationCenter defaultCenter] removeClientAsMessageProcessingObserver];
            }
            if (success && ![success isKindOfClass:[NSString class]]) {
                
                [[PNObservationCenter defaultCenter] addClientAsMessageProcessingObserverWithBlock:[success copy]];
            }
            
            [[self sharedInstance].serviceChannel sendMessage:messageObject];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T SEND MESSAGE: %@ ON CHANNEL: %@ (STATE: %@)",
                        message, channel, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            PNError *sendingError = error?error:[PNError errorWithCode:statusCode];
            sendingError.associatedObject = messageObject;
            
            [[self sharedInstance] notifyDelegateAboutMessageSendingFailedWithError:sendingError];
            
            
            if (success && ![success isKindOfClass:[NSString class]]) {
                
                success(PNMessageSendingError, sendingError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE MESSAGE SENDING (STATE: %@)",
                           [self humanReadableStateFrom:[self sharedInstance].state]];
               }];
               
               [self postponeSendMessage:message toChannel:channel compressed:shouldCompressMessage
                     withCompletionBlock:(success ? [success copy] : nil)];
           }];
    
    
    return messageObject;
}

+ (void)postponeSendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
        withCompletionBlock:(id)success {
    
    [[self sharedInstance] postponeSelector:@selector(sendMessage:toChannel:compressed:withCompletionBlock:)
                                  forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:message], [PNHelper nilifyIfNotSet:channel], @(shouldCompressMessage),
                                              [PNHelper nilifyIfNotSet:success]]
                                 outOfOrder:[success isKindOfClass:[NSString class]]];
}

+ (void)sendMessage:(PNMessage *)message {
    
    [self sendMessage:message compressed:NO];
}

+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage {
    
    [self sendMessage:message.message toChannel:message.channel compressed:shouldCompressMessage withCompletionBlock:nil];
}

+ (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message.message compressed:NO withCompletionBlock:success];
}

+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message.message toChannel:message.channel compressed:shouldCompressMessage withCompletionBlock:success];
}


#pragma mark - History methods

+ (void)requestFullHistoryForChannel:(PNChannel *)channel {
    
    [self requestFullHistoryForChannel:channel includingTimeToken:NO];
}

+ (void)requestFullHistoryForChannel:(PNChannel *)channel
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestFullHistoryForChannel:channel includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestFullHistoryForChannel:channel includingTimeToken:shouldIncludeTimeToken withCompletionBlock:nil];
}

+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:nil includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate {
    
    [self requestHistoryForChannel:channel from:startDate includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel from:startDate to:nil includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate includingTimeToken:NO
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:0 includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit includingTimeToken:NO
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:NO
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO REQUEST HISTORY FOR CHANNEL: %@ (STATE: %@)",
                channel, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"REQUEST HISTORY FOR CHANNEL: %@ (STATE: %@)",
                        channel, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (!handleBlock || (handleBlock && ![handleBlock isKindOfClass:[NSString class]])) {
            
                [[PNObservationCenter defaultCenter] removeClientAsHistoryDownloadObserver];
            }
            if (handleBlock && ![handleBlock isKindOfClass:[NSString class]]) {
                
                [[PNObservationCenter defaultCenter] addClientAsHistoryDownloadObserverWithBlock:[handleBlock copy]];
            }
            
            PNMessageHistoryRequest *request = [PNMessageHistoryRequest messageHistoryRequestForChannel:channel
                                                                from:startDate to:endDate limit:limit
                                                      reverseHistory:shouldReverseMessageHistory
                                                  includingTimeToken:shouldIncludeTimeToken];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T REQUEST HISTORY FOR CHANNEL: %@ (STATE: %@)",
                        channel, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            PNError *sendingError = [PNError errorWithCode:statusCode];
            sendingError.associatedObject = channel;
            
            [[self sharedInstance] notifyDelegateAboutHistoryDownloadFailedWithError:sendingError];
            
            if (handleBlock && ![handleBlock isKindOfClass:[NSString class]]) {
                
                handleBlock(nil, channel, startDate, endDate, sendingError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE HISTORY REQUEST FOR CHANNEL: %@ (STATE: %@)",
                           channel, [self humanReadableStateFrom:[self sharedInstance].state]];
               }];

               [self postponeRequestHistoryForChannel:channel from:startDate to:endDate limit:limit
                                       reverseHistory:shouldReverseMessageHistory
                                   includingTimeToken:shouldIncludeTimeToken
                                  withCompletionBlock:(handleBlock ? [handleBlock copy] : nil)];
           }];
}

+ (void)postponeRequestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                                   limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory
                      includingTimeToken:(BOOL)shouldIncludeTimeToken
                     withCompletionBlock:(id)handleBlock {

    SEL selector = @selector(requestHistoryForChannel:from:to:limit:reverseHistory:includingTimeToken:withCompletionBlock:);
    [[self sharedInstance] postponeSelector:selector forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:channel], [PNHelper nilifyIfNotSet:startDate], [PNHelper nilifyIfNotSet:endDate],
                                              @(limit), @(shouldReverseMessageHistory), @(shouldIncludeTimeToken),
                                              [PNHelper nilifyIfNotSet:handleBlock]]
                                 outOfOrder:[handleBlock isKindOfClass:[NSString class]]];
}


#pragma mark - Participant methods

+ (void)requestParticipantsList {

    [self requestParticipantsListWithCompletionBlock:nil];
}

+ (void)requestParticipantsListWithCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self requestParticipantsListWithClientIdentifiers:YES andCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired {

    [self requestParticipantsListWithClientIdentifiers:isClientIdentifiersRequired andCompletionBlock:nil];
}

+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self requestParticipantsListWithClientIdentifiers:isClientIdentifiersRequired clientState:NO
                                    andCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState {

    [self requestParticipantsListWithClientIdentifiers:isClientIdentifiersRequired clientState:shouldFetchClientState
                                    andCompletionBlock:nil];
}

+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self requestParticipantsListForChannel:nil clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:shouldFetchClientState withCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel {
    
    [self requestParticipantsListForChannel:channel withCompletionBlock:nil];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:YES withCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired {

    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                        withCompletionBlock:nil];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:NO withCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState {

    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:shouldFetchClientState withCompletionBlock:nil];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO REQUEST PARTICIPANTS LIST FOR CHANNEL: %@ (STATE: %@)",
                channel, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];

    [self performAsyncLockingBlock:^{

        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"REQUEST PARTICIPANTS LIST FOR CHANNEL: %@ (STATE: %@)",
                        channel, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (!handleBlock || (handleBlock && ![handleBlock isKindOfClass:[NSString class]])) {

                [[PNObservationCenter defaultCenter] removeClientAsParticipantsListDownloadObserver];
            }
            if (handleBlock && ![handleBlock isKindOfClass:[NSString class]]) {

                [[PNObservationCenter defaultCenter] addClientAsParticipantsListDownloadObserverWithBlock:[handleBlock copy]];
            }


            PNHereNowRequest *request = [PNHereNowRequest whoNowRequestForChannel:channel
                                                        clientIdentifiersRequired:isClientIdentifiersRequired
                                                                      clientState:shouldFetchClientState];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T REQUEST PARTICIPANTS LIST FOR CHANNEL: %@ "
                        "(STATE: %@)", channel, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            PNError *sendingError = [PNError errorWithCode:statusCode];
            sendingError.associatedObject = channel;

            [[self sharedInstance] notifyDelegateAboutParticipantsListDownloadFailedWithError:sendingError];

            if (handleBlock && ![handleBlock isKindOfClass:[NSString class]]) {

                handleBlock(nil, channel, sendingError);
            }
        }
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                   return [NSString stringWithFormat:@"POSTPONE PARTICIPANTS LIST REQUEST FOR CHANNEL  "
                           "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
               }];

               [self postponeRequestParticipantsListForChannel:channel
                                    clientIdentifiersLRequired:isClientIdentifiersRequired
                                                   clientState:shouldFetchClientState
                                           withCompletionBlock:(handleBlock ? [handleBlock copy] : nil)];
           }];
}

+ (void)postponeRequestParticipantsListForChannel:(PNChannel *)channel
                       clientIdentifiersLRequired:(BOOL)isClientIdentifiersRequired
                                      clientState:(BOOL)shouldFetchClientState
                              withCompletionBlock:(id)handleBlock {

    SEL targetSelector = @selector(requestParticipantsListForChannel:clientIdentifiersRequired:clientState:withCompletionBlock:);
    [[self sharedInstance] postponeSelector:targetSelector forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:channel], @(isClientIdentifiersRequired),
                                              @(shouldFetchClientState),
                                              [PNHelper nilifyIfNotSet:handleBlock]]
                                 outOfOrder:[handleBlock isKindOfClass:[NSString class]]];
}


+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier {

    [self requestParticipantChannelsList:clientIdentifier withCompletionBlock:nil];
}

+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock {

    [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

        return [NSString stringWithFormat:@"TRYING TO REQUEST PARTICIPANT CHANNELS LIST FOR IDENTIFIER: %@ (STATE: %@)",
                clientIdentifier, [self humanReadableStateFrom:[self sharedInstance].state]];
    }];

    [self performAsyncLockingBlock:^{

        // Check whether client is able to send request or not
        NSInteger statusCode = [[self sharedInstance] requestExecutionPossibilityStatusCode];
        if (statusCode == 0) {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"REQUEST PARTICIPANT CHANNELS LIST FOR IDENTIFIER: %@ "
                        "(STATE: %@)", clientIdentifier, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];
            
            if (!handleBlock || (handleBlock && ![handleBlock isKindOfClass:[NSString class]])) {

                [[PNObservationCenter defaultCenter] removeClientAsParticipantChannelsListDownloadObserver];
            }
            if (handleBlock && ![handleBlock isKindOfClass:[NSString class]]) {

                [[PNObservationCenter defaultCenter] addClientAsParticipantChannelsListDownloadObserverWithBlock:[handleBlock copy]];
            }


            PNWhereNowRequest *request = [PNWhereNowRequest whereNowRequestForIdentifier:clientIdentifier];
            [[self sharedInstance] sendRequest:request shouldObserveProcessing:YES];
        }
        else {

            [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                return [NSString stringWithFormat:@"CAN'T REQUEST PARTICIPANT CHANNELS LIST FOR IDENTIFIER: %@ "
                        "(STATE: %@)", clientIdentifier, [self humanReadableStateFrom:[self sharedInstance].state]];
            }];

            PNError *sendingError = [PNError errorWithCode:statusCode];
            sendingError.associatedObject = clientIdentifier;

            [[self sharedInstance] notifyDelegateAboutParticipantChannelsListDownloadFailedWithError:sendingError];

            if (handleBlock && ![handleBlock isKindOfClass:[NSString class]]) {

                handleBlock(clientIdentifier, nil, sendingError);
            }
        }
    }
               postponedExecutionBlock:^{

                   [PNLogger logGeneralMessageFrom:[self sharedInstance] message:^NSString * {

                       return [NSString stringWithFormat:@"POSTPONE PARTICIPANT CHANNELS LIST REQUEST FOR IDENTIFIER "
                               "(STATE: %@)", [self humanReadableStateFrom:[self sharedInstance].state]];
                   }];

                   [self postponeRequestParticipantChannelsList:clientIdentifier
                                            withCompletionBlock:(handleBlock ? [handleBlock copy] : nil)];
               }];
}

+ (void)postponeRequestParticipantChannelsList:(NSString *)clientIdentifier
                           withCompletionBlock:(id)handleBlock {

    SEL targetSelector = @selector(requestParticipantChannelsList:withCompletionBlock:);
    [[self sharedInstance] postponeSelector:targetSelector forObject:self
                             withParameters:@[[PNHelper nilifyIfNotSet:clientIdentifier],
                                              [PNHelper nilifyIfNotSet:handleBlock]]
                                 outOfOrder:[handleBlock isKindOfClass:[NSString class]]];
}


#pragma mark - Crypto helper methods

+ (id)AESDecrypt:(id)object {
    
    return [self AESDecrypt:object error:NULL];
}

+ (id)AESDecrypt:(id)object error:(PNError **)decryptionError {

    __block id decryptedObject = nil;

    // Check whether user provided JSON string or not.
    if ([PNJSONSerialization isJSONString:object]) {

        if ([object isKindOfClass:[NSString class]]) {
            
            __block id decodedJSONObject = nil;
            [PNJSONSerialization JSONObjectWithString:object
                                      completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName) {

                                      decodedJSONObject = result;
                                  }
                                       errorBlock:^(NSError *error) {

                                               [PNLogger logGeneralMessageFrom:self message:^NSString * {

                                                   return [NSString stringWithFormat:@"MESSAGE DECODING ERROR: %@", error];
                                               }];
                                           }];
            
            object = decodedJSONObject;
        }
        else {
            
            decryptedObject = object;
        }
    }

    if ([PNCryptoHelper sharedInstance].isReady) {

        PNError *processingError;
        NSInteger processingErrorCode = -1;

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
        BOOL isExpectedDataType = [object isKindOfClass:[NSString class]];
#else
        BOOL isExpectedDataType = [object isKindOfClass:[NSString class]] ||
		[object isKindOfClass:[NSArray class]] ||
		[object isKindOfClass:[NSDictionary class]];
#endif
        if (isExpectedDataType) {

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            NSString *decodedMessage = [[PNCryptoHelper sharedInstance] decryptedStringFromString:object error:&processingError];
#else
            id decodedMessage = [[PNCryptoHelper sharedInstance] decryptedObjectFromObject:object error:&processingError];
#endif
            if (decodedMessage == nil || processingError != nil) {

                processingErrorCode = kPNCryptoInputDataProcessingError;
            }
            else if (decodedMessage != nil) {

                decryptedObject = decodedMessage;
            }

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            if (processingError == nil && processingErrorCode < 0) {

                [PNJSONSerialization JSONObjectWithString:decodedMessage
                                          completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName) {

											  decryptedObject = result;
                                          }
                                               errorBlock:^(NSError *error) {

                                                   [PNLogger logGeneralMessageFrom:self message:^NSString * {

                                                       return [NSString stringWithFormat:@"MESSAGE DECODING ERROR: %@", error];
                                                   }];
                                               }];
            }
#endif
        }
        else {

            processingErrorCode = kPNCryptoInputDataProcessingError;
        }

        if (processingError != nil || processingErrorCode > 0) {

            if (processingErrorCode > 0) {

                processingError = [PNError errorWithCode:processingErrorCode];
            }
            if (decryptionError != NULL) {

                *decryptionError = processingError;
            }
            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"Message decoding failed because of error: %@", processingError];
            }];
            decryptedObject = @"DECRYPTION_ERROR";
        }
    }
    else {

        decryptedObject = object;
    }


    return decryptedObject;
}

+ (NSString *)AESEncrypt:(id)object {

    return [self AESEncrypt:object error:NULL];
}


+ (NSString *)AESEncrypt:(id)object error:(PNError **)encryptionError {
    
    PNError *processingError;
    NSString *encryptedObjectHash = nil;
    if ([PNCryptoHelper sharedInstance].isReady) {
        
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
        object = object ? [PNJSONSerialization stringFromJSONObject:object] : @"";
#endif
        
        // Retrieve reference on encrypted message (if possible)
        if ([PNCryptoHelper sharedInstance].isReady) {
            
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            NSString *encryptedData = [[PNCryptoHelper sharedInstance] encryptedStringFromString:object error:&processingError];
            
            encryptedObjectHash = [NSString stringWithFormat:@"\"%@\"", encryptedData];
#else
            id encryptedMessage = [[PNCryptoHelper sharedInstance] encryptedObjectFromObject:object error:&processingError];
            NSString *encryptedData = [PNJSONSerialization stringFromJSONObject:encryptedMessage];
            
            encryptedObjectHash = [NSString stringWithFormat:@"%@", encryptedData];
#endif
            
            if (processingError != nil) {
                
                if (encryptionError != NULL) {
                    
                    *encryptionError = processingError;
                }
                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"Message encryption failed with error: %@\nUnencrypted message will be sent.",
                            processingError];
                }];
            }
        }
    }
    
    
    return encryptedObjectHash;
}


#pragma mark - Misc methods

+ (void)showVserionInfo {
    
    NSString *pubnubLogo = @"| +--------+          +-+       +-+     +-+          +-+\n"
"| | +----+ |          | |       | |    /  |          | |\n"
"| | |    | |          | |       | |   / / |          | |\n"
"| | +----+ | +-+  +-+ | +-----\\ | |  / /| | +-+  +-+ | +-----\\\n"
"| | +------+ | |  | | | +---+ | | | / / | | | |  | | | +---+ |\n"
"| | |        | |  | | | |   | | | |/ /  | | | |  | | | |   | |\n"
"| | |        | +--+ | | +---+ | |   /   | | | +--+ | | +---+ |\n"
"| +-+        \\------/ +-------/ +--/    +-+ \\------/ +-------/\n|\n|\n";
    NSString *informationBlockSeparator = @"\n+--------------------------------------------------------------\n";

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"\n\n%@%@| PubNub.com real-time messaging network information:\n| - version: %@\n| - git branch: %@\n| - commit identifier: %@%@\n\n",
                  informationBlockSeparator, pubnubLogo, kPNLibraryVersion, kPNCodebaseBranch, kPNCodeCommitIdentifier, informationBlockSeparator];
    }];
}

+ (NSString *)humanReadableStateFrom:(PNPubNubClientState)state {
    
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

        [PNLogger prepare];
        [[self class] showVserionInfo];

        self.state = PNPubNubClientStateCreated;
        self.cache = [PNCache new];
        self.launchSessionIdentifier = [PNHelper UUID];
        self.reachability = [PNReachability serviceReachability];
        pendingInvocations = [NSMutableArray array];
        
        // Adding PubNub services availability observer
        __block __pn_desired_weak PubNub *weakSelf = self;
        self.reachability.reachabilityChangeHandleBlock = ^(BOOL connected) {

            [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                return [NSString stringWithFormat:@"IS CONNECTED? %@ (STATE: %@)", connected?@"YES":@"NO",
                        [weakSelf humanReadableStateFrom:weakSelf.state]];
            }];

            if (!connected) {

                [weakSelf stopHeartbeatTimer];
            }

            weakSelf.updatingClientIdentifier = NO;
            if (weakSelf.shouldConnectOnServiceReachabilityCheck) {

                [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                    return [NSString stringWithFormat:@"CLIENT SHOULD TRY CONNECT ON SERVICE REACHABILITY CHECK (STATE:"
                            " %@)", [weakSelf humanReadableStateFrom:weakSelf.state]];
                }];
                
                weakSelf.connectOnServiceReachabilityCheck = NO;
                if (connected) {

                    [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                        return [NSString stringWithFormat:@"INTERNET CONNECITON AVAILABLE. TRY TO CONNECT (STATE: %@)",
                                [weakSelf humanReadableStateFrom:weakSelf.state]];
                    }];
                    
                    weakSelf.asyncLockingOperationInProgress = NO;
                    
                    [[weakSelf class] connect];
                }
                else {

                    [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                        return [NSString stringWithFormat:@"INTERNET CONNECITON NOT AVAILABLE. REPORT ERROR (STATE: %@)",
                                [weakSelf humanReadableStateFrom:weakSelf.state]];
                    }];

                    weakSelf.connectOnServiceReachability = YES;
                    [weakSelf handleConnectionErrorOnNetworkFailure];
                    weakSelf.asyncLockingOperationInProgress = YES;
                }
            }
            else {
                
                if (connected) {

                    [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                        return [NSString stringWithFormat:@"INTERNET CONNECITON AVAILABLE (STATE: %@)",
                                [weakSelf humanReadableStateFrom:weakSelf.state]];
                    }];
                    
                    // In case if client is in 'disconnecting on network error' state when connection become available
                    // force client to change it state to "completed" stage of disconnection on network error
                    if (weakSelf.state == PNPubNubClientStateDisconnectingOnNetworkError) {

                        [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                            return [NSString stringWithFormat:@"DISCONNECTED ON ERROR (STATE: %@)",
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

                        [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                            return [NSString stringWithFormat:@"LIBRARY OUT OF SYNC. CONNECTION STATE IS IMPOSSIBLE IF "
                                    "'NETWORK AVAILABLE' ARRIVE (STATE: %@)", [weakSelf humanReadableStateFrom:weakSelf.state]];
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

                                [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                    return [NSString stringWithFormat:@"SHOULD RESTORE CONNECTION (STATE: %@)",
                                            [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                                
                                weakSelf.restoringConnection = YES;
                            }

                            if (isSuspended) {

                                [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                    return [NSString stringWithFormat:@"SHOULD RESUME CONNECTION (STATE: %@)",
                                            [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];

                                weakSelf.state = PNPubNubClientStateConnected;

                                weakSelf.restoringConnection = NO;
                                [weakSelf.messagingChannel resume];
                                [weakSelf.serviceChannel resume];
                            }
                            else {

                                [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                    return [NSString stringWithFormat:@"SHOULD CONNECT (STATE: %@)",
                                            [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];

                                [[weakSelf class] connect];
                            }
                        }
                    }
                    else {

                        [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                            return [NSString stringWithFormat:@"THERE IS NO SUITABLE ACTION FOR CURRENT SITUATION "
                                    "(STATE: %@)", [weakSelf humanReadableStateFrom:weakSelf.state]];
                        }];
                    }
                }
                else {

                    [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                        return [NSString stringWithFormat:@"INTERNET CONNECITON NOT AVAILABLE (STATE: %@)",
                                [weakSelf humanReadableStateFrom:weakSelf.state]];
                    }];
                    BOOL hasBeenSuspended = weakSelf.state == PNPubNubClientStateSuspended;
                    
                    // Check whether PubNub client was connected or connecting right now
                    if (weakSelf.state == PNPubNubClientStateConnected ||
                        weakSelf.state == PNPubNubClientStateConnecting || hasBeenSuspended) {
                        
                        if (weakSelf.state == PNPubNubClientStateConnecting) {

                            [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                return [NSString stringWithFormat:@"CLIENT TRIED TO CONNECT (STATE: %@)",
                                        [weakSelf humanReadableStateFrom:weakSelf.state]];
                            }];

                            weakSelf.state = PNPubNubClientStateDisconnectingOnNetworkError;

                            // Messaging channel will close second channel automatically.
                            [_sharedInstance.messagingChannel disconnectWithReset:NO];
                            
                            if (weakSelf.state == PNPubNubClientStateDisconnectingOnNetworkError ||
                                weakSelf.state == PNPubNubClientStateDisconnectedOnNetworkError) {

                                [weakSelf handleConnectionErrorOnNetworkFailure];
                            }
                            else {

                                [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                    return [NSString stringWithFormat:@"DURING CONNECTION CHANNEL DISCONNECTION LIBRARY "
                                            "NOTICED INTERNET CONNECTION AND WAS ABLE TO LAUNCH RESTORE PROCESS (STATE: %@)",
                                            [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                            }

                            [weakSelf flushPostponedMethods:YES];
                        }
                        else {
                            
                            if (weakSelf.state == PNPubNubClientStateSuspended) {

                                [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                    return [NSString stringWithFormat:@"CLIENT WAS SUSPENDED (STATE: %@)",
                                            [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                            }
                            else {

                                [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                    return [NSString stringWithFormat:@"CLIENT WAS CONNECTED (STATE: %@)",
                                            [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                            }


                            if (![weakSelf shouldRestoreConnection]) {

                                [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                    return [NSString stringWithFormat:@"AUTO CONNECTION TURNED OFF (STATE: %@)",
                                            [weakSelf humanReadableStateFrom:weakSelf.state]];
                                }];
                            }
                            else {

                                [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                    return [NSString stringWithFormat:@"CLIENT WILL CONNECT AS SOON AS INTERNET BECOME "
                                            "AVAILABLE (STATE: %@)", [weakSelf humanReadableStateFrom:weakSelf.state]];
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

                        [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                            return [NSString stringWithFormat:@"THERE IS NOTHING THAT LIBRARY CAN DO WHEN NETWORK IS "
                                    "DOWN AND LIBRARY HASN'T CONNECTED TO THE SERVICE (STATE: %@)",
                                    [weakSelf humanReadableStateFrom:weakSelf.state]];
                        }];
                    }
                }
            }
        };

        [self subscribeForNotifications];
    }
    
    
    return self;
}

- (NSArray *)presenceEnabledChannels {
    
    return [self.messagingChannel presenceEnabledChannels];
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
        [request isKindOfClass:[PNClientStateRequest class]] ||
        [request isKindOfClass:[PNClientStateUpdateRequest class]] ||
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

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"CHANNEL CONNECTED: %@ (STATE: %@)", channel, [self humanReadableStateFrom:self.state]];
    }];

    BOOL isChannelsConnected = [self.messagingChannel isConnected] && [self.serviceChannel isConnected];
    BOOL isCorrectRemoteHost = [self.configuration.origin isEqualToString:host];
    
    // Check whether all communication channels connected and whether client in corresponding state or not
    if (isChannelsConnected && isCorrectRemoteHost && self.state == PNPubNubClientStateConnecting) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"BOTH CHANNELS CONNECTED TO THE ORIGIN: %@ (STATE: %@)", host,
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
}

- (void)connectionChannel:(PNConnectionChannel *)channel didReconnectToHost:(NSString *)host {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"CHANNEL RECONNECTED: %@ (STATE: %@)", channel, [self humanReadableStateFrom:self.state]];
    }];

    
    // Check whether received event from same host on which client is configured or not and client connected at this
    // moment
    if ([self.configuration.origin isEqualToString:host]) {

        if (self.state == PNPubNubClientStateConnecting) {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"CHANNEL RECONNECTED DURING PUBNUB 'CONNECTING' STATE WHICH MEAN THAT "
                        "SECOND CHANNEL DIDN'T REPORTED YET THAT IT WAS CONNECTED AND '%@' WAS ABLE TO RECOVED AFTER SOME"
                        " ERROR (STATE: %@)", channel, [self humanReadableStateFrom:self.state]];
            }];

            [self connectionChannel:channel didConnectToHost:host];
        }
        else if (self.state == PNPubNubClientStateConnected) {

            [self warmUpConnection:channel];
        }
    }
}

- (void)  connectionChannel:(PNConnectionChannel *)channel connectionDidFailToOrigin:(NSString *)host
                  withError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"CHANNEL FAILED TO CONNECT: %@ (STATE: %@)", channel, [self humanReadableStateFrom:self.state]];
    }];
    
    // Check whether client in corresponding state and all communication channels not connected to the server
    if(self.state == PNPubNubClientStateConnecting && [self.configuration.origin isEqualToString:host] &&
       ![self.messagingChannel isConnected] && ![self.serviceChannel isConnected]) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"CLIENT FAILED TO CONNECT TO ORIGIN: %@ (STATE: %@)", host,
                    [self humanReadableStateFrom:self.state]];
        }];
        
        self.state = PNPubNubClientStateDisconnectedOnNetworkError;
        self.connectOnServiceReachabilityCheck = NO;
        self.connectOnServiceReachability = NO;
        
        [self.messagingChannel disconnectWithEvent:NO];
        [self.serviceChannel disconnectWithEvent:NO];
        
        if (![self.configuration shouldKillDNSCache]) {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"TRYING TO KILL DNS CACHE FOR %@ (STATE: %@)", host,
                        [self humanReadableStateFrom:self.state]];
            }];
            self.asyncLockingOperationInProgress = NO;
            
            [self.configuration shouldKillDNSCache:YES];
            [self.messagingChannel disconnectWithEvent:NO];
            [self.serviceChannel disconnectWithEvent:NO];
            
            [[self class] connect];
        }
        else {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"NOTIFY DELEGATE THAT CONNECTION CAN'T BE ESTABLISHED TO %@ (STATE: %@)",
                        host, [self humanReadableStateFrom:self.state]];
            }];
            
            [self.configuration shouldKillDNSCache:NO];
            
            // Send notification to all who is interested in it (observation center will track it as well)
            [self notifyDelegateClientConnectionFailedWithError:error];
        }
    }
}

- (void)connectionChannel:(PNConnectionChannel *)channel didDisconnectFromOrigin:(NSString *)host {

    // Check whether notification arrived from channels on which PubNub library is looking at this moment
    BOOL shouldHandleChannelEvent = [channel isEqual:self.messagingChannel] || [channel isEqual:self.serviceChannel] ||
                                    self.state == PNPubNubClientStateDisconnectingOnConfigurationChange;

    [self stopHeartbeatTimer];

    if (shouldHandleChannelEvent) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"CHANNEL DISCONNECTED: %@ (STATE: %@)", channel, [self humanReadableStateFrom:self.state]];
        }];
    }
    else {

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"RELEASED CHANNEL DISCONNECTED: %@. DON'T HANDLE EVENT (STATE: %@)", channel,
                    [self humanReadableStateFrom:self.state]];
        }];
    }
    
    // Check whether host name arrived or not (it may not arrive if event sending instance was dismissed/deallocated)
    if (host == nil) {
        
        host = self.configuration.origin;
    }

    BOOL isForceClosingSecondChannel = NO;
    if (self.state != PNPubNubClientStateDisconnecting && self.state != PNPubNubClientStateDisconnectingOnConfigurationChange &&
        shouldHandleChannelEvent) {

        self.state = PNPubNubClientStateDisconnectingOnNetworkError;
        if ([channel isEqual:self.messagingChannel] &&
            (![self.serviceChannel isDisconnected] || [self.serviceChannel isConnected])) {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"DISCONNECTING SERVICE CONNECTION CHANNEL: %@ (STATE: %@)",
                        channel, [self humanReadableStateFrom:self.state]];
            }];

            isForceClosingSecondChannel = YES;
            [self.serviceChannel disconnect];
        }
        else if ([channel isEqual:self.serviceChannel] &&
                 (![self.messagingChannel isDisconnected] || [self.messagingChannel isConnected])) {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"DISCONNECTING MESSAGING CONNECTION CHANNEL: %@ (STATE: %@)",
                        channel, [self humanReadableStateFrom:self.state]];
            }];

            isForceClosingSecondChannel = YES;
            [self.messagingChannel disconnectWithReset:NO];
        }
    }

    
    // Check whether received event from same host on which client is configured or not and all communication
    // channels are closed
    if(shouldHandleChannelEvent && !isForceClosingSecondChannel && [self.configuration.origin isEqualToString:host] &&
       [self.messagingChannel isDisconnected] && [self.serviceChannel isDisconnected]  &&
       self.state != PNPubNubClientStateDisconnected && self.state != PNPubNubClientStateDisconnectedOnNetworkError) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"CLIENT DISCONNECTED FROM ORIGIN: %@ (STATE: %@)", host,
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

                        [PNLogger logGeneralMessageFrom:self message:^NSString * {

                            return [NSString stringWithFormat:@"CLIENT SHOULD RESTORE CONNECTION. REACHABILITY CHECK "
                                    "COMPLETED (STATE: %@)", [self humanReadableStateFrom:self.state]];
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

                        if ([weakSelf.delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:)]) {

                            [weakSelf.delegate pubnubClient:weakSelf didDisconnectFromOrigin:host];
                        }
                        [PNLogger logDelegateMessageFrom:weakSelf message:^NSString * {

                            return [NSString stringWithFormat:@"PubNub client disconnected from PubNub origin at: %@",
                                    host];
                        }];


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
                                [PNLogger logDelegateMessageFrom:weakSelf message:^NSString * {

                                    return [NSString stringWithFormat:@"PubNub client closed connection because of error: "
                                            "%@", connectionError];
                                }];


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

                                [PNLogger logGeneralMessageFrom:self message:^NSString * {

                                    return [NSString stringWithFormat:@"CLIENT SHOULD RESTORE CONNECTION. REACHABILITY CHECK "
                                            "COMPLETED (STATE: %@)", [self humanReadableStateFrom:self.state]];
                                }];
                                
                                self.asyncLockingOperationInProgress = NO;
                                self.restoringConnection = YES;

                                // Try to restore connection to remote PubNub services
                                [[self class] connect];
                            }
                            else {

                                [PNLogger logGeneralMessageFrom:self message:^NSString * {

                                    return [NSString stringWithFormat:@"DESTROY COMPONENTS (STATE: %@)", [self humanReadableStateFrom:self.state]];
                                }];

                                disconnectionNotifyBlock();
                            }
                        }
                        // In case if there is no connection check whether clint should restore connection or not.
                        else if(![self shouldRestoreConnection]) {

                            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                                return [NSString stringWithFormat:@"DESTROY COMPONENTS (STATE: %@)", [self humanReadableStateFrom:self.state]];
                            }];

                            self.state = PNPubNubClientStateDisconnected;
                            disconnectionNotifyBlock();
                        }
                        else if ([self shouldRestoreConnection]) {

                            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                                return [NSString stringWithFormat:@"CONNECTION WILL BE RESTORED AS SOON AS INTERNET CONNECTION "
                                        "WILL GO UP (STATE: %@)", [self humanReadableStateFrom:self.state]];
                            }];
                            
                            if (!reachabilityWillSimulateAction) {
                                
                                [self notifyDelegateClientDidDisconnectWithError:connectionError];
                            }
                        }
                    }
                }
            }
            else {

                [PNLogger logGeneralMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"CLIENT ALREADY CONNECTING BACK. DON'T DO ANYTHING. (STATE: %@)",
                            [self humanReadableStateFrom:self.state]];
                }];
            }
        }
        // Check whether server unexpectedly closed connection while client was active or not
        else if(self.state == PNPubNubClientStateConnected) {
            
            self.state = PNPubNubClientStateDisconnected;
            
            if([self shouldRestoreConnection]) {

                [PNLogger logGeneralMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"CLIENT SHOULD RESTORE CONNECTION. WAS CONNECTED BEFORE. (STATE: %@)",
                            [self humanReadableStateFrom:self.state]];
                }];
                
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

    // Check whether on resume there is no async locking operation is running
    if (!self.asyncLockingOperationInProgress) {

        [self handleLockingOperationComplete:YES];
    }

    // Checking whether all communication channels connected or not
    if ([self.messagingChannel isConnected] && [self.serviceChannel isConnected]) {

        [self notifyDelegateAboutConnectionToOrigin:self.configuration.origin];
        [self launchHeartbeatTimer];
    }
}

- (BOOL)connectionChannelCanConnect:(PNConnectionChannel *)channel {

    // Help reachability instance update it's state our of schedule
    [self.reachability refreshReachabilityState];


    return [self.reachability isServiceAvailable];
}

- (BOOL)connectionChannelShouldRestoreConnection:(PNConnectionChannel *)channel {

    // Help reachability instance update it's state our of schedule
    [self.reachability refreshReachabilityState];

    BOOL isSimulatingReachability = [self.reachability isSimulatingNetworkSwitchEvent];
    BOOL shouldRestoreConnection = self.state == PNPubNubClientStateConnecting ||
                                   self.state == PNPubNubClientStateConnected ||
                                   self.state == PNPubNubClientStateDisconnectingOnNetworkError ||
                                   self.state == PNPubNubClientStateDisconnectedOnNetworkError;

    // Ensure that there is connection available as well as permission to connect
    shouldRestoreConnection = shouldRestoreConnection && [self.reachability isServiceAvailable] && !isSimulatingReachability;


    return shouldRestoreConnection;
}


#pragma mark - Handler methods

- (void)handleHeartbeatTimer {

    // Checking whether we are still connected and there is some channels for which we can create this heartbeat
    // request.
    if ([self isConnected] && ![self isResuming] && [[[self class] subscribedChannels] count] &&
        self.configuration.presenceHeartbeatTimeout > 0.0f) {

        // Prepare and send request w/o observation (it mean that any response for request will be ignored
        NSArray *channels = [[self class] subscribedChannels];
        [self sendRequest:[PNHeartbeatRequest heartbeatRequestForChannels:channels
                                                          withClientState:[self.cache stateForChannels:channels]]
  shouldObserveProcessing:NO];
    }
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)handleApplicationDidEnterBackgroundState:(NSNotification *)__unused notification {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"HANDLE APPLICATION ENTERED BACKGROUND (STATE: %@)", [self humanReadableStateFrom:self.state]];
    }];
    
	if (![self canRunInBackground]) {

        BOOL canInformAboutSuspension = [self.delegate respondsToSelector:@selector(pubnubClient:willSuspendWithBlock:)];
        void(^suspensionCompletionBlock)(void) = ^{

            // Ensure that application is still in background execution context.
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {

                if (!canInformAboutSuspension) {

                    [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"APPLICATION CAN'T RUN IN BACKGROUND."; }];
                }
                else {

                    [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"COMPLETED TASKS BEFORE ENETERING BACKGROUND."; }];
                }
                [self.reachability suspend];

                // Check whether application connected or not
                if ([self isConnected]) {

                    [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"SUSPENDING..."; }];

                    self.state = PNPubNubClientStateSuspended;

                    self.asyncLockingOperationInProgress = NO;
                    [self.messagingChannel suspend];
                    [self.serviceChannel suspend];
                }
                else if (self.state == PNPubNubClientStateConnecting ||
                         self.state == PNPubNubClientStateDisconnecting ||
                         self.state == PNPubNubClientStateDisconnectingOnNetworkError) {

                    if (self.state == PNPubNubClientStateConnecting) {

                        [PNLogger logGeneralMessageFrom:self message:^NSString * {

                            return [NSString stringWithFormat:@"CLIENT TRIED TO CONNECT. TERMINATE CONNECTION AND MARK ERROR "
                                    "(STATE: %@)", [self humanReadableStateFrom:self.state]];
                        }];

                        self.state = PNPubNubClientStateDisconnectedOnNetworkError;
                    }
                    else if (self.state == PNPubNubClientStateDisconnecting){

                        [PNLogger logGeneralMessageFrom:self message:^NSString * {

                            return [NSString stringWithFormat:@"CLIENT TRIED TO DISCONNECT. TERMINATE CONNECTION AND MARK AS "
                                    "DISCONNECTED (STATE: %@)", [self humanReadableStateFrom:self.state]];
                        }];

                        self.state = PNPubNubClientStateDisconnected;
                    }
                    else if (self.state == PNPubNubClientStateDisconnectingOnNetworkError){

                        [PNLogger logGeneralMessageFrom:self message:^NSString * {

                            return [NSString stringWithFormat:@"CLIENT TRIED TO DISCONNECT. TERMINATE CONNECTION AND MARK ERROR "
                                    "(STATE: %@)", [self humanReadableStateFrom:self.state]];
                        }];

                        self.state = PNPubNubClientStateDisconnectedOnNetworkError;
                    }

                    [self.messagingChannel disconnectWithEvent:NO];
                    [self.serviceChannel disconnectWithEvent:NO];
                }
            }
            else {

                [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"APPLICATION NOT IN BACKGROUND."; }];
            }
        };

        if (!canInformAboutSuspension) {

            suspensionCompletionBlock();
        }
        else {

            // Informing delegate that PubNub client will suspend soon.
            [self.delegate pubnubClient:self
                   willSuspendWithBlock:^(void(^actionsBlock)(void (^)())) {

                if (actionsBlock) {

                    [PNLogger logGeneralMessageFrom:self message:^NSString * {

                        return [NSString stringWithFormat:@"CLIENT TRY TO POSTPONE APPLICATION SUSPENSION "
                                "(STATE: %@)", [self humanReadableStateFrom:self.state]];
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
                                
                                [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"USER DIDN'T "
                                    "CALLED COMPLETION BLOCK IN TIME. FORE BLOCK EXECUTION."; }];
                                
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
        }
    }
}

- (void)handleApplicationDidEnterForegroundState:(NSNotification *)__unused notification  {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"HANDLE APPLICATION ENTERED FOREGROUND (STATE: %@)", [self humanReadableStateFrom:self.state]];
    }];

    // Try to refresh reachability state (there is situation when reachability state changed within
    // library to handle sockets timeout/error)
    BOOL reachabilityWillSimulateAction = [self.reachability refreshReachabilityState];


    if ([self.reachability isServiceAvailable]) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"CONNECTION AVAILABLE"; }];

        // Check whether application is suspended
        if (self.state == PNPubNubClientStateSuspended) {

            [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"RESUMING..."; }];

            self.state = PNPubNubClientStateConnected;
            
            self.asyncLockingOperationInProgress = NO;
            [self.messagingChannel resume];
            [self.serviceChannel resume];
        }
        else if (self.state == PNPubNubClientStateDisconnectedOnNetworkError) {

            [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"CONNECTION WAS TERMINATED BECAUSE OF ERROR BEFORE SUSPENSION."; }];

            if ([self shouldRestoreConnection]) {

                [PNLogger logGeneralMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"CONNECTION WILL BE RESTORED AS SOON AS INTERNET CONNECTION "
                            "WILL GO UP (STATE: %@)", [self humanReadableStateFrom:self.state]];
                }];

                if (!reachabilityWillSimulateAction) {

                    [self notifyDelegateClientDidDisconnectWithError:[PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]];
                }
            }
        }
    }
    else {

        [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"CONNECTION WENT DOWN WHILE APPLICATION WAS IN BACKGROUND."; }];
    }
}
#else
- (void)handleWorkspaceWillSleep:(NSNotification *)notification {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"HANDLE WORKSPACE SLEEP (STATE: %@)", [self humanReadableStateFrom:self.state]];
    }];
    [self.reachability suspend];

    // Check whether application connected or not
    if ([self isConnected]) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"SUSPENDING..."; }];

        self.state = PNPubNubClientStateSuspended;
        
        self.asyncLockingOperationInProgress = NO;
        [self.messagingChannel suspend];
        [self.serviceChannel suspend];
    }
    else if (self.state == PNPubNubClientStateConnecting ||
             self.state == PNPubNubClientStateDisconnecting ||
             self.state == PNPubNubClientStateDisconnectingOnNetworkError) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"THERE IS NO WAY TO SUSPEND CLIENT (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        if (self.state == PNPubNubClientStateConnecting) {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"CLIENT TRIED TO CONNECT. TERMINATE CONNECTION AND MARK ERROR "
                        "(STATE: %@)", [self humanReadableStateFrom:self.state]];
            }];

            self.state = PNPubNubClientStateDisconnectedOnNetworkError;
        }
        else if (self.state == PNPubNubClientStateDisconnecting){

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"CLIENT TRIED TO DISCONNECT. TERMINATE CONNECTION AND MARK AS "
                        "DISCONNECTED (STATE: %@)", [self humanReadableStateFrom:self.state]];
            }];

            self.state = PNPubNubClientStateDisconnected;
        }
        else if (self.state == PNPubNubClientStateDisconnectingOnNetworkError){

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"CLIENT TRIED TO DISCONNECT. TERMINATE CONNECTION AND MARK ERROR "
                        "(STATE: %@)", [self humanReadableStateFrom:self.state]];
            }];

            self.state = PNPubNubClientStateDisconnectedOnNetworkError;
        }

        [self.messagingChannel disconnectWithEvent:NO];
        [self.serviceChannel disconnectWithEvent:NO];
    }
}

- (void)handleWorkspaceDidWake:(NSNotification *)notification {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"HANDLE WORKSPACE WAKE (STATE: %@)", [self humanReadableStateFrom:self.state]];
    }];

    // Try to refresh reachability state (there is situation when reachability state changed within
    // library to handle sockets timeout/error)
    BOOL reachabilityWillSimulateAction = [self.reachability refreshReachabilityState];

    
    if ([self.reachability isServiceAvailable]) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"CONNECTION AVAILABLE"; }];

        // Check whether application is suspended
        if (self.state == PNPubNubClientStateSuspended) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"RESUMING..."; }];

            self.state = PNPubNubClientStateConnected;
            
            self.asyncLockingOperationInProgress = NO;
            [self.messagingChannel resume];
            [self.serviceChannel resume];
        }
        else if (self.state == PNPubNubClientStateDisconnectedOnNetworkError) {

        [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"CONNECTION WAS TERMINATED BECAUSE OF ERROR BEFORE SLEEP."; }];

            if ([self shouldRestoreConnection]) {

                [PNLogger logGeneralMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"CONNECTION WILL BE RESTORED AS SOON AS INTERNET CONNECTION "
                            "WILL GO UP (STATE: %@)", [self humanReadableStateFrom:self.state]];
                }];

                if (!reachabilityWillSimulateAction) {

                    [self notifyDelegateClientDidDisconnectWithError:[PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]];
                }
            }
        }
    }
    else {

        [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"CONNECTION WENT DOWN WHILE COMPUTER SLEPT."; }];
    }
}
#endif

- (void)handleConnectionErrorOnNetworkFailure {

    [self handleConnectionErrorOnNetworkFailureWithError:[PNError errorWithCode:kPNClientConnectionFailedOnInternetFailureError]];
}

- (void)handleConnectionErrorOnNetworkFailureWithError:(PNError *)error {

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
    
    self.asyncLockingOperationInProgress = NO;

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

- (NSString *)humanReadableStateFrom:(PNPubNubClientState)state {
    
    return [[self class] humanReadableStateFrom:state];
}

- (void)launchHeartbeatTimer {

    [self stopHeartbeatTimer];


    if ([self isConnected] && ![self isResuming] && [[[self class] subscribedChannels] count] &&
        self.configuration.presenceHeartbeatTimeout > 0.0f) {

        self.heartbeatTimer = [NSTimer timerWithTimeInterval:self.configuration.presenceHeartbeatInterval target:self
                                                    selector:@selector(handleHeartbeatTimer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.heartbeatTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopHeartbeatTimer {

    if ([self.heartbeatTimer isValid]) {

        [self.heartbeatTimer invalidate];
    }
    self.heartbeatTimer = nil;
}

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

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"{ERROR} Crypto helper initialization failed because of error: %@",
                        helperInitializationError];
            }];
        }
    }
    else {

        [PNCryptoHelper resetHelper];
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

- (void)flushPostponedMethods:(BOOL)shouldExecute {

    NSArray *invocationsForFlush = [NSArray arrayWithArray:pendingInvocations];
    [pendingInvocations removeAllObjects];

    [invocationsForFlush enumerateObjectsUsingBlock:^(NSInvocation *postponedInvocation,
                                                     NSUInteger postponedInvocationIdx,
                                                     BOOL *postponedInvocationEnumeratorStop) {
        
        self.asyncLockingOperationInProgress = NO;
        if (postponedInvocation && shouldExecute) {

            [postponedInvocation invoke];
        }
    }];
}

- (BOOL)shouldPostponeMethodCall {
    
    return self.isAsyncLockingOperationInProgress;
}

- (void)postponeSelector:(SEL)calledMethodSelector
               forObject:(id)object
          withParameters:(NSArray *)parameters
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

    [PNLogger logDelegateMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client successfully connected to PubNub origin at: %@", originHostName];
    }];

    
    [self sendNotification:kPNClientDidConnectToOriginNotification withObject:originHostName];
}

- (void)notifyDelegateAboutStateRetrievalDidFailWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO RETRIEVE STATE FOR CLIENT (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate us able to handle state retrieval error or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:clientStateRetrieveDidFailWithError:)]) {

            [self.delegate pubnubClient:self clientStateRetrieveDidFailWithError:error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client did fail to receive state for client %@ on channel %@ because of error: %@",
                    ((PNClient *)error.associatedObject).identifier, ((PNClient *)error.associatedObject).channel, error];
        }];

        [self sendNotification:kPNClientStateRetrieveDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutStateUpdateDidFailWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO UPDATE STATE FOR CLIENT (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate able to state update error even or not.
        if ([self.delegate respondsToSelector:@selector(pubnubClient:clientStateUpdateDidFailWithError:)]) {

            [self.delegate performSelector:@selector(pubnubClient:clientStateUpdateDidFailWithError:)
                                withObject:self withObject:error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client did fail to update state for client %@ at channel %@ because of error: %@",
                    ((PNClient *)error.associatedObject).identifier, ((PNClient *)error.associatedObject).channel, error];
        }];

        [self sendNotification:kPNClientStateUpdateDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutResubscribeWillStartOnChannels:(NSArray *)channels {

    if ([channels count] > 0) {

        if ([self shouldChannelNotifyAboutEvent:self.messagingChannel]) {

            // Notify delegate that client is about to restore subscription on previously subscribed channels
            if ([self.delegate respondsToSelector:@selector(pubnubClient:willRestoreSubscriptionOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:willRestoreSubscriptionOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client resuming subscription on: %@", channels];
            }];


            [self sendNotification:kPNClientSubscriptionWillRestoreNotification withObject:channels];
        }
    }
}

- (void)notifyDelegateAboutSubscriptionFailWithError:(PNError *)error
                            completeLockingOperation:(BOOL)shouldCompleteLockingOperation {

    void(^handlerBlock)(void) = ^{

        if (!self.isUpdatingClientIdentifier) {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"FAILED TO SUBSCRIBE (STATE: %@)", [self humanReadableStateFrom:self.state]];
            }];

        	// Check whether delegate is able to handle subscription error or not
        	if ([self.delegate respondsToSelector:@selector(pubnubClient:subscriptionDidFailWithError:)]) {

            	[self.delegate performSelector:@selector(pubnubClient:subscriptionDidFailWithError:)
                	                withObject:self
                    	            withObject:(id)error];
	        }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client failed to subscribe because of error: %@", error];
            }];


    	    [self sendNotification:kPNClientSubscriptionDidFailNotification withObject:error];
        }
        else {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"FAILED TO SUBSCRIBE DURING CLIENT IDENTIFIER UPDATE (STATE: %@)",
                        [self humanReadableStateFrom:self.state]];
            }];

            [self sendNotification:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification withObject:error];
        }
    };

    if (shouldCompleteLockingOperation) {

        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {

        handlerBlock();
    }
}

- (void)notifyDelegateAboutUnsubscriptionFailWithError:(PNError *)error
                              completeLockingOperation:(BOOL)shouldCompleteLockingOperation {

    void(^handlerBlock)(void) = ^{

        if (!self.isUpdatingClientIdentifier) {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"FAILED TO UNSUBSCRIBE (STATE: %@)", [self humanReadableStateFrom:self.state]];
            }];

        	// Check whether delegate is able to handle unsubscription error or not
        	if ([self.delegate respondsToSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)]) {

            	[self.delegate performSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)
                                	withObject:self
                                	withObject:(id)error];
        	}

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client failed to unsubscribe because of error: %@", error];
            }];


        	[self sendNotification:kPNClientUnsubscriptionDidFailNotification withObject:error];
        }
        else {

            [PNLogger logGeneralMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"FAILED TO UNSUBSCRIBE DURING CLIENT IDENTIFIER UPDATE (STATE: %@)",
                        [self humanReadableStateFrom:self.state]];
            }];

            [self sendNotification:kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification withObject:error];
        }
    };

    if (shouldCompleteLockingOperation) {

        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {

        handlerBlock();
    }
}

- (void)notifyDelegateAboutPresenceEnablingFailWithError:(PNError *)error
                                completeLockingOperation:(BOOL)shouldCompleteLockingOperation {

    void(^handlerBlock)(void) = ^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO ENABLE PRESENCE (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate is able to handle unsubscription error or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:presenceObservationEnablingDidFailWithError:)]) {

            [self.delegate performSelector:@selector(pubnubClient:presenceObservationEnablingDidFailWithError:)
                                withObject:self
                                withObject:(id)error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to enable presence observation because of error: "
                    "%@", error];
        }];


        [self sendNotification:kPNClientPresenceEnablingDidFailNotification withObject:error];
    };

    if (shouldCompleteLockingOperation) {

        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {

        handlerBlock();
    }
}

- (void)notifyDelegateAboutPresenceDisablingFailWithError:(PNError *)error
                                 completeLockingOperation:(BOOL)shouldCompleteLockingOperation {

    void(^handlerBlock)(void) = ^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO DISABLE PRESENCE (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate is able to handle unsubscription error or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:presenceObservationDisablingDidFailWithError:)]) {

            [self.delegate performSelector:@selector(pubnubClient:presenceObservationDisablingDidFailWithError:)
                                withObject:self
                                withObject:(id)error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to disable presence observation because of error:"
                            " %@", error];
        }];


        [self sendNotification:kPNClientPresenceDisablingDidFailNotification withObject:error];
    };

    if (shouldCompleteLockingOperation) {

        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {

        handlerBlock();
    }
}

- (void)notifyDelegateAboutPushNotificationsEnableFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO ENABLED PUSH NOTIFICATION ON CHANNEL (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate is able to handle push notification enabling error or not
        SEL selector = @selector(pubnubClient:pushNotificationEnableDidFailWithError:);
        if ([self.delegate respondsToSelector:selector]) {

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:selector withObject:self withObject:error];
            #pragma clang diagnostic pop
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed push notification enable because of error: %@",
                          error];
        }];


        [self sendNotification:kPNClientPushNotificationEnableDidFailNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsDisableFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO DISABLE PUSH NOTIFICATIONS ON CHANNELS (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
            
        // Check whether delegate is able to handle push notification enabling error or not
        SEL selector = @selector(pubnubClient:pushNotificationDisableDidFailWithError:);
        if ([self.delegate respondsToSelector:selector]) {

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:selector withObject:self withObject:error];
            #pragma clang diagnostic pop
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to disable push notifications because of error: "
                    "%@", error];
        }];


        [self sendNotification:kPNClientPushNotificationDisableDidFailNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsRemoveFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO REMOVE REMOVE PUSH NOTIFICATIONS FROM ALL CHANNELS (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
            
        // Check whether delegate is able to handle push notifications removal error or not
        SEL selector = @selector(pubnubClient:pushNotificationsRemoveFromChannelsDidFailWithError:);
        if ([self.delegate respondsToSelector:selector]) {

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:selector withObject:self withObject:error];
            #pragma clang diagnostic pop
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed remove push notifications from channels because "
                    "of error: %@", error];
        }];


        [self sendNotification:kPNClientPushNotificationRemoveDidFailNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO REQUEST PUSH NOTIFICATION ENABLED CHANNELS (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
            
        // Check whether delegate is able to handle push notifications removal error or not
        SEL selector = @selector(pubnubClient:pushNotificationEnabledChannelsReceiveDidFailWithError:);
        if ([self.delegate respondsToSelector:selector]) {

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:selector withObject:self withObject:error];
            #pragma clang diagnostic pop
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to receive list of channels because of error: "
                    "%@", error];
        }];


        [self sendNotification:kPNClientPushNotificationChannelsRetrieveDidFailNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutAccessRightsChangeFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO CHANGE ACCESS RIGHTS (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        if ([self.delegate respondsToSelector:@selector(pubnubClient:accessRightsChangeDidFailWithError:)]) {

            [self.delegate pubnubClient:self accessRightsChangeDidFailWithError:error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to change access rights because of error: %@", error];
        }];


        [self sendNotification:kPNClientAccessRightsChangeDidFailNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutAccessRightsAuditFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO AUDIT ACCESS RIGHTS (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        if ([self.delegate respondsToSelector:@selector(pubnubClient:accessRightsAuditDidFailWithError:)]) {

            [self.delegate pubnubClient:self accessRightsAuditDidFailWithError:error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to audit access rights because of error: %@", error];
        }];


        [self sendNotification:kPNClientAccessRightsAuditDidFailNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutTimeTokenRetrievalFailWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO RETRIEVE TIME TOKEN (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
            
        // Check whether delegate is able to handle time token retrieval error or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)]) {

            [self.delegate performSelector:@selector(pubnubClient:timeTokenReceiveDidFailWithError:)
                                withObject:self
                                withObject:error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to receive time token because of error: %@",
                    error];
        }];


        [self sendNotification:kPNClientDidFailTimeTokenReceiveNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutMessageSendingFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO SEND MESSAGE (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
            
        // Check whether delegate is able to handle message sending error or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailMessageSend:withError:)]) {

            [self.delegate pubnubClient:self didFailMessageSend:error.associatedObject withError:error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to send message '%@' because of error: %@",
                    error.associatedObject, error];
        }];


        [self sendNotification:kPNClientMessageSendingDidFailNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutHistoryDownloadFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO DOWNLOAD HISTORY (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
            
        // Check whether delegate us able to handle message history download error or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailHistoryDownloadForChannel:withError:)]) {

            [self.delegate pubnubClient:self didFailHistoryDownloadForChannel:error.associatedObject withError:error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to download history for %@ because of error: %@",
                    error.associatedObject, error];
        }];


        [self sendNotification:kPNClientHistoryDownloadFailedWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutParticipantsListDownloadFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO DOWNLOAD PARTICIPANTS LIST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
            
        // Check whether delegate us able to handle participants list download error or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailParticipantsListDownloadForChannel:withError:)]) {

            [self.delegate pubnubClient:self didFailParticipantsListDownloadForChannel:error.associatedObject
                              withError:error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to download participants list for channel %@ "
                    "because of error: %@", error.associatedObject, error];
        }];


        [self sendNotification:kPNClientParticipantsListDownloadFailedWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutParticipantChannelsListDownloadFailedWithError:(PNError *)error {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"FAILED TO DOWNLOAD PARTICIPANT CHANNELS LIST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate us able to handle participants list download error or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didFailParticipantChannelsListDownloadForIdentifier:withError:)]) {

            [self.delegate pubnubClient:self didFailParticipantChannelsListDownloadForIdentifier:error.associatedObject
                              withError:error];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client failed to download participant channels list for identifier %@ "
                    "because of error: %@", error.associatedObject, error];
        }];


        [self sendNotification:kPNClientParticipantChannelsListDownloadFailedWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutError:(PNError *)error {
    
    if ([self.delegate respondsToSelector:@selector(pubnubClient:error:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:error:)
                            withObject:self
                            withObject:error];
    }

    [PNLogger logDelegateMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client report that error occurred: %@", error];
    }];

    
    [self sendNotification:kPNClientErrorNotification withObject:error];
}

- (void)notifyDelegateClientWillDisconnectWithError:(PNError *)error {
    
    if ([self.delegate respondsToSelector:@selector(pubnubClient:willDisconnectWithError:)]) {
        
        [self.delegate performSelector:@selector(pubnubClient:willDisconnectWithError:)
                            withObject:self
                            withObject:error];
    }

    [PNLogger logDelegateMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub clinet will close connection because of error: %@", error];
    }];
    
    [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
}

- (void)notifyDelegateClientDidDisconnectWithError:(PNError *)error {
    
    if ([self.delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:withError:)]) {
        
        [self.delegate pubnubClient:self didDisconnectFromOrigin:self.configuration.origin withError:error];
    }

    [PNLogger logDelegateMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client closed connection because of error: %@", error];
    }];
    
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

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client was unable to connect because of error: %@", error];
        }];

        
        [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:shouldStartNextPostponedOperation];
}

- (void)sendNotification:(NSString *)notificationName withObject:(id)object {
    
    // Send notification to all who is interested in it (observation center will track it as well)
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

- (BOOL)shouldKeepTimeTokenOnChannelsListChange {

    BOOL shouldKeepTimeTokenOnChannelsListChange = self.configuration.shouldKeepTimeTokenOnChannelsListChange;
    if ([self.delegate respondsToSelector:@selector(shouldKeepTimeTokenOnChannelsListChange)]) {

        shouldKeepTimeTokenOnChannelsListChange = [[self.delegate shouldKeepTimeTokenOnChannelsListChange] boolValue];
    }


    return shouldKeepTimeTokenOnChannelsListChange;
}

- (BOOL)shouldRestoreSubscription {
    
    BOOL shouldRestoreSubscription = self.configuration.shouldResubscribeOnConnectionRestore;
    if ([self.delegate respondsToSelector:@selector(shouldResubscribeOnConnectionRestore)]) {
        
        shouldRestoreSubscription = [[self.delegate shouldResubscribeOnConnectionRestore] boolValue];
    }
    
    
    return shouldRestoreSubscription;
}

- (BOOL)shouldChannelNotifyAboutEvent:(PNConnectionChannel *)channel {
    
    BOOL shouldChannelNotifyAboutEvent = NO;
    if (self.state != PNPubNubClientStateCreated && self.state != PNPubNubClientStateDisconnecting &&
        self.state != PNPubNubClientStateDisconnected && self.state != PNPubNubClientStateReset &&
        (self.state == PNPubNubClientStateConnecting || self.state == PNPubNubClientStateConnected)) {
        
        shouldChannelNotifyAboutEvent = [channel isConnected] || [channel isConnecting];
    }

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"SHOULD CHANNEL NOTIFY DELEGATE? %@ (STATE: %@)", shouldChannelNotifyAboutEvent ? @"YES" : @"NO",
                [self humanReadableStateFrom:self.state]];
    }];
    
    
    return shouldChannelNotifyAboutEvent;
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


    return statusCode;
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

- (void)messagingChannelDidReset:(PNMessagingChannel *)messagingChannel {

    [self handleLockingOperationComplete:YES];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willSubscribeOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"WILL SUBSCRIBE ON: %@", channels];
    }];

    if ([self isConnected]) {
        
        self.asyncLockingOperationInProgress = YES;
    }
}

- (void)messagingChannel:(PNMessagingChannel *)channel didSubscribeOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced withClientState:(NSDictionary *)clientState {

    self.restoringConnection = NO;

    void(^handlingBlock)(void) = ^{

        // Storing new data for channels.
        [self.cache storeClientState:clientState forChannels:channels];

        if ([self shouldChannelNotifyAboutEvent:channel]) {

            if (!self.isUpdatingClientIdentifier) {

                [PNLogger logGeneralMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"SUBSCRIBED ON CHANNELS (STATE: %@)", [self humanReadableStateFrom:self.state]];
                }];

				if ([self shouldChannelNotifyAboutEvent:channel]) {

					// Check whether delegate can handle subscription on channel or not
					if ([self.delegate respondsToSelector:@selector(pubnubClient:didSubscribeOnChannels:)]) {

						[self.delegate performSelector:@selector(pubnubClient:didSubscribeOnChannels:)
											withObject:self
											withObject:channels];
					}

                    [PNLogger logDelegateMessageFrom:self message:^NSString * {

                        return [NSString stringWithFormat:@"PubNub client successfully subscribed on channels: %@", channels];
                    }];


					[self sendNotification:kPNClientSubscriptionDidCompleteNotification withObject:channels];
				}
				else {

                    [PNLogger logGeneralMessageFrom:self message:^NSString * {

                        return [NSString stringWithFormat:@"SUBSCRIBED ON CHANNELS DURING CLIENT IDENTIFIER UPDATE (STATE: %@)",
                        		[self humanReadableStateFrom:self.state]];
                    }];

					[self sendNotification:kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification withObject:channels];
				}
			}
		}
    };

    if (!isSequenced) {

        [self handleLockingOperationBlockCompletion:handlingBlock shouldStartNext:YES];
    }
    else {

        handlingBlock();
    }

    [self launchHeartbeatTimer];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willRestoreSubscriptionOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"WILL RESTORE SUBSCRIPTION ON: %@", channels];
    }];

    if ([self.messagingChannel isConnected] ) {

        self.asyncLockingOperationInProgress = YES;
    }

    [self notifyDelegateAboutResubscribeWillStartOnChannels:channels];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didRestoreSubscriptionOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {

    self.restoringConnection = NO;

    void(^handlingBlock)(void) = ^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"RESTORED SUBSCRIPTION ON CHANNELS (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];

        if ([self shouldChannelNotifyAboutEvent:messagingChannel]) {

            // Check whether delegate can handle subscription restore on channels or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didRestoreSubscriptionOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:didRestoreSubscriptionOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client successfully restored subscription on channels: %@",
                        channels];
            }];


            [self sendNotification:kPNClientSubscriptionDidRestoreNotification withObject:channels];
        }
    };

    if (!isSequenced) {

        [self handleLockingOperationBlockCompletion:handlingBlock shouldStartNext:YES];
    }
    else {

        handlingBlock();
    }

    [self launchHeartbeatTimer];
}

- (void)messagingChannel:(PNMessagingChannel *)channel didFailSubscribeOnChannels:(NSArray *)channels
               withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutSubscriptionFailWithError:error completeLockingOperation:!isSequenced];

    [self launchHeartbeatTimer];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willUnsubscribeFromChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"WILL UNSUBSCRIBE FROM: %@", channels];
    }];

    if ([self isConnected]) {
        
        self.asyncLockingOperationInProgress = YES;
    }
}

- (void)messagingChannel:(PNMessagingChannel *)channel didUnsubscribeFromChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {

    void(^handlerBlock)(void) = ^{

        // Removing cached data for channels set.
        [self.cache purgeStateForChannels:channels];

        if ([self shouldChannelNotifyAboutEvent:channel]) {

            if (!self.isUpdatingClientIdentifier) {

                [PNLogger logGeneralMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"UNSUBSCRIBED FROM CHANNELS (STATE: %@)", [self humanReadableStateFrom:self.state]];
                }];

				if ([self shouldChannelNotifyAboutEvent:channel]) {

					// Check whether delegate can handle unsubscription event or not
					if ([self.delegate respondsToSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)]) {

						[self.delegate performSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)
											withObject:self
											withObject:channels];
					}

                    [PNLogger logDelegateMessageFrom:self message:^NSString * {

                        return [NSString stringWithFormat:@"PubNub client successfully unsubscribed from channels: %@", channels];
                    }];


					[self sendNotification:kPNClientUnsubscriptionDidCompleteNotification withObject:channels];
				}
				else {

                    [PNLogger logGeneralMessageFrom:self message:^NSString * {

                        return [NSString stringWithFormat:@"UNSUBSCRIBED FROM CHANNELS DURING CLIENT IDENTIFIER UPDATE (STATE: %@)",
                        		[self humanReadableStateFrom:self.state]];
                    }];

					[self sendNotification:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification withObject:self];
				}
			}
		}
    };

    if (!isSequenced) {

        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {

        handlerBlock();
    }

    [self launchHeartbeatTimer];
}

- (void)messagingChannel:(PNMessagingChannel *)channel didFailUnsubscribeOnChannels:(NSArray *)channels
               withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutUnsubscriptionFailWithError:error completeLockingOperation:!isSequenced];

    [self launchHeartbeatTimer];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willEnablePresenceObservationOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"WILL ENABLE PRESENCE ON: %@", channels];
    }];

    if ([self isConnected]) {
        
        self.asyncLockingOperationInProgress = YES;
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didEnablePresenceObservationOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {

    void(^handlerBlock)(void) = ^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"DID ENABLE PRESENCE ON CHANNELS (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];

        if ([self shouldChannelNotifyAboutEvent:messagingChannel]) {

            // Check whether delegate can handle new message arrival or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didEnablePresenceObservationOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:didEnablePresenceObservationOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client successfully enabled presence observation on channels: "
                        "%@", channels];
            }];


            [self sendNotification:kPNClientPresenceEnablingDidCompleteNotification withObject:channels];
        }
    };

    if (!isSequenced) {

        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {

        handlerBlock();
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didFailPresenceEnablingOnChannels:(NSArray *)channels
               withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutPresenceEnablingFailWithError:error completeLockingOperation:!isSequenced];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willDisablePresenceObservationOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"WILL DISABLE PRESENCE ON: %@", channels];
    }];

    if ([self isConnected]) {
        
        self.asyncLockingOperationInProgress = YES;
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didDisablePresenceObservationOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {

    void(^handlerBlock)(void) = ^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"DID DISABLE PRESENCE ON CHANNELS (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];

        if ([self shouldChannelNotifyAboutEvent:messagingChannel]) {

            // Check whether delegate can handle new message arrival or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didDisablePresenceObservationOnChannels:)]) {

                [self.delegate performSelector:@selector(pubnubClient:didDisablePresenceObservationOnChannels:)
                                    withObject:self
                                    withObject:channels];
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client successfully disabled presence observation on channels: "
                        "%@", channels];
            }];


            [self sendNotification:kPNClientPresenceDisablingDidCompleteNotification withObject:channels];
        }
    };

    if (!isSequenced) {

        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {

        handlerBlock();
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didFailPresenceDisablingOnChannels:(NSArray *)channels
               withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    error.associatedObject = channels;
    [self notifyDelegateAboutPresenceDisablingFailWithError:error completeLockingOperation:!isSequenced];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveMessage:(PNMessage *)message {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"RECEIVED MESSAGE (STATE: %@)", [self humanReadableStateFrom:self.state]];
    }];
    [self launchHeartbeatTimer];
    
    if ([self shouldChannelNotifyAboutEvent:messagingChannel]) {
        
        // Check whether delegate can handle new message arrival or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessage:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:didReceiveMessage:)
                                withObject:self
                                withObject:message];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client received message: %@", message];
        }];

        
        [self sendNotification:kPNClientDidReceiveMessageNotification withObject:message];
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveEvent:(PNPresenceEvent *)event {
    
    // Try to update cached channel data
    PNChannel *channel = event.channel;
    if (channel) {
        
        [channel updateWithEvent:event];
    }

    // In case if there is no error and client identifier is the same as this one, client will store retrieved state
    // in cache (useful if someone from outside changed state for this client).
    if (event.type == PNPresenceEventStateChanged && [event.client.identifier isEqualToString:self.clientIdentifier]) {

        [self.cache purgeStateForChannel:event.client.channel];
        [self.cache storeClientState:event.client.data forChannel:event.client.channel];
    }

    [PNLogger logGeneralMessageFrom:self message:^NSString * {
        
        return [NSString stringWithFormat:@"RECEIVED EVENT (STATE: %@)", [self humanReadableStateFrom:self.state]];
    }];

    [self launchHeartbeatTimer];
    
    if ([self shouldChannelNotifyAboutEvent:messagingChannel]) {
        
        // Check whether delegate can handle presence event arrival or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceivePresenceEvent:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:didReceivePresenceEvent:)
                                withObject:self
                                withObject:event];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client received presence event: %@", event];
        }];

        
        [self sendNotification:kPNClientDidReceivePresenceEventNotification withObject:event];
    }
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveClientState:(PNClient *)client {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"CLIENT STATE RETRIEVED (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];

        // In case if there is no error and client identifier is the same as this one,
        // client will store retrieved state in cache.
        if ([client.identifier isEqualToString:self.clientIdentifier]) {
            
            [self.cache purgeStateForChannel:client.channel];
            [self.cache storeClientState:client.data forChannel:client.channel];
        }


        if ([self shouldChannelNotifyAboutEvent:channel]) {

            // Check whether delegate is able to handle state retrieval event or not
            SEL selector = @selector(pubnubClient:didReceiveClientState:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:client];
                #pragma clang diagnostic pop
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client successfully received state for client %@ on channel %@: %@ ",
                        client.identifier, client.channel, client.data];
            }];


            [self sendNotification:kPNClientDidReceiveClientStateNotification withObject:client];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel clientStateReceiveDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutStateRetrievalDidFailWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE CLIENT STATE AUDIT REQUEST (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        PNClient *clientInformation = (PNClient *)error.associatedObject;
        [[self class] requestClientState:clientInformation.identifier forChannel:clientInformation.channel
             withCompletionHandlingBlock:(id)@""];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didUpdateClientState:(PNClient *)client {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"CLIENT STATE UPDATED (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        // Ensure that we received data for this client or not
        if ([client.identifier isEqualToString:self.clientIdentifier]) {
            
            [self.cache storeClientState:client.data forChannel:client.channel];
        }

        if ([self shouldChannelNotifyAboutEvent:channel]) {

            // Check whether delegate is able to handle state update event or not
            SEL selector = @selector(pubnubClient:didUpdateClientState:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:client];
                #pragma clang diagnostic pop
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client successfully updated state for client %@ at channel %@: %@ ",
                        client.identifier, client.channel, client.data];
            }];


            [self sendNotification:kPNClientDidUpdateClientStateNotification withObject:client];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel clientStateUpdateDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutStateUpdateDidFailWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE CLIENT STATE UPDATE REQUEST (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        PNClient *clientInformation = (PNClient *)error.associatedObject;
        [[self class] updateClientState:clientInformation.identifier state:clientInformation.data
                             forChannel:clientInformation.channel withCompletionHandlingBlock:(id)@""];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"ACCESS RIGHTS CHANGED (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];

        if ([self shouldChannelNotifyAboutEvent:channel]) {

            // Check whether delegate is able to handle access rights change event or not
            SEL selector = @selector(pubnubClient:didChangeAccessRights:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:accessRightsCollection];
                #pragma clang diagnostic pop
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client changed access rights: %@", accessRightsCollection];
            }];


            [self sendNotification:kPNClientAccessRightsChangeDidCompleteNotification withObject:accessRightsCollection];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel accessRightsChangeDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutAccessRightsChangeFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE ACCESS RIGHTS UPDATE REQUEST (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        PNAccessRightOptions *rightsInformation = (PNAccessRightOptions *)error.associatedObject;
        [[self class] changeAccessRightsForChannels:rightsInformation.channels accessRights:rightsInformation.rights
                                            clients:rightsInformation.clientsAuthorizationKeys
                                          forPeriod:rightsInformation.accessPeriodDuration
                        withCompletionHandlingBlock:(id)@""];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"ACCESS RIGHTS AUDITED (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];

        if ([self shouldChannelNotifyAboutEvent:channel]) {

            // Check whether delegate is able to handle access rights change event or not
            SEL selector = @selector(pubnubClient:didAuditAccessRights:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:accessRightsCollection];
                #pragma clang diagnostic pop
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client audited access rights: %@", accessRightsCollection];
            }];


            [self sendNotification:kPNClientAccessRightsAuditDidCompleteNotification withObject:accessRightsCollection];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel accessRightsAuditDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutAccessRightsAuditFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE ACCESS RIGHTS AUDIT REQUEST (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        PNAccessRightOptions *rightsInformation = (PNAccessRightOptions *)error.associatedObject;
        [[self class] auditAccessRightsForChannels:rightsInformation.channels clients:rightsInformation.clientsAuthorizationKeys
                       withCompletionHandlingBlock:(id)@""];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveTimeToken:(NSNumber *)timeToken {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"RECEIVED TIME TOKEN (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:channel]) {
            
            // Check whether delegate can handle time token retrieval or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveTimeToken:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didReceiveTimeToken:)
                                    withObject:self
                                    withObject:timeToken];
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client recieved time token: %@", timeToken];
            }];
            
            
            [self sendNotification:kPNClientDidReceiveTimeTokenNotification withObject:timeToken];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel receiveTimeTokenDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutTimeTokenRetrievalFailWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE TIME TOKEN REQUEST (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        [[self class] requestServerTimeTokenWithCompletionBlock:(id)@""];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didEnablePushNotificationsOnChannels:(NSArray *)channels {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"ENABLED PUSH NOTIFICATIONS ON CHANNELS (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:channel]) {
            
            // Check whether delegate is able to handle push notification enabled event or not
            SEL selector = @selector(pubnubClient:didEnablePushNotificationsOnChannels:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:channels];
                #pragma clang diagnostic pop
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client enabled push notifications on channels: %@", channels];
            }];

            
            [self sendNotification:kPNClientPushNotificationEnableDidCompleteNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)                  serviceChannel:(PNServiceChannel *)channel
didFailPushNotificationEnableForChannels:(NSArray *)channels
                               withError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        error.associatedObject = channels;
        [self notifyDelegateAboutPushNotificationsEnableFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE PUSH NOTIFICATION ENABLE REQUEST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        NSData *devicePushToken = (NSData *)error.associatedObject;
        [[self class] enablePushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                             andCompletionHandlingBlock:(id)@""];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didDisablePushNotificationsOnChannels:(NSArray *)channels {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"DISABLED PUSH NOTIFICATIONS ON CHANNELS (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:channel]) {
            
            // Check whether delegate is able to handle push notification disable event or not
            SEL selector = @selector(pubnubClient:didDisablePushNotificationsOnChannels:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:channels];
                #pragma clang diagnostic pop
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client disabled push notifications on channels: %@", channels];
            }];

            
            [self sendNotification:kPNClientPushNotificationDisableDidCompleteNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)                   serviceChannel:(PNServiceChannel *)channel
didFailPushNotificationDisableForChannels:(NSArray *)channels
                                withError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        error.associatedObject = channels;
        [self notifyDelegateAboutPushNotificationsDisableFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE PUSH NOTIFICATION DISABLE REQUEST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        NSData *devicePushToken = (NSData *)error.associatedObject;
        [[self class] disablePushNotificationsOnChannels:channels withDevicePushToken:devicePushToken
                              andCompletionHandlingBlock:(id)@""];
    }
}

- (void)serviceChannelDidRemovePushNotifications:(PNServiceChannel *)channel {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"REMOVED PUSH NOTIFICATIONS FROM ALL CHANNELS (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:channel]) {
            
            // Check wheter delegate is able to handle successful push notification removal from
            // all channels or not
            SEL selector = @selector(pubnubClientDidRemovePushNotifications:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self];
                #pragma clang diagnostic pop
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client removed push notifications from all channels"];
            }];


            [self sendNotification:kPNClientPushNotificationRemoveDidCompleteNotification withObject:nil];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationsRemoveWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutPushNotificationsRemoveFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE PUSH NOTIFICATION REMOVAL REQUEST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        NSData *devicePushToken = (NSData *)error.associatedObject;
        [[self class] removeAllPushNotificationsForDevicePushToken:devicePushToken
                                       withCompletionHandlingBlock:(id)@""];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didReceivePushNotificationsEnabledChannels:(NSArray *)channels {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"DID RECEIVE PUSH NOTIFICATINO ENABLED CHANNELS (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:channel]) {
            
            // Check whether delegate is able to handle push notification enabled
            // channels retrieval or not
            SEL selector = @selector(pubnubClient:didReceivePushNotificationEnabledChannels:);
            if ([self.delegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:selector withObject:self withObject:channels];
                #pragma clang diagnostic pop
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client received push notificatino enabled channels: %@",
                        channels];
            }];

            
            [self sendNotification:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification withObject:channels];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationEnabledChannelsReceiveWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutPushNotificationsEnabledChannelsFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE PUSH NOTIFICATION AUDIT REQUEST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        NSData *devicePushToken = (NSData *)error.associatedObject;
        [[self class] requestPushNotificationEnabledChannelsForDevicePushToken:devicePushToken
                                                   withCompletionHandlingBlock:(id)@""];
    }
}

- (void)  serviceChannel:(PNServiceChannel *)channel
didReceiveNetworkLatency:(double)latency
     andNetworkBandwidth:(double)bandwidth {
    
    // TODO: NOTIFY NETWORK METER INSTANCE ABOUT ARRIVED DATA
}

- (void)serviceChannel:(PNServiceChannel *)channel willSendMessage:(PNMessage *)message {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"WILL SEND MESSAGE (STATE: %@)", [self humanReadableStateFrom:self.state]];
    }];
    
    if ([self shouldChannelNotifyAboutEvent:channel]) {
        
        // Check whether delegate can handle message sending event or not
        if ([self.delegate respondsToSelector:@selector(pubnubClient:willSendMessage:)]) {
            
            [self.delegate performSelector:@selector(pubnubClient:willSendMessage:)
                                withObject:self
                                withObject:message];
        }

        [PNLogger logDelegateMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"PubNub client is about to send message: %@", message];
        }];

        
        [self sendNotification:kPNClientWillSendMessageNotification withObject:message];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didSendMessage:(PNMessage *)message {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"DID SEND MESSAGE (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:channel]) {
            
            // Check whether delegate can handle message sent event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didSendMessage:)]) {
                
                [self.delegate performSelector:@selector(pubnubClient:didSendMessage:)
                                    withObject:self
                                    withObject:message];
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client sent message: %@", message];
            }];

            
            [self sendNotification:kPNClientDidSendMessageNotification withObject:message];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)channel didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        error.associatedObject = message;
        [self notifyDelegateAboutMessageSendingFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE MESSAGE SENDING REQUEST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        [[self class] sendMessage:message compressed:message.shouldCompressMessage
              withCompletionBlock:(id)@""];
    }
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveMessagesHistory:(PNMessagesHistory *)history {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"DID RECEIVE HISTORY ON CHANNEL (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:serviceChannel]) {
            
            // Check whether delegate can response on history download event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessageHistory:forChannel:startingFrom:to:)]) {
                
                [self.delegate pubnubClient:self
                   didReceiveMessageHistory:history.messages
                                 forChannel:history.channel
                               startingFrom:history.startDate
                                         to:history.endDate];
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client received history for %@ starting from %@ to %@: %@",
                        history.channel, history.startDate, history.endDate, history.messages];
            }];

            
            [self sendNotification:kPNClientDidReceiveMessagesHistoryNotification withObject:history];
        }
    }
                                shouldStartNext:YES];
}

- (void)           serviceChannel:(PNServiceChannel *)serviceChannel
  didFailHisoryDownloadForChannel:(PNChannel *)channel
                        withError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        error.associatedObject = channel;
        [self notifyDelegateAboutHistoryDownloadFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE MESSAGES HISTORY REQUEST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        NSDictionary *options = (NSDictionary *)error.associatedObject;
        [[self class] requestHistoryForChannel:channel from:[options valueForKey:@"startDate"] to:[options valueForKey:@"endDate"]
                                         limit:[[options valueForKey:@"limit"] integerValue]
                                reverseHistory:[[options valueForKey:@"revertMessages"] boolValue]
                            includingTimeToken:[[options valueForKey:@"includeTimeToken"] boolValue]
                           withCompletionBlock:(id)@""];
    }
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantsList:(PNHereNow *)participants {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"DID RECEIVE PARTICIPANTS LIST (STATE: %@)", [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:serviceChannel]) {
            
            // Check whether delegate can response on participants list download event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveParticipantsList:forChannel:)]) {
                
                [self.delegate pubnubClient:self
                 didReceiveParticipantsList:participants.participants
                                 forChannel:participants.channel];
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client received participants list for channel %@: %@",
                        participants.participants, participants.channel];
            }];

            
            [self sendNotification:kPNClientDidReceiveParticipantsListNotification withObject:participants];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailParticipantsListLoadForChannel:(PNChannel *)channel
             withError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        error.associatedObject = channel;
        [self notifyDelegateAboutParticipantsListDownloadFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE PARTICIPANTS LIST REQUEST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        NSDictionary *options = (NSDictionary *)error.associatedObject;
        [[self class] requestParticipantsListForChannel:channel clientIdentifiersRequired:[[options valueForKey:@"clientIdentifiersRequired"] boolValue]
                                            clientState:[[options valueForKey:@"fetchClientState"] boolValue]
                                    withCompletionBlock:(id)@""];
    }
    
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantChannelsList:(PNWhereNow *)participantChannels {

    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"DID RECEIVE PARTICIPANT CHANNELS LIST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];

        if ([self shouldChannelNotifyAboutEvent:serviceChannel]) {

            // Check whether delegate can response on participant channels list download event or not
            if ([self.delegate respondsToSelector:@selector(pubnubClient:didReceiveParticipantChannelsList:forIdentifier:)]) {

                [self.delegate pubnubClient:self
          didReceiveParticipantChannelsList:participantChannels.channels
                              forIdentifier:participantChannels.identifier];
            }

            [PNLogger logDelegateMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"PubNub client received participant channels list for identifier %@: %@",
                        participantChannels.identifier, participantChannels.channels];
            }];


            [self sendNotification:kPNClientDidReceiveParticipantChannelsListNotification withObject:participantChannels];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailParticipantChannelsListLoadForIdentifier:(NSString *)clientIdentifier
             withError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        error.associatedObject = clientIdentifier;
        [self notifyDelegateAboutParticipantChannelsListDownloadFailedWithError:error];
    }
    else {
        
        [PNLogger logGeneralMessageFrom:self message:^NSString * {
            
            return [NSString stringWithFormat:@"RESCHEDULE CLIENT'S CHANNELS REQUEST (STATE: %@)",
                    [self humanReadableStateFrom:self.state]];
        }];
        
        [[self class] requestParticipantChannelsList:clientIdentifier
                                 withCompletionBlock:(id)@""];
    }
}


#pragma mark - Memory management

- (void)dealloc {

    [self.cache purgeAllState];
    self.cache = nil;

    [PNLogger logGeneralMessageFrom:self message:^NSString * { return @"Destroyed"; }];
}

#pragma mark -


@end
