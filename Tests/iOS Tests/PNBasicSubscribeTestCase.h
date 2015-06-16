//
//  PNBasicSubscribeTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

@class XCTestExpectation;

@interface PNBasicSubscribeTestCase : PNBasicClientTestCase <PNObjectEventListener>

@property (nonatomic) XCTestExpectation *subscribeExpectation;

@end
