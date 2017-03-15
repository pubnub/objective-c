#import "PNUnsubscribeAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Unsubscribe API call builder.
 @discussion Class describe interface which allow to unsubscribe from \c channel(s) or channel \c group(s)
             with set of additional optinos.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNUnsubscribeChannelsOrGroupsAPICallBuilder : PNUnsubscribeAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify whether unsubscription should be done for presence as well.
 @discussion On block call return block which consume \a BOOL and specify wheter client should unsubscribe 
             from presence \c channel(s) or presence channel \c group(s).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNUnsubscribeChannelsOrGroupsAPICallBuilder *(^withPresence)(BOOL withPresence);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief   Perform composed API call.
 @warning If no list of presence \c channel name(s) has been specified before method call - \b PubNub client 
          will unsubscribed from all \c channel(s) and channel \c group(s) (including presence \c channel(s) 
          and channel \c group(s)).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) dispatch_block_t perform;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
