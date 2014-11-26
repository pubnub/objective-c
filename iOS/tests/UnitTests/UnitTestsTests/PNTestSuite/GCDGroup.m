//
//  GCDWrapper.h
//  pubnub
//
//  Created by Vadim Osovets on 11/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "GCDGroup.h"

#import <libkern/OSAtomic.h>

@implementation GCDGroup {
    dispatch_group_t    _gcdGroup;
    volatile int32_t    _enterCount;
}

+ (instancetype)group {
    return [self new];
}

- (instancetype)init {
    if (self = [super init]) {
        _gcdGroup = dispatch_group_create();
    }
    return self;
}

#pragma mark - Public

- (void)enter {
    OSAtomicIncrement32(&(_enterCount));
    dispatch_group_enter(_gcdGroup);
}

- (void)enterTimes:(int)times {
    _enterCount += times;
    
    for (int i = 0; i < times; i++) {
        dispatch_group_enter(_gcdGroup);
    }
}

- (void)leave {
    OSAtomicDecrement32(&(_enterCount));
    dispatch_group_leave(_gcdGroup);
}

- (BOOL)isEntered {
    return _enterCount != 0;
}

- (int)timesEntered {
    return _enterCount;
}

- (long)wait:(dispatch_time_t) timeout {
    return dispatch_group_wait(_gcdGroup, timeout);
}

- (void)setNotifyBlock:(dispatch_block_t)block
               atQueue:(dispatch_queue_t)queue {
    dispatch_group_notify(_gcdGroup, queue, block);
}

- (void)dealloc {
    if ([self isEntered]) {
        for (int i = 0; i < _enterCount; i++) {
            dispatch_group_leave(_gcdGroup);
        }
    }
    
    _gcdGroup = NULL;
}

@end
