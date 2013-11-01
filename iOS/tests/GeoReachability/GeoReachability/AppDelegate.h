//
//  AppDelegate.h
//  GeoReachability
//
//  Created by Valentin Tuller on 10/14/13.
//  Copyright (c) 2013 Valentin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, PNDelegate> {
	CLLocationManager *locationManager;
	BOOL isInBackground;
}

@property (strong, nonatomic) UIWindow *window;

@end
