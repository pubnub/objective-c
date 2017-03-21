#import "PNStateAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Presence state modification API call builder.
 @discussion Class describe interface which allow to modify \c user's presence state for \c channel and / or
             channel \c group.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNStateModificationAPICallBuilder : PNStateAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify unique \c user identifier.
 @discussion On block call return block which consume (\b required) unique \c user identifier for which 
             presence state should be modified on provided \c channel or channel \c group.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder *(^uuid)(NSString *uuid);


/**
 @brief      Specify \c user's presence state.
 @discussion On block call return block which consume dictionary which should be bound to \c uuid on specified
             \c channel or channel \c group.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder *(^state)(NSDictionary * _Nullable state); 

/**
 @brief      Specify \c channel name.
 @discussion On block call return block which consume name of \c channel for which \c user's presence state 
             should be modified.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder *(^channel)(NSString *channel);

/**
 @brief      Specify channel \c group name.
 @discussion On block call return block which consume name of channel \c group for which \c user's presence 
             state should be modified.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder *(^channelGroup)(NSString *channelGroup);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b not required) state modification for user on channel
             processing completion block which pass only one argument - request processing status to report 
             about how data pushing was successful or not.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNSetStateCompletionBlock _Nullable block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
