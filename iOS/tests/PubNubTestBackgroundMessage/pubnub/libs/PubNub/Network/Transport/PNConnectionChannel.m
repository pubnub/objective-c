//
//  PNConnectionChannel.m
//  pubnub
//
//  Connection channel is intermediate class between transport network layer and other library classes.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import "PNConnectionChannel.h"
#import "PNConnection+Protected.h"
#import "NSObject+PNAdditions.h"
#import "PNNotifications.h"
#import "PNRequestsQueue.h"
#import "PNConfiguration.h"
#import "PNErrorCodes.h"
#import "PNResponse.h"
#import "PNHelper.h"
#import "PNError.h"

#import "PNLoggerSymbols.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub connection channel  must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Structures

typedef NS_OPTIONS(NSUInteger, PNConnectionStateFlag)  {

    // Channel trying to establish connection to PubNub services
    PNConnectionChannelConnecting = 1 << 0,

    // Channel reconnecting with same settings which was used during initialization
    PNConnectionChannelReconnect = 1 << 1,

    // Channel is resuming it's operation state
    PNConnectionChannelResuming = 1 << 2,

    // Channel is ready for work (connections established and requests queue is ready)
    PNConnectionChannelConnected = 1 << 3,

    // Channel is transferring to suspended state
    PNConnectionChannelSuspending = 1 << 4,

    // Channel is in suspended state
    PNConnectionChannelSuspended = 1 << 5,

    // Channel is disconnecting on user request (for example: leave request for all channels)
    PNConnectionChannelDisconnecting = 1 << 6,

    // Channel is ready, but was disconnected and waiting command for connection (or was unable to connect during
    // initialization). All requests queue is alive (if they wasn't flushed by user)
    PNConnectionChannelDisconnected = 1 << 7
};

typedef NS_OPTIONS(NSUInteger, PNConnectionErrorStateFlag)  {

    // Flag which allow to set whether client is experiencing some error or not
    PNConnectionChannelError = 1 << 8
};

// Structure describes stored request packet structure
struct PNStoredRequestKeysStruct {

    __unsafe_unretained NSString *request;

    // Under this key is stored whether request should be observer by user or not
    __unsafe_unretained NSString *isObserved;
};

struct PNStoredRequestKeysStruct PNStoredRequestKeys = {
    .request = @"request",
    .isObserved = @"shouldObserve"
};


#pragma mark - Private interface methods

@interface PNConnectionChannel () <PNConnectionDelegate>


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) PNConfiguration *configuration;

/**
 Stores reference on all requests on which we are waiting for response
 */
@property (nonatomic, strong) NSMutableDictionary *observedRequests;

/**
 Stores reference on all requests which was required to be stored because of some reasons (for example re-schedule
 request in case of error)
 */
@property (nonatomic, strong) NSMutableDictionary *storedRequests;

/**
 Stores list of identifiers from requests which has been sent and waiting for response (request objects is stored
 inside 'storedRequests' and can be accessed with keys from this array)
 */
@property (nonatomic, strong) NSMutableArray *storedRequestsList;

/**
 Stores reference on array of scheduled requests
 */
@property (nonatomic, strong) PNRequestsQueue *requestsQueue;

/**
 Stores reference on connection which is used as transport layer to send messages to the PubNub service
 */
@property (nonatomic, strong) PNConnection *connection;

/**
 Timer used to track requests execution time and report timeout if execution time (till response arrive) exceeded
 allowed time frame
 */
@property (nonatomic, strong) NSTimer *timeoutTimer;

/**
 Current connection channel state
 */
@property (nonatomic, assign) unsigned long state;

@property (nonatomic, strong) NSString *name;


#pragma mark - Instance methods

/**
 Allow schedule stored requests back into requests queue. Which requests should be scheduled back controlled by
 subclass instances

 @note Template method
 */
- (void)rescheduleStoredRequests:(NSArray *)requestsList;

/**
 Allow schedule stored requests back into requests queue. Which requests should be scheduled back controlled by
 subclass instances

 @param requestsList
 List of requests which should be rescheduled for further processing.

 @param shouldResetRequestsRetryCount
 Whether requests' error counter should be reset or not.

 @note Template method
 */
- (void)rescheduleStoredRequests:(NSArray *)requestsList resetRetryCount:(BOOL)shouldResetRequestsRetryCount;

/**
 Retrieve reference on stored request at specific index
 */
- (PNBaseRequest *)storedRequestAtIndex:(NSUInteger)requestIndex;

/**
 Check whether response should be processed on this communication channel or not
 */
- (BOOL)shouldHandleResponse:(PNResponse *)response;

/**
 Launch/stop request timeout timer which will be fired if no response will arrive from service along specified
 timeout in seconds
 */
- (void)startTimeoutTimerForRequest:(PNBaseRequest *)request;
- (void)stopTimeoutTimerForRequest:(PNBaseRequest *)request;


#pragma mark - Handler methods

/**
 Called by timeout timer

 @note Template method
 */
- (void)handleTimeoutTimer:(NSTimer *)timer;

/**
 Called when new request is scheduled on queue and specify whether request should be stored for some time or not

 @note Template method
 */
- (BOOL)shouldStoreRequest:(PNBaseRequest *)request;


#pragma mark - Misc methods

/**
 @brief Transport layer initialization if required
 
 @discussion Connection initialization required before usage. In case if there is no previous connection instance, it 
 will be created with current channel configuration.
 
 @since 3.7.0
 */
- (void)prepareConnectionIfRequired;

- (BOOL)isConnecting;

/**
 * Allow to manipulate with requests in specific storage by their identifiers
 */
- (id)requestFromStorage:(NSMutableDictionary *)storage withIdentifier:(NSString *)identifier;
- (void)removeRequest:(PNBaseRequest *)request fromStorage:(NSMutableDictionary *)storage;

/**
 Print our current connection state
 */
- (NSString *)stateDescription;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNConnectionChannel


#pragma mark - Class methods

+ (id)connectionChannelWithConfiguration:(PNConfiguration *)configuration type:(PNConnectionChannelType)connectionChannelType
                             andDelegate:(id<PNConnectionChannelDelegate>)delegate {
    
    return [[[self class] alloc] initWithConfiguration:configuration type:connectionChannelType andDelegate:delegate];
}


#pragma mark - Instance methods

- (id)initWithConfiguration:(PNConfiguration *)configuration type:(PNConnectionChannelType)connectionChannelType
                andDelegate:(id<PNConnectionChannelDelegate>)delegate {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        self.delegate = delegate;
        self.configuration = configuration;
        [PNBitwiseHelper clear:&_state];
        self.observedRequests = [NSMutableDictionary dictionary];
        self.storedRequests = [NSMutableDictionary dictionary];
        self.storedRequestsList = [NSMutableArray array];

        
        // Retrieve connection identifier based on connection channel type
        self.name = PNConnectionIdentifiers.messagingConnection;
        if (connectionChannelType == PNConnectionChannelService) {
            
            self.name = PNConnectionIdentifiers.serviceConnection;
        }

        // Set initial connection channel state
        [PNBitwiseHelper removeFrom:&_state bit:PNConnectionChannelDisconnected];

        dispatch_queue_t targetQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [self pn_setPrivateDispatchQueue:[self pn_serialQueueWithOwnerIdentifier:@"connection-channel" andTargetQueue:targetQueue]];

        // Initialize connection to the PubNub services
        self.requestsQueue = [PNRequestsQueue new];
        self.requestsQueue.delegate = self;
        
        [self connect];
    }
    
    
    return self;
}

- (void)connect {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.connectionAttempt, (self.name ? self.name : self), @(self.state)];
        }];

        void(^connectionCompletionSimulation)(void) = ^{

            [PNBitwiseHelper clear:&_state];
            [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelConnected];

            // Because with getters 'isConnected' channel provided wrong state, outside code may rely on connection
            // completion notifications, so we simulate it
            [self connection:self.connection didConnectToHost:self.configuration.origin];
        };
        

        // Check whether connection already connected but channel internal state is out of sync
        if (([self.connection isConnected] && ![self isConnected])) {

            [PNLogger logCommunicationChannelWarnMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.outOfSyncWithConnection, (self.name ? self.name : self), @(self.state)];
            }];

            connectionCompletionSimulation();
        }
        // Checking whether data connection is connected or not
        else if (![self.connection isConnected]) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.connecting, (self.name ? self.name : self), @(self.state)];
            }];

            [PNBitwiseHelper clear:&_state];
            [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelDisconnected, PNConnectionChannelConnecting, BITS_LIST_TERMINATOR];
            [self prepareConnectionIfRequired];
            [self.connection connect];
        }
        // Check whether channel already connected or not
        else if ([self isConnected]) {

            connectionCompletionSimulation();
        }
    }];
}

- (BOOL)isConnecting {

    __block BOOL isConnecting = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        isConnecting = [PNBitwiseHelper is:self.state strictly:YES containsBits:PNConnectionChannelDisconnected, PNConnectionChannelConnecting,
                        BITS_LIST_TERMINATOR];
    }];

    
    return isConnecting;
}

- (BOOL)isReconnecting {

    __block BOOL isReconnecting = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        isReconnecting = [PNBitwiseHelper is:self.state strictly:YES containsBits:PNConnectionChannelConnecting, PNConnectionChannelReconnect,
                          BITS_LIST_TERMINATOR];
    }];

    
    return isReconnecting;
}

- (BOOL)isConnected {

    __block BOOL isConnected = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        isConnected = [PNBitwiseHelper is:self.state containsBit:PNConnectionChannelConnected] && ![self isReconnecting];
    }];


    return isConnected;
}

- (void)disconnect {

    [self pn_dispatchAsynchronouslyBlock:^{

        [self disconnectWithEvent:YES];
    }];
}

- (void)disconnectOnInternalRequest {

    [self.connection closeConnection];
}

- (void)disconnectWithEvent:(BOOL)shouldNotifyOnDisconnection {

    NSString *symbolCode = PNLoggerSymbols.connectionChannel.disconnectingWithEvent;
    if (!shouldNotifyOnDisconnection) {

        symbolCode = PNLoggerSymbols.connectionChannel.disconnectingWithOutEvent;
    }

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[symbolCode, (self.name ? self.name : self), @(self.state)];
        }];

        void(^disconnectionCompletionSimulation)() = ^{

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.disconnected, (self.name ? self.name : self), @(self.state)];
            }];

            [PNBitwiseHelper clear:&_state];
            [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelDisconnected];

            [self stopTimeoutTimerForRequest:nil];
            [self unscheduleNextRequest];

            if (shouldNotifyOnDisconnection) {

                // Because with getters 'isDisconnected' channel provided wrong state, outside code may rely on disconnection
                // completion notifications, so we simulate it
                [self connection:self.connection didDisconnectFromHost:self.configuration.origin];
            }
        };

        // Check whether connection already disconnected but channel internal state is out of sync
        if ([self.connection isDisconnected] && ![self isDisconnected]) {

            [PNLogger logCommunicationChannelWarnMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.outOfSyncWithDisconnection, (self.name ? self.name : self),
                        @(self.state)];
            }];


            // Destroy connection communication instance
            self.connection.delegate = nil;
            _connection = nil;

            disconnectionCompletionSimulation();
        }
            // Checking whether data connection is disconnected or not
        else if (![self.connection isDisconnected]) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.disconnecting, (self.name ? self.name : self), @(self.state)];
            }];


            [PNBitwiseHelper clear:&_state];
            if (shouldNotifyOnDisconnection) {

                [self stopTimeoutTimerForRequest:nil];
                [self unscheduleNextRequest];

                [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelConnected, PNConnectionChannelDisconnecting,
                                       BITS_LIST_TERMINATOR];
                [self.connection disconnect];
            }
            else {

                // Destroy connection communication instance
                self.connection.delegate = nil;
                _connection = nil;

                disconnectionCompletionSimulation();
            }
        }
            // Check whether channel already disconnected or not
        else if ([self isConnected]) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.disconnecting, (self.name ? self.name : self), @(self.state)];
            }];

            self.connection.delegate = nil;
            _connection = nil;

            disconnectionCompletionSimulation();
        }
        else {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.alreadyDisconnected, (self.name ? self.name : self), @(self.state)];
            }];

            self.connection.delegate = nil;
            _connection = nil;
        }
    }];
}

- (BOOL)isDisconnecting {

    __block BOOL isDisconnecting = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        isDisconnecting = [PNBitwiseHelper is:self.state strictly:YES containsBits:PNConnectionChannelConnected, PNConnectionChannelDisconnecting,
                           BITS_LIST_TERMINATOR];
    }];


    return isDisconnecting;
}

- (BOOL)isDisconnected {

    __block BOOL isDisconnected = NO;

    [self pn_dispatchSynchronouslyBlock:^{

        isDisconnected = [PNBitwiseHelper is:self.state containsBit:PNConnectionChannelDisconnected];
        isDisconnected = isDisconnected || [PNBitwiseHelper is:self.state containsBit:PNConnectionChannelSuspended];
        isDisconnected = isDisconnected && ![self isConnecting];
    }];


    return isDisconnected;
}

- (void)suspend {

    [self pn_dispatchSynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.suspensionAttempt, (self.name ? self.name : self), @(self.state)];
        }];

        void(^suspensionCompletionSimulation)(void) = ^{

            [PNBitwiseHelper clear:&_state];
            [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelDisconnected, PNConnectionChannelSuspended, BITS_LIST_TERMINATOR];

            [self stopTimeoutTimerForRequest:nil];
            [self unscheduleNextRequest];

            // Because with getters 'isSuspended' channel provided wrong state, outside code may rely on suspension
            // completion notifications, so we simulate it
            [self connectionDidSuspend:self.connection];
        };

        // Check whether connection already suspended but channel internal state is out of sync
        if ([self.connection isSuspended] && ![self.connection isResuming] && ![self isSuspended]) {

            [PNLogger logCommunicationChannelWarnMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.outOfSyncWithSuspension, (self.name ? self.name : self),
                         @(self.state)];
            }];

            suspensionCompletionSimulation();
        }
        // Checking whether data connection is suspended or try to resume
        else if (![self.connection isSuspended] || [self.connection isResuming]) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.suspending, (self.name ? self.name : self), @(self.state)];
            }];

            [PNBitwiseHelper clear:&_state];
            [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelConnected, PNConnectionChannelSuspending, BITS_LIST_TERMINATOR];

            [self stopTimeoutTimerForRequest:nil];
            [self unscheduleNextRequest];

            [self.delegate connectionChannelWillSuspend:self];

            [self.connection suspend];
        }
        // Check whether channel already suspended or not
        else if ([self isSuspended]) {

            suspensionCompletionSimulation();
        }
    }];
}

- (BOOL)isSuspending {

    __block BOOL isSuspending = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        isSuspending = [PNBitwiseHelper is:self.state strictly:YES containsBits:PNConnectionChannelConnected, PNConnectionChannelSuspending,
                        BITS_LIST_TERMINATOR];
    }];


    return isSuspending;
}

- (BOOL)isSuspended {

    __block BOOL isSuspended = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        isSuspended = [PNBitwiseHelper is:self.state strictly:YES containsBits:PNConnectionChannelDisconnected,
                       PNConnectionChannelSuspended, BITS_LIST_TERMINATOR];
    }];


    return isSuspended;
}

- (void)resume {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.resumeAttempt, (self.name ? self.name : self), @(self.state)];
        }];

        void(^resumingCompletionSimulation)(void) = ^{

            [PNBitwiseHelper clear:&_state];
            [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelConnected];

            // Because with getters 'isSuspended' channel provided wrong state, outside code may rely on resume completion
            // notifications, so we simulate it
            [self connectionDidResume:self.connection];
        };

        // Check whether connection already resumed but channel internal state is out of sync
        if (![self.connection isSuspended] && [self isSuspended]) {

            [PNLogger logCommunicationChannelWarnMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.outOfSyncWithResuming, (self.name ? self.name : self),
                         @(self.state)];
            }];

            resumingCompletionSimulation();
        }
        // Checking whether data connection is suspended or not
        else if ([self.connection isSuspended]) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.resuming, (self.name ? self.name : self), @(self.state)];
            }];

            [PNBitwiseHelper clear:&_state];
            [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelDisconnected, PNConnectionChannelResuming, BITS_LIST_TERMINATOR];
            [self.delegate connectionChannelWillResume:self];

            [self.connection resume];
        }
        // Check whether channel already resumed or not
        else if (![self isSuspended]) {

            resumingCompletionSimulation();
        }
    }];
}

- (BOOL)isResuming {

    __block BOOL isResuming = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        isResuming = [PNBitwiseHelper is:self.state strictly:YES containsBits:PNConnectionChannelDisconnected,
                      PNConnectionChannelResuming, BITS_LIST_TERMINATOR];
    }];

    return isResuming;
}

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
}

- (BOOL)isWaitingRequestCompletion:(NSString *)requestIdentifier {
    
    return [self observedRequestWithIdentifier:requestIdentifier] != nil ||
           [self isWaitingStoredRequestCompletion:requestIdentifier];
}

- (BOOL)shouldScheduleRequest:(PNBaseRequest *)request {

    return YES;
}

- (void)handleRequestProcessingDidFail:(PNBaseRequest *)request withError:(PNError *)error {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
}

- (void)makeScheduledRequestsFail:(NSArray *)requestsList withError:(PNError *)processingError {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
}

- (void)purgeObservedRequestsPool {

    [self pn_dispatchSynchronouslyBlock:^{

        [self.observedRequests removeAllObjects];
    }];
}

- (id)requestFromStorage:(NSMutableDictionary *)storage withIdentifier:(NSString *)identifier {

    __block PNBaseRequest *request = nil;
    if(identifier != nil) {

        request = [storage valueForKey:identifier];
    }


    return request;
}

- (void)removeRequest:(PNBaseRequest *)request fromStorage:(NSMutableDictionary *)storage {

    if(request != nil) {

        [storage removeObjectForKey:request.shortIdentifier];
    }
}

- (PNBaseRequest *)requestWithIdentifier:(NSString *)identifier {

    PNBaseRequest *request = [self observedRequestWithIdentifier:identifier];
    if (!request) {

        request = [self storedRequestWithIdentifier:identifier];
    }


    return request;
}

- (PNBaseRequest *)observedRequestWithIdentifier:(NSString *)identifier {

    __block PNBaseRequest *request = nil;
    [self pn_dispatchSynchronouslyBlock:^{

        request = [self requestFromStorage:self.observedRequests withIdentifier:identifier];
    }];


    return request;
}

- (void)removeObservationFromRequest:(PNBaseRequest *)request {

    [self pn_dispatchAsynchronouslyBlock:^{

        [self removeRequest:request fromStorage:self.observedRequests];
    }];
}

- (void)purgeStoredRequestsPool {

    [self pn_dispatchAsynchronouslyBlock:^{

        [self.storedRequestsList removeAllObjects];
        [self.storedRequests removeAllObjects];
    }];
}

- (PNBaseRequest *)storedRequestWithIdentifier:(NSString *)identifier {

    __block PNBaseRequest *request = nil;
    [self pn_dispatchSynchronouslyBlock:^{

        NSDictionary *storedRequestInformation = [self requestFromStorage:self.storedRequests withIdentifier:identifier];
        request = [storedRequestInformation valueForKeyPath:PNStoredRequestKeys.request];
    }];


    return request;
}

- (PNBaseRequest *)nextStoredRequest {

    return [self storedRequestAtIndex:0];
}

- (PNBaseRequest *)nextStoredRequestAfter:(PNBaseRequest *)request {

    __block PNBaseRequest *nextRequest = nil;
    [self pn_dispatchSynchronouslyBlock:^{

        NSUInteger previousRequestIndex = [self.storedRequestsList indexOfObject:request.shortIdentifier];
        if (previousRequestIndex != NSNotFound) {

            nextRequest = [self storedRequestAtIndex:(previousRequestIndex + 1)];
        }
    }];


    return nextRequest;
}

- (PNBaseRequest *)lastStoredRequest {

    __block PNBaseRequest *lastStoredRequest = nil;
    [self pn_dispatchSynchronouslyBlock:^{

        lastStoredRequest = [self storedRequestAtIndex:MAX([self.storedRequestsList count] - 1, 0)];
    }];


    return lastStoredRequest;
}

- (PNBaseRequest *)storedRequestAtIndex:(NSUInteger)requestIndex {

    __block PNBaseRequest *request = nil;
    [self pn_dispatchSynchronouslyBlock:^{

        if ([self.storedRequestsList count] > 0 && requestIndex < [self.storedRequestsList count]) {

            NSString *requestIdentifier = [self.storedRequestsList objectAtIndex:requestIndex];
            request = [self storedRequestWithIdentifier:requestIdentifier];
        }
    }];


    return request;
}

- (BOOL)isWaitingStoredRequestCompletion:(NSString *)identifier {

    __block BOOL isWaitingStoredRequestCompletion = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        NSDictionary *storedRequestInformation = [self requestFromStorage:self.storedRequests withIdentifier:identifier];
        isWaitingStoredRequestCompletion = [[storedRequestInformation valueForKeyPath:PNStoredRequestKeys.isObserved] boolValue];
    }];


    return isWaitingStoredRequestCompletion;
}

- (void)removeStoredRequest:(PNBaseRequest *)request {

    if (request) {

        [self pn_dispatchAsynchronouslyBlock:^{

            [self.storedRequestsList removeObject:request.shortIdentifier];
            [self removeRequest:request fromStorage:self.storedRequests];
        }];
    }
}

- (void)destroyRequest:(PNBaseRequest *)request {

    if (request) {
        
        [self unscheduleRequest:request];
        [self removeStoredRequest:request];
        [self removeObservationFromRequest:request];
    }
}

- (void)destroyByRequestClass:(Class)requestClass {

    [self pn_dispatchAsynchronouslyBlock:^{

        NSMutableArray *requests = [NSMutableArray array];
        [self.storedRequestsList enumerateObjectsUsingBlock:^(id requestIdentifier, NSUInteger requestIdentifierIdx,
                                                              BOOL *requestIdentifierEnumeratorStop) {

            PNBaseRequest *request = [self storedRequestWithIdentifier:requestIdentifier];
            if ([request isKindOfClass:requestClass]) {

                [requests addObject:request];
            }
        }];

        [requests enumerateObjectsUsingBlock:^(id request, NSUInteger requestIdx, BOOL *requestEnumeratorStop) {

            [self destroyRequest:request];
        }];
    }];
}

- (BOOL)hasRequestsWithClass:(Class)requestClass {

    __block BOOL hasRequestsWithClass = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        [self.storedRequestsList enumerateObjectsUsingBlock:^(id requestIdentifier, NSUInteger requestIdentifierIdx,
                                                              BOOL *requestIdentifierEnumeratorStop) {

            PNBaseRequest *request = [self storedRequestWithIdentifier:requestIdentifier];
            if ([request isKindOfClass:requestClass]) {

                hasRequestsWithClass = YES;
                *requestIdentifierEnumeratorStop = YES;
            }
        }];
    }];


    return hasRequestsWithClass;
}

- (NSArray *)requestsWithClass:(Class)requestClass {

    NSMutableArray *requests = [NSMutableArray array];
    [self pn_dispatchSynchronouslyBlock:^{

        [self.storedRequestsList enumerateObjectsUsingBlock:^(id requestIdentifier, NSUInteger requestIdentifierIdx,
                                                              BOOL *requestIdentifierEnumeratorStop) {

            PNBaseRequest *request = [self storedRequestWithIdentifier:requestIdentifier];
            if ([request isKindOfClass:requestClass]) {

                [requests addObject:request];
            }
        }];
    }];


    return requests;
}

- (void)prepareConnectionIfRequired {
    
    [self pn_dispatchSynchronouslyBlock:^{
        
        if (_connection == nil) {
            
            _connection = [PNConnection connectionWithConfiguration:self.configuration andIdentifier:self.name];
            
            [_connection pn_dispatchSynchronouslyBlock:^{
                
                _connection.delegate = self;
                _connection.dataSource = self.requestsQueue;
            }];
            
            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.connectionChannel.resourceLinkage, (self.name ? self.name : self),
                         (self.requestsQueue ? [NSString stringWithFormat:@"%p", self.requestsQueue] : [NSNull null]),
                         (_connection ? [NSString stringWithFormat:@"%p", _connection] : [NSNull null])];
            }];
        }
    }];
}


#pragma mark - Handler methods

- (void)handleTimeoutTimer:(NSTimer *)timer {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
}

- (BOOL)shouldStoreRequest:(PNBaseRequest *)request {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
    
    
    return YES;
}


#pragma mark - Misc methods

- (NSString *)stateDescription {

    NSMutableString *connectionState = [NSMutableString stringWithFormat:@"\n[CHANNEL::%@ STATE DESCRIPTION", self.name];
    if ([PNBitwiseHelper is:self.state containsBit:PNConnectionChannelConnecting]) {

        [connectionState appendFormat:@"\n- CONNECTING..."];
    }
    if ([PNBitwiseHelper is:self.state containsBit:PNConnectionChannelReconnect]) {

        [connectionState appendFormat:@"\n- RECONNECTING..."];
    }
    if ([PNBitwiseHelper is:self.state containsBit:PNConnectionChannelResuming]) {

        [connectionState appendFormat:@"\n- RESUMING..."];
    }
    if ([PNBitwiseHelper is:self.state containsBit:PNConnectionChannelConnected]) {

        [connectionState appendFormat:@"\n- CONNECTED"];
    }
    if ([PNBitwiseHelper is:self.state containsBit:PNConnectionChannelSuspending]) {

        [connectionState appendFormat:@"\n- SUSPENDING..."];
    }
    if ([PNBitwiseHelper is:self.state containsBit:PNConnectionChannelSuspended]) {

        [connectionState appendFormat:@"\n- SUSPENDED"];
    }
    if ([PNBitwiseHelper is:self.state containsBit:PNConnectionChannelDisconnecting]) {

        [connectionState appendFormat:@"\n- DISCONNECTING..."];
    }
    if ([PNBitwiseHelper is:self.state containsBit:PNConnectionChannelDisconnected]) {

        [connectionState appendFormat:@"\n- DISCONNECTED"];
    }
    if ([PNBitwiseHelper is:self.state containsBit:PNConnectionChannelError]) {

        [connectionState appendFormat:@"\n- ERROR"];
    }


    return connectionState;
}


#pragma mark - Requests queue management methods

- (void)scheduleRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing {

    [self scheduleRequest:request shouldObserveProcessing:shouldObserveProcessing outOfOrder:NO launchProcessing:YES];
}

- (void)scheduleRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing
             outOfOrder:(BOOL)shouldEnqueueRequestOutOfOrder launchProcessing:(BOOL)shouldLaunchRequestsProcessing {

    [self pn_dispatchAsynchronouslyBlock:^{

        if ([self shouldScheduleRequest:request]) {

            if([self.requestsQueue enqueueRequest:request outOfOrder:shouldEnqueueRequestOutOfOrder]) {
                
                [request finalizeWithConfiguration:self.configuration clientIdentifier:[self.delegate clientIdentifier]];

                if (shouldObserveProcessing) {

                    [self.observedRequests setValue:request forKey:request.shortIdentifier];
                }

                if ([self shouldStoreRequest:request]) {

                    if (shouldEnqueueRequestOutOfOrder) {

                        [self.storedRequestsList insertObject:request.shortIdentifier atIndex:0];
                    }
                    else {

                        [self.storedRequestsList addObject:request.shortIdentifier];
                    }
                    [self.storedRequests setValue:@{PNStoredRequestKeys.request:request,
                                                    PNStoredRequestKeys.isObserved :@(shouldObserveProcessing)}
                                           forKey:request.shortIdentifier];
                }

                if (shouldLaunchRequestsProcessing) {

                    // Launch communication process on sockets by triggering requests queue processing
                    [self scheduleNextRequest];
                }
            }
        }
        else {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.ignoreScheduledRequest, (self.name ? self.name : self),
                        (request ? request : [NSNull null]), @(self.state)];
            }];
        }
    }];
}

- (void)scheduleNextRequest {

    [_connection scheduleNextRequestExecution];
}

- (void)unscheduleNextRequest {

    [_connection unscheduleRequestsExecution];
}

- (void)unscheduleRequest:(PNBaseRequest *)request {

    [self.requestsQueue removeRequest:request];
}

- (void)reconnect {

    BOOL isConnected = [self isConnected];
    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.reconnectingByRequest, (self.name ? self.name : self),
                    @(self.state)];
        }];

        [PNBitwiseHelper clear:&_state];
        if (isConnected) {

            [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelConnected];
        }
        [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelReconnect];
        
        [self prepareConnectionIfRequired];
        [self.connection reconnect];
    }];
}

- (void)clearScheduledRequestsQueue {

    [self.requestsQueue removeAllRequests];
}

- (void)terminate {

    [self cleanUp];
}

- (void)rescheduleStoredRequests:(NSArray *)requestsList {

    [self rescheduleStoredRequests:requestsList resetRetryCount:YES];
}

- (void)rescheduleStoredRequests:(NSArray *)requestsList resetRetryCount:(BOOL)shouldResetRequestsRetryCount {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
}

- (BOOL)shouldHandleResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);


    return YES;
}

- (BOOL)shouldHandleConnectionToHost {

    __block BOOL shouldHandleConnectionToHost = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        shouldHandleConnectionToHost = [PNBitwiseHelper is:self.state strictly:NO containsBits:PNConnectionChannelDisconnected, PNConnectionChannelDisconnecting,
                                        PNConnectionChannelConnecting, BITS_LIST_TERMINATOR];
    }];


    return shouldHandleConnectionToHost;
}

- (BOOL)shouldHandleReconnectionToHost {

    return [self isReconnecting];
}

- (void)startTimeoutTimerForRequest:(PNBaseRequest *)request {

    [self pn_dispatchSynchronouslyBlock:^{

        [self stopTimeoutTimerForRequest:nil];

        // Stop timeout timer only for requests which is scheduled from the name of user
        if ((request.isSendingByUserRequest && [self isWaitingRequestCompletion:request.shortIdentifier]) ||
                request == nil) {

            NSTimeInterval interval = request ? [request timeout] : self.configuration.subscriptionRequestTimeout;
            self.timeoutTimer = [NSTimer timerWithTimeInterval:interval
                                                        target:self
                                                      selector:@selector(handleTimeoutTimer:)
                                                      userInfo:request
                                                       repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
        }
    }];
}

- (void)stopTimeoutTimerForRequest:(PNBaseRequest *)request {

    [self pn_dispatchSynchronouslyBlock:^{

        // Stop timeout timer only for requests which is scheduled from the name of user
        if ((request.isSendingByUserRequest && [self isWaitingRequestCompletion:request.shortIdentifier]) ||
            request == nil) {

            if ([self.timeoutTimer isValid]) {

                [self.timeoutTimer invalidate];
            }
            self.timeoutTimer = nil;
        }
    }];
}


#pragma mark - Connection delegate methods

- (void)connectionConfigurationDidFail:(PNConnection *)connection {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.configurationFailed, (self.name ? self.name : self),
                    @(self.state)];
        }];

        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelDisconnected, PNConnectionChannelError, BITS_LIST_TERMINATOR];

        // Clean up requests, because there is no use from stream
        [self purgeStoredRequestsPool];
        [self purgeObservedRequestsPool];
        [self clearScheduledRequestsQueue];


        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];


        // Notify delegate that stream configuration failed and it can't be used anymore
        [self.delegate connectionChannelConfigurationDidFail:self];
    }];
}

- (void)connectionDidReset:(PNConnection *)connection {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.connectionChannel.handleConnectionReset, (self.name ? self.name : self),
                    @(self.state)];
        }];

        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelConnected];

        if ([self.storedRequestsList count]) {

            // Ask to reschedule required requests
            [self rescheduleStoredRequests:self.storedRequestsList];

            // Launch communication process on sockets by triggering requests queue processing
            [self scheduleNextRequest];
        }
    }];
}

- (void)connection:(PNConnection *)connection didConnectToHost:(NSString *)hostName {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.handleConnectionReady, (self.name ? self.name : self),
                    @(self.state)];
        }];

        // Check whether channel is waiting for connection completion or not
        BOOL isExpected = [self shouldHandleConnectionToHost];
        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelConnected];

        if ([self.storedRequestsList count]) {

            // Ask to reschedule required requests
            [self rescheduleStoredRequests:self.storedRequestsList];
        }

        // Launch communication process on sockets by triggering requests queue processing
        [self scheduleNextRequest];


        if (isExpected) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.connected, (self.name ? self.name : self),
                        @(self.state)];
            }];

            [self.delegate connectionChannel:self didConnectToHost:hostName];
        }
    }];
}

- (void)connectionDidSuspend:(PNConnection *)connection {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.handleSuspension, (self.name ? self.name : self),
                    @(self.state)];
        }];

        // Check whether channel is waiting for suspension or not
        BOOL isExpected = [self isSuspending];
        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelDisconnected, PNConnectionChannelSuspended,
                               BITS_LIST_TERMINATOR];

        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];


        if (isExpected) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.suspended, (self.name ? self.name : self),
                        @(self.state)];
            }];

            [self.delegate connectionChannelDidSuspend:self];
        }
    }];
}

- (void)connectionDidResume:(PNConnection *)connection {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.handleResume, (self.name ? self.name : self),
                    @(self.state)];
        }];

        // Check whether channel is waiting for resume or not
        BOOL isExpected = [self isResuming];
        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelConnected];


        BOOL doesWarmingUpRequired = [self.storedRequestsList count] == 0;
        if ([self.storedRequestsList count]) {

            // Ask to reschedule required requests
            [self rescheduleStoredRequests:self.storedRequestsList];

            // Launch communication process on sockets by triggering requests queue processing
            [self scheduleNextRequest];
        }


        if (isExpected) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.resumed, (self.name ? self.name : self),
                        @(self.state)];
            }];

            [self.delegate connectionChannelDidResume:self requireWarmUp:doesWarmingUpRequired];
        }
    }];
}

- (void)connection:(PNConnection *)connection checkCanConnect:(void(^)(BOOL))checkCompletionBlock; {

    [self.delegate connectionChannel:self checkCanConnect:checkCompletionBlock];
}

- (void)connection:(PNConnection *)connection checkShouldRestoreConnection:(void(^)(BOOL))checkCompletionBlock; {

    [self.delegate connectionChannel:self checkShouldRestoreConnection:checkCompletionBlock];
}

- (void)connection:(PNConnection *)connection willReconnectToHost:(NSString *)hostName {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.willRestoreConnection, (self.name ? self.name : self),
                    @(self.state)];
        }];

        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];


        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelDisconnected, PNConnectionChannelConnecting,
                               PNConnectionChannelReconnect, BITS_LIST_TERMINATOR];
    }];
}

- (void)connection:(PNConnection *)connection didReconnectToHost:(NSString *)hostName {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.handleConnectionRestore, (self.name ? self.name : self),
                    @(self.state)];
        }];

        // Check whether channel is waiting for reconnection completion or not
        BOOL isExpected = [self shouldHandleReconnectionToHost];
        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelConnected];

        BOOL doesWarmingUpRequired = [self.storedRequestsList count] == 0;
        if ([self.storedRequestsList count] > 0) {

            // Ask to reschedule required requests
            [self rescheduleStoredRequests:self.storedRequestsList];

            // Launch communication process on sockets by triggering requests queue processing
            [self scheduleNextRequest];
        }


        if (isExpected && doesWarmingUpRequired) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.connectionRestored, (self.name ? self.name : self),
                        @(self.state)];
            }];

            [self.delegate connectionChannel:self didReconnectToHost:hostName];
        }
    }];
}

- (void)connection:(PNConnection *)connection willReconnectToHostAfterError:(NSString *)hostName {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.willRestoreConnectionAfterError, (self.name ? self.name : self),
                    @(self.state)];
        }];

        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];

        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelDisconnected, PNConnectionChannelConnecting,
                               PNConnectionChannelReconnect, BITS_LIST_TERMINATOR];
    }];
}

- (void)connection:(PNConnection *)connection didReconnectToHostAfterError:(NSString *)hostName {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.handleConnectionRestoreAfterError, (self.name ? self.name : self),
                    @(self.state)];
        }];

        // Check whether channel is waiting for reconnection completion or not
        BOOL isExpected = [self shouldHandleReconnectionToHost];
        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelConnected];


        BOOL doesWarmingUpRequired = [self.storedRequestsList count] == 0;
        if ([self.storedRequestsList count] > 0) {

            // Ask to reschedule required requests
            [self rescheduleStoredRequests:self.storedRequestsList];

            // Launch communication process on sockets by triggering requests queue processing
            [self scheduleNextRequest];
        }


        if (isExpected && doesWarmingUpRequired) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.connectionRestored, (self.name ? self.name : self),
                        @(self.state)];
            }];

            [self.delegate connectionChannel:self didReconnectToHost:hostName];
        }
    }];
}


- (void)connection:(PNConnection *)connection willDisconnectFromHost:(NSString *)host withError:(PNError *)error {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.handleDisconnectionBecauseOfError, (self.name ? self.name : self),
                    @(self.state)];
        }];

        // Check whether channel is in suitable state to handle this event or not
        BOOL isExpected = [self isConnected] && ![PNBitwiseHelper is:self.state
                                                         containsBit:PNConnectionChannelDisconnecting];
        isExpected = isExpected && ![self isSuspending];

        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelConnected, PNConnectionChannelDisconnecting,
                               PNConnectionChannelError, BITS_LIST_TERMINATOR];


        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];

        
        [self.delegate isPubNubServiceAvailable:NO checkCompletionBlock:^(BOOL available) {
            
            if ([self.storedRequestsList count]) {
                
                PNError *errorForRequests = nil;
                if (available) {
                    
                    errorForRequests = [PNError errorWithCode:kPNRequestExecutionFailedClientNotReadyError];
                }
                [self makeScheduledRequestsFail:[NSArray arrayWithArray:self.storedRequestsList]
                                      withError:errorForRequests];
            }
            
            
            if (isExpected) {
                
                [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.connectionChannel.disconnectedBecauseOfError, (self.name ? self.name : self),
                             @(self.state)];
                }];
                
                [self.delegate connectionChannel:self willDisconnectFromOrigin:host withError:error];
            }
        }];
    }];
}

- (void)connection:(PNConnection *)connection didDisconnectFromHost:(NSString *)hostName {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.handleDisconnection, (self.name ? self.name : self),
                    @(self.state)];
        }];

        // Check whether channel is in suitable state to handle this event or not
        BOOL isExpected = [PNBitwiseHelper is:self.state strictly:NO containsBits:PNConnectionChannelDisconnected,
                                              PNConnectionChannelDisconnecting, BITS_LIST_TERMINATOR];
        if (isExpected) {

            [PNBitwiseHelper clear:&_state];
            [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelDisconnected];
        }

        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];

        [self.delegate isPubNubServiceAvailable:NO checkCompletionBlock:^(BOOL available) {
            
            if ([self.storedRequestsList count]) {
                
                PNError *error = nil;
                if (available) {
                    
                    error = [PNError errorWithCode:kPNRequestExecutionFailedClientNotReadyError];
                }
                [self makeScheduledRequestsFail:[NSArray arrayWithArray:self.storedRequestsList] withError:error];
            }
            
            
            if (isExpected) {
                
                [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.connectionChannel.disconnected, (self.name ? self.name : self),
                             @(self.state)];
                }];
                
                [self.delegate connectionChannel:self didDisconnectFromOrigin:hostName];
            }
        }];
    }];
}

- (void)connection:(PNConnection *)connection didRestoreAfterServerCloseConnectionToHost:(NSString *)hostName {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.connectionRestoredAfterClosingByServerRequest, (self.name ? self.name : self),
                    @(self.state)];
        }];

        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelConnected];


        if ([self.storedRequestsList count]) {

            // Ask to reschedule required requests
            [self rescheduleStoredRequests:self.storedRequestsList resetRetryCount:NO];

            // Launch communication process on sockets by triggering requests queue processing
            [self scheduleNextRequest];
        }
    }];
}

- (void)connection:(PNConnection *)connection willDisconnectByServerRequestFromHost:(NSString *)hostName {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.closingConnectionByServerRequest, (self.name ? self.name : self),
                    @(self.state)];
        }];

        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];

        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelConnected, PNConnectionChannelDisconnecting,
                               BITS_LIST_TERMINATOR];
    }];
}

- (void)connection:(PNConnection *)connection didDisconnectByServerRequestFromHost:(NSString *)hostName {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.disconnectedByServerRequest, (self.name ? self.name : self),
                    @(self.state)];
        }];

        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelDisconnected];

        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];
    }];
}

- (void)connection:(PNConnection *)connection connectionDidFailToHost:(NSString *)hostName withError:(PNError *)error {

    [self pn_dispatchAsynchronouslyBlock:^{

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.handleConnectionFailedBecauseOfError, (self.name ? self.name : self),
                    @(self.state)];
        }];

        // Check whether channel is in suitable state to handle this event or not
        BOOL isExpected = [self isConnecting] || [self isReconnecting];
        isExpected = isExpected || [self isResuming];

        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bits:PNConnectionChannelDisconnected, PNConnectionChannelError,
                               BITS_LIST_TERMINATOR];


        // Check whether all streams closed or not (in case if server closed only one from read/write streams)
        if (![connection isDisconnected]) {

            [connection disconnectByInternalRequest];
        }


        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];


        if (isExpected) {

            [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.connectionChannel.connectionFailedBecauseOfError, (self.name ? self.name : self),
                        @(self.state)];
            }];

            [self.delegate connectionChannel:self connectionDidFailToOrigin:hostName withError:error];
        }
    }];
}

- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response {

    // Retrieve reference on request for which this response was received
    PNBaseRequest *request = [self observedRequestWithIdentifier:response.requestIdentifier];
    BOOL shouldObserveExecution = request != nil;

    // In case if there is no request object, this mean that this is non-observer request which is stored in other storage
    if (request == nil) {

        request = [self requestWithIdentifier:response.requestIdentifier];
        shouldObserveExecution = [self isWaitingRequestCompletion:request.shortIdentifier];
    }
    
    // In case if arrived malformed response (completely messed) there is no chance to find out to which request it is related. This is prediction
    // way which will allow to detect corresponding request (will be taken last one in queue).
    // WARNING: This approach a bit risky, because it heavily rely on order of requests in queue (if something will alter it, wrong request may
    // suffer from error handling logic.
    if (request == nil && response.response == nil) {
        
        request = [self nextStoredRequest];
        shouldObserveExecution = [self isWaitingRequestCompletion:request.shortIdentifier];
    }

    // Check whether request successfully received and can be used or not
    BOOL shouldResendRequest = response.error.code == kPNResponseMalformedJSONError || response.statusCode >= 500;
    BOOL isRequestSentByUser = request != nil && request.isSendingByUserRequest;
    BOOL shouldHandleResponse = [self shouldHandleResponse:response];

    [self stopTimeoutTimerForRequest:request];

    // Check whether response is valid or not
    if (shouldResendRequest) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.malformedJSONPResponse, (self.name ? self.name : self),
                    (response ? response : [NSNull null]), @(self.state)];
        }];

        if (request) {

            if ([request canRetry]) {
                
                [request increaseRetryCount];
                [request resetWithRetryCount:NO];
                
                [self destroyRequest:request];
            }
            else {
                
                shouldResendRequest = NO;
                [self requestsQueue:nil didFailRequestSend:request withError:response.error];
            }
        }
    }
    // Looks like response is valid (continue)
    else {

        if (shouldHandleResponse && isRequestSentByUser) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.receivedResponse, (self.name ? self.name : self),
                        (response ? response : [NSNull null]), @(self.state)];
            }];
        }

        [self destroyRequest:request];

        if (shouldHandleResponse) {

            [self processResponse:response forRequest:request];
        }
    }
    

    if (shouldResendRequest) {

        if (request) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.reschedulingRequest, (self.name ? self.name : self),
                        (request ? request : [NSNull null]), @(self.state)];
            }];

            [self scheduleRequest:request shouldObserveProcessing:shouldObserveExecution outOfOrder:YES
                 launchProcessing:NO];
        }
        else {

            [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.requestRescheduleImpossible, (self.name ? self.name : self),
                        (request ? request : [NSNull null]), @(self.state)];
            }];
        }

        // Asking to schedule next request
        [self scheduleNextRequest];
    }
    else {

        // Asking to schedule next request
        [self scheduleNextRequest];
    }
}


#pragma mark - Requests queue delegate methods

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Updating request state
    request.processing = YES;
}

- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request {

    // Updating request state
    request.processing = NO;
    request.processed = YES;

    BOOL isWaitingForRequestCompletion = [self isWaitingRequestCompletion:request.shortIdentifier];

    // Launching timeout timer only for requests which is scheduled from the name of user
    if (request.isSendingByUserRequest && isWaitingForRequestCompletion) {

        [self startTimeoutTimerForRequest:request];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request withError:(PNError *)error {

    // Updating request state
    request.processing = NO;
    request.processed = NO;

    // Check whether connection available or not
    [self.delegate isPubNubServiceAvailable:YES checkCompletionBlock:^(BOOL available) {
        
        if ([self isConnected] && available) {
            
            // Increase request retry count
            [request increaseRetryCount];
        }
        
        [self stopTimeoutTimerForRequest:request];
    }];
}

- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request {

    // Updating request state
    request.processing = NO;
    request.processed = NO;
    [request resetRetryCount];

    [self stopTimeoutTimerForRequest:request];
}

- (void)shouldRequestsQueue:(PNRequestsQueue *)queue removeCompletedRequest:(PNBaseRequest *)request
            checkCompletion:(void(^)(BOOL))checkCompletionBlock {

    checkCompletionBlock(YES);
}


#pragma mark - Memory management

- (void)cleanUp {
    
    BOOL isConnected = [self isConnected];
    [self pn_dispatchSynchronouslyBlock:^{
    
        // Remove all requests sent by this communication channel
        [self clearScheduledRequestsQueue];
        [self stopTimeoutTimerForRequest:nil];
        [self purgeObservedRequestsPool];
        [self purgeStoredRequestsPool];
        
        _connection.dataSource = nil;
        _requestsQueue.delegate = nil;
        _requestsQueue = nil;

        [PNBitwiseHelper clear:&_state];
        [PNBitwiseHelper addTo:&_state bit:PNConnectionChannelDisconnected];
    }];
    
    if (isConnected) {
        
        [_delegate connectionChannel:self didDisconnectFromOrigin:nil];
    }

    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.connectionChannel.connectionReset, (self.name ? self.name : self),
                (_connection ? [NSString stringWithFormat:@"%p", _connection] : [NSNull null]),
                (_connection ? _connection : [NSNull null]), @(self.state)];
    }];
    
    [self pn_dispatchSynchronouslyBlock:^{
        
        _connection.delegate = nil;
        [_connection prepareForTermination];
        _connection = nil;
    }];
    
    [PNDispatchHelper release:[self pn_privateQueue]];
    [self pn_setPrivateDispatchQueue:nil];
}

- (void)dealloc {

    if (_connection) {

        [self cleanUp];
    }

    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.connectionChannel.destroyed, (_name ? _name : @""),
                @(_state)];
    }];
}

#pragma mark -


@end
