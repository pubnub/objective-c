//
//  NSString+PNAdditionTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/27/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+PNAddition.h"

@interface NSString ()
- (NSString *)percentEscapedStringWithEscapeString:(NSString *)stringWithCharsForEscape;
- (NSTimeInterval)timeout;
- (NSString *)ASCIIStringHEXEncodedString:(BOOL)shouldUseHEXCodes;
@end

@interface NSString_PNAdditionTest : XCTestCase

@end

@implementation NSString_PNAdditionTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testPercentEscapedString {
	NSString *string = @":asdf/asdf?asdf#sadf[b sg]s g@as rg!srt$re&g’rqreqge( sg)sdfgh* stght+ h,sth;a=a@$%^@$&";
	XCTAssertTrue( [[string pn_percentEscapedString] isEqualToString: @"%3Aasdf%2Fasdf%3Fasdf%23sadf%5Bb%20sg%5Ds%20g%40as%20rg%21srt%24re%26g%E2%80%99rqreqge%28%20sg%29sdfgh%2A%20stght%2B%20h%2Csth%3Ba%3Da%40%24%25%5E%40%24%26"] == YES, @"");

	XCTAssertTrue( [[string percentEscapedStringWithEscapeString: @":/?#[]@!$&’()*+,;="] isEqualToString: @"%3Aasdf%2Fasdf%3Fasdf%23sadf%5Bb%20sg%5Ds%20g%40as%20rg%21srt%24re%26g%E2%80%99rqreqge%28%20sg%29sdfgh%2A%20stght%2B%20h%2Csth%3Ba%3Da%40%24%25%5E%40%24%26"] == YES, @"");
}

-(void)testASCIIString {
	NSString *string = @":asdf/asdf?asdf#sadf[b sg]s g@as rg!srt$re&g’rqreqge( sg)sdfgh* stght+ h,sth;a=a@$%^@$&";
	XCTAssertTrue( [[string pn_ASCIIString] isEqualToString: @"58971151001024797115100102639711510010235115971001029198321151039311532103649711532114103331151141163611410138103821711411311410111310310140321151034111510010210310442321151161031041164332104441151161045997619764363794643638"] == YES, @"");

	XCTAssertTrue( [[string pn_ASCIIHEXString] isEqualToString: @"3A617364662F617364663F6173646623736164665B622073675D732067406173207267217372742472652667201972717265716765282073672973646667682A2073746768742B20682C7374683B613D614024255E402426"] == YES, @"");

	XCTAssertTrue( [[string ASCIIStringHEXEncodedString:NO] isEqualToString: @"58971151001024797115100102639711510010235115971001029198321151039311532103649711532114103331151141163611410138103821711411311410111310310140321151034111510010210310442321151161031041164332104441151161045997619764363794643638"] == YES, @"");

	XCTAssertTrue( [[string ASCIIStringHEXEncodedString:YES] isEqualToString: @"3A617364662F617364663F6173646623736164665B622073675D732067406173207267217372742472652667201972717265716765282073672973646667682A2073746768742B20682C7374683B613D614024255E402426"] == YES, @"");
}

-(void)testTruncatedString {
	NSString *string = @":asdf/asdf?asdf#sadf[b sg]s g@as rg!srt$re&g’rqreqge( sg)sdfgh* stght+ h,sth;a=a@$%^@$&";
	NSString *trunc = [string pn_truncatedString: 20 lineBreakMode: NSLineBreakByCharWrapping];
	XCTAssertTrue( [trunc isEqualToString: @":asdf/asdf?asdf#sadf[b sg]s g@as rg!srt$re&g’rqreqge( sg)sdfgh* stght+ h,sth;a=a@$%^@$&"], @"" );

	trunc = [string pn_truncatedString: 20 lineBreakMode: NSLineBreakByClipping];
	XCTAssertTrue( [trunc isEqualToString: @":asdf/asdf?asdf#sadf"] == YES, @"" );

	trunc = [string pn_truncatedString: 20 lineBreakMode: NSLineBreakByTruncatingHead];
	XCTAssertTrue( [trunc isEqualToString: @"…t+ h,sth;a=a@$%^@$&"] == YES, @"" );

	trunc = [string pn_truncatedString: 20 lineBreakMode: NSLineBreakByTruncatingMiddle];
	XCTAssertTrue( [trunc isEqualToString: @":asdf/asdf…a=a@$%^@$&"] == YES, @"" );

	trunc = [string pn_truncatedString: 20 lineBreakMode: NSLineBreakByTruncatingTail];
	XCTAssertTrue( [trunc isEqualToString: @":asdf/asdf?asdf#sad…"] == YES, @"" );

	trunc = [string pn_truncatedString: 20 lineBreakMode: NSLineBreakByWordWrapping];
	XCTAssertTrue( [trunc isEqualToString: @":asdf/asdf?asdf#sadf[b sg]s g@as rg!srt$re&g’rqreqge( sg)sdfgh* stght+ h,sth;a=a@$%^@$&"] == YES, @"" );
}

-(void)testSha256Data {
	NSString *string = @":asdf/asdf?asdf#sadf[b sg]s g@as rg!srt$re&g’rqreqge( sg)sdfgh* stght+ h,sth;a=a@$%^@$&";
	NSString *fromData = [[string pn_sha256Data] description];
	XCTAssertTrue( [fromData isEqualToString: @"<702eb86c 6b3a94af 5b3ef9fc cde39d83 93892a68 e1697901 7645a911 370682ca>"] == YES, @"");
}


-(void)testSha256HEXString {
	NSString *string = @":asdf/asdf?asdf#sadf[b sg]s g@as rg!srt$re&g’rqreqge( sg)sdfgh* stght+ h,sth;a=a@$%^@$&";
	NSString *hex = [string pn_sha256HEXString];
	NSLog(@"from %@", hex);
	XCTAssertTrue( [hex isEqualToString: @"702eb86c6b3a94af5b3ef9fccde39d83"] == YES, @"");
}

@end



