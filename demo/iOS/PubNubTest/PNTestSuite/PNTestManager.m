//
//  PNTestManager.m
//  SubUnsubStressTest
//
//  Created by Vadim Osovets on 4/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import "PNTestManager.h"
#import "PNBaseTestCase.h"

#import "FTChangeSettings.h"

@implementation PNTestManager {
    NSMutableArray *_testcases;
    NSOperationQueue *_testQueue;
}

+ (instancetype)shared {
    static PNTestManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self new];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _testQueue = [NSOperationQueue mainQueue];
        
        // TODO: move to setup
        [_testQueue setMaxConcurrentOperationCount:1];
        
        _testcases = [NSMutableArray array];
    }
    
    return self;
}

- (void)addTests:(NSArray *)tests {
    for (NSString *className in tests) {
        Class testCaseClass = NSClassFromString(className);
        
        // TODO: set assert if we try to load another class than PNBaseTestCase
        PNBaseTestCase *testCase = [testCaseClass new];
        
        NSAssert([testCaseClass isSubclassOfClass:[PNBaseTestCase class]], @"Check which class you've put into test queue: %@", className);
        
        if (testCase) {
            testCase.name = className;
            [_testcases addObject:testCase];
        }
    }
}

- (void)addTestsFromBundleWithName:(NSString *)bundleName {
    
    NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], bundleName]];
    
    NSError *error = nil;
    
    BOOL res = [bundle loadAndReturnError:&error];
    if (res == NO || error) {
        // TODO: show an error here.
        NSLog(@"Cannot load bundle with name: %@ during error: %@", bundleName, error);
        return;
    }
    
    NSLog(@"Bundle: %@", bundle);
}

- (void)resume {
    NSLog(@"%s", __FUNCTION__);

    [_testQueue addOperations:_testcases waitUntilFinished:NO];
}

- (void)printResults {
}

@end
