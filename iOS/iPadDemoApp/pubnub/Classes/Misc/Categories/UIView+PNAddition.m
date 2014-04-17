//
//  UIView+PNAddition.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "UIView+PNAddition.h"
#import "UIScreen+PNAddition.h"


#pragma mark Static

static NSTimeInterval const kPNViewDefaultAppearAnimationDuration = 0.6f;
static NSTimeInterval const kPNViewDefaultDisappearAnimationDuration = 0.4f;


#pragma mark Category implementation

@implementation UIView (PNAddition)

+ (id)viewFromNib {
    
    NSArray *nibElements = [[NSBundle mainBundle] loadNibNamed:[self viewNibName] owner:nil options:nil];
    __block UIView *view = nil;
    [nibElements enumerateObjectsUsingBlock:^(id element, NSUInteger elementIds, BOOL *elementEnumeratorStop) {
        
        if ([element isKindOfClass:[self class]]) {
            
            view = element;
            *elementEnumeratorStop = YES;
            
        }
    }];
    
    
    return view;
}

+ (NSString *)viewNibName {
    
    return NSStringFromClass([self class]);
}

+ (UIViewAnimationOptions)animationCurveFromKeyboardAnimationCurve:(UIViewAnimationCurve)keyboardAnimationCurve {
    
    UIViewAnimationOptions curve = UIViewAnimationOptionCurveEaseInOut;
    
    switch (keyboardAnimationCurve) {
        case UIViewAnimationCurveEaseIn:
            
            curve = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            
            curve = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            
            curve = UIViewAnimationOptionCurveLinear;
            break;
        default:
            break;
    }
    
    
    return curve;
}


#pragma mark - Instance methods

- (void)showWithOptions:(PNViewAnimationOptions)options animated:(BOOL)shouldAnimate {
    
    CGRect targetFrame = [self finalViewLocation];
    CGRect startFrame = [self finalViewLocation];
    CGFloat startAlpha = 1.0f;
    CGFloat targetAlpha = 1.0f;
    if ((options & PNViewAnimationOptionTransitionFromTop) != 0 || (options & PNViewAnimationOptionTransitionFromBottom) != 0) {
        
        CGFloat targetOffset = (startFrame.origin.y + startFrame.size.height);
        if ((options & PNViewAnimationOptionTransitionFromTop) != 0) {
            
            targetOffset *= -1.0f;
        }
        else {
            
            targetOffset += startFrame.size.height;
        }
        
        startFrame = CGRectOffset(startFrame, 0.0f, targetOffset);
    }
    if ((options & PNViewAnimationOptionTransitionFromLeft) != 0 || (options & PNViewAnimationOptionTransitionFromRight) != 0) {
        
        CGFloat targetOffset = (startFrame.origin.x + startFrame.size.width);
        if ((options & PNViewAnimationOptionTransitionFromLeft) != 0) {
            
            targetOffset *= -1.0f;
        }
        else {
            
            targetOffset += startFrame.size.width;
        }
        
        startFrame = CGRectOffset(startFrame, targetOffset, 0.0f);
    }
    if ((options & PNViewAnimationOptionTransitionFadeIn) != 0) {
        
        startAlpha = 0.0f;
    }
    self.frame = startFrame;
    self.alpha = startAlpha;
    
    UIView *targetView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController) {
        
        targetView = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController.view;
    }
    [targetView addSubview:self];
    [UIView animateWithDuration:(shouldAnimate ? [self appearAnimationDuration] : 0.0f) delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            
                            self.alpha = targetAlpha;
                            self.frame = targetFrame;
                        } completion:NULL];
}

- (void)dismissWithOptions:(PNViewAnimationOptions)options animated:(BOOL)shouldAnimate {
    
    CGRect targetFrame = self.frame;
    CGFloat targetAlpha = 1.0f;
    
    if ((options & PNViewAnimationOptionTransitionToTop) != 0 || (options & PNViewAnimationOptionTransitionToBottom) != 0) {
        
        CGFloat targetOffset = (targetFrame.origin.y + targetFrame.size.height);
        if ((options & PNViewAnimationOptionTransitionFromTop) != 0) {
            
            targetOffset *= -1.0f;
        }
        else {
            
            targetOffset += targetFrame.size.height;
        }
        
        targetFrame = CGRectOffset(targetFrame, 0.0f, targetOffset);
    }
    if ((options & PNViewAnimationOptionTransitionToLeft) != 0 || (options & PNViewAnimationOptionTransitionToRight) != 0) {
        
        CGFloat targetOffset = (targetFrame.origin.x + targetFrame.size.width);
        if ((options & PNViewAnimationOptionTransitionFromLeft) != 0) {
            
            targetOffset *= -1.0f;
        }
        else {
            
            targetOffset += targetFrame.size.width;
        }
        
        targetFrame = CGRectOffset(targetFrame, targetOffset, 0.0f);
    }
    if ((options & PNViewAnimationOptionTransitionFadeOut) != 0) {
        
        targetAlpha = 0.0f;
    }
    
    
    [UIView animateWithDuration:(shouldAnimate ? [self disappearAnimationDuration] : 0.0f) delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.alpha = targetAlpha;
                         self.frame = targetFrame;
                     } completion:^(BOOL completed){
                         
                         [self removeFromSuperview];
                     }];
}

- (CGRect)finalViewLocation {
    
    CGRect targetFrame = self.frame;
    CGRect availableFrame = [[UIScreen mainScreen] applicationFrameForCurrentOrientation];
    targetFrame.origin = (CGPoint){.x = ceilf((availableFrame.size.width - targetFrame.size.width) * 0.5f),
                                   .y = ceilf((availableFrame.size.height - targetFrame.size.height) * 0.5f)};
    
    
    return targetFrame;
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewDefaultAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDefaultDisappearAnimationDuration;
}

@end
