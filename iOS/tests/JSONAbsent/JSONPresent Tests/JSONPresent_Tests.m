//
//  JSONPresent_Tests.m
//  JSONPresent Tests
//
//  Created by Valentin Tuller on 10/15/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNJSONSerialization.h"
#import "PNJSONSerialization+JsonTest.h"

@interface JSONPresent_Tests : SenTestCase

@end

@implementation JSONPresent_Tests

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

- (void)testExample
{
	STAssertTrue( [PNJSONSerialization isNSJSONAvailable] == YES, @"NSJSON not available");
	STAssertTrue( [PNJSONSerialization isJSONKitAvailable] == NO, @"JSONKit not available");
}

@end
