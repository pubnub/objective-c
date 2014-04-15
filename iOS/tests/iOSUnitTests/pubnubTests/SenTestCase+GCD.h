//
//  SenTestCase+GCD.h
//  pubnub
//
//  Created by Vadim Osovets on 4/15/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface SenTestCase (GCD)

/**
 * Hold current thread and keep it for
 * timeout value,
 * check state of group each time after timeInterval
 */
- (void)waitGroup:(dispatch_group_t)dispatchGroup
       withTimout:(NSInteger)timeout
 withTimeInterval:(NSInteger)timeInterval;

/**
 * Hold current thread and keep it for
 * timeout value,
 * check state of group each time after timeInterval
 * timeInterval value is 1 sec
 */
- (void)waitGroup:(dispatch_group_t)dispatchGroup
       withTimout:(NSInteger)timeout;

/**
 * Hold current thread and keep it for
 * timeout value,
 * check state of group each time after timeInterval
 * timeInterval value is 1 sec
 * timeout 30 second
 */
- (void)waitGroup:(dispatch_group_t)dispatchGroup;

@end
