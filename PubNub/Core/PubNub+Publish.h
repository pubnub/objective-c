#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark API group protocols

/**
 @brief      Protocol which describe publish result data object structure.
 @discussion Contain information about when message has been accepted by \b PubNub service and
             message associated with operation.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNPublishData <PNErrorStatusData>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Service-provided time stamp at which message has been pushed to remote data object live
         feed.
 
 @return Number with unsigned long long as timestamp.
 
 @since 4.0
 */
- (NSNumber *)timetoken;

/**
 @brief  Service-provide information about service response message.
 
 @return String received from \b PubNub service along with processing results.
 
 @since 4.0
 */
- (NSString *)information;

@end


/**
 @brief  Protocol which describe operation processing status object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNPublishStatus <PNStatus>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNPublishData> *data;

@end


#pragma mark - Types

/**
 @brief  Message publish completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNPublishCompletionBlock)(PNStatus<PNPublishStatus> *status);

/**
 @brief  Message size calculation completion block.
 
 @param size Calculated size of the packet which will be used to send message.
 
 @since 4.0
 */
typedef void(^PNMessageSizeCalculationCompletionBlock)(NSInteger size);


#pragma mark - API group interface

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
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
       withCompletion:^(PNStatus<PNPublishStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle message publish error. Check 'category' property to find out possible issue 
         // because of which request did fail.
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
- (void)  publish:(id)message toChannel:(NSString *)channel
   withCompletion:(PNPublishCompletionBlock)block;

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
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client publish:@{@"Hello":@"world"} toChannel:@"announcement" compressed:NO
       withCompletion:^(PNStatus<PNPublishStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle message publish error. Check 'category' property to find out possible issue 
         // because of which request did fail.
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
- (void)  publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed
   withCompletion:(PNPublishCompletionBlock)block;

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
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client publish:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO
       withCompletion:^(PNStatus<PNPublishStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle message publish error. Check 'category' property to find out possible issue 
         // because of which request did fail.
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
- (void)  publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
   withCompletion:(PNPublishCompletionBlock)block;

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
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client publish:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO 
           compressed:YES withCompletion:^(PNStatus<PNPublishStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle message publish error. Check 'category' property to find out possible issue 
         // because of which request did fail.
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
     compressed:(BOOL)compressed withCompletion:(PNPublishCompletionBlock)block;


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
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
    mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}}
       withCompletion:^(PNStatus<PNPublishStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle message publish error. Check 'category' property to find out possible issue 
         // because of which request did fail.
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
  mobilePushPayload:(NSDictionary *)payloads withCompletion:(PNPublishCompletionBlock)block;

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
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
    mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} compressed:YES
       withCompletion:^(PNStatus<PNPublishStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle message publish error. Check 'category' property to find out possible issue 
         // because of which request did fail.
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
     compressed:(BOOL)compressed withCompletion:(PNPublishCompletionBlock)block;

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
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
    mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} storeInHistory:YES
       withCompletion:^(PNStatus<PNPublishStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle message publish error. Check 'category' property to find out possible issue 
         // because of which request did fail.
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
     withCompletion:(PNPublishCompletionBlock)block;

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
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
    mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} storeInHistory:YES compressed:NO
       withCompletion:^(PNStatus<PNPublishStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Message successfully published to specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle message publish error. Check 'category' property to find out possible issue 
         // because of which request did fail.
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
         compressed:(BOOL)compressed withCompletion:(PNPublishCompletionBlock)block;


///------------------------------------------------
/// @name Message helper
///------------------------------------------------

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to
             \b PubNub network.
 @discussion Size calculation use percent-escaped \c message and all added headers to get full size.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client sizeOfMessage:@{@"Hello":@"world"} toChannel:@"announcement"
             withCompletion:^(NSInteger size) {
 
     // Actual message size is: size
 }];
 @endcode
 
 @param message Message for which size should be calculated.
 @param channel Name of the channel to which message should be sent (it is part of request URI).
 @param block   Referecnce on block which should be sent, when message size calculation will be
                completed.
 
 @since 4.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to
             \b PubNub network.
 @discussion Size calculation use percent-escaped \c message and all added headers to get full size.

 @code
 @endcode
 Extension to \c -sizeOfMessage:toChannel:withCompletion: and specify whether message should be 
 compressed or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client sizeOfMessage:@{@"Hello":@"world"} toChannel:@"announcement" compressed:YES
             withCompletion:^(NSInteger size) {
 
     // Actual message size is: size
 }];
 @endcode
 
 @param message         Message for which size should be calculated.
 @param channel         Name of the channel to which message should be sent (it is part of request 
                        URI).
 @param compressMessage \c YES in case if message should be compressed before sending to \b PubNub
                        network.
 @param block           Referecnce on block which should be sent, when message size calculation will
                        be completed.
 
 @since 4.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to
             \b PubNub network.
 @discussion Size calculation use percent-escaped \c message and all added headers to get full size.

 @code
 @endcode
 Extension to \c -sizeOfMessage:toChannel:withCompletion: and specify whether message should be
 stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client sizeOfMessage:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO
             withCompletion:^(NSInteger size) {
 
     // Actual message size is: size
 }];
 @endcode
 
 @param message     Message for which size should be calculated.
 @param channel     Name of the channel to which message should be sent (it is part of request URI).
 @param shouldStore \c YES in case if message should be placed into history storage.
 @param block       Referecnce on block which should be sent, when message size calculation will be
                    completed.
 
 @since 4.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to
             \b PubNub network.
 @discussion Size calculation use percent-escaped \c message and all added headers to get full size.

 @code
 @endcode
 Extension to \c -sizeOfMessage:toChannel:compressed:withCompletion: and specify whether message 
 should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client sizeOfMessage:@{@"Hello":@"world"} toChannel:@"announcement" compressed:NO 
             storeInHistory:NO withCompletion:^(NSInteger size) {
 
     // Actual message size is: size
 }];
 @endcode
 
 @param message         Message for which size should be calculated.
 @param channel         Name of the channel to which message should be sent (it is part of request 
                        URI).
 @param compressMessage \c YES in case if message should be compressed before sending to \b PubNub
                        network.
 @param shouldStore     \c NO in case if message shouldn't be available after it has been sent via
                        history storage API methods group.
 @param block           Referecnce on block which should be sent, when message size calculation will
                        be completed.
 
 @since 4.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block;

#pragma mark -


@end
