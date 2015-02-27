//
//  ViewController.m
//  demo9
//
//  Created by geremy cohen on 5/8/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()



@property (nonatomic, weak) IBOutlet UITextView *requestOutput;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) PubNub *pubNub;


- (IBAction)enablePush:(id)sender;
- (IBAction)disablePush:(id)sender;
- (IBAction)disableAllPush:(id)sender;
- (IBAction)auditPush:(id)sender;
- (IBAction)sendString:(id)sender;

- (void)configurePubNubClient;
- (void)showStatusMessage:(NSString *)message;
- (void)executeAPNSRequest:(void(^)(NSData *devicePushToken))request;

@end


@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configurePubNubClient];
}

- (void)configurePubNubClient {
    
//    NSString *subscriptionKey = @"sub-c-e0d8405a-b823-11e2-89ba-02ee2ddab7fe";
//    NSString *publishKey = @"pub-c-6d82cd87-cd15-461c-8de6-d0330419f439";
//    NSString *secretKey = @"sec-ODgxMDA0NWYtOThkNC00MjgyLWFlOWYtYzdiMGM5NTU2NTlk";
    
    NSString *subscriptionKey = @"demo";
    NSString *publishKey = @"demo";
    NSString *secretKey = @"demo";
    
    NSLog(@"Sub key: %@\nPub key: %@\nSec key: %@\n"
          "Dev Console URL: http://www.pubnub.com/console?channel=apns&pub=%@&sub=%@",
          subscriptionKey, publishKey, secretKey, publishKey, subscriptionKey);
    

    __pn_desired_weak __typeof__(self) weakSelf = self;
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    PNConfiguration *myConfig = [PNConfiguration configurationWithPublishKey:publishKey
                                                                subscribeKey:subscriptionKey
                                                                   secretKey:secretKey];
    self.pubNub = [PubNub connectingClientWithConfiguration:myConfig delegate:appDelegate
                                            andSuccessBlock:NULL errorBlock:^(PNError *error) {
                                                
        __strong __typeof__(self) strongSelf = weakSelf;
        [strongSelf showStatusMessage:@"There was an error connecting"];
    }];
}

- (void)displayResults:(NSString *)results withOpName:(NSString *)opName {
    
    if (results == nil) {
        
        results = @"Success";
    }

    [self showStatusMessage:[NSString stringWithFormat:@"%@ completed. \nResults: %@",
                             opName, results]];
}

- (void)showStatusMessage:(NSString *)message {
    
    [self.imageView setHidden:YES];
    [self.requestOutput setText:message];
}

- (void)executeAPNSRequest:(void(^)(NSData *devicePushToken))request {
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appDelegate.devicePushToken) {
        
        request(appDelegate.devicePushToken);
    }
    else {
        
        [self showStatusMessage:@"Error: Device push notification token not received yet or used"
         " provisioning profile which is not suitable for usage with APNS."];
    }
}

- (IBAction)enablePush:(id)sender {
    
    [self executeAPNSRequest:^(NSData *devicePushToken) {
        
        [self.pubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"apns"]
                                  withDevicePushToken:devicePushToken
                           andCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
                               
                               [self processChannels:channels withError:error withOp:@"Enable Push"];
                           }];
    }];
}

- (IBAction)disablePush:(id)sender {
    
    [self executeAPNSRequest:^(NSData *devicePushToken) {
        
        [self.pubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"apns"]
                                   withDevicePushToken:devicePushToken
                            andCompletionHandlingBlock:^(NSArray *array, PNError *error) {
                                
            [self displayResults:error.description withOpName:@"Disable Push"];
        }];
    }];
}

- (IBAction)disableAllPush:(id)sender {
    
    [self executeAPNSRequest:^(NSData *devicePushToken) {
    
        [self.pubNub removeAllPushNotificationsForDevicePushToken:devicePushToken
                                      withCompletionHandlingBlock:^(PNError *error) {
                                          
            [self displayResults:error.description withOpName:@"Remove All"];
        }];
    }];
}

- (IBAction)auditPush:(id)sender {
    
    [self executeAPNSRequest:^(NSData *devicePushToken) {
        
        [self.pubNub requestPushNotificationEnabledChannelsForDevicePushToken:devicePushToken
                                                  withCompletionHandlingBlock:^(NSArray *channels,
                                                                                PNError *error) {
                                                      
            [self processChannels:channels withError:error withOp:@"Audit"];
        }];
    }];
}

- (IBAction)sendString:(id)sender {
    
    [self.pubNub sendMessage:@"Greetz from APNS" toChannel:[PNChannel channelWithName:@"apns"]];
}

- (void)processChannels:(NSArray *)channels withError:(PNError *)error withOp:(NSString *)op {

    id result = nil;
    if (error == nil) {
        
        result = [[channels valueForKey:@"name"] componentsJoinedByString:@", "];
    }
    else {
        
        result = error.description;
    }

    [self displayResults:result withOpName:op];
}

@end
