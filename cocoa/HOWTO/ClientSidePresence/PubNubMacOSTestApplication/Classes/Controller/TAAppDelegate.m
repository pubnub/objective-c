//
//  TAAppDelegate.m
//  PubNubMacOSTestApplication
//
//  Created by Sergey Mamontov on 4/22/13.
//  Copyright (c) 2013 Sergey Mamontov. All rights reserved.
//

#import "TAAppDelegate.h"
#import "PNMessage.h"

#pragma mark Static

// Stores reference on list of channels on which library should subscribe
static NSString * const kTAChannelName = @"hello_world";

#pragma mark - Private interface declaration

@interface TAAppDelegate () <PNDelegate>

#pragma mark - Properties

// Stores whether client disconnected on network error
// or not
@property (nonatomic, assign, getter = isDisconnectedOnNetworkError) BOOL disconnectedOnNetworkError;

#pragma mark - Instance methods

- (void)initializePubNubClient;

#pragma mark - Console simulation of base functionality

- (void)connect;
- (void)subscribeOnChannels;

#pragma mark -

@end


#pragma mark - Public interface methods

@implementation TAAppDelegate

@synthesize myChannel, pingPongTimer, presenceChannel, occupants;

#pragma mark - Instance methods

- (void)sweepOccupants{

    NSNumber *currentTime = [NSNumber numberWithLong:[NSDate timeIntervalSinceReferenceDate]];

    // avoid mutating during enumeration

    NSLog(@"All Occupants:");
    for(id key in [occupants allKeys]) {

        NSNumber *lastTime =  [occupants objectForKey:key];
        NSLog(@"user=%@ lastUpdate=%@", key, lastTime);

        if ([currentTime intValue] - [lastTime intValue] > 10) {
            //[textView setText:[[NSString stringWithFormat:@"Haven't heard from %@ in 10 seconds. Removing it from the occupants list!",key] stringByAppendingFormat:@"\n%@\n",textView.text]];
            NSLog(@"Haven't heard from %@ in 10 seconds. Removing it from the occupants list!",key);
            [occupants removeObjectForKey:key];
            //[presenceView setText:@""];

        }

        //[presenceView setText:[[NSString stringWithFormat:@"user=%@ lastUpdate=%@", key, lastTime] stringByAppendingFormat:@"\n%@\n", presenceView.text]];
    }
}

- (void)updateOccupant:(NSString *)uuid {
    [occupants setValue:[NSNumber numberWithInt:[NSDate timeIntervalSinceReferenceDate]] forKey:uuid];
    [self sweepOccupants];
}

- (void)addOccupant:(NSString *)uuid {
    [occupants setValue:[NSNumber numberWithInt:[NSDate timeIntervalSinceReferenceDate]] forKey:uuid];
    [self sweepOccupants];
}


- (void)initializePubNubClient {


    occupants = [NSMutableDictionary dictionaryWithCapacity:1000];
    myChannel = [PNChannel channelWithName:@"z" shouldObservePresence:NO];
    presenceChannel = [PNChannel channelWithName:[myChannel.name stringByAppendingString:@"-presence"] shouldObservePresence:NO];

    [PubNub setDelegate:self];

    self.myChannel = [PNChannel channelWithName:@"z"];

    // Subscribe for client connection state change
    // (observe when client will be disconnected)
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                BOOL connected,
                                                                PNError *error) {

                                                            if (!connected && error) {

                                                                PNLog(PNLogGeneralLevel, self, @"#2 PubNub client was unable to connect because of error: %@",
                                                                        [error localizedDescription],
                                                                        [error localizedFailureReason]);
                                                            }
                                                        }];


    // Subscribe application delegate on subscription updates
    // (events when client subscribe on some channel)
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
                                                                 withCallbackBlock:^(PNSubscriptionProcessState state,
                                                                         NSArray *channels,
                                                                         PNError *subscriptionError) {

                                                                     switch (state) {

                                                                         case PNSubscriptionProcessNotSubscribedState:

                                                                             PNLog(PNLogGeneralLevel, self,
                                                                                     @"{BLOCK-P} PubNub client subscription failed with error: %@",
                                                                                     subscriptionError);
                                                                             break;

                                                                         case PNSubscriptionProcessSubscribedState:

                                                                             PNLog(PNLogGeneralLevel, self,
                                                                                     @"{BLOCK-P} PubNub client subscribed on channels: %@",
                                                                                     channels);
                                                                             break;

                                                                         case PNSubscriptionProcessWillRestoreState:

                                                                             PNLog(PNLogGeneralLevel, self,
                                                                                     @"{BLOCK-P} PubNub client will restore subscribed on channels: %@",
                                                                                     channels);
                                                                             break;

                                                                         case PNSubscriptionProcessRestoredState:

                                                                             PNLog(PNLogGeneralLevel, self,
                                                                                     @"{BLOCK-P} PubNub client restores subscribed on channels: %@",
                                                                                     channels);
                                                                             break;
                                                                     }
                                                                 }];

    // Subscribe on message arrival events with block
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {



                                                         }];


    // Subscribe on presence event arrival events with block
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {

        NSString *alreadyExists = [[NSString alloc]init];
        NSString *uuid = [[NSString alloc]init];

        uuid = event.uuid;

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
            alreadyExists = [occupants objectForKey:uuid];
            if (alreadyExists) {
                //[textView setText:[[NSString stringWithFormat:@"Heard from an existing user: %@", uuid] stringByAppendingFormat:@"\n%@\n",textView.text]];
                NSLog(@"Heard from an existing user: %@", uuid);
                [self updateOccupant:uuid];
            } else {
                //[textView setText:[[NSString stringWithFormat:@"Heard from a new user: %@", uuid] stringByAppendingFormat:@"\n%@\n",textView.text]];
                NSLog(@"Heard from a new user: %@", uuid);
                [self addOccupant:uuid];
            }
        }

    }];


}


#pragma mark - Console simulation of base functionality

- (void)connect {

    // Update PubNub client configuration
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];

    TAAppDelegate *weakSelf = self;
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, weakSelf, @"{BLOCK} PubNub client connected to: %@", origin);

        // wait 1 second
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            [weakSelf subscribeOnChannels];

        });
    } errorBlock:^(PNError *connectionError) {

        if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {

            PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");

            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                PNLog(PNLogGeneralLevel,
                        weakSelf,
                        [NSString stringWithFormat:@"Connection error: %@(%@)\nReason:\n%@\n\nSuggestion:\n%@",
                                                   [connectionError localizedDescription],
                                                   NSStringFromClass([self class]),
                                                   [connectionError localizedFailureReason],
                                                   [connectionError localizedRecoverySuggestion]]);
            });
        }
    }];
}

- (void)subscribeOnChannels {

    // then subscribe on channel 'zzz'
    [PubNub subscribeOnChannel:self.myChannel];
    [PubNub enablePresenceObservationForChannel:presenceChannel];

    self.pingPongTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                          target:self
                                                        selector:@selector(presSub:)
                                                        userInfo:nil
                                                         repeats:YES];

}

//The method the timer will call when fired
- (void)presSub:(NSTimer *)aTimer {
    [self sweepOccupants];
    NSLog(@"Ping!");
    [PubNub subscribeOnChannel:presenceChannel withPresenceEvent:YES];
    [self performSelector:@selector(presUnsub) withObject:NULL afterDelay:4.0];
}

- (void)presUnsub{
    NSLog(@"Pong!");
    [PubNub unsubscribeFromChannel:presenceChannel withPresenceEvent:YES];
}


- (IBAction)stopTimer {
    [self.pingPongTimer invalidate];
}


#pragma mark - NSApplication delegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(receivedWakeNote:)
                                                               name:NSWorkspaceDidWakeNotification
                                                             object:nil] ;

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(receivedSleepNote:)
                                                               name:NSWorkspaceWillSleepNotification
                                                             object:nil] ;




    [self initializePubNubClient];
    [PubNub setClientIdentifier:@"PubNubOnMac"];

    [self connect];
}


- (void)receivedSleepNote: (NSNotification *)notification {
    NSLog(@"GOING TO SLEEP!");

//    [PubNub unsubscribeFromChannel:self.myChannel withCompletionHandlingBlock:^(NSArray *channels, PNError *error){
//
//        NSLog(@"FINISHED UNSUBBING.");
//        //[PubNub disconnect];
//        NSLog(@"FINISHED DISCO");
//
//    }];

    NSLog(@"GOOD NITE!");
}


- (void)receivedWakeNote: (NSNotification *)notification {

    NSLog(@"WOKE UP!");
    //[self connect];
}

#pragma mark - PubNub client delegate methods

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client report that error occurred: %@", error);
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {


    if (self.isDisconnectedOnNetworkError) {

        PNLog(PNLogGeneralLevel, self, @"PubNub client trying to restore connection to PubNub origin at: %@", origin);
    }
    else {

        PNLog(PNLogGeneralLevel, self, @"PubNub client is about to connect to PubNub origin at: %@", origin);
    }
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {

    if (self.isDisconnectedOnNetworkError) {

        PNLog(PNLogGeneralLevel, self, @"PubNub client restored connection to PubNub origin at: %@", origin);
    }
    else {

        PNLog(PNLogGeneralLevel, self, @"PubNub client successfully connected to PubNub origin at: %@", origin);
    }


    self.disconnectedOnNetworkError = NO;
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"#1 PubNub client was unable to connect because of error: %@", error);

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionFailedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub clinet will close connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client closed connection because of error: %@", error);

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionClosedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {

    PNLog(PNLogGeneralLevel, self, @"PubNub client disconnected from PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully subscribed on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client resuming subscription on: %@", channels);
}

- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully restored subscription on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully unsubscribed from channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to unsubscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {

    PNLog(PNLogGeneralLevel, self, @"PubNub client recieved time token: %@", timeToken);
}

- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive time token because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client is about to send message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message '%@' because of error: %@", message, error);
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received presence event: %@", event);
}

- (void)pubnubClient:(PubNub *)client
        didReceiveMessageHistory:(NSArray *)messages
        forChannel:(PNChannel *)channel
        startingFrom:(NSDate *)startDate
        to:(NSDate *)endDate {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received history for %@ starting from %@ to %@: %@",
            channel, startDate, endDate, messages);
}

- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download history for %@ because of error: %@",
            channel, error);
}

- (void)      pubnubClient:(PubNub *)client
didReceiveParticipantsLits:(NSArray *)participantsList
                forChannel:(PNChannel *)channel {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received participants list for channel %@: %@",
            participantsList, channel);
}

- (void)                     pubnubClient:(PubNub *)client
didFailParticipantsListDownloadForChannel:(PNChannel *)channel
                                withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
            channel, error);
}

#pragma mark -


@end
