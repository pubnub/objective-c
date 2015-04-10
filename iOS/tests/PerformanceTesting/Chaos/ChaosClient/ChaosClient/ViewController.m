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

static const NSUInteger kClientAmount = 2;

static NSString *const kTestGroupName = @"ChaosTest";

@interface ViewController () <PNDelegate>

@property (nonatomic, strong) NSMutableArray *clients;

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
    self.clients = [NSMutableArray arrayWithCapacity:kClientAmount * 2];
    
    [self runBroadcaster];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateInstancePool];
    });
}

- (void)updateInstancePool {
    for (int i = [self.clients count]; i < kClientAmount; i++) {
        [self runPubNubInstance];
    }
}

- (void)runPubNubInstance {
    // create instance
    
    PubNub *pubNubClient = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                               andDelegate:self];
    
    [pubNubClient connectWithSuccessBlock:^(NSString *origin) {
        if (origin) {
            
            // request all available channels
            [pubNubClient requestChannelsForGroup:[PNChannelGroup channelGroupWithName:kTestGroupName inNamespace:kTestGroupName]
                      withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *error) {
                          
                          if (error) {
                              NSAssert(YES, @"Request all channels in group: %@", error);
                          }
                          
                          for (PNChannel *channel in channelGroup.channels) {
                              if ([channel isKindOfClass:[PNChannel class]]) {
                                  
                                  GCDGroup *group = [GCDGroup group];
                                  
                                  [group enterTimes:3];
                                  
                          // subscribe to channel
                                  [pubNubClient subscribeOn:@[channel]
                                withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
                                      if (error) {
                                          NSAssert(YES, @"Request all channels in group: %@", error);
                                      }
                                    
                                    if (state == PNSubscriptionProcessSubscribedState) {
                                        [group leave];
                                    }
                                  }];
                                  // request participants
                                  
                                  [pubNubClient requestParticipantsListFor:@[channel] withCompletionBlock:^(PNHereNow *presenceInformation, NSArray *channels, PNError *error) {
                                      if (error) {
                                          NSAssert(YES, @"Request participants channels in group: %@", error);
                                      }
                                      
                                        [group leave];
                                  }];
                                  // request full history
                                  
                                  [pubNubClient requestFullHistoryForChannel:channel
                                                         withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error) {
                                                             if (error) {
                                                                 NSAssert(YES, @"Request participants channels in group: %@", error);
                                                             }
                                                             
                                                             NSLog(@"%@", messages);
                                                             [group leave];
                                                         }];
                                  
                                  // after completion and delay:
                                  //  - unsubscribe & disconnect
                                  //  - remove instance
                                  
                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                      if ([GCDWrapper isGCDGroup:group timeoutFiredValue:30]) {
                                          NSAssert(NO, @"Timeout fired");
                                      }
                                      
                                      NSLog(@"Finished");
                                      
                                      [self.clients removeObject:pubNubClient];
                                      
                                      // run more client if needed
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self updateInstancePool];
                                      });
                                      
                                      NSLog(@"Removed");
                                  });
                                 
                                  // remove instance in some autorelease pool?
                                }
                                }
                      }];
        }
    } errorBlock:^(PNError *error) {
        NSAssert(NO, @"Error: %@", error);
    }];
    
    [self.clients addObject:pubNubClient];
}

- (void)runBroadcaster {
    self.broadcaster = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
    
    [self.broadcaster connectWithSuccessBlock:^(NSString *origin) {
        if (origin) {
            // subscribe to channel
            [self.broadcaster addChannels:@[[PNChannel channelWithName:@"TestiOS"]]
                                  toGroup:[PNChannelGroup channelGroupWithName:kTestGroupName inNamespace:kTestGroupName]
              withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
                  if (error) {
                      NSAssert(NO, @"Failed to add channel to group: %@", error);
                  }
              }];
        }
    } errorBlock:^(PNError *error) {
        NSAssert(NO, @"Error: %@", error);
    }];
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    NSLog(@"Client: %@ message: %@", client.clientIdentifier, message);
}

@end
