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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // amongst other things, set the sub/pub keys to demo
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);

        // then subscribe on channel a
        [PubNub subscribeOnChannel:[PNChannel channelWithName:@"a" shouldObservePresence:YES]];

    }
            // In case of an error, you always can extract the details via
            // localizedDescription, localizedFailureReason and localizedRecoverySuggestion

                         errorBlock:^(PNError *connectionError) {
                             if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
                                 PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
                             }

                             UIAlertView *connectionErrorAlert = [UIAlertView new];
                             connectionErrorAlert.title = [NSString stringWithFormat:@"%@(%@)",
                                                                                     [connectionError localizedDescription],
                                                                                     NSStringFromClass([self class])];
                             connectionErrorAlert.message = [NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@",
                                                                                       [connectionError localizedFailureReason],
                                                                                       [connectionError localizedRecoverySuggestion]];
                             [connectionErrorAlert addButtonWithTitle:@"OK"];
                             [connectionErrorAlert show];
                         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
