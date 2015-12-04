/*fabric:start-text*/
// Publishing a JSON object to a channel is really easy. Here is an an example to get you started.
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
        self.client?.publish(["announcement": "Welcome to PubNub!"], toChannel: "announcements", withCompletion: { (status) -> Void in
            
            if !status.error {
                
                // Message successfully published to specified channel.
            }
            else{
                
                // Handle message publish error. Check 'category' property
                // to find out possible reason because of which request did fail.
                // Review 'errorData' property (which has PNErrorData data type) of status
                // object to get additional information about the issue.
                //
                // Request can be resent using: status.retry()
            }
        })
        /*fabric:end-highlight*/
        
        return true
    }
}
/*fabric:end-code*/

