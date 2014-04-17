//
//  PNNavigationMenuButton.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/25/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNButton.h"
#import "PNNavigationMenuDelegate.h"


#pragma mark Public interface declaration

@interface PNNavigationMenuButton : PNButton


#pragma mark - Properties

/**
 Stores reference menu structure.
 */
@property (nonatomic, strong) id structure;

/**
 Allow to check whether button sub-menu opened or not.
 */
@property (nonatomic, assign, getter = isExpanded) BOOL expanded;

/**
 Stores sub-menu entry level (or depth).
 */
@property (nonatomic, assign) NSUInteger level;

/**
 Stores reference on parent menu button for which sub-menu has been built.
 */
@property (nonatomic, pn_desired_weak) PNNavigationMenuButton *parent;

/**
 Stores reference on delegate which will accept all events from userinteraction with this button.
 */
@property (nonatomic, pn_desired_weak) IBOutlet id<PNNavigationMenuDelegate> delegate;


#pragma mark - Class methods

/**
 Construct navigation item with predefined state.
 
 @param structure
 \b NSDictionary which describes button itself and possibe sub-menu items.
 
 @param parentItem
 Reference on parent item (in case if this button has been created ans sub-menu entry).
 
 @return Configured item which can be placed into navigation menu.
 */
+ (PNNavigationMenuButton *)buttonWithSubmenuStructure:(NSDictionary *)structure parent:(PNNavigationMenuButton *)parentItem;

/**
 Allow to receive font which should be used for sub-menu entries.
 */
+ (UIFont *)subMenuEntryFont;

#pragma mark -


@end
