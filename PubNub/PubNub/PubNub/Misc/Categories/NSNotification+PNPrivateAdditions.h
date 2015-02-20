#import <Foundation/Foundation.h>


/**
 @brief Notification which is used by \b PubNub client internals to deliver some additional data
        along with default notification.

 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface NSNotification (PNPrivateAdditions)


#pragma mark - Class methods

/**
 @brief      This method allow to wrap name of notification which is used by user.
 @discussion This notification name will be used by observer to pre-process some data passed along
             with notification.

 @param userNotification Public notification name used by user to catch some \b PubNub client
                         events.

 @return Wrapped notification name which can be used internally.

 @since <#version number#>
 */
+ (NSString *)pn_privateNotificationNameFrom:(NSString *)userNotification;

/**
 @brief Construct notification object which allow to extend data which is passed by standard
        notification object.

 @param notificationName Public notification name (internally will be wrapped into private
                         notification name).
 @param callbackToken    Token which represent unique block which has been registered to trigger for
                         this notification.
 @param userData         Data which should at the end should be sent to the user in public
                         notification.
 @param senderObject     Reference on object from who this notification should be sent.

 @return Reference on constructed and ready to use private notification instance.

 @since <#version number#>
 */
+ (instancetype)pn_notificationWithName:(NSString *)notificationName
                          callbackToken:(NSString *)callbackToken data:(id)userData
                                 sender:(id)senderObject;


#pragma mark - Instance methods

/**
 @brief Fetch data stored inside of private notification.

 @return Reference on object which should be sent along with default public notification object.

 @since <#version number#>
 */
- (id)pn_data;

/**
 @brief Fetch reference on callback token which should ead to block which should be called in
        response for this notification.

 @return Reference on unique callback token.

 @since <#version number#>
 */
- (NSString *)pn_callbackToken;

/**
 @brief Fetch original notification name.

 @return Original notification name which has been passed during private instance creation.

 @since <#version number#>
 */
- (NSString *)pn_notificationName;

/**
 @brief Construct public notification using only required portion of data.

 @return Public notification which will use original notification name and data which is stored in
         private notification as userInfo

 @since <#version number#>
 */
- (NSNotification *)pn_notification;

#pragma mark -


@end