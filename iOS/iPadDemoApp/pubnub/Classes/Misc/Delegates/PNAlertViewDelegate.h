//
//  PNAlertViewDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/24/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNAlertView;


#pragma mark - Delegate interface declaration

@protocol PNAlertViewDelegate <NSObject>


@required

/**
 If delegate implement this method, it will be notified that alert view is closed.
 
 @param view
 \b PNAlertView instance which called this callback method.
 
 @param buttonIndex
 Index of the button with which user closed alert.
 */
- (void)alertView:(PNAlertView *)view didDismissWithButtonIndex:(NSUInteger)buttonIndex;

#pragma mark -


@end
