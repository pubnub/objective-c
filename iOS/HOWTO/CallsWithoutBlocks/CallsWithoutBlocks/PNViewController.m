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

    [PubNub subscribeOnChannel:channel_1];
    [PubNub subscribeOnChannel:channel_2];

    [PubNub enablePresenceObservationForChannel:channel_2];
    [PubNub disablePresenceObservationForChannel:channel_1];

    [PubNub unsubscribeFromChannel:channel_1];
    [PubNub requestParticipantsListForChannel:channel_2];

    PNMessage *myMessage = [PubNub sendMessage:@"hello world!" toChannel:channel_2];

    [PubNub sendMessage:@"hello ping3!" toChannel:channel_2];

    //[PubNub disconnect];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end