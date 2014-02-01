//
//  PNAuthorizationKeyChangeView.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/26/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNAuthorizationKeyChangeDelegate.h"
#import "PNShadowEnableView.h"


@interface PNAuthorizationKeyChangeView : PNShadowEnableView


#pragma mark Properties

// Stores reference on delegate which will be used to notify about authorization key change attempt.
@property (nonatomic, pn_desired_weak) id<PNAuthorizationKeyChangeDelegate> delegate;


#pragma mark - Class methods

/**
 * Allow to load instance from NIB file
 */
+ (id)viewFromNib;

#pragma mark -


@end
