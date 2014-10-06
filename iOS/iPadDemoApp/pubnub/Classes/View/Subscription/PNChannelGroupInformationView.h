//
//  PNChannelGroupInformationView.h
//  pubnub
//
//  Created by Sergey Mamontov on 10/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"
#import "PNChannelInformationDelegate.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface implementation

@interface PNChannelGroupInformationView : PNInputFormView


#pragma mark - Properties

/**
 Stores reference on delegate which will accept all events from channel information view.
 */
@property (nonatomic, pn_desired_weak) id<PNChannelInformationDelegate> delegate;

/**
 Stores whether view should allow some data editing or not.
 */
@property (nonatomic, assign, getter = shouldAllowEditing) BOOL allowEditing;

@end
