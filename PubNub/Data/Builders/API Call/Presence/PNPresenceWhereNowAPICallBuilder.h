#import "PNPresenceAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      \b User 'where now' API call builder.
 @discussion Class describe interface which provide access to \b user 'where now' API.
 
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNPresenceWhereNowAPICallBuilder : PNPresenceAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify unique \c user idetifier.
 @discussion On block call return block which consume unique \c user idetifier for which should be retireved 
             presence information (list of channels on which \c user subscribed).
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNPresenceWhereNowAPICallBuilder *(^uuid)(NSString *uuid);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b required) where now processing completion block 
             which pass two arguments: \c result - in case of successful request processing \c data field will
             contain results of where now operation; \c status - in case if error occurred during request 
             processing.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNWhereNowCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
