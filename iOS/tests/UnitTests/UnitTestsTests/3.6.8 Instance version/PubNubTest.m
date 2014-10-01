//
//  PubNubTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 9/30/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface PubNubTest : XCTestCase

<
PNDelegate
>

@end

@implementation PubNubTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Test

/**
 Check that changes in clients identifiers doesn't affect any other instance of PubNub.
 */

- (void)testIdentifiers
{
    NSString *const kIdentifier1 = @"1";
    NSString *const kIdentifier2 = @"2";
    NSString *const kIdentifier3 = @"3";
    
    [PubNub setClientIdentifier:kIdentifier1];
    PubNub *pubNub2 = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:nil];
    [pubNub2 setClientIdentifier:kIdentifier2];
    
    PubNub *pubNub3 = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    [pubNub3 setClientIdentifier:kIdentifier3];
    
    // check different identifiers
    
    XCTAssertEqualObjects([PubNub clientIdentifier], kIdentifier1, @"Client identifiers inconsistent.");
    XCTAssertEqualObjects([pubNub2 clientIdentifier], kIdentifier2, @"Client identifiers inconsistent.");
    XCTAssertEqualObjects([pubNub3 clientIdentifier], kIdentifier3, @"Client identifiers inconsistent.");
}

/**
 Check that changes in clients configuration doesn't affect any other instance of PubNub.
 */

- (void)testConnect {
    
    NSString *const kStubConf2 = @"pubsub.com.origin2";
    NSString *const kStubConf3 = @"subkey3";
    
    PNConfiguration *configuration2 = [PNConfiguration configurationForOrigin:kStubConf2
                                                                   publishKey:kStubConf2 subscribeKey:kStubConf2 secretKey:kStubConf2];
    
    PNConfiguration *configuration3 = [PNConfiguration configurationForOrigin:kStubConf3
                                                                   publishKey:kStubConf3 subscribeKey:kStubConf3 secretKey:kStubConf3];
;
    
    [PubNub setClientIdentifier:kIdentifier1];
    PubNub *pubNub2 = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:nil];
    [pubNub2 setClientIdentifier:kIdentifier2];
    
    PubNub *pubNub3 = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    [pubNub3 setClientIdentifier:kIdentifier3];
    
    // check different identifiers
    
    XCTAssertEqualObjects([PubNub clientIdentifier], kIdentifier1, @"Client identifiers inconsistent.");
    XCTAssertEqualObjects([pubNub2 clientIdentifier], kIdentifier2, @"Client identifiers inconsistent.");
    XCTAssertEqualObjects([pubNub3 clientIdentifier], kIdentifier3, @"Client identifiers inconsistent.");
}

- (void)testDelegates {
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
