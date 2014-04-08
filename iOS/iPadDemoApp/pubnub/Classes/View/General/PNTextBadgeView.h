//
//  PNTextBadgeView.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/26/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNRoundedView.h"


#pragma mark Public interface declaration

@interface PNTextBadgeView : PNRoundedView


#pragma mark - Properties

/**
 This propperty allow to specify whether badge should hide if it will be assigned empty string or equal to "0".
 */
@property (nonatomic, assign, getter = shouldHideWithEmptyOrZeroValue) BOOL hideWithEmptyOrZeroValue;


#pragma mark - Instance methods

/**
 Update value which is held by badge. Badge may increase in width, so it always should be taken into account.
 By default size will be increased along with position update (badge will increase it's width in both sides from place
 where it has been pinned).
 
 @param badgeValue
 \b NSString instance which should be shown in badge.
 */
- (void)updateBadgeValueTo:(NSString *)badgeValue;

#pragma mark -


@end
