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
    [self runPubNubInstance];
    });
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
                              if (channel isKindOfClass:[PNChannel class]) {
                                  
                          // subscribe to channel
                                  [pubNubClient subscribeOn:@[channelGroup] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
                                      if (error) {
                                          NSAssert(YES, @"Request all channels in group: %@", error);
                                      }
                                  }];
                                  // request participants
                                  // request full history
                                  
                                  // after completion and delay:
                                  //  - unsubscribe & disconnect
                                  //  - remove instance
                                  
                                  // remove instance in some autorelease pool?
                              }];

                              }
                          }
                          
        }
    } errorBlock:^(PNError *error) {
        NSAssert(YES, @"Error: %@", error);
    }];
    
    [self.clients addObject:pubNubClient];
}

- (void)runBroadcaster {
    self.broadcaster = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
    
    [self.broadcaster connectWithSuccessBlock:^(NSString *origin) {
        if (origin) {
            // subscribe to channel
            //            [pubNubClient requestDefaultChannelGroupsWithCompletionHandlingBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
            //                NSLog(@"test");
            //            }];
            
            [self.broadcaster addChannels:@[[PNChannel channelWithName:@"TestiOS"]]
                                  toGroup:[PNChannelGroup channelGroupWithName:kTestGroupName inNamespace:kTestGroupName]
              withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
                  if (error) {
                      NSAssert(YES, @"Failed to add channel to group: %@", error);
                  }
              }];
        }
    } errorBlock:^(PNError *error) {
        NSAssert(YES, @"Error: %@", error);
    }];
}

@end
