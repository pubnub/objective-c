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

                    [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                        return [NSString stringWithFormat:@"#2 PubNub client was unable to connect because of error: %@",
                                [error localizedFailureReason]];
                    }];
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
                                                        [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                                            return [NSString stringWithFormat:@"{BLOCK-P} PubNub client subscription failed with error: %@",
                                                                    [subscriptionError localizedFailureReason]];
                                                        }];
                                                    }
                                                    break;

                                                case PNSubscriptionProcessSubscribedState:
                                                    {
                                                        [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                                            return [NSString stringWithFormat:@"{BLOCK-P} PubNub client subscribed on channels: %@",
                                                                    channels];
                                                        }];
                                                    }
                                                    break;

                                                case PNSubscriptionProcessWillRestoreState:
                                                    {
                                                        [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                                            return [NSString stringWithFormat:@"{BLOCK-P} PubNub client will restore subscribed on channels: %@",
                                                                    channels];
                                                        }];
                                                    }
                                                    break;

                                                case PNSubscriptionProcessRestoredState:
                                                    {
                                                        [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                                            return [NSString stringWithFormat:@"{BLOCK-P} PubNub client restores subscribed on channels: %@",
                                                                    channels];
                                                        }];
                                                    }
                                                    break;
                                            }
                                        }];

    // Subscribe on message arrival events with block
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:weakSelf
                                                         withBlock:^(PNMessage *message) {

                                     [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                         return [NSString stringWithFormat:@"{BLOCK-P} PubNubc client received new message: %@",
                                                 message];
                                     }];
                            }];

    // Subscribe on presence event arrival events with block
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:weakSelf
                                                        withBlock:^(PNPresenceEvent *presenceEvent) {

                                                            [PNLogger logGeneralMessageFrom:weakSelf message:^NSString * {

                                                                 return [NSString stringWithFormat:@"{BLOCK-P} PubNubc client received new event: %@",
                                                                         presenceEvent];
                                                            }];
                                                     }];
}


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        
        [[PNDataManager sharedInstance] handleOpenWithURL:[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey]];
    }
    
    [self initializePubNubClient];
    
    UIRemoteNotificationType type = (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
    
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

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    // Application received push notification (only in foreground or if application is able to work in background),
}

#pragma mark - PubNub client delegate methods

- (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client changed access rights configuration: %@",
                accessRightsCollection];
    }];
}

- (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to change access rights configuration because of error: %@",
                error];
    }];
}

- (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client completed access rights audition: %@",
                accessRightsCollection];
    }];
}

- (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to audit access rights because of error: %@",
                error];
    }];
}

- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client enabled push notifications on channels: %@",
                channels];
    }];
}

- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed push notification enable because of error: %@",
                error];
    }];
}

- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client disabled push notifications on channels: %@",
                channels];
    }];
}

- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to disable push notifications because of error: %@",
                error];
    }];
}

- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client received push notificatino enabled channels: %@",
                channels];
    }];
}

- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to receive list of channels because of error: %@",
                error];
    }];
}

- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return @"PubNub client removed push notifications from all channels";
    }];
}

- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed remove push notifications from channels because of error: %@",
                error];
    }];
}

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client report that error occurred: %@", error];
    }];
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {


    NSString *message = [NSString stringWithFormat:@"PubNub client is about to connect to PubNub origin at: %@", origin];
    if (self.isDisconnectedOnNetworkError) {

        message = [NSString stringWithFormat:@"PubNub client trying to restore connection to PubNub origin at: %@", origin];
    }

    [PNLogger logGeneralMessageFrom:self message:^NSString * { return message; }];
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {

    NSString *message = [NSString stringWithFormat:@"PubNub client successfully connected to PubNub origin at: %@", origin];
    if (self.isDisconnectedOnNetworkError) {

        message = [NSString stringWithFormat:@"PubNub client restored connection to PubNub origin at: %@", origin];
    }

    [PNLogger logGeneralMessageFrom:self message:^NSString * { return message; }];

    self.disconnectedOnNetworkError = NO;
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"#1 PubNub client was unable to connect because of error: %@", error];
    }];

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionFailedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub clinet will close connection because of error: %@", error];
    }];
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client closed connection because of error: %@", error];
    }];

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionClosedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client disconnected from PubNub origin at: %@", origin];
    }];
}

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

- (void)pubnubClient:(PubNub *)client didReceiveClientState:(PNClient *)remoteClient {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client successfully received state for client %@ on channel %@: %@",
                remoteClient.identifier, remoteClient.channel, remoteClient.data];
    }];
}

- (void)pubnubClient:(PubNub *)client clientStateRetrieveDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client did fail to receive state for client %@ on channel %@ because of error: %@",
                ((PNClient *)error.associatedObject).identifier, ((PNClient *)error.associatedObject).channel, error];
    }];
}

- (void)pubnubClient:(PubNub *)client didUpdateClientState:(PNClient *)remoteClient {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client successfully updated state for client %@ at channel %@: %@",
                remoteClient.identifier, remoteClient.channel, remoteClient.data];
    }];
}

- (void)pubnubClient:(PubNub *)client clientStateUpdateDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client did fail to update state for client %@ at channel %@ because of error: %@",
                ((PNClient *)error.associatedObject).identifier, ((PNClient *)error.associatedObject).channel, error];
    }];
}

- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client successfully subscribed on channels: %@", channels];
    }];
}

- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client resuming subscription on: %@", channels];
    }];
}

- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client successfully restored subscription on channels: %@", channels];
    }];
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to subscribe because of error: %@", error];
    }];
}

- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client successfully unsubscribed from channels: %@", channels];
    }];
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to unsubscribe because of error: %@", error];
    }];
}

- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client successfully enabled presence observation on channels: %@", channels];
    }];
}

- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to enable presence observation because of error: %@", error];
    }];
}

- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client successfully disabled presence observation on channels: %@", channels];
    }];
}

- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to disable presence observation because of error: %@", error];
    }];
}

- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client recieved time token: %@", timeToken];
    }];
}

- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to receive time token because of error: %@", error];
    }];
}

- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client is about to send message: %@", message];
    }];
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to send message '%@' because of error: %@", message, error];
    }];
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client sent message: %@", message];
    }];
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client received message: %@", message];
    }];
}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client received presence event: %@", event];
    }];
}

- (void)pubnubClient:(PubNub *)client didReceiveMessageHistory:(NSArray *)messages forChannel:(PNChannel *)channel
        startingFrom:(PNDate *)startDate to:(PNDate *)endDate {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client received history for %@ starting from %@ to %@: %@",
                channel, startDate, endDate, messages];
    }];
}

- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to download history for %@ because of error: %@",
                channel, error];
    }];
}

- (void)pubnubClient:(PubNub *)client didReceiveParticipantsList:(NSArray *)participantsList
          forChannel:(PNChannel *)channel {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client received participants list for channel %@: %@",
                participantsList, channel];
    }];
}

- (void)pubnubClient:(PubNub *)client didFailParticipantsListDownloadForChannel:(PNChannel *)channel
           withError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to download participants list for channel %@ because of error: %@",
                channel, error];
    }];
}

- (void)pubnubClient:(PubNub *)client didReceiveParticipantChannelsList:(NSArray *)participantChannelsList
       forIdentifier:(NSString *)clientIdentifier {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client received participant channels list for identifier %@: %@",
                participantChannelsList, clientIdentifier];
    }];
}

- (void)pubnubClient:(PubNub *)client didFailParticipantChannelsListDownloadForIdentifier:(NSString *)clientIdentifier
           withError:(PNError *)error {

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client failed to download participant channels list for identifier %@ "
                "because of error: %@", clientIdentifier, error];
    }];
}

- (NSNumber *)shouldResubscribeOnConnectionRestore {

    NSNumber *shouldResubscribeOnConnectionRestore = @(YES);

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client should restore subscription? %@",
                [shouldResubscribeOnConnectionRestore boolValue] ? @"YES" : @"NO"];
    }];


    return shouldResubscribeOnConnectionRestore;
}

- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {

    NSNumber *shouldRestoreSubscriptionFromLastTimeToken = @(NO);
    NSString *lastTimeToken = @"0";

    if ([[PubNub subscribedChannels] count] > 0) {

        lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
    }

    [PNLogger logGeneralMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"PubNub client should restore subscription from last time token? %@ (last time token: %@)",
                    [shouldRestoreSubscriptionFromLastTimeToken boolValue]?@"YES":@"NO", lastTimeToken];
    }];


    return shouldRestoreSubscriptionFromLastTimeToken;
}

#pragma mark -


@end
