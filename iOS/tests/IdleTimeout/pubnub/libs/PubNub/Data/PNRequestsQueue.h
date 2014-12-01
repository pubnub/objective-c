//
//  PNRequestsQueue.h
//  pubnub
//
//  This class was created for iOS PubNub client support to handle request sending via single socket connection.
//  This is singleton class which will help to organize requests into single FIFO pipe.
//
//
//  Created by Sergey Mamontov on 12/13/12.
//
//

#import <Foundation/Foundation.h>
#import "PNRequestsQueueDelegate.h"
#import "PNConnectionDelegate.h"
#import "PNMacro.h"


#pragma mark Class forward

@class PNBaseRequest;


#pragma mark - Public interface declaration

@interface PNRequestsQueue : NSObject <PNConnectionDataSource>


#pragma mark - Properties

// Stores reference on connection delegate which also will be packet provider for connection
@property (nonatomic, pn_desired_weak) id<PNRequestsQueueDelegate> delegate;

// Stores list of scheduled queries
@property (nonatomic, readonly) NSArray *requestsQueue;


#pragma mark - Instance methods

/**
 * Will add request into the queue if it is still not there. Returns whether request has been placed into queue or not
 */
- (void)enqueueRequest:(PNBaseRequest *)request outOfOrder:(BOOL)shouldEnqueueRequestOutOfOrder withBlock:(void (^)(BOOL scheduled))enqueueCompletionBlock;
- (void)removeRequest:(PNBaseRequest *)request;

/**
 * Removes all requests which is not placed for processing into connection buffer
 */
- (void)removeAllRequests;

#pragma mark -


@end
