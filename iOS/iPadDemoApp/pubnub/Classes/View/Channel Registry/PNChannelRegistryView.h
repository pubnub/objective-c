//
//  PNChannelRegistryView.h
//  pubnub
//
//  Created by Sergey Mamontov on 10/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"


#pragma mark Public interface declaration

@interface PNChannelRegistryView : PNInputFormView


#pragma mark - Class methods

/**
 @brief Retrieve reference on fully configured channel registry view which is ready for use with namespace audition
 requests.
 
 @return Configured and ready to use \b PNChannelRegistryView instance.
 */
+ (instancetype)viewFromNibForNamespaceAudit;

/**
 @brief Retrieve reference on fully configured channel registry view which is ready for use with namespace remove
 requests.
 
 @return Configured and ready to use \b PNChannelRegistryView instance.
 */
+ (instancetype)viewFromNibForNamespaceRemove;

/**
 @brief Retrieve reference on fully configured channel registry view which is ready for use with channel group audition
 requests.
 
 @return Configured and ready to use \b PNChannelRegistryView instance.
 */
+ (instancetype)viewFromNibForChannelGroupAudit;

/**
 @brief Retrieve reference on fully configured channel registry view which is ready for use with channel group remove
 requests.
 
 @return Configured and ready to use \b PNChannelRegistryView instance.
 */
+ (instancetype)viewFromNibForChannelGroupRemove;


/**
 @brief Retrieve reference on fully configured channel registry view which is ready for use with channel group channels
 remove requests.
 
 @return Configured and ready to use \b PNChannelRegistryView instance.
 */
+ (instancetype)viewFromNibForChannelGroupChannelsAdd;


/**
 @brief Retrieve reference on fully configured channel registry view which is ready for use with channel group channels
 add requests.
 
 @return Configured and ready to use \b PNChannelRegistryView instance.
 */
+ (instancetype)viewFromNibForChannelGroupChannelsRemove;


/**
 @brief Retrieve reference on fully configured channel registry view which is ready for use with channel group channels
 audit requests.
 
 @return Configured and ready to use \b PNChannelRegistryView instance.
 */
+ (instancetype)viewFromNibForChannelGroupChannelsAudit;

#pragma mark -


@end
