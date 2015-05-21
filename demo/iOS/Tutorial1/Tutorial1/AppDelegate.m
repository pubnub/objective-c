//
//  AppDelegate.m
//  Tutorial1
//
//  Created by gcohen on 5/12/15.
//  Copyright (c) 2015 geremy cohen. All rights reserved.
//

#import "AppDelegate.h"
#import "PubNub.h"
#import "PNResponse.h"
#import "PNStatus+Private.h"

#pragma mark Private interface declaration

@interface AppDelegate () <PNObjectEventListener>

#pragma mark - Properties

@property(nonatomic, strong) PubNub *client;
@property(nonatomic, strong) NSString *channel;
@property(nonatomic, strong) NSString *channel2;
@property(nonatomic, strong) NSTimer *timer;


#pragma mark - Configuration

- (void)updateClientConfiguration;
- (void)printClientConfiguration;

#pragma mark -
@end

#pragma mark - Interface implementation

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self tireKicker];
    return YES;
}

- (void)tireKicker {
    [self pubNubInit];
    [self pubNubTime];
    //[self pubNubHistory];
    [self pubNubSubscribe];
}

- (void)pubNubInit {
    // Initialize PubNub client.
    self.channel = @"ping_3";
    self.channel2 = @"ping_10";

    self.client = [PubNub clientWithPublishKey:@"demo-36" andSubscribeKey:@"demo-36"];

    [self.client addListeners:@[self]];

    [PNLog enableLogLevel:PNRequestLogLevel];
    [self updateClientConfiguration];
    [self printClientConfiguration];
}

-(void)delayedSub
{
    NSLog(@"Timer Called");
    [self.client subscribeToChannels:@[_channel2] withPresence:YES andCompletion:^(PNStatus *status) {
        if (!status.isError) {
            NSLog(@"^^^^Second Subscribe request succeeded at timetoken %@.", status.currentTimetoken);
        } else {
            NSLog(@"^^^^Second Subscribe request did not succeed. Will auto retry?: %@", status.willAutomaticallyRetry ? @"YES" : @"NO");
        }
    }];
}

- (void)pubNubSubscribe {
    // Subscribe
    [self.client subscribeToChannels:@[_channel] withPresence:YES andCompletion:^(PNStatus *status) {
        // Here we monitor subscribe events that we care about only at subscribe call time.
        // Subsequent subscribe loop status events should be monitored within didReceiveStatus listener

        if (!status.isError) {
            NSLog(@"^^^^Subscribe request succeeded at timetoken %@.", status.currentTimetoken);

            self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(delayedSub) userInfo:nil repeats:NO];

        } else {
            NSLog(@"^^^^Subscribe request did not succeed. Will auto retry?: %@", status.willAutomaticallyRetry ? @"YES" : @"NO");
        }
    }];
}

- (void)pubNubHistory {
    // History
    [self.client historyForChannel:_channel withCompletion:^(PNResult *result, PNStatus *status) {

        if (status.isError) {

            if (status.category == PNAccessDeniedCategory) {

                NSLog(@"History request failed because of PAM: %@", [status data]);
            }
            else if (status.category == PNDecryptionErrorCategory) {

                NSLog(@"History request received messages, but failed to decrypt them.");
            }
            else {

                NSLog(@"History request failed: %@", [status debugDescription]);
            }
        }
        if (result) {

            NSLog(@"Loaded history data: %@", result.data);
        }
    }];
}

- (void)pubNubTime {
// Time (Ping) to PubNub Servers
    [self.client timeWithCompletion:^(PNResult *result, PNStatus *status) {
        if (result.data) {
            NSLog(@"Result from Time: %@", result.data);
        }

        if (status.debugDescription) {
            NSLog(@"Event Status from Time: %@ - Is an error: %@", [status debugDescription], (status.isError ? @"YES" : @"NO"));
        }

    }];
}



- (void)publishHelloWorld {
    [self.client publish:@"I'm here!" toChannel:_channel
          withCompletion:^(PNStatus *status) {

              if (!status.isError) {

                  NSLog(@"Message sent at TT: %@", status.data[@"tt"]);
              } else {

                  NSLog(@"An error occurred while publishing: %@", status.data[@"information"]);
                  NSLog(@"Because this WILL NOT autoretry (%@), you must manually resend this message again.",
                          (status.willAutomaticallyRetry ? @"YES" : @"NO"));
              }
          }];
}

/********************************** Subscribe Loop Listeners  Start ********************************/

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message withStatus:(PNStatus *)status {

    NSLog(@"Did receive message: %@", message.data);
    if (status.isError) {
        
        NSLog(@"Message error: %@", @(status.category));
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {

    NSLog(@"Did receive presence event: %@", event.data);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {

    // Easily filter errors vs informational events with .isError attribute

    NSLog(@"^^^^Status DETECTED: %i", status.category);

    if (status.isError) {

        NSLog(@"^^^^Status ERROR: %i", status.category);

        if (status.category == PNDisconnectedCategory) {

            // PNDisconnect happens as part of our regular operation
            // No need to monitor for this unless requested by support

            NSLog(@"ExpectedDisconnect! Channel Info: %@", status.channels);

        }
        else if (status.category == PNUnexpectedDisconnectCategory) {

            // PNUnexpectedDisconnect happens as part of our regular operation
            // This event happens when radio / connectivity is lost

            NSLog(@"UnexpectedDisconnect! Channel Info: %@", status.channels);

        }

    } else

    if (!status.isError) {

        NSLog(@"^^^^Status NON-ERROR: %i", status.category);

        NSLog(@"*** status.category is: %@", @(status.category));

        if (status.category == PNConnectedCategory) {

            // Connect event. You can do stuff like publish, and know you'll get it.
            // Or just use the connected event to confirm you are subscribed for UI / internal notifications, etc

            // NSLog(@"Subscribe Connected to %@", status.data[@"channels"]);
            NSLog(@"Connected! Channel Info: %@", status.channels);
            [self publishHelloWorld];

        }


        else if (status.category == PNReconnectedCategory) {

            // PNUnexpectedDisconnect happens as part of our regular operation
            // This event happens when radio / connectivity is lost

            NSLog(@"Reconnected! Channel Info: %@", status.channels);

        }

        else if (status.category == PNMalformedResponseCategory) {

            NSLog(@"Bad JSON. Is error? %@, It will autoretry (%@)",
                    (status.isError ? @"YES" : @"NO"),
                    (status.willAutomaticallyRetry ? @"YES" : @"NO"));

            // If willAutomaticallyRetry is 'NO' then it is possible manually relaunch request
            // using: [status retry];
            // Retry attempts can be canceled with this code: [status cancelAutomaticRetry];


        }
            // When receiving a 403
        else if (status.category == PNAccessDeniedCategory) {

            NSLog(@"PAM Access Denied against channel %@ -- it will autoretry: %@",
                    status.data[@"channels"], (status.willAutomaticallyRetry ? @"YES" : @"NO"));
            NSLog(@"In the meantime, you may wish to change the autotoken or unsubscribe from the channel in question.");

        }
    }
}


/********************************** Subscribe Loop Listeners End ********************************/


#pragma mark - Configuration

- (void)updateClientConfiguration {

    [self.client commitConfiguration:^{

        // Set PubNub Configuration
        self.client.TLSEnabled = YES;
        self.client.origin = @"ios4.pubnub.com";
        self.client.authKey = @"myAuthKey";
        self.client.uuid = @"ios4.0Tutorial";

        // Presence Settings
        self.client.presenceHeartbeatValue = 120;
        self.client.presenceHeartbeatInterval = 3;

        // Cipher Key Settings
        //self.client.cipherKey = @"enigma";

        // Time Token Handling Settings
        self.client.keepTimeTokenOnListChange = YES;
        self.client.restoreSubscription = YES;
        self.client.catchUpOnSubscriptionRestore = YES;
    }];
}

- (void)printClientConfiguration {

    // Get PubNub Options
    NSLog(@"SSELEnabled: %@", (self.client.isTLSEnabled ? @"YES" : @"NO"));
    NSLog(@"Origin: %@", self.client.origin);
    NSLog(@"authKey: %@", self.client.authKey);
    NSLog(@"UUID: %@", self.client.uuid);

    // Time Token Handling Settings
    NSLog(@"keepTimeTokenOnChannelChange: %@",
            (self.client.shouldKeepTimeTokenOnListChange ? @"YES" : @"NO"));
    NSLog(@"resubscribeOnConnectionRestore: %@",
            (self.client.shouldRestoreSubscription ? @"YES" : @"NO"));
    NSLog(@"catchUpOnSubscriptionRestore: %@",
            (self.client.shouldTryCatchUpOnSubscriptionRestore ? @"YES" : @"NO"));

    // Get Presence Options
    NSLog(@"Heartbeat value: %@", @(self.client.presenceHeartbeatValue));
    NSLog(@"Heartbeat interval: %@", @(self.client.presenceHeartbeatInterval));

    // Get CipherKey
    NSLog(@"Cipher key: %@", self.client.cipherKey);
}

#pragma mark -

@end
