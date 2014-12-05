//
//  ViewController.m
//  APNSClient
//
//  Created by Vadim Osovets on 9/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property NSData *deviceToken;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // Configure Keys
    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                 // Configure your keys!
                                                             publishKey:@"pub-c-12b1444d-4535-4c42-a003-d509cc071e09"
                                                           subscribeKey:@"sub-c-6dc508c0-bff0-11e3-a219-02ee2ddab7fe"
                                                              secretKey:@"sec-c-YjIzMWEzZmEtYWVlYS00MzMzLTkyZGItNWJkMjRlZGQ4MjAz"];
//    [myConfig setCipherKey:@"qrerweqrewrw"];
    
    // Define Channel
    PNChannel *my_channel = [PNChannel channelWithName:@"test_push"
                                 shouldObservePresence:YES];
    [PubNub setConfiguration:myConfig];
    [PubNub connect];
    [PubNub grantAllAccessRightsForApplicationAtPeriod:NSIntegerMax
                            andCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightCollection, PNError *error) {
                                NSLog(@"error: %@", error);
                            }];
    
    
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self withCallbackBlock:^(NSString *origin, BOOL connected, PNError *connectionError){
        
        if (connected)
        {
            NSLog(@"OBSERVER: Successful Connection!");
            
            // Subscribe on connect
            [PubNub subscribeOnChannel:my_channel];
            
            // #3 Define AppDelegate
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            // #4 Pass the deviceToken from the Delegate
            _deviceToken = appDelegate.deviceToken;
            
            // #5 Double check we've passed the token properly
            NSLog(@"Device token received: %@", _deviceToken);
            
            // #6 If we have the device token, enable apns for our channel if it isn't already enabled.
            if (_deviceToken) {
                
                // APNS enabled already?
                [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:_deviceToken
                                                     withCompletionHandlingBlock:^(NSArray *channels, PNError *error){
                                                         if (channels.count == 0 )
                                                         {
                                                             NSLog(@"BLOCK: requestPushNotificationEnabledChannelsForDevicePushToken: Channel: %@ , Error %@",channels,error);
                                                             
                                                             // Enable APNS on this Channel with deviceToken
                                                             [PubNub enablePushNotificationsOnChannel:my_channel
                                                                                  withDevicePushToken:_deviceToken
                                                                           andCompletionHandlingBlock:^(NSArray *channel, PNError *error){
                                                                               NSLog(@"BLOCK: enablePushNotificationsOnChannel: %@ , Error %@",channel,error);
                                                                           }];
                                                         }
                                                     }];
            }
        }
        else if (!connected || connectionError != nil )
        {
            NSLog(@"OBSERVER: Error %@, Connection Failed!", connectionError.localizedDescription);
        }
        
    }];
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error){
        
        switch (state) {
            case PNSubscriptionProcessSubscribedState:{
                NSLog(@"OBSERVER: Subscribed to Channel: %@", channels[0]);
                
                //1k
//                NSDictionary *testDict = [self generateTestDictWithDepth:2 maxKeysOnLevel:2];
                NSDictionary *testDict = [self generateTestDictWithDepth:1 maxKeysOnLevel:3];
                
                NSData *data = [NSPropertyListSerialization dataWithPropertyList:[NSDictionary dictionaryWithDictionary:testDict]
                                                                          format:NSPropertyListXMLFormat_v1_0 options:NSProprietaryStringEncoding error:NULL];
                
                NSString *message = [NSString stringWithFormat:@"%@", data];
                message = @"afdsfsdafsdfsdfasdfsdfsdafsadfsadfsdfsdf\
                afsdfsdfsdfsdfsfasfafdsfsdafsadfsdfsdfsadfsadfsadfsadf\
                afsadfsdafsdfsdfasfsafsadfsafsadfsfsfsfsdfsdfsadfasdfs";
                
//                NSLog(@"Data size: %luKb", (unsigned long)[data length]/1024);
                NSLog(@"Data size: %luKb", (unsigned long)[message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]/1024);
                NSLog(@"Data size: %lub", (unsigned long)[message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
                
                [PubNub sendMessage:[NSString stringWithFormat:@"This is an Apple Push Notification!" ] toChannel:my_channel ];
                
                [PubNub sendMessage:message toChannel:my_channel];
                
#warning To test special case from customer, related to crypt key in configuraiton and sending push notifications.
                
                [PubNub sendMessage:@"Send encrypted" applePushNotification:nil toChannel:my_channel
                         compressed:YES storeInHistory:NO withCompletionBlock:^(PNMessageState
                                                                                state, id object) {
                             switch (state) {
                                 case PNMessageSent:
                                     NSLog(@"Done");
                                     break;
                                     
                                 default:
                                     break;
                             }
                         
                         }];
                
            }
                break;
            case PNSubscriptionProcessNotSubscribedState:
                NSLog(@"OBSERVER: Not subscribed to Channel: %@, Error: %@", channels[0], error);
                break;
            case PNSubscriptionProcessWillRestoreState:
                NSLog(@"OBSERVER: Will re-subscribe to Channel: %@", channels[0]);
                break;
            case PNSubscriptionProcessRestoredState:
                NSLog(@"OBSERVER: Re-subscribed to Channel: %@", channels[0]);
                break;
        }
    }];
    [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data){
        
        switch (state) {
            case PNMessageSent:
                NSLog(@"OBSERVER: Message Sent.");
                break;
            case PNMessageSending:
                NSLog(@"OBSERVER: Sending Message...");
                break;
            case PNMessageSendingError:
                NSLog(@"OBSERVER: ERROR: Failed to Send Message.");
                break;
            default:
                break;
        }
    }];
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
        NSLog(@"OBSERVER: Channel: %@, Message: %@", message.channel.name, message.message);
        
        NSString *stringMessage = [NSString stringWithFormat:@"%@", message.message];
        
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"APNS in channel: %@", message.channel.name] message:stringMessage
                                  delegate:nil cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
    }];
    
    // #7 Add an observer to catch when push notifications are enabled. (optional)
    [[PNObservationCenter defaultCenter] addClientPushNotificationsEnableObserver:self
                                                                withCallbackBlock:^(NSArray *channels, PNError *error){
                                                                    NSLog(@"OBSERVER: addClientPushNotificationsEnableObserver: channels: %@ Error: %@.", channels, error);
                                                                }];
    // #8 Add an observer to catch if push notifications are disabled. (optional)
    [[PNObservationCenter defaultCenter] addClientPushNotificationsDisableObserver:self
                                                                 withCallbackBlock:^(NSArray *channels, PNError *error){
                                                                     NSLog(@"OBSERVER: addClientPushNotificationsDisableObserver: channels: %@, error: %@ ", channels, error);
                                                                     
                                                                 }];
    // #9 Add an observer to catch when requestPushNotificationEnabledChannelsForDevicePushToken is returned (optional)
    [[PNObservationCenter defaultCenter] addClientPushNotificationsEnabledChannelsObserver:self
                                                                         withCallbackBlock:^(NSArray *channels, PNError *error){
                                                                             NSLog(@"OBSERVER: addClientPushNotificationsEnabledChannelsObserver: channels: %@ error: %@" ,channels,error);
                                                                         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tests

#pragma mark - Generate test data

- (NSDictionary *)generateTestDictWithDepth:(NSUInteger)depth maxKeysOnLevel:(NSUInteger)maxKeysOnLevel {
    /*
     NSDictionary *testDict = [self generateTestDictWithDepth:2 maxKeysOnLevel:4];
     
     NSData *data = [NSPropertyListSerialization dataWithPropertyList:[NSDictionary dictionaryWithDictionary:testDict]
     format:NSPropertyListXMLFormat_v1_0 options:NSProprietaryStringEncoding error:NULL];
     NSLog(@"Data size: %luKb", (unsigned long)[data length]/1024);

     */
    
    // generate test dictionary
    
    NSLog(@"Start generating test data:\n\t depth: %lu, \n\tmax keys: %lu", depth, maxKeysOnLevel);
    
    NSMutableDictionary *dict = [self parentDictionary:[NSMutableDictionary new] generateDictWithKeys:maxKeysOnLevel
                                              andDepth:depth];
    
    NSLog(@"End");
    
    return dict;
}

- (NSMutableDictionary *)parentDictionary:(NSDictionary *)parentDict
                     generateDictWithKeys:(NSUInteger)maxKeysOnLevel
                                 andDepth:(NSUInteger)depth {
    
    //    NSLog(@"\tcurrent depth: %lu", depth);
    
    if (depth == 0) {
        return [@{[NSString stringWithFormat:@"%lu", (unsigned long)depth]: @"end"} mutableCopy];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for (NSUInteger i = 0; i < maxKeysOnLevel; i++) {
        dict[[NSString stringWithFormat:@"%lu.%lu", (unsigned long)depth, (unsigned long)i]] = [self parentDictionary:dict
                                                                                                 generateDictWithKeys:maxKeysOnLevel andDepth:depth - 1];
    }
    
    return dict;
}

@end
