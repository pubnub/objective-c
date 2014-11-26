//
//  PNConnectionChannel.h
//  pubnub
//
//  Connection channel is intermediate class between transport network layer and other library classes.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import <Foundation/Foundation.h>
#import "PNConnectionChannelDelegate.h"
#import "PNRequestsQueueDelegate.h"
#import "PNConnectionDelegate.h"


#pragma mark Class forward

@class PNConfiguration;


#pragma mark - Structures

#pragma mark - Connection channel types

// This enum represents list of available connection
// channel types
typedef enum _PNConnectionChannelType {
    
    // Channel used to communicate with PubNub messaging
    // service:
    //   - subscription
    //   - presence
    //   - leave
    PNConnectionChannelMessaging,
    
    // Channel used for sending other requests like:
    //   - history
    //   - time token
    //   - latency meter
    //   - list of participants
    PNConnectionChannelService
} PNConnectionChannelType;


#pragma mark - Class forward

@class PNBaseRequest;


@interface PNConnectionChannel : NSObject <PNRequestsQueueDelegate, PNConnectionDelegate>


#pragma mark - Properties

// Connection channel delegate
@property (nonatomic, pn_desired_weak) id<PNConnectionChannelDelegate> delegate;


#pragma mark Class methods

/**
 Returns reference on fully configured channel which is ready to be connected and usage.

 @param configuration
 Reference on \b PNConfiguration instance which should be used by connection channel and accompany classes.

 @param connectionChannelType
 Basing on connection type different identifiers will be used.

 @param delegate
 Reference on delegate which will accept all general callbacks from underlay connection channel class.

 @return Reference on fully configured and ready to use instance.
 */
+ (id)connectionChannelWithConfiguration:(PNConfiguration *)configuration type:(PNConnectionChannelType)connectionChannelType
                             andDelegate:(id<PNConnectionChannelDelegate>)delegate;


#pragma mark - Instance methods

/**
 Initialize connection channel which on it's own will initiate socket connection with streams

 @param configuration
 Reference on \b PNConfiguration instance which should be used by connection channel and accompany classes.

 @param connectionChannelType
 Basing on connection type different identifiers will be used.

 @param delegate
 Reference on delegate which will accept all general callbacks from underlay connection channel class.

 @return Reference on fully configured and ready to use instance.
 */
- (id)initWithConfiguration:(PNConfiguration *)configuration type:(PNConnectionChannelType)connectionChannelType
                andDelegate:(id<PNConnectionChannelDelegate>)delegate;

- (void)connect;

- (void)checkConnecting:(void (^)(BOOL connecting))checkCompletionBlock;

/**
 * Check whether connection channel connected and ready for work
 */
- (void)checkConnected:(void (^)(BOOL connected))checkCompletionBlock;

/**
 Closing connection to the server. Requests queue won't be flushed.
 */
- (void)disconnect;

/**
 * Check whether connection channel disconnected
 */
- (void)checkDisconnected:(void (^)(BOOL disconnected))checkCompletionBlock;

/**
 @brief Check whether connection channel re-establish connection on request or because of internal
 logic.

 @param checkCompletionBlock Block which is called at the end of check process and pass \c YES in
                             case if channel in the reconnection process.
 */
- (void)checkReconnecting:(void (^)(BOOL reconnecting))checkCompletionBlock;

/**
 * Stop any channel activity by request
 */
- (void)suspend;
- (void)checkSuspended:(void (^)(BOOL suspended))checkCompletionBlock;

/**
 * Resume channel activity and proceed execution of all suspended tasks
 */
- (void)resume;
- (void)checkResuming:(void (^)(BOOL resuming))checkCompletionBlock;


#pragma mark - Requests queue management methods

/**
 * Managing requests queue
 * shouldObserveProcessing - means whether communication channel is interested in report that request passed
 *                           in this method was completed or not (PubNub service completed request processing)
 */
- (void)scheduleRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing;

/**
 * Same as scheduleRequest:shouldObserveProcessing: but allow to specify whether request should be put
 * out of order (executed next) or not
 */
- (void)scheduleRequest:(PNBaseRequest *)request shouldObserveProcessing:(BOOL)shouldObserveProcessing
             outOfOrder:(BOOL)shouldEnqueueRequestOutOfOrder launchProcessing:(BOOL)shouldLaunchRequestsProcessing;

/**
 * Triggering requests queue execution (maybe it was locked with previous request and waited)
 */
- (void)scheduleNextRequest;

/**
 * Ask connection to stop pulling requests from request queue and wait for further commands
 */
- (void)unscheduleNextRequest;

/**
 * Remove particular request which was scheduled with this communication channel to queue
 */
- (void)unscheduleRequest:(PNBaseRequest *)request;

/**
 * Remove all requests which was scheduled with this communication channel
 */
- (void)clearScheduledRequestsQueue;

#pragma mark -


@end
