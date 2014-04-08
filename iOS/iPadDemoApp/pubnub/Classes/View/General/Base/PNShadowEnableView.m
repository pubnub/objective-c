//
//  PNShadowEnableView.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#import "PNShadowEnableView.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark Private interface

@interface PNShadowEnableView ()


#pragma mark - Properties

@property (nonatomic, strong) UIColor *fillColor;


#pragma mark - Instance methods

/**
 Initialize and set all required information which is required by view.
 */
- (void)prepare;

/**
 Basing on provided corner radius information will be constructed bezier path which will enclose view's content.
 */
- (UIBezierPath *)viewBorderPath;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNShadowEnableView


#pragma mark - Instance methods

- (void)awakeFromNib {

    // Forward to the super class to complete initializations
    [super awakeFromNib];
    
    [self prepare];
    [self updateShadow];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        
        [self prepare];
        [self updateShadow];
    }
}

- (void)prepare {
    
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = self.shadowOffest;
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f].CGColor;
    self.layer.shadowRadius = (self.shadowSize ? [self.shadowSize floatValue] : 5.0f);
    
    if (!self.fillColor) {
        
        self.fillColor = self.backgroundColor;
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)updateShadow {
    
    self.layer.shadowPath = [self viewBorderPath].CGPath;
}

- (UIBezierPath *)viewBorderPath {
    
    UIBezierPath *path = nil;
    if (self.topCornerRadius || self.bottomCornerRadius) {
        
        UIRectCorner corners = (UIRectCornerTopLeft | UIRectCornerTopRight);
        CGSize radii = (CGSize){.width = [self.topCornerRadius floatValue], .height = [self.topCornerRadius floatValue]};
        if (self.bottomCornerRadius) {
            
            corners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
            radii = (CGSize){.width = [self.bottomCornerRadius floatValue], .height = [self.bottomCornerRadius floatValue]};
        }
        path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:radii];
    }
    else  {
        
        path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self.cornerRadius floatValue]];
    }
    
    
    return path;
}

- (void)drawRect:(CGRect)rect {
    
    // Forward method call to the super class
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.fillColor setFill];
    [self.borderColor setStroke];
    
    if (self.borderColor) {
        
        CGContextSetLineWidth(context, 1.0f);
    }
    CGContextAddPath(context, [self viewBorderPath].CGPath);
    CGContextFillPath(context);
    CGContextStrokePath(context);
}

#pragma mark -


@end
