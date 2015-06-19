#import "PNErrorStatus.h"
#import "PNChannelClientStateResult.h"


/**
 @brief  Class which allow to get access to used client state during state update process.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNClientStateUpdateData : PNChannelClientStateData


#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNClientStateUpdateStatus : PNErrorStatus


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on client state for channel request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNClientStateUpdateData *data;

#pragma mark -


@end
