//
//  TimeCommand.m
//  pubnub
//
//  Created by Valentin Tuller on 11/6/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNConnection.h"
#import "PNHereNowResponseParser.h"
#import "Swizzler.h"
#import "PNDefaultConfiguration.h"
#import "Swizzler.h"

@interface TimeCommand : XCTestCase <PNDelegate> {
	XCTestExpectation *_disconnectFromOriginExpectation;
}

@end

@implementation TimeCommand


- (void)setUp
{
    [super setUp];
    
    [PubNub disconnect];
//    [PubNub resetClient];
}

- (void)tearDown {
    [PubNub disconnect];
    
    [GCDWrapper sleepForSeconds:1];
    
    [super tearDown];
}

#pragma mark - Tests

- (void)test10Connection {
    
//    [PubNub resetClient];
    
    [GCDWrapper sleepForSeconds:1];
    [PubNub setDelegate:self];
    [PubNub setConfiguration:[PNConfiguration defaultTestConfiguration]];
    
    XCTestExpectation *connectExpection = [self expectationWithDescription:@"PubNub connect"];
    XCTestExpectation *connectionDidFailExpectation = [self expectationForNotification:kPNClientConnectionDidFailWithErrorNotification
                                                                    object:nil
                                                                   handler:^BOOL(NSNotification *notification) {
                                                                       NSLog(@"Notif: %@", notification);
                                                                       return YES;
                                                                   }];
    _disconnectFromOriginExpectation = [self expectationWithDescription:@"Disconnect from PubNub."];
    
    SwizzleReceipt *receipt = [self setOriginLookupResourcePath];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [connectExpection fulfill];
    } errorBlock:^(PNError *error) {
        XCTFail(@"Error during connection: %@", [error localizedDescription]);
    }];
    
    [self waitForExpectationsWithTimeout:kTestTestTimout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            return;
        }
    }];
     
    connectExpection = nil;
    connectionDidFailExpectation = nil;
    _disconnectFromOriginExpectation = nil;
    
    NSLog(@"finish swizzle");
    
    [Swizzler unswizzleFromReceipt:receipt];
}

#pragma mark - Delegates

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    
    if (_disconnectFromOriginExpectation) {
        [_disconnectFromOriginExpectation fulfill];
    }
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
    
    if (_disconnectFromOriginExpectation) {
        [_disconnectFromOriginExpectation fulfill];
    }
}

#pragma mark - Swizzle

-(SwizzleReceipt*)setOriginLookupResourcePath {
	return [Swizzler swizzleSelector:@selector(originLookupResourcePath)
				 forClass:[PNNetworkHelper class]
						   withBlock:
			^(id self, SEL sel){
				NSLog(@"PNNetworkHelper originLookupResourcePath");
				return @"http://google.com";
			}];
}

@end
