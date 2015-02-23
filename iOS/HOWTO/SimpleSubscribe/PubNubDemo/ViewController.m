//
//  ViewController.m
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "ViewController.h"
#import "PNMessage+Protected.h"
#import "PubNub+Protected.h"

@interface ViewController () <PNDelegate>

@property (nonatomic, strong) PubNub *pubNub;

@end

@implementation ViewController
@synthesize textView, presenceView, uuidView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //[uuidView setText:[NSString stringWithFormat:@"%@", [PubNub clientIdentifier]]];

    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"  publishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"];
    myConfig.presenceHeartbeatTimeout = 5;
    self.pubNub = [PubNub clientWithConfiguration:myConfig andDelegate:self];

    __pn_desired_weak __typeof__(self) weakSelf = self;
    [self.pubNub.observationCenter addMessageReceiveObserver:self
                                              withBlock:^(PNMessage *message) {
                                                  
          __strong __typeof__(self) strongSelf = weakSelf;

          NSLog(@"Text Length: %lu", (unsigned long)strongSelf.textView.text.length);

          if (strongSelf.textView.text.length > 2000) {
              [strongSelf.textView setText:@""];
          }

          [strongSelf.textView setText:[message.message stringByAppendingFormat:@"\n%@\n", strongSelf.textView.text]];

      }];

    [self.pubNub.observationCenter addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {
        
        __strong __typeof__(self) strongSelf = weakSelf;

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

        [strongSelf.presenceView setText:[eventString stringByAppendingFormat:@"\n%@\n", strongSelf.presenceView.text]];

    }];


    [self.pubNub setClientIdentifier:@"SimpleSubscribeInstance"];

    [self.pubNub connectWithSuccessBlock:^(NSString *origin) {

//                PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);

                // wait 1 second
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                NSMutableDictionary *currentState = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *zzState = [[NSMutableDictionary alloc] init];

                // then subscribe on channel a
                PNChannel *myChannel = [PNChannel channelWithName:@"a" shouldObservePresence:YES];


                [zzState setObject:@"demo app started" forKey:@"appEvent"];
                [currentState setObject:zzState forKey:@"a"];


                [self.pubNub subscribeOn:@[myChannel] withClientState:currentState];

                int64_t delayInSeconds = 5.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // grab global occupancy list 5s later
                [self.pubNub requestParticipantsListWithClientIdentifiers:NO clientState:YES];

            });

            }); }
            // In case of error you always can pull out error code and identify what happened and what you can do // additional information is stored inside error's localizedDescription, localizedFailureReason and
            // localizedRecoverySuggestion)
                         errorBlock:^(PNError *connectionError) {
                             if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
//                                 PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
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
