//
//  PNInputFormView.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"
#import "UIScreen+PNAddition.h"
#import "UIView+PNAddition.h"


#pragma mark Private interface declaration

@interface PNInputFormView ()


#pragma mark - Properties

/**
 Stores minium Y value which can be appliied to the view when animated on keyboard appear.
 */
@property (nonatomic, strong) NSNumber *minimumVerticalPosition;


#pragma mark - Instance methods

#pragma mark - Handler methods

- (void)handleKeyboardFrameChange:(NSNotification *)notification;
- (void)handleKeyboardWillHide:(NSNotification *)notification;

/**
 @brief Template methods.
 */
- (void)handleUserInputCompleted;


#pragma mark - Misc methods

- (void)subscribeOnKeyboardEvents;
- (void)unsubscribeFromKeyboardEvents;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNInputFormView


#pragma mark - Instnce methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    if (!self.minimumVerticalPosition) {
        
        self.minimumVerticalPosition = [NSNumber numberWithFloat:[[UIScreen mainScreen] applicationFrameForCurrentOrientation].origin.y];
    }
    
    [self subscribeOnKeyboardEvents];
}

- (void)didMoveToSuperview {
    
    self.originalVerticalPosition = self.frame.origin.y;
}

- (BOOL)isUserInputActive {
    
    return self.originalVerticalPosition != self.frame.origin.y;
}

- (void)completeUserInput {
    
    [self endEditing:YES];
}

- (void)setOriginalVerticalPosition:(CGFloat)originalVerticalPosition {
    
    _originalVerticalPosition = originalVerticalPosition;
}


#pragma mark - Handler methods

- (void)handleKeyboardFrameChange:(NSNotification *)notification {
    
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect keyboardTargetRect;
    [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardTargetRect];
    keyboardTargetRect = [[UIScreen mainScreen] normalizedForCurrentOrientationFrame:keyboardTargetRect];
    
    CGRect availableFrame = [[UIScreen mainScreen] applicationFrameForCurrentOrientation];
    if ((availableFrame.size.height - keyboardTargetRect.origin.y) >= 0.0f) {
        
        availableFrame.size.height = availableFrame.size.height - keyboardTargetRect.origin.y;
    }
    
    CGRect targetFrame = self.frame;
    targetFrame.origin.y = MIN(MAX([self.minimumVerticalPosition floatValue], (availableFrame.size.height - targetFrame.size.height) * 0.5f),
                               self.originalVerticalPosition);
    
    [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationCurveFromKeyboardAnimationCurve:animationCurve]
                     animations:^{
                         
                         // Adjust view position on keyboard frane change
                         self.frame = targetFrame;
                     } completion:NULL];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
    
    [self handleUserInputCompleted];
}

- (void)handleUserInputCompleted {
    
}


#pragma mark - Misc methods

- (void)subscribeOnKeyboardEvents {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardFrameChange:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)unsubscribeFromKeyboardEvents {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc {
    
    [self unsubscribeFromKeyboardEvents];
}

#pragma mark -


@end
