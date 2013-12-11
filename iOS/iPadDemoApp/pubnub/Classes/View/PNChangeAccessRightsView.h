//
//  PNChangeAccessRightsView.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/27/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNAccessRightsChangeDelegate.h"
#import "PNShadowEnableView.h"


#pragma mark Structure

typedef enum _PNAccessRightsChangeMode {
    
    PNAccessRightsGrantMode,
    PNAccessRightsRevokeMode
} PNAccessRightsChangeMode;


#pragma mark - Public interface declaration

@interface PNChangeAccessRightsView : PNShadowEnableView


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) id<PNAccessRightsChangeDelegate> delegate;


#pragma mark - Class methods

/**
 Allow to load instance from NIB file
 */
+ (id)viewFromNib;


#pragma mark - Instance methods

/**
 Allow to modify view to work for corresponding access rights change mode.
 
 @param mode
 \b PNAccessRightsChangeMode enum field which specify for what kind of access rights modification view should operate.
 */
- (void)setAccessRightsChangeMode:(PNAccessRightsChangeMode)mode;

#pragma mark -

@end
