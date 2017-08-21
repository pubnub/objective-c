#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      History / storage modification API call builder.
 @discussion Class describe interface which provide access to history / storage modification API.
 
 @author Sergey Mamontov
 @since 4.7.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNDeleteMessageAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify target channel name.
 @discussion On block call return block which consume (\b required) name of \c channel for which modifications
             in history / storage should be done.
 
 @since 4.7.0
 */
@property (nonatomic, readonly, strong) PNDeleteMessageAPICallBuilder *(^channel)(NSString *channel);

/**
 @brief      Specify start of interval from \c channel history from which events should be removed.
 @discussion On block call return block which consume time token for oldest event starting from which events
             should be removed. If no \c end value provided, will be removed all events till specified 
             \c start date (not inclusive).
 @note       Value will be converted to required precision internally.
 @note       Ignored in case if history for multiple channels should be retrieved.
 
 @since 4.7.0
 */
@property (nonatomic, readonly, strong) PNDeleteMessageAPICallBuilder *(^start)(NSNumber *start);

/**
 @brief      Specify \c end of interval from \c channel history from which events should be removed.
 @discussion On block call return block which consume time token for latest event till which events should be 
             removed. If no \c start value provided, will be removed all events starting from specified 
             \c end date (inclusive).
 @note       Value will be converted to required precision internally.
 @note       Ignored in case if history for multiple channels should be retrieved.
 
 @since 4.7.0
 */
@property (nonatomic, readonly, strong) PNDeleteMessageAPICallBuilder *(^end)(NSNumber *end);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b not required) events delete processing completion 
             block which pass only one argument - request processing status to report about how data pushing 
             was successful or not.
 
 @since 4.7.0
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNMessageDeleteCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
