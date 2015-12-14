/*fabric:start-text*/
// Initialize the PubNub client and enable push notifications on channels to receive updates while the application is inactive.
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
    /*fabric:end-highlight*/
    UIUserNotificationType types = (UIUserNotificationTypeBadge | UIUserNotificationTypeSound |
                                    UIUserNotificationTypeAlert);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /*fabric:start-highlight*/
    [self.client addPushNotificationsOnChannels:@[@"announcements"] withDevicePushToken:deviceToken
                                  andCompletion:^(PNAcknowledgmentStatus *status) {
        
        // Check whether request successfully completed or not.
        if (!status.isError) {
            
            // Handle successful push notification enabling on passed channels.
        }
        // Request processing failed.
        else {
            
            // Handle modification error. Check 'category' property to find out possible issue because
            // of which request did fail.
            //
            // Request can be resent using: [status retry];
        }
    }];
    /*fabric:end-highlight*/
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

@end
/*fabric:end-code*/
