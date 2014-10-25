//
//  NSObject+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/6/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSObject+PNAdditions.h"
#import <objc/runtime.h>
#import "PNHelper.h"


#pragma mark Category private interface declaration

@interface NSObject (PNAdditionsPrivate)


#pragma mark - Instance methods


/**
 Dispatch specified block on queue synchronous or asynchronous depending on settings.

 @param queue
 Reference on queue which should be used for block dispatching.

 @param dispatchSynchronously
 Whether code should be dispatched with \a dispatch_sync or \a dispatch_async.

 @param block
 Code block which should be dispatched.
 */
- (void)pn_dispatchOnQueue:(dispatch_queue_t)queue synchronous:(BOOL)dispatchSynchronously block:(dispatch_block_t)block;


#pragma mark - Misc methods

/**
 Check associated objects storage for reference on specific key pointer value.

 @note If \c NULL returned as pointer it mean that it never stored for provided queue. Queue is new or doesn't belong
 to receiver object.

 @param queue
 Reference on queue for which pointer should be found.

 @return Specific key pointer value or \c NULL if there is no key stored for specified queue.
 */
- (const void *)pn_specificKeyPointerForQueue:(dispatch_queue_t)queue;

/**
 Store in associated objects linkage between queue and specific key pointer.

 @param pointer
 Pointer to specific key.

 @param queue
 Reference on GCD queue which should be linked with pointer.
 */
- (void)pn_storeSpecificKeyPointer:(const void *)pointer forQueue:(dispatch_queue_t)queue;

/**
 Return reference on existing or lazily create new map of queue name to pointer of "specific" key.

 @return Mutable dictionary which is able to store new mapping entries.
 */
- (NSMutableDictionary *)pn_queuePointers;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation NSObject (PNAdditions)


#pragma mark - Instance methods

- (dispatch_queue_t)pn_serialQueueWithOwnerIdentifier:(NSString *)ownerIdentifier andTargetQueue:(dispatch_queue_t)targetQueue {

    NSString *queueIdentifier = [NSString stringWithFormat:@"com.pubnub.%@.%@", ownerIdentifier, [PNHelper UUID]];
    const char *cQueueIdentifier = [queueIdentifier UTF8String];

    dispatch_queue_t privateQueue = dispatch_queue_create(cQueueIdentifier, DISPATCH_QUEUE_SERIAL);
    if (targetQueue) {

        dispatch_set_target_queue(privateQueue, targetQueue);
    }

    void *context = (__bridge void *)self;

    // Construct pointer which will be used for code block execution and make sure to run code on provided queue.
    const void *privateQueueSpecificPointer = &cQueueIdentifier;
    [self pn_storeSpecificKeyPointer:privateQueueSpecificPointer forQueue:privateQueue];
    dispatch_queue_set_specific(privateQueue, privateQueueSpecificPointer, context, NULL);


    return privateQueue;
}

- (dispatch_queue_t)pn_privateQueue {
    
    dispatch_queue_t queue = ((PNDispatchObjectWrapper *)objc_getAssociatedObject(self, "privateQueue")).queue;
    
    return (queue ? queue : NULL);
}

- (void)pn_setPrivateDispatchQueue:(dispatch_queue_t)queue {
    
    if (queue) {

        objc_setAssociatedObject(self, "privateQueue", [PNDispatchObjectWrapper wrapperForObject:queue], OBJC_ASSOCIATION_RETAIN);
    }
}

- (void)pn_dispatchSynchronouslyBlock:(dispatch_block_t)block {

    dispatch_queue_t privateQueue = [self pn_privateQueue];
    NSAssert(privateQueue != NULL, @"The given block can't be scheduled because private queue not set yet.");

    [self pn_dispatchSynchronouslyOnQueue:privateQueue block:block];
}

- (void)pn_dispatchSynchronouslyOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block {

    [self pn_dispatchOnQueue:queue synchronous:YES block:block];
}

- (void)pn_dispatchAsynchronouslyBlock:(dispatch_block_t)block {

    dispatch_queue_t privateQueue = [self pn_privateQueue];
    NSAssert(privateQueue != NULL, @"The given block can't be scheduled because private queue not set yet.");

    [self pn_dispatchAsynchronouslyOnQueue:privateQueue block:block];
}

- (void)pn_dispatchAsynchronouslyOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block {

    [self pn_dispatchOnQueue:queue synchronous:NO block:block];
}

- (void)pn_dispatchOnQueue:(dispatch_queue_t)queue synchronous:(BOOL)dispatchSynchronously block:(dispatch_block_t)block {

    if (block) {

        // Checking whether we already running on provided queue or not.
        if ([self pn_specificKeyPointerForQueue:queue]) {

            // Looks like code execution flow already on specified queue, so we will just execute block.
            // In this case dispatchSynchronously is ignored and executed in current context to prevent possible deadlock.
            block();
        }
        else {

            if (dispatchSynchronously) {

                dispatch_sync(queue, ^{

                    block();
                });
            }
            else {

                dispatch_async(queue, block);
            }
        }
    }
}

- (void)pn_scheduleOnPrivateQueueAssert {

    dispatch_queue_t privateQueue = [self pn_privateQueue];
    if (privateQueue != NULL) {

        NSAssert(([self pn_specificKeyPointerForQueue:[self pn_privateQueue]] != NULL),
                 @"Code shoud be shceduled on private queue");
    }
}


#pragma mark - Misc methods

- (const void *)pn_specificKeyPointerForQueue:(dispatch_queue_t)queue {

    const char *pointer = NULL;
    if (queue) {

        // Retrieve reference on stored specific ket pointer value using queue label as key.
        const char *queueLabel = dispatch_queue_get_label(queue);
        NSValue *pointerValue = [[self pn_queuePointers] valueForKey:[NSString stringWithUTF8String:queueLabel]];


        pointer = (pointerValue ? [pointerValue pointerValue] : NULL);
    }


    return pointer;
}

- (void)pn_storeSpecificKeyPointer:(const void *)pointer forQueue:(dispatch_queue_t)queue {

    if (pointer != NULL && queue != NULL) {

        // Store reference on specific ket pointer value using queue label as key.
        const char *queueLabel = dispatch_queue_get_label(queue);
        [[self pn_queuePointers] setValue:[NSValue valueWithPointer:pointer]
                                   forKey:[NSString stringWithUTF8String:queueLabel]];
    }
}

- (NSMutableDictionary *)pn_queuePointers {

    NSMutableDictionary *queuePointers = objc_getAssociatedObject(self, "queuePointersMap");
    if (!queuePointers) {

        queuePointers = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, "queuePointersMap", queuePointers, OBJC_ASSOCIATION_RETAIN);
    }


    return queuePointers;
}

#pragma mark -


@end
