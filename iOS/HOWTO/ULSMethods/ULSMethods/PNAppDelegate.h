//
//  PNAppDelegate.h
//  ULSMethods
//
//  Created by geremy cohen on 06/07/13.
//  Copyright (c) 2013 PubNub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNViewController;

@interface PNAppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PNViewController *viewController;

@end