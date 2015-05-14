//
//  AppDelegate.m
//  ClientTest
//
//  Created by Sergey Mamontov on 5/2/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "PubNub.h"

@interface AppDelegate () <PNObjectEventListener>

@property (nonatomic, strong) PubNub *client;

@end

@implementation AppDelegate

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message {
    
    NSLog(@"NEW MESSAGE: %@", message.data);
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    
    NSLog(@"PRESENCE EVENT: %@", event.data);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    NSLog(@"STATUS: %@", [status debugDescription]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Initialize PubNub client.
    self.client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    
    // Time
    [self.client timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        NSLog(@"Time: %@ (status: %@)", [result data], [status debugDescription]);
    }];
    
    // Message publish (compressed/not compressed and with 'cipherKey' from above encrypted)
    [self.client publish:@{@"Hello":@"world"} toChannel:@"HelloPubNub"
          withCompletion:^(PNStatus *status) {
              
              NSLog(@"Publish status: %@", [status debugDescription]);
          }];
    [self.client publish:@{@"I should":@"be compressed"} toChannel:@"HelloPubNub" compressed:YES
          withCompletion:^(PNStatus *status) {
              
              NSLog(@"Publish compressed status: %@", [status debugDescription]);
          }];
    
    // History (also decrypt messages from history)
    NSNumber *startDate = @(((NSUInteger)[[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970])*10000000);
    NSNumber *endDate = @(((NSUInteger)[[NSDate date] timeIntervalSince1970])*10000000);
    [self.client historyForChannel:@"HelloPubNub" start:startDate end:endDate includeTimeToken:YES
                    withCompletion:^(PNResult *result, PNStatus *status) {
                        
                        NSLog(@"History: %@ (status: %@)", [result data], [status debugDescription]);
                    }];
    
    // Client state manipulation (also available for channel group)
    [self.client setState:@{@"Very important":@"data"} forUUID:self.client.uuid
                onChannel:@"HelloPubNub" withCompletion:^(PNStatus *status) {
                    
                    NSLog(@"State update status: %@", [status debugDescription]);
                }];
    [self.client stateForUUID:self.client.uuid onChannel:@"HelloPubNub"
               withCompletion:^(PNResult *result, PNStatus *status) {
                   
                   NSLog(@"State fetch: %@ (status: %@)", [result data], [status debugDescription]);
               }];
    
    // APNS
    NSData *token = [@"00000000000000000000000000000000" dataUsingEncoding:NSUTF8StringEncoding];
    [self.client addPushNotificationsOnChannels:@[@"PubNub-Push1",@"PubNub-Push2"]
                            withDevicePushToken:token andCompletion:^(PNStatus *status) {
                                
                                NSLog(@"APNS enable status: %@", [status debugDescription]);
                            }];
    [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:token
                                                         andCompletion:^(PNResult *result, PNStatus *status) {
                                                             
                                                             NSLog(@"APNS enabled: %@ (status: %@)", [result data], [status debugDescription]);
                                                         }];
    [self.client removePushNotificationsFromChannels:@[@"PubNub-Push2"] withDevicePushToken:token
                                       andCompletion:^(PNStatus *status) {
                                           
                                           NSLog(@"APNS disable status: %@", [status debugDescription]);
                                       }];
    
    // Channel group
    [self.client addChannels:@[@"PubNub-fcg",@"PubNub-fcg"] toGroup:@"PubNub-cg"
              withCompletion:^(PNResult *result, PNStatus *status) {
                  
                  NSLog(@"Channel group channels list change: %@ (status: %@)", [result data], status);
              }];
    [self.client channelsForGroup:@"PubNub-cg" withCompletion:^(PNResult *result, PNStatus *status) {
        
        NSLog(@"Channel group channels audit: %@ (status: %@)", [result data], [status debugDescription]);
    }];
    
    // Presence
    [self.client hereNowData:PNHereNowUUID withCompletion:^(PNResult *result, PNStatus *status) {
        
        NSLog(@"Global here now: %@ (status: %@)", [result data], [status debugDescription]);
    }];
    
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

@end
