//
//  AppDelegate.m
//  Tutorial1
//
//  Created by gcohen on 5/12/15.
//  Copyright (c) 2015 geremy cohen. All rights reserved.
//

#import "AppDelegate.h"
#import "PNStatus+Private.h"
#import <PubNub/PubNub.h>

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
    self.channel = @"ping_3";
    self.channel2 = @"ping_10";

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
    self.client = [PubNub clientWithPublishKey:@"pam" andSubscribeKey:@"pam"];

    // Bind didReceiveMessage, didReceiveStatus, and didReceivePresenceEvent 'listeners' to this delegate
    // just be sure the target has implemented the PNObjectEventListener extension

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
            [self handleStatus:status];
        }
    }];
}

- (void)pubNubSubscribe {
    // Subscribe

    [self.client subscribeToChannels:@[_channel] withPresence:YES andCompletion:^(PNStatus *status) {

        // There are two places to monitor for the outcomes of a subscribe.

        // The first place is here, within the subscribe status completion block.
        // Here we monitor subscribe events that we care about only at subscribe call time.
        // This context will disappear after the initial subscribe connect event.

        // Subsequent subscribe loop status events are received within didReceiveStatus listener
        // And the messages that arrive via this subscribe call are received via the didReceiveMessage listener

        if (!status.isError) {
            NSLog(@"^^^^Subscribe request succeeded at timetoken %@.", status.currentTimetoken);
            self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(delayedSub) userInfo:nil repeats:NO];
        } else {
            NSLog(@"^^^^Second Subscribe request did not succeed. All subscribe operations will autoretry when possible.");
            [self handleStatus:status];
        }
    }];
}

- (void)pubNubHistory {
    // History

    [self.client historyForChannel:_channel withCompletion:^(PNResult *result, PNStatus *status) {

        // For completion blocks that provide both result and status parameters, you will only ever
        // have a non-nil status or result.

        // If you have a result, the data you specifically requested (in this case, history response) is available in result.data
        // If you have a status, error or non-error status information is available regarding the call.

        if (status) {
            // As a status, this contains error or non-error information about the history request, but not the actual history data I requested.
            // Timeout Error, PAM Error, etc.

            [self handleStatus:status];
        }
        else if (result) {
            // As a result, this contains the messages, start, and end timetoken in the data attribute

            NSLog(@"Loaded history data: %@", result.data);  // TODO: Call out data attributes here
        }
    }];
}


- (void)pubNubTime {
    // Time (Ping) to PubNub Servers

    [self.client timeWithCompletion:^(PNResult *result, PNStatus *status) {
        if (result.data) {
            NSLog(@"Result from Time: %@", result.data);
        }
        else if (status) {
            [self handleStatus:status];
        }
    }];
}

- (void)publishHelloWorld {
    [self.client publish:@"I'm here!" toChannel:_channel
          withCompletion:^(PNStatus *status) {
              if (!status.isError) {
                  NSLog(@"Message sent at TT: %@", status.data[@"tt"]);
              } else {
                  [self handleStatus:status];
              }
          }];
}

#pragma mark - Streaming Data didReceiveMessage Listener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message withStatus:(PNStatus *)status {

    if (status) {
        [self handleStatus:status];
    } else if (message) {
        NSLog(@"Received message: %@", message.data);
    }
}

#pragma mark - Streaming Data didReceivePresenceEvent Listener

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    // TODO detail fields in data that depict the Presence event

    NSLog(@"Did receive presence event: %@", event.data);
}

#pragma mark - Streaming Data didReceiveStatus Listener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {

    // This is where we'll find ongoing status events from our subscribe loop
    // Results (messages) from our subscribe loop will be found in didReceiveMessage
    // Results (presence events) from our subscribe loop will be found in didReceiveStatus

    [self handleStatus:status];
}

#pragma mark - example status handling

- (void)handleStatus:(PNStatus *)status {

    // TODO differentiate between errors, non-errors, connection, ack status events
    // TODO handleErrorStatus vs handleNonErrorStatus ?

//    Two types of status events are possible. Errors, and non-errors. Errors will prevent normal operation of your app.
//
//    If this was a subscribe or presence PAM error, the system will continue to retry automatically.
//    If this was any other operation, you will need to manually retry the operation.
//
//    You can always verify if an operation will auto retry by checking status.willAutomaticallyRetry
//    If the operation will not auto retry, you can manually retry by calling [status retry]
//    Retry attempts can be cancelled via [status cancelAutomaticRetry]

    if (status.isError) {
        [self handleErrorStatus:status];
    } else {
        [self handleNonErrorStatus:status];
    }

}

- (void)handleErrorStatus:(PNStatus *)status {


    if (status.category == PNAccessDeniedCategory) {

        // Access Denied via PAM. Access status.data to determine the resource in question that was denied.
        // In addition, you can also change auth key dynamically if needed."

        NSLog(@"^^^^ Debug: %@", status.debugDescription);
        NSLog(@"^^^^ handleErrorStatus: PAM Error: for resource Will Auto Retry?: %@", status.willAutomaticallyRetry ? @"YES" : @"NO");

        if (status.data[@"channels"]) {
            NSLog(@"PAM error on channel %@", status.data[@"channels"][0]);
        } else if (status.data[@"channel-groups"]) {
            NSLog(@"PAM error on channel %@", status.data[@"channel-groups"][0]);
        }
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

    else if (status.category == PNTimeoutCategory) {

        NSLog(@"For whatever reason, the request timed out. Temporary connectivity issues, etc.");
    }

    else {
        // Aside from checking for PAM, this is a generic catch-all if you just want to handle any error, regardless of reason
        // status.debugDescription will shed light on exactly whats going on

        NSLog(@"Request failed... if this is an issue that is consistently interrupting the performance of your app,");
        NSLog(@"email the output of debugDescription to support along with all available log info: %@", [status debugDescription]);
    }
}

- (void)handleNonErrorStatus:(PNStatus *)status {

    // This method demonstrates how to handle status events that are not errors -- that is,
    // status events that can safely be ignored, but if you do choose to handle them, you
    // can get increased functionality from the client

    if (status.category == PNAcknowledgmentCategory) {
        NSLog(@"^^^^ Non-error status: ACK");

        // For methods like Publish, Channel Group Add|Remove|List, APNS Add|Remove|List
        // when the method is executed, and completes, you can receive the 'ack' for it here.
        // status.data will contain more server-provided information about the ack as well.

    }

    if (status.operation == PNSubscribeOperation) {

        // Specific to the subscribe loop operation, you can handle connection events
        // These status checks are only available via the subscribe status completion block or
        // on the long-running subscribe loop listener didReceiveStatus

        // Connection events are never defined as errors via status.isError

        if (status.category == PNDisconnectedCategory) {
            // PNDisconnect happens as part of our regular operation
            // No need to monitor for this unless requested by support
            NSLog(@"^^^^ Non-error status: Expected Disconnect, Channel Info: %@", status.channels);
        }

        else if (status.category == PNUnexpectedDisconnectCategory) {
            // PNUnexpectedDisconnect happens as part of our regular operation
            // This event happens when radio / connectivity is lost

            NSLog(@"^^^^ Non-error status: Unexpected Disconnect, Channel Info: %@", status.channels);
        }

        else if (status.category == PNConnectedCategory) {

            // Connect event. You can do stuff like publish, and know you'll get it.
            // Or just use the connected event to confirm you are subscribed for UI / internal notifications, etc

            // NSLog(@"Subscribe Connected to %@", status.data[@"channels"]);
            NSLog(@"^^^^ Non-error status: Connected, Channel Info: %@", status.channels);
            [self publishHelloWorld];

        }
        else if (status.category == PNReconnectedCategory) {

            // PNUnexpectedDisconnect happens as part of our regular operation
            // This event happens when radio / connectivity is lost

            NSLog(@"^^^^ Non-error status: Reconnected, Channel Info: %@", status.channels);

        }

    }

}

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
        self.client.presenceHeartbeatInterval = 60;

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
