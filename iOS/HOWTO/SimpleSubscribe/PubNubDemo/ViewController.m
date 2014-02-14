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

    [PubNub setClientIdentifier:@"SimpleSubscribe"];
    //[uuidView setText:[NSString stringWithFormat:@"%@", [PubNub clientIdentifier]]];

    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {

                                                             NSLog(@"Text Length: %i", textView.text.length);

                                                             if (textView.text.length > 2000) {
                                                                 [textView setText:@""];
                                                             }

                                                             [textView setText:[message.message stringByAppendingFormat:@"\n%@\n", textView.text]];

                                                         }];

    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {

        NSString *eventString;
        if (event.type == PNPresenceEventJoin) {
            eventString = @"Join";
        } else
        if (event.type == PNPresenceEventLeave) {
            eventString = @"Leave";
        } else
        if (event.type == PNPresenceEventTimeout) {
            eventString = @"Timeout";
        }

        eventString = [NSString stringWithFormat:@"%@ : %@", event.client.identifier, eventString];

        [presenceView setText:[eventString stringByAppendingFormat:@"\n%@\n", presenceView.text]];



    }];


    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"presence-beta.pubnub.com"  publishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"];

    // Set the presence heartbeat to 5s
    myConfig.presenceHeartbeatTimeout = 5;

    [PubNub setConfiguration:myConfig];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);

        // wait 1 second
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            NSMutableDictionary *currentState = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *zzState = [[NSMutableDictionary alloc] init];

            // then subscribe on channel zz
            PNChannel *myChannel = [PNChannel channelWithName:@"zz" shouldObservePresence:YES];


            [zzState setObject:@"demo app started" forKey:@"appEvent"];
            [currentState setObject:zzState forKey:@"zz"];


            [PubNub subscribeOnChannel:myChannel withClientState:currentState];

            int64_t delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // grab global occupancy list 5s later
                [PubNub requestParticipantsListWithClientIdentifiers:NO clientState:YES];

            });

        }); }
            // In case of error you always can pull out error code and identify what happened and what you can do // additional information is stored inside error's localizedDescription, localizedFailureReason and
            // localizedRecoverySuggestion)
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

- (IBAction)clearAll:(id)sender {
    textView.text = @"";
    presenceView.text = @"";
}
@end
