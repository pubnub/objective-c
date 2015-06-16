//
//  PNBasicSubscribeTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import "PNBasicSubscribeTestCase.h"

@implementation PNBasicSubscribeTestCase

- (void)setUp {
    [super setUp];
    [self.client addListeners:@[self]];
}

- (void)tearDown {
    self.subscribeExpectation = nil;
    [self.client removeListeners:@[self]];
    [super tearDown];
}

@end
