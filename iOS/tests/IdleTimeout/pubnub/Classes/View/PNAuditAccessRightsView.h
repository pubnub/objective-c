//
//  PNAuditAccessRightsView.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/27/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNAccessRightsAuditionDelegate.h"
#import "PNShadowEnableView.h"


#pragma mark Public interface declaration

@interface PNAuditAccessRightsView : PNShadowEnableView


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) id<PNAccessRightsAuditionDelegate> delegate;


#pragma mark - Class methods

/**
 Allow to load instance from NIB file
 */
+ (id)viewFromNib;

#pragma mark -

@end
