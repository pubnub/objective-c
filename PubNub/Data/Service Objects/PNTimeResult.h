#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which allow to get access to time API processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNTimeData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Current time on \b PubNub network servers.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *timetoken;

#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNTimeResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on time request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNTimeData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
