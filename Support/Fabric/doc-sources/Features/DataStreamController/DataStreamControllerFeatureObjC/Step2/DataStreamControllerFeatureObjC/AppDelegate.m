/*fabric:start-text*/
// To receive messages from the channel group, subscribe to the channel group created in the previous step.
/*fabric:end-text*/
/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
/*fabric:start-code*/
#import "AppDelegate.h"
#import <PubNub/PubNub.h>
#import <PubNubBridge/PubNub+FAB.h>


@interface AppDelegate ()

@property (nonatomic, strong) PubNub *client;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*fabric:start-highlight*/
    __weak __typeof(self) weakSelf = self;
    /*fabric:end-highlight*/
    self.client = [PubNub client];
    [self.client addChannels:@[@"announcements", @"lobby"] toGroup:@"tradeshow"
              withCompletion:^(PNAcknowledgmentStatus *status) {
                  
        /*fabric:start-highlight*/
        __strong __typeof(self) strongSelf = weakSelf;
        
        // Check whether request successfully completed or not.
        if (!status.isError) {
            
            [strongSelf.client addListener:strongSelf];
            [strongSelf.client subscribeToChannelGroups:@[@"tradeshow"] withPresence:NO];
        }
        // Request processing failed.
        else {
            
            // Handle channels list modification for group error. Check 'category' property to find out
            // possible issue because of which request did fail.
            //
            // Request can be resent using: [status retry];
        }
        /*fabric:end-highlight*/
    }];
    
    return YES;
}

@end
/*fabric:end-code*/
