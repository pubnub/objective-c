//
//  ViewController.m
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // amongst other things, set the sub/pub keys to demo
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);
        // wait 1 second
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // then subscribe on channel a
            PNChannel *myChannel = [PNChannel channelWithName:@"b" shouldObservePresence:YES];
            [PubNub subscribeOnChannel:myChannel];
            [PubNub enableAPNSOnChannel:myChannel forDevice:@"mydeviceid"];
        }); }
     // In case of error you always can pull out error code and identify what happened and what you can do // additional information is stored inside error's localizedDescription, localizedFailureReason and
     // localizedRecoverySuggestion)
                         errorBlock:^(PNError *connectionError) {
                             if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
                                 // wait 1 second
                                 int64_t delayInSeconds = 1.0;
                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                     PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
                                 }); }
                             UIAlertView *connectionErrorAlert = [UIAlertView new]; connectionErrorAlert.title = [NSString stringWithFormat:@"%@(%@)",
                                                                                                                  [connectionError localizedDescription],
                                                                                                                  NSStringFromClass([self class])];
                             connectionErrorAlert.message = [NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@",
                                                             [connectionError localizedFailureReason],
                                                             [connectionError localizedRecoverySuggestion]]; [connectionErrorAlert addButtonWithTitle:@"OK"];
                             [connectionErrorAlert show]; }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
