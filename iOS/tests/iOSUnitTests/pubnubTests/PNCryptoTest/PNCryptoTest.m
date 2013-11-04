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
													   cipherKey:@"enigma"];
	STAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:nil
												 publishKey:nil
											   subscribeKey:nil
												  secretKey:nil
												  cipherKey:@" asdashd asd fsdkl faskd asdkf kasldf "];
	STAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:@"chaos.pubnub.com"
												 publishKey:nil
											   subscribeKey:nil
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	STAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
												 publishKey:nil
											   subscribeKey:nil
												  secretKey:nil
												  cipherKey:@"enigma"];
	STAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:@"enigma"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	STAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
	configuration = [PNConfiguration configurationForOrigin:nil
												 publishKey:nil
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"enigma"];
	STAssertNotNil( configuration, @"configuration can be nil");
	[configurations addObject: configuration];
////
    PNError *helperInitializationError = nil;
	BOOL result;
	for( int i=0; i<configurations.count; i++ ) {
		result = [[PNCryptoHelper sharedInstance] updateWithConfiguration:configurations[i] withError:&helperInitializationError];
		STAssertTrue( result, @"result can be NO");
		STAssertNil( helperInitializationError, @"helperInitializationError %@", helperInitializationError);

		for( int j=0; j<strings.count; j++ ) {
			PNError *processingError = nil;
			NSString *encodeString = [[PNCryptoHelper sharedInstance] encryptedStringFromString: strings[j] error: &processingError];
			STAssertNil( processingError, @"processingError %@", processingError);
			STAssertFalse( [strings[j] isEqual: encodeString], @"strings must be not equal");
			processingError = nil;
			NSString *decodeString = [[PNCryptoHelper sharedInstance] decryptedStringFromString: encodeString error: &processingError];
			STAssertNil( processingError, @"processingError %@", processingError);
			STAssertEqualObjects( strings[j], decodeString, @"strings not equal");


			NSString *encrypt = [PubNub AESEncrypt: strings[j] error: &processingError];
			STAssertTrue( encrypt.length > 0 , @"encrypt empty");
			STAssertNil( processingError, @"AESEncrypt error, %@", processingError);

			processingError = nil;
			NSString *decrypt = [PubNub AESDecrypt: encrypt error: &processingError];
			STAssertNil( processingError, @"AESDecrypt error, %@, %@", processingError, strings[j]);
//			if( processingError != nil ) {
//				processingError = nil;
//				NSString *decrypt = [PubNub AESDecrypt: encrypt error: &processingError];
//			}
			if( processingError == nil )
				STAssertEqualObjects( strings[j], decrypt, @"AESEncrypt != AESDecrypt (string)");
		}
//file://localhost/Users/tuller/work/pubnub%203.5.2/iOS/tests/iOSUnitTests/pubnubTests/PNCryptoTest/PNCryptoTest.m: test failure: -[PNCryptoTest test10updateWithConfiguration] failed: "((processingError) == nil)" should be true. AESDecrypt error, Domain=com.pubnub.pubnub; Code=123; Description="CRYPTO: Input data processing error"; Reason="The crypto helper failed to process input data because of an unknown error"; Fix suggestion="The cryptor stumbled on an unknown error during input data processing."; Associated object=(null), asdvjad  adfa asdkfjlhas half alhkashkf asfdhk1239851239847пывоадфыоафлыва
//file://localhost/Users/tuller/work/pubnub%203.5.2/iOS/tests/iOSUnitTests/pubnubTests/PNCryptoTest/PNCryptoTest.m: test failure: -[PNCryptoTest test10updateWithConfiguration] failed: "((processingError) == nil)" should be true. AESDecrypt error, Domain=com.pubnub.pubnub; Code=123; Description="CRYPTO: Input data processing error"; Reason="The crypto helper failed to process input data because of an unknown error"; Fix suggestion="The cryptor stumbled on an unknown error during input data processing."; Associated object=(null), 12312341#%##$^#^@$^%&^&*:{AD:{X>QW{~{!@{::{AD

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
		for( int j=0; j<objects.count; j++ ) {
			PNError *processingError = nil;
			id encodeObject = [[PNCryptoHelper sharedInstance] encryptedObjectFromObject: objects[j] error: &processingError];
//			NSData *dataEncode = [NSKeyedArchiver archivedDataWithRootObject:encodeObject];
			STAssertNil( processingError, @"processingError %@", processingError);
//			STAssertFalse( [data isEqualToData: dataEncode], @"objects must be not equal");

			id decodeObject = [[PNCryptoHelper sharedInstance] decryptedObjectFromObject: encodeObject error: &processingError];
			STAssertNil( processingError, @"processingError %@", processingError);
			NSData *data	   = [NSKeyedArchiver archivedDataWithRootObject:objects[j]];
			NSData *dataDecode = [NSKeyedArchiver archivedDataWithRootObject:decodeObject];
			result = [objects[j] isEqual: decodeObject];
			if( result == NO ) {
				NSLog(@"isEtalonDictionary Fail \n%@\n%@", data, dataDecode );
				NSLog(@"isEtalonDictionary Fail \n%@\n%@", objects[j], decodeObject );
			}
			STAssertTrue( result, @"objects not equal");

			NSString *encrypt = [PubNub AESEncrypt: objects[j] error: &processingError];
			STAssertTrue( encrypt.length > 0 , @"encrypt empty");
			STAssertNil( processingError, @"AESEncrypt error", processingError);

			processingError = nil;
			id decrypt = [PubNub AESDecrypt: encrypt error: &processingError];
			result = [objects[j] isEqual: decrypt];
			if( result == NO ) {
				NSLog(@"AESEncrypt != AESDecrypt (objects) \n%@\n%@", objects[j], decrypt );
			}
			STAssertNil( processingError, @"AESDecrypt error, %@, %@", processingError, objects[j]);
			if( processingError == nil )
				STAssertEqualObjects( objects[j], decrypt, @"AESEncrypt != AESDecrypt (objects)");
		}
#endif
	}

	configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
												 publishKey:nil
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:nil];
	result = [[PNCryptoHelper sharedInstance] updateWithConfiguration:configuration withError:&helperInitializationError];
	STAssertFalse( result, @"result can be YES");
	STAssertNotNil( helperInitializationError, @"helperInitializationError %@", helperInitializationError);
}

@end
