//
//  AppDelegate.m
//  Tutorial1
//
//  Created by gcohen on 5/12/15.
//  Copyright (c) 2015 geremy cohen. All rights reserved.
//

#import "AppDelegate.h"
#import "PubNub.h"
#import "PNResult+Private.h"

@interface AppDelegate () <PNObjectEventListener>
    @property (nonatomic, strong) PubNub *client;
    @property (nonatomic, strong) NSString *channel;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize PubNub client.
    self.channel = @"HelloiOS4.0";
    self.client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    [self.client addListeners:@[self]];

    // Time (Ping) to PubNub Servers
    [self.client timeWithCompletion:^(PNResult *result, PNStatus *status) {
        if (result.data) {
            NSLog(@"Result from Time: %@", result.data);
        }

        if (status.debugDescription)  {
            NSLog(@"Event Status from Time: %@ - Is an error: %@", [status debugDescription], (status.isError ? @"YES" : @"NO"));
        }

    }];

    [self.client subscribeToChannels:@[_channel] withPresence:YES andCompletion:^(PNStatus *status) {
        
        // On initial subscribe connect event
        if (status.category == PNConnectedCategory) {
            
            NSLog(@"Subscribe Connected to %@", status.data[@"channels"]);
            
            [self.client publish:@"I'm here!" toChannel:_channel compressed:YES
                  withCompletion:^(PNStatus *status) {
                    
                if (!status.isError) {
                    
                    NSLog(@"Message sent at TT: %@", status.data[@"tt"]);
                } else {
                    
                    NSLog(@"An error occurred while publishing: %@", status.data[@"information"]);
                    NSLog(@"Because this WILL NOT autoretry (%@), you must manually resend this message again.",
                          (status.willAutomaticallyRetry ? @"YES" : @"NO"));
                }
            }];
         
        }
    }];


    return YES;
}

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message {
    
    NSLog(@"Did receive message: %@", message.data);
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    
    NSLog(@"Did receive presence event: %@", event.data);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    // On expected disconnect. For example, channel changing
    if (status.category == PNDisconnectedCategory) {
        
        NSLog(@"Subscribe disconnected expectedly from %@", status.data[@"channels"]);
    }
    // On unexpected disconnect. For example, Airplane mode turned on, Suspended, Backgrounded
    else if (status.category == PNUnexpectedDisconnectCategory) {
        
        NSLog(@"Subscribe disconnected unexpectedly from %@", status.data[@"channels"]);
    }
    // When reconnecting from an unexpected disconnect (airplane mode disabled, resuming from foreground)
    else if (status.category == PNReconnectedCategory) {
        
        NSLog(@"Subscribe reconnected to %@", status.data[@"channels"]);
    }
    // !!!: This case almost impossible for subscrib/unsubscribe events.
    // When receiving malformed / Non-JSON
    else if (status.category == PNMalformedResponseCategory) {
        
        NSLog(@"Bad JSON. Is error? %@, It will autoretry (%@)",
              (status.isError ? @"YES" : @"NO"),
              (status.willAutomaticallyRetry ? @"YES" : @"NO"));
        
        // If willAutomaticallyRetry is 'NO' then it is possible manually relaunch request
        // using: [status retry];

    }
    // When receiving a 403
    else if (status.category == PNAccessDeniedCategory) {
        
        NSLog(@"PAM Access Denied against channel %@ -- it will autoretry: %@",
              status.data[@"channels"], (status.willAutomaticallyRetry ? @"YES" : @"NO"));
        NSLog(@"In the meantime, you may wish to change the autotoken or unsubscribe from the channel in question.");
        
        // Retry attempts can be canceled with this code: [status cancelAutomaticRetry];
    }
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
