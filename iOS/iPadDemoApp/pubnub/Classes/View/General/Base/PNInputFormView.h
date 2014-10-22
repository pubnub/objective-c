//
//  PNInputFormView.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPopoverView.h"


#pragma mark Public interface declaration

@interface PNInputFormView : PNPopoverView


#pragma mark - Properties

@property (nonatomic, assign) CGFloat originalVerticalPosition;


#pragma mark - Instance methods

/**
 Check whether user input is active at this moment or not.
 */
- (BOOL)isUserInputActive;

/**
 Allow to dismiss keyboard which has been shown during form data input.
 */
- (void)completeUserInput;

#pragma mark -


@end
