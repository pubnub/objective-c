#import "PNStateAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Presence state audit API call builder.
 @discussion Class describe interface which allow to audit user's presence state (retrieve state information 
             which has been set for user on \c channel and / or channel \c group).
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNStateAuditAPICallBuilder : PNStateAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify unique \c user identifier.
 @discussion On block call return block which consume (\b required) unique \c user identifier for which 
             presence state audition should be done for provided \c channel or channel \c group.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder *(^uuid)(NSString *uuid);

/**
 @brief      Specify \c channel name.
 @discussion On block call return block which consume name of \c channel for which \c user's presence state 
             should be audited.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder *(^channel)(NSString *channel);

/**
 @brief      Specify channel \c group name.
 @discussion On block call return block which consume name of channel \c group for which \c user's presence 
             state should be audited.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder *(^channelGroup)(NSString *channelGroup);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b required) state audition for user on channel 
             processing completion block which pass two arguments: \c result - in case of successful request 
             processing \c data field will contain results of client state retrieve operation; \c status - in 
             case if error occurred during request processing.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNChannelStateCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
