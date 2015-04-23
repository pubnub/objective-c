//
//  PNConnectClientWithConfigTest.m
//  UnitTests
//
//  Created by Sergey on 11/6/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSString * const kAuthorizationKey = nil;

@interface PNConnectClientWithConfigTest : XCTestCase <PNDelegate> {
    dispatch_group_t _resGroup;
}
@end

@implementation PNConnectClientWithConfigTest

- (void)setUp {
    [super setUp];
    
    [PubNub setDelegate:self];
    [PubNub disconnect];
}

- (void)tearDown {
    [PubNub disconnect];
    [super tearDown];
}

#pragma mark - Tests

// Test
- (void)testConfiguration {
    
    PNConfiguration *configuration = [PNConfiguration accessManagerTestConfiguration];
    
    configuration.authorizationKey = kAuthorizationKey;

    _resGroup = dispatch_group_create();
    dispatch_group_enter(_resGroup);
    dispatch_group_enter(_resGroup);
    
    [PubNub connectingClientWithConfiguration:configuration delegate:self andSuccessBlock:^(NSString *res) {
        dispatch_group_leave(_resGroup);
    } errorBlock:^(PNError *error) {
        XCTFail(@"Error occurs during connection: %@", error);
        dispatch_group_leave(_resGroup);
    }];

    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
    }
    
    _resGroup = NULL;
}


#pragma mark - PubNub Delegate

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
    // ?
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    if (_resGroup) {
        dispatch_group_leave(_resGroup);
    }
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    if (error == nil) {
         // Looks like there is no internet connection at the moment when this method has been called or PubNub client doesn't have enough time
        // to validate its availability.
        //
        // In this case connection will be established automatically as soon as internet connection will be detected.
    }
    else {
        // Happened something really bad and PubNub client can't establish connection, so we should update our interface to let user know and
        // do something to recover from this situation.
        //
        // Error also can be sent by PubNub client if you tried to connect while already connected or just launched connection.
        //
        // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
        // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
    }
}
@end
    
