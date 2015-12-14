/*fabric:start-text*/
// To handle real-time presence events on subscribed channels, add a presence event handling callback.
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
    [self.client subscribeToPresenceChannels:@[@"lobby"]];
    
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
- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
   
    // Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
    // state-change).
    if (event.data.actualChannel != nil) {
        
        // Presence event has been received on channel group stored in
        // event.data.subscribedChannel
    }
    else {
        
        // Presence event has been received on channel stored in
        // event.data.subscribedChannel
    }
    
    if (![event.data.presenceEvent isEqualToString:@"state-change"]) {
        
        NSLog(@"%@ \"%@'ed\" at: %@ on %@ (Occupancy: %@)",
              event.data.presence.uuid, event.data.presenceEvent, event.data.presence.timetoken,
              (event.data.actualChannel?: event.data.subscribedChannel),
              event.data.presence.occupancy);
    }
    else {
        
        NSLog(@"%@ changed state at: %@ on %@ to:\n%@", event.data.presence.uuid,
              event.data.presence.timetoken,
              (event.data.actualChannel?: event.data.subscribedChannel), event.data.presence.state);
    }
}
/*fabric:end-highlight*/

@end
/*fabric:end-code*/
