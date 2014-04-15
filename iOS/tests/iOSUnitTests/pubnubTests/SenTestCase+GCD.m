//
//  SenTestCase+GCD.m
//  pubnub
//
//  Created by Vadim Osovets on 4/15/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "SenTestCase+GCD.h"

@implementation SenTestCase (GCD)

- (void)waitGroup:(dispatch_group_t)dispatchGroup
       withTimout:(NSInteger)timeout
 withTimeInterval:(NSInteger)timeInterval {
    
    NSInteger i = timeout;
    while(i-- > 0) {
        
        if (!dispatch_group_wait(dispatchGroup, DISPATCH_TIME_NOW)) {
            break;
        }
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    }
    
    STAssertFalse(i < 0, @"Timout during connection");
}

- (void)waitGroup:(dispatch_group_t)dispatchGroup
       withTimout:(NSInteger)timeout {
    [self waitGroup:dispatchGroup
         withTimout:timeout
   withTimeInterval:1];
}

- (void)waitGroup:(dispatch_group_t)dispatchGroup {
    [self waitGroup:dispatchGroup
         withTimout:30
   withTimeInterval:1];
}

@end
