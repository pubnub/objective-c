//
//  Configuration.m
//  pubnub
//
//  Created by Valentin Tuller on 11/13/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

// TODO: needs improvement. It practically doesn't test anything.

#import <XCTest/XCTest.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface Configuration : XCTestCase <PNDelegate> {
    
	NSMutableArray *_configurations;
}

@end

@implementation Configuration

- (void)tearDown {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[super tearDown];
}

- (void)setUp {
    [super setUp];

	PNConfiguration *configuration = nil;
	_configurations = [NSMutableArray array];

	configuration = [PNConfiguration configurationForOrigin:@"punsub123.pubnub.com"
												 publishKey:@"sdfga"
											   subscribeKey:@"sadasfsad"
												  secretKey:@"test key"
												  cipherKey:@"my_key"];
	configuration.useSecureConnection = NO;
	[_configurations addObject: configuration];

	configuration = [PNConfiguration configurationForOrigin:@"punsub.pubnub.com"
												 publishKey:@"aasd sad ads"
											   subscribeKey:@"asdfadas asd"
												  secretKey:@"test key"
												  cipherKey:@" asdashd asd fsdkl faskd asdkf kasldf "];
	configuration.useSecureConnection = YES;
	[_configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"punsub1.pubnub.com"
												 publishKey:@"a a as a "
											   subscribeKey:@"a a as a "
												  secretKey:@"test key"
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = NO;
	[_configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
												 publishKey:@"ss s s sdgdaf"
											   subscribeKey:@"aaaaasdfaaaa"
												  secretKey:@"test key"
												  cipherKey:@"enigma"];
	configuration.useSecureConnection = YES;
	[_configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"pubsub2.pubnub.com"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:@"test key"
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = NO;
	[_configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"google.com.ua"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:@"test key"
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = YES;
	[_configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"google.com"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:@"test key"
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = NO;
	[_configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"mail.ru"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:@"test key"
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = YES;
	[_configurations addObject: configuration];

	configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-c-c9b0fe21-4ae1-433b-b766-62667cee65ef" subscribeKey:@"sub-c-d91ee366-9dbd-11e3-a759-02ee2ddab7fe" secretKey: @"sec-c-ZDUxZGEyNmItZjY4Ny00MjJmLWE0MjQtZTQyMDM0NTY2MDVk" cipherKey:@"rwrwrweqrewrwerewrewqrw"];
	[_configurations addObject: configuration];


                     configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey:@"test key" cipherKey:@"fsdafasdfsdaf"];
	[_configurations addObject: configuration];
	
	[_configurations addObject: [PNConfiguration defaultConfiguration]];

	[[NSNotificationCenter defaultCenter] addObserver:self
						   selector:@selector(clientErrorNotification:)
							   name:kPNClientErrorNotification
							 object:nil];
    
    [PubNub setDelegate:self];
}

#pragma mark - Test

- (void)test10Configurations {
    for(PNConfiguration *configuration in _configurations) {
        
        [PubNub setConfiguration:configuration];
        
        if (![[[PubNub sharedInstance] configuration].origin isEqualToString:configuration.origin ]) {
            NSLog(@"1");
        }
        
        XCTAssertEqualObjects([[PubNub sharedInstance] configuration].origin, configuration.origin, @"Origins are not equial: %@ <> %@", [[PubNub sharedInstance] configuration].origin, configuration.origin);
        XCTAssertEqualObjects([[PubNub sharedInstance] configuration].publishKey, configuration.publishKey, @"PublishKeys are not equial");
        XCTAssertEqualObjects([[PubNub sharedInstance] configuration].subscriptionKey, configuration.subscriptionKey, @"SubcriptionKeys are not equial");
        XCTAssertEqualObjects([[PubNub sharedInstance] configuration].cipherKey, configuration.cipherKey, @"CipherKeys are not equial");
    }
}

@end
