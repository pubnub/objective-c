//
//  PNCryptoTest.m
//  pubnub
//
//  Created by Valentin Tuller on 9/25/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNCryptoTest.h"
#import "PNJSONSerialization.h"
#import "PNConfiguration.h"
#import "PNCryptoHelper.h"
#import "PubNub+Cipher.h"

@interface PNCryptoTest () {
	NSMutableArray *configurations;
	NSMutableArray *strings;
	NSMutableArray *objects;
}

@end

@implementation PNCryptoTest

-(void)test10updateWithConfiguration {
	configurations = [NSMutableArray array];
    PNConfiguration *configuration = nil;
	strings = [NSMutableArray array];
	[strings addObject: @"				"];
	[strings addObject: @"asdvjad  adfa asdkfjlhas half alhkashkf asfdhk1239851239847пывоадфыоафлыва"];
	[strings addObject: @"asdvjad a"];
	[strings addObject: @"asdvjad  adfa asdkfjlhas half alhkashkf asfdhk1239851239847пывоадфыоафлыва"];
	[strings addObject: @"				"];
	[strings addObject: @"12312341#%##$^#^@$^%&^&*:{AD:{X>QW{~{!@{::{AD"];
	[strings addObject: @"a"];
	[strings addObject: @"12345678"];
	[strings addObject: @"1234567890abcdef"];
	[strings addObject: @"1234567890abcdef1234567890abcdef"];
	[strings addObject: @"1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"];
	[strings addObject: [NSString stringWithFormat:@"%@", [NSDate date]]];

	objects = [NSMutableArray array];
	[objects addObject: @{@"hello":@"world", @"in":@[@"field", @"field2"]}];
	[objects addObject: @{@"strings":@"asdfasdfasdfasdf asfasd"}];
//	[objects addObject: @{@"strings":[NSNumber numberWithFloat: 1231.435]}];
	[objects addObject: @{@"string ad aldjsasjhfd asdkfjh s":strings}];
	[objects addObject: @{@"string ad ald3452345	#$%^@#!#$^$%&jswergasjhfd asdkfjh s":@{@"asdfgadsf":@"value"}}];
	[objects addObject: @{@"string ad ald3452345	#$%^@#!#$^$%&jsasjhfd asdkfjh s":@{@"asdfgadsf":@"value", @"arr":@[@"asdf", @"ssdfgsdf", [NSString stringWithFormat:@"%@", [NSDate date]]]}}];
	NSMutableArray *arr = [strings copy];
	[objects addObject: [arr arrayByAddingObject: strings]];
///////////////////////////////////////
	configuration = [PNConfiguration configurationForOrigin:nil
													  publishKey:nil
													subscribeKey:nil
													   secretKey:nil
													   cipherKey:@"my_key"];
	XCTAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:nil
												 publishKey:nil
											   subscribeKey:nil
												  secretKey:nil
												  cipherKey:@" asdashd asd fsdkl faskd asdkf kasldf "];
	XCTAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:@"chaos.pubnub.com"
												 publishKey:nil
											   subscribeKey:nil
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	XCTAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
												 publishKey:nil
											   subscribeKey:nil
												  secretKey:nil
												  cipherKey:@"enigma"];
	XCTAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:@"enigma"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	XCTAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:nil
												 publishKey:nil
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"enigma"];
	XCTAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
    PNError *helperInitializationError = nil;
	BOOL res;
    
	for( int i=0; i<configurations.count; i++ ) {
        PNCryptoHelper *result = [PNCryptoHelper helperWithConfiguration:[PNConfiguration defaultConfiguration] error:&helperInitializationError];
        
		XCTAssertTrue( result, @"result can be NO");
		XCTAssertNil( helperInitializationError, @"helperInitializationError %@", helperInitializationError);

		for( int j=0; j<strings.count; j++ ) {
			PNError *processingError = nil;
			NSString *encodeString = [result encryptedStringFromString: strings[j] error: &processingError];
			XCTAssertNil( processingError, @"processingError %@", processingError);
			XCTAssertFalse( [strings[j] isEqual: encodeString], @"strings must be not equal");
			processingError = nil;
			NSString *decodeString = [result decryptedStringFromString: encodeString error: &processingError];
			XCTAssertNil( processingError, @"processingError %@", processingError);
			XCTAssertEqualObjects( strings[j], decodeString, @"strings not equal");


            
			NSString *encrypt = [PubNub AESEncrypt: strings[j] error: &processingError];
//			if( encrypt.length > 3 && [[encrypt substringToIndex:1] isEqualToString: @"\""] )
//				encrypt = [encrypt substringWithRange: NSMakeRange(1, encrypt.length-2)];
			NSLog(@"string \n%@", strings[j]);
			NSLog(@"encrypt \n%@", encrypt);
			XCTAssertTrue( encrypt.length > 0 , @"encrypt empty");
			XCTAssertNil( processingError, @"AESEncrypt error, %@", processingError);

			processingError = nil;
			NSString *decrypt = [PubNub AESDecrypt: encrypt error: &processingError];
			NSLog(@"decrypt \n%@", decrypt);
//			if( decrypt.length > 3 && [[decrypt substringToIndex:1] isEqualToString: @"\""] )
//				decrypt = [decrypt substringWithRange: NSMakeRange(1, decrypt.length-2)];
			XCTAssertNil( processingError, @"AESDecrypt error, %@, %@", processingError, strings[j]);
//			if( processingError != nil ) {
//				processingError = nil;
//				NSString *decrypt = [PubNub AESDecrypt: encrypt error: &processingError];
//			}
			if( processingError == nil )
				XCTAssertEqualObjects( strings[j], decrypt, @"AESEncrypt != AESDecrypt (string)");
		}

		for( int j=0; j<objects.count; j++ ) {
			PNError *processingError = nil;
#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
			id encodeObject = [[PNCryptoHelper sharedInstance] encryptedObjectFromObject: objects[j] error: &processingError];
//			NSData *dataEncode = [NSKeyedArchiver archivedDataWithRootObject:encodeObject];
			XCTAssertNil( processingError, @"processingError %@", processingError);
//			XCTAssertFalse( [data isEqualToData: dataEncode], @"objects must be not equal");

			id decodeObject = [[PNCryptoHelper sharedInstance] decryptedObjectFromObject: encodeObject error: &processingError];
			XCTAssertNil( processingError, @"processingError %@", processingError);
			NSData *data	   = [NSKeyedArchiver archivedDataWithRootObject:objects[j]];
			NSData *dataDecode = [NSKeyedArchiver archivedDataWithRootObject:decodeObject];
			res = [objects[j] isEqual:decodeObject];
			if( res == NO ) {
				NSLog(@"isEtalonDictionary Fail \n%@\n%@", data, dataDecode );
				NSLog(@"isEtalonDictionary Fail \n%@\n%@", objects[j], decodeObject );
			}
			XCTAssertTrue( result, @"objects not equal");
#endif

			NSString *encrypt = [PubNub AESEncrypt: objects[j] error: &processingError];
//			if( encrypt.length > 3 && [[encrypt substringToIndex:1] isEqualToString: @"\""] )
//				encrypt = [encrypt substringWithRange: NSMakeRange(1, encrypt.length-2)];
			NSLog(@"encrypt %@", encrypt);
            
			XCTAssertTrue( encrypt.length > 0 , @"encrypt empty");
			XCTAssertNil( processingError, @"AESEncrypt error", processingError);

			processingError = nil;
            id decrypt = [PubNub AESDecrypt:encrypt
                                      error:&processingError];
            
			res = [objects[j] isEqual:decrypt];
			if( result == NO ) {
				NSLog(@"AESEncrypt != AESDecrypt (objects) \n%@\n%@", objects[j], decrypt );
			}
			XCTAssertNil( processingError, @"AESDecrypt error, %@, %@", processingError, objects[j]);
			if( processingError == nil )
				XCTAssertEqualObjects( objects[j], decrypt, @"AESEncrypt != AESDecrypt (objects)");
		}
	}

	configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
												 publishKey:nil
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:nil];
    PNCryptoHelper *result = [PNCryptoHelper helperWithConfiguration:[PNConfiguration defaultConfiguration] error:&helperInitializationError];
	XCTAssertFalse( result, @"result can be YES");
	XCTAssertNotNil( helperInitializationError, @"helperInitializationError %@", helperInitializationError);
}

@end
