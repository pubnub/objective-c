//
//  PNTestManager.h
//  SubUnsubStressTest
//
//  Created by Vadim Osovets on 4/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNBaseTestCase;

@interface PNTestManager : NSObject

+ (instancetype)shared;

/*
 Initializators
 */

- (void)addTests:(NSArray *)tests;
- (void)addTestsFromBundleWithName:(NSString *)bundleName;
- (void)addTestsFromBundle:(NSBundle *)bundle excludedTests:(NSArray *)excludedTests;

/**
 Setup
 */

- (void)setMaxConcurrectTest:(NSUInteger)maxConcurrectTest;

/**
 Run
 */
- (void)resume;
- (void)pause;

/**
 Analyze results
 */

- (void)printResults;


@end
