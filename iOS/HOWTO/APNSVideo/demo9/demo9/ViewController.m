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

@end

@implementation ViewController
@synthesize deviceToken;
@synthesize pubNub;

- (void)viewDidLoad {
    [super viewDidLoad];


    NSLog(@"Sub key: %@", @"sub-c-e0d8405a-b823-11e2-89ba-02ee2ddab7fe");
    NSLog(@"Pub key: %@", @"pub-c-6d82cd87-cd15-461c-8de6-d0330419f439");
    NSLog(@"Sex key: %@", @"sec-ODgxMDA0NWYtOThkNC00MjgyLWFlOWYtYzdiMGM5NTU2NTlk");
    NSLog(@"Dev Console URL: %@", @"http://www.pubnub.com/console?channel=apns&pub=pub-c-6d82cd87-cd15-461c-8de6-d0330419f439&sub=sub-c-e0d8405a-b823-11e2-89ba-02ee2ddab7fe");

    // Do any additional setup after loading the view, typically from a nib.
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    PNConfiguration *myConfig = [PNConfiguration configurationWithPublishKey:@"pub-c-6d82cd87-cd15-461c-8de6-d0330419f439" subscribeKey:@"sub-c-e0d8405a-b823-11e2-89ba-02ee2ddab7fe" secretKey:@"sec-ODgxMDA0NWYtOThkNC00MjgyLWFlOWYtYzdiMGM5NTU2NTlk"];
    self.pubNub = [PubNub clientWithConfiguration:myConfig andDelegate:appDelegate];

    [pubNub connectWithSuccessBlock:^(NSString *origin) {
        [PubNub subscribeOnChannel:[PNChannel channelWithName:@"apns"]];

        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        deviceToken = appDelegate.dToken;


        if (deviceToken) {



        }

    }                    errorBlock:^(PNError *error) {
        NSLog(@"There was an error connecting");
        [_imageView setHidden:YES];
        [_requestOutpu setText:[NSString stringWithFormat:@"Error: Could Not Detect DeviceID. Please restart App."]];


    }];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayResults:(NSString *)results withOpName:(NSString *)opName {
    if (results == nil) {
        results = @"Success";
    }

    [_imageView setHidden:YES];
    [_requestOutpu setText:[NSString stringWithFormat:@"%@ completed. \nResults: %@", opName, results]];
}

- (IBAction)enablePush:(id)sender {

    [self.pubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"apns"] withDevicePushToken:deviceToken andCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        [self processChannels:channels withError:error withOp:@"Enable Push" ];
    }];
}

- (IBAction)disablePush:(id)sender {
    [self.pubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"apns"] withDevicePushToken:deviceToken andCompletionHandlingBlock:^(NSArray *array, PNError *error) {
        [self displayResults:error.description withOpName:@"Disable Push"];
    }];
}

- (IBAction)disableAllPush:(id)sender {
    [self.pubNub removeAllPushNotificationsForDevicePushToken:deviceToken withCompletionHandlingBlock:^(PNError *error) {
        [self displayResults:error.description withOpName:@"Remove All"];
    }];
}

- (IBAction)auditPush:(id)sender {
    [self.pubNub requestPushNotificationEnabledChannelsForDevicePushToken:deviceToken withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        [self processChannels:channels withError:error withOp:@"Audit"];
    }];
}

- (IBAction)sendString:(id)sender {
    [self.pubNub sendMessage:@"Greetz from APNS" toChannel:[PNChannel channelWithName:@"apns"]];
}

- (void)processChannels:(NSArray *)channels withError:(PNError *)error withOp:(NSString *)op {

    id result = nil;

    if (error == nil)
            result = [[channels valueForKey:@"name"] componentsJoinedByString:@", "];
        else
            result = error.description;

    [self displayResults:result withOpName:op];
}
@end
