//
//  BaseTest.h
//  AllMethods
//
//  Created by Vadim Osovets on 5/18/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseTest;

@protocol BaseTestDelegate <NSObject>

- (void)test:(BaseTest *)test finishedWithSuccess:(BOOL)res;
- (void)test:(BaseTest *)test reachedTimeout:(BOOL)res;

@end

@interface BaseTest : NSObject

@property (nonatomic, assign) BOOL isFailed;

/**
 By default we assume that test shouldn't take more than 30s
 */
@property (nonatomic, assign) NSTimeInterval timeoutRunning;

@property (nonatomic, weak) id<BaseTestDelegate> delegate;

/**
 Can be overloaded by childs.
 */
- (void)setup;

/**
 Main method for tests.
 */
- (void)run;

/**
 Clean up after tests and invalidate running timer.
 Should be called by childs.
 */
- (void)teardown;

@end
