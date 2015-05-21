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

- (void)delayedSub {
    NSLog(@"Timer Called");
    [self.client subscribeToChannels:@[_channel2] withPresence:YES andCompletion:^(PNStatus *status) {
        if (!status.isError) {
            NSLog(@"^^^^Second Subscribe request succeeded at timetoken %@.", status.currentTimetoken);
        } else {
            NSLog(@"^^^^Second Subscribe request did not succeed. All subscribe operations will autoretry when possible.");
            [self handleErrors:status];
        }
    }];
}

- (void)pubNubSubscribe {
    // Subscribe

    [self.client subscribeToChannels:@[_channel] withPresence:YES andCompletion:^(PNStatus *status) {

        // There are two places to monitor for the outcomes of a subscribe.

        // The first place is here, within the subscribe completion block.
        // Here we monitor subscribe events that we care about only at subscribe call time.
        // This context will disappear after the initial subscribe connect event.

        // Subsequent subscribe loop status events are received within didReceiveStatus listener
        // And the messages that arrive via this subscribe call are received via the didReceiveMessage listener

        if (status.isError) {
            [self handleErrors:status];
        }

        else if (!status.isError) {
            NSLog(@"^^^^Subscribe request succeeded at timetoken %@.", status.currentTimetoken);

            self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(delayedSub) userInfo:nil repeats:NO];

        } else {
            NSLog(@"^^^^Second Subscribe request did not succeed. All subscribe operations will autoretry when possible.");
            [self handleErrors:status];
        }
    }];
}

- (void)pubNubHistory {
    // History

    [self.client historyForChannel:_channel withCompletion:^(PNResult *result, PNStatus *status) {

        if (status.isError) {
            [self handleErrors:status];
        }
        else if (result) {
            NSLog(@"Loaded history data: %@", result.data);  // TODO: Call out data attributes here
        }
    }];
}

- (void)handleErrors:(PNStatus *)status {

    /*

    // TODO differentiate between errors, non-errors, connection, ack status events
    // TODO handleErrorStatus vs handleNonErrorStatus ?

    Then could handle like this:

        if (status.isError) {
            [self handleErrorStatus:status];
        } else if (!status.isError) {
            [self handleNonErrorStatus:status];
        }

     */

    NSLog(@"Two types of status events are possible. Errors, and non-errors. Errors will prevent normal operation of your app.");

    NSLog(@"\nIf this was a subscribe or presence PAM error, the system will continue to retry automatically.");
    NSLog(@"If this was any other operation, you will need to manually retry the operation.");

    NSLog(@"\nYou can always verify if an operation will auto retry by checking status.willAutomaticallyRetry: %@", status.willAutomaticallyRetry ? @"YES" : @"NO");
    NSLog(@"If the operation will not auto retry, you can manually retry by calling [status retry]");
    NSLog(@"Retry attempts can be cancelled via [status cancelAutomaticRetry]");

    NSLog(@"^^^^Status Category: %i\n\n", status.category);

    // if this is a subscribe or presence operation, check to see if its a connection-related status

    if (status.operation == PNSubscribeOperation) {
        [self handleSubscribeConnectionChange:status];
    }

    else if (status.category == PNAccessDeniedCategory) {

        NSLog(@"Access Denied via PAM. Access status.data to determine the resource in question that was denied. %@", [status data]);
        NSLog(@"In addition, you can also change auth key dynamically if needed.");

        // TODO detail fields in data that depict the PAM error

    }
    else if (status.category == PNDecryptionErrorCategory) {

        NSLog(@"Decryption error. Be sure the data is encrypted and/or encrypted with the correct cipher key.");
        NSLog(@"You can find the raw data returned from the server in the status.data attribute: %@", status.data);
        // TODO: detail fields in data that show "broken" ciphertext
    }
    else if (status.category == PNMalformedResponseCategory) {

        NSLog(@"We were expecting JSON from the server, but we got HTML, or otherwise not legal JSON.");
        NSLog(@"This may happen when you connect to a public WiFi Hotspot that requires you to auth via your web browser first,");
        NSLog(@"or if there is a proxy somewhere returning an HTML access denied error, or if there was an intermittent server issue.");
    }

    else {
        NSLog(@"Request failed... if this is an issue that is consistently interrupting the performance of your app, email the output of debugDescription to support along with all available log info: %@", [status debugDescription]);
    }
}

- (void)pubNubTime {
    // Time (Ping) to PubNub Servers

    [self.client timeWithCompletion:^(PNResult *result, PNStatus *status) {
        if (result.data) {
            NSLog(@"Result from Time: %@", result.data);
        }
        else if (status.debugDescription) {
            [self handleErrors:status];
        }
    }];
}

- (void)publishHelloWorld {
    [self.client publish:@"I'm here!" toChannel:_channel
          withCompletion:^(PNStatus *status) {
              if (!status.isError) {
                  NSLog(@"Message sent at TT: %@", status.data[@"tt"]);
              } else {
                  [self handleErrors:status];
              }
          }];
}

/********************************** Subscribe Loop Listeners  Start ********************************/

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message withStatus:(PNStatus *)status {

    if (status) {
        [self handleErrors:status];
    } else if (message) {
        NSLog(@"Received message: %@", message.data);
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    // TODO detail fields in data that depict the PAM error

    NSLog(@"Did receive presence event: %@", event.data);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {

    // This is where we'll find ongoing status events from our subscribe loop
    // Results (messages) from our subscribe loop will be found in didReceiveMessage
    // Results (presence events) from our subscribe loop will be found in didReceiveStatus

    [self handleErrors:status];
}

- (void)handleSubscribeConnectionChange:(PNStatus *)status {

    // This method shows how to act on connection events specifically related to the subscribe loop
    // Don't use these status checks on anything other than the subscribe status completion block or
    // on the long-running subscribe loop listener didReceiveStatus

    // Connection events are never defined as errors via status.isError

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
    else if (status.category == PNConnectedCategory) {

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
