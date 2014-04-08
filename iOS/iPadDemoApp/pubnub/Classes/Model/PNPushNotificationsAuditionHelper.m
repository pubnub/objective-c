//
//  PNPushNotificationsAuditionHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPushNotificationsAuditionHelper.h"
#import "PNDataManager.h"


#pragma mark Private interface declaration

@interface PNPushNotificationsAuditionHelper ()


#pragma mark - Properties

/**
 Stores list of channels for which push notifications has been enabled.
 */
@property (nonatomic, strong) NSArray *pushNotificationEnabledChannels;

#pragma mark -


@end


#pragma mark - Public interface declaration

@implementation PNPushNotificationsAuditionHelper


#pragma mark - Instance methods

- (NSArray *)channels {
    
    return self.pushNotificationEnabledChannels;
}

- (void)performRequestWithBlock:(void(^)(NSArray *, PNError *))handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:[PNDataManager sharedInstance].devicePushToken
                                         withCompletionHandlingBlock:^(NSArray *channels, PNError *requestError) {
                                             
                                             weakSelf.pushNotificationEnabledChannels = channels;
                                             
                                             if (handlerBlock) {
                                                 
                                                 handlerBlock(channels, requestError);
                                             }
                                         }];
}

#pragma mark -


@end
