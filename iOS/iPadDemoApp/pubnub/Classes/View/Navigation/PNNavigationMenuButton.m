//
//  PNNavigationMenuButton.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/25/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNNavigationMenuButton.h"
#import "PNDemoAppStructures.h"


#pragma mark Static

static CGFloat const kPNSubmenuButtonTitleVerticalMargin = 16.0f;


#pragma mark - Private interface declaration

@interface PNNavigationMenuButton ()


#pragma mark - Properties

/**
 Stores reference on JSON string which describes sub-menu structure.
 */
@property (nonatomic, strong) NSString *itemsStructure;



#pragma mark - Instance methods

/**
 Perform all required preparations to so button will be ready to work.
 */
- (void)prepare;

#pragma mark - Handler methods

- (void)handleButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNNavigationMenuButton


#pragma mark - Class methods

+ (PNNavigationMenuButton *)buttonWithSubmenuStructure:(NSDictionary *)structure parent:(PNNavigationMenuButton *)parentItem {
    
    PNNavigationMenuButton *button = [self buttonWithType:UIButtonTypeCustom];
    
    UIFont *buttonTitleFont = [self subMenuEntryFont];
    NSString *title = [[structure valueForKey:PNNavigationTreeStructureKeys.buttonTitle] uppercaseString];
    button.titleLabel.font = buttonTitleFont;
    
    if (parentItem) {
        
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, kPNSubmenuButtonTitleVerticalMargin, 0, 0);
    }
    [button setTitle:title forState:UIControlStateNormal];
    if (parentItem) {
        
        button.mainBackgroundColor = parentItem.mainBackgroundColor;
        button.highlightedBackgroundColor = parentItem.highlightedBackgroundColor;
        button.mainTitleColor = parentItem.mainTitleColor;
        button.highlightedTitleColor = parentItem.highlightedTitleColor;
        
    }
    if ([structure valueForKey:PNNavigationTreeStructureKeys.subItems]) {
        
        button.structure = [structure valueForKey:PNNavigationTreeStructureKeys.subItems];
    }
    else {
        
        button.structure = structure;
    }
    button.parent = parentItem;
    
    
    return button;
}

+ (UIFont *)subMenuEntryFont {
    
    return [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
}


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    [self prepare];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        
        [self prepare];
    }
}

- (void)prepare {
    
    if ([[self actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] == 0) {
        
        [self addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(self.itemsStructure) {
        
        self.structure = [NSJSONSerialization JSONObjectWithData:[self.itemsStructure dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments error:NULL];
    }
}

#pragma mark - Handler methods

- (void)handleButtonTap:(id)sender {
    
    [self.delegate userDidTapOnButton:self];
}

#pragma mark -


@end
