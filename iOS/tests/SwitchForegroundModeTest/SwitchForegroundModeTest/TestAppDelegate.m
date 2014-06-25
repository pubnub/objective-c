//
//  TestAppDelegate.m
//  SwitchForegroundModeTest
//
//  Created by Vadim Osovets on 6/24/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import "TestAppDelegate.h"
#import "GCDWrapper.h"

@implementation TestAppDelegate {
    dispatch_group_t _syncGroup;
    PNChannel *_channel;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [UIViewController new];
    
    // initialize PubNub client
    
    [PubNub setDelegate:self];
    
    _syncGroup = dispatch_group_create();
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self test];
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Test

- (void)test {
    /*
     Scenario of tests:
     
     Subscribe to several channels.
     Sending messages non-stop.
     
     Make sure that all completion blocks are called for postponed messages.
     */
    
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"presence-beta.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey:nil
                                                                   cipherKey:nil authorizationKey:nil];
    
    configuration.useSecureConnection = NO;
    
    [PubNub setConfiguration:configuration];
    
    dispatch_group_enter(_syncGroup);
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        PNLog(PNLogGeneralLevel, nil, @"\n{BLOCK} PubNub client connected to: %@", origin);
        dispatch_group_leave(_syncGroup);
    }
                         errorBlock:^(PNError *connectionError) {
                             dispatch_group_leave(_syncGroup);
                             NSLog(@"connectionError %@", connectionError);
                         }];
    
    [GCDWrapper waitGroup:_syncGroup];
    NSLog(@"1.1 Connected successfully");
    
    // create channel
    _channel = [PNChannel channelWithName:@"iosdev_postponed_messages"];
    
    dispatch_group_enter(_syncGroup);
    
    [PubNub subscribeOnChannel:_channel
               withClientState:nil
    andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        if (!error) {
            if (state == PNSubscriptionProcessSubscribedState) {
                dispatch_group_leave(_syncGroup);
            }
        } else {
            NSAssert(YES, @"Error during subscription to channel.");
        }
    }];
    
    [GCDWrapper waitGroup:_syncGroup];
    
    [self sendMessages];
}

- (void)sendMessages {
    for (int i = 0; i < 100; i++) {
        
        NSString *messageBody = [NSString stringWithFormat:@"message: %d", i];
        
        dispatch_group_enter(_syncGroup);
        
        [PubNub sendMessage:messageBody
                  toChannel:_channel
        withCompletionBlock:^(PNMessageState state, id message) {
            
            if (state == PNMessageSent) {
                NSLog(@"Message: %@", message);
                
                NSString *assertMessage = [NSString stringWithFormat:@"Messages are not equal: %@ <> %@", messageBody, [(PNMessage *)message message]];
                
                NSAssert(![messageBody isEqualToString:[(PNMessage *)message  message]], assertMessage);
                
                dispatch_group_leave(_syncGroup);
            }
        }];
    }
    
    [GCDWrapper waitGroup:_syncGroup
               withTimout:60];
    
    // sleep before next cycle
    [GCDWrapper sleepForSeconds:3];
    
    [self sendMessages];
}

#pragma mark - PubNub Delegates

- (void)pubnubClient:(PubNub *)client willSuspendWithBlock:(void(^)(void(^)(void(^)(void))))preSuspensionBlock {
    
    if ([PubNub sharedInstance].isConnected) {
        
        preSuspensionBlock(^(void(^completionBlock)(void)){
            
            int64_t delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                
                [PubNub sendMessage:@"Hello my friend" toChannel:[PNChannel channelWithName:@"boom"]
                withCompletionBlock:^(PNMessageState state, id data) {
                    
                    if (state != PNMessageSending) {
                        
                        NSString *message = @"Message has been sent";
                        if (state == PNMessageSendingError) {
                            
                            message = [NSString stringWithFormat:@"Message sending failed with error: %@", ((PNError *)data).localizedFailureReason];
                        }
                        [PNLogger logGeneralMessageFrom:self message:^NSString *{
                            
                            return message;
                        }];
                        completionBlock();
                    }
                }];
            });
        });
    }
}

@end
