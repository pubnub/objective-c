//
//  AppDelegate.h
//  demo9
//
//  Created by geremy cohen on 5/8/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>

@property (strong, nonatomic) UIWindow *window;
@property NSString *apnsID;
@property NSData *dToken;

@end
