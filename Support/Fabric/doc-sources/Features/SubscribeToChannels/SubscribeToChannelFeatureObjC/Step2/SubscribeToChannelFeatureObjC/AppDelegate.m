/*fabric:start-text*/
// It is always a good idea to add a subscription/connection status handling callback to know when the subscription process completed or stumbled on an unexpected disconnection.
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
    
    self.client = [PubNub client];
    [self.client addListener:self];
    [self.client subscribeToChannels:@[@"announcements", @"lobby"] withPresence:NO];
    
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
