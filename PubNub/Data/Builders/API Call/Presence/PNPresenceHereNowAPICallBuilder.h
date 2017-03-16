#import "PNPresenceAPICallBuilder.h"


#pragma mark Class forward

@class PNPresenceChannelGroupHereNowAPICallBuilder, PNPresenceChannelHereNowAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Presence 'here now' API call builder.
 @discussion Class describe interface which provide access to various 'here now' presence endpoints.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNPresenceHereNowAPICallBuilder : PNPresenceAPICallBuilder


///------------------------------------------------
/// @name Channel
///------------------------------------------------

/**
 @brief      Stores reference on builder which is responsible for access to \c channel 'here now' API.
 @discussion Returned block consume name of \c channel for which 'here now' presence information should be 
             requested.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceChannelHereNowAPICallBuilder *(^channel)(NSString *channel);


///------------------------------------------------
/// @name Channel Group
///------------------------------------------------

/**
 @brief      Stores reference on builder which is responsible for access to channel \c group 'here now' API.
 @discussion On block call return block which consume name of channel \c group for which 'here now' presence 
             information should be requested.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceChannelGroupHereNowAPICallBuilder *(^channelGroup)(NSString *channelGroup);


///------------------------------------------------
/// @name Global
///------------------------------------------------

/**
 @brief      Specify exact type of data which should be received.
 @discussion On block call return block which consume one of \b PNHereNowVerbosityLevel fields to instruct 
             what exactly data it expected in response.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceHereNowAPICallBuilder *(^verbosity)(PNHereNowVerbosityLevel verbosity);

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b required) here now processing completion block which
             pass two arguments: \c result - in case of successful request processing \c data field will 
             contain results of here now operation; \c status - in case if error occurred during request 
             processing.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNGlobalHereNowCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
