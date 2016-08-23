//
//  AppDelegate.m
//  PubNub Mac Example
//
//  Created by Jordan Zucker on 11/3/15.
//  Copyright © 2015 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "AppDelegate.h"

@interface AppDelegate () <PNObjectEventListener>

#pragma mark - Properties

@property(nonatomic, strong) PubNub *client;
@property(nonatomic, strong) NSString *channel1;
@property(nonatomic, strong) NSString *channel2;
@property(nonatomic, strong) NSString *channelGroup1;
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

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
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
    self.channelGroup1 = @"myChannelGroup";
    self.pubKey = @"demo-36";
    self.subKey = @"demo-36";
    self.authKey = @"myAuthKey";
    
    
    
    
#pragma mark - Kick the Tires!
    
    [self tireKicker];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)pubNubInit {
    
    // Initialize PubNub client.
    self.myConfig = [PNConfiguration configurationWithPublishKey:_pubKey subscribeKey:_subKey];
    
    [self updateClientConfiguration];
    [self printClientConfiguration];
    
    // Bind config
    self.client = [PubNub clientWithConfiguration:self.myConfig];
    
    // Configure logger
    self.client.logger.enabled = YES;
    self.client.logger.writeToFile = YES;
    self.client.logger.maximumLogFileSize = (10 * 1024 * 1024);
    self.client.logger.maximumNumberOfLogFiles = 10;
    [self.client.logger setLogLevel:PNVerboseLogLevel];
    
    // Bind didReceiveMessage, didReceiveStatus, and didReceivePresenceEvent 'listeners' to this delegate
    // just be sure the target has implemented the PNObjectEventListener extension
    [self.client addListener:self];
    [self pubNubSetState];
}

- (void)tireKicker {
    [self pubNubInit];
    
#pragma mark - Time
    
    [self pubNubTime];
    
#pragma mark - Publish
    [self pubNubPublish];
    
#pragma mark - History
    
    [self pubNubHistory];
    
#pragma mark - Channel Groups Subscribe / Unsubscribe
    
    [self pubNubSubscribeToChannelGroup];
    [self pubNubUnsubFromChannelGroups];
    
#pragma mark - Channel Subscribe / Unsubscribe
    
    [self pubNubSubscribeToChannels];
    [self pubNubUnsubscribeFromChannels];
    
#pragma mark - Presence Subscribe / Unsubscribe
    
    [self pubNubSubscribeToPresence];
    [self pubNubUnsubFromPresence];
    
#pragma mark - Here Nows
    
    [self pubNubHereNowForChannel];
    [self pubNubGlobalHereNow];
    [self pubNubHereNowForChannelGroups];
    [self pubNubWhereNow];
    
#pragma mark - CG Admin
    
    [self pubNubCGAdd];
    [self pubNubChannelsForGroup];
    [self pubNubCGRemoveAllChannels];
    [self pubNubCGRemoveSomeChannels];
    
#pragma mark - State Admin
    [self pubNubSetState];
    [self pubNubGetState];
    
    
#pragma mark - 3rd Party Push Notifications Admin
    
    [self pubNubAddPushNotifications];
    [self pubNubRemovePushNotification];
    [self pubNubRemoveAllPushNotifications];
    [self pubNubGetAllPushNotifications];
    
#pragma mark - Public Encryption/Decryption Methods
    
    [self pubNubAESDecrypt];
    [self pubNubAESEncrypt];
    
#pragma mark - Message Size Check Methods
    
    [self pubNubSizeOfMessage];
    
}

- (void)pubNubSizeOfMessage{
    
    [self.client sizeOfMessage:@"Connected! I'm here!" toChannel:_channel1
                withCompletion:^(NSInteger size) {
                    
                    NSLog(@"^^^^ Message size: %@", @(size));
                }];
}

- (void)pubNubAESDecrypt{
    /*
     [PNAES decrypt:<#(NSString *)object#> withKey:<#(NSString *)key#>];
     [PNAES decrypt:<#(NSString *)object#> withKey:<#(NSString *)key#> andError:<#(NSError *__autoreleasing *)error#>];
     */
}

- (void)pubNubAESEncrypt{
    /*
     [PNAES encrypt:<#(NSData *)data#> withKey:<#(NSString *)key#>];
     [PNAES encrypt:<#(NSData *)data#> withKey:<#(NSString *)key#> andError:<#(NSError *__autoreleasing *)error#>];
     */
}

- (void)pubNubAddPushNotifications {
    /*
     [self.client addPushNotificationsOnChannels:<#(NSArray *)channels#> withDevicePushToken:<#(NSData *)pushToken#> andCompletion:<#(PNPushNotificationsStateModificationCompletionBlock)block#>];
     */
}

- (void)pubNubRemovePushNotification {
    /*
     [self.client removePushNotificationsFromChannels:<#(NSArray *)channels#> withDevicePushToken:<#(NSData *)pushToken#> andCompletion:<#(PNPushNotificationsStateModificationCompletionBlock)block#>];
     */
}

- (void)pubNubRemoveAllPushNotifications {
    /*
     [self.client removeAllPushNotificationsFromDeviceWithPushToken:<#(NSData *)pushToken#> andCompletion:<#(PNPushNotificationsStateModificationCompletionBlock)block#>];
     */
}

- (void)pubNubGetAllPushNotifications {
    /*
     [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:<#(NSData *)pushToken#> andCompletion:<#(PNPushNotificationsStateAuditCompletionBlock)block#>];
     */
}

- (void)pubNubSetState {
    
    __weak __typeof(self) weakSelf = self;
    [self.client setState:@{[self randomString] : @{[self randomString] : [self randomString]}} forUUID:_myConfig.uuid onChannel:_channel1 withCompletion:^(PNClientStateUpdateStatus *status) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf handleStatus:status];
    }];
}

- (void)pubNubGetState{
    
    [self.client stateForUUID:_myConfig.uuid onChannel:_channel1
               withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
                   
                   if (status) {
                       [self handleStatus:status];
                   }
                   else if (result) {
                       
                       NSLog(@"^^^^ Loaded state %@ for channel %@", result.data.state, self->_channel1);
                   }
                   
               }];
    
    /*
     [self.client stateForUUID:<#(NSString *)uuid#> onChannelGroup:<#(NSString *)group#> withCompletion:<#(PNChannelGroupStateCompletionBlock)block#>];
     */
}



- (void)pubNubUnsubFromChannelGroups {
    [self.client unsubscribeFromChannelGroups:@[@"myChannelGroup"] withPresence:NO];
    
    
}

- (void)pubNubSubscribeToPresence {
    [self.client subscribeToPresenceChannels:@[_channel1]];
}

- (void)pubNubUnsubFromPresence {
    [self.client unsubscribeFromPresenceChannels:@[_channel1]];
}



- (void)pubNubSubscribeToChannels {
    [self.client subscribeToChannels:@[_channel1] withPresence:YES clientState:@{_channel1:@{@"foo":@"bar"}}];
    
    /*
     [self.client subscribeToChannels:<#(NSArray *)channels#> withPresence:<#(BOOL)shouldObservePresence#>];
     [self.client isSubscribedOn:<#(NSString *)name#>]
     */
    
}

- (void)pubNubUnsubscribeFromChannels {
    [self.client unsubscribeFromChannels:@[_channel1] withPresence:YES];
}

- (void)pubNubSubscribeToChannelGroup {
    [self.client subscribeToChannelGroups:@[_channelGroup1] withPresence:NO];
    /*
     [self.client subscribeToChannelGroups:@[_channelGroup1] withPresence:YES clientState:@{@"foo":@"bar"}];
     */
    
}



- (void)pubNubWhereNow {
    [self.client whereNowUUID:@"123456" withCompletion:^(PNPresenceWhereNowResult *result,
                                                         PNErrorStatus *status) {
        
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded whereNow data: %@", result.data.channels);
        }
    }];
}

- (void)pubNubCGRemoveSomeChannels {
    
    [self.client removeChannels:@[_channel2] fromGroup:_channelGroup1 withCompletion:^(PNAcknowledgmentStatus *status) {
        
        
        if (!status.isError) {
            NSLog(@"^^^^CG Remove Some Channels request succeeded at timetoken %@.", status);
        } else {
            NSLog(@"^^^^CG Remove Some Channels request did not succeed. All subscribe operations will autoretry when possible.");
            [self handleStatus:status];
        }
    }];
}

- (void)pubNubCGRemoveAllChannels {
    
    [self.client removeChannelsFromGroup:_channelGroup1
                          withCompletion:^(PNAcknowledgmentStatus *status) {
                              
                              if (!status.isError) {
                                  NSLog(@"^^^^CG Remove All Channels request succeeded");
                              } else {
                                  NSLog(@"^^^^CG Remove All Channels request did not succeed. All subscribe operations will autoretry when possible.");
                                  [self handleStatus:status];
                              }
                          }];
}


- (void)pubNubCGAdd {
    
    __weak __typeof(self) weakSelf = self;
    [self.client addChannels:@[_channel1, _channel2] toGroup:_channelGroup1
              withCompletion:^(PNAcknowledgmentStatus *status) {
                  
                  __strong __typeof(self) strongSelf = weakSelf;
                  
                  if (!status.isError) {
                      
                      NSLog(@"^^^^CGAdd request succeeded");
                  }
                  else {
                      
                      NSLog(@"^^^^CGAdd Subscribe request did not succeed. All subscribe operations will autoretry when possible.");
                      [strongSelf handleStatus:status];
                  }
              }];
    
}

- (void)pubNubChannelsForGroup {
    
    [self.client channelsForGroup:_channelGroup1
                   withCompletion:^(PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
                       if (status) {
                           [self handleStatus:status];
                       }
                       else if (result) {
                           NSLog(@"^^^^ Loaded all channels %@ for group %@",
                                 result.data.channels, self->_channelGroup1);
                       }
                   }];
}

- (void)pubNubHereNowForChannel {
    
    [self.client hereNowForChannel:_channel1 withCompletion:^(PNPresenceChannelHereNowResult *result,
                                                              PNErrorStatus *status) {
        if (status) {
            
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded hereNowForChannel data: occupancy: %@, uuids: %@", result.data.occupancy, result.data.uuids);
        }
    }];
    
    // If you want to control the 'verbosity' of the server response -- restrict to (values are additive):
    
    // Occupancy                : PNHereNowOccupancy
    // Occupancy + UUID         : PNHereNowUUID
    // Occupancy + UUID + State : PNHereNowState
    
    [self.client hereNowForChannel:_channel1 withVerbosity:PNHereNowState
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                            if (status) {
                                [self handleStatus:status];
                            }
                            else if (result) {
                                NSLog(@"^^^^ Loaded hereNowForChannel data: occupancy: %@, uuids: %@", result.data.occupancy, result.data.uuids);
                            }
                        }];
    
}


- (void)pubNubGlobalHereNow {
    
    [self.client hereNowWithCompletion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded Global hereNow data: channels: %@, total channels: %@, total occupancy: %@", result.data.channels, result.data.totalChannels, result.data.totalOccupancy);
        }
    }];
    
    // If you want to control the 'verbosity' of the server response -- restrict to (values are additive):
    
    // Occupancy                : PNHereNowOccupancy
    // Occupancy + UUID         : PNHereNowUUID
    // Occupancy + UUID + State : PNHereNowState
    
    [self.client hereNowWithVerbosity:PNHereNowOccupancy completion:^(PNPresenceGlobalHereNowResult *result,
                                                                      PNErrorStatus *status) {
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded Global hereNow data: channels: %@, total channels: %@, total occupancy: %@", result.data.channels, result.data.totalChannels, result.data.totalOccupancy);
        }
    }];
    
}

- (void)pubNubHereNowForChannelGroups{
    /*
     [self.client hereNowForChannelGroup:<#(NSString *)group#> withCompletion:<#(PNChannelGroupHereNowCompletionBlock)block#>];
     [self.client hereNowForChannelGroup:<#(NSString *)group#> withVerbosity:<#(PNHereNowVerbosityLevel)level#> completion:<#(PNChannelGroupHereNowCompletionBlock)block#>];
     */
}


- (void)pubNubHistory {
    // History
    
    [self.client historyForChannel:_channel1 withCompletion:^(PNHistoryResult *result,
                                                              PNErrorStatus *status) {
        
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
            
            NSLog(@"Loaded history data: %@ with start %@ and end %@", result.data.messages, result.data.start, result.data.end);
        }
    }];
    
    /*
     [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> includeTimeToken:<#(BOOL)shouldIncludeTimeToken#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
     [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> limit:<#(NSUInteger)limit#> includeTimeToken:<#(BOOL)shouldIncludeTimeToken#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
     [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> limit:<#(NSUInteger)limit#> reverse:<#(BOOL)shouldReverseOrder#> includeTimeToken:<#(BOOL)shouldIncludeTimeToken#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
     [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> limit:<#(NSUInteger)limit#> reverse:<#(BOOL)shouldReverseOrder#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
     [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> limit:<#(NSUInteger)limit#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
     [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
     [self.client historyForChannel:<#(NSString *)channel#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
     */
    
}


- (void)pubNubTime {
    
    [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
        if (result.data) {
            NSLog(@"Result from Time: %@", result.data.timetoken);
        }
        else if (status) {
            [self handleStatus:status];
        }
    }];
}

- (void)pubNubPublish {
    [self.client publish:@"Connected! I'm here!" toChannel:_channel1
          withCompletion:^(PNPublishStatus *status) {
              if (!status.isError) {
                  NSLog(@"Message sent at TT: %@", status.data.timetoken);
              } else {
                  [self handleStatus:status];
              }
          }];
    
    /*
     [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
     [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> withCompletion:<#(PNPublishCompletionBlock)block#>];
     [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> storeInHistory:<#(BOOL)shouldStore#> withCompletion:<#(PNPublishCompletionBlock)block#>];
     [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> storeInHistory:<#(BOOL)shouldStore#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
     [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> withCompletion:<#(PNPublishCompletionBlock)block#>];
     [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
     [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> storeInHistory:<#(BOOL)shouldStore#> withCompletion:<#(PNPublishCompletionBlock)block#>];
     [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> storeInHistory:<#(BOOL)shouldStore#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
     */
    
}

#pragma mark - Streaming Data didReceiveMessage Listener

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    if (message) {
        
        NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,
              message.data.subscribedChannel, message.data.timetoken);
    }
}

#pragma mark - Streaming Data didReceivePresenceEvent Listener

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
    NSLog(@"^^^^^ Did receive presence event: %@", event.data.presenceEvent);
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
    
    //    Two types of status events are possible. Errors, and non-errors. Errors will prevent normal operation of your app.
    //
    //    If this was a subscribe or presence PAM error, the system will continue to retry automatically.
    //    If this was any other operation, you will need to manually retry the operation.
    //
    //    You can always verify if an operation will auto retry by checking status.willAutomaticallyRetry
    //    If the operation will not auto retry, you can manually retry by calling [status retry]
    //    Retry attempts can be cancelled via [status cancelAutomaticRetry]
    
    if (status.isError) {
        [self handleErrorStatus:(PNErrorStatus *)status];
    } else {
        [self handleNonErrorStatus:status];
    }
    
}

- (void)handleErrorStatus:(PNErrorStatus *)status {
    
    NSLog(@"^^^^ Debug: %@", status.debugDescription);
    
    if (status.category == PNAccessDeniedCategory) {
        
        NSLog(@"^^^^ handleErrorStatus: PAM Error: for resource Will Auto Retry?: %@", status.willAutomaticallyRetry ? @"YES" : @"NO");
        
        [self handlePAMError:status];
    }
    else if (status.category == PNDecryptionErrorCategory) {
        
        NSLog(@"Decryption error. Be sure the data is encrypted and/or encrypted with the correct cipher key.");
        NSLog(@"You can find the raw data returned from the server in the status.data attribute: %@", status.associatedObject);
        if (status.operation == PNSubscribeOperation) {
            
            NSLog(@"Decryption failed for message from channel: %@",
                  ((PNMessageData *)status.associatedObject).subscribedChannel);
        }
    }
    else if (status.category == PNMalformedFilterExpressionCategory) {
        
        NSLog(@"Value which has been passed to -setFilterExpression: malformed.");
        NSLog(@"Please verify specified value with declared filtering expression syntax.");
    }
    else if (status.category == PNMalformedResponseCategory) {
        
        NSLog(@"We were expecting JSON from the server, but we got HTML, or otherwise not legal JSON.");
        NSLog(@"This may happen when you connect to a public WiFi Hotspot that requires you to auth via your web browser first,");
        NSLog(@"or if there is a proxy somewhere returning an HTML access denied error, or if there was an intermittent server issue.");
    }
    
    else if (status.category == PNTimeoutCategory) {
        
        NSLog(@"For whatever reason, the request timed out. Temporary connectivity issues, etc.");
    }
    else if (status.category == PNNetworkIssuesCategory) {
        
        NSLog(@"Request can't be processed because of network issues.");
    }
    else {
        // Aside from checking for PAM, this is a generic catch-all if you just want to handle any error, regardless of reason
        // status.debugDescription will shed light on exactly whats going on
        
        NSLog(@"Request failed... if this is an issue that is consistently interrupting the performance of your app,");
        NSLog(@"email the output of debugDescription to support along with all available log info: %@", [status debugDescription]);
    }
    if (status.operation == PNHeartbeatOperation) {
        
        NSLog(@"Heartbeat operation failed.");
    }
}

- (void)handlePAMError:(PNErrorStatus *)status {
    // Access Denied via PAM. Access status.data to determine the resource in question that was denied.
    // In addition, you can also change auth key dynamically if needed."
    
    NSString *pamResourceName = (status.errorData.channels ? status.errorData.channels.firstObject : 
                                 status.errorData.channelGroups.firstObject);
    NSString *pamResourceType = status.errorData.channels ? @"channel" : @"channel-groups";
    
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
        
        [self reconfigOnPAMError:status];
    }
}

- (void)reconfigOnPAMError:(PNErrorStatus *)status {
    
    
    // If this is a subscribe PAM error
    
    if (status.operation == PNSubscribeOperation) {
        
        PNSubscribeStatus *subscriberStatus = (PNSubscribeStatus *)status;
        
        NSArray *currentChannels = subscriberStatus.subscribedChannels;
        NSArray *currentChannelGroups = subscriberStatus.subscribedChannelGroups;
        
        self.myConfig.authKey = @"myAuthKey";
        
        [self.client copyWithConfiguration:self.myConfig completion:^(PubNub *client){
            
            self.client = client;
            
            [self.client subscribeToChannels:currentChannels withPresence:NO];
            [self.client subscribeToChannelGroups:currentChannelGroups withPresence:NO];
        }];
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
        
        PNSubscribeStatus *subscriberStatus = (PNSubscribeStatus *)status;
        // Specific to the subscribe loop operation, you can handle connection events
        // These status checks are only available via the subscribe status completion block or
        // on the long-running subscribe loop listener didReceiveStatus
        
        // Connection events are never defined as errors via status.isError
        if (status.category == PNUnexpectedDisconnectCategory) {
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
            [self pubNubPublish];
            
        }
        else if (status.category == PNReconnectedCategory) {
            
            // PNUnexpectedDisconnect happens as part of our regular operation
            // This event happens when radio / connectivity is lost
            
            NSLog(@"^^^^ Non-error status: Reconnected, Channel Info: %@",
                  subscriberStatus.subscribedChannels);
        }
    }
    else if (status.operation == PNUnsubscribeOperation) {
        
        if (status.category == PNDisconnectedCategory) {
            // PNDisconnect happens as part of our regular operation
            // No need to monitor for this unless requested by support
            NSLog(@"^^^^ Non-error status: Expected Disconnect");
        }
    }
    else if (status.operation == PNHeartbeatOperation) {
        
        NSLog(@"Heartbeat operation successful.");
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
    self.myConfig.presenceHeartbeatInterval = 5;
    
    // Cipher Key Settings
    //    self.myConfig.cipherKey = @"enigma";
    
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
