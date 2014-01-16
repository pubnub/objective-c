//
//  AppDelegate.h
//  pubnubDemoExample
//
//  Created by rajat  on 18/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

// Stores reference on PubNub client configuration
@property (nonatomic, strong) PNConfiguration *pubnubConfig;

- (void)initializePubNubClient;

@end
