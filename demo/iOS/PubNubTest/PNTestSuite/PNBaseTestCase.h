//
//  PNBaseTestCase.h
//  SubUnsubStressTest
//
//  Created by Vadim Osovets on 4/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNBaseTestCase;

@protocol PNBaseTestCaseDelegate <NSObject>

- (void)testCaseDidStart:(PNBaseTestCase *)testCase;
- (void)testCaseDidFinish:(PNBaseTestCase *)testCase;

@end

@interface PNBaseTestCase : NSOperation

@property (nonatomic, weak) id<PNBaseTestCaseDelegate> delegate;
@property (nonatomic, assign) BOOL isFailed;
@property (nonatomic) NSError *error;

@end
