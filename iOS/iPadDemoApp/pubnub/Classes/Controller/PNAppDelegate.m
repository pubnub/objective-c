//
//  PNAppDelegate.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNAppDelegate.h"
#import "PNIdentificationViewController.h"
#import "PNMainViewController.h"
#import "PNDataManager.h"


#pragma mark Private interface methods

@interface PNAppDelegate ()


#pragma mark - Properties

// Stores whether client disconnected on network error
// or not
@property (nonatomic, assign, getter = isDisconnectedOnNetworkError) BOOL disconnectedOnNetworkError;


#pragma mark - Instance methods

- (void)initializePubNubClient;


@end


#pragma mark - Public interface methods

@implementation PNAppDelegate


#pragma mark - Instance methods

- (void)initializePubNubClient {

    [PubNub setDelegate:self];

    __pn_desired_weak __typeof__(self) weakSelf = self;

    // Subscribe for client connection state change (observe when client will be disconnected)
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *error) {

                if (!connected && error) {

                    NSLog(@"#2 PubNub client was unable to connect because of error: %@", [error localizedFailureReason]);
                }
            }];


    // Subscribe application delegate on subscription updates (events when client subscribe on some channel)
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:weakSelf
                                                                 withCallbackBlock:^(PNSubscriptionProcessState state,
                                                                                     NSArray *channels,
                                                                                     PNError *subscriptionError) {

                                            switch (state) {

                                                case PNSubscriptionProcessNotSubscribedState:
                                                    {
                                                        NSLog(@"{BLOCK-P} PubNub client subscription failed with error: %@",
                                                              [subscriptionError localizedFailureReason]);
                                                    }
                                                    break;

                                                case PNSubscriptionProcessSubscribedState:
                                                    {
                                                        NSLog(@"{BLOCK-P} PubNub client subscribed on channels: %@",
                                                              channels);
                                                    }
                                                    break;

                                                case PNSubscriptionProcessWillRestoreState:
                                                    {
                                                        NSLog(@"{BLOCK-P} PubNub client will restore subscribed on channels: %@",
                                                              channels);
                                                    }
                                                    break;

                                                case PNSubscriptionProcessRestoredState:
                                                    {
                                                        NSLog(@"{BLOCK-P} PubNub client restores subscribed on channels: %@",
                                                              channels);
                                                    }
                                                    break;
                                            }
                                        }];

    // Subscribe on message arrival events with block
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:weakSelf withBlock:^(PNMessage *message) {
         
        NSLog(@"{BLOCK-P} PubNubc client received new message: %@", message);
    }];

    // Subscribe on presence event arrival events with block
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:weakSelf withBlock:^(PNPresenceEvent *presenceEvent) {

        NSLog(@"{BLOCK-P} PubNubc client received new event: %@", presenceEvent);
    }];
}


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        
        [[PNDataManager sharedInstance] handleOpenWithURL:[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey]];
    }
    
    [self initializePubNubClient];
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connect];
    [[PubNub sharedInstance] requestDefaultChannelGroupsWithCompletionHandlingBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
        
        NSLog(@"NAMESPACE: %@", namespaceName);
        NSLog(@"GROUPS NAME: %@", [channelGroups valueForKey:@"groupName"]);
        NSLog(@"GROUPS NAMESPACE NAME: %@", [channelGroups valueForKey:@"nspace"]);
    }];
    
    #if !TARGET_IPHONE_SIMULATOR
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // Registering for push notifications under iOS8
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        
        // Register for push notifications for pre-iOS8
        UIRemoteNotificationType type = (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
    }
    #endif
    
    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [PNIdentificationViewController new];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [[PNDataManager sharedInstance] handleOpenWithURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [PNDataManager sharedInstance].devicePushToken = deviceToken;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [PNDataManager sharedInstance].devicePushToken = nil;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Application received push notification (only in foreground or if application is able to work in background),
}

#pragma mark - PubNub client delegate methods

- (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

    NSLog(@"PubNub client changed access rights configuration: %@", accessRightsCollection);
}

- (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client failed to change access rights configuration because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

    NSLog(@"PubNub client completed access rights audition: %@", accessRightsCollection);
}

- (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client failed to audit access rights because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

    NSLog(@"PubNub client enabled push notifications on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client failed push notification enable because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

    NSLog(@"PubNub client disabled push notifications on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client failed to disable push notifications because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {

    NSLog(@"PubNub client received push notificatino enabled channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client failed to receive list of channels because of error: %@", error);
}

- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {

    NSLog(@"PubNub client removed push notifications from all channels");
}

- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client failed remove push notifications from channels because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {

    NSLog(@"PubNub client report that error occurred: %@", error);
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {


    NSString *message = [NSString stringWithFormat:@"PubNub client is about to connect to PubNub origin at: %@", origin];
    if (self.isDisconnectedOnNetworkError) {

        message = [NSString stringWithFormat:@"PubNub client trying to restore connection to PubNub origin at: %@", origin];
    }
    
    NSLog(@"%@", message);
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {

    NSString *message = [NSString stringWithFormat:@"PubNub client successfully connected to PubNub origin at: %@", origin];
    if (self.isDisconnectedOnNetworkError) {

        message = [NSString stringWithFormat:@"PubNub client restored connection to PubNub origin at: %@", origin];
    }
    
    NSLog(@"%@", message);

    self.disconnectedOnNetworkError = NO;
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {

    NSLog(@"#1 PubNub client was unable to connect because of error: %@", error);

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionFailedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {

    NSLog(@"PubNub clinet will close connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {

    NSLog(@"PubNub client closed connection because of error: %@", error);

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionClosedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {

    NSLog(@"PubNub client disconnected from PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didReceiveClientState:(PNClient *)remoteClient {

    NSMutableDictionary *state = [NSMutableDictionary dictionary];
    [remoteClient.channels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx,
                                                        BOOL *channelEnumeratoStop) {
        
        [state setValue:[remoteClient stateForChannel:channel] forKey:channel.name];
    }];
    NSLog(@"PubNub client successfully received state for client %@ on channels: %@", remoteClient.identifier, state);
}

- (void)pubnubClient:(PubNub *)client clientStateRetrieveDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client did fail to receive state for client %@ on channel %@ because of error: %@",
          ((PNClient *)error.associatedObject).identifier,((PNClient *)error.associatedObject).channel, error);
}

- (void)pubnubClient:(PubNub *)client didUpdateClientState:(PNClient *)remoteClient {

    NSLog(@"PubNub client successfully updated state for client %@ at channel %@: %@", remoteClient.identifier,
          remoteClient.channel, [remoteClient stateForChannel:remoteClient.channel]);
}

- (void)pubnubClient:(PubNub *)client clientStateUpdateDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client did fail to update state for client %@ at channel %@ because of error: %@",
          ((PNClient *)error.associatedObject).identifier, ((PNClient *)error.associatedObject).channel, error);
}

- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {

    NSLog(@"PubNub client successfully subscribed on channels: %@", channelObjects);
}

- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOn:(NSArray *)channelObjects {

    NSLog(@"PubNub client resuming subscription on: %@", channelObjects);
}

- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOn:(NSArray *)channelObjects {

    NSLog(@"PubNub client successfully restored subscription on channels: %@", channelObjects);
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {

    NSLog(@"PubNub client failed to subscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {

    NSLog(@"PubNub client successfully unsubscribed from channels: %@", channelObjects);
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client failed to unsubscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOn:(NSArray *)channelObjects {

    NSLog(@"PubNub client successfully enabled presence observation on channels: %@", channelObjects);
}

- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client failed to enable presence observation because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOn:(NSArray *)channelObjects {

    NSLog(@"PubNub client successfully disabled presence observation on channels: %@", channelObjects);
}

- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {

    NSLog(@"PubNub client failed to disable presence observation because of error: %@", error);
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

- (void)pubnubClient:(PubNub *)client didReceiveMessageHistory:(NSArray *)messages forChannel:(PNChannel *)channel
        startingFrom:(PNDate *)startDate to:(PNDate *)endDate {

    NSLog(@"PubNub client received history for %@ starting from %@ to %@: %@", channel, startDate, endDate, messages);
}

- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {

    NSLog(@"PubNub client failed to download history for %@ because of error: %@", channel, error);
}

- (void)pubnubClient:(PubNub *)client didReceiveParticipants:(PNHereNow *)presenceInformation
                                                  forObjects:(NSArray *)channelObjects {
    
    NSLog(@"PubNub client received participants list for channels and groups %@: %@", channelObjects, presenceInformation);
}

- (void)pubnubClient:(PubNub *)client didFailParticipantsListDownloadFor:(NSArray *)channelObjects
           withError:(PNError *)error {
    
    NSLog(@"PubNub client failed to download participants list for channels %@ because of error: %@", channelObjects, error);
}

- (void)pubnubClient:(PubNub *)client didReceiveParticipantChannelsList:(NSArray *)participantChannelsList
       forIdentifier:(NSString *)clientIdentifier {

    NSLog(@"PubNub client received participant channels list for identifier %@: %@", participantChannelsList, clientIdentifier);
}

- (void)pubnubClient:(PubNub *)client didFailParticipantChannelsListDownloadForIdentifier:(NSString *)clientIdentifier
           withError:(PNError *)error {

    NSLog(@"PubNub client failed to download participant channels list for identifier %@ because of error: %@",
          clientIdentifier, error);
}

- (NSNumber *)shouldResubscribeOnConnectionRestore {

    NSNumber *shouldResubscribeOnConnectionRestore = @(YES);

    NSLog(@"PubNub client should restore subscription? %@", [shouldResubscribeOnConnectionRestore boolValue] ? @"YES" : @"NO");


    return shouldResubscribeOnConnectionRestore;
}

- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {

    NSNumber *shouldRestoreSubscriptionFromLastTimeToken = @(NO);
    NSString *lastTimeToken = @"0";

    if ([[PubNub subscribedObjectsList] count] > 0) {

        lastTimeToken = [[[PubNub subscribedObjectsList] lastObject] updateTimeToken];
    }

    NSLog(@"PubNub client should restore subscription from last time token? %@ (last time token: %@)",
          [shouldRestoreSubscriptionFromLastTimeToken boolValue] ? @"YES" : @"NO", lastTimeToken);


    return shouldRestoreSubscriptionFromLastTimeToken;
}

#pragma mark -


@end
