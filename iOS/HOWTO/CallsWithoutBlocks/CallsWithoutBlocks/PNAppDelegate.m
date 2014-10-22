//
//  PNAppDelegate.m
//  CallsWithoutBlocks
//
//  Created by geremy cohen on 06/04/13.
//  Copyright (c) 2013 PubNub. All rights reserved.
//

#import "PNAppDelegate.h"
#import "PNViewController.h"
#import "PNMessage+Protected.h"
#import "PNPresenceEvent.h"
#import "PNPresenceEvent+Protected.h"

@implementation PNAppDelegate

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {

    NSLog(@"MESSAGE: %@", [NSString stringWithFormat:@"received: %@", message.message]);

}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
    //PNLog(PNLogGeneralLevel, self, @"PubNub client received presence event: %@", event);
    //NSLog(event);

    NSLog(@"Received presence event %@ on channel %@", event.description, event.channel.name);

}

- (void)pubnubClient:(PubNub *)client didReceiveParticipantsList:(NSArray *)participantsList forChannel:(PNChannel *)channel {
    NSLog(@"hereNow on channel: %@! %@", channel.name, participantsList);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[PNViewController alloc] initWithNibName:@"PNViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];


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

@end