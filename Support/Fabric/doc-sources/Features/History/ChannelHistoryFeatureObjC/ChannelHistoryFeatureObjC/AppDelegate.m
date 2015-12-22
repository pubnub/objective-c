/*fabric:start-text*/
// If the storage and history feature is enabled, you can use this snippet to retrieve previously published messages from storage.
/*fabric:end-text*/
/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
/*fabric:start-code*/
#import "AppDelegate.h"
/*fabric:start-highlight*/
#import <PubNub/PubNub.h>
#import <PubNubBridge/PubNub+FAB.h>
/*fabric:end-highlight*/


@interface AppDelegate ()

/*fabric:start-highlight*/
@property (nonatomic, strong) PubNub *client;
/*fabric:end-highlight*/

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*fabric:start-highlight*/
    self.client = [PubNub client];
    [self.client historyForChannel:@"lobby" withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        
        // Check whether request successfully completed or not.
        if (!status.isError) {
            
            // Handle downloaded history using:
            //   result.data.start - oldest message time stamp in response
            //   result.data.end - newest message time stamp in response
            //   result.data.messages - list of messages
        }
        // Request processing failed.
        else {
            
            // Handle message history download error. Check 'category' property to find out possible
            // issue because of which request did fail.
            //
            // Request can be resent using: [status retry];
        }
    }];
    /*fabric:end-highlight*/
    
    return YES;
}

@end
/*fabric:end-code*/
