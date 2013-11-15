//
//  AppDelegate.h
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestMusicPlayer.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PNDelegate> {
	TestMusicPlayer *musicPlayer;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
