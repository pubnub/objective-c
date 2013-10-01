//
//  AppDelegate.h
//  pubnubBackground
//
//  Created by rajat  on 23/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "MessageQueue.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

- (void) InitializePubNubClient;

- (void) ConnectPubnubClient;

- (void) StartSendLoop;

- (void) SendLoop;

- (void) SetIdleTime: (NSString*)idleTime;

- (void) EndSendLoop;

- (void) Disconnect;

- (void) WriteLog: (NSString *)message isEssential: (bool)isError;

- (void) SubscribeToChannels: (NSString *)channel;

- (void) UnsubscribeToChannels: (NSString *)channel;

// Stores reference on PubNub client configuration
@property (nonatomic, strong) PNConfiguration *pubnubConfig;

// Stores whether client disconnected on network error
// or not
@property (nonatomic, assign, getter = isDisconnectedOnNetworkError) BOOL disconnectedOnNetworkError;

@property (nonatomic, assign, setter = shouldDisplayAllLogs:) BOOL displayAllLogs;

@property (nonatomic, assign, setter = isLoopingOn:, getter = isLoopingOn) BOOL runLoop;

@property (nonatomic, assign, setter = shouldUseAutoNames:, getter = shouldUseAutoNames) BOOL autoChannels;

@property (nonatomic, copy, setter = SetChannels:, getter = GetChannels) NSString * subscribeToChannels;

// Stores reference on current channel
@property (nonatomic, strong) PNChannel *currentChannel;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSMutableDictionary *dictMessageQueue;

@end
