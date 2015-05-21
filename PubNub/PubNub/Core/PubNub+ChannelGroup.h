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
 @brief  Fetch list of all (application keys wide) active channel groups.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client channelGroupsWithCompletion:^(PNResult *result, PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {

         // Fetched list of groups stored in result.data[@"channel-groups"]
     }
     // Request processing failed.
     else {

         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "error": Number (boolean),
         //     "status": Number (boolean),
         //     "information": String (description)
         // }
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param block Channel groups audition process completion block which pass two arguments:
              \c result - in case of successful request processing \c data field will contain
              results of channel groups audition operation; \c status - in case if error occurred 
              during request processing.
 
 @since 4.0
 */
- (void)channelGroupsWithCompletion:(PNCompletionBlock)block;

/**
 @brief  Fetch list of channels which is registered in specified \c group.
 @note   If \c group will be set to \c nil this method will work as \c -channelGroupsWithCompletion:
         and return list of channel groups.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client channelsForGroup:@"pubnub" withCompletion:^(PNResult *result, PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {

         // Fetched list of channels stored in result.data[@"channels"]
     }
     // Request processing failed.
     else {

         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "error": Number (boolean),
         //     "status": Number (boolean),
         //     "information": String (description)
         // }
         //
         // Request can be resend using: [status retry];
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
- (void)channelsForGroup:(NSString *)group withCompletion:(PNCompletionBlock)block;


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
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [self.client addChannels:@[@"ios", @"macos", @"MS"] toGroup:@"os"
           withCompletion:^(PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // Channels successfully added to specified channel group.
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "error": Number (boolean),
         //     "status": Number (boolean),
         //     "information": String (description)
         // }
         //
         // Request can be resend using: [status retry];
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
     withCompletion:(PNStatusBlock)block;

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
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [self.client removeChannels:@[@"ios", @"macos", @"MS"] fromGroup:@"os"
              withCompletion:^(PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // Channels successfully removed from specified channel group.
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "error": Number (boolean),
         //     "status": Number (boolean),
         //     "information": String (description)
         // }
         //
         // Request can be resend using: [status retry];
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
        withCompletion:(PNStatusBlock)block;

/**
 @brief      Remove all channels from \c group.
 @discussion After all channels removed from \c group it become invalid and can't be used in 
             subscribe process anymore.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [self.client removeChannelsFromGroup:@"os" withCompletion:^(PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {
            
         // All channels from channel group and group itself successfully removed.
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         // status.data for PNAccessDeniedCategory it will look like this:
         // {
         //     "error": Number (boolean),
         //     "status": Number (boolean),
         //     "information": String (description)
         // }
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param group    Name of the group from which all channels should be removed.
 @param block    Channel group removal process completion block which pass only one 
                 argument - request processing status to report about how data pushing was 
                 successful or not.
 
 @since 4.0
 */
- (void)removeChannelsFromGroup:(NSString *)group withCompletion:(PNStatusBlock)block;

#pragma mark -


@end
