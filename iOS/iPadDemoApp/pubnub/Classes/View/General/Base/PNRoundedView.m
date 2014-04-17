//
//  PNRoundedView.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/17/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNRoundedView.h"


#pragma mark - Public interface implementation

@implementation PNRoundedView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    self.fillColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame {
    
    // Check whether initialization has been successful or not
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    // Forward method call to the super class.
    [super drawRect:rect];
    
    CGFloat topLeftRadius = 0.0f;
    CGFloat topRightRadius = 0.0f;
    CGFloat bottomLeftRadius = 0.0f;
    CGFloat bottomRightRadius = 0.0f;
    if (self.cornerRadius) {
        
        topLeftRadius = topRightRadius = bottomLeftRadius = bottomRightRadius = [self.cornerRadius floatValue];
    }
    else {
        
        if (self.topLeftCornerRadius) {
            
            topLeftRadius = [self.topLeftCornerRadius floatValue];
        }
        
        if (self.topRightCornerRadius) {
            
            topRightRadius = [self.topRightCornerRadius floatValue];
        }
        
        if (self.bottomLeftCornerRadius) {
            
            bottomLeftRadius = [self.bottomLeftCornerRadius floatValue];
        }
        
        if (self.bottomRightCornerRadius) {
            
            bottomRightRadius = [self.bottomRightCornerRadius floatValue];
        }
    }
    
    // Retrieve reference on current graphic context in which we can draw.
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.fillColor setFill];
    if (self.borderColor) {
        
        [self.borderColor setStroke];
    }
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 1.0f);
	CGContextMoveToPoint(context, CGRectGetMinX(rect) + topLeftRadius - 0.5f, CGRectGetMinY(rect) + 0.5f);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect) - topRightRadius - 0.5f, CGRectGetMinY(rect) + 0.5f);
	CGContextAddArc(context, CGRectGetMaxX(rect) - topRightRadius + 0.5f, CGRectGetMinY(rect) + topRightRadius + 0.5f, topRightRadius, 3 * M_PI_2, 0, 0); // TR
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect) + 0.5f, CGRectGetMaxY(rect) - bottomRightRadius + 0.5f);
	CGContextAddArc(context, CGRectGetMaxX(rect) - bottomRightRadius + 0.5f, CGRectGetMaxY(rect) - bottomRightRadius + 0.5f, bottomRightRadius, 0, M_PI_2, 0); // BR
    CGContextAddLineToPoint(context, CGRectGetMinX(rect) + bottomLeftRadius + 0.5f, CGRectGetMaxY(rect) + 0.5f);
	CGContextAddArc(context, CGRectGetMinX(rect) + bottomLeftRadius - 0.5f, CGRectGetMaxY(rect) - bottomLeftRadius + 0.5f, bottomLeftRadius, M_PI_2, M_PI, 0); // BL
    CGContextAddLineToPoint(context, CGRectGetMinX(rect) - 0.5f, CGRectGetMinY(rect) + topRightRadius + 0.5f);
	CGContextAddArc(context, CGRectGetMinX(rect) + topRightRadius - 0.5f, CGRectGetMinY(rect) + topRightRadius + 0.5f, topRightRadius, M_PI, 3 * M_PI_2, 0); // TL
	CGContextClosePath(context);
	CGContextFillPath(context);
    CGContextStrokePath(context);
}

@end
