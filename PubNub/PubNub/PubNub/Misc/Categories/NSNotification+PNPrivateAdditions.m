/**
 @author Sergey Mamontov
 @since 3.7.9
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "NSNotification+PNPrivateAdditions.h"


#pragma mark Types & Structures

struct PNPrivateNotificationDataStructure {

    /**
     @brief Stores reference on original notification name for which this instance has been created.

     @since 3.7.9
     */
    __unsafe_unretained NSString *notificationName;

    /**
     @brief Stores reference on data which should be sent along with notification.

     @since 3.7.9
     */
    __unsafe_unretained NSString *data;

    /**
     @brief Stores reference on token which allow to find correct callback block and call it.

     @since 3.7.9
     */
    __unsafe_unretained NSString *callbackToken;
};

struct PNPrivateNotificationDataStructure PNPrivateNotificationData = {

   .notificationName = @"notificationName",
   .data = @"notificationData",
   .callbackToken = @"token"
};


#pragma mark - Class interface implementation

@implementation NSNotification (PNPrivateAdditions)


#pragma mark - Class methods

+ (NSString *)pn_privateNotificationNameFrom:(NSString *)userNotification {

    return [userNotification stringByReplacingOccurrencesOfString:@"Notification"
                                                       withString:@"PrivateNotification"
                                                          options:NSBackwardsSearch
                                                            range:(NSRange){0, userNotification.length}];
}

+ (instancetype)pn_notificationWithName:(NSString *)notificationName
                          callbackToken:(NSString *)callbackToken data:(id)userData
                                 sender:(id)senderObject {

    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObject:notificationName
                                                                   forKey:PNPrivateNotificationData.notificationName];
    if (userData) {

        [data setValue:userData forKey:PNPrivateNotificationData.data];
    }
    if (callbackToken) {

        [data setValue:callbackToken forKey:PNPrivateNotificationData.callbackToken];
    }

    return [self notificationWithName:[self pn_privateNotificationNameFrom:notificationName]
                               object:senderObject userInfo:[data copy]];
}


#pragma mark - Instance methods

- (id)pn_data {

    return [self.userInfo valueForKey:PNPrivateNotificationData.data];
}

- (NSString *)pn_callbackToken {

    return [self.userInfo valueForKey:PNPrivateNotificationData.callbackToken];
}

- (NSString *)pn_notificationName {

    return [self.userInfo valueForKey:PNPrivateNotificationData.notificationName];
}

- (NSNotification *)pn_notification {

    return [NSNotification notificationWithName:[self pn_notificationName] object:self.object
                                       userInfo:([self pn_data] ? [self pn_data] : self.userInfo)];
}

#pragma mark -


@end