//
//  PNRoundedView.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/17/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface PNRoundedView : UIView


#pragma mark - Properties

/**
 Stores corner radius which will be applied to all four corners.
 
 @note If this property specified, then all other particular radiuses will be discarded.
 */
@property (nonatomic, strong) NSNumber *cornerRadius;

/**
 Stores top left corner radius value.
 
 @note This value will be discarded if \c cornerRadius specified.
 */
@property (nonatomic, strong) NSNumber *topLeftCornerRadius;

/**
 Stores top right corner radius value.
 
 @note This value will be discarded if \c cornerRadius specified.
 */
@property (nonatomic, strong) NSNumber *topRightCornerRadius;

/**
 Stores top left corner radius value.
 
 @note This value will be discarded if \c cornerRadius specified.
 */
@property (nonatomic, strong) NSNumber *bottomLeftCornerRadius;

/**
 Stores top right corner radius value.
 
 @note This value will be discarded if \c cornerRadius specified.
 */
@property (nonatomic, strong) NSNumber *bottomRightCornerRadius;

/**
 Specify color of the border around view.
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 Stores reference on the collor which will be used to fill view (allow to custom color with XIB).
 */
@property (nonatomic, strong) UIColor *fillColor;

#pragma mark -


@end
