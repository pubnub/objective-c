//
//  AppDelegate.m
//  demo9
//
//  Created by geremy cohen on 5/8/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSData *devicePushToken;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#if !TARGET_IPHONE_SIMULATOR
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // Registering for push notifications under iOS8
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        
        // Register for push notifications for pre-iOS8
        UIRemoteNotificationType type = (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
    }
#endif
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"My device token is: %@", deviceToken);
    self.devicePushToken = deviceToken;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSString *message = nil;
    id alert = [userInfo objectForKey:@"aps"];
    if ([alert isKindOfClass:[NSString class]]) {
        
        message = alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        
        message = [alert objectForKey:@"alert"];
    }
    
    if (alert) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                            message:@"is the message."  delegate:self
                                                  cancelButtonTitle:@"Yeah PubNub!"
                                                  otherButtonTitles:@"Cool PubNub!", nil];
        [alertView show];
    }
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    
    NSLog(@"I got a message! : %@", message);
}

@end
