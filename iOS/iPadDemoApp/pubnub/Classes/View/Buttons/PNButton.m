//
//  PNButton.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNButton.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+PNLocalization.h"


#pragma mark Private interface declaration

@interface PNButton ()


#pragma mark - Instance methods

/**
 Update main button parameters.
 */
- (void)update;

- (void)makeHighlighted;


#pragma mark -


@end


#pragma mark Public interface implementation

@implementation PNButton


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the superclass
    [super awakeFromNib];
    
    [self update];
}

- (id)initWithFrame:(CGRect)frame {
    
    // Check whether initialization has been successful or not
    if ((self = [super initWithFrame:frame])) {
        
        [self update];
    }
    
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    if (newSuperview) {
        
        [self update];
    }
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    
    [super setTitle:[title localized] forState:state];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    // Forward method call to the superclass
    [super setHighlighted:highlighted];
    
    self.backgroundColor = highlighted ? self.highlightedBackgroundColor : self.mainBackgroundColor;
    self.titleLabel.backgroundColor = self.backgroundColor;
}

- (void)setEnabled:(BOOL)enabled {
    
    self.userInteractionEnabled = enabled;
    self.alpha = (enabled ? 1.0f : 0.5f);
}

- (void)update {
    
    self.mainTitleColor = self.mainTitleColor ? self.mainTitleColor : [UIColor whiteColor];
    self.highlightedTitleColor = self.highlightedTitleColor ? self.highlightedTitleColor : self.mainTitleColor;
    
    self.layer.cornerRadius = [self.cornerRadius floatValue];
    self.backgroundColor = self.mainBackgroundColor;
    self.titleLabel.backgroundColor = self.backgroundColor;
    [self setTitleColor:self.mainTitleColor forState:UIControlStateNormal];
    [self setTitleColor:self.highlightedTitleColor forState:UIControlStateHighlighted];
    [self setNeedsDisplay];
}

- (void)highlight {
    
    [self performSelector:@selector(makeHighlighted) withObject:nil afterDelay:0.0f];
}

- (void)makeHighlighted {
    
    self.highlighted = YES;
}

#pragma mark -


@end
