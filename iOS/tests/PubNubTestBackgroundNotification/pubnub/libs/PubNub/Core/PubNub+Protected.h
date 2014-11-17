/**
 Extending \b PubNub class with properties and methods which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */

#import "PNPrivateImports.h"
#import "PNConnectionChannelDelegate.h"
#import "PNServiceChannelDelegate.h"
#import "PNMessageChannelDelegate.h"
#import "PNDelegate.h"
#import "PNMacro.h"
#import "PubNub.h"


@class PNConfiguration, PNReachability, PNCryptoHelper, PNBaseRequest, PNCache;


#pragma mark Static

typedef enum _PNPubNubClientState {

    // Client instance was reset
    PNPubNubClientStateReset,
    
    // Client instance was just created
    PNPubNubClientStateCreated,
    
    // Client is trying to establish connection to remote PubNub services
    PNPubNubClientStateConnecting,
    
    // Client successfully connected to remote PubNub services
    PNPubNubClientStateConnected,
    
    // Client is disconnecting from remote services
    PNPubNubClientStateDisconnecting,
    
    // Client closing connection because configuration has been changed while client was connected
    PNPubNubClientStateDisconnectingOnConfigurationChange,
    
    // Client is disconnecting from remote services because of network failure
    PNPubNubClientStateDisconnectingOnNetworkError,
    
    // Client disconnected from remote PubNub services (by user request)
    PNPubNubClientStateDisconnected,

    PNPubNubClientStateSuspended,
    
    // Client disconnected from remote PubNub service because of network failure
    PNPubNubClientStateDisconnectedOnNetworkError
} PNPubNubClientState;


#pragma mark - Private interface declaration

@interface PubNub (Protected)


#pragma mark - Properties

/**
 Stores current client state.
 */
@property (nonatomic, assign) PNPubNubClientState state;

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
 Stores reference on client delegate
 */
@property (nonatomic, pn_desired_weak) id<PNDelegate> clientDelegate;

/**
 Stores whether library is performing one of async locking methods or not (if yes, other calls will be placed
 into pending set)
 */
@property (nonatomic, assign, getter = isAsyncLockingOperationInProgress) BOOL asyncLockingOperationInProgress;

/**
 Stores whether client updating client identifier or not
 */
@property (nonatomic, assign, getter = isUpdatingClientIdentifier) BOOL updatingClientIdentifier;

/**
 Stores whether client is restoring connection after network failure or not
 */
@property (nonatomic, assign, getter = isRestoringConnection) BOOL restoringConnection;


#pragma mark - Instance methods

/**
 Reschedule \b PubNub method call. Depending on whether client will perform some actions on it's own, this method will
 deal with procedural lock to make sure that re-scheduled method will be triggered in time.
 
 @param methodBlock
 Block which contains reference on method call which should be launched again w/o handling block modification.
 */
- (void)rescheduleMethodCall:(void(^)(void))methodBlock;

/**
 Check whether delegate should be notified about some runtime event (errors will be notified w/o regard to this flag)
 
 @param channel
 Reference on connection channel at which callback is fired.
 
 @return \c YES in case if reporting channel is in correct state and it's callback should be taken into account.
 */
- (void)checkShouldChannelNotifyAboutEvent:(PNConnectionChannel *)channel withBlock:(void (^)(BOOL shouldNotify))checkCompletionBlock;

/**
 Launch heartbeat timer if possible (if client connected and there is channels on which client subscribed at this
 moment).
 */
- (void)launchHeartbeatTimer;

/**
 Disable previously launched heartbeat timer.
 */
- (void)stopHeartbeatTimer;


#pragma mark - Requests management methods

/**
 * Sends message over corresponding communication channel
 */
- (void)sendRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing;


#pragma mark - Handler methods

/**
 Handle locking operation completion and pop new one from pending invocations list.
 
 @param shouldStartNext
 If set to \c YES next postponed method call will be executed.
 */
- (void)handleLockingOperationComplete:(BOOL)shouldStartNext;

/**
 Handle locking operation completion and pop new one from pending invocations list.
 
 @param operationPostBlock
 Block which is called when locking operation completed.
 
 @param shouldStartNext
 If set to \c YES next postponed method call will be executed.
 */
- (void)handleLockingOperationBlockCompletion:(void(^)(void))operationPostBlock shouldStartNext:(BOOL)shouldStartNext;


#pragma mark - Misc methods

/**
 Retrieve request execution possibility code. If everything is fine, than 0 will be returned, in other case it will
 be treated as error and mean that request execution is impossible
 */
- (NSInteger)requestExecutionPossibilityStatusCode;

/**
 Allow to perform code which should lock asynchronous methods execution till it ends and in case if code itself
 should be postponed, corresponding block is passed.
 
 @param codeBlock
 Block of code which should be performed if procedural lock is turned off.
 
 @param postponedCodeBlock
 Block of code which will be called if procedural lock is on and doesn't allow to run another operation,
 */
- (void)performAsyncLockingBlock:(void(^)(void))codeBlock postponedExecutionBlock:(void(^)(void))postponedCodeBlock;

/**
 * Place selector into list of postponed calls with corresponding parameters If 'placeOutOfOrder' is specified,
 * selector will be placed first in FIFO queue and will be executed as soon as it will be possible.
 */
- (void)postponeSelector:(SEL)calledMethodSelector forObject:(id)object withParameters:(NSArray *)parameters
              outOfOrder:(BOOL)placeOutOfOrder;

/**
 Wrap around NSNotificationCenter to simplify notification sending.
 
 @param notificationName
 Name of notificatino which should be sent.
 
 @param object
 Reference on object along with which notification should be sent.
 */
- (void)sendNotification:(NSString *)notificationName withObject:(id)object;

/**
 Convert provided client state informatino into human-readable format.
 
 @param state
 One field from \b PNPubNubClientState enumerator.
 
 @return Formatted string
 */
- (NSString *)humanReadableStateFrom:(PNPubNubClientState)state;

#pragma mark -


@end
