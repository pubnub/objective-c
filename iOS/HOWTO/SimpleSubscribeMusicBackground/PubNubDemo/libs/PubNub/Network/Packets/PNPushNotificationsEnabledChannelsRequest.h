//
//  PNPushNotificationsEnabledChannelsRequest.h
//  pubnub
//
//  This class allow to create request which will
//  retrieve list of channels on which push notifications
//  eas enabled.
//
//
//  Created by Sergey Mamontov on 05/10/13.
//
//

#import "PNBaseRequest.h"


@interface PNPushNotificationsEnabledChannelsRequest : PNBaseRequest


#pragma mark Class methods

+ (PNPushNotificationsEnabledChannelsRequest *)requestWithDevicePushToken:(NSData *)pushToken;


#pragma mark - Instance methods

- (id)initWithDevicePushToken:(NSData *)pushToken;

#pragma mark -


@end
