/*fabric:start-text*/
// To handle real-time messages from a subscribed channel group (subscribed on in previous steps), add a message handling callback.
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
        self.client?.addChannels(["announcements", "lobby"], toGroup: "tradeshow",
            withCompletion: {[weak self] (status) -> Void in
                
                // Check whether request successfully completed or not.
                if !status.error {
                    
                    withExtendedLifetime(self) {
                        
                        self!.client?.addListener(self!)
                        self!.client?.subscribeToChannelGroups(["tradeshow"], withPresence: false)
                    }
                }
                else {
                }
        })

        return true
    }
    
    func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        
        if status.category == .PNUnexpectedDisconnectCategory {
        }
        else if status.category == .PNConnectedCategory {
        }
        else if status.category == .PNReconnectedCategory {
        }
        else if status.category == .PNDisconnectedCategory {
        }
        else if status.category == .PNDecryptionErrorCategory {
        }
    }
    
    /*fabric:start-highlight*/
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        
        // Handle new message stored in message.data.message
        if message.data.actualChannel != nil {
            
            // Message has been received on channel group stored in
            // message.data.subscribedChannel
        }
        else {
            
            // Message has been received on channel stored in
            // message.data.subscribedChannel
        }
        
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
    }
    /*fabric:end-highlight*/
}
/*fabric:end-code*/

