//
//  AppDelegate.m
//  CheckingBackgroundTransition
//
//  Created by Sergey Kazanskiy on 3/23/15.
//  Copyright (c) 2015 PubNub. All rights reserved.
//

#import "AppDelegate.h"

#import <PubNub/PNImports.h>

// in second
static NSUInteger kDelayBeforeTestStart = 1;
static NSString *kTestURL = @"https://www.google.com.ua";
static NSString *kTestChannelName = @"channel1";

@interface AppDelegate () <PNDelegate> {
    PNChannel *_testChannel;
    PubNub *_client;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _testChannel = [PNChannel channelWithName:@"channel1"];
    _client = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    [_client connectWithSuccessBlock:^(NSString *origin) {
        
        [_client sendMessage:@"Hello" toChannel:_testChannel];
    } errorBlock:^(PNError *error) {
        
        if (error) {
            
            NSLog(@"%@", error);
        }
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


// Message
- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayBeforeTestStart * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Methode openURL send application to background.
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTestURL]];
    });
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
    
    NSLog(@"%@", error);
}


// Background
- (BOOL)shouldRunClientInBackground {
    
    return NO;
}

- (void)pubnubClient:(PubNub *)client willSuspendWithBlock:(void (^)(void (^)(void (^)(void))))preSuspensionBlock {

    NSLog(@"Test successful, willSuspendWithBlock is called.");
}

@end
