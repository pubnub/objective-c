//
//  BaseTest.m
//  AllMethods
//
//  Created by Vadim Osovets on 5/18/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import "BaseTest.h"

@implementation BaseTest {
    NSTimer *_timer;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.timeoutRunning = 30;
    }
    
    return self;
}

- (void)setup {}

- (void)run {
    _timer = [NSTimer timerWithTimeInterval:self.timeoutRunning
                                     target:self
                                   selector:@selector(timerFire:)
                                   userInfo:nil
                                    repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer
                                 forMode:NSDefaultRunLoopMode];
}

- (void)timerFire:(NSTimer *)timer {
    if ([self.delegate respondsToSelector:@selector(test:reachedTimeout:)]) {
        [self.delegate test:self reachedTimeout:YES];
    }
}

- (void)teardown {
    if ([_timer isValid]) {
        [_timer invalidate];
    }
}

@end
