/*fabric:start-text*/
// It is always a good idea to add a subscription status handling callback to know when a subscription process completed or stumbled on an unexpected disconnection.
/*fabric:end-text*/
/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
/*fabric:start-code*/
#import "AppDelegate.h"
#import <PubNub/PubNub.h>
#import <PubNubBridge/PubNub+FAB.h>


/*fabric:start-highlight*/
@interface AppDelegate () <PNObjectEventListener>
/*fabric:end-highlight*/

@property (nonatomic, strong) PubNub *client;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    __weak __typeof(self) weakSelf = self;
    self.client = [PubNub client];
    [self.client addChannels:@[@"announcements", @"lobby"] toGroup:@"tradeshow"
              withCompletion:^(PNAcknowledgmentStatus *status) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        
        // Check whether request successfully completed or not.
        if (!status.isError) {
            
            [strongSelf.client addListener:strongSelf];
            [strongSelf.client subscribeToChannelGroups:@[@"tradeshow"] withPresence:NO];
        }
        // Request processing failed.
        else {
        }
    }];
    
    return YES;
}

/*fabric:start-highlight*/
- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    
    if (status.category == PNUnexpectedDisconnectCategory) {
        
        // This event happens when radio / connectivity is lost
    }
    else if (status.category == PNConnectedCategory) {
        
        // Connect event. You can do stuff like publish, and know you'll get it.
        // Or just use the connected event to confirm you are subscribed for
        // UI / internal notifications, etc
    }
    else if (status.category == PNReconnectedCategory) {
        
        // Happens as part of our regular operation. This event happens when
        // radio / connectivity is lost, then regained.
    }
    else if (status.category == PNDisconnectedCategory) {
        
        // Disconnection event. After this moment any messages from unsubscribed channel
        // won't reach this callback.
    }
    else if (status.category == PNDecryptionErrorCategory) {
        
        // Handle messsage decryption error. Probably client configured to
        // encrypt messages and on live data feed it received plain text.
    }
}
/*fabric:end-highlight*/

@end
/*fabric:end-code*/
