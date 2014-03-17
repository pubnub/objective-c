//
//  PNTimeTokenRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

// We don't have anything to test yet in this class

#import "PNTimeTokenRequestTest.h"
#import "PNTimeTokenRequest.h"

@implementation PNTimeTokenRequestTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInit {
	PNTimeTokenRequest *request = [[PNTimeTokenRequest alloc] init];
	STAssertTrue( request != nil, @"");
	STAssertTrue( request.sendingByUserRequest == YES, @"");

	STAssertTrue( [[request callbackMethodName] isEqualToString: @"t"] == YES, @"");
}

-(void)testResourcePath {
	PNTimeTokenRequest *request = [[PNTimeTokenRequest alloc] init];
	NSString *resourcePath = [request resourcePath];
	NSLog(@"res %@", resourcePath);
	STAssertTrue( [resourcePath hasPrefix: @"/time/t_"] == YES, @"");
	STAssertTrue( resourcePath.length == 13, @"");
}

@end
