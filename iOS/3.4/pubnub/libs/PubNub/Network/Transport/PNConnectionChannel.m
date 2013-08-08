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
#import "PubNub+Protected.h"
#import "PNRequestsQueue.h"
#import "PNResponse.h"


#pragma mark Structures

typedef NS_OPTIONS(NSUInteger, PNConnectionStateFlag)  {

    // Channel trying to establish connection to PubNub services
    PNConnectionConnecting = 1 << 0,

    // Channel reconnecting with same settings which was used during initialization
    PNConnectionReconnecting = 1 << 1,

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    // Channel is resuming it's operation state
    PNConnectionResuming = 1 << 2,
#endif

    // Channel is ready for work (connections established and requests queue is ready)
    PNConnectionConnected = 1 << 3,

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    // Channel is transferring to suspended state
    PNConnectionSuspending = 1 << 4,

    // Channel is in suspended state
    PNConnectionSuspended = 1 << 5,
#endif

    // Channel is disconnecting on user request (for example: leave request for all channels)
    PNConnectionDisconnecting = 1 << 6,

    // Channel is ready, but was disconnected and waiting command for connection (or was unable to connect during
    // initialization). All requests queue is alive (if they wasn't flushed by user)
    PNConnectionDisconnected = 1 << 7
};

typedef NS_OPTIONS(NSUInteger, PNConnectionErrorStateFlag)  {

    // Flag which allow to set whether client is experiencing some error or not
    PNConnectionError = 1 << 8
};

typedef NS_OPTIONS(NSUInteger, PNConnectionCleanStateFlag)  {

    // Flag which can be used to clean connection states
    PNConnectionCleanConnection = (PNConnectionConnecting | PNConnectionConnected),

    // Flag which can be used to clean disconnection states
    PNConnectionCleanDisconnection = (PNConnectionDisconnecting | PNConnectionDisconnected),

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    // Flag which can be used to clean suspension/resuming states
    PNConnectionCleanSuspension = (PNConnectionResuming | PNConnectionSuspending | PNConnectionSuspended),
#endif
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


#pragma mark Private interface methods

@interface PNConnectionChannel () <PNConnectionDelegate>


#pragma mark - Properties

// Stores reference on connection which is used as transport layer to send messages to the PubNub service
@property (nonatomic, strong) PNConnection *connection;

// Stores reference on array of scheduled requests
@property (nonatomic, strong) PNRequestsQueue *requestsQueue;

// Stores reference on all requests on which we are waiting for response
@property (nonatomic, strong) NSMutableDictionary *observedRequests;

// Stores reference on all requests which was required to be stored because of some reasons (for example re-schedule
// request in case of error)
@property (nonatomic, strong) NSMutableDictionary *storedRequests;

// Stores reference on all requests which has been sent but there is still no response on them from server
// (in case if in response will arrive error, first message from this stack will be taken and sent)
@property (nonatomic, strong) NSMutableDictionary *requestsWaitingForResponse;

// Stores list of identifiers from requests which has been sent and waiting for response
// (request objects is stored inside 'requestsWaitingForResponse' and can be accessed with keys from this array)
@property (nonatomic, strong) NSMutableArray *waitingForResponseRequestsList;

@property (nonatomic, strong) NSTimer *timeoutTimer;

@property (nonatomic, strong) NSString *name;

// Current connection channel state
@property (nonatomic, assign) NSUInteger state;


#pragma mark - Instance methods

/**
 * Check whether response should be processed on this communication channel or not
 */
- (BOOL)shouldHandleResponse:(PNResponse *)response;

/**
 * Launch/stop request timeout timer which will be fired if no response will arrive from service along specified
 * timeout in seconds
 */
- (void)startTimeoutTimerForRequest:(PNBaseRequest *)request;
- (void)stopTimeoutTimerForRequest:(PNBaseRequest *)request;


#pragma mark - Requests queue management methods

/**
 * Resend last request which is waiting for response from server
 * (used in situations when connection went down before response arrived from server)
 */
- (void)rescheduleWaitingForResponseRequests;


#pragma mark - Handler methods

/**
 * Called by timeout timer
 * (template method)
 */
- (void)handleTimeoutTimer:(NSTimer *)timer;

/**
 * Called when new request is scheduled on queue and specify whether request should be stored for some time or not
 * (template method)
 */
- (BOOL)shouldStoreRequest:(PNBaseRequest *)request;


#pragma mark - Misc methods

/**
 * Allow to manipulate with requests in specific storage by their identifiers
 */
- (id)requestFromStorage:(NSMutableDictionary *)storage withIdentifier:(NSString *)identifier;
- (void)removeRequest:(PNBaseRequest *)request fromStorage:(NSMutableDictionary *)storage;

/**
 * Print our current connection state
 */
- (NSString *)stateDescription;


@end


#pragma mark Public interface methods

@implementation PNConnectionChannel


#pragma mark - Class methods

+ (id)connectionChannelWithType:(PNConnectionChannelType)connectionChannelType
                    andDelegate:(id<PNConnectionChannelDelegate>)delegate {
    
    return [[[self class] alloc] initWithType:connectionChannelType andDelegate:delegate];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType andDelegate:(id<PNConnectionChannelDelegate>)delegate {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        self.delegate = delegate;
        PNBitClear(&_state);
        self.observedRequests = [NSMutableDictionary dictionary];
        self.storedRequests = [NSMutableDictionary dictionary];
        self.requestsWaitingForResponse = [NSMutableDictionary dictionary];
        self.waitingForResponseRequestsList = [NSMutableArray array];

        
        // Retrieve connection identifier based on connection channel type
        self.name = PNConnectionIdentifiers.messagingConnection;
        if (connectionChannelType == PNConnectionChannelService) {
            
            self.name = PNConnectionIdentifiers.serviceConnection;
        }
        
        
        // Initialize connection to the PubNub services
        self.connection = [PNConnection connectionWithIdentifier:self.name];
        self.connection.delegate = self;
        self.requestsQueue = [PNRequestsQueue new];
        self.requestsQueue.delegate = self;
        self.connection.dataSource = self.requestsQueue;
        [self connect];
    }
    
    
    return self;
}

- (void)connect {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] TRYING TO CONNECT (STATE: %d)",
          self.name, self.state);

    // Check whether connection channel is disconnected and not trying to connect at this moment
    if (![self isConnected] && !PNBitIsOn(self.state, PNConnectionConnecting)) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] CONNECTING... (STATE: %d)",
              self.name, self.state);

        PNBitClear(&_state);
        PNBitOn(&_state, PNConnectionConnecting);
        [self.connection connect];
    }
    // Check whether channel already connected
    else if ([self isConnected]) {

        // Simulate connection completion
        [self connection:self.connection didConnectToHost:[PubNub sharedInstance].configuration.origin];
    }
}

- (BOOL)isConnected {
    
    return PNBitIsOn(self.state, PNConnectionConnected);
}

- (void)disconnect {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] TRYING TO DISCONNECT (STATE: %d)",
          self.name, self.state);

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    if ([self isConnected] ||
        PNBitsIsOn(self.state, NO, PNConnectionConnecting, PNConnectionReconnecting, PNConnectionResuming, 0)) {
#else
    if ([self isConnected] || PNBitsIsOn(self.state, NO, PNConnectionConnecting, PNConnectionReconnecting, 0)) {
#endif
        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] DISCONNECTING... (STATE: %d)",
              self.name, self.state);

        PNBitClear(&_state);
        PNBitOn(&_state, PNConnectionDisconnecting);

        [self.connection disconnect];
    }
    else {

        // Simulate connection close
        [self connection:self.connection didDisconnectFromHost:[PubNub sharedInstance].configuration.origin];
    }
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (BOOL)suspend {

    BOOL canSuspend = PNBitStrictIsOn(self.state, PNConnectionConnected) && !PNBitIsOn(self.state, PNConnectionCleanSuspension);

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] TRYING TO SUSPEND (STATE: %d)",
          self.name, self.state);

    if (canSuspend) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUSPENDING... (STATE: %d)",
              self.name, self.state);

        PNBitClear(&_state);
        PNBitOn(&_state, PNConnectionSuspending);
        [self.delegate connectionChannelWillSuspend:self];


        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];

        [self.connection suspend];
    }
    else if (PNBitsIsOn(self.state, NO, PNConnectionDisconnecting, PNConnectionDisconnecting, PNConnectionCleanSuspension, 0)) {

        canSuspend = YES;
    }


    return canSuspend;
}

- (BOOL)resume {

    BOOL canResume = PNBitIsOn(self.state, PNConnectionSuspended);

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] TRYING TO RESUME (STATE: %d)",
          self.name, self.state);

    // Ensure that connection channel is in suspended mode
    if (canResume) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RESUMING... (STATE: %d)",
              self.name, self.state);

        PNBitClear(&_state);
        PNBitOn(&_state, PNConnectionResuming);
        [self.delegate connectionChannelWillResume:self];

        [self.connection resume];
        [self scheduleNextRequest];
    }
    else if (PNBitsIsOn(self.state, NO, PNConnectionConnecting, PNConnectionConnected, PNConnectionReconnecting, 0)) {

        canResume = YES;
    }


    return canResume;
}
#endif

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
}

- (BOOL)isWaitingRequestCompletion:(NSString *)requestIdentifier {
    
    return [self observedRequestWithIdentifier:requestIdentifier] != nil ||
           [self isWaitingStoredRequestCompletion:requestIdentifier] ||
           [self isWaitingResponseWaitingRequestCompletion:requestIdentifier];
}

- (void)purgeObservedRequestsPool {
    
    [self.observedRequests removeAllObjects];
}

- (id)requestFromStorage:(NSMutableDictionary *)storage withIdentifier:(NSString *)identifier {

    PNBaseRequest *request = nil;
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
    if (!request) {

        if (identifier) {

            request = [self responseWaitingRequestWithIdentifier:identifier];
        }
        else {

            request = [self nextRequestWaitingForResponse];
        }
    }


    return request;
}

- (PNBaseRequest *)observedRequestWithIdentifier:(NSString *)identifier {

    return [self requestFromStorage:self.observedRequests withIdentifier:identifier];
}

- (void)removeObservationFromRequest:(PNBaseRequest *)request {

    [self removeRequest:request fromStorage:self.observedRequests];
}

- (void)purgeStoredRequestsPool {

    [self.requestsWaitingForResponse removeAllObjects];
    [self.waitingForResponseRequestsList removeAllObjects];
    [self.storedRequests removeAllObjects];
}

- (PNBaseRequest *)storedRequestWithIdentifier:(NSString *)identifier {

    NSDictionary *storedRequestInformation = [self requestFromStorage:self.storedRequests withIdentifier:identifier];
    return [storedRequestInformation valueForKeyPath:PNStoredRequestKeys.request];
}

- (BOOL)isWaitingStoredRequestCompletion:(NSString *)identifier {

    NSDictionary *storedRequestInformation = [self requestFromStorage:self.storedRequests withIdentifier:identifier];
    return [[storedRequestInformation valueForKeyPath:PNStoredRequestKeys.isObserved] boolValue];
}

- (void)removeStoredRequest:(PNBaseRequest *)request {

    if (request) {

        [self removeRequest:request fromStorage:self.storedRequests];
    }
}

- (PNBaseRequest *)responseWaitingRequestWithIdentifier:(NSString *)identifier {

    NSDictionary *waitingRequestInformation = [self requestFromStorage:self.requestsWaitingForResponse withIdentifier:identifier];
    return [waitingRequestInformation valueForKeyPath:PNStoredRequestKeys.request];
}

- (BOOL)isWaitingResponseWaitingRequestCompletion:(NSString *)identifier {

    NSDictionary *waitingRequestInformation = [self requestFromStorage:self.requestsWaitingForResponse withIdentifier:identifier];
    return [[waitingRequestInformation valueForKeyPath:PNStoredRequestKeys.isObserved] boolValue];
}

- (PNBaseRequest *)nextRequestWaitingForResponse {

    PNBaseRequest *request = nil;
    if ([self.waitingForResponseRequestsList count] > 0) {

        NSString *nextRequestIdentifier = [self.waitingForResponseRequestsList objectAtIndex:0];
        request = [self responseWaitingRequestWithIdentifier:nextRequestIdentifier];
    }


    return request;
}

- (void)removeResponseWaitingRequest:(PNBaseRequest *)request {

    if (request) {

        [self.waitingForResponseRequestsList removeObject:request.shortIdentifier];
        [self removeRequest:request fromStorage:self.requestsWaitingForResponse];
    }
}

- (void)destroyRequest:(PNBaseRequest *)request {

    [self unscheduleRequest:request];
    [self removeStoredRequest:request];
    [self removeResponseWaitingRequest:request];
    [self removeObservationFromRequest:request];
}


#pragma mark - Handler methods

- (void)handleTimeoutTimer:(NSTimer *)timer {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
}

- (BOOL)shouldStoreRequest:(PNBaseRequest *)request {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);
    
    
    return YES;
}

- (NSString *)stateDescription {

    NSMutableString *connectionState = [NSMutableString stringWithFormat:@"\n[CHANNEL::%@ STATE DESCRIPTION", self.name];
    if (PNBitIsOn(self.state, PNConnectionConnecting)) {

        [connectionState appendFormat:@"\n- CONNECTING..."];
    }
    if (PNBitIsOn(self.state, PNConnectionConnected)) {

        [connectionState appendFormat:@"\n- CONNECTED"];
    }
    if (PNBitIsOn(self.state, PNConnectionReconnecting)) {

        [connectionState appendFormat:@"\n- RECONNECTING..."];
    }
    if (PNBitIsOn(self.state, PNConnectionDisconnecting)) {

        [connectionState appendFormat:@"\n- DISCONNECTING..."];
    }
    if (PNBitIsOn(self.state, PNConnectionDisconnected)) {

        [connectionState appendFormat:@"\n- DISCONNECTED"];
    }
    if (PNBitIsOn(self.state, PNConnectionError)) {

        [connectionState appendFormat:@"\n- ERROR"];
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    if (PNBitIsOn(self.state, PNConnectionSuspending)) {

        [connectionState appendFormat:@"\n- SUSPENDING..."];
    }
    if (PNBitIsOn(self.state, PNConnectionSuspended)) {

        [connectionState appendFormat:@"\n- SUSPENDED"];
    }
    if (PNBitIsOn(self.state, PNConnectionResuming)) {

        [connectionState appendFormat:@"\n- RESUMING..."];
    }
#endif


    return connectionState;
}


#pragma mark - Requests queue management methods

- (void)scheduleRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing {

    [self scheduleRequest:request shouldObserveProcessing:shouldObserveProcessing outOfOrder:NO];
}

- (void)scheduleRequest:(PNBaseRequest *)request
shouldObserveProcessing:(BOOL)shouldObserveProcessing
             outOfOrder:(BOOL)shouldEnqueueRequestOutOfOrder {

    if([self.requestsQueue enqueueRequest:request outOfOrder:shouldEnqueueRequestOutOfOrder]) {

        if (shouldObserveProcessing) {

            [self.observedRequests setValue:request forKey:request.shortIdentifier];
        }

        if ([self shouldStoreRequest:request]) {

            [self.storedRequests setValue:@{PNStoredRequestKeys.request:request,
                                            PNStoredRequestKeys.isObserved :@(shouldObserveProcessing)}
                                   forKey:request.shortIdentifier];
        }

        // Launch communication process on sockets by triggering requests queue processing
        [self scheduleNextRequest];
    }
}

- (void)rescheduleWaitingForResponseRequests {

    PNBaseRequest *request = [self nextRequestWaitingForResponse];
    while (request != nil) {

        request.processing = NO;
        request.processed = NO;
        BOOL shouldObserveRequest = [self isWaitingResponseWaitingRequestCompletion:request.shortIdentifier];
        [self destroyRequest:request];
        [self scheduleRequest:request shouldObserveProcessing:shouldObserveRequest outOfOrder:YES];

        request = [self nextRequestWaitingForResponse];
    }
}

- (void)scheduleNextRequest {

    [self.connection scheduleNextRequestExecution];
}

- (void)unscheduleNextRequest {

    [self.connection unscheduleRequestsExecution];
}

- (void)unscheduleRequest:(PNBaseRequest *)request {

    [self.requestsQueue removeRequest:request];
}

- (void)reconnect {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RECONNECTING BY REQUEST... (STATE: %d)",
          self.name, self.state);

    BOOL isConnected = PNBitIsOn(self.state, PNConnectionConnected);
    PNBitClear(&_state);
    if (isConnected) {

        PNBitOn(&_state, PNConnectionConnected);
    }
    PNBitOn(&_state, PNConnectionReconnecting);

    [self.connection reconnect];
}

- (void)clearScheduledRequestsQueue {

    [self.requestsQueue removeAllRequests];
}

- (void)terminate {

    [self cleanUp];
}

- (BOOL)shouldHandleResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);


    return YES;
}

- (void)startTimeoutTimerForRequest:(PNBaseRequest *)request {

    // Stop timeout timer only for requests which is scheduled from the name of user
    if ((request.isSendingByUserRequest && [self isWaitingRequestCompletion:request.shortIdentifier]) ||
        request == nil) {

        self.timeoutTimer = [NSTimer timerWithTimeInterval:[request timeout]
                                                    target:self
                                                  selector:@selector(handleTimeoutTimer:)
                                                  userInfo:request
                                                   repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimeoutTimerForRequest:(PNBaseRequest *)request {

    // Stop timeout timer only for requests which is scheduled from the name of user
    if ((request.isSendingByUserRequest && [self isWaitingRequestCompletion:request.shortIdentifier]) ||
        request == nil) {

        if ([self.timeoutTimer isValid]) {

            [self.timeoutTimer invalidate];
        }
        self.timeoutTimer = nil;
    }
}


#pragma mark - Connection delegate methods

- (void)connectionConfigurationDidFail:(PNConnection *)connection {

    PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] CONFIGUIRATION FAILED (STATE: %d)",
          self.name, self.state);

    PNBitClear(&_state);
    PNBitsOn(&_state, PNConnectionDisconnected, PNConnectionError, 0);
    [self unscheduleNextRequest];

    [self.delegate connectionChannelConfigurationDidFail:self];
}

- (void)connection:(PNConnection *)connection didConnectToHost:(NSString *)hostName {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] CONNECTED (STATE: %d)",
          self.name, self.state);

    BOOL wasConnected = PNBitIsOn(self.state, PNConnectionConnected);
    PNBitClear(&_state);
    PNBitOn(&_state, PNConnectionConnected);
    
    if (!wasConnected) {

        [self.delegate connectionChannel:self didConnectToHost:hostName];
    }


    // Reissue all requests which was unable to get response from server
    [self rescheduleWaitingForResponseRequests];
    
    // Launch communication process on sockets by triggering requests queue processing
    [self scheduleNextRequest];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)connectionDidSuspend:(PNConnection *)connection {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] SUSPENDED (STATE: %d)",
          self.name, self.state);

    PNBitClear(&_state);
    PNBitOn(&_state, PNConnectionSuspended);

    [self unscheduleNextRequest];

    [self.delegate connectionChannelDidSuspend:self];
}

- (void)connectionDidResume:(PNConnection *)connection {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RESUMED (STATE: %d)",
          self.name, self.state);

    PNBitClear(&_state);
    PNBitOn(&_state, PNConnectionConnected);

    [self.delegate connectionChannelDidResume:self];

    // Reissue all requests which was unable to get response from server
    [self rescheduleWaitingForResponseRequests];

    // Launch communication process on sockets by triggering requests queue processing
    [self scheduleNextRequest];
}
#endif

- (BOOL)connectionShouldRestoreConnection:(PNConnection *)connection {

    [[PubNub sharedInstance].reachability refreshReachabilityState];
    BOOL connectionShouldRestoreConnection = PNBitsIsOn(self.state, NO, PNConnectionConnected, PNConnectionConnecting, 0);

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    connectionShouldRestoreConnection = connectionShouldRestoreConnection || PNBitIsOn(self.state, PNConnectionResuming);
#endif
    connectionShouldRestoreConnection = connectionShouldRestoreConnection && [[PubNub sharedInstance].reachability isServiceAvailable];

    return connectionShouldRestoreConnection;
}

- (void)connection:(PNConnection *)connection didReconnectToHost:(NSString *)hostName {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RESTORED CONNECTION (STATE: %d)",
          self.name, self.state);

    PNBitClear(&_state);
    PNBitOn(&_state, PNConnectionConnected);
    [self.delegate connectionChannel:self didReconnectToHost:hostName];

    // Reissue all requests which was unable to get response from server
    [self rescheduleWaitingForResponseRequests];

    // Launch communication process on sockets by triggering requests queue processing
    [self scheduleNextRequest];
}

- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response {

    // Retrieve reference on request for which this response was received
    PNBaseRequest *request = [self observedRequestWithIdentifier:response.requestIdentifier];

    // Check whether request successfully received and can be used or not
    BOOL shouldResendRequest = response.error.code == kPNResponseMalformedJSONError || response.statusCode >= 500;
    BOOL shouldObserveExecution = request != nil;
    BOOL isRequestSentByUser = request == nil || request.isSendingByUserRequest;
    BOOL shouldHandleResponse = [self shouldHandleResponse:response];

    [self stopTimeoutTimerForRequest:request];

    // Check whether response is valid or not
    if (shouldResendRequest) {

        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] RECEIVED MALFORMED RESPONSE: %@ (STATE: %d)",
              self.name, response, self.state);

        if (request == nil) {

            request = [self requestWithIdentifier:response.requestIdentifier];
        }

        if (request) {

            [request reset];

            if (!shouldObserveExecution) {

                shouldObserveExecution = [self isWaitingRequestCompletion:request.shortIdentifier];
            }
            [self destroyRequest:request];
        }

    }
    // Looks like response is valid (continue)
    else {

        if (shouldHandleResponse && isRequestSentByUser) {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RECIEVED RESPONSE: %@ (STATE: %d)",
                  self.name, response, self.state);
        }

        if (request == nil) {

            request = [self requestWithIdentifier:response.requestIdentifier];
        }

        [self destroyRequest:request];

        if (shouldHandleResponse) {

            [self processResponse:response forRequest:request];
        }
    }


    if (shouldResendRequest) {

        if (request) {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RESCHEDULING REQUEST: %@ (STATE: %d)",
                  self.name, request, self.state);

            [self scheduleRequest:request shouldObserveProcessing:shouldObserveExecution];
        }
        else {

            PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] CAN'T RESCHEDULE REQUEST FOR RESPONSE: %@ (STATE: %d)",
                  self.name, response, self.state);

            // Asking to schedule next request
            [self scheduleNextRequest];
        }
    }
    else {

        // Asking to schedule next request
        [self scheduleNextRequest];
    }
}

- (void)connection:(PNConnection *)connection willDisconnectFromHost:(NSString *)host withError:(PNError *)error {
    
    if ([self isConnected] && !PNBitsIsOn(self.state, NO, PNConnectionDisconnecting, PNConnectionDisconnected, 0)) {

        PNBitClear(&_state);
        PNBitsOn(&_state, PNConnectionDisconnecting, PNConnectionError, 0);

        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];

        [self.delegate connectionChannel:self willDisconnectFromOrigin:host withError:error];
    }
}

- (void)connection:(PNConnection *)connection connectionDidFailToHost:(NSString *)hostName withError:(PNError *)error {
    
    if (!PNBitIsOn(self.state, PNConnectionDisconnected)) {

        PNBitClear(&_state);
        PNBitsOn(&_state, PNConnectionDisconnected, PNConnectionError, 0);
        
        
        // Check whether all streams closed or not (in case if server closed only one from read/write streams)
        if (![connection isDisconnected]) {
            
            [connection disconnectByUserRequest:NO];
        }

        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];

        [self.delegate connectionChannel:self connectionDidFailToOrigin:hostName withError:error];
    }
}

- (void)connection:(PNConnection *)connection didDisconnectFromHost:(NSString *)hostName {
    
    if(!PNBitIsOn(self.state, PNConnectionDisconnected)) {

        PNBitClear(&_state);
        PNBitOn(&_state, PNConnectionDisconnected);

        [self stopTimeoutTimerForRequest:nil];
        [self unscheduleNextRequest];

        [self.delegate connectionChannel:self didDisconnectFromOrigin:hostName];
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


    // Launching timeout timer only for requests which is scheduled
    // from the name of user
    if (request.isSendingByUserRequest && isWaitingForRequestCompletion) {

        [self startTimeoutTimerForRequest:request];
    }

    if ([self shouldStoreRequest:request]) {

        [self.waitingForResponseRequestsList addObject:request.shortIdentifier];
        [self.requestsWaitingForResponse setValue:@{PNStoredRequestKeys.request:request,
                                                    PNStoredRequestKeys.isObserved :@(isWaitingForRequestCompletion)}
                                           forKey:request.shortIdentifier];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request withError:(PNError *)error {

    // Updating request state
    request.processing = NO;
    request.processed = NO;

    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        // Increase request retry count
        [request increaseRetryCount];
    }

    [self removeResponseWaitingRequest:request];
    [self stopTimeoutTimerForRequest:request];
}

- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request {

    // Updating request state
    request.processing = NO;
    request.processed = NO;
    [request resetRetryCount];

    [self removeResponseWaitingRequest:request];
    [self stopTimeoutTimerForRequest:request];
}

- (BOOL)shouldRequestsQueue:(PNRequestsQueue *)queue removeCompletedRequest:(PNBaseRequest *)request {

    return YES;
}


#pragma mark - Memory management

- (void)cleanUp {
    
    // Remove all requests sent by this communication channel
    [self clearScheduledRequestsQueue];
    [self stopTimeoutTimerForRequest:nil];

    _connection.dataSource = nil;
    _requestsQueue.delegate = nil;
    _requestsQueue = nil;

    BOOL isConnected = PNBitIsOn(_state, PNConnectionConnected);
    PNBitClear(&_state);
    PNBitOn(&_state, PNConnectionDisconnected);
    if (isConnected) {
        
        [_delegate connectionChannel:self didDisconnectFromOrigin:nil];
    }
    
    _connection.delegate = nil;
    [PNConnection destroyConnection:_connection];
    _connection = nil;
}

- (void)dealloc {
    
    [self cleanUp];

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] DESTROYED (STATE: %d)",
          _name, _state);
}

#pragma mark -


@end
