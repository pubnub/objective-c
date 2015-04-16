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
    
    GCDGroup *_resGroup;
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
    __block int callBackCounter = 0;
    
    PNConfiguration *config = [PNConfiguration defaultTestConfiguration];
    [PubNub setConfiguration:config];
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
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
                           
                           if (i == 19) {
                               
                               for (int j = 20; j < 40; j++) {
                                   
                                   [PubNub sendMessage:[NSString stringWithFormat:@"dev test message: %d", i] toChannel:channel withCompletionBlock:^(PNMessageState state, id message) {
                                       
                                       if (PNMessageSent == state) {
                                           
                                           @synchronized(self) {
                                               [blockIds addObject:[NSNumber numberWithInt:i]];
                                           }
                                           
                                           // leave first enter
                                           if (j == 39) {
                                               callBackCounter++;
                                               if (callBackCounter == 1) {
                                                   [_resGroup leave];
                                               };
                                           }
                                       }
                                   }];
                               }
                           };
                       }
                   }];
               }
           }
       }];
        
    } errorBlock:^(PNError *error) {
        XCTFail(@"Connect is failed");
    }];

    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTFail(@"Timeout fired during sent message");
    }
    
    XCTAssertTrue(callBackCounter == 1, @"callBackCounter = %d", callBackCounter);

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
