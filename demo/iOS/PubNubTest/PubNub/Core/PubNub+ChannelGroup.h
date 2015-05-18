#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


/**
 @brief      \b PubNub client core class extension to provide access to 'stream controller' API 
             group.
 @discussion Set of API which allow to manage channels colletions and manipulate list of channels
             in collection.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub (ChannelGroup)


///------------------------------------------------
/// @name Channel group audition
///------------------------------------------------

/**
 @brief  Fetch list of all (application keys wide) active channel groups list.
 
 @param block Channel groups audition process completion block which pass two arguments:
              \c result - in case of successful request processing \c data field will contain
              results of channel groups audition operation; \c status - in case if error occurred 
              during request processing.
 
 @since 4.0
 */
- (void)channelGroupsWithCompletion:(PNCompletionBlock)block;

/**
 @brief  Fetch list of channels which is registered in specified \c group.
 @note   If \c group will be set to \c nil then list of channel groups will be returned instead of
         channels list.
 
 @param group Name of the group from which channels should be fetched.
 @param block Channels audition process completion block which pass two arguments: \c result - in 
              case of successful request processing \c data field will contain results of channel 
              groups channels audition operation; \c status - in case if error occurred during 
              request processing.
 
 @since 4.0
 */
- (void)channelsForGroup:(NSString *)group withCompletion:(PNCompletionBlock)block;


///------------------------------------------------
/// @name Channel group content manipulation
///------------------------------------------------

/**
 @brief      Add new channels to channel \c group.
 @discussion After addition channels to group it can be used in subscribe request to subscribe on
             remote data objects live feed with single group name.
 
 @param channels List of channel names which should be added to the \c group.
 @param group    Name of the group into which channels should be added.
 @param block    Channels addition process completion block which pass two arguments: \c result - in
                 case of successful request processing \c data field will contain results of 
                 channels addition operation; \c status - in case if error occurred during request
                 processing.
 
 @since 4.0
 */
- (void)addChannels:(NSArray *)channels toGroup:(NSString *)group
     withCompletion:(PNCompletionBlock)block;

/**
 @brief      Remove specified \c channels from channel \c group.
 @discussion After removal channel's live feed events will be unavailable for client which is
             subscribed on channel \c group.
 @warning    In case if \c nil will be passed as \c channels then whole channel group will be 
             removed.
 
 @param channels List of channel names which should be removed from \c group.
 @param group    Name of the group from which channels should be removed.
 @param block    Channels removal process completion block which pass two arguments: \c result - in
                 case of successful request processing \c data field will contain results of 
                 channels removal operation; \c status - in case if error occurred during request 
                 processing.
 
 @since 4.0
 */
- (void)removeChannels:(NSArray *)channels fromGroup:(NSString *)group
        withCompletion:(PNCompletionBlock)block;

/**
 @brief      Remove all channels from \c group.
 @discussion After all channels removed from \c group it become invalid and can't be used in 
             subscribe process anymore.
 
 @param group    Name of the group from which all channels should be removed.
 @param block    Channel group removal process completion block which pass two arguments: 
                 \c result - in case of successful request processing \c data field will contain 
                 results of all channels removal operation; \c status - in case if error occurred
                 during request processing.
 
 @since 4.0
 */
- (void)removeChannelsFromGroup:(NSString *)group withCompletion:(PNCompletionBlock)block;

#pragma mark -


@end
