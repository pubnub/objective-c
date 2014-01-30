//
//  AppDelegate.m
//  pubNubBackgroundMediator
//
//  Created by Valentin Tuller on 9/25/13.
//  Copyright (c) 2013 Valentin. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	NSLog(@"launchOptions %@", launchOptions);
	[[UIApplication sharedApplication] setIdleTimerDisabled: YES];

	MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
	masterViewController.navigationItem.title = @"Mediator";
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
	self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

	return YES;
}

-(void)openUrl {
	if( returnToId != nil )
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@://", returnToId]]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	NSLog(@"openURL %@, %@, %@", url, sourceApplication, annotation);
	NSString *parameterString = [[[url absoluteString] componentsSeparatedByString: @"://?"] objectAtIndex: 1];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *param in [parameterString componentsSeparatedByString:@"&"]) {
		NSArray *elts = [param componentsSeparatedByString:@"="];
		if([elts count] < 2)
			continue;
		[params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
	}
	NSLog(@"params %@", params);
	afterSeconds = [params[@"afterSeconds"] intValue];
	returnToId = params[@"returnToId"];
	[self performSelector: @selector(openUrl) withObject: nil afterDelay: afterSeconds];
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

//	[self performSelector: @selector(openUrl) withObject: nil afterDelay: afterSeconds];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
