/*fabric:start-text*/
// It is always a good idea to add a subscription status handling callback to know when a subscription process completed or stumbled on an unexpected disconnection.
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
/*fabric:start-highlight*/
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {
/*fabric:end-highlight*/

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
    
    /*fabric:start-highlight*/
    func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        
        if status.category == .PNUnexpectedDisconnectCategory {
            
            // This event happens when radio / connectivity is lost
        }
        else if status.category == .PNConnectedCategory {
            
            // Connect event. You can do stuff like publish, and know you'll get it.
            // Or just use the connected event to confirm you are subscribed for
            // UI / internal notifications, etc
        }
        else if status.category == .PNReconnectedCategory {
            
            // Happens as part of our regular operation. This event happens when
            // radio / connectivity is lost, then regained.
        }
        else if status.category == .PNDisconnectedCategory {
            
            // Disconnection event. After this moment any messages from unsubscribed channel
            // won't reach this callback.
        }
        else if status.category == .PNDecryptionErrorCategory {
            
            // Handle messsage decryption error. Probably client configured to
            // encrypt messages and on live data feed it received plain text.
        }
    }
    /*fabric:end-highlight*/
}
/*fabric:end-code*/

