//
//  PubNubTemporaryMethodInvocationStorageTest.m
//  pubnub
//
//  Created by Vadim Osovets on 7/14/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

extern NSMutableArray *reprioritizedPendingInvocations;

@interface PubNubTemporaryMethodInvocationStorageTest : SenTestCase
<
PNDelegate
>

@end

@implementation PubNubTemporaryMethodInvocationStorageTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPubNubInit
{
    [PubNub setDelegate:self];
    
    STAssertTrue([reprioritizedPendingInvocations isKindOfClass:[NSMutableArray class]], @"Pending invocation is not initialized.");
    
    /*
     Test for:
     - (void)postponeSelector:(SEL)calledMethodSelector forObject:(id)object withParameters:(NSArray *)parameters
     outOfOrder:(BOOL)placeOutOfOrder{
     
     - (void)handleLockingOperationBlockCompletion:(void(^)(void))operationPostBlock shouldStartNext:(BOOL)shouldStartNext
     */
}

@end
