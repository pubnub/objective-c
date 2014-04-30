//
//  SenTestCase+GCD.h
//  pubnub
//
//  Created by Vadim Osovets on 4/15/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDWrapper : NSObject

/**
 * Hold current thread and keep it for
 * timeout value,
 * check state of group each time after default timeInterval
 */
+ (void)waitGroup:(dispatch_group_t)dispatchGroup
       withTimout:(NSInteger)timeout;

/**
 * Hold current thread and keep it for
 * timeout value,
 * check state of group each time after timeInterval
 */
+ (void)waitGroup:(dispatch_group_t)dispatchGroup
       withTimout:(NSInteger)timeout
     withInterval:(NSInteger)timeinterval;

/**
 * Hold current thread and keep it for
 * timeout value,
 * check state of group each time after timeInterval
 * timeout 30 second
 */
+ (void)waitGroup:(dispatch_group_t)dispatchGroup;

/**
 * Hold main thread and for number of seconds
 */
+ (void)sleepForSeconds:(NSUInteger)sec;

@end
