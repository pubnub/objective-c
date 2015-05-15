//
//  AppDelegate.m
//  ClientTest
//
//  Created by Sergey Mamontov on 5/2/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "PubNub.h"

@interface AppDelegate () <PNObjectEventListener>

@property (nonatomic, strong) PubNub *client;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Initialize PubNub client.
    self.client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    [self.client addListeners:@[self]];
    
    // Time
    [self.client timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        NSLog(@"Time: %@ (status: %@)", [result data], [status debugDescription]);
    }];
    
    // Message publish (compressed/not compressed and with 'cipherKey' from above encrypted)
    [self.client publish:@{@"Hello":@"world"} toChannel:@"HelloPubNub"
          withCompletion:^(PNStatus *status) {
              
              NSLog(@"Publish status: %@", [status debugDescription]);
          }];
    [self.client publish:@{@"I should":@"be compressed"} toChannel:@"HelloPubNub" compressed:YES
          withCompletion:^(PNStatus *status) {
              
              NSLog(@"Publish compressed status: %@", [status debugDescription]);
          }];
    
    // History (also decrypt messages from history)
    NSNumber *startDate = @(((NSUInteger)[[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970])*10000000);
    NSNumber *endDate = @(((NSUInteger)[[NSDate date] timeIntervalSince1970])*10000000);
    [self.client historyForChannel:@"HelloPubNub" start:startDate end:endDate includeTimeToken:YES
                    withCompletion:^(PNResult *result, PNStatus *status) {
                        
                        NSLog(@"History: %@ (status: %@)", [result data], [status debugDescription]);
                    }];
    
    // Client state manipulation (also available for channel group)
    [self.client setState:@{@"Very important":@"data"} forUUID:self.client.uuid
                onChannel:@"HelloPubNub" withCompletion:^(PNStatus *status) {
                    
                    NSLog(@"State update status: %@", [status debugDescription]);
                }];
    [self.client stateForUUID:self.client.uuid onChannel:@"HelloPubNub"
               withCompletion:^(PNResult *result, PNStatus *status) {
                   
                   NSLog(@"State fetch: %@ (status: %@)", [result data], [status debugDescription]);
               }];
    
    // APNS
    NSData *token = [@"00000000000000000000000000000000" dataUsingEncoding:NSUTF8StringEncoding];
    [self.client addPushNotificationsOnChannels:@[@"PubNub-Push1",@"PubNub-Push2"]
                            withDevicePushToken:token andCompletion:^(PNStatus *status) {
                                
                                NSLog(@"APNS enable status: %@", [status debugDescription]);
                            }];
    [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:token
                                                         andCompletion:^(PNResult *result, PNStatus *status) {
                                                             
                                                             NSLog(@"APNS enabled: %@ (status: %@)", [result data], [status debugDescription]);
                                                         }];
    [self.client removePushNotificationsFromChannels:@[@"PubNub-Push2"] withDevicePushToken:token
                                       andCompletion:^(PNStatus *status) {
                                           
                                           NSLog(@"APNS disable status: %@", [status debugDescription]);
                                       }];
    
    // Channel group
    [self.client addChannels:@[@"PubNub-fcg",@"PubNub-fcg"] toGroup:@"PubNub-cg"
              withCompletion:^(PNResult *result, PNStatus *status) {
                  
                  NSLog(@"Channel group channels list change: %@ (status: %@)", [result data], status);
              }];
    [self.client channelsForGroup:@"PubNub-cg" withCompletion:^(PNResult *result, PNStatus *status) {
        
        NSLog(@"Channel group channels audit: %@ (status: %@)", [result data], [status debugDescription]);
    }];
    
    // Presence
    [self.client hereNowData:PNHereNowUUID withCompletion:^(PNResult *result, PNStatus *status) {
        
        NSLog(@"Global here now: %@ (status: %@)", [result data], [status debugDescription]);
    }];
    
    return YES;
}

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message {
    
    NSLog(@"Message: %@", message.data);
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    
    NSLog(@"Presence event: %@", event.data);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    NSLog(@"Status: %@", [status debugDescription]);
}

@end
