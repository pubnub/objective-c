//
//  PNPushNotificationStateChangeView.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"


#pragma mark Public interface declaration

@interface PNPushNotificationStateChangeView : PNInputFormView


#pragma mark - Class methods

/**
 Retrieve reference on initialized view which is suitable for push notification enabling on specified list of channels.
 */
+ (instancetype)viewFromNibForEnabling;

/**
 Retrieve reference on initialized view which is suitable for push notification disabling on specified list of channels.
 */
+ (instancetype)viewFromNibForDisabling;

#pragma mark -


@end
