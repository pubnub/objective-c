//
//  PubNubTemporaryMethodInvocationStorageTest.m
//  pubnub
//
//  Created by Vadim Osovets on 7/14/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//


/* This set of test cases should cover most of scenarious to
 test pending invocation queue.
 */

#import <XCTest/XCTest.h>
#import "GCDWrapper.h"

@interface PubNubInvocationStorageTest : XCTestCase
<
PNDelegate
>

@end

@implementation PubNubInvocationStorageTest {
    dispatch_group_t _resultGroup;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    [PubNub disconnect];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPubNubInvocationQueue
{
    [PubNub setDelegate:self];
    
    __block NSMutableArray *blockIds = [NSMutableArray new];
    
    PNConfiguration *config = [PNConfiguration defaultTestConfiguration];
    [PubNub setConfiguration:config];
    
    _resultGroup = dispatch_group_create();
    
    dispatch_group_enter(_resultGroup);
    
    [PubNub connectWithSuccessBlock:^(NSString *result) {
        PNChannel *channel = [PNChannel channelWithName:@"vadimTestDev"];
        
        @synchronized(self) {
            [blockIds addObject:[NSNumber numberWithInt:0]];
        }
        
        [PubNub subscribeOn:@[channel]
       withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
           
           if (state == PNSubscriptionProcessSubscribedState) {
               // send messages
               
               @synchronized(self) {
                   [blockIds addObject:[NSNumber numberWithInt:1]];
               }
               
               for (int i = 2; i < 20; i++) {
                   [PubNub sendMessage:[NSString stringWithFormat:@"dev test message: %d", i] toChannel:channel withCompletionBlock:^(PNMessageState state, id message) {
                       
                       if (PNMessageSent == state) {
                           @synchronized(self) {
                               [blockIds addObject:[NSNumber numberWithInt:i]];
                           }
                           
                           for (int i = 20; i < 40; i++) {
                               
                               [PubNub sendMessage:[NSString stringWithFormat:@"dev test message: %d", i] toChannel:channel withCompletionBlock:^(PNMessageState state, id message) {
                                   
                                   if (PNMessageSent == state) {
                                   
                                       @synchronized(self) {
                                           [blockIds addObject:[NSNumber numberWithInt:i]];
                                       }
                                       
                                       // leave first enter
                                       if (i == 39) {
                                           dispatch_group_leave(_resultGroup);
                                       }
                                   }
                               }];
                           }
                       }
                   }];
               }
           }
       }];
        
    } errorBlock:^(PNError *error) {
        XCTFail(@"Connect is failed");
    }];

    [GCDWrapper waitGroup:_resultGroup];
    
    // check correct of invocation order
    
    [blockIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *first = obj;
        
        if (idx < [blockIds count] - 1) {
            NSNumber *second = blockIds[idx + 1];
            
            if (NSOrderedDescending == [first compare:second]) {
                *stop = YES;
                XCTFail(@"Incorrect order of blocks: %@ > %@", first, second);
            }
        }
    }];
}

@end
