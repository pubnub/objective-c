#import "PNStreamAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Stream audit API call builder.
 @discussion Protocol describe interface which provide access to stream audition endpoints.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNStreamAuditAPICallBuilder : PNStreamAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify channel \c group for audition.
 @discussion On block call return block which consume (\b required) name of channel \c group for which list of
             registered channels should be received.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamAuditAPICallBuilder *(^channelGroup)(NSString *channelGroup);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b required) channels audition process completion block
             which pass two arguments: \c result - in case of successful request processing \c data field will
             contain results of channel groups channels audition operation; \c status - in case if error 
             occurred during request processing.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNGroupChannelsAuditCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
