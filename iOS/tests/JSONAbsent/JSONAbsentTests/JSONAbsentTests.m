//
//  JSONAbsentTests.m
//  JSONAbsentTests
//
//  Created by Vadim Osovets on 11/1/13.
//  Copyright (c) 2013 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNJSONSerialization.h"
#import "PNJSONSerialization+JsonTest.h"

@interface JSONAbsentTests : XCTestCase

@end

@implementation JSONAbsentTests

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

- (void)testJSONAbsent
{
    XCTAssert([PNJSONSerialization isNSJSONAvailable] == YES, @"NSJSON is not available");
	XCTAssert( [PNJSONSerialization isJSONKitAvailable] == NO, @"JSONKit is available");
}

@end
