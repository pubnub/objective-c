#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which allow to get access to channel history processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNHistoryData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Channel history messages.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSArray *messages;

/**
 @brief  History time frame start time.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *start;

/**
 @brief   History time frame end time.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *end;

#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNHistoryResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on channel history request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNHistoryData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
