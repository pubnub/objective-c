//
//  AppDelegate.m
//  MultipleInstanceTest
//
//  Created by Vadim Osovets on 2/9/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import "AppDelegate.h"

#import "PNImports.h"
#import "PNConfiguration+Test.h"


static NSUInteger kAmountOfClients = 3;
static NSUInteger kAmountOfMessages = 10;

@interface AppDelegate ()

<
PNDelegate
>

@end

@implementation AppDelegate {
    NSMutableArray *_clients;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self multipleInstanceTest];
    });
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
        NSLog(@"Received: %@", message);
    }];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Tests

- (PubNub *)pubNubClientWithName:(NSString *)name {
    PNConfiguration *configuration = [PNConfiguration defaultTestConfiguration];
    
    PubNub *client = [PubNub clientWithConfiguration:configuration];
    [client setClientIdentifier:name];
    [client setDelegate:self];
    
    [client connectWithSuccessBlock:^(NSString *origin) {
        NSLog(@"client is connected: %@", name);
    } errorBlock:^(PNError *error) {
        NSAssert(error, @"Error during connection: %@", [error localizedDescription]);
    }];
    
    return client;
}

- (void)multipleInstanceTest {
    _clients = [NSMutableArray arrayWithCapacity:kAmountOfClients];
    
    
    // initialization
    for (NSUInteger i = 0; i < kAmountOfClients; i++) {
        [_clients addObject:[self pubNubClientWithName:[NSString stringWithFormat:@"Client №%@", @(i)]]];
    }
    
    // subscribe to one channel - Multiple Instance Channel test
    
    PNChannel *channel = [PNChannel channelWithName:@"MIC test"];
    
    // send messages simultaneously
    [_clients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PubNub *client = (PubNub *)obj;
        
        [client subscribeOn:@[channel]];
        
        // subscribe to messages
        
        for (NSUInteger i = 0; i < kAmountOfMessages; i++) {
            NSString *message = [NSString stringWithFormat:@"Message-%@", @(i)];
            
            [client sendMessage:message
                      toChannel:channel
                     compressed:YES
                 storeInHistory:YES
            withCompletionBlock:^(PNMessageState state, id data) {
                switch (state) {
                    case PNMessageSendingError:
                    {
                        NSAssert(YES, @"Error: %@", data);
                    }
                        break;
                    case PNMessageSent:
                    {}
                        break;
                    case PNMessageSending:
                    {}
                        break;

                        
                    default:
                        break;
                }
            }];
        }
    }];
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    NSLog(@"%@ received: %@", client.clientIdentifier, message);
}

@end
