//
//  AppDelegate.h
//  pubNubBackgroundMediator
//
//  Created by Valentin Tuller on 9/25/13.
//  Copyright (c) 2013 Valentin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
	NSString *returnToId;
	int afterSeconds;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@end
