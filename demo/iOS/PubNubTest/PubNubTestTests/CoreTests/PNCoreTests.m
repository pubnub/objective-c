//
//  PNCoreTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015  PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

@interface PNCoreTests : XCTestCase

@property (nonatomic, copy) NSString *publishKey;
@property (nonatomic, copy) NSString *subscribeKey;
@property (nonatomic, copy) NSString *authKey;
@property (nonatomic, copy, setter = setUUID:) NSString *uuid;
@property (nonatomic, copy) NSString *cipherKey;
@property (nonatomic, assign) NSTimeInterval subscribeMaximumIdleTime;
@property (nonatomic, assign) NSTimeInterval nonSubscribeRequestTimeout;
@property (nonatomic, assign) NSInteger presenceHeartbeatValue;
@property (nonatomic, assign) NSInteger presenceHeartbeatInterval;
@property (nonatomic, assign, getter = isSSLEnabled) BOOL SSLEnabled;
@property (nonatomic, assign, getter = shouldKeepTimeTokenOnListChange) BOOL keepTimeTokenOnListChange;
@property (nonatomic, assign, getter = shouldRestoreSubscription) BOOL restoreSubscription;
@property (nonatomic, assign, getter = shouldTryCatchUpOnSubscriptionRestore) BOOL catchUpOnSubscriptionRestore;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;

- (void)commitConfiguration:(dispatch_block_t)block;
+ (instancetype)clientWithPublishKey:(NSString *)publishKey
                     andSubscribeKey:(NSString *)subscribeKey;
@end


@implementation PNCoreTests  {
    
    PubNub *_pubNub;
    GCDGroup *_resGroup;
    NSData *_devicePushToken;
}

- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    _devicePushToken = nil;
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}

- (void)testCommitConfiguration {


}

@end
