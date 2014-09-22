//
//  NSObject+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/6/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Category methods declaration

@interface NSObject (PNAdditions)


#pragma mark - Instance methods

/**
 Construct new dispatch queue which should be owned by caller.

 @param ownerIdentifier
 Identifier of the owner which will be append as prefix to unique queue identifier.

 @param targetQueue
 If provided, then it will be used as target for new queue.

 @warning Caller is responsible for queue retain and release.

 @return New non-retained dispatch queue.
 */
- (dispatch_queue_t)pn_serialQueueWithOwnerIdentifier:(NSString *)ownerIdentifier andTargetQueue:(dispatch_queue_t)targetQueue;

/**
 Retrieve reference on private queue.

 @return Private queue or \c NULL if it hasn't been set yet.
 */
- (dispatch_queue_t)pn_privateQueue;

/**
 Set provided queue as object's private queue which will be used for synchronous and asynchronous block execution.

 @param queue
 Reference on queue which should be set as object's private queue.
 */
- (void)pn_setPrivateDispatchQueue:(dispatch_queue_t)queue;

/**
 Dispatch specified block synchronously on private queue.

 @warning Assertion will fire in case if private queue not specified earlier.

 @param block
 Code block which should be dispatched.
 */
- (void)pn_dispatchSynchronouslyBlock:(dispatch_block_t)block;

/**
 Dispatch specified block on queue synchronously.

 @param queue
 Reference on queue which should be used for block dispatching.

 @param block
 Code block which should be dispatched.
 */
- (void)pn_dispatchSynchronouslyOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block;

/**
 Dispatch specified block asynchronously on private queue.

 @param block
 Code block which should be dispatched.
 */
- (void)pn_dispatchAsynchronouslyBlock:(dispatch_block_t)block;

/**
 Dispatch specified block on queue asynchronously.

 @warning Assertion will fire in case if private queue not specified earlier.

 @param queue
 Reference on queue which should be used for block dispatching.

 @param block
 Code block which should be dispatched.
 */
- (void)pn_dispatchAsynchronouslyOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block;

/**
 Create assertion which will fire in case if code is running on non-private queue.
 */
- (void)pn_scheduleOnPrivateQueueAssert;

#pragma mark -


@end
