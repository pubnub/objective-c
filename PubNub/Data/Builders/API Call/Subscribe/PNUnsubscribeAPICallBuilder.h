#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNUnsubscribeChannelsOrGroupsAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Unsubscribe API call builder.
 @discussion Class describe interface which provide access to various unsubscription endpoints.
 
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNUnsubscribeAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Channels and Channel Groups
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for access to
             unsubscription API.
 @discussion On block call return block which consume list of \c channel name(s) from which \b PubNub client 
             should unsubscribe.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNUnsubscribeChannelsOrGroupsAPICallBuilder *(^channels)(NSArray<NSString *> *channels);

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for access to
             unsubscription API.
 @discussion On block call return block which consume list of channel \c group name(s) from which \b PubNub 
             client should unsubscribe.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNUnsubscribeChannelsOrGroupsAPICallBuilder *(^channelGroups)(NSArray<NSString *> *channelGroups);


///------------------------------------------------
/// @name Presence
///------------------------------------------------

/**
 @brief      Specify list of presence \c channel(s).
 @discussion On block call return block which consume list of presence \c channel name(s) from which \b PubNub
             client should unsubscribe.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNUnsubscribeAPICallBuilder *(^presenceChannels)(NSArray<NSString *> *presenceChannels);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief   Perform composed API call.
 @warning If no list of \c channel(s) or channel \c group(s) has been specified before method call - \b PubNub
          client will unsubscribed from all \c channel(s) and channel \c group(s) (including presence 
          \c channel(s) and channel \c group(s)).
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) dispatch_block_t perform;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
