#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNSubscribeChannelsOrGroupsAPIBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Subscribe API call builder.
 @discussion Class describe interface which provide access to various subscription endpoints.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNSubscribeAPIBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Channels and Channel Groups
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for access to
             subscription API.
 @discussion On block call return block which consume list of \c channel name(s) from which \b PubNub client 
             should subscribe.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder *(^channels)(NSArray<NSString *> *channels); 

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for access to
             subscription API.
 @discussion On block call return block which consume list of channel \c group name(s) from which \b PubNub 
             client should subscribe.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder *(^channelGroups)(NSArray<NSString *> *channelGroups);


///------------------------------------------------
/// @name Presence
///------------------------------------------------

/**
 @brief      Specify list of presence \c channel name(s).
 @discussion On block call return block which consume list of presence \c channel name(s) for which \b PubNub 
             client should subscribe.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeAPIBuilder *(^presenceChannels)(NSArray<NSString *> *presenceChannels); 


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
