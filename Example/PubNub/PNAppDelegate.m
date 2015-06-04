//
//  PNAppDelegate.m
//  PubNub
//
//  Created by CocoaPods on 06/03/2015.
//  Copyright (c) 2014 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>

#import "PNAppDelegate.h"

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
    
    // self.channel1 = @"bad";
    // self.channel2 = @"good";
    // self.pubKey = @"pam";
    // self.subKey = @"pam";
    // self.authKey = @"myAuthKey";
    
#pragma mark - Non-PAM Use Case Config
    
    // Settings Config for Non-PAM Example
    self.channel1 = @"bot";
    self.channel2 = @"myCh";
    self.pubKey = @"demo-36";
    self.subKey = @"demo-36";
    self.authKey = @"myAuthKey";
    
    [self tireKicker];
    return YES;
}

- (void)tireKicker {
    [self pubNubInit];
        [self pubNubTime];
    //    [self pubNubHistory];
    //    [self pubNubHereNow];
    //    [self pubNubCGAdd];
    //    [self pubNubCGRemoveAllChannels];
    //    [self pubNubCGRemoveSomeChannels];
    //    [self pubNubWhereNow];
    
    [self pubNubSubscribe];
}

- (void)pubNubInit {
    // Initialize PubNub client.
    // Initialize PubNub client.
    self.myConfig = [PNConfiguration configurationWithPublishKey:_pubKey subscribeKey:_subKey];
    
    // Bind didReceiveMessage, didReceiveStatus, and didReceivePresenceEvent 'listeners' to this delegate
    // just be sure the target has implemented the PNObjectEventListener extension
    
    [self.client addListeners:@[self]];
    
    [PNLog enableLogLevel:PNRequestLogLevel];
    [self updateClientConfiguration];
    [self printClientConfiguration];
    
    self.client = [PubNub clientWithConfiguration:self.myConfig];
    
}

- (void)pubNubSubscribe {
    // Subscribe
    
    [self.client subscribeToChannels:@[_channel1] withPresence:NO];
    
}

- (void)pubNubWhereNow {
    
    [self.client whereNowUUID:@"12345" withCompletion:^(PNResult<PNWhereNowResult> *result,
                                                        PNStatus<PNStatus> *status) {
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
    
    [self.client removeChannels:@[_channel2] fromGroup:@"myChannelGroup"
                 withCompletion:^(PNStatus<PNStatus> *status) {
        
         if (!status.isError) {
             NSLog(@"^^^^CG Remove Some Channels request succeeded at timetoken");
         } else {
             NSLog(@"^^^^CG Remove Some Channels request did not succeed. All subscribe operations will autoretry when possible.");
             [self handleStatus:status];
         }
    }];
}

- (void)pubNubCGRemoveAllChannels {
    
    [self.client removeChannelsFromGroup:@"myChannelGroup" withCompletion:^(PNStatus<PNStatus> *status) {

        if (!status.isError) {
            NSLog(@"^^^^CG Remove All Channels request succeeded at timetoken");
        } else {
            NSLog(@"^^^^CG Remove All Channels request did not succeed. All subscribe operations will autoretry when possible.");
            [self handleStatus:status];
        }
    }];
}


- (void)pubNubCGAdd {
    
    __weak typeof (self) wself = self;
    [self.client addChannels:@[_channel1, _channel2] toGroup:@"myChannelGroup"
              withCompletion:^(PNStatus<PNStatus> *status) {
                  
          if (!status.isError) {
              NSLog(@"^^^^CGAdd request succeeded at timetoken.");
          } else {
              NSLog(@"^^^^CGAdd Subscribe request did not succeed. All subscribe operations will autoretry when possible.");
              [wself handleStatus:status];
          }
        
    }];
}

- (void)pubNubHereNow {
    
    [self.client hereNowForChannel:_channel1 withCompletion:^(PNResult<PNHereNowResult> *result, PNStatus<PNStatus> *status) {
        
        if (status) {
            // As a status, this contains error or non-error information about the history request, but not the actual history data I requested.
            // Timeout Error, PAM Error, etc.
            
            [self handleStatus:status];
        }
        else if (result) {
            // As a result, this contains the messages, start, and end timetoken in the data attribute
            
            NSLog(@"^^^^ Loaded hereNowForChannel data: %@", result.data);  // TODO: Call out data attributes here
        }
    }];
}

- (void)pubNubHistory {
    
    // History
    [self.client historyForChannel:_channel1
                    withCompletion:^(PNResult<PNHistoryResult> *result, PNStatus<PNStatus> *status) {
        
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
    [self.client timeWithCompletion:^(PNResult<PNTimeResult> *result, PNStatus<PNStatus> *status) {
        
        if (result.data) {
            NSLog(@"Result from Time: %@", result.data.timetoken);
        }
        else if (status) {
            
            [self handleStatus:status];
        }
    }];
}

- (void)publishHelloWorld {
    
    [self.client publish:@"I'm here!" toChannel:_channel1
          withCompletion:^(PNStatus<PNPublishStatus> *status) {
        
        if (!status.isError) {
            
            NSLog(@"Message sent at TT: %@", status.data.timetoken);
        }
        else {
            
            [self handleStatus:status];
        }
    }];
}

#pragma mark - Streaming Data didReceiveMessage Listener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult<PNMessageResult> *)message
    withStatus:(PNStatus<PNStatus> *)status {
    
    if (status) {
        [self handleStatus:status];
    } else if (message) {
        NSLog(@"Received message: %@", message.data);
    }
}

#pragma mark - Streaming Data didReceivePresenceEvent Listener

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult<PNPresenceEventResult> *)event {
    // TODO detail fields in data that depict the Presence event
    
    NSLog(@"Did receive presence event: %@", event.data);
}

#pragma mark - Streaming Data didReceiveStatus Listener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus<PNSubscriberStatus> *)status {
    
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
            [self.client unsubscribeFromChannels:@[pamResourceName] withPresence:YES];
            [self.client subscribeToChannels:@[_channel2] withPresence:NO];
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
    self.myConfig.TLSEnabled = YES;
    self.myConfig.origin = @"ios4.pubnub.com";
    self.myConfig.authKey = _authKey;
    self.myConfig.uuid = @"ios4.0Tutorial";
    
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

- (void)printClientConfiguration {
    
    // Get PubNub Options
    NSLog(@"SSELEnabled: %@", (self.myConfig.isTLSEnabled ? @"YES" : @"NO"));
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
