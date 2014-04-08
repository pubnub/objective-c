//
//  PNButton.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface PNButton : UIButton


#pragma mark - Properties

/**
 Property stores reference on background color which is set for button in normal state.
 */
@property (nonatomic, strong) UIColor *mainBackgroundColor;

/**
 Property stores reference on background collor which is set when button is tapped.
 */
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;

/**
 Property stores reference on title color which is set when button in normal state.
 */
@property (nonatomic, strong) UIColor *mainTitleColor;

/**
 Property stores reference on title color which is set when button is tapped.
 */
@property (nonatomic, strong) UIColor *highlightedTitleColor;

/**
 Property stores reference on number which is used to draw rounded corners (if required).
 */
@property (nonatomic, strong) NSNumber *cornerRadius;


#pragma mark - Instance methods

/**
 Allow to highlight button after user touched it (in other case button will look like deselected).
 */
- (void)highlight;

#pragma mark -


@end
