//
//  AppDelegate.m
//  pubnubBackground
//
//  Created by rajat  on 23/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//
    
#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

NSString *idleTimeVal = @"10";

bool displayLogs = false;

NSString *longitude = @"";

NSString *latitude = @"";

NSString *address = @"";

const int noOfChannels =3;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                     UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];
    
    self.dictMessageQueue = [[NSMutableDictionary alloc] init];
    displayLogs = true;
    
    return YES;
}

- (void) WriteLog: (NSString *)message isEssential: (bool)isEssential{
    PNLog(PNLogGeneralLevel, self, message);

    bool displayLog = true;
    if(!self.displayAllLogs && !isEssential){
        displayLog = false;
    }
    
    if(displayLog){
        NSLog(@"%@",message);
        if(displayLogs){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewController DisplayInLog: message];
            });
        }
    }
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
    displayLogs = false;
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;

    if ([device respondsToSelector:@selector(isMultitaskingSupported)])
        backgroundSupported = device.multitaskingSupported;
    
    if(backgroundSupported) {
        [self WriteLog:@"running in bg mode" isEssential:NO];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self WriteLog:@"running in fg mode" isEssential:NO];
    displayLogs = true;
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

- (void)SetIdleTime: (NSString*)idleTime{
    idleTimeVal = idleTime;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currentLocation = [self.locationManager location];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    latitude =[NSString stringWithFormat:@"%f",  currentLocation.coordinate.latitude];
    longitude =[NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            // Pick the best out of the possible placemarks
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *addressString = [placemark name];
            address = addressString;
        }
    }];
}


- (void)SendLoop{
    UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    }];

    NSMutableArray *channels =  [[NSMutableArray alloc] init];
  
    if(self.shouldUseAutoNames){
        for (int i=0; i< noOfChannels; i++){
            int r = arc4random()/100000;
            NSString * strChName = [NSString stringWithFormat:@"testCh%u", r];
            [channels addObject:strChName];
        }
    } else {
        NSString *newChannelString = [self GetChannels];

        NSString *newTrimmedString = [newChannelString stringByReplacingOccurrencesOfString:@" " withString:@""];

        NSArray *nsa = [[NSArray alloc] initWithArray:[newTrimmedString componentsSeparatedByString:@","]];
        channels = [nsa mutableCopy];
        NSLog(@"Custom Channels: %@", channels);
    }
    
    //subscribe
    for(int i=0; i<[channels count]; i++){
        NSLog(@"Subscribing to: %@", [channels objectAtIndex:i]);
        [self.dictMessageQueue setObject:[[MessageQueue alloc] init] forKey:[channels objectAtIndex:i]];
        [self SubscribeToChannels: [channels objectAtIndex:i]];
    }
    
    int iCount =0;
    while (self.runLoop) {
        iCount++;
        @autoreleasepool{
            //send
            for(int i=0; i<[channels count]; i++){
                @try{
                    NSString *channel = [channels objectAtIndex:i];
                    if([channel length]>0){
                        [self WriteLog:[NSString stringWithFormat:@"sending message '%d' on channel '%@'", iCount, channel] isEssential:YES];

                        PNChannel *ch = [PNChannel channelWithName:channel
                                             shouldObservePresence:NO];
                        NSMutableString *messageToPublish = [NSString stringWithFormat:@""];
                        
                        if(!displayLogs){
                            messageToPublish = [NSString stringWithFormat:@"\"Current location:  lat: %@, long: %@, address: %@\"", latitude, longitude, address];
                            [PubNub sendMessage:messageToPublish toChannel:ch];
                            id anObject = [self.dictMessageQueue objectForKey:channel];
                            [anObject enqueue:messageToPublish];
                        }
                        NSDate *date = [NSDate date];
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        NSTimeZone *zone = [NSTimeZone localTimeZone];
                        [formatter setTimeZone:zone];
                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

                        messageToPublish = [NSString stringWithFormat:@"test message %d, dt: %@", iCount, [formatter stringFromDate:date]];
                        id anObject = [self.dictMessageQueue objectForKey:channel];
                        [anObject enqueue:messageToPublish];
                        [PubNub sendMessage:messageToPublish toChannel:ch];
                    }
                } @catch (NSException * e) {
                    [self WriteLog: [NSString stringWithFormat:@"Exception: %@", e] isEssential:NO];
                    [self WriteLog: [NSString stringWithFormat:@"Stack trace: %@", [e callStackSymbols]] isEssential:NO];
                }
            }
        }
        
        int val = [[idleTimeVal stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue];
        [NSThread sleepForTimeInterval: val];
    }
    //unsubscribe
    
    for(int i=0; i<[channels count]; i++){
        [self UnsubscribeToChannels: [channels objectAtIndex:i]];
    }
    
    [NSThread exit];
    
    if (bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    }
}

- (void) UnsubscribeToChannels: (NSString *)channelToUnsub{
    if([channelToUnsub length]>0){
        PNChannel *channel = [PNChannel channelWithName:channelToUnsub];
        [PubNub unsubscribeFromChannel:channel withCompletionHandlingBlock:^(NSArray *channels, PNError *subscriptionError){
            NSString *alertMessage = [NSString stringWithFormat:@"Unsubscribed channel: %@",
                                      channelToUnsub];
            if(subscriptionError != nil){
                alertMessage = [NSString stringWithFormat:@"Unsubscribe error : %@, %@",
                                channelToUnsub, subscriptionError.description];
            }
            [self WriteLog: alertMessage isEssential:YES];
            [self.viewController ShowChannelInLabel: channel.name bRemove:YES];
        }];
    }
}

-(void) SubscribeToChannels: (NSString *)channel{
    if([channel length]>0){
        self.currentChannel = [PNChannel channelWithName:channel
                                   shouldObservePresence:NO];
        [self WriteLog:[NSString stringWithFormat:@"currentChannel:%p", channel] isEssential:NO];
        
        [PubNub subscribeOnChannel:self.currentChannel withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
            
            NSString *alertMessage = [NSString stringWithFormat:@"Subscribed on channel: %@",
                                      channel];
            if (state == PNSubscriptionProcessNotSubscribedState) {
                
                alertMessage = [NSString stringWithFormat:@"Failed to subscribe on: %@", channel];
                [self WriteLog: alertMessage isEssential:YES];
            } else if (state == PNSubscriptionProcessSubscribedState) {
                if(displayLogs){
                    NSLog(@"TextStatus: %@", alertMessage);
                    [self WriteLog: alertMessage isEssential:YES];
                    [self.viewController ShowChannelInLabel: channel bRemove:NO];
                } else {
                    [self WriteLog: alertMessage isEssential:YES];
                }
            }
        }];
    }
}

- (void) Disconnect{
    [PubNub disconnect];
    
    [[PNObservationCenter defaultCenter] removeChannelParticipantsListProcessingObserver:self];
    [[PNObservationCenter defaultCenter] removeTimeTokenReceivingObserver:self];
    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self];
    [[PNObservationCenter defaultCenter] removeChannelParticipantsListProcessingObserver:self];
    [[PNObservationCenter defaultCenter] removePresenceEventObserver:self];
    [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
    [[PNObservationCenter defaultCenter] removePresenceEventObserver:self];
}


- (void)EndSendLoop{
    self.runLoop = false;
}

- (void) InitializePubNubClient {
    
    [PubNub setDelegate:self];
    
    // Subscribe for client connection state change
    // (observe when client will be disconnected)
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *error) {
                                                            
                                                            if (!connected && error) {
                                                                NSString *str = [NSString stringWithFormat:@"Error:%@",
                                                                                 [error localizedDescription]];
                                                                
                                                                [self WriteLog:str isEssential:YES];
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
                                                                             
                                                                             [self WriteLog: [NSString stringWithFormat:
                                                                                                  @"{BLOCK-P} PubNub client subscription failed with error: %@",
                                                                                                  subscriptionError] isEssential:YES];
                                                                             break;
                                                                             
                                                                         case PNSubscriptionProcessSubscribedState:
                                                                             
                                                                             break;
                                                                             
                                                                         case PNSubscriptionProcessWillRestoreState:
                                                                             
                                                                             [self WriteLog: [NSString stringWithFormat:
                                                                                                  @"{BLOCK-P} PubNub client will restore subscribed on channels: %@",
                                                                                                  channels] isEssential:YES];
                                                                             break;
                                                                             
                                                                         case PNSubscriptionProcessRestoredState:
                                                                             
                                                                             [self WriteLog: [NSString stringWithFormat:
                                                                                                  @"{BLOCK-P} PubNub client restores subscribed on channels: %@",
                                                                                                  channels] isEssential:YES];
                                                                             break;
                                                                     }
                                                                 }];
    
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {
                                                             
                                                            @try {
                                                             id anObject = [self.dictMessageQueue objectForKey:message.channel.name];
                                                             
                                                             NSObject *obj= [anObject dequeue];
                                                             if(obj != Nil){
                                                                 NSString *m =[NSString stringWithFormat:@"%@",obj];
                                                                 
                                                                 NSString *j = message.message;

                                                                 if([j isEqualToString:m]){
                                                                     
                                                                     [self WriteLog: [NSString stringWithFormat:@"Message matched '%@' on channel '%@'", m, message.channel.name] isEssential:YES];
                                                                     
                                                                 }else{
                                                                     
                                                                     [self WriteLog: [NSString stringWithFormat:@"Message match failed, clearing stack Expected:'%@', Got:'%@' on channel '%@'", j, m, message.channel.name] isEssential:YES];
                                                                     [anObject clear];
                                                                     
                                                                 }
                                                             }
                                                            }
                                                             @catch (NSException * e) {
                                                                 [self WriteLog: [NSString stringWithFormat:@"Exception: %@", e] isEssential:NO];                                                                 [self WriteLog: [NSString stringWithFormat:@"Stack trace: %@", [e callStackSymbols]] isEssential:NO];
                                                            }
                                                             
                                                             [self WriteLog: [NSString stringWithFormat:@"[CH: %@]: %@",message.channel.name, message.message] isEssential:NO];
                                                         }];
}

-(void) ConnectPubnubClient {
    self.pubnubConfig = [PNConfiguration defaultConfiguration];
    NSLog(@"%@", self.pubnubConfig);
    [PubNub setConfiguration:self.pubnubConfig];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [self WriteLog: [NSString stringWithFormat:@"{BLOCK} PubNub client connected to: %@", origin] isEssential:YES];
    }
     // In case of error you always can pull out error code and
     // identify what is happened and what you can do
     // (additional information is stored inside error's
     // localizedDescription, localizedFailureReason and
     // localizedRecoverySuggestion)
                         errorBlock:^(PNError *connectionError) {
                             if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
                                 [self WriteLog: [NSString stringWithFormat:@"Connection will be established as soon as internet connection will be restored"] isEssential:NO];
                             }

                             NSString *str = [NSString stringWithFormat:@"Error:\n%@\n, %@, error: %@, Suggestion:\n%@",
                                              [connectionError localizedDescription],
                                              NSStringFromClass([self class]),
                                              [connectionError localizedFailureReason],
                                              [connectionError localizedRecoverySuggestion]];
                             
                             [self WriteLog: str isEssential:NO];
                         }];
}

- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client enabled push notifications on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed push notification enable because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client disabled push notifications on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable push notifications because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received push notificatino enabled channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive list of channels because of error: %@", error);
}

- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client removed push notifications from all channels");
}

- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed remove push notifications from channels because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client report that error occurred: %@", error);
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
    
    
    if (self.isDisconnectedOnNetworkError) {
        
        PNLog(PNLogGeneralLevel, self, @"PubNub client trying to restore connection to PubNub origin at: %@", origin);
    }
    else {
        
        PNLog(PNLogGeneralLevel, self, @"PubNub client is about to connect to PubNub origin at: %@", origin);
    }
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    
    if (self.isDisconnectedOnNetworkError) {
        
        PNLog(PNLogGeneralLevel, self, @"PubNub client restored connection to PubNub origin at: %@", origin);
    }
    else {
        
        PNLog(PNLogGeneralLevel, self, @"PubNub client successfully connected to PubNub origin at: %@", origin);
    }
    
    
    self.disconnectedOnNetworkError = NO;
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"#1 PubNub client was unable to connect because of error: %@", error);
    
    self.disconnectedOnNetworkError = error.code == kPNClientConnectionFailedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub clinet will close connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client closed connection because of error: %@", error);
    
    self.disconnectedOnNetworkError = error.code == kPNClientConnectionClosedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client disconnected from PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
    
    //PNLog(PNLogGeneralLevel, self, @"PubNub client successfully subscribed on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client resuming subscription on: %@", channels);
}

- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully restored subscription on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully unsubscribed from channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to unsubscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully enabled presence observation on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to enable presence observation because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully disabled presence observation on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable presence observation because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client recieved time token: %@", timeToken);
}

- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive time token because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client is about to send message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
    [self WriteLog: [NSString stringWithFormat:@"PubNub client sent message: %@", message]isEssential:YES];
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message '%@' because of error: %@", message, error);
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
    [self WriteLog: [NSString stringWithFormat:@"PubNub client sent message: %@", message]isEssential:NO];
    PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received presence event: %@", event);
}

- (void)    pubnubClient:(PubNub *)client
didReceiveMessageHistory:(NSArray *)messages
              forChannel:(PNChannel *)channel
            startingFrom:(PNDate *)startDate
                      to:(PNDate *)endDate {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received history for %@ starting from %@ to %@: %@",
          channel, startDate, endDate, messages);
}

- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download history for %@ because of error: %@",
          channel, error);
}

- (void)      pubnubClient:(PubNub *)client
didReceiveParticipantsList:(NSArray *)participantsList
                forChannel:(PNChannel *)channel {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received participants list for channel %@: %@",
          participantsList, channel);
}

- (void)                     pubnubClient:(PubNub *)client
didFailParticipantsListDownloadForChannel:(PNChannel *)channel
                                withError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
          channel, error);
}

- (NSNumber *)shouldResubscribeOnConnectionRestore {
    
    NSNumber *shouldResubscribeOnConnectionRestore = @(YES);
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription? %@", [shouldResubscribeOnConnectionRestore boolValue] ? @"YES" : @"NO");
    
    return shouldResubscribeOnConnectionRestore;
}

- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {
    
    NSNumber *shouldRestoreSubscriptionFromLastTimeToken = @(NO);
    NSString *lastTimeToken = @"0";
    
    if ([[PubNub subscribedChannels] count] > 0) {
        
        lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
    }
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription from last time token? %@ (last time token: %@)",
          [shouldRestoreSubscriptionFromLastTimeToken boolValue]?@"YES":@"NO", lastTimeToken);
    
    return shouldRestoreSubscriptionFromLastTimeToken;
}

@end
