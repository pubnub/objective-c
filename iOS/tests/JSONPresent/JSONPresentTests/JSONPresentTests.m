//
//  JSONPresentTests.m
//  JSONPresentTests
//
//  Created by Vadim Osovets on 11/1/13.
//  Copyright (c) 2013 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNJSONSerialization+JsonTest.h"

@interface JSONPresentTests : XCTestCase

@end

@implementation JSONPresentTests

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

- (void)testJSONPresent
{
    XCTAssert( [PNJSONSerialization isNSJSONAvailable] == YES, @"NSJSON not is available");
	XCTAssert( [PNJSONSerialization isJSONKitAvailable] == YES, @"JSONKit is not available");
}

@end
