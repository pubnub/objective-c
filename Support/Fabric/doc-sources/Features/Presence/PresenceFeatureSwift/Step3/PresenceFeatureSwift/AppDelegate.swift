/*fabric:start-text*/
// To handle real-time presence events on subscribed channels, add a presence event handling callback.
/*fabric:end-text*/
/**
@author Sergey Mamontov
@copyright © 2009-2015 PubNub, Inc.
*/
/*fabric:start-code*/
import UIKit
import PubNub
import PubNubBridge


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

    var window: UIWindow?
    var client: PubNub?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.client = PubNub.client()
        self.client?.addListener(self)
        self.client?.subscribeToPresenceChannels(["lobby"])
        
        return true
    }
    
    func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        
        if status.category == .PNUnexpectedDisconnectCategory {
        }
        else if status.category == .PNConnectedCategory {
        }
        else if status.category == .PNReconnectedCategory {
        }
        else if status.category == .PNDecryptionErrorCategory {
        }
    }
    
    /*fabric:start-highlight*/
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
        // state-change).
        if event.data.actualChannel != nil {
            
            // Presence event has been received on channel group stored in
            // event.data.subscribedChannel
        }
        else {
            
            // Presence event has been received on channel stored in
            // event.data.subscribedChannel
        }
        
        if event.data.presenceEvent != "state-change" {
            
            println("\(event.data.presence.uuid) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) " +
                "(Occupancy: \(event.data.presence.occupancy))");
        }
        else {
            
            println("\(event.data.presence.uuid) changed state at: " +
                "\(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) to:\n" +
                "\(event.data.presence.state)");
        }
    }
    /*fabric:end-highlight*/
}
/*fabric:end-code*/

