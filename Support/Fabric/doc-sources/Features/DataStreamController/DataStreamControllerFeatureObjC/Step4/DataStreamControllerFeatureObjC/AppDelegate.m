/*fabric:start-text*/
// To handle real-time messages from a subscribed channel group (subscribed on in previous steps), add a message handling callback.
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
