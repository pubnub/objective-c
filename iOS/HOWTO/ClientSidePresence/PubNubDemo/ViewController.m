//
//  ViewController.m
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "ViewController.h"
#import "PNMessage+Protected.h"
#import "PubNub+Subscription.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize textView, presenceView, uuidView;
@synthesize pingPongTimer, myChannel, presenceChannel, occupants;


- (void)sweepOccupants{

    [presenceView setText:@""];

    NSNumber *currentTime = [NSNumber numberWithLong:[NSDate timeIntervalSinceReferenceDate]];

    // avoid mutating during enumeration
        
    NSLog(@"All Occupants:");
    for(id key in [occupants allKeys]) {

        NSNumber *lastTime =  [occupants objectForKey:key];
        NSLog(@"user=%@ lastUpdate=%@", key, lastTime);

        if ([currentTime intValue] - [lastTime intValue] > 10) {
            [textView setText:[[NSString stringWithFormat:@"Haven't heard from %@ in 10 seconds. Removing it from the occupants list!",key] stringByAppendingFormat:@"\n%@\n",textView.text]];
            NSLog(@"Haven't heard from %@ in 10 seconds. Removing it from the occupants list!",key);
            [occupants removeObjectForKey:key];
            [presenceView setText:@""];

        }

    }

    for(id key in [occupants allKeys]) {
        NSNumber *lastTime =  [occupants objectForKey:key];
        [presenceView setText:[[NSString stringWithFormat:@"user=%@ lastUpdate=%@", key, lastTime] stringByAppendingFormat:@"\n%@\n", presenceView.text]];
    }
}

- (void)updateOccupant:(NSString *)uuid {
    [occupants setValue:[NSNumber numberWithInt:[NSDate timeIntervalSinceReferenceDate]] forKey:uuid];
}

- (void)addOccupant:(NSString *)uuid {
    [occupants setValue:[NSNumber numberWithInt:[NSDate timeIntervalSinceReferenceDate]] forKey:uuid];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    occupants = [NSMutableDictionary dictionaryWithCapacity:1000];
    myChannel = [PNChannel channelWithName:@"z" shouldObservePresence:NO];
    presenceChannel = [PNChannel channelWithName:[myChannel.name stringByAppendingString:@"-presence"] shouldObservePresence:YES];


    //[uuidView setText:[NSString stringWithFormat:@"%@", [PubNub clientIdentifier]]];

    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {

                                                             NSLog(@"Text Length: %lu", (unsigned long)textView.text.length);

                                                             if (textView.text.length > 2000) {
                                                                 [textView setText:@""];
                                                             }

                                                             [textView setText:[[NSString stringWithFormat:@"%@", message.message] stringByAppendingFormat:@"\n%@\n", textView.text]];

                                                         }];

    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {

        NSString *alreadyExists = [[NSString alloc]init];
        NSString *uuid = [[NSString alloc]init];

        uuid = event.client.identifier;

        // ignore yourself
        if ([uuid isEqualToString:[PubNub clientIdentifier]]) {
            return;
        }

        NSString *eventString;
        if (event.type == PNPresenceEventJoin) {
            eventString = @"Join";
        } else if (event.type == PNPresenceEventLeave) {
            eventString = @"Leave";
        } else if (event.type == PNPresenceEventTimeout) {
            eventString = @"Timeout";
        }

        //eventString = [NSString stringWithFormat:@"%@ : %@", uuid, eventString];




        if (![eventString isEqualToString:@"Timeout"]) {

            [textView setText:[[NSString stringWithFormat:@"Presence Event Received!"] stringByAppendingFormat:@"\n%@\n",textView.text]];


            alreadyExists = [occupants objectForKey:uuid];
            if (alreadyExists) {
                [textView setText:[[NSString stringWithFormat:@"Heard from an existing user: %@", uuid] stringByAppendingFormat:@"\n%@\n",textView.text]];
                NSLog(@"Heard from an existing user: %@", uuid);
                [self updateOccupant:uuid];
            } else {
                [textView setText:[[NSString stringWithFormat:@"Heard from a new user: %@", uuid] stringByAppendingFormat:@"\n%@\n",textView.text]];
                NSLog(@"Heard from a new user: %@", uuid);
                [self addOccupant:uuid];
            }
        }

    }];





    // Do any additional setup after loading the view, typically from a nib.

    // amongst other things, set the sub/pub keys to demo
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

//        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);

        // wait 1 second
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

            // then subscribe on channel a

            [PubNub subscribeOn:@[myChannel]];
            [PubNub enablePresenceObservationFor:@[presenceChannel]];

//            self.pingPongTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
//                                                          target:self
//                                                        selector:@selector(presSub:)
//                                                        userInfo:nil
//                                                         repeats:YES];

            [self presSub:NULL];

        });
    }
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



//This will start a repeating timer that will fire every 5 seconds


//The method the timer will call when fired
- (void)presSub:(NSTimer *)aTimer {
    [self sweepOccupants];
    NSLog(@"Ping!");
    [PubNub subscribeOn:@[presenceChannel]];
    [self performSelector:@selector(presUnsub) withObject:NULL afterDelay:5.0];
}

- (void)presUnsub{
    [self sweepOccupants];
    NSLog(@"Pong!");
    
    [PubNub unsubscribeFrom:@[presenceChannel]];
    [self performSelector:@selector(presSub:) withObject:NULL afterDelay:5.0];

}


- (IBAction)stopTimer {
    [self.pingPongTimer invalidate];
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
