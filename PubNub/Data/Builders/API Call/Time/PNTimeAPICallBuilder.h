#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Time API call builder.
 @discussion Class describe interface which allow to use time API endpoint.
 
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNTimeAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b required) time request process results handling 
             block which pass two arguments: \c result - in case of successful request processing \c data 
             field will contain server-provided time token; \c status - in case if error occurred during 
             request processing.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNTimeCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
