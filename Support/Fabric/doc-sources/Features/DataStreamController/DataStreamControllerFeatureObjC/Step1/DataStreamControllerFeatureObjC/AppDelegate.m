/*fabric:start-text*/
// Configure the client and channel group with set of channels.
/*fabric:end-text*/
/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
/*fabric:start-code*/
#import "AppDelegate.h"
/*fabric:start-highlight*/
#import <PubNub/PubNub.h>
#import <PubNubBridge/PubNub+FAB.h>
/*fabric:end-highlight*/


@interface AppDelegate ()

/*fabric:start-highlight*/
@property (nonatomic, strong) PubNub *client;
/*fabric:end-highlight*/

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*fabric:start-highlight*/
    self.client = [PubNub client];
    [self.client addChannels:@[@"announcements", @"lobby"] toGroup:@"tradeshow"
              withCompletion:^(PNAcknowledgmentStatus *status) {
                  
    }];
    /*fabric:end-highlight*/
    
    return YES;
}

@end
/*fabric:end-code*/
