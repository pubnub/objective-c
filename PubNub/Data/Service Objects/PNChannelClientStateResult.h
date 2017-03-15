#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which allow to get access to client state for channel processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNChannelClientStateData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  User-provided client state information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, id> *state;

#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNChannelClientStateResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on client state for channel request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNChannelClientStateData *data;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
