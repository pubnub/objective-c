#import "PNResult.h"
#import "PNServiceData.h"


/**
 @brief  Class which allow to get access to channel groups list audit processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNChannelGroupsData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Registered and active channel groups.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSArray *groups;

#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNChannelGroupsResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on channel groups list audit request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNChannelGroupsData *data;

#pragma mark -


@end
