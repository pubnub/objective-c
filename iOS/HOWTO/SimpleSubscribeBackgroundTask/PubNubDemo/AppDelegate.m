//
//  AppDelegate.m
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"


#pragma mark Private interface methods

@interface AppDelegate ()


#pragma mark - Properties

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, copy) void(^backgroundTaskExpirationHandler)(void);


@end


#pragma mark - Public interface methods

@implementation AppDelegate

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    PNLog(PNLogGeneralLevel,self,@"PubNub client received message: %@", message);
}

- (BOOL)shouldRunClientInBackground {
    
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [PubNub setDelegate:self];
    
    if (application.applicationState != UIApplicationStateActive) {
        [self keepApplicationAliveInBackground];
    }
    else {
        
        [self removeApplicationFromBackgroundBackground];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [self keepApplicationAliveInBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self removeApplicationFromBackgroundBackground];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)keepApplicationAliveInBackground {
    
    UIApplication *application = [UIApplication sharedApplication];
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    __block BOOL isBackgroundTaskExpired = NO;
    void(^backgroundTask)(void) = ^{
        
        // Start the long-running task.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // When the job expires it still keeps running since we never exited it. Thus have the expiration handler
            // set a flag that the job expired and use that to exit the while loop and end the task.
            while(application.applicationState != UIApplicationStateActive && !isBackgroundTaskExpired) {
                
                [NSThread sleepForTimeInterval:1];
            }
            
            isBackgroundTaskExpired = NO;
        });
    };
    
    if (self.backgroundTaskExpirationHandler == nil) {
        
        weakSelf.backgroundTaskExpirationHandler = ^{
            
            UIBackgroundTaskIdentifier oldIdentifier = weakSelf.backgroundTaskIdentifier;
            weakSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
            weakSelf.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:weakSelf.backgroundTaskExpirationHandler];
            [application endBackgroundTask:oldIdentifier];
            isBackgroundTaskExpired = YES;
            while (isBackgroundTaskExpired) {
                
                [NSThread sleepForTimeInterval:1.0f];
            }
            backgroundTask();
        };
    }
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:self.backgroundTaskExpirationHandler];
    backgroundTask();
}

- (void)removeApplicationFromBackgroundBackground {
    
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    self.backgroundTaskExpirationHandler = nil;
}

@end