//
//  ViewController.m
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "ViewController.h"
#import "PNMessage+Protected.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize textView, presenceView, uuidView;

- (void)viewDidLoad
{
    [super viewDidLoad];



    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);

    } errorBlock:^(PNError *connectionError) {

        UIAlertView *connectionErrorAlert = [UIAlertView new];

        connectionErrorAlert.title = [NSString stringWithFormat:@"%@(%@)",

                                                                [connectionError localizedDescription
                                                                ],

                                                                NSStringFromClass([self class])];

        connectionErrorAlert.message = [NSString stringWithFormat:@"SetUpPubnub Reason:\n%@\n\nSuggestion:\n%@",

        [connectionError localizedFailureReason],

        [connectionError localizedRecoverySuggestion]];

        [connectionErrorAlert addButtonWithTitle:@"OK"];

        [connectionErrorAlert show];

    }];

    PNChannel *defaultChannel = [PNChannel channelWithName:@"zzz" shouldObservePresence:YES];

    [PubNub subscribeOnChannel:defaultChannel withCompletionHandlingBlock:^(
            PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {

    }];

// Uncomment this setClientIdentifier line to reproduce issue

[PubNub setClientIdentifier:@"foo"];

    [PubNub sendMessage:@"hi" toChannel:defaultChannel];

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clearAll:(id)sender {
    textView.text = @"";
    presenceView.text = @"";
}
@end
