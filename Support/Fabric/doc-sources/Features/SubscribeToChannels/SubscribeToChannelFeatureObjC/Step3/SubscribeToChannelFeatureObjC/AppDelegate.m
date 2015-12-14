/*fabric:start-text*/
// To handle messages from the previous subscribe steps, add a message handling callback.
/*fabric:end-text*/
/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
/*fabric:start-code*/
#import "AppDelegate.h"
#import <PubNub/PubNub.h>
#import <PubNubBridge/PubNub+FAB.h>


@interface AppDelegate () <PNObjectEventListener>

@property (nonatomic, strong) PubNub *client;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.client = [PubNub client];
    [self.client addListener:self];
    [self.client subscribeToChannels:@[@"announcements", @"lobby"] withPresence:NO];
    
    return YES;
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    
    if (status.category == PNUnexpectedDisconnectCategory) {
    }
    else if (status.category == PNConnectedCategory) {
    }
    else if (status.category == PNReconnectedCategory) {
    }
    else if (status.category == PNDisconnectedCategory) {
    }
    else if (status.category == PNDecryptionErrorCategory) {
    }
}

/*fabric:start-highlight*/
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    // Handle new message stored in message.data.message
    if (message.data.actualChannel != nil) {
        
        // Message has been received on channel group stored in
        // message.data.subscribedChannel
    }
    else {
        
        // Message has been received on channel stored in
        // message.data.subscribedChannel
    }
    
    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,
          (message.data.actualChannel?: message.data.subscribedChannel), message.data.timetoken);
}
/*fabric:end-highlight*/

@end
/*fabric:end-code*/
