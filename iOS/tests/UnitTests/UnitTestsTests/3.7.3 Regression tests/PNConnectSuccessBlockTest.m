//
//  PNConnectSuccessBlockTest.m
//  UnitTests
//
//  Created by Sergey on 11/13/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSString *kOrigin = @"pubsub.pubnub.com";
static NSString *kPublishKey = @"demo";
static NSString *kSubscribeKey = @"demo";
static NSString *kSecretKey = @"mySecret";

@interface PNConnectSuccessBlockTest : XCTestCase <PNDelegate> {
    dispatch_group_t _resGroup1;
    dispatch_group_t _resGroup2;
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

// Instance connection
- (void)testInstanceConnectSuccessBlock {
    
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kOrigin
                                                                  publishKey:kPublishKey
                                                                subscribeKey:kSubscribeKey
                                                                   secretKey:nil];
    
    _pubNub = [PubNub clientWithConfiguration:configuration andDelegate:self];
    
    _resGroup1 = dispatch_group_create();
    dispatch_group_enter(_resGroup1);
    
    [_pubNub connectWithSuccessBlock:^(NSString *origin){
        dispatch_group_leave(_resGroup1);
    }
                         errorBlock:^(PNError *connectionError){
                             
                             if (connectionError == nil) {
                                 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
                                 XCTFail(@"Looks like there is no internet for connection");
                             }
                             else {
                                 XCTFail(@"Happened something really bad and PubNub client can't establish connection");
                             }

   }];
    
    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Instance connection passed unsuccessfully");
    }
    else {
        NSLog(@"Instance connection with success block went well");
        _resGroup1 = nil;
    }
    
}

// PubNub connection
- (void)testPubNubConnectSuccessBlock {
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kOrigin
                                                                  publishKey:kPublishKey
                                                                subscribeKey:kSubscribeKey
                                                                   secretKey:nil];

    [PubNub setConfiguration:configuration];
    
    _resGroup2 = dispatch_group_create();
    dispatch_group_enter(_resGroup2);
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        dispatch_group_leave(_resGroup2);
        }
                         errorBlock:^(PNError *connectionError) {
                            
                          if (connectionError == nil) {
                              PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
                              XCTFail(@"Looks like there is no internet connection");
                          }
                          else {
                              XCTFail(@"Happened something really bad and PubNub can't establish connection: %@", connectionError);
                          }

                      }];
    
    if ([GCDWrapper isGroup:_resGroup2 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. PubNub connection passed unsuccessfully");
    }
    
    _resGroup2 = nil;
}

@end
