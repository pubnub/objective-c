//
//  PNPushNotificationsAuditionHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNPushNotificationsAuditionHelper : NSObject


#pragma mark - Instance methods

/**
 Return list of channels for which push notifications has been enabled during previous sessions.
 
 @return List of \b PNChannel instances.
 */
- (NSArray *)channels;

/**
 Perform channels push notification audition.
 
 @param handlerBlock
 Block which will be called when process will be completed and pass two parameters: reference on list of channels and
 error (if request failed).
 */
- (void)performRequestWithBlock:(void(^)(NSArray *, PNError *))handlerBlock;

#pragma mark -


@end
