#import "PNSubscribeAPIBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Subscribe API call builder.
 @discussion Class describe interface which allow to subscribe to \c channel(s) or channel \c group(s) with
             set of additional optinos.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNSubscribeChannelsOrGroupsAPIBuilder : PNSubscribeAPIBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify whether subscription should be done for presence as well.
 @discussion On block call return block which consume \a BOOL and specify wheter client should subscribe to 
             presence \c channel(s) or presence channel \c group(s).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder *(^withPresence)(BOOL withPresence);

/**
 @brief      Specify \c time from which client should try to catch up on messages.
 @discussion On block call return block which consume time token from which client should try to catch up on 
             messages.
 @note       Value will be converted to required precision internally.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder *(^withTimetoken)(NSNumber *withTimetoken);

/**
 @brief      Specify \c user's presence state for \c channel(s) and channel \c group(s).
 @discussion On block call return block which consume dictionary which should be bound to \c uuid and contain 
             list of \c state for each of which key is name of \c channel or channel \c group where it should 
             be set.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder *(^state)(NSDictionary *state);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief  Perform composed API call.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) dispatch_block_t perform;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
