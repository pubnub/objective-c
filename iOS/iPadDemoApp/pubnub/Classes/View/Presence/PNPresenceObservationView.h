//
//  PNPresenceObservationView.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/31/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"


#pragma mark Public interface declaration

@interface PNPresenceObservationView : PNInputFormView


#pragma mark - Class methods

/**
 Retrieve reference on initialized view which is suitable for channel presence observation enabling.
 */
+ (instancetype)viewFromNibForEnabling;

/**
 Retrieve reference on initialized view which is suitable for channel presence observation disabling.
 */
+ (instancetype)viewFromNibForDisabling;

#pragma mark -


@end
