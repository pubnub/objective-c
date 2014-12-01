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


#define DEBUG_QUEUE 0
#if DEBUG_QUEUE
    #warning Queue assertion is ON. Turn OFF before deployment.
#endif


#pragma mark Category private interface declaration

@interface NSObject (PNAdditionsPrivate)


#pragma mark - Instance methods

#pragma mark - Misc methods

/**
 @brief Look into instance storage for information about whether object discard requirement on code
 execution only on private queue or not.
 
 @return \c YES will allow to execute submitted block w/o check and treated as private by default.
 
 @since 3.7.3
 */
- (BOOL)pn_ignoringPrivateQueueRequirement;

/**
 @brief Allow to check whether currently instance code is running on it's private queue or not.
 
 @return \c YES in case if dispatch_get_specific for pointer stored inside of associated object will
 return non-NULL information.
 
 @since 3.7.3
 */
- (BOOL)pn_runningOnPrivateQueue;

/**
 @brief Try to retrieve reference on wrapper which should be stored as associated object of instance
 if queue has been configured before.
 
 @return \c nil in case if private queue never been configured for this instance.
 
 @since 3.7.3
 */
- (PNDispatchObjectWrapper *)pn_privateQueueWrapper;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation NSObject (PNAdditions)


#pragma mark - Instance methods

- (dispatch_queue_t)pn_privateQueue {
    
    dispatch_queue_t queue = [self pn_privateQueueWrapper].queue;
    
    return (queue ? queue : NULL);
}

- (PNDispatchObjectWrapper *)pn_privateQueueWrapper {
    
    return (PNDispatchObjectWrapper *)objc_getAssociatedObject(self, "privateQueue");
}

- (void)pn_setupPrivateSerialQueueWithIdentifier:(NSString *)identifier
                                     andPriority:(dispatch_queue_priority_t)priority {
    
    dispatch_queue_t privateQueue = [PNDispatchHelper serialQueueWithIdentifier:identifier];
    dispatch_queue_t targetQueue = dispatch_get_global_queue(priority, 0);
    dispatch_set_target_queue(privateQueue, targetQueue);
    const char *cQueueIdentifier = dispatch_queue_get_label(privateQueue);
    
    // Construct pointer which will be used for code block execution and make sure to run code on provided queue.
    void *context = (__bridge void *)self;
    const void *privateQueueSpecificPointer = &cQueueIdentifier;
    dispatch_queue_set_specific(privateQueue, privateQueueSpecificPointer, context, NULL);
    
    // Store queue inside of wrapper as associated object of this instance
    PNDispatchObjectWrapper *wrapper = [PNDispatchObjectWrapper wrapperForObject:privateQueue
                                        specificKey:[NSValue valueWithPointer:privateQueueSpecificPointer]];
    if (wrapper) {
        
        objc_setAssociatedObject(self, "privateQueue", wrapper, OBJC_ASSOCIATION_RETAIN);
    }
    
}

- (void)pn_destroyPrivateDispatchQueue {
    
    [PNDispatchHelper release:[self pn_privateQueue]];
    objc_setAssociatedObject(self, "privateQueue", nil, OBJC_ASSOCIATION_RETAIN);
}

- (void)pn_dispatchBlock:(dispatch_block_t)block {

    dispatch_queue_t privateQueue = [self pn_privateQueue];
    NSAssert(privateQueue != NULL, @"The given block can't be scheduled because private queue not set yet.");

    [self pn_dispatchOnQueue:privateQueue block:block];
}

- (void)pn_dispatchOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block {

    if (block) {

        if (queue) {

            // Check whether code is running on instance private queue or not
            if ([self pn_runningOnPrivateQueue]) {

                block();
            }
            else {

                dispatch_async(queue, block);
            }
        }
        else {

            block();
        }
    }
}

- (void)pn_scheduleOnPrivateQueueAssert {
    
#if DEBUG_QUEUE
    NSAssert([self pn_runningOnPrivateQueue], @"Code should be scheduled on private queue");
#endif
}

- (void)pn_ignorePrivateQueueRequirement {
    
    objc_setAssociatedObject(self, "ignorePrivateQueueRequirement", @YES, OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - Misc methods

- (BOOL)pn_ignoringPrivateQueueRequirement {
    
    return [(NSNumber *)objc_getAssociatedObject(self, "ignorePrivateQueueRequirement") boolValue];
}

- (BOOL)pn_runningOnPrivateQueue {
    
    BOOL runningOnPrivateQueue = [self pn_ignoringPrivateQueueRequirement];
    if (!runningOnPrivateQueue) {
        
        PNDispatchObjectWrapper *wrapper = [self pn_privateQueueWrapper];
        if (wrapper) {
            
            runningOnPrivateQueue = [(__bridge id)dispatch_get_specific(wrapper.specificKeyPointer.pointerValue) isEqual:self];
        }
    }
    
    return runningOnPrivateQueue;
}

#pragma mark -


@end
