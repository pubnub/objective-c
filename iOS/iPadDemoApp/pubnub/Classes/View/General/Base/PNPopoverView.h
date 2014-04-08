//
//  PNPopoverView.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNShadowEnableView.h"


#pragma mark Public interface declaration

@interface PNPopoverView : PNShadowEnableView


#pragma mark - Properties

/**
 This property allow to specify whether background elements should be disabled when this popover view appear or not.
 */
@property (nonatomic, assign, getter = shouldDisableBackgroundElementsOnAppear) BOOL disableBackgroundElementsOnAppear;

/**
 This property allow to specify whether background should be dimmed or not (work only if \c disableBackgroundElementsOnAppear
 set to \c YES).
 */
@property (nonatomic, assign, getter = shouldDimmBackgroundOnAppear) BOOL dimmBackgroundOnAppear;

#pragma mark -


@end
