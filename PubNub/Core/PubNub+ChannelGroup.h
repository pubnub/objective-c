#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNChannelGroupChannelsResult, PNAcknowledgmentStatus, PNChannelGroupsResult, PNErrorStatus;


#pragma mark - Types

/**
 @brief  Channel groups list audition completion block.
 
 @param result Reference on result object which describe service response on audition request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNGroupAuditCompletionBlock)(PNChannelGroupsResult *result, PNErrorStatus *status);

/**
 @brief  Channel group channels list audition completion block.
 
 @param result Reference on result object which describe service response on audition request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNGroupChannelsAuditCompletionBlock)(PNChannelGroupChannelsResult *result,
                                                   PNErrorStatus *status);

/**
 @brief  Channel group content modification completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNChannelGroupChangeCompletionBlock)(PNAcknowledgmentStatus *status);


#pragma mark - API group interface

/**
 @brief      \b PubNub client core class extension to provide access to 'stream controller' API 
             group.
 @discussion Set of API which allow to manage channels collections and manipulate list of channels
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
 @brief  Fetch list of all (application keys wide) active channel groups.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client channelGroupsWithCompletion:^(PNChannelGroupsResult *result, PNErrorStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
 
        // Handle downloaded list of groups using: result.data.groups
     }
     // Request processing failed.
     else {
     
        // Handle channel group audition error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
     }
 }];
 @endcode
 
 @param block Channel groups audition process completion block which pass two arguments:
              \c result - in case of successful request processing \c data field will contain
              results of channel groups audition operation; \c status - in case if error occurred 
              during request processing.
 
 @since 4.0
 */
- (void)channelGroupsWithCompletion:(PNGroupAuditCompletionBlock)block;

/**
 @brief  Fetch list of channels which is registered in specified \c group.
 @note   If \c group will be set to \c nil this method will work as \c -channelGroupsWithCompletion:
         and return list of channel groups.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client channelsForGroup:@"pubnub" withCompletion:^(PNChannelGroupChannelsResult *result,
                                                          PNErrorStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
 
        // Handle downloaded list of chanels using: result.data.channels
     }
     // Request processing failed.
     else {
     
        // Handle channels for group audition error. Check 'category' property to find out possible 
        // issue because of which request did fail.
        //
        // Request can be resent using: [status retry];
     }
 }];
 @endcode
 
 @param group Name of the group from which channels should be fetched.
 @param block Channels audition process completion block which pass two arguments: \c result - in 
              case of successful request processing \c data field will contain results of channel 
              groups channels audition operation; \c status - in case if error occurred during 
              request processing.
 
 @since 4.0
 */
- (void)channelsForGroup:(NSString *)group withCompletion:(PNGroupChannelsAuditCompletionBlock)block;


///------------------------------------------------
/// @name Channel group content manipulation
///------------------------------------------------

/**
 @brief      Add new channels to the \c group.
 @discussion After addition channels to group it can be used in subscribe request to subscribe on
             remote data objects live feed with single group name.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client addChannels:@[@"ios", @"macos", @"Win"] toGroup:@"os"
           withCompletion:^(PNAcknowledgmentStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
 
        // Handle successful channels list modification for group.
     }
     // Request processing failed.
     else {
     
        // Handle channels list modification for group error. Check 'category' property to find out
        // possible issue because of which request did fail.
        //
        // Request can be resent using: [status retry];
     }
 }];
 @endcode
 
 @param channels List of channel names which should be added to the \c group.
 @param group    Name of the group into which channels should be added.
 @param block    Channels addition process completion block which pass only one argument - request 
                 processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)addChannels:(NSArray *)channels toGroup:(NSString *)group
     withCompletion:(PNChannelGroupChangeCompletionBlock)block;

/**
 @brief      Remove specified \c channels from \c group.
 @discussion After specified channels will be removed, events from those channel's live feed won't
             be delivered to the client which is subscribed at specified channel group.
 @warning    In case if \c nil will be passed as \c channels then this method will work as 
             \c -removeChannelsFromGroup:withCompletion: and remove all channels from specified 
             group and group itself.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client removeChannels:@[@"ios", @"macos", @"Win"] fromGroup:@"os"
              withCompletion:^(PNAcknowledgmentStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
 
        // Handle successful channels list modification for group.
     }
     // Request processing failed.
     else {
     
        // Handle channels list modification for group error. Check 'category' property to find out
        // possible issue because of which request did fail.
        //
        // Request can be resent using: [status retry];
     }
 }];
 @endcode
 
 @param channels List of channel names which should be removed from \c group.
 @param group    Name of the group from which channels should be removed.
 @param block    Channels removal process completion block which pass only one argument - request 
                 processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)removeChannels:(NSArray *)channels fromGroup:(NSString *)group
        withCompletion:(PNChannelGroupChangeCompletionBlock)block;

/**
 @brief      Remove all channels from \c group.
 @discussion After all channels removed from \c group it become invalid and can't be used in 
             subscribe process anymore.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client removeChannelsFromGroup:@"os" withCompletion:^(PNAcknowledgmentStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
 
        // Handle successful channel group removal.
     }
     // Request processing failed.
     else {
     
        // Handle channel group removal error. Check 'category' property to find out possible issue
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
     }
 }];
 @endcode
 
 @param group    Name of the group from which all channels should be removed.
 @param block    Channel group removal process completion block which pass only one 
                 argument - request processing status to report about how data pushing was 
                 successful or not.
 
 @since 4.0
 */
- (void)removeChannelsFromGroup:(NSString *)group
                 withCompletion:(PNChannelGroupChangeCompletionBlock)block;

#pragma mark -


@end
