//
//  PNNumberBadgeView.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/24/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNTextBadgeView.h"


#pragma mark Public interface declaration

@interface PNNumberBadgeView : PNTextBadgeView


#pragma mark - Instance methods

/**
 Update value which is held by badge. Badge may increase in width, so it always should be taken into account.
 By default size will be increased along with position update (badge will increase it's width in both sides from place
 where it has been pinned).
 
 @param badgeValue
 It can be any decimal value.
 */
- (void)updateIntegerBadgeValueTo:(NSInteger)badgeValue;

#pragma mark -


@end
