//
//  PNTextBadgeView.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/26/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNTextBadgeView.h"


#pragma mark Static

/**
 At badge initialization badge will has sides length eaqual to this value till new badge value will be assigned.
 */
static CGFloat const kPNBadgeMinimumSizeLength = 20.0f;

static CGFloat const kPNBadgeValueSideMargin = 8.0f;


#pragma mark - Private interface declaration

@interface PNTextBadgeView ()


#pragma mark - Properties

@property (nonatomic, strong) UILabel *badgeValueLabel;

@property (nonatomic, assign) NSString *currentBadgeValue;


#pragma mark - Instance methods

- (void)prepareBadgeLayout;


#pragma mark - Misc methods

/**
 Allow to calculate resulting badge size taking into account value and font which will be used for badge layout.
 
 @return Calculated badge size (it will be used to update position as well).
 */
- (CGSize)sizeForCurrentValue;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNTextBadgeView


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        self.cornerRadius = @(kPNBadgeMinimumSizeLength * 0.5f);
        self.fillColor = [UIColor colorWithWhite:0.35f alpha:0.65f];
        [self prepareBadgeLayout];
    }
    
    
    return self;
}

- (void)setHideWithEmptyOrZeroValue:(BOOL)hideWithEmptyOrZeroValue {
    
    BOOL isVisibilityChanged = _hideWithEmptyOrZeroValue != hideWithEmptyOrZeroValue;
    _hideWithEmptyOrZeroValue = hideWithEmptyOrZeroValue;
    
    if (isVisibilityChanged) {
        
        [self updateBadgeValueTo:self.currentBadgeValue];
    }
}

- (void)updateBadgeValueTo:(NSString *)badgeValue {
    
    if ((!badgeValue || [badgeValue isEqualToString:@"0"]) && self.shouldHideWithEmptyOrZeroValue && !self.isHidden) {
        
        self.hidden = YES;
    }
    
    self.badgeValueLabel.text = badgeValue;
    
    CGSize badgeValueLabelSize = [self sizeForCurrentValue];
    CGRect badgeFrame = self.frame;
    CGFloat targetBadgeWidth = badgeValueLabelSize.width + kPNBadgeValueSideMargin * 2.0f;
    CGFloat targetBadgeOffset = ceilf((targetBadgeWidth - badgeFrame.size.width) * 0.5f);
    badgeFrame.origin.x = badgeFrame.origin.x - targetBadgeOffset;
    badgeFrame.size.width = targetBadgeWidth;
    self.frame = badgeFrame;
    
    CGRect badgeValueFrame = (CGRect){.origin = (CGPoint){.x = ceilf((targetBadgeWidth - badgeValueLabelSize.width) * 0.5f),
        .y = ceilf((badgeFrame.size.height - badgeValueLabelSize.height) * 0.5f)},
        .size = badgeValueLabelSize};
    self.badgeValueLabel.frame = badgeValueFrame;
    
    if (badgeValue && ![badgeValue isEqualToString:@"0"] && self.isHidden) {
        
        self.hidden = NO;
    }
    
    self.currentBadgeValue = badgeValue;
}

- (void)prepareBadgeLayout {
    
    self.frame = (CGRect){.size = (CGSize){.width = kPNBadgeMinimumSizeLength, .height = kPNBadgeMinimumSizeLength}};
    self.badgeValueLabel = [UILabel new];
    self.badgeValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    self.badgeValueLabel.textColor = [UIColor whiteColor];
    self.badgeValueLabel.backgroundColor = self.backgroundColor;
    [self addSubview:self.badgeValueLabel];
    [self updateBadgeValueTo:@"0"];
}

- (CGSize)sizeForCurrentValue {
    
    CGSize calculatedSize = [self.badgeValueLabel.text sizeWithFont:self.badgeValueLabel.font];
    
    
    return (CGSize){.width = ceilf(calculatedSize.width), .height = ceilf(calculatedSize.height)};
}

#pragma mark -


@end
