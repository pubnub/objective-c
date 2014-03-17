//
//  PNNetworkHelperTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/27/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNNetworkHelper.h"

@interface PNNetworkHelper ()
+ (id)fetchWLANInformation;
@end

@interface PNNetworkHelperTest : SenTestCase

@end

@implementation PNNetworkHelperTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testNetworkAddress {
	NSString *networkAddress = [PNNetworkHelper networkAddress];
	NSLog( @"net %@", networkAddress);
	STAssertTrue( [networkAddress stringByReplacingOccurrencesOfString: @"." withString: @""].length == networkAddress.length-3, @"");

	NSCharacterSet *charactersToRemove = [NSCharacterSet characterSetWithCharactersInString: @"0123456789."];
	NSString *trimmedReplacement = [[networkAddress componentsSeparatedByCharactersInSet: charactersToRemove] componentsJoinedByString:@"" ];
	STAssertTrue( trimmedReplacement.length == 0, @"");
}

-(void)testOriginLookupResourcePath {
	NSString *originLookupResourcePath = [PNNetworkHelper originLookupResourcePath];
	NSLog( @"originLookupResourcePath %@", originLookupResourcePath);
	STAssertTrue( [originLookupResourcePath hasPrefix: @"http://ios.pubnub.com/time/t_"] == YES, @"");
	STAssertTrue( originLookupResourcePath.length == 44, @"");
}


@end
