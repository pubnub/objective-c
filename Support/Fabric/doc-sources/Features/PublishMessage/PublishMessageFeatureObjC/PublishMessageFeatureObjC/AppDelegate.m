/*fabric:start-text*/
// Publishing a JSON object to a channel is really easy. Here is an an example to get you started.
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

- (BOOL)            application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*fabric:start-highlight*/
    self.client = [PubNub client];
    [self.client publish:@{@"announcement": @"Welcome to PubNub!"}
               toChannel:@"announcements" withCompletion:^(PNPublishStatus *status) {
              
        // Check whether request successfully completed or not.
        if (!status.isError) {
         
            // Message successfully published to specified channel.
        }
        // Request processing failed.
        else {
            
            // Handle message publish error. Check 'category' property to find out possible issue
            // because of which request did fail.
            //
            // Request can be resent using: [status retry];
        }
    }];
    /*fabric:end-highlight*/
    
    return YES;
}

@end
/*fabric:end-code*/
