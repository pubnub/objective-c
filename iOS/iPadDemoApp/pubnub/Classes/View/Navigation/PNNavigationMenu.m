//
//  PNNavigationMenu.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/26/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNNavigationMenu.h"
#import "PNNavigationMenuDelegate.h"
#import "PNNavigationMenuButton.h"
#import "PNDemoAppStructures.h"
#import "UIScreen+PNAddition.h"


#pragma mark Structures

struct PNNavigationTreeStructureKeysStruct PNNavigationTreeStructureKeys = {
    
    .buttonTitle = @"title",
    .subItems = @"items",
    .buttonAction = @"action"
};

struct PNNavigationSubMenEntryDataStruct {
    
    /**
     Key is used to store option button for which submenu is built.
     */
    __unsafe_unretained NSString *item;
    
    /**
     Key is used to store sub-menu view.
     */
    __unsafe_unretained NSString *subMenu;
};

struct PNNavigationSubMenEntryDataStruct PNNavigationSubMenEntryData = {
    
    .item = @"item",
    .subMenu = @"menu"
};


#pragma mark - Static

static CGFloat const kPNNavigationSubMenuAppearDuration = 0.4f;
static CGFloat const kPNNavigationSubMenuDisappearDuration = 0.2f;
static CGFloat const kPNNavigationSubMenuEntryHeight = 31.0f;
static CGFloat const kPNNavigationSubMenuVerticalOffset = 10.0f;
static CGFloat const kPNNavigationSubMenuEntryHorizontalMargin = 16.0f;


#pragma mark - Private interface declaration

@interface PNNavigationMenu () <PNNavigationMenuDelegate>


#pragma mark - Properties

@property (nonatomic, strong) IBOutletCollection(PNNavigationMenuButton) NSArray *buttons;

/**
 Navigation menu will run all actions on specified target.
 */
@property (nonatomic, pn_desired_weak) IBOutlet id target;

/**
 Stores current sub-menu level which is opened to the user.
 */
@property (nonatomic, assign) NSUInteger currentLevel;

/**
 Stores array of sub-menu entries basing on their level. Each index in array represent level for which menu has been
 opened.
 */
@property (nonatomic, strong) NSMutableArray *subMenuList;

/**
 Stores reference on button which will be placed on lower layer of navigation menu when popup menu is shown.
 This button will allow to handle tap ouside of navigation menu.
 */
@property (nonatomic, strong) UIButton *backgroundButton;


#pragma mark - Instance methods

- (void)prepareNavigationMenu;

/**
 Manipulate background button appearance.
 */
- (void)placeBackgroundButtonIfRequired;
- (void)removeBackgroundButtonIfRequired;

/**
 Allow to build sub-menu for selected option.
 
 @param button
 Reference on button from navigation menu.
 */
- (void)buildSubMenuForMenuOption:(PNNavigationMenuButton *)button;

/**
 Close sub-menu tree for provided option.
 
 @param button
 Reference on button from navigation menu.
 */
- (void)closeSubMenuForMenuOption:(PNNavigationMenuButton *)button;

/**
 Close whole sub-menu tree.
 */
- (void)closeSubMenu;

- (void)unhighlightButtonsExcept:(PNNavigationMenuButton *)selectedButton;


#pragma mark - Handler methods

- (void)handleBackgroundButtonTap:(id)sender;


#pragma mark - Misc methods

/**
 Allow to calculate final option submenu width basing on provided option structure.
 
 @param optionButton
 Reference on parent menu option button.
 
 @return target submenu width which can be used to build menu.
 */
- (CGFloat)subMenuWidthForOption:(PNNavigationMenuButton *)optionButton;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNNavigationMenu


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super clas
    [super awakeFromNib];
    
    [self prepareNavigationMenu];
}

- (void)prepareNavigationMenu {
    
    self.subMenuList = [NSMutableArray array];
}

- (void)placeBackgroundButtonIfRequired {
    
    if ([self.subMenuList count] == 1) {
        
        if (!self.backgroundButton) {
            
            self.backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.backgroundButton.frame = [[UIScreen mainScreen] applicationFrameForCurrentOrientation];
            self.backgroundButton.backgroundColor = [UIColor clearColor];
            [self.backgroundButton addTarget:self action:@selector(handleBackgroundButtonTap:)
                            forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.superview insertSubview:self.backgroundButton belowSubview:self];
    }
}

- (void)removeBackgroundButtonIfRequired {
    
    if ([self.subMenuList count] == 0) {
        
        [self.backgroundButton removeFromSuperview];
    }
}

- (void)buildSubMenuForMenuOption:(PNNavigationMenuButton *)button {
    
    [button highlight];
    
    NSArray *subMenuEntries = (NSArray *)button.structure;
    
    // Calculate sub-menu position and size
    CGFloat subMenuWidth = [self subMenuWidthForOption:button];
    CGFloat menuHorizontalPosition = button.frame.origin.x;
    CGFloat menuVerticalPosition = CGRectGetHeight(button.frame);
    if (button.parent) {
        
        CGFloat parentSubMenuVerticalOffset = [button superview].frame.origin.y;
        menuHorizontalPosition = [button superview].frame.origin.x + button.frame.size.width;
        menuVerticalPosition = parentSubMenuVerticalOffset + button.frame.origin.y + kPNNavigationSubMenuVerticalOffset;
    }
    CGFloat subMenuHeight = ([subMenuEntries count] * kPNNavigationSubMenuEntryHeight) + kPNNavigationSubMenuEntryHorizontalMargin;
    CGRect holderViewFrame = (CGRect){.origin = (CGPoint){.x = menuHorizontalPosition, .y = menuVerticalPosition},
                                      .size = (CGSize){.width = subMenuWidth, .height = subMenuHeight}};
    
    // Create buttons holding view
    PNShadowEnableView *holderView = [[PNShadowEnableView alloc] initWithFrame:holderViewFrame];
    holderView.backgroundColor = [UIColor whiteColor];
    holderView.shadowSize = button.parent ? @(2) : @(1);
    holderView.shadowOffest = (CGSize){.height = (button.parent ? 0.0f : 3.0f)};
    if (button.parent) {
        
        holderView.cornerRadius = @(5);
    }
    else {
        
        holderView.bottomCornerRadius = @(5);
    }
    
    __block CGFloat verticalOffset = kPNNavigationSubMenuEntryHorizontalMargin * 0.5;
    [subMenuEntries enumerateObjectsUsingBlock:^(NSDictionary *entryData, NSUInteger entryDataIdx,
                                                 BOOL *entryDataEnumeratorStop) {
        PNNavigationMenuButton *subMenuButton = [PNNavigationMenuButton buttonWithSubmenuStructure:entryData parent:button];
        subMenuButton.delegate = self;
        subMenuButton.frame = (CGRect){.origin = (CGPoint){.x = 0.0f, .y = verticalOffset},
                                       .size = (CGSize){.width = subMenuWidth, .height = kPNNavigationSubMenuEntryHeight}};
        verticalOffset += subMenuButton.frame.size.height;
        
        // Increasing level for sub-menu if it will be opened.
        subMenuButton.level = (button.level + 1);
        
        [holderView addSubview:subMenuButton];
    }];
    
    button.expanded = YES;
    
    holderView.alpha = 0.0f;
    [self.superview insertSubview:holderView aboveSubview:(button.parent ? [button superview] : self)];
    [self.subMenuList addObject:@{PNNavigationSubMenEntryData.item:button, PNNavigationSubMenEntryData.subMenu:holderView}];
    
    [self placeBackgroundButtonIfRequired];
    
    [UIView animateWithDuration:kPNNavigationSubMenuAppearDuration delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         holderView.alpha = 1.0f;
                     } completion:NULL];
}

- (void)closeSubMenuForMenuOption:(PNNavigationMenuButton *)button {
    
    button.highlighted = NO;
    button.expanded = NO;
    
    // Because level reference on next sub-menu level, we should decrease it.
    
    if (button.level < [self.subMenuList count]) {
        
        NSRange targetSubMenuRange = NSMakeRange(button.level, ([self.subMenuList count] - button.level));
        NSArray *targetSubMenu = [self.subMenuList subarrayWithRange:targetSubMenuRange];
        [self.subMenuList removeObjectsInRange:targetSubMenuRange];
        
        [self removeBackgroundButtonIfRequired];
        
        [UIView animateWithDuration:kPNNavigationSubMenuDisappearDuration delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             [targetSubMenu enumerateObjectsUsingBlock:^(NSDictionary *subMenuData, NSUInteger subMenuDataIdx,
                                                                         BOOL *subMenuDataEnumeratorStop) {
                                 
                                 PNNavigationMenuButton *item = [subMenuData valueForKey:PNNavigationSubMenEntryData.item];
                                 item.highlighted = NO;
                                 item.expanded = NO;
                                 
                                 UIView *subMenuView = [subMenuData valueForKey:PNNavigationSubMenEntryData.subMenu];
                                 subMenuView.alpha = 0.0f;
                             }];
                         } completion:^(BOOL finished) {
                             
                             [[targetSubMenu valueForKey:PNNavigationSubMenEntryData.subMenu] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                         }];
    }
}

- (void)closeSubMenu {
    
    NSArray *targetSubMenu = [NSArray arrayWithArray:self.subMenuList];
    [self.subMenuList removeAllObjects];
    
    [self removeBackgroundButtonIfRequired];
    
    [UIView animateWithDuration:kPNNavigationSubMenuDisappearDuration delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         [targetSubMenu enumerateObjectsUsingBlock:^(NSDictionary *subMenuData, NSUInteger subMenuDataIdx,
                                                                     BOOL *subMenuDataEnumeratorStop) {
                             
                             PNNavigationMenuButton *item = [subMenuData valueForKey:PNNavigationSubMenEntryData.item];
                             item.highlighted = NO;
                             item.expanded = NO;
                             
                             UIView *subMenuView = [subMenuData valueForKey:PNNavigationSubMenEntryData.subMenu];
                             subMenuView.alpha = 0.0f;
                         }];
                     } completion:^(BOOL finished) {
                         
                         [[targetSubMenu valueForKey:PNNavigationSubMenEntryData.subMenu] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                     }];
}

- (void)unhighlightButtonsExcept:(PNNavigationMenuButton *)selectedButton {
    
    // Enumerate over the list of buttons on same level and deselect them (if selected).
    [[selectedButton.superview subviews] enumerateObjectsUsingBlock:^(id object, NSUInteger objectIdx,
                                                                      BOOL *objectEnumeratorStop) {
        
        if ([object respondsToSelector:@selector(highlight)]) {
            
            ((UIButton *)object).highlighted = [object isEqual:selectedButton];
        }
    }];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self closeSubMenu];
}


#pragma mark - Handler methods

- (void)handleBackgroundButtonTap:(id)sender {
    
    [self closeSubMenu];
}


#pragma mark - Misc methods

- (CGFloat)subMenuWidthForOption:(PNNavigationMenuButton *)optionButton {
    
    UIFont *buttonTitleFont = [PNNavigationMenuButton subMenuEntryFont];
    __block CGFloat maximumTitleWidth = 0.0f;
    
    [(NSArray *)optionButton.structure enumerateObjectsUsingBlock:^(NSDictionary *entryData, NSUInteger entryDataIdx,
                                                                    BOOL *entryDataEnumeratorStop) {
        
        NSString *title = [[entryData valueForKey:PNNavigationTreeStructureKeys.buttonTitle] uppercaseString];
        CGSize titleSize = [title sizeWithFont:buttonTitleFont];
        
        maximumTitleWidth = MAX(maximumTitleWidth, titleSize.width);
    }];
    
    // Calculate final button width
    maximumTitleWidth += kPNNavigationSubMenuEntryHorizontalMargin * 2.0f;
    
    
    return maximumTitleWidth;
}


#pragma mark - Navigation button delegate

- (void)userDidTapOnButton:(PNNavigationMenuButton *)button {
    
    [self unhighlightButtonsExcept:button];
    
    
    // Checking whether single item data has been provided or not
    if ([button.structure isKindOfClass:[NSDictionary class]]) {
        
        if ([button.structure valueForKey:PNNavigationTreeStructureKeys.buttonAction]) {
            
            SEL selector = NSSelectorFromString([button.structure valueForKey:PNNavigationTreeStructureKeys.buttonAction]);
            if ([self.target respondsToSelector:selector]) {
                
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.target performSelector:selector withObject:button];
                #pragma clang diagnostic pop
            }
            [self closeSubMenu];
        }
    }
    else {
        
        PNNavigationMenuButton *currentItem = nil;
        if ([self.subMenuList count]) {
            
            NSDictionary *itemHolder = [self.subMenuList lastObject];
            currentItem = [itemHolder valueForKey:PNNavigationSubMenEntryData.item];
            if (currentItem && currentItem.isExpanded && [self.subMenuList indexOfObject:itemHolder] != 0 &&
                button.level != currentItem.level) {
                
                NSInteger targetIndex = [self.subMenuList indexOfObject:itemHolder] - 1;
                currentItem = [[self.subMenuList objectAtIndex:targetIndex] valueForKey:PNNavigationSubMenEntryData.item];
            }
        }
        
        // Check whether menu already opened or not
        if (!button.isExpanded) {
            
            // In case if another top level menu tapped, we should completely close menu which has been previously opened
            // by user.
            if (button.level == 0 && [self.subMenuList count]) {
                
                [self closeSubMenu];
            }
            
            if (currentItem && button.level <= currentItem.level) {
                
                [self closeSubMenuForMenuOption:currentItem];
            }
            
            [self buildSubMenuForMenuOption:button];
        }
        else {
            
            [self closeSubMenuForMenuOption:button];
        }
    }
}

@end
