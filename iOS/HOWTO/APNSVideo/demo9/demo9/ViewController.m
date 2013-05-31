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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    PNConfiguration *myConfig = [PNConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"];
    [PubNub setConfiguration:myConfig];
    
    PNChannel *myChannel = [PNChannel channelWithName:@"hello_world"];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [PubNub subscribeOnChannel:myChannel];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSData *deviceToken = appDelegate.dToken;
        
        // add a channel to APNS
        [PubNub enablePushNotificationsOnChannel:myChannel withDevicePushToken:deviceToken];
        
//		// remove that channel from APNS
//		[PubNub disablePushNotificationsOnChannel:myChannel withDevicePushToken:deviceToken];
//        
//        // this will request all channels associated with this push token
//        [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:deviceToken withCompletionHandlingBlock:^(NSArray *channels, PNError *error){}];
//        
//        // this will disassociate all channels with this push token in a single method call
//        [PubNub removeAllPushNotificationsForDevicePushToken:deviceToken withCompletionHandlingBlock:^(PNError *error){}];
        
    } errorBlock:^(PNError *error) {
        NSLog(@"There was an error connecting");
    }];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
