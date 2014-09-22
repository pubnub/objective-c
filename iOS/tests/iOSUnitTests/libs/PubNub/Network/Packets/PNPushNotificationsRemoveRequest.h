//
//  PNPushNotificationsRemoveRequest.h
//  pubnub
//
//  This class allwo to build request which will remove
//  push notifications from all channels on which
//  they was enabled before.
//
//
//  Created by Sergey Mamontov on 05/10/13.
//
//

#import "PNBaseRequest.h"


@interface PNPushNotificationsRemoveRequest : PNBaseRequest


#pragma mark - Properties

// Stores reference on stringified push notification token
@property (nonatomic, readonly, strong) NSData *devicePushToken;


#pragma mark Class methods

+ (PNPushNotificationsRemoveRequest *)requestWithDevicePushToken:(NSData *)pushToken;


#pragma mark - Instance methods

- (id)initWithDevicePushToken:(NSData *)pushToken;

#pragma mark -


@end
