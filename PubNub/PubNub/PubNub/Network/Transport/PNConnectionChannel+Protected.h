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


#pragma mark - Properties

@property (nonatomic, strong) NSString *name;


#pragma mark - Instance methods

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request;

- (void)handleRequestProcessingDidFail:(PNBaseRequest *)request withError:(PNError *)error;

/**
 * Simulate requests failure (used in case if connection terminated by user or because of network error
 */
- (void)makeScheduledRequestsFail:(NSArray *)requestsList withError:(PNError *)processingError;

/**
 * Returns whether communication channel is waiting for request processing completion from backend or not
 */
- (BOOL)isWaitingRequestCompletion:(NSString *)requestIdentifier;
- (BOOL)shouldScheduleRequest:(PNBaseRequest *)request;

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
- (NSArray *)requestsWithClass:(Class)requestClass;

/**
 Close only connection w/o any further notification to the user.
 */
- (void)terminateConnection;

/**
 Closing connection to the server. Requests queue won't be flushed.
 If 'shouldNotifyOnDisconnection' is set to YES, than connection channel will receive disconnection event and pass
 it forward
 */
- (void)disconnectWithEvent:(BOOL)shouldNotifyOnDisconnection;

/**
 * Reconnect main communication channel on which this communication channel is working
 */
- (void)reconnectWithBlock:(dispatch_block_t)processReportBlock;


#pragma mark - Misc methods

/**
* Check whether connection channel connected and ready for work
*/
- (BOOL)isConnected;

- (BOOL)isConnecting;
- (BOOL)isReconnecting;

- (BOOL)isSuspending;
- (BOOL)isSuspended;
- (BOOL)isResuming;

/**
* Check whether connection channel disconnected
*/
- (BOOL)isDisconnected;

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
