/*fabric:start-text*/
// To receive messages from the channel group, subscribe to the channel group created in the previous step.
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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: PubNub?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.client = PubNub.client()
        self.client?.addChannels(["announcements", "lobby"], toGroup: "tradeshow",
            withCompletion: {[weak self] (status) -> Void in
                
                /*fabric:start-highlight*/
                // Check whether request successfully completed or not.
                if !status.error {
                    
                    withExtendedLifetime(self) {
                        
                        self!.client?.addListener(self!)
                        self!.client?.subscribeToChannelGroups(["tradeshow"], withPresence: false)
                    }
                }
                else {
                    
                    // Handle channels list modification for group error. Check 'category' property
                    // to find out possible reason because of which request did fail.
                    // Review 'errorData' property (which has PNErrorData data type) of status
                    // object to get additional information about issue.
                    //
                    // Request can be resent using: status.retry()
                }
                /*fabric:end-highlight*/
        })

        return true
    }
}
/*fabric:end-code*/

