#import "PubNub.h"

/**
 Base class extension which provide methods for APNS manipulation.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (APNS)


#pragma mark - Class (singleton) methods

/**
 Enable push notifications on specified channel. This API allow to observer for messages in specific channel via
 Apple Push Notifications even if application is not running. Each time when someone post message into channel for which
 this API has been called from client side, server will send push notification to the device which used this API to
 observe for new messages. Device identification (to which push notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +enablePushNotificationsOnChannel:withDevicePushToken:andCompletionHandlingBlock:
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;

/**
 Enable push notifications on specified channel.
 
 @code
 @endcode
 This method extends \a +enablePushNotificationsOnChannel:withDevicePushToken: and allow to specify push
 notification enabling process handling block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
 
      if (error == nil) {

          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push 
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
 
          if (error == nil) {
 
             // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
             // notifications to arrive.
          }
          else {
 
              // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @param handlerBlock
 The block which is called when push notification enabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification enabling state changed; \c error - error because of which push notification enabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +enablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

/**
 Enable push notifications on set of channels. This API allow to observer for messages in specified set of channels
 via Apple Push Notifications even if application is not running. Each time when someone post message into channels
 for which this API was called from client side, server will send push notification to the device which used this API to
 observe for new messages. Device identification (to which push notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance..
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +enablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
 
 @see +disablePushNotificationsOnChannels:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;

/**
 Enable push notifications on set of channels.
 
 @code
 @endcode
 This method extends \a +enablePushNotificationsOnChannels:withDevicePushToken: and allow to specify push
 notification enabling process handling block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
 
      if (error == nil) {

          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push 
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){

          if (error == nil) {

              // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
              // notifications to arrive.
          }
          else {

              // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.

 @param channels
 Array of \b PNChannel instances for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @param handlerBlock
 The block which is called when push notification enabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification enabling state changed; \c error - error because of which push notification enabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +enablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

/**
 Disable push notifications on specified channel. After usage of this API, observation will be removed from specified
 channel and no more push notifications will be delivered to the device. Device identification (to which push
 notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:andCompletionHandlingBlock:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;

/**
 Disable push notifications on specified channel.
 
 @code
 @endcode
 This method extends \a +disablePushNotificationsOnChannel:withDevicePushToken: and allow to specify push
 notifications disable process handling block.

 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
     if (error == nil) {

         // PubNub client successfully disabled push notifications on specified set of channels.
     }
     else {
 
         // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
         // push notifications.
     }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
          if (error == nil) {
              
              // PubNub client successfully disabled push notifications on specified set of channels.
          }
          else {
 
              // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification disabling state changed; \c error - error because of which push notification disabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

/**
 Disable push notifications on set of channels. After usage of this API, observation will be removed from specified
 channel and no more push notifications will be delivered to the device. Device identification (to which push
 notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +disablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;

/**
 Disable push notifications on set of channel.
 
 @code
 @endcode
 This method extends \a +disablePushNotificationsOnChannels:withDevicePushToken: and allow to specify push
 notifications disable process handling block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
     if (error == nil) {
 
         // PubNub client successfully disabled push notifications on specified set of channels.
     }
     else {
 
         // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
         // push notifications.
     }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:deviceToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
          if (error == nil) {
              
              // PubNub client successfully disabled push notifications on specified set of channels.
          }
          else {
 
              // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification disabling state changed; \c error - error because of which push notification disabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +disablePushNotificationsOnChannels:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

/**
 Disable push notification from all channels at which it has been enabled with specified \c pushToken. As soon as this
 request will be completed, \b PubNub client won't receive remote push notification on any of the channels when new message is posted into it.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub removeAllPushNotificationsForDevicePushToken:self.devicePushToken
  withCompletionHandlingBlock:^(PNError *error) {

         if (error == nil) {

             // Push notifications has been disabled from all channels on which it has been enabled using specified
             // device push notification.
         }
         else {

             // PubNub did fail to disable push notifications from all channels on which client subscribed with
             // specified device push notification. Error reason can be found in error instance.
         }
  }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

     // You are free to disable push notifications from all channels right from this callback or store device push token in property and use it later.
     [PubNub removeAllPushNotificationsForDevicePushToken:deviceToken withCompletionHandlingBlock:^(PNError *error) {

         if (error == nil) {

             // Push notifications has been disabled from all channels on which it has been enabled using specified
             // device push notification.
         }
         else {

             // PubNub did fail to disable push notifications from all channels on which client subscribed with
             // specified device push notification. Error reason can be found in error instance.
         }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {

     // Push notifications has been disabled from all channels on which it has been enabled using specified device
     // push notification.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {

     // PubNub did fail to disable push notifications from all channels on which client subscribed with specified
     // device push notification. Error reason can be found in error instance.
 }
 @endcode
 
 There is also way to observe push notification disable process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsRemoveObserver:self withCallbackBlock:^(PNError *error) {
 
     if (error == nil) {

         // Push notifications has been disabled from all channels on which it has been enabled using specified
         // device push notification.
     }
     else {

         // PubNub did fail to disable push notifications from all channels on which client subscribed with
         // specified device push notification. Error reason can be found in error instance.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationRemoveDidCompleteNotification,
 kPNClientPushNotificationRemoveDidFailNotification.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes one argument:
 \c error - error because of which push notification disabling failed. Always check \a error.code to find out what caused error (check PNErrorCodes
 header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class

 @see +requestPushNotificationEnabledChannelsForDevicePushToken:withCompletionHandlingBlock:
 */
+ (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;

/**
 Receive list of channels on which push notifications has been enabled with specified \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:self.devicePushToken
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {

          // PubNub client successfully pulled out list of channels for which message observation has been enabled
          // with specified device push token.
      }
      else {

          // PubNub client did fail to pull out list of channels for which message observation has been enabled with
          // specified device push token.
      }
  }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to pull out all channels for which push notification hass been enabled right from this callback or store device push 
     // token in property and use it later.
     [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:deviceToken
      withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {

          if (error == nil) {

              // PubNub client successfully pulled out list of channels for which message observation has been enabled
              // with specified device push token.
          }
          else {

              // PubNub client did fail to pull out list of channels for which message observation has been enabled with
              // specified device push token.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
  - (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {
 
     // PubNub client successfully pulled out list of channels for which message observation has been enabled with
     // specified device push token.
 }
 
 - (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out list of channels for which message observation has been enabled with
     // specified device push token.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnabledChannelsObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully pulled out list of channels for which message observation has been enabled with
         // specified device push token.
     }
     else {

         // PubNub client did fail to pull out list of channels for which message observation has been enabled with
         // specified device push token.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationChannelsRetrieveDidCompleteNotification,
 kPNClientPushNotificationChannelsRetrieveDidFailNotification.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes two arguments:
 \c channels - return list of channels for which push notification has been enabled with specified device push token;
 \c error - error because of push notification enabled channels fetch failed. Always check \a error.code to find out what
 caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and
 \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class

 @see +removeAllPushNotificationsForDevicePushToken:withCompletionHandlingBlock:
 */
+ (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;


#pragma mark - Instance methods

/**
 Enable push notifications on specified channel. This API allow to observer for messages in specific channel via
 Apple Push Notifications even if application is not running. Each time when someone post message into channel for which
 this API has been called from client side, server will send push notification to the device which used this API to
 observe for new messages. Device identification (to which push notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see -enablePushNotificationsOnChannel:withDevicePushToken:andCompletionHandlingBlock:
 
 @see -disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see -removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
- (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;

/**
 Enable push notifications on specified channel.
 
 @code
 @endcode
 This method extends \a -enablePushNotificationsOnChannel:withDevicePushToken: and allow to specify push
 notification enabling process handling block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
 
      if (error == nil) {

          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push 
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
 
          if (error == nil) {
 
             // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
             // notifications to arrive.
          }
          else {
 
              // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @param handlerBlock
 The block which is called when push notification enabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification enabling state changed; \c error - error because of which push notification enabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see -enablePushNotificationsOnChannel:withDevicePushToken:
 
 @see -disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see -removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
- (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

/**
 Enable push notifications on set of channels. This API allow to observer for messages in specified set of channels
 via Apple Push Notifications even if application is not running. Each time when someone post message into channels
 for which this API was called from client side, server will send push notification to the device which used this API to
 observe for new messages. Device identification (to which push notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance..
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see -enablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
 
 @see -disablePushNotificationsOnChannels:withDevicePushToken:
 
 @see -removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
- (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;

/**
 Enable push notifications on set of channels.
 
 @code
 @endcode
 This method extends \a -enablePushNotificationsOnChannels:withDevicePushToken: and allow to specify push
 notification enabling process handling block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
 
      if (error == nil) {

          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push 
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){

          if (error == nil) {

              // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
              // notifications to arrive.
          }
          else {

              // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.

 @param channels
 Array of \b PNChannel instances for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @param handlerBlock
 The block which is called when push notification enabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification enabling state changed; \c error - error because of which push notification enabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see -enablePushNotificationsOnChannel:withDevicePushToken:
 
 @see -disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see -removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
- (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

/**
 Disable push notifications on specified channel. After usage of this API, observation will be removed from specified
 channel and no more push notifications will be delivered to the device. Device identification (to which push
 notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see -disablePushNotificationsOnChannel:withDevicePushToken:andCompletionHandlingBlock:
 
 @see -removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
- (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;

/**
 Disable push notifications on specified channel.
 
 @code
 @endcode
 This method extends \a -disablePushNotificationsOnChannel:withDevicePushToken: and allow to specify push
 notifications disable process handling block.

 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
     if (error == nil) {

         // PubNub client successfully disabled push notifications on specified set of channels.
     }
     else {
 
         // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
         // push notifications.
     }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
          if (error == nil) {
              
              // PubNub client successfully disabled push notifications on specified set of channels.
          }
          else {
 
              // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification disabling state changed; \c error - error because of which push notification disabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see -disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see -removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
- (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

/**
 Disable push notifications on set of channels. After usage of this API, observation will be removed from specified
 channel and no more push notifications will be delivered to the device. Device identification (to which push
 notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see -disablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
 
 @see -removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
- (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;

/**
 Disable push notifications on set of channel.
 
 @code
 @endcode
 This method extends \a -disablePushNotificationsOnChannels:withDevicePushToken: and allow to specify push
 notifications disable process handling block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
     if (error == nil) {
 
         // PubNub client successfully disabled push notifications on specified set of channels.
     }
     else {
 
         // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
         // push notifications.
     }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:deviceToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
          if (error == nil) {
              
              // PubNub client successfully disabled push notifications on specified set of channels.
          }
          else {
 
              // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification disabling state changed; \c error - error because of which push notification disabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see -disablePushNotificationsOnChannels:withDevicePushToken:
 
 @see -removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
- (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

/**
 Disable push notification from all channels at which it has been enabled with specified \c pushToken. As soon as this
 request will be completed, \b PubNub client won't receive remote push notification on any of the channels when new message is posted into it.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub removeAllPushNotificationsForDevicePushToken:self.devicePushToken
  withCompletionHandlingBlock:^(PNError *error) {

         if (error == nil) {

             // Push notifications has been disabled from all channels on which it has been enabled using specified
             // device push notification.
         }
         else {

             // PubNub did fail to disable push notifications from all channels on which client subscribed with
             // specified device push notification. Error reason can be found in error instance.
         }
  }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

     // You are free to disable push notifications from all channels right from this callback or store device push token in property and use it later.
     [PubNub removeAllPushNotificationsForDevicePushToken:deviceToken withCompletionHandlingBlock:^(PNError *error) {

         if (error == nil) {

             // Push notifications has been disabled from all channels on which it has been enabled using specified
             // device push notification.
         }
         else {

             // PubNub did fail to disable push notifications from all channels on which client subscribed with
             // specified device push notification. Error reason can be found in error instance.
         }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {

     // Push notifications has been disabled from all channels on which it has been enabled using specified device
     // push notification.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {

     // PubNub did fail to disable push notifications from all channels on which client subscribed with specified
     // device push notification. Error reason can be found in error instance.
 }
 @endcode
 
 There is also way to observe push notification disable process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsRemoveObserver:self withCallbackBlock:^(PNError *error) {
 
     if (error == nil) {

         // Push notifications has been disabled from all channels on which it has been enabled using specified
         // device push notification.
     }
     else {

         // PubNub did fail to disable push notifications from all channels on which client subscribed with
         // specified device push notification. Error reason can be found in error instance.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationRemoveDidCompleteNotification,
 kPNClientPushNotificationRemoveDidFailNotification.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes one argument:
 \c error - error because of which push notification disabling failed. Always check \a error.code to find out what caused error (check PNErrorCodes
 header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class

 @see -requestPushNotificationEnabledChannelsForDevicePushToken:withCompletionHandlingBlock:
 */
- (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;

/**
 Receive list of channels on which push notifications has been enabled with specified \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestPushNotificationEnabledChannelsForDevicePushToken:self.devicePushToken
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {

          // PubNub client successfully pulled out list of channels for which message observation has been enabled
          // with specified device push token.
      }
      else {

          // PubNub client did fail to pull out list of channels for which message observation has been enabled with
          // specified device push token.
      }
  }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to pull out all channels for which push notification hass been enabled right from this callback or store device push 
     // token in property and use it later.
     [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:deviceToken
      withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {

          if (error == nil) {

              // PubNub client successfully pulled out list of channels for which message observation has been enabled
              // with specified device push token.
          }
          else {

              // PubNub client did fail to pull out list of channels for which message observation has been enabled with
              // specified device push token.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
  - (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {
 
     // PubNub client successfully pulled out list of channels for which message observation has been enabled with
     // specified device push token.
 }
 
 - (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out list of channels for which message observation has been enabled with
     // specified device push token.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPushNotificationsEnabledChannelsObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully pulled out list of channels for which message observation has been enabled with
         // specified device push token.
     }
     else {

         // PubNub client did fail to pull out list of channels for which message observation has been enabled with
         // specified device push token.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationChannelsRetrieveDidCompleteNotification,
 kPNClientPushNotificationChannelsRetrieveDidFailNotification.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes two arguments:
 \c channels - return list of channels for which push notification has been enabled with specified device push token;
 \c error - error because of push notification enabled channels fetch failed. Always check \a error.code to find out what
 caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and
 \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class

 @see -removeAllPushNotificationsForDevicePushToken:withCompletionHandlingBlock:
 */
- (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;

#pragma mark -


@end
