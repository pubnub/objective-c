#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      History / storage API call builder.
 @discussion Class describe interface which provide access to history / storage API.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNHistoryAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify target channel name.
 @discussion On block call return block which consume (\b required) name of \c channel for which access to 
             history / storage should be done.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder *(^channel)(NSString *channel);

/**
 @brief      Specify start of interval from \c channel history from which events should be returned.
 @discussion On block call return block which consume time token for oldest event starting from which next 
             should be returned events.
 @note       Value will be converted to required precision internally.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder *(^start)(NSNumber *start);

/**
 @brief      Specify \c end of interval from \c channel history from which events should be returned.
 @discussion On block call return block which consume time token for latest event till which events should be 
             pulled out.
 @note       Value will be converted to required precision internally.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder *(^end)(NSNumber *end);

/**
 @brief      Specify how many events should be returned at once.
 @discussion On block call return block which consume maximum number of events which should be returned in
             response (not more then \b 100).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder *(^limit)(NSUInteger limit);

/**
 @brief      Specify whether events' time tokens should be retrieved or not.
 @discussion On block call return block which consume \a BOOL and specify wheter events' time tokens should be
             retrieved as well or not.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder *(^includeTimeToken)(BOOL includeTimeToken); 

/**
 @brief      Specify whether events order in response should be reversed or not.
 @discussion On block call return block which consume \a BOOL and specify whether events order in response 
             should be reversed or not.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder *(^reverse)(BOOL reverse);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Method will execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b required) history pull processing completion block 
             which pass two arguments: \c result - in case of successful request processing \c data field will
             contain results of history request operation; \c status - in case if error occurred during 
             request processing.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNHistoryCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
