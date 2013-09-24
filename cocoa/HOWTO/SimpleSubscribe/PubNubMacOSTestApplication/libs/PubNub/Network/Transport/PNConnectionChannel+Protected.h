//
//  PNConnectionChannel+Protected.h
//  pubnub
//
//  This header file used by library internal components which require to access to some methods and properties
//  which shouldn't be visible to other application components
//
//  Created by Sergey Mamontov.
//
//

#import "PNConnectionChannel.h"


@class PNBaseRequest;
@class PNRequestsQueue;


@interface PNConnectionChannel (Protected)


#pragma mark - Instance methods

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request;

/**
 * Returns whether communication channel is waiting for request processing completion from backend or not
 */
- (BOOL)isWaitingRequestCompletion:(NSString *)requestIdentifier;

/**
 * Clean up requests stack
 */
- (void)purgeObservedRequestsPool;

/**
 * Retrieve reference on request instance which is stored in one of "observed", "stored", "waiting for response"
 * storage
 */
- (PNBaseRequest *)requestWithIdentifier:(NSString *)identifier;

/**
 * Retrieve reference on request which was observed by communication channel by it's identifier
 */
- (PNBaseRequest *)observedRequestWithIdentifier:(NSString *)identifier;
- (void)removeObservationFromRequest:(PNBaseRequest *)request;

/**
 * Clean up stored requests stack
 */
- (void)purgeStoredRequestsPool;

/**
 * Retrieve reference on request which was stored by communication channel by it's identifier
 */
- (PNBaseRequest *)storedRequestWithIdentifier:(NSString *)identifier;
- (PNBaseRequest *)nextStoredRequest;
- (PNBaseRequest *)nextStoredRequestAfter:(PNBaseRequest *)request;
- (PNBaseRequest *)lastStoredRequest;
- (BOOL)isWaitingStoredRequestCompletion:(NSString *)identifier;
- (void)removeStoredRequest:(PNBaseRequest *)request;

/**
 * Completely destroys request by removing it from queue and requests observation list
 */
- (void)destroyRequest:(PNBaseRequest *)request;
- (void)destroyByRequestClass:(Class)requestClass;

/**
 * Allow to check whether requests with specified class already placed into storage
 */
- (BOOL)hasRequestsWithClass:(Class)requestClass;

/**
 * Closing connection to the server. Requests queue won't be flushed.
 * If 'shouldNotifyOnDisconnection' is set to YES, than connection channel will receive disconnection event and pass
 * it forward
 */
- (void)disconnectWithEvent:(BOOL)shouldNotifyOnDisconnection;

/**
 * Reconnect main communication channel on which this communication channel is working
 */
- (void)reconnect;


#pragma mark - Misc methods

- (BOOL)isConnecting;
- (BOOL)isReconnecting;
- (BOOL)isDisconnecting;

/**
 * Check whether connection channel should handle connection notification or not
 * (when client connected to specified host)
 */
- (BOOL)shouldHandleConnectionToHost;

/**
 * Check whether connection channel should handle re-connection notification or not
 * (when client connected to specified host)
 */
- (BOOL)shouldHandleReconnectionToHost;

/**
 * Clear communication channel request pool
 */
- (void)clearScheduledRequestsQueue;
- (void)terminate;
- (void)cleanUp;

#pragma mark -


@end