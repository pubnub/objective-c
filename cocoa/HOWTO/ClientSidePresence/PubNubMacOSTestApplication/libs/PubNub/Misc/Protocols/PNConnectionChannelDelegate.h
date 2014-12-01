//
//  PNConnectionChannelDelegate.h
//  pubnub
//
//  Describes interface which is used to
//  organize communication between connection
//  channel management code and PubNub client
//  instance.
//
//
//  Created by Sergey Mamontov on 12/16/12.
//
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNConnectionChannel, PNError;


#pragma mark - Connection channel observer methods

@protocol PNConnectionChannelDelegate <NSObject>


@required

/**
 * Sent to the PubNub client when connection channel was unable to enable connection
 */
- (void)connectionChannelConfigurationDidFail:(PNConnectionChannel *)channel;

/**
 * Sent to the PubNub client when connection channel successfully
 * configured and connected to the specified PubNub services origin
 */
- (void)connectionChannel:(PNConnectionChannel *)channel didConnectToHost:(NSString *)host;

/**
 * Sent to the PubNub client when connection channel successfully
 * restored it's operation after connection error
 */
- (void)connectionChannel:(PNConnectionChannel *)channel didReconnectToHost:(NSString *)host;

/**
 * Sent to the PubNub client when connection channel was unable
 * to establish connection with remote PubNub services because
 * of error
 */
- (void)connectionChannel:(PNConnectionChannel *)channel connectionDidFailToOrigin:(NSString *)host
                withError:(PNError *)error;

/**
 * Sent to the PubNub client when connection channel disconnected
 * from PubNub services
 */
- (void)connectionChannel:(PNConnectionChannel *)channel didDisconnectFromOrigin:(NSString *)host;

/**
 * Sent to the PubNub client when connection channel disconnected
 * from PubNub services because of error
 */
- (void)connectionChannel:(PNConnectionChannel *)channel willDisconnectFromOrigin:(NSString *)host
                withError:(PNError *)error;

/**
 @brief Send to PubNub client when connection channel is about to reschedule requests which stored
 in queue and didn't have enough time to complete processing.
 
 @param channel Reference on communication channel which sent this event.
 
 @since 3.7.3
 */
- (void)connectionChannelWillReschedulePendingRequests:(PNConnectionChannel *)channel;

/**
 * Sent to the PubNub client when connection channel is about to suspend it's operation
 */
- (void)connectionChannelWillSuspend:(PNConnectionChannel *)channel;

/**
 * Sent to the PubNub client when connection channel suspended
 */
- (void)connectionChannelDidSuspend:(PNConnectionChannel *)channel;

/**
 * Sent to the PubNub client when connection channel is about to resume it's operation
 */
- (void)connectionChannelWillResume:(PNConnectionChannel *)channel;

/**
 * Sent to the PubNub client when connection channel resumed it's operation
 * and ready to process requests
 */
- (void)connectionChannelDidResume:(PNConnectionChannel *)channel requireWarmUp:(BOOL)isWarmingUpRequired;

/**
 * Sent to the delegate each timer when connection channel want to ensure on whether it can connect or it is
 * impossible at this moment because of some reasons (no internet connection)
 * This method is called periodically by intervals defined in connection class.
 */
- (void)connectionChannel:(PNConnectionChannel *)channel checkCanConnect:(void(^)(BOOL))checkCompletionBlock;

/**
 * Sent to the delegate each timer when connection channel want to ensure on whether it should resume it's operation
 * or not (after it was disconnected).
 * This method is called periodically by intervals defined in connection class.
 */
- (void)connectionChannel:(PNConnectionChannel *)channel checkShouldRestoreConnection:(void(^)(BOOL))checkCompletionBlock;

/**
 Retrieve client identifier provided or generated for user by \b PubNub client.
 
 @return Unique client identifier
 */
- (NSString *)clientIdentifier;

/**
 Sent to the delegate when underlying connection channel want to find out about network and service reachability.
 
 @param shouldUpdateInformation
 Whether \b PubNub client should trigger syncrhronous state update or not
 
 @return \c YES in case if \b PubNub and network reachable.
 */
- (void)isPubNubServiceAvailable:(BOOL)shouldUpdateInformation checkCompletionBlock:(void(^)(BOOL))checkCompletionBlock;

#pragma mark -

@end
