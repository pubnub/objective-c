//
//  NSData+PNAdditionsTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/27/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSData+PNAdditions.h"

@interface NSData ()
+ (NSData *)dataFromBase64String:(NSString *)encodedSting;
@end

@interface NSData_PNAdditionsTest : XCTestCase

@end

@implementation NSData_PNAdditionsTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

//1. Test data from base string
-(void)testDataFromBase64String {
    NSString *string = @"strajdasjdfnajsd adfja jdakld jfaksldj  kalalkja df0913485134578130495@%^@%^@$%^";
    
    string = [[[NSData alloc] initWithBase64EncodedString: @"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0"
               @"aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1"
               @"c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0"
               @"aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdl"
               @"LCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="
                                                  options:NSDataBase64DecodingIgnoreUnknownCharacters] description];
    
    XCTAssertTrue( [string isEqualToString: @"<4d616e20 69732064 69737469 6e677569 73686564 2c206e6f 74206f6e 6c792062 79206869 73207265 61736f6e 2c206275 74206279 20746869 73207369 6e67756c 61722070 61737369 6f6e2066 726f6d20 6f746865 7220616e 696d616c 732c2077 68696368 20697320 61206c75 7374206f 66207468 65206d69 6e642c20 74686174 20627920 61207065 72736576 6572616e 6365206f 66206465 6c696768 7420696e 20746865 20636f6e 74696e75 65642061 6e642069 6e646566 61746967 61626c65 2067656e 65726174 696f6e20 6f66206b 6e6f776c 65646765 2c206578 63656564 73207468 65207368 6f727420 76656865 6d656e63 65206f66 20616e79 20636172 6e616c20 706c6561 73757265 2e>"], @"");
}

//2. Test base encoding    was NSData dataFromBase64String
-(void)testBase64Encoding {
	NSData *data = [[NSData alloc] initWithBase64EncodedString:  @"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0"
					@"aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1"
					@"c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0"
					@"aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdl"
					@"LCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
	NSString *base64Encoding = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
	XCTAssertTrue( [base64Encoding isEqualToString: @"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="], @"");
}

//3. Test HEX string    was NSData dataFromBase64String
-(void)testHEXString {
	NSData *data = [[NSData alloc] initWithBase64EncodedString: @"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0"
					@"aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1"
					@"c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0"
					@"aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdl"
					@"LCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
	NSString *hex = [data pn_HEXString];
	XCTAssertTrue( [hex isEqualToString: @"4D616E2069732064697374696E677569736865642C206E6F74206F6E6C792062792068697320726561736F6E2C2062757420627920746869732073696E67756C61722070617373696F6E2066726F6D206F7468657220616E696D616C732C2077686963682069732061206C757374206F6620746865206D696E642C207468617420627920612070"] == YES, @"");
}

//4. Test GZIP deflate    was NSData dataFromBase64String
-(void)testGZIPDeflate {
	NSData *data = [[NSData alloc] initWithBase64EncodedString: @"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0"
					@"aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1"
					@"c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0"
					@"aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdl"
					@"LCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
	NSString *zip = [[data pn_GZIPDeflate] description];
	NSLog(@"zip %@", zip);
	XCTAssertTrue( [zip isEqualToString: @"<1f8b0800 00000000 00032d8f d191c420 0c435b51 0199ebe4 8a704001 cf1193c1 b0bbe97e 2173bfb2 f424ff8a 411d51bd aba5a19e 193758ed a8566eec 37f23c37 8a57dbb0 8fbea4be 345ffe22 0d97b86b 351cad9e a83db341 4c4f29be e19d35e4 552028c3 27f49861 e2549b2d 3dcb8313 5c6cce17 9b58e0f2 44164db9 43edb187 6a73dd60 9ce038c5 c843ba26 d90b9168 33d7d780 19fcb3fa 2e8c891b f80964f4 07e0b9b6 8e17334f fe5788dd 08d24c0a ae32df1b 8d3f5fbf dc8e6b0d 010000>"] == YES, @"");
}

//5. Test HEX push token    was NSData dataFromBase64String
-(void)testHEXPushToken {
	NSData *data = [[NSData alloc] initWithBase64EncodedString: @"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0"
					@"aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1"
					@"c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0"
					@"aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdl"
					@"LCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
	NSString *hex = [[data pn_HEXPushToken] description];
	XCTAssertTrue( [hex isEqualToString: @"4D616E2069732064697374696E677569736865642C206E6F74206F6E6C792062792068697320726561736F6E2C2062757420627920746869732073696E67756C61722070617373696F6E2066726F6D206F7468657220616E696D616C732C2077686963682069732061206C757374206F6620746865206D696E642C20746861742062792061207065727365766572616E6365206F662064656C6967687420696E2074686520636F6E74696E75656420616E6420696E6465666174696761626C652067656E65726174696F6E206F66206B6E6F776C656467652C2065786365656473207468652073686F727420766568656D656E6365206F6620616E79206361726E616C20706C6561737572652E"] == YES, @"");
}

@end

