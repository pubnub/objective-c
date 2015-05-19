//
//  TestConfigurator.m
//  AllMethods
//
//  Created by Vadim Osovets on 5/18/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import "TestConfigurator.h"

@class TestConfigurator;

static TestConfigurator *_sharedInstance = nil;

@implementation TestConfigurator

+ (instancetype)shared {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [self new];
    });
    
    return _sharedInstance;
}

#pragma mark - Properties

- (NSString *)mainPubKey {
    return @"demo";
}

- (NSString *)mainSubKey {
    return @"demo";
}

- (NSTimeInterval)testTimeout {
    return 10;
}

@end
