//
//  PNHistoryTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

@interface PNHistoryTests : XCTestCase

@end

@implementation PNHistoryTests {
    
    PubNub *_pubNub;
    GCDGroup *_resGroup;
}


- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}

- (void)testHistory {

    // Get timetoken until send message
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block NSNumber *_timetoken1;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        _timetoken1 = [NSNumber numberWithLongLong:[[result.data objectForKey:@"tt"] longLongValue] ];
        [_resGroup leave];
    }];

    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        
        NSLog(@"Timeout fired");
    }

    // Send message to channel
    [_resGroup enter];
    
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:NO withCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        
        NSLog(@"Timeout fired");
    }

    // Get timetoken after send message
    [_resGroup enter];
    
    __block NSNumber *_timetoken2;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        _timetoken2 = [NSNumber numberWithLongLong:[[result.data objectForKey:@"tt"] longLongValue] ];
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        
        NSLog(@"Timeout fired");
    }

    // Get history for channel
    [_pubNub historyForChannel:@"testChannel1" start:_timetoken1 end:_timetoken2 limit:1 reverse:NO includeTimeToken:YES withCompletion:^(PNResult *result, PNStatus *status) {

        if (status.error) {
            
            XCTFail(@"Error");
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during publishing");
    }
}

@end
