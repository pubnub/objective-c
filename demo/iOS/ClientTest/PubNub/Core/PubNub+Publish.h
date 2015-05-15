#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


/**
 @brief      \b PubNub client core class extension to provide access to 'publish' API group.
 @discussion Set of API which allow to push data to \b PubNub service. Data pusched to remote data
             objects called 'channels' and then delivered on their live feeds to all subscribers.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub (Publish)


///------------------------------------------------
/// @name Plain message publish
///------------------------------------------------

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub 
             service. If client has been configured with cipher key message will be encrypted as 
             well.
 @note       Objects can be pushed only to regular channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client publish:@{@"Hello":@"world"} toChannel:@"announcement" withCompletion:^(PNStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
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
 
 @param message Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                \a NSDictionary) which will be published.
 @param channel Reference on name of the channel to which message should be published.
 @param block   Publish processing completion block which pass only one argument - request 
                processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel withCompletion:(PNStatusBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub
             service. If client has been configured with cipher key message will be encrypted as
             well.
 @note       Objects can be pushed only to regular channels.

 @code
 @endcode
 Extension to \c -publish:toChannel:withCompletion: and allow to specify whether message should be
 compressed or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client publish:@{@"Hello":@"world"} toChannel:@"announcement" compressed:NO 
  withCompletion:^(PNStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
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

 @param message    Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                   \a NSDictionary) which will be published.
 @param channel    Reference on name of the channel to which message should be published.
 @param compressed Whether message should be compressed and sent with request body instead of URI
                   part. Compression useful in case if large data should be published, in another 
                   case it will lead to packet size grow.
 @param block      Publish processing completion block which pass only one argument - request
                   processing status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed
 withCompletion:(PNStatusBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub 
             service. If client has been configured with cipher key message will be encrypted as 
             well.
 @note       Objects can be pushed only to regular channels.
 
 @code
 @endcode
 Extension to \c -publish:toChannel:withCompletion: and allow to specify whether message should be
 stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client publish:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO
  withCompletion:^(PNStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
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
 
 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                    \a NSDictionary) which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param block       Publish processing completion block which pass only one argument - request 
                    processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
 withCompletion:(PNStatusBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub
             service. If client has been configured with cipher key message will be encrypted as
             well.
 @note       Objects can be pushed only to regular channels.

 @code
 @endcode
 Extension to \c -publish:toChannel:storeInHistory:withCompletion: and allow to specify whether
 message should be compressed or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client publish:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO compressed:YES
  withCompletion:^(PNStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
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

 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                    \a NSDictionary) which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param compressed  Compression useful in case if large data should be published, in another
                    case it will lead to packet size grow.
 @param block       Publish processing completion block which pass only one argument - request 
                    processing status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
     compressed:(BOOL)compressed withCompletion:(PNStatusBlock)block;


///------------------------------------------------
/// @name Composited message publish
///------------------------------------------------

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub 
             service. If client has been configured with cipher key message will be encrypted as 
             well.
 @note       Objects can be pushed only to regular channels.
 
 @code
 @endcode
 Extension to \c -publish:toChannel:withCompletion: and allow to specify push payloads which can be
 sent using different vendors (Apple and/or Google).
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client    publish:@{@"Hello":@"world"} toChannel:@"announcement"
  mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} withCompletion:^(PNStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
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
 
 @param message  Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                 \a NSDictionary) which will be published.
 @param channel  Reference on name of the channel to which message should be published.
 @param payloads Dictionary with payloads for different vendors (Apple with "apns" key and Google
                 with "gcm").
 @param block    Publish processing completion block which pass only one argument - request 
                 processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads withCompletion:(PNStatusBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub
             service. If client has been configured with cipher key message will be encrypted as
             well.
 @note       Objects can be pushed only to regular channels.

 @code
 @endcode
 Extension to \c -publish:toChannel:mobilePushPayload:withCompletion: and specify whether message
 itself should be compressed or not. Only message will be compressed and \c payloads will be kept in
 JSON string format.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client    publish:@{@"Hello":@"world"} toChannel:@"announcement"
  mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} compressed:YES
     withCompletion:^(PNStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
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

 @param message    Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                   \a NSDictionary) which will be published.
 @param channel    Reference on name of the channel to which message should be published.
 @param payloads   Dictionary with payloads for different vendors (Apple with "apns" key and Google
                   with "gcm").
 @param compressed Compression useful in case if large data should be published, in another
                   case it will lead to packet size grow.
 @param block      Publish processing completion block which pass only one argument - request 
                   processing status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel mobilePushPayload:(NSDictionary *)payloads
     compressed:(BOOL)compressed withCompletion:(PNStatusBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub 
             service. If client has been configured with cipher key message will be encrypted as 
             well.
 @note       Objects can be pushed only to regular channels.
 
 @code
 @endcode
 Extension to \c -publish:toChannel:withCompletion: and allow to specify push payloads which can be
 sent using different vendors (Apple and/or Google).
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client    publish:@{@"Hello":@"world"} toChannel:@"announcement"
  mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} storeInHistory:YES
     withCompletion:^(PNStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
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
 
 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                    \a NSDictionary) which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param payloads    Dictionary with payloads for different vendors (Apple with "apns" key and Google 
                    with "gcm").
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param block       Publish processing completion block which pass only one argument - request 
                    processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
     withCompletion:(PNStatusBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub
             service. If client has been configured with cipher key message will be encrypted as
             well.
 @note       Objects can be pushed only to regular channels.

 @code
 @endcode
 Extension to \c -publish:toChannel:mobilePushPayload:storeInHistory:withCompletion:  and specify
 whether message itself should be compressed or not. Only message will be compressed and \c payloads
 will be kept in JSON string format.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 [client    publish:@{@"Hello":@"world"} toChannel:@"announcement"
  mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} storeInHistory:YES compressed:NO
     withCompletion:^(PNStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
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

 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                    \a NSDictionary) which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param payloads    Dictionary with payloads for different vendors (Apple with "apns" key and Google
                    with "gcm").
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param compressed  Compression useful in case if large data should be published, in another
                    case it will lead to packet size grow.
 @param block       Publish processing completion block which pass only one argument - request
                    processing status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
         compressed:(BOOL)compressed withCompletion:(PNStatusBlock)block;

#pragma mark -


@end
