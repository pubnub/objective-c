/*fabric:start-text*/
// To receive messages from other users in real-time, you must subscribe to the desired channels first.
/*fabric:end-text*/
/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
/*fabric:start-code*/
import UIKit
/*fabric:start-highlight*/
import PubNub
import PubNubBridge
/*fabric:end-highlight*/


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /*fabric:start-highlight*/
    var client: PubNub?
    /*fabric:end-highlight*/

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /*fabric:start-highlight*/
        self.client = PubNub.client()
        self.client?.addListener(self)
        self.client?.subscribeToChannels(["lobby"], withPresence: false)
        /*fabric:end-highlight*/
        
        return true
    }
}
/*fabric:end-code*/

