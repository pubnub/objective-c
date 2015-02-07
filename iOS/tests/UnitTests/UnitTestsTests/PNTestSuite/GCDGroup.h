//
//  GCDWrapper.h
//  pubnub
//
//  Created by Vadim Osovets on 11/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDGroup : NSObject

/** Any error that can occur while doing a lot of tasks. */
@property (nonatomic) NSError *error;

+ (instancetype)group;

- (void)enter;
- (void)leave;

- (void)enterTimes:(NSUInteger)times;
- (long)wait:(dispatch_time_t) timeout;

- (BOOL)isEntered;
- (int)timesEntered;

- (void)setNotifyBlock:(dispatch_block_t)block
               atQueue:(dispatch_queue_t)queue;

@end
