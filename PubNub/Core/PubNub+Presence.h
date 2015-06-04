#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark API group protocols

/**
 @brief      Protocol which describe here now data object structure.
 @discussion Contain presence information about channels.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNHereNowData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Active channel subscribers unique identifiers.
 @note   This object can be empty in case if only occupancy has been requested.
 @note   This object can contain list of uuids or dictionary with uuids and client state information
         bound to them.
 
 @return Subscribers information (unique identifiers list of dictionary with client's state 
         information).
 
 @since 4.0
 */
- (id)uuids;

/**
 @brief  Active subscribers count.
 
 @return Number of unique subscribers on channel.
 
 @since 4.0
 */
- (NSNumber *)occupancy;

@end


/**
 @brief      Protocol which describe global here now data object structure.
 @discussion Contain presence information about each channel which is registered for \b PunNub 
             application keys.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNGlobalHereNowData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief      Active channels list.
 @discussion Each dictionary key represent channel name and it's value is presence information for 
             it.
 
 @return Channel based presence information dictionary.
 
 @since 4.0
 */
- (NSDictionary *)channels;

/**
 @brief  Total number of active channels.
 
 @return Number of channels with active subscribers.
 
 @since 4.0
 */
- (NSNumber *)totalChannels;

/**
 @brief  Total number of subscribers.
 
 @return Overall number of subscribers on channels.
 
 @since 4.0
 */
- (NSNumber *)totalOccupancy;

@end


/**
 @brief      Protocol used to provide access to \c data field structure for \b PNStatus instance 
             object.
 @discussion Mostly used for state set operations and represent resulting object which has been 
             stored in \b PubNub network.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNChannelGroupHereNowData <PNGlobalHereNowData>

@end


/**
 @brief      Protocol used to provide access to \c data field structure for \b PNStatus instance 
             object.
 @discussion Mostly used for state set operations and represent resulting object which has been 
             stored in \b PubNub network.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNWhereNowData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  List of channels on which client subscribed.
 
 @return Channel names list.
 
 @since 4.0
 */
- (NSDictionary *)channels;

@end


/**
 @brief      Protocol which describe object returned from state audit API.
 @discussion This method allow to provide access to structured response data field.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNHereNowResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Structured \b PNResult \c data field information.
 
 @return Reference on field which hold structured service response.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNHereNowData> *data;

@end


/**
 @brief  Protocol which describe operation processing resulting object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNGlobalHereNowResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNGlobalHereNowData> *data;

@end


/**
 @brief  Protocol which describe operation processing resulting object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNChannelGroupHereNowResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNChannelGroupHereNowData> *data;

@end


/**
 @brief  Protocol which describe operation processing resulting object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNWhereNowResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNWhereNowData> *data;

@end


#pragma mark - Types

/**
 @brief  Here now completion block.
 
 @param result Reference on result object which describe service response on here now request.
 @param status Reference on status instance which hold information about procesing results.
 
 @since 4.0
 */
typedef void(^PNHereNowCompletionBlock)(PNResult<PNHereNowResult> *result,
                                        PNStatus<PNStatus> *status);

/**
 @brief  Global here now completion block.
 
 @param result Reference on result object which describe service response on here now request.
 @param status Reference on status instance which hold information about procesing results.
 
 @since 4.0
 */
typedef void(^PNGlobalHereNowCompletionBlock)(PNResult<PNGlobalHereNowResult> *result,
                                              PNStatus<PNStatus> *status);

/**
 @brief  Channel group here now completion block.
 
 @param result Reference on result object which describe service response on here now request.
 @param status Reference on status instance which hold information about procesing results.
 
 @since 4.0
 */
typedef void(^PNChannelGroupHereNowCompletionBlock)(PNResult<PNChannelGroupHereNowResult> *result,
                                                    PNStatus<PNStatus> *status);

/**
 @brief  UUID where now completion block.
 
 @param result Reference on result object which describe service response on where now request.
 @param status Reference on status instance which hold information about procesing results.
 
 @since 4.0
 */
typedef void(^PNWhereNowCompletionBlock)(PNResult<PNWhereNowResult> *result,
                                         PNStatus<PNStatus> *status);


#pragma mark - API group interface
/**
 @brief      \b PubNub client core class extension to provide access to 'presence' API group.
 @discussion Set of API which allow to retrieve information about subscriber(s) on remote data 
             object live feeds and perform heartbeat requests to let \b PubNub service know what
             client still interested in updates from feed.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub (Presence)


///------------------------------------------------
/// @name Global here now
///------------------------------------------------

/**
 @brief      Request information about subscribers on all remote data objects live feeds.
 @discussion This is application wide request for all remote data objects which is registered under
             publish and subscribe keys used for client configuration.
 @note       This API will retrieve only list of UUIDs for each remote data object and number of 
             subscribers in total for objects and overall.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client hereNowWithCompletion:^(PNResult *result, PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {

         // Global here now information successfully received.
         // result.data will look like this:
         // {
         //     "channels": {
         //         <channel name>: {
         //             "occupancy": Number,
         //             "uuids": [
         //                 String,
         //                 ...
         //             ]
         //         },
         //         ...
         //     },
         //     "total_channels": Number,
         //     "total_occupancy": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param block Here now processing completion block which pass two arguments: \c result - in case of
              successful request processing \c data field will contain results of here now 
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowWithCompletion:(PNGlobalHereNowCompletionBlock)block;

/**
 @brief      Request information about subscribers on all remote data objects live feeds.
 @discussion This is application wide request for all remote data objects which is registered under
             publish and subscribe keys used for client configuration.
 @note       This API will retrieve only list of UUIDs for each remote data object and number of 
             subscribers in total for objects and overall.

 @code
 @endcode
 Extension to \c -hereNowWithCompletion: and allow to specify here now data which should be returned
 by \b PubNub service.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client hereNowData:PNHereNowState withCompletion:^(PNResult *result, PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {

         // Global here now information successfully received. Additionally state for each 
         // subscriber has been requested.
         // result.data will look like this:
         // {
         //     "channels": {
         //         <channel name>: {
         //             "occupancy": Number,
         //             "uuids": [
         //                 {
         //                     "uuid": String,
         //                     "state": Dictionary
         //                 },
         //                 ...
         //             ]
         //         },
         //         ...
         //     },
         //     "total_channels": Number,
         //     "total_occupancy": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param type  Reference on one of \b PNHereNowDataType fields to instruct what exactly data it 
              expected in response.
 @param block Here now processing completion block which pass two arguments: \c result - in case of 
              successful request processing \c data field will contain results of here now
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowData:(PNHereNowDataType)type withCompletion:(PNGlobalHereNowCompletionBlock)block;


///------------------------------------------------
/// @name Channel here now
///------------------------------------------------

/**
 @brief  Request information about subscribers on specific channel live feeds.
 @note   This API will retrieve only list of UUIDs for specified channel and number of subscribers 
         on it.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client hereNowForChannel:@"pubnub" withCompletion:^(PNResult *result, PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {

         // Channel here now information successfully received.
         // result.data will look like this:
         // {
         //     "occupancy": Number,
         //     "uuids": [
         //         String,
         //         ...
         //     ]
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param channel Reference on channel for which here now information should be received.
 @param block   Here now processing completion block which pass two arguments: \c result - in case 
                of successful request processing \c data field will contain results of here now 
                operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowForChannel:(NSString *)channel withCompletion:(PNHereNowCompletionBlock)block;

/**
 @brief  Request information about subscribers on specific channel live feeds.
 @note   This API will retrieve only list of UUIDs for specifiedchannel and number of subscribers on
         it.

 @code
 @endcode
 Extension to \c -hereNowForChannel:withCompletion: and allow to specify here now data which should
 be returned by \b PubNub service.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client hereNowData:PNHereNowState forChannel:@"pubnub" 
      withCompletion:^(PNResult *result, PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {

         // Channel here now information successfully received. Additionally state for each
         // subscriber has been requested.
         // result.data will look like this:
         // {
         //     "occupancy": Number,
         //     "uuids": [
         //         {
         //             "uuid": String,
         //             "state": Dictionary
         //         },
         //         ...
         //     ]
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param type    Reference on one of \b PNHereNowDataType fields to instruct what exactly data it
                expected in response.
 @param channel Reference on channel for which here now information should be received.
 @param block   Here now processing completion block which pass two arguments: \c result - in case 
                of successful request processing \c data field will contain results of here now 
                operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowData:(PNHereNowDataType)type forChannel:(NSString *)channel
     withCompletion:(PNHereNowCompletionBlock)block;


///------------------------------------------------
/// @name Channel group here now
///------------------------------------------------

/**
 @brief  Request information about subscribers on specific channel group live feeds.
 @note   This API will retrieve only list of UUIDs for specified channel group and number of
         subscribers on it.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client hereNowForChannelGroup:@"developers" withCompletion:^(PNResult *result, PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {

         // Channel group here now information successfully received.
         // result.data will look like this:
         // {
         //     "channels": {
         //         <channel name>: {
         //             "occupancy": Number,
         //             "uuids": [
         //                 String,
         //                 ...
         //             ]
         //         },
         //         ...
         //     },
         //     "total_channels": Number,
         //     "total_occupancy": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param group Reference on channel group name for which here now information should be received.
 @param block Here now processing completion block which pass two arguments: \c result - in case of 
              successful request processing \c data field will contain results of here now 
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowForChannelGroup:(NSString *)group
                withCompletion:(PNChannelGroupHereNowCompletionBlock)block;

/**
 @brief  Request information about subscribers on specific channel group live feeds.
 @note   This API will retrieve only list of UUIDs for specified channel group and number of
         subscribers on it.

 @code
 @endcode
 Extension to \c -hereNowForChannel:withCompletion: and allow to specify here now data which should
 be returned by \b PubNub service.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client hereNowData:PNHereNowState forChannelGroup:@"developers" 
      withCompletion:^(PNResult *result, PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {

         // Channel group here now information successfully received. Additionally state for each
         // subscriber has been requested.
         // result.data will look like this:
         // {
         //     "channels": {
         //         <channel name>: {
         //             "occupancy": Number,
         //             "uuids": [
         //                 {
         //                     "uuid": String,
         //                     "state": Dictionary
         //                 },
         //                 ...
         //             ]
         //         },
         //         ...
         //     },
         //     "total_channels": Number,
         //     "total_occupancy": Number
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param type  Reference on one of \b PNHereNowDataType fields to instruct what exactly data it
              expected in response.
 @param group Reference on channel group for which here now information should be received.
 @param block Here now processing completion block which pass two arguments: \c result - in case of 
              successful request processing \c data field will contain results of here now 
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowData:(PNHereNowDataType)type forChannelGroup:(NSString *)group
     withCompletion:(PNChannelGroupHereNowCompletionBlock)block;


///------------------------------------------------
/// @name Client where now
///------------------------------------------------

/**
 @brief  Request information about remote data object live feeds on which client with specified UUID
         subscribed at this moment.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client hereNowData:PNHereNowState forChannelGroup:@"developers" 
      withCompletion:^(PNResult *result, PNStatus *status) {
        
     // Check whether request successfully completed or not.
     if (!status.isError) {

         // Client where now information successfully received. Additionally state for each
         // subscriber has been requested.
         // result.data will look like this:
         // {
         //     "channels": {
         //         String,
         //         ...
         //     }
         // }
     }
     // Request processing failed.
     else {
            
         // status.category field contains reference on one of PNStatusCategory enum fields
         // which describe error category (can be access denied in case if PAM used for keys
         // which is used for configuration). All PNStatusCategory fields has  builtin documentation
         // and describe what exactly happened.
         // Depending on category type status.data may contain additional information about issue 
         // (service response).
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param uuid  Reference on UUID for which request should be performed.
 @param block Where now processing completion block which pass two arguments: \c result - in case of
              successful request processing \c data field will contain results of where now
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNWhereNowCompletionBlock)block;

#pragma mark -


@end
