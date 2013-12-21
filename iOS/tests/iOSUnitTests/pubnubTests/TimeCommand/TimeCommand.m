//
//  TimeCommand.m
//  pubnub
//
//  Created by Valentin Tuller on 11/6/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNConnection.h"
#import "PNHereNowResponseParser.h"
#import "Swizzler.h"
#import "PNDefaultConfiguration.h"
#import "Swizzler.h"

@interface TimeCommand : SenTestCase <PNDelegate> {
	BOOL _isPNClientConnectionDidFailWithErrorNotification;
	BOOL _isDidDisconnectFromOrigin;
	BOOL _isDidConnectToOrigin;
	BOOL _PNClientDidConnectToOriginNotification;
}

@end

@implementation TimeCommand


- (void)setUp
{
    [super setUp];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidConnectToOriginNotification:)
							   name:kPNClientDidConnectToOriginNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidDisconnectFromOriginNotification:)
							   name:kPNClientDidDisconnectFromOriginNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientConnectionDidFailWithErrorNotification:)
							   name:kPNClientConnectionDidFailWithErrorNotification
							 object:nil];
}

-(void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
	NSLog(@"didConnectToOrigin %@", origin);//3
	_isDidConnectToOrigin = YES;
}

-(void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
	NSLog(@"didDisconnectFromOrigin %@", origin);
	_isDidDisconnectFromOrigin = YES;
}

-(void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
	NSLog(@"didDisconnectFromOrigin %@, withError, %@", origin, error);//2
	_isDidDisconnectFromOrigin = YES;
}

-(void)kPNClientDidConnectToOriginNotification:(NSNotification *)notification {
    NSLog(@"kPNClientDidConnectToOriginNotification");//4
	_PNClientDidConnectToOriginNotification = YES;
}
-(void)kPNClientDidDisconnectFromOriginNotification:(NSNotification *)notification {
    NSLog(@"kPNClientDidDisconnectFromOriginNotification");
}
-(void)kPNClientConnectionDidFailWithErrorNotification:(NSNotification *)notification {
    NSLog(@"kPNClientConnectionDidFailWithErrorNotification");//1
	_isPNClientConnectionDidFailWithErrorNotification = YES;
}

-(void)test10Connection {
	[PubNub resetClient];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block BOOL isCompletionBlockCalled = NO;

	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[PubNub setDelegate:self];
		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];

		[PubNub connectWithSuccessBlock:^(NSString *origin) {
			PNLog(PNLogGeneralLevel, nil, @"\n\n\n\n\n\n\n{BLOCK} PubNub client connected to: %@", origin);
			dispatch_semaphore_signal(semaphore);
			isCompletionBlockCalled = YES;
		}
							 errorBlock:^(PNError *connectionError) {
								 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
								 dispatch_semaphore_signal(semaphore);
								 //								 STFail(@"connectionError %@", connectionError);
								 isCompletionBlockCalled = YES;
							 }];
	});
	for( int j=0; j<kPNConnectionIdleTimeout+10 && isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue(isCompletionBlockCalled, @"Completion block not called");


	_isPNClientConnectionDidFailWithErrorNotification = NO;
	_isDidDisconnectFromOrigin = NO;
	NSLog(@"start swizzle");
	SwizzleReceipt *receipt = [self setOriginLookupResourcePath];
	for( int j=0; j<20; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( _isPNClientConnectionDidFailWithErrorNotification, @"notification not called");
	STAssertTrue( _isDidDisconnectFromOrigin, @"delegate's method not called");

	_isDidConnectToOrigin = NO;
	_PNClientDidConnectToOriginNotification = NO;
	NSLog(@"finish swizzle");
	[Swizzler unswizzleFromReceipt:receipt];
	for( int j=0; j<20; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( _PNClientDidConnectToOriginNotification, @"notification not called");
	STAssertTrue( _isDidConnectToOrigin, @"delegate's method not called");
}


-(SwizzleReceipt*)setOriginLookupResourcePath {
	return [Swizzler swizzleSelector:@selector(originLookupResourcePath)
				 forClass:[PNNetworkHelper class]
						   withBlock:
			^(id self, SEL sel){
				PNLog(PNLogGeneralLevel, nil, @"PNNetworkHelper originLookupResourcePath");
				return @"http://google.com";
			}];
}

@end
