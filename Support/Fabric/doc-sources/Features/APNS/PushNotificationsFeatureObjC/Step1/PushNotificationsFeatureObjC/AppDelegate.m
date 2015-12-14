/*fabric:start-text*/
// Register the application for remote push notifications and handle registration request results.
/*fabric:end-text*/
/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
/*fabric:start-code*/
#import "AppDelegate.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*fabric:start-highlight*/
    UIUserNotificationType types = (UIUserNotificationTypeBadge | UIUserNotificationTypeSound |
                                    UIUserNotificationTypeAlert);
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    // In iOS 8, this is when the user receives a system prompt for notifications in your app
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    /*fabric:end-highlight*/

    return YES;
}

/*fabric:start-highlight*/
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // We have our devide push token now.
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    // Something went wrong and you better to look into error description.
}
/*fabric:end-highlight*/

@end
/*fabric:end-code*/
