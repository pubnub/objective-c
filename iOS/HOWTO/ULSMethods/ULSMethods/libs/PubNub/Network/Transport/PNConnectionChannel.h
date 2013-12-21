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


#pragma mark Structures


#pragma mark Connection channel types

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
@property (nonatomic, assign) id<PNConnectionChannelDelegate> delegate;


#pragma mark Class methods

/**
 * Returns reference on fully configured channel which is ready to be connected and usage
 */
+ (id)connectionChannelWithType:(PNConnectionChannelType)connectionChannelType
                    andDelegate:(id<PNConnectionChannelDelegate>)delegate;


#pragma mark - Instance methods

/**
 * Initialize connection channel which on it's own will initiate socket connection with streams
 */
- (id)initWithType:(PNConnectionChannelType)connectionChannelType andDelegate:(id<PNConnectionChannelDelegate>)delegate;

- (void)connect;

/**
 * Check whether connection channel connected and ready for work
 */
- (BOOL)isConnected;

/**
 * Closing connection to the server. Requests queue won't be flushed.
 */
- (void)disconnect;

/**
 * Check whether connection channel disconnected
 */
- (BOOL)isDisconnected;

/**
 * Stop any channel activity by request
 */
- (void)suspend;
- (BOOL)isSuspending;
- (BOOL)isSuspended;

/**
 * Resume channel activity and proceed execution of all suspended tasks
 */
- (void)resume;
- (BOOL)isResuming;


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
- (void)scheduleRequest:(PNBaseRequest *)request
shouldObserveProcessing:(BOOL)shouldObserveProcessing
             outOfOrder:(BOOL)shouldEnqueueRequestOutOfOrder
       launchProcessing:(BOOL)shouldLaunchRequestsProcessing;

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
