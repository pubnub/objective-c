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
    [self.client addListener:self];
}

- (void)tearDown {
    self.subscribeExpectation = nil;
    [self.client removeListener:self];
    [super tearDown];
}

@end
