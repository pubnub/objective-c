//
//  AppDelegate.h
//  PubNubDemo
//
//  Created by Jiang ZC on 2/21/13.
//  Copyright (c) 2013 JiangZC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
