//
//  PNPopoverView.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPopoverView.h"
#import "UIScreen+PNAddition.h"


#pragma mark Private interface declaration

@interface PNPopoverView ()


#pragma mark - Properties

/**
 Stores reference on view which is used to prevent user from interaction with elements which is behind this view.
 */
@property (nonatomic, strong) UIView *userInteractionLockView;


#pragma mark - Instance methods

/**
 Add view behind current form to prevent user from interaction with background elements.
 
 @param view
 \b UIView instance which will be 'locked' from user interaction.
 */
- (void)addLockViewFor:(UIView *)view;

/**
 Allow to remove interaction locking view from background of this view.
 */
- (void)removeBackgroundLockView;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNPopoverView


#pragma mark - Instance methods

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    if (self.shouldDisableBackgroundElementsOnAppear) {
    
        if (newSuperview) {
            
            [self addLockViewFor:newSuperview];
        }
        else {
            
            [self removeBackgroundLockView];
        }
    }
}

- (void)addLockViewFor:(UIView *)view {
    
    CGRect viewFrame = view.frame;
    CGRect availableFrame = [[UIScreen mainScreen] applicationFrameForCurrentOrientation];
    availableFrame.size = (CGSize){.width = (availableFrame.size.width + 40.0f), .height = (availableFrame.size.height + 40.0f)};
    availableFrame = CGRectOffset(availableFrame, -viewFrame.origin.x, -(viewFrame.origin.y + availableFrame.origin.y));
    self.userInteractionLockView = [[UIView alloc] initWithFrame:availableFrame];
    
    if (self.shouldDimmBackgroundOnAppear) {
        
        self.userInteractionLockView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.2f];
    }
    
    [view insertSubview:self.userInteractionLockView belowSubview:self];
}

- (void)removeBackgroundLockView {
    
    [self.userInteractionLockView removeFromSuperview];
}


#pragma mark -


@end
