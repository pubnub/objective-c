#import "PNPresenceHereNowAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      \b Channel 'here now' API call builder.
 @discussion Class describe interface which provide access to \b channel 'here now' API.
 
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNPresenceChannelHereNowAPICallBuilder : PNPresenceHereNowAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify exact type of data which should be received.
 @discussion Returned block consume one of \b PNHereNowVerbosityLevel fields to instruct what exactly data it 
             expected in response.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNPresenceChannelHereNowAPICallBuilder *(^verbosity)(PNHereNowVerbosityLevel verbosity);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b required) here now processing completion block which
             pass two arguments: \c result - in case of successful request processing \c data field will 
             contain results of here now operation; \c status - in case if error occurred during request 
             processing.
 
 @since <#version#>
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNHereNowCompletionBlock block);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
