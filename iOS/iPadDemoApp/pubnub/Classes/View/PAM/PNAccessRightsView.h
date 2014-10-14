//
//  PNAccessRightsView.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/6/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"


#pragma mark Public interface declaration

@interface PNAccessRightsView : PNInputFormView


#pragma mark - Class methods

/**
 Retrieve reference on initialized view which will be suitable for access rights change for provided target.
 
 @param information
 Stores reference on instance which represent access rights target and mode.
 */
+ (instancetype)viewFromNibForAccessRightsInformation:(PNAccessRightsInformation *)information;

/**
 Retrieve reference on initialized view which is suitable application access rights audition.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForApplicationAudit;

/**
 Retrieve reference on initialized view which is suitable application access rights change.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForApplicationGrant;

/**
 Retrieve reference on initialized view which is suitable application access rights revoke.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForApplicationRevoke;

/**
 Retrieve reference on initialized view which is suitable channel access rights audition.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForChannelAudit;

/**
 Retrieve reference on initialized view which is suitable channel access rights change.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForChannelGrant;

/**
 Retrieve reference on initialized view which is suitable channel access rights revoke.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForChannelRevoke;

/**
 Retrieve reference on initialized view which is suitable channel group / namespace access rights audition.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForChannelGroupAudit;

/**
 Retrieve reference on initialized view which is suitable channel group / namespace access rights change.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForChannelGroupGrant;

/**
 Retrieve reference on initialized view which is suitable channel group / namespace access rights revoke.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForChannelGroupRevoke;

/**
 Retrieve reference on initialized view which is suitable user access rights audition.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForUserAuditOnChannel;

/**
 Retrieve reference on initialized view which is suitable user access rights change.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForUserGrantOnChannel;

/**
 Retrieve reference on initialized view which is suitable user access rights revoke.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForUserRevokeOnChannel;

/**
 Retrieve reference on initialized view which is suitable user access rights audition.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForUserAuditOnChannelGroup;

/**
 Retrieve reference on initialized view which is suitable user access rights change.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForUserGrantOnChannelGroup;

/**
 Retrieve reference on initialized view which is suitable user access rights revoke.
 
 @return Configured and ready to use view.
 */
+ (instancetype)viewFromNibForUserRevokeOnChannelGroup;

#pragma mark -


@end
