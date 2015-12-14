/*fabric:start-text*/
// If the storage and history feature is enabled, you can use this snippet to retrieve previously published messages from storage.
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
        self.client?.historyForChannel("lobby", withCompletion: { (result, status) -> Void in
            
            if status == nil {
                
                // Handle downloaded history using:
                //   result.data.start - oldest message time stamp in response
                //   result.data.end - newest message time stamp in response
                //   result.data.messages - list of messages
            }
            else {
                
                // Handle message history download error. Check 'category' property
                // to find out possible reason because of which request did fail.
                // Review 'errorData' property (which has PNErrorData data type) of status
                // object to get additional information about issue.
                //
                // Request can be resent using: status.retry()
            }
        })
        /*fabric:end-highlight*/
        
        return true
    }
}
/*fabric:end-code*/
