//
//  PNBackgroundAppDelegate.h
//  pubnub
//
//  Created by Valentin Tuller on 9/24/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface PNBackgroundAppDelegate : UIResponder <UIApplicationDelegate, PNDelegate, CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	PNChannel *pnChannel;
	NSArray *messages;
	int numberMessage;
	UITextView *tbxLog;
	NSTimer *timerReset;

	int numberConfiguration;
	int timeout;
}



#pragma mark Properties

@property (nonatomic, strong) UIWindow *window;
@property NSString *lastTimeToken;
@property NSString *lastClientIdentifier;

#pragma mark -


@end
