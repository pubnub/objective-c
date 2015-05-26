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

// keys "demo"
- (NSString *)mainPubKey {
    return @"demo";
}

- (NSString *)mainSubKey {
    return @"demo";
}

// keys "admin"
- (NSString *)adminPubKey {
    return @"pub-c-c37b4f44-6eab-4827-9059-3b1c9a4085f6";
}

- (NSString *)adminSubKey {
    return @"sub-c-fb5d8de4-3735-11e4-8736-02ee2ddab7fe";
}

// keys "Vadim"
- (NSString *)VadimPubKey {
    return @"pub-c-12b1444d-4535-4c42-a003-d509cc071e09";
}

- (NSString *)VadimSubKey {
    return @"sub-c-6dc508c0-bff0-11e3-a219-02ee2ddab7fe";
}
- (NSTimeInterval)testTimeout {
    return 10;
}

@end
