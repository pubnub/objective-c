//
//  PNConnectSuccessBlockTest.m
//  UnitTests
//
//  Created by Sergey on 11/13/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface PNConnectSuccessBlockTest : XCTestCase <PNDelegate> {
    GCDGroup *_resGroup1;
    GCDGroup *_resGroup2;
    
    PubNub *_pubNub;
}
@end


@implementation PNConnectSuccessBlockTest

- (void)setUp {
    [super setUp];
    [PubNub disconnect];
}

- (void)tearDown {
    [PubNub disconnect];
    [super tearDown];
}

#pragma mark - Tests

// Instance connection
- (void)testInstanceConnectSuccessBlock {
    
    
    PNConfiguration *configuration = [PNConfiguration defaultTestConfiguration];
    
    _pubNub = [PubNub clientWithConfiguration:configuration andDelegate:self];
    
    _resGroup1 = [GCDGroup group];
    [_resGroup1 enter];
    
    [_pubNub connectWithSuccessBlock:^(NSString *origin){
        [_resGroup1 leave];
    }
                         errorBlock:^(PNError *connectionError){
                             
                             if (connectionError == nil) {
                                 NSLog(@"connectionError %@", connectionError);
                                 XCTFail(@"Looks like there is no internet for connection");
                             }
                             else {
                                 XCTFail(@"Happened something really bad and PubNub client can't establish connection");
                             }
                             [_resGroup1 leave];

   }];
    
    if ([GCDWrapper isGCDGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Instance connection passed unsuccessfully");
    }
    
    _resGroup1 = nil;
}

// PubNub connection
- (void)testPubNubConnectSuccessBlock {
    
    PNConfiguration *configuration = [PNConfiguration defaultTestConfiguration];

    [PubNub setConfiguration:configuration];
    
    _resGroup2 = [GCDGroup group];
    [_resGroup2 enter];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [_resGroup2 leave];
        }
                         errorBlock:^(PNError *connectionError) {
                            
                          if (connectionError == nil) {
                              NSLog(@"connectionError %@", connectionError);
                              XCTFail(@"Looks like there is no internet connection");
                          }
                          else {
                              XCTFail(@"Happened something really bad and PubNub can't establish connection: %@", connectionError);
                          }

                             [_resGroup2 leave];
                      }];
    
    if ([GCDWrapper isGCDGroup:_resGroup2 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. PubNub connection passed unsuccessfully");
    }
    
    _resGroup2 = nil;
}

@end
