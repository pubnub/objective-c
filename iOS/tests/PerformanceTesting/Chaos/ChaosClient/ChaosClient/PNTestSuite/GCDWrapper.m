//
//  XCTestCase+GCD.m
//  pubnub
//
//  Created by Vadim Osovets on 4/15/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "GCDWrapper.h"
#import "GCDGroup.h"

@implementation GCDWrapper

+ (void)waitGroup:(dispatch_group_t)dispatchGroup
       withTimout:(NSInteger)timeout {
    
    NSDate *dateLimit = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
     while(YES) {
        if (!dispatch_group_wait(dispatchGroup, DISPATCH_TIME_NOW)) {
            break;
        }
         
         if ([[NSDate date] compare:dateLimit] == NSOrderedDescending) {
             NSAssert(YES, @"Timout during last operation. Time limit: %d", (int)timeout);
             break;
         }
        
         [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
}

+ (void)waitGroup:(dispatch_group_t)dispatchGroup
       withTimout:(NSInteger)timeout
     withInterval:(NSInteger)timeInterval {
    NSDate *dateLimit = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    while(YES) {
        if (!dispatch_group_wait(dispatchGroup, DISPATCH_TIME_NOW)) {
            break;
        }
        
        if ([[NSDate date] compare:dateLimit] == NSOrderedDescending) {
            NSAssert(YES, @"Timout during last operation. Time limit: %d", (int)timeout);
            break;
        }
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    }
}

+ (void)waitGroup:(dispatch_group_t)dispatchGroup {
    [self waitGroup:dispatchGroup
         withTimout:30];
}

+ (BOOL)isGroup:(dispatch_group_t)dispatchGroup timeoutFiredValue:(NSInteger)timeout {
    NSDate *dateLimit = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    BOOL res = NO;
    
    while(YES) {
        if (!dispatch_group_wait(dispatchGroup, DISPATCH_TIME_NOW)) {
            break;
        }
        
        if ([[NSDate date] compare:dateLimit] == NSOrderedDescending) {
            res = YES;
            break;
        }
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
    return res;
}

+ (BOOL)isGCDGroup:(GCDGroup *)gcdGroup timeoutFiredValue:(NSInteger)timeout {
    NSDate *dateLimit = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    BOOL res = NO;
    
    while(YES) {
        if (![gcdGroup wait:DISPATCH_TIME_NOW]) {
            break;
        }
        
        if ([[NSDate date] compare:dateLimit] == NSOrderedDescending) {
            res = YES;
            break;
        }
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
    return res;
}

+ (void)sleepForSeconds:(NSUInteger)sec {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:sec]];
}

@end
