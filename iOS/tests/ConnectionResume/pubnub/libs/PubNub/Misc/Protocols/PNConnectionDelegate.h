//
//  PNConnectionDelegate.h
//  pubnub
//
//  Describes interface which is used to
//  organize communication between connection
//  (transport layer) and connection channel
//  management code
//
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#pragma mark Class forward

@class PNConnection, PNWriteBuffer, PNResponse, PNError;
@class PNBaseRequest;


#pragma mark - Connection observer delegate methods

@protocol PNConnectionDelegate <NSObject>

@required

/**
 * Sent to the delegate when connection channel was unable to complete its configuration
 */
- (void)connectionConfigurationDidFail:(PNConnection *)connection;

/**
 * Sent to the delegate when connection reset itself because of some critical circumstances
 */
- (void)connectionDidReset:(PNConnection *)connection;

/**
 * Sent to the delegate when both streams (read/write) connected to the opened socket
 */
- (void)connection:(PNConnection *)connection didConnectToHost:(NSString *)hostName;

/**
 * Send to the delegate when both streams (read/write) suspended
 */
- (void)connectionDidSuspend:(PNConnection *)connection;

/**
 * Send to the delegate when both streams (read/write) resumed after suspension
 */
- (void)connectionDidResume:(PNConnection *)connection;

/**
 * Sent to the delegate each timer when connection want to ensure on whether it can connect or it is impossible at this
 * moment because of some reasons (no internet connection)
 * This method is called periodically by intervals defined in connection class.
 */
- (void)connection:(PNConnection *)connection checkCanConnect:(void(^)(BOOL))checkCompletionBlock;

/**
 * Sent to the delegate each timer when connection want to ensure on whether it should resume it's operation
 * or not (after it was disconnected).
 * This method is called periodically by intervals defined in connection class.
 */
- (void)connection:(PNConnection *)connection checkShouldRestoreConnection:(void(^)(BOOL))checkCompletionBlock;

/**
 * Sent to the delegate when connection will reconnect streams (read/write)
 */
- (void)connection:(PNConnection *)connection willReconnectToHost:(NSString *)hostName;

/**
 * Sent to the delegate when both streams (read/write) was reconnected because of some reason
 */
- (void)connection:(PNConnection *)connection didReconnectToHost:(NSString *)hostName;

/**
 * Sent to the delegate when connection will reconnect streams after some error (read/write)
 */
- (void)connection:(PNConnection *)connection willReconnectToHostAfterError:(NSString *)hostName;

/**
 * Sent to the delegate when both streams (read/write) was reconnected because of some reason
 */
- (void)connection:(PNConnection *)connection didReconnectToHostAfterError:(NSString *)hostName;

/**
 * Sent to the delegate when one of the streams received error and connection is forced to close because of it
 */
- (void)connection:(PNConnection *)connection willDisconnectFromHost:(NSString *)host withError:(PNError *)error;

/**
 * Sent to the delegate when both streams (read/write) disconnected from remote host
 */
- (void)connection:(PNConnection *)connection didDisconnectFromHost:(NSString *)hostName;

/**
 * Sent to the delegate each time when connection restored after it has been closed by server request
 */
- (void)connection:(PNConnection *)connection didRestoreAfterServerCloseConnectionToHost:(NSString *)hostName;

/**
 * Sent to the delegate each time when connection is about terminate because of server request
 */
- (void)connection:(PNConnection *)connection willDisconnectByServerRequestFromHost:(NSString *)hostName;

/**
 * Sent to the delegate each time when connection terminated because of server request
 */
- (void)connection:(PNConnection *)connection didDisconnectByServerRequestFromHost:(NSString *)hostName;

/**
 * Sent to the delegate when one of the stream (read/write) was unable to open connection with socket
 */
- (void)connection:(PNConnection *)connection connectionDidFailToHost:(NSString *)hostName withError:(PNError *)error;

/**
 * Sent to the delegate each time when new response arrives via socket from remote server
 */
- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response;

#pragma mark -


@end


#pragma mark - Connection data source delegate methods

@protocol PNConnectionDataSource <NSObject>

@required

/**
 * Check whether data source can provide connection with data which can be sent over the network
 * to PubNub services (requests will be executed automatically)
 */
- (BOOL)hasDataForConnection:(PNConnection *)connection;

- (NSString *)nextRequestIdentifierForConnection:(PNConnection *)connection;
- (PNBaseRequest *)nextRequestForConnection:(PNConnection *)connection;

/**
 * Delegate should provide write buffer which will be used to send serialized data over the network
 */
- (PNWriteBuffer *)connection:(PNConnection *)connection requestDataForIdentifier:(NSString *)requestIdentifier;

/**
 * Sent when connection started request processing (sending payload via sockets)
 */
- (void)connection:(PNConnection *)connection processingRequestWithIdentifier:(NSString *)requestIdentifier;

/**
 * Notify data source that request with specified identifier has been sent, so it should be removed from queue
 */
- (void)connection:(PNConnection *)connection didSendRequestWithIdentifier:(NSString *)requestIdentifier;

/**
 * Notify data source that request with specified identifier has been canceled (unscheduled) from execution
 */
- (void)connection:(PNConnection *)connection didCancelRequestWithIdentifier:(NSString *)requestIdentifier;

/**
 * Notify data source that request with specified identifier wasn't sent because of some error
 */
- (void)                   connection:(PNConnection *)connection
didFailToProcessRequestWithIdentifier:(NSString *)requestIdentifier
                            withError:(PNError *)error;

@end
