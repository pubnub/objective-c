//
//  PubNub+PublishTests.m
//  PubNubTest
//
//  Created by Vadim Osovets on 5/27/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <PubNub/PubNub.h>

#import "TestConfigurator.h"

@interface PubNub_PublishTests : XCTestCase

@end

@implementation PubNub_PublishTests {
    PubNub *_pubNub;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    _pubNub = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testPublishNilMessage {
    // This is an example of a functional test case.
    
    [_pubNub publish:nil
           toChannel:[TestConfigurator uniqueString] mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
      }];
}

@end
