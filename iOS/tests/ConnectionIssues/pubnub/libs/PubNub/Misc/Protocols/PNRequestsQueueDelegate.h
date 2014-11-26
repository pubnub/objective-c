//
//  PNRequestsQueueDelegate.h
//  pubnub
//
//  Describes interface which is used to organize
//  communication between requests queue and
//  communication channels.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#pragma mark Class forward

@class PNRequestsQueue, PNBaseRequest, PNError;


@protocol PNRequestsQueueDelegate <NSObject>

@required

/**
 * Will notify delegate every time when request which delegate scheduled went for processing
 */
- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request
            withBlock:(dispatch_block_t)notifyCompletionBlock;

/**
 * Will notify delegate that particular request processing  has been canceled (in most cases this will be caused by
 * socket write stream error)
 */
- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request
            withBlock:(dispatch_block_t)notifyCompletionBlock;

/**
 * Will notify delegate that particular request has been processed and sent to the server
 */
- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request
            withBlock:(dispatch_block_t)notifyCompletionBlock;

/**
 * Will notify delegate that particular request processing failed
 */
- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request
                error:(PNError *)error withBlock:(dispatch_block_t)notifyCompletionBlock;

/**
 * Ask delegate whether he allow to remove sent request from queue or not (there are some special cases when whole
 * requests queue should be locked till request processing by server will arrive, but not more than configured
 * lock time)
 */
- (void)shouldRequestsQueue:(PNRequestsQueue *)queue removeCompletedRequest:(PNBaseRequest *)request
            checkCompletion:(void(^)(BOOL))checkCompletionBlock;

@end
