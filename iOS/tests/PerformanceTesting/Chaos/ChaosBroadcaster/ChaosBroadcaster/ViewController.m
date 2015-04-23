//
//  ViewController.m
//  ChaosClient
//
//  Created by Vadim Osovets on 4/9/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import "ViewController.h"

#import "PNConfiguration+Test.h"
#import "GCDGroup.h"
#import "GCDWrapper.h"
#import "PubNub/PNImports.h"

static NSString *const kTestGroupName = @"ChaosTest";
static const NSUInteger kChannelsInPool = 3;
static const NSUInteger kMessagesInPool = 3;
static const NSUInteger kUnsubscribeDelay = 5;

@interface ViewController () <PNDelegate>

@property (nonatomic, strong) PubNub *broadcaster;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self startTest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tests

- (void)startTest {
    
    [self runBroadcaster];
}

- (void)runBroadcaster {
    self.broadcaster = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
    
    [self.broadcaster connectWithSuccessBlock:^(NSString *origin) {
        if (origin) {
            // subscribe to channel
            
            [self updateChannelsPool];
        }
    } errorBlock:^(PNError *error) {
        NSAssert(NO, @"Error: %@", error);
    }];
}

- (void)updateChannelsPool {
    for (NSInteger i = [[self.broadcaster subscribedObjectsList] count]; i < kChannelsInPool; i++) {
        // create channel with unique name
        
        PNChannel *channel = [PNChannel channelWithName:[NSString stringWithFormat:@"%@", @([@([[NSDate date] timeIntervalSince1970]) integerValue])] shouldObservePresence:YES];
        
        NSLog(@"Channel: %@", channel.name);
        
        // add channel to group
        
        [self.broadcaster addChannels:@[channel]
                              toGroup:[PNChannelGroup channelGroupWithName:kTestGroupName inNamespace:kTestGroupName]
          withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
              if (error) {
                  NSAssert(NO, @"Failed to add channel to group: %@", error);
              } else {
                  // subscribe on this channel
                  [self.broadcaster subscribeOn:@[channel]
                    withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
                        switch (state) {
                            case PNSubscriptionProcessNotSubscribedState:
                                
                                // There should be a reason because of which subscription failed and it can be found in 'error' instance
                                // Update user interface to let user know that something went wrong and do something to recover from this
                                // state.
                                //
                                // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use
                                // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable
                                // description for error). 'error.associatedObject' contains array of PNChannel instances on which PubNub
                                //client was unable to subscribe.
                                break;
                            case PNSubscriptionProcessSubscribedState:
                                
                                // PubNub client completed subscription on specified set of channels.
                                [self sendMessagesToChannel:channel];
                                break;
                            default:
                                break;
                        }
                    }];
              }
          }];
        
        // send messages to this channel
        
        // after delay unsubscribe from this channel
    }
}

- (void)sendMessagesToChannel:(PNChannel *)channel {
    for (NSUInteger i = 0; i < kMessagesInPool; i++) {
        [self.broadcaster sendMessage:[NSString stringWithFormat:@"%@", @(i)]
                            toChannel:channel
                       storeInHistory:YES
                  withCompletionBlock:^(PNMessageState state, id data) {
                      NSLog(@"");
                      if (state == PNMessageSent)
                          if (i == kMessagesInPool - 1) {
                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kUnsubscribeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                              
                              [self.broadcaster unsubscribeFrom:@[channel] withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
                                  if (error) {
                                      NSAssert(NO, @"Error during unsubscribe: %@", error);
                                  } else {
                                      [self updateChannelsPool];
                                  }
                              }];
                          });
                      }
                  }];
    }
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    NSLog(@"Client: %@ message: %@", client.clientIdentifier, message);
}

@end
