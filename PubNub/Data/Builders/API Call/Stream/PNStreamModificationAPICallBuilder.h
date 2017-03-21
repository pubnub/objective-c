#import "PNStreamAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Stream modification API call builder.
 @discussion Class describe interface which allow to \b add channel(s) to channel \c group.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNStreamModificationAPICallBuilder : PNStreamAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify channel \c group for modification.
 @discussion On block call return block which consume (\b required) name of channel \c group for which list of
             registered channels should be modified.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamModificationAPICallBuilder *(^channelGroup)(NSString *channelGroup);

/**
 @brief      Specify channel name(s) list.
 @discussion On block call return block which consume channel name(s) list which should be used  during
             channel \c group registered channels list modification.
 @warning    \b PubNub client will remove specified channel \c group if \c nil or \c empty list will be passed
             during \c remove.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamModificationAPICallBuilder *(^channels)(NSArray<NSString *> *channels);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b not required) channel group modification process 
             completion block which pass only one argument - request processing status to report about how 
             data pushing was successful or not.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNChannelGroupChangeCompletionBlock _Nullable block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
