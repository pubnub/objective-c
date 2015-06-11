//
//  AppDelegate.m
//  Tutorial1
//
//  Created by gcohen on 5/12/15.
//  Copyright (c) 2015 geremy cohen. All rights reserved.
//

#import "PNAppDelegate.h"
#import <PubNub/PubNub.h>

#pragma mark Private interface declaration

@interface PNAppDelegate () <PNObjectEventListener>

#pragma mark - Properties

@property(nonatomic, strong) PubNub *client;
@property(nonatomic, strong) NSString *channel1;
@property(nonatomic, strong) NSString *channel2;
@property(nonatomic, strong) NSString *subKey;
@property(nonatomic, strong) NSString *pubKey;
@property(nonatomic, strong) NSString *authKey;

@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, strong) PNConfiguration *myConfig;


#pragma mark - Configuration

- (void)updateClientConfiguration;
- (void)printClientConfiguration;

#pragma mark -
@end

#pragma mark - Interface implementation

@implementation PNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#pragma mark - PAM Use Case Config

    // Settings Config for PAM Example
    // Uncomment this section line for a PAM use-case example

    // http://www.pubnub.com/console/?channel=good&origin=d.pubnub.com&sub=pam&pub=pam&cipher=&ssl=false&secret=pam&auth=myAuthKey

//     self.channel1 = @"good";
//     self.channel2 = @"bad";
//     self.pubKey = @"pam";
//     self.subKey = @"pam";
//     self.authKey = @"foo";

#pragma mark - Non-PAM Use Case Config

//    Settings Config for Non-PAM Example
    self.channel1 = @"bot";
    self.channel2 = @"myCh";
    self.pubKey = @"demo-36";
    self.subKey = @"demo-36";
    self.authKey = @"myAuthKey";




#pragma mark - Kick the Tires!

    [self tireKicker];
    return YES;
}

- (void)tireKicker {
    [self pubNubInit];
//    [self pubNubTime];
//    [self publishHelloWorld];
//    [self pubNubHistory];

    [self pubNubSubscribeToChannels];
//    [self pubNubSubscribeWithState];
//    [self pubNubSubscribeToPresence];


//    [self pubNubHereNowForChannel];
//    [self pubNubHereNowForChannelWithVerbosity];
//    [self pubNubGlobalHereNow];
//    [self pubNubGlobalHereNowWithVerbosity];
//    [self pubNubWhereNow];

//    [self pubNubCGAdd];
//    [self pubNubCGRemoveAllChannels];
//    [self pubNubCGRemoveSomeChannels];
//    [self pubNubSubscribeToChannelGroups];
//    [self pubNubUnsubFromChannelGroups];

//    [self pubNubSetRandomState];
}

- (void)pubNubSetRandomState{
    [self.client setState:@{[self randomString] : @{[self randomString] : [self randomString]}} forUUID:_myConfig.uuid onChannel:_channel1 withCompletion:^(PNStatus <PNSetStateStatus> *status) {
        //self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pubNubSetRandomState) userInfo:nil repeats:NO];
    }];
}

- (void)pubNubSubscribeWithState{
    [self.client subscribeToChannels:@[_channel1] withPresence:NO clientState: @{_channel1: @{@"foo":@"bar"}}];
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pubNubSetRandomState) userInfo:nil repeats:NO];
}

- (void)pubNubSubscribeToChannelGroups {
    [self.client subscribeToChannelGroups:@[@"myChannelGroup"] withPresence:NO];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pubNubUnsubFromChannelGroups) userInfo:nil repeats:NO];
}

- (void)pubNubUnsubFromChannelGroups {
    [self.client unsubscribeFromChannelGroups:@[@"myChannelGroup"] withPresence:NO];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pubNubSubscribeToChannelGroups) userInfo:nil repeats:NO];
}

- (void)pubNubSubscribeToPresence {
    [self.client subscribeToPresenceChannels:@[_channel1]];
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pubNubUnsubFromPresence) userInfo:nil repeats:NO];
}

- (void)pubNubUnsubFromPresence {
    [self.client unsubscribeFromPresenceChannels:@[_channel1]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pubNubSubscribeToPresence) userInfo:nil repeats:NO];
}

- (void)pubNubInit {

    [PNLog enabled:YES];
    [PNLog setMaximumLogFileSize:10];
    [PNLog setMaximumNumberOfLogFiles:10];

    // Initialize PubNub client.
    self.myConfig = [PNConfiguration configurationWithPublishKey:_pubKey subscribeKey:_subKey];

    [self updateClientConfiguration];
    [self printClientConfiguration];

    // Bind config
    self.client = [PubNub clientWithConfiguration:self.myConfig];

    // Bind didReceiveMessage, didReceiveStatus, and didReceivePresenceEvent 'listeners' to this delegate
    // just be sure the target has implemented the PNObjectEventListener extension
    [self.client addListeners:@[self]];

}

- (void)pubNubSubscribeToChannels {
    // Subscribe
    [self.client subscribeToChannels:@[_channel1] withPresence:NO];
}

- (void)pubNubSubscribeToChannelGroup {
    // Subscribe
    [self.client subscribeToChannelGroups:@[@"myChannelGroup"] withPresence:NO];
}



- (void)pubNubWhereNow {
    [self.client whereNowUUID:@"123456" withCompletion:^(PNResult <PNWhereNowResult> *result, PNStatus <PNStatus> *status) {

        if (status) {
            // As a status, this contains error or non-error information about the history request, but not the actual history data I requested.
            // Timeout Error, PAM Error, etc.

            [self handleStatus:status];
        }
        else if (result) {
            // As a result, this contains the messages, start, and end timetoken in the data attribute

            NSLog(@"^^^^ Loaded whereNow data: %@", result.data.channels);  // TODO: Call out data attributes here


        }
    }];
}

- (void)pubNubCGRemoveSomeChannels {
    [self.client removeChannels:@[_channel2] fromGroup:@"myChannelGroup" withCompletion:^(PNStatus <PNStatus> *status) {

        if (!status.isError) {
            NSLog(@"^^^^CG Remove Some Channels request succeeded at timetoken %@.", status.data);
        } else {
            NSLog(@"^^^^CG Remove Some Channels request did not succeed. All subscribe operations will autoretry when possible.");
            [self handleStatus:status];
        }
    }];
}

- (void)pubNubCGRemoveAllChannels {

    [self.client removeChannelsFromGroup:@"myChannelGroup" withCompletion:^(PNStatus <PNStatus> *status) {
        if (!status.isError) {
            NSLog(@"^^^^CG Remove All Channels request succeeded at timetoken %@.", status.data.channels);
        } else {
            NSLog(@"^^^^CG Remove All Channels request did not succeed. All subscribe operations will autoretry when possible.");
            [self handleStatus:status];
        }
    }];
}


- (void)pubNubCGAdd {

    __weak __typeof(self) weakSelf = self;
    [self.client addChannels:@[_channel1, _channel2] toGroup:@"myChannelGroup" withCompletion:^(PNStatus <PNStatus> *status) {
        if (!status.isError) {
            NSLog(@"^^^^CGAdd request succeeded at timetoken %@.", status.data.channels);
        } else {
            NSLog(@"^^^^CGAdd Subscribe request did not succeed. All subscribe operations will autoretry when possible.");
            [weakSelf handleStatus:status];
        }

    }];
}

- (void)pubNubHereNowForChannelWithVerbosity {
    // If you want to control the 'verbosity' of the server response -- restrict to (values are additive):

    // Occupancy                : PNHereNowOccupancy
    // Occupancy + UUID         : PNHereNowUUID
    // Occupancy + UUID + State : PNHereNowState

    [self.client hereNowForChannel:_channel1 withVerbosity:PNHereNowState completion:^(PNResult <PNHereNowResult> *result, PNStatus <PNStatus> *status) {
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded hereNowForChannel data: occupancy: %@, uuids: %@", result.data.occupancy, result.data.uuids);
        }
    }];
}

- (void)pubNubHereNowForChannel {

    [self.client hereNowForChannel:_channel1 withCompletion:^(PNResult <PNHereNowResult> *result, PNStatus <PNStatus> *status) {
        if (status) {

            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded hereNowForChannel data: occupancy: %@, uuids: %@", result.data.occupancy, result.data.uuids);
        }
    }];
}

- (void)pubNubGlobalHereNowWithVerbosity {

    // If you want to control the 'verbosity' of the server response -- restrict to (values are additive):

    // Occupancy                : PNHereNowOccupancy
    // Occupancy + UUID         : PNHereNowUUID
    // Occupancy + UUID + State : PNHereNowState

    [self.client hereNowWithVerbosity:PNHereNowOccupancy completion:^(PNResult <PNGlobalHereNowResult> *result, PNStatus <PNStatus> *status) {
    if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded Global hereNow data: channels: %@, total channels: %@, total occupancy: %@", result.data.channels, result.data.totalChannels, result.data.totalOccupancy);
        }
    }];
}

- (void)pubNubGlobalHereNow {

    [self.client hereNowWithCompletion:^(PNResult <PNGlobalHereNowResult> *result, PNStatus <PNStatus> *status) {
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded Global hereNow data: channels: %@, total channels: %@, total occupancy: %@", result.data.channels, result.data.totalChannels, result.data.totalOccupancy);
        }
    }];
}

- (void)pubNubHistory {
    // History

    [self.client historyForChannel:_channel1 withCompletion:^(PNResult <PNHistoryResult> *result, PNStatus <PNStatus> *status) {

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

    [self.client timeWithCompletion:^(PNResult <PNTimeResult> *result, PNStatus <PNStatus> *status) {
        if (result.data) {
            NSLog(@"Result from Time: %@", result.data.timetoken);
        }
        else if (status) {
            [self handleStatus:status];
        }
    }];
}

- (void)publishHelloWorld {
    [self.client publish:@"Connected! I'm here!" toChannel:_channel1
          withCompletion:^(PNStatus <PNPublishStatus> *status) {
              if (!status.isError) {
                  NSLog(@"Message sent at TT: %@", status.data.timetoken);
              } else {
                  [self handleStatus:status];
              }
          }];
}

#pragma mark - Streaming Data didReceiveMessage Listener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult <PNMessageResult>*)message
    withStatus:(PNStatus<PNStatus> *)status {

    if (status) {
        [self handleStatus:status];
    } else if (message) {
        NSLog(@"Received message: %@", message.data.message);
    }
}

#pragma mark - Streaming Data didReceivePresenceEvent Listener

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult <PNPresenceEventResult> *)event {
    // TODO detail fields in data that depict the Presence event

    NSLog(@"^^^^^ Did receive presence event: %@", event.data);
}

#pragma mark - Streaming Data didReceiveStatus Listener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus <PNSubscriberStatus> *)status {

    // This is where we'll find ongoing status events from our subscribe loop
    // Results (messages) from our subscribe loop will be found in didReceiveMessage
    // Results (presence events) from our subscribe loop will be found in didReceiveStatus

    [self handleStatus:status];
}

#pragma mark - example status handling

- (void)handleStatus:(PNStatus<PNStatus> *)status {

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

- (void)handleErrorStatus:(PNStatus<PNStatus> *)status {


    NSLog(@"^^^^ Debug: %@", status.debugDescription);
    NSLog(@"^^^^ handleErrorStatus: PAM Error: for resource Will Auto Retry?: %@", status.willAutomaticallyRetry ? @"YES" : @"NO");

    if (status.category == PNAccessDeniedCategory) {
        [self handlePAMError:status];
    }
    else if (status.category == PNDecryptionErrorCategory) {

        NSLog(@"Decryption error. Be sure the data is encrypted and/or encrypted with the correct cipher key.");
        NSLog(@"You can find the raw data returned from the server in the status.data attribute: %@", status.data);
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

- (void)handlePAMError:(PNStatus<PNStatus> *)status {
    // Access Denied via PAM. Access status.data to determine the resource in question that was denied.
    // In addition, you can also change auth key dynamically if needed."

    NSString *pamResourceName = status.data.channels ? status.data.channels[0] : status.data.channelGroups;
    NSString *pamResourceType = status.data.channels ? @"channel" : @"channel-groups";

    NSLog(@"PAM error on %@ %@", pamResourceType, pamResourceName);

    // If its a PAM error on subscribe, lets grab the channel name in question, and unsubscribe from it, and re-subscribe to a channel that we're authed to

    if (status.operation == PNSubscribeOperation) {

        if ([pamResourceType isEqualToString:@"channel"]) {
            NSLog(@"^^^^ Unsubscribing from %@", pamResourceName);
            [self reconfigOnPAMError:status];
        }

        else {
            [self.client unsubscribeFromChannelGroups:@[pamResourceName] withPresence:YES];
            // the case where we're dealing with CGs instead of CHs... follows the same pattern as above
        }

    } else if (status.operation == PNPublishOperation) {

        NSLog(@"^^^^ Error publishing with authKey: %@ to channel %@.", _authKey, pamResourceName);
        NSLog(@"^^^^ Setting auth to an authKey that will allow for both sub and pub");
        // TODO Fix:
        // [self.client setAuthKey:@"myAuthKeyForPubAndSubToChannelGood"];

        [self reconfigOnPAMError:status];
    }
}

- (void)reconfigOnPAMError:(PNStatus <PNStatus> *)status {


    // If this is a subscribe PAM error

    if (status.operation == PNSubscribeOperation) {

        PNStatus<PNSubscriberStatus> *subscriberStatus = ( PNStatus<PNSubscriberStatus> *)status;

        NSArray *currentChannels = subscriberStatus.subscribedChannels;
        NSArray *currentChannelGroups = subscriberStatus.subscribedChannelGroups;

        // TODO: Implement a proper "LEAVE" in the helper method for better presence support

        self.myConfig.authKey = @"myAuthKey";

        [self.client copyWithConfiguration:self.myConfig completion:^(PubNub *client){

            self.client = client;

            [self.client subscribeToChannels:currentChannels withPresence:NO];
            [self.client subscribeToChannelGroups:currentChannelGroups withPresence:NO];
        }];
    }

}

- (void)handleNonErrorStatus:(PNStatus<PNStatus> *)status {

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

        PNStatus<PNSubscriberStatus> *subscriberStatus = ( PNStatus<PNSubscriberStatus> *)status;
        // Specific to the subscribe loop operation, you can handle connection events
        // These status checks are only available via the subscribe status completion block or
        // on the long-running subscribe loop listener didReceiveStatus

        // Connection events are never defined as errors via status.isError

        if (status.category == PNDisconnectedCategory) {
            // PNDisconnect happens as part of our regular operation
            // No need to monitor for this unless requested by support
            NSLog(@"^^^^ Non-error status: Expected Disconnect, Channel Info: %@",
                    subscriberStatus.subscribedChannels);
        }

        else if (status.category == PNUnexpectedDisconnectCategory) {
            // PNUnexpectedDisconnect happens as part of our regular operation
            // This event happens when radio / connectivity is lost

            NSLog(@"^^^^ Non-error status: Unexpected Disconnect, Channel Info: %@",
                    subscriberStatus.subscribedChannels);
        }

        else if (status.category == PNConnectedCategory) {

            // Connect event. You can do stuff like publish, and know you'll get it.
            // Or just use the connected event to confirm you are subscribed for UI / internal notifications, etc

            // NSLog(@"Subscribe Connected to %@", status.data[@"channels"]);
            NSLog(@"^^^^ Non-error status: Connected, Channel Info: %@",
                    subscriberStatus.subscribedChannels);
            [self publishHelloWorld];

        }
        else if (status.category == PNReconnectedCategory) {

            // PNUnexpectedDisconnect happens as part of our regular operation
            // This event happens when radio / connectivity is lost

            NSLog(@"^^^^ Non-error status: Reconnected, Channel Info: %@",
                    subscriberStatus.subscribedChannels);

        }

    }

}

#pragma mark - Configuration

- (void)updateClientConfiguration {

    // Set PubNub Configuration
    self.myConfig.TLSEnabled = NO;
    self.myConfig.uuid = [self randomString];
    self.myConfig.origin = @"pubsub.pubnub.com";
    self.myConfig.authKey = _authKey;

    // Presence Settings
    self.myConfig.presenceHeartbeatValue = 120;
    self.myConfig.presenceHeartbeatInterval = 60;

    // Cipher Key Settings
    //self.client.cipherKey = @"enigma";

    // Time Token Handling Settings
    self.myConfig.keepTimeTokenOnListChange = YES;
    self.myConfig.restoreSubscription = YES;
    self.myConfig.catchUpOnSubscriptionRestore = YES;
}

- (NSString *)randomString {
    return [NSString stringWithFormat:@"%d", arc4random_uniform(74)];
}

- (void)printClientConfiguration {

    // Get PubNub Options
    NSLog(@"TLSEnabled: %@", (self.myConfig.isTLSEnabled ? @"YES" : @"NO"));
    NSLog(@"Origin: %@", self.myConfig.origin);
    NSLog(@"authKey: %@", self.myConfig.authKey);
    NSLog(@"UUID: %@", self.myConfig.uuid);

    // Time Token Handling Settings
    NSLog(@"keepTimeTokenOnChannelChange: %@",
            (self.myConfig.shouldKeepTimeTokenOnListChange ? @"YES" : @"NO"));
    NSLog(@"resubscribeOnConnectionRestore: %@",
            (self.myConfig.shouldRestoreSubscription ? @"YES" : @"NO"));
    NSLog(@"catchUpOnSubscriptionRestore: %@",
            (self.myConfig.shouldTryCatchUpOnSubscriptionRestore ? @"YES" : @"NO"));

    // Get Presence Options
    NSLog(@"Heartbeat value: %@", @(self.myConfig.presenceHeartbeatValue));
    NSLog(@"Heartbeat interval: %@", @(self.myConfig.presenceHeartbeatInterval));

    // Get CipherKey
    NSLog(@"Cipher key: %@", self.myConfig.cipherKey);
}

#pragma mark -

@end
