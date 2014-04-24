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
       withTimout:(NSInteger)timeout {
    
    NSDate *dateLimit = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
     while(YES) {
        if (!dispatch_group_wait(dispatchGroup, DISPATCH_TIME_NOW)) {
            break;
        }
         
         if ([[NSDate date] compare:dateLimit] == NSOrderedDescending) {
             STFail(@"Timout during last operation. Time limit: %d", timeout);
             break;
         }
        
         [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
}

- (void)waitGroup:(dispatch_group_t)dispatchGroup
       withTimout:(NSInteger)timeout
     withInterval:(NSInteger)timeInterval {
    NSDate *dateLimit = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    while(YES) {
        if (!dispatch_group_wait(dispatchGroup, DISPATCH_TIME_NOW)) {
            break;
        }
        
        if ([[NSDate date] compare:dateLimit] == NSOrderedDescending) {
            STFail(@"Timout during last operation. Time limit: %d", timeout);
            break;
        }
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    }
}

- (void)waitGroup:(dispatch_group_t)dispatchGroup {
    [self waitGroup:dispatchGroup
         withTimout:30];
}

@end
