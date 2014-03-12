//
//  PNShadowEnableView.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#import <Foundation/Foundation.h>
#import "PNRoundedView.h"

#pragma mark Publis interface declaration

@interface PNShadowEnableView : UIView


#pragma mark - Properties

/**
 Specify radius for the view's corners.
 */
@property (nonatomic, strong) NSNumber *cornerRadius;

/**
 Stores corner radius value for upper left and right corners.
 
 @note This value will be discarded if \c cornerRadius specified.
 */
@property (nonatomic, strong) NSNumber *topCornerRadius;

/**
 Stores corner radius value for bottom left and right corners.
 
 @note This value will be discarded if \c cornerRadius specified.
 */
@property (nonatomic, strong) NSNumber *bottomCornerRadius;

/**
 Specify color of the border around view.
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 Specify shadow size (by default it will be set to 5)
 */
@property (nonatomic, strong) NSNumber *shadowSize;

/**
 Specify shadow offset (by default it will be set to {0.0f, 0.0f})
 */
@property (nonatomic, assign) CGSize shadowOffest;


#pragma mark - Instance methods

- (void)updateShadow;

#pragma mark -


@end
