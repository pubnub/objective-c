//
//  PNAppDelegate.m
//  SubUnsubStressTest
//
//  Created by Vadim Osovets on 4/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import "PNAppDelegate.h"
#import "PubNub+Protected.h"
#import "GCDWrapper.h"

static const NSInteger kTimeout = 6;

@implementation PNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PubNub setDelegate:self];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
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

#pragma mark - Test suite

- (void)test {
    NSLog(@"\t1.1 Start");
    // start test sub-unsub case
    
    // connect
    [PubNub disconnect];
    
    dispatch_group_t resGroup = dispatch_group_create();
    
//    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"sub-c-6dc508c0-bff0-11e3-a219-02ee2ddab7fe" subscribeKey:@"pub-c-12b1444d-4535-4c42-a003-d509cc071e09" secretKey:nil
//                                                                   cipherKey:nil authorizationKey:nil];
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo-36" subscribeKey:@"demo-36" secretKey:nil
                                                                   cipherKey:nil authorizationKey:nil];
    
//    configuration.presenceHeartbeatTimeout = 20;
//    configuration.presenceHeartbeatInterval = 20;
    configuration.useSecureConnection = NO;
    
    [PubNub setConfiguration:configuration];
    
    dispatch_group_enter(resGroup);
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        PNLog(PNLogGeneralLevel, nil, @"\n{BLOCK} PubNub client connected to: %@", origin);
        dispatch_group_leave(resGroup);
    }
                         errorBlock:^(PNError *connectionError) {
                             dispatch_group_leave(resGroup);
                             NSLog(@"connectionError %@", connectionError);
                         }];
    
    [GCDWrapper waitGroup:resGroup];
    NSLog(@"1.1 Subscribed successfully");
    
    // create channel
    PNChannel *channel = [PNChannel channelWithName:@"iosdev_sub_unsub_test"];
    
    for (NSUInteger i = 0; i < 5; i++) {
        // initialize state dictionary
        NSDictionary *clientState = @{@"client": @"iosdev",
                                      @"subscribe number": @(i)};
        
        //subsribe with state
        dispatch_group_enter(resGroup);
        
        [PubNub subscribeOnChannel:channel
                   withClientState:clientState
        andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
            
            NSLog(@"1.2:%ld Subscribed with state: %@ error: %@", i, clientState, subscriptionError);
            
            dispatch_group_leave(resGroup);
        }];
        
        [GCDWrapper waitGroup:resGroup
                   withTimout:kTimeout];
        
        NSLog(@"1.3 Request state");
        //request state
        
        dispatch_group_enter(resGroup);
        
		[PubNub requestClientState:[PubNub sharedInstance].clientIdentifier
                        forChannel:channel
       withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
           
           NSLog(@"1.4:%ld client.data channel %@\nexpect state %@, \n%@", i, client.data, clientState, channel.name);
           
           if (![client.data isEqualToDictionary:clientState]) {
               NSLog(@"1.4.1:%ld Error!", i);
           }
           
           dispatch_group_leave(resGroup);
       }];
        
        [GCDWrapper waitGroup:resGroup
                   withTimout:kTimeout];
        
        //unsubscribe
        dispatch_group_enter(resGroup);
        
        [PubNub unsubscribeFromChannel:channel withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
            
            if (error == nil) {
                
                // PubNub client successfully unsubscribed from specified channels.
                NSLog(@"1.5:%ld Successfully unsubscribed from channel: %@ with state: %@", i, [channel name], clientState);
            }
            else {
                
                // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
                //
                // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
                // unsubscribe.
            }
            
            dispatch_group_leave(resGroup);
            
            [GCDWrapper waitGroup:resGroup
                       withTimout:kTimeout];
            
            NSLog(@"BEFORE sleep: %ld", i);
            [GCDWrapper sleepForSeconds:10];
            NSLog(@"AFTER sleep: %ld", i);
        }];
    }
    
    [PubNub disconnect];
    
    NSLog(@"\t2. End");
}

@end
