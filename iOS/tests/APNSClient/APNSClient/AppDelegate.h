//
//  AppDelegate.h
//  APNSClient
//
//  Created by Vadim Osovets on 9/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>

@property (strong, nonatomic) UIWindow *window;

@property NSData *deviceToken;

@end

