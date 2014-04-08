//
//  PNClientStateView.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"


#pragma mark Public interface declaration

@interface PNClientStateView : PNInputFormView


#pragma mark - Class methods

/**
 Retrieve reference on initialized view which is suitable for viewing client state data.
 */
+ (instancetype)viewFromNibForViewing;

/**
 Retrieve reference on initialized view which is suitable for editing client state data.
 */
+ (instancetype)viewFromNibForEditing;


#pragma mark - Instance methods

/**
 Prepare view to layout provided data.
 
 @param channel
 \b PNChannle instance which will be used during state manipulation requests (can b e\c nil)
 
 @param clientIdentifier
 Identifier for which state manipulation should be done.
 
 @param clientState
 \b NSDictionary instance which represent client's state in specified channel.
 */
- (void)configureFor:(PNChannel *)channel clientIdentifier:(NSString *)clientIdentifier andState:(NSDictionary *)clientState;

#pragma mark -


@end
