//
//  UIView+PNAddition.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Structures

typedef NS_OPTIONS(NSUInteger, PNViewAnimationOptions)  {
    
    // Flag which enable view's animation from top to middle.
    PNViewAnimationOptionTransitionFromTop = 1 << 0,
    
    // Flag which enable view's animation from middle to top.
    PNViewAnimationOptionTransitionToTop = 1 << 1,
    
    // Flag which enable view's animation from bottom to middle.
    PNViewAnimationOptionTransitionFromBottom = 1 << 2,
    
    // Flag which enable view's animation from middle to bottom.
    PNViewAnimationOptionTransitionToBottom = 1 << 3,
    
    // Flag which enable view's animation from left to middle.
    PNViewAnimationOptionTransitionFromLeft = 1 << 4,
    
    // Flag which enable view's animation from middle to left.
    PNViewAnimationOptionTransitionToLeft = 1 << 5,
    
    // Flag which enable view's animation from right to middle.
    PNViewAnimationOptionTransitionFromRight = 1 << 6,
    
    // Flag which enable view's animation from middle to right.
    PNViewAnimationOptionTransitionToRight = 1 << 7,
    
    // Flag which enable view's appear animation
    PNViewAnimationOptionTransitionFadeIn = 1 << 8,
    
    // Flag which enable view's disappear animation
    PNViewAnimationOptionTransitionFadeOut = 1 << 9
};


#pragma mark Public interface declaration

@interface UIView (PNAddition)


#pragma mark - Class methods

/**
 In case if \b UIView instance has XIB file with same name, this helper will allow to load it and return reference on
 initialized view which has been loaded from it.
 
 @return \b UIView instance from XIB file with same name as instance class on which it has been called or \c 'nil' if 
 there is no such XIB file.
 */
+ (id)viewFromNib;

+ (UIViewAnimationOptions)animationCurveFromKeyboardAnimationCurve:(UIViewAnimationCurve)keyboardAnimationCurve;


#pragma mark - Instance methods

/**
 Perform required actions to show this interface in specified view.
 
 @param view
 \b UIView instance which will be used to display this view.
 
 @param options
 Is a bitmask of PNViewAnimationOptions type fields which specify how exactly view should be shown.
 
 @param shouldAnimate
 Whether view should appear with animation or not.
 */
- (void)showWithOptions:(PNViewAnimationOptions)options animated:(BOOL)shouldAnimate;

/**
 Hide view with specified animation options.
 
 @param options
 Is a bitmask of PNViewAnimationOptions type fields which specify how exactly view shold be hidden.
 
 @param shouldAnimate
 Whether view should appear with animation or not.
 */
- (void)dismissWithOptions:(PNViewAnimationOptions)options animated:(BOOL)shouldAnimate;

/**
 Allow to calculate target view location inside specified view (this location will be used as final view location at the
 end of animation).
 
 @param view
 \b UIView for which final location should be calculated.
 
 @return \b CGRect with information about final view location inside specified view.
 */
- (CGRect)finalViewLocation;

#pragma mark -


@end
