//
//  TestSemaphor.m
//  BillsApp
//
//  Created by Marin Todorov on 17/01/2012.
//  Copyright (c) 2012 Marin Todorov. All rights reserved.
//

#import "TestSemaphor.h"

@implementation TestSemaphor

@synthesize flags;

+(TestSemaphor *)sharedInstance {   
    static TestSemaphor *sharedInstance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [TestSemaphor alloc];
        sharedInstance = [sharedInstance init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        self.flags = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.flags = nil;
}

- (BOOL)isLifted:(NSString*)key {
    return [self.flags objectForKey:key] != nil;
}

- (void)lift:(NSString*)key {
    [self.flags setObject:@"YES" forKey:key];
}

- (BOOL)waitForKey:(NSString *)key timeout:(NSTimeInterval)timeout {
    BOOL keepRunning;
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        keepRunning = ![[TestSemaphor sharedInstance] isLifted:key];
        
        if([timeoutDate timeIntervalSinceNow] < 0.0) {
            [self lift:key];
            return NO;
        }
    } while (keepRunning);
    return YES;
}

- (BOOL)waitForKey:(NSString*)key {
    return [self waitForKey:key timeout:20.0];
}


@end
