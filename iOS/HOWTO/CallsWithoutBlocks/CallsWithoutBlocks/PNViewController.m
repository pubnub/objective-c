//
//  PNViewController.m
//  CallsWithoutBlocks
//
//  Created by geremy cohen on 06/04/13.
//  Copyright (c) 2013 PubNub. All rights reserved.
//

#import "PNViewController.h"

@interface PNViewController ()

@end

@implementation PNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey:@"mySecret"]];
    [PubNub connect];

    PNChannel *channel_1 = [PNChannel channelWithName:@"a" shouldObservePresence:YES];
    PNChannel *channel_2 = [PNChannel channelWithName:@"ping_3" shouldObservePresence:NO];

    [PubNub subscribeOn:@[channel_1]];
    [PubNub subscribeOn:@[channel_2]];

    [PubNub enablePresenceObservationFor:@[channel_2]];
    [PubNub disablePresenceObservationFor:@[channel_1]];

    [PubNub unsubscribeFrom:@[channel_1]];
    [PubNub requestParticipantsListFor:@[channel_2]];

    PNMessage *myMessage = [PubNub sendMessage:@"hello world!" toChannel:channel_2];
    NSLog(@"MESSAGE OBJECT: %@", myMessage);
    
    [PubNub sendMessage:@"hello ping3!" toChannel:channel_2];

    // Do a HereNow call after 5 sec
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [PubNub requestParticipantsListFor:@[channel_2]];
    });


//    [PubNub disconnect];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end