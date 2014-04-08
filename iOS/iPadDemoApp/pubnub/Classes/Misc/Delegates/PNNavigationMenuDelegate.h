//
//  PNNavigationMenuDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/26/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNNavigationMenuButton;


#pragma mark - Protocol declaration

@protocol PNNavigationMenuDelegate <NSObject>


@required

/**
 Every time when user tap on button, this delegate method will be called.
 */
- (void)userDidTapOnButton:(PNNavigationMenuButton *)button;

#pragma mark -


@end
