//
//  AppDelegate.m
//  pubnubDemoExample
//
//  Created by rajat  on 18/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (void)initializePubNubClient {
    
    [PubNub setDelegate:self];
    
    
    // Subscribe for client connection state change
    // (observe when client will be disconnected)
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *error) {
                                                            
                                                            if (!connected && error) {
                                                                
                                                                UIAlertView *infoAlertView = [UIAlertView new];
                                                                infoAlertView.title = [NSString stringWithFormat:@"%@(%@)",
                                                                                       [error localizedDescription],
                                                                                       NSStringFromClass([self class])];
                                                                infoAlertView.message = [NSString stringWithFormat:@"Reason:\n%@\nSuggestion:\n%@",
                                                                                         [error localizedFailureReason],
                                                                                         [error localizedRecoverySuggestion]];
                                                                [infoAlertView addButtonWithTitle:@"OK"];
                                                                [infoAlertView show];
                                                            }
                                                        }];
    
    
    // Subscribe application delegate on subscription updates
    // (events when client subscribe on some channel)
    // Subscribe application delegate on subscription updates
    // (events when client subscribe on some channel)
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
                                                                 withCallbackBlock:^(PNSubscriptionProcessState state,
                                                                                     NSArray *channels,
                                                                                     PNError *subscriptionError) {
                                                                     
                                                                     switch (state) {
                                                                             
                                                                         case PNSubscriptionProcessNotSubscribedState:
                                                                             
                                                                             NSLog(@"{BLOCK-P} PubNub client subscription failed with error: %@",
                                                                                   subscriptionError);
                                                                             break;
                                                                             
                                                                         case PNSubscriptionProcessSubscribedState:
                                                                             
                                                                             NSLog(@"{BLOCK-P} PubNub client subscribed on channels: %@",
                                                                                   channels);
                                                                             break;
                                                                             
                                                                         case PNSubscriptionProcessWillRestoreState:
                                                                             
                                                                             NSLog(@"{BLOCK-P} PubNub client will restore subscribed on channels: %@",
                                                                                   channels);
                                                                             break;
                                                                             
                                                                         case PNSubscriptionProcessRestoredState:
                                                                             
                                                                             NSLog(@"{BLOCK-P} PubNub client restores subscribed on channels: %@",
                                                                                   channels);
                                                                             break;
                                                                     }
                                                                 }];
    
    // Subscribe on message arrival events with block
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {
                                                             
                                                             NSLog(@"{BLOCK-P} PubNubc client received new message: %@",
                                                                   message);
                                                         }];
    
    // Subscribe on presence event arrival events with block
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self
                                                        withBlock:^(PNPresenceEvent *presenceEvent) {
                                                            
                                                            NSLog(@"{BLOCK-P} PubNubc client received new event: %@",
                                                                  presenceEvent);
                                                        }];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
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

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    
    NSLog(@"PubNub client report that error occurred: %@", error);
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
    
    NSLog(@"PubNub client is about to connect to PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    
    NSLog(@"PubNub client successfully connected to PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    
    NSLog(@"PubNub client was unable to connect because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
    
    NSLog(@"PubNub clinet will close connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectWithError:(PNError *)error {
    
    NSLog(@"PubNub client closed connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    
    NSLog(@"PubNub client disconnected from PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
    
    NSLog(@"PubNub client successfully subscribed on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    
    NSLog(@"PubNub client failed to subscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
    
    NSLog(@"PubNub client successfully unsubscribed from channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    
    NSLog(@"PubNub client failed to unsubscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
    
    NSLog(@"PubNub client recieved time token: %@", timeToken);
}

- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
    
    NSLog(@"PubNub client failed to receive time token because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
    
    NSLog(@"PubNub client is about to send message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
    
    NSLog(@"PubNub client failed to send message '%@' because of error: %@", message, error);
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
    
    NSLog(@"PubNub client sent message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    
    NSLog(@"PubNub client received message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
    
    NSLog(@"PubNub client received presence event: %@", event);
}

- (void)pubnubClient:(PubNub *)client
didReceiveMessageHistory:(NSArray *)messages
          forChannel:(PNChannel *)channel
        startingFrom:(NSDate *)startDate
                  to:(NSDate *)endDate {
    
    NSLog(@"PubNub client received history for %@ starting from %@ to %@: %@",
          channel, startDate, endDate, messages);
}

- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {
    
    NSLog(@"PubNub client failed to download history for %@ because of error: %@",
          channel, error);
}

- (void)      pubnubClient:(PubNub *)client
didReceiveParticipantsLits:(NSArray *)participantsList
                forChannel:(PNChannel *)channel {
    
    NSLog(@"PubNub client received participants list for channel %@: %@",
        participantsList, channel);
}

- (void)                     pubnubClient:(PubNub *)client
didFailParticipantsListDownloadForChannel:(PNChannel *)channel
                                withError:(PNError *)error {
    
    NSLog(@"PubNub client failed to download participants list for channel %@ because of error: %@",
          channel, error);
}

- (NSNumber *)shouldResubscribeOnConnectionRestore {
    
    return @(NO);
}

@end
