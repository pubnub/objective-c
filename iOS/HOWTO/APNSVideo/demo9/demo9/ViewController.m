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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    PNConfiguration *myConfig = [PNConfiguration configurationWithPublishKey:@"pub-c-6d82cd87-cd15-461c-8de6-d0330419f439" subscribeKey:@"sub-c-e0d8405a-b823-11e2-89ba-02ee2ddab7fe" secretKey:@"sec-ODgxMDA0NWYtOThkNC00MjgyLWFlOWYtYzdiMGM5NTU2NTlk"];
    [PubNub setConfiguration:myConfig];

    PNChannel *myChannel = [PNChannel channelWithName:@"hello_world"];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [PubNub subscribeOnChannel:myChannel];

        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        NSData *deviceToken = appDelegate.dToken;


        if (deviceToken) {

            // add a channel to APNS
            [PubNub enablePushNotificationsOnChannel:myChannel withDevicePushToken:deviceToken];

            //      remove that channel from APNS
            //		[PubNub disablePushNotificationsOnChannel:myChannel withDevicePushToken:deviceToken];

            // this will request all channels associated with this push token
            // Do a HereNow call after 5 sec
            double delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:deviceToken withCompletionHandlingBlock:^(NSArray *channels, PNError *error){}];
            });

//
//        // this will disassociate all channels with this push token in a single method call
//        [PubNub removeAllPushNotificationsForDevicePushToken:deviceToken withCompletionHandlingBlock:^(PNError *error){}];

        }

    }                    errorBlock:^(PNError *error) {
        NSLog(@"There was an error connecting");
    }];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
