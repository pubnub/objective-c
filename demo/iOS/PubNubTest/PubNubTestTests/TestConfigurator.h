//
//  TestConfigurator.h
//  AllMethods
//
//  Created by Vadim Osovets on 5/18/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestConfigurator : NSObject

+ (instancetype)shared;

- (NSString *)mainPubKey;
- (NSString *)mainSubKey;

- (NSString *)adminPubKey;
- (NSString *)adminSubKey;

- (NSString *)VadimPubKey;
- (NSString *)VadimSubKey;

- (NSTimeInterval)testTimeout;

@end
