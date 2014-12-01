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
 Retrieve reference on private queue.
 
 @return Private queue or \c NULL if it hasn't been set yet.
 */
- (dispatch_queue_t)pn_privateQueue;

/**
 @brief Configure private queue which will be owned by object on which it configured.
 
 @discussion At configuration, object is able to retain created queue, but destruction should be 
 assisted from outside (because category created on base class which won't allow to reload -dealloc
 method).
 
 @param identifier Identifier of the owner which will be append as prefix to unique queue 
                   identifier.
 @param priority   Priority of the queue, which should be set as target for this private queue.
 
 @since 3.7.3
 */
- (void)pn_setupPrivateSerialQueueWithIdentifier:(NSString *)identifier
                                     andPriority:(dispatch_queue_priority_t)priority;

/**
 Terminate and release private dispatch queue.
 */
- (void)pn_destroyPrivateDispatchQueue;

/**
 Dispatch specified block asynchronously on private queue.

 @param block
 Code block which should be dispatched.
 */
- (void)pn_dispatchBlock:(dispatch_block_t)block;

/**
 Dispatch specified block on queue asynchronously.

 @warning Assertion will fire in case if private queue not specified earlier.

 @param queue
 Reference on queue which should be used for block dispatching.

 @param block
 Code block which should be dispatched.
 */
- (void)pn_dispatchOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block;

/**
 Create assertion which will fire in case if code is running on non-private queue.
 */
- (void)pn_scheduleOnPrivateQueueAssert;

/**
 @brief Allow to disable assert for the time when code should be called outside of queue.
 
 @discussion This method mostly used in cases where there is not much time for GCD async operation 
 completion, but queue dedicated methods should be called.
 This method doesn't have backward functionality and permanently disable requirement.
 
 @since 3.7.3
 */
- (void)pn_ignorePrivateQueueRequirement;

#pragma mark -


@end
