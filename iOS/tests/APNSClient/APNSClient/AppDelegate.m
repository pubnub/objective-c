//
//  AppDelegate.m
//  APNSClient
//
//  Created by Vadim Osovets on 9/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    // TODO: for feature usage
//    UIMutableUserNotificationAction* acceptLeadAction = [[UIMutableUserNotificationAction alloc] init];
//    acceptLeadAction.identifier = @"Accept";
//    acceptLeadAction.title = @"Accept";
//    acceptLeadAction.activationMode = UIUserNotificationActivationModeForeground;
//    acceptLeadAction.destructive = false;
//    acceptLeadAction.authenticationRequired = false;
//    
//    UIMutableUserNotificationCategory* category = [[UIMutableUserNotificationCategory alloc] init];
//    category.identifier = @"category_with_large_payload";
//    [category setActions:@[acceptLeadAction] forContext: UIUserNotificationActionContextDefault];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                         |UIUserNotificationTypeSound
                                                                                         |UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    [PubNub setDelegate:self];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - APNS

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"DELEGATE: Device Token is: %@", deviceToken);
    
    self.deviceToken = deviceToken;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    //register to receive notifications
    [application registerForRemoteNotifications];
}

#pragma mark - PubNub's pushes

// #5 Process received push notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *message = nil;
    id alert = [userInfo objectForKey:@"aps"];
    if ([alert isKindOfClass:[NSString class]]) {
        message = alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        message = [alert objectForKey:@"alert"];
    }
    if (alert) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                            message:@"Sent Via PubNub Mobile Gateway."  delegate:self
                                                  cancelButtonTitle:@"Thanks PubNub!"
                                                  otherButtonTitles:@"Send Me More!", nil];
        [alertView show];
    }
}

// #6 Add PubNub delegate to catch when channel in enabled with APNs
- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {
    
    // This delegate method is called if push notifications for all channels are successfully enabled.
    // “channels” will contain the array of channels which have push notifications enabled.
    
    NSLog(@"DELEGATE: Enabled push notifications on channels: %@", channels);
    
}

// #7 Add PubNub delegate to catch when apns receives a push notification for a channel
- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {
    
    // This delegate method is called when the client successfully receives push notifications for a channel.
    // “channels” will contain the array of channels which received push notifications.
    
    NSLog(@"DELEGATE: Received push notifications for these enabled channels: %@", channels);
}

// #8 Add PubNub delegate to catch when client fails to enable apns for channel
- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
    
    // This delegate method is called when an error occurs on enabling push notifications for all channels.
    // “error” will contain the details of the error.
    
    NSLog(@"DELEGATE: Failed push notification enable. error: %@", error);
    
}

// #9 Add PubNub delegate to catch when apns is disabled for a channel (optional)
- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {
    
    // This delegate method is called when push notifications for all channels are successfully disabled.
    // “channels” will contain the array of channels which have push notifications disabled.
    
    NSLog(@"DELEGATE: Disabled push notifications on channels: %@", channels);
}

// #10 Add PubNub delegate to catch when apns fails to be disabled for a channel (optional)
- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
    
    
    // This delegate method is called when an error occurs on disabling push notifications for all channels.
    // “error” will contain the details of the error.
    
    NSLog(@"DELEGATE: Failed to disable push notifications because of error: %@", error);
}

// #11 Add PubNub delegate to catch when apns disabled for all channels (optional)
- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {
    
    //This delegate method is called when push notifications for all channels are successfully removed.
    
    NSLog(@"DELEGATE: Removed push notifications from all channels");
}

// #12 Add delegate to catch when apns fails to be disabled for channels (optional)
- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {
    
    // This delegate method is called when an error occurs on removing push notifications for all channels.
    // “error” will contain the details of the error.
    
    NSLog(@"DELEGATE: Failed remove push notifications from channels because of error: %@",error);
}

// #13 Add PubNub delegate to catch when apns fails to receive a push notification for some reason (optional)
- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {
    
    // This delegate method is called when the client fails to receive push notifications for a channel.
    // “error” will contain the details of the error.
    NSLog(@"DELEGATE: Failed to receive list of channels because of error: %@", error);
}

@end
