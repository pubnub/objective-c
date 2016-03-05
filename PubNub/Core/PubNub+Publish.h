#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNPublishStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Types

/**
 @brief  Message publish completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNPublishCompletionBlock)(PNPublishStatus *status);

/**
 @brief  Message size calculation completion block.
 
 @param size Calculated size of the packet which will be used to send message.
 
 @since 4.0
 */
typedef void(^PNMessageSizeCalculationCompletionBlock)(NSInteger size);


#pragma mark - API group interface

/**
 @brief      \b PubNub client core class extension to provide access to 'publish' API group.
 @discussion Set of API which allow to push data to \b PubNub service. Data pushed to remote data objects
             called 'channels' and then delivered on their live feeds to all subscribers.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PubNub (Publish)


///------------------------------------------------
/// @name Plain message publish
///------------------------------------------------

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
      withCompletion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param message Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which 
                will be published.
 @param channel Reference on name of the channel to which message should be published.
 @param block   Publish processing completion block which pass only one argument - request processing status
                to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)  publish:(id)message toChannel:(NSString *)channel
   withCompletion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:withCompletion: and allow to specify metadata payload which 
             will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
        withMetadata:@{@"to":@"John Doe"} completion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param message  Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which 
                 will be published.
 @param channel  Reference on name of the channel to which message should be published.
 @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block    Publish processing completion block which pass only one argument - request processing status 
                 to report about how data pushing was successful or not.
 
 @since 4.3.0
 */
- (void)  publish:(id)message toChannel:(NSString *)channel 
     withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
       completion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:withCompletion: and allow to specify whether message should be
             compressed or not.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement" compressed:NO
      withCompletion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode

 @param message    Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                   which will be published.
 @param channel    Reference on name of the channel to which message should be published.
 @param compressed Whether message should be compressed and sent with request body instead of URI part.
                   Compression useful in case if large data should be published, in another case it will lead
                   to packet size grow.
 @param block      Publish processing completion block which pass only one argument - request processing 
                   status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)  publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed
   withCompletion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:compressed:withCompletion: and allow to specify
             metadata payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement" compressed:NO
        withMetadata:@{@"to":@"John Doe"} completion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode

 @param message    Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                   which will be published.
 @param channel    Reference on name of the channel to which message should be published.
 @param compressed Whether message should be compressed and sent with request body instead of URI part. 
                   Compression useful in case if large data should be published, in another case it will lead
                   to packet size grow.
 @param metadata   \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block      Publish processing completion block which pass only one argument - request processing 
                   status to report about how data pushing was successful or not.

 @since 4.3.0
 */
- (void)  publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed 
     withMetadata:(nullable NSDictionary<NSString *, id> *)metadata 
       completion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:withCompletion: and allow to specify whether message should be
             stored in history or not.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO
      withCompletion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                    which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param block       Publish processing completion block which pass only one argument - request processing 
                    status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)  publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
   withCompletion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:storeInHistory:withCompletion: and allow to specify metadata 
             payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO
        withMetadata:@{@"to":@"John Doe"} completion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                    which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param metadata    \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block       Publish processing completion block which pass only one argument - request processing
                    status to report about how data pushing was successful or not.
 
 @since 4.3.0
 */
- (void)  publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore 
     withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
       completion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:storeInHistory:withCompletion: and allow to specify whether 
             message should be compressed or not.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO 
          compressed:YES withCompletion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode

 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                    which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param compressed  Compression useful in case if large data should be published, in another case it will lead
                    to packet size grow.
 @param block       Publish processing completion block which pass only one argument - request processing 
                    status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
     compressed:(BOOL)compressed withCompletion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:storeInHistory:compressed:withCompletion: and allow to specify
             metadata payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO 
          compressed:YES withMetadata:@{@"to":@"John Doe"} 
          completion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode

 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                    which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param compressed  Compression useful in case if large data should be published, in another case it will lead
                    to packet size grow.
 @param metadata    \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block       Publish processing completion block which pass only one argument - request processing 
                    status to report about how data pushing was successful or not.

 @since 4.3.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
     compressed:(BOOL)compressed withMetadata:(nullable NSDictionary<NSString *, id> *)metadata 
     completion:(nullable PNPublishCompletionBlock)block;


///------------------------------------------------
/// @name Composite message publish
///------------------------------------------------

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:withCompletion: and allow to specify push payloads which can 
             be sent using different vendors (Apple and/or Google).
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
   mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}}
      withCompletion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param message  Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which 
                 will be published.
 @param channel  Reference on name of the channel to which message should be published.
 @param payloads Dictionary with payloads for different vendors (Apple with "apns" key and Google with "gcm").
 @param block    Publish processing completion block which pass only one argument - request processing status 
                 to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)    publish:(nullable id)message toChannel:(NSString *)channel
  mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
     withCompletion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:withCompletion:mobilePushPayload: and allow to specify 
             metadata payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
   mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} 
        withMetadata:@{@"to":@"John Doe"} completion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param message  Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which 
                 will be published.
 @param channel  Reference on name of the channel to which message should be published.
 @param payloads Dictionary with payloads for different vendors (Apple with "apns" key and Google with "gcm").
 @param block    Publish processing completion block which pass only one argument - request processing status
                 to report about how data pushing was successful or not.
 
 @since 4.3.0
 */
- (void)    publish:(nullable id)message toChannel:(NSString *)channel
  mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       withMetadata:(nullable NSDictionary<NSString *, id> *)metadata 
         completion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:mobilePushPayload:withCompletion: and specify whether message
             itself should be compressed or not. Only message will be compressed and \c payloads will be kept
             in JSON string format.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
   mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} compressed:YES
      withCompletion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode

 @param message    Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                   which will be published.
 @param channel    Reference on name of the channel to which message should be published.
 @param payloads   Dictionary with payloads for different vendors (Apple with "apns" key and Google with 
                   "gcm").
 @param compressed Compression useful in case if large data should be published, in another case it will lead
                   to packet size grow.
 @param block      Publish processing completion block which pass only one argument - request processing 
                   status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)    publish:(nullable id)message toChannel:(NSString *)channel
  mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads compressed:(BOOL)compressed 
     withCompletion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:mobilePushPayload:compressed:withCompletion: and allow to
             specify metadata payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
   mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} compressed:YES
        withMetadata:@{@"to":@"John Doe"} completion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode

 @param message    Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                   which will be published.
 @param channel    Reference on name of the channel to which message should be published.
 @param payloads   Dictionary with payloads for different vendors (Apple with "apns" key and Google with 
                   "gcm").
 @param compressed Compression useful in case if large data should be published, in another case it will lead
                   to packet size grow.
 @param metadata   \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block      Publish processing completion block which pass only one argument - request processing 
                   status to report about how data pushing was successful or not.

 @since 4.3.0
 */
- (void)    publish:(nullable id)message toChannel:(NSString *)channel
  mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads compressed:(BOOL)compressed 
       withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
         completion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:withCompletion: and allow to specify push payloads which can 
             be sent using different vendors (Apple and/or Google).
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
   mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} storeInHistory:YES
      withCompletion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                    which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param payloads    Dictionary with payloads for different vendors (Apple with "apns" key and Google with 
                    "gcm").
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param block       Publish processing completion block which pass only one argument - request processing 
                    status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)    publish:(nullable id)message toChannel:(NSString *)channel
  mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
     withCompletion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:mobilePushPayload:storeInHistory:withCompletion: and allow to 
             specify metadata payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
   mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} storeInHistory:YES
        withMetadata:@{@"to":@"John Doe"} completion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                    which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param payloads    Dictionary with payloads for different vendors (Apple with "apns" key and Google with 
                    "gcm").
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param metadata    \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block       Publish processing completion block which pass only one argument - request processing 
                    status to report about how data pushing was successful or not.
 
 @since 4.3.0
 */
- (void)    publish:(nullable id)message toChannel:(NSString *)channel
  mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
       withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
         completion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:mobilePushPayload:storeInHistory:withCompletion: and allow to 
             specify whether message itself should be compressed or not. Only message will be compressed and 
             \c payloads will be kept in JSON string format.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
   mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} storeInHistory:YES compressed:NO
      withCompletion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode

 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                    which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param payloads    Dictionary with payloads for different vendors (Apple with "apns" key and Google with 
                    "gcm").
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param compressed  Compression useful in case if large data should be published, in another case it will lead
                    to packet size grow.
 @param block       Publish processing completion block which pass only one argument - request processing 
                    status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)    publish:(nullable id)message toChannel:(NSString *)channel
  mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
         compressed:(BOOL)compressed withCompletion:(nullable PNPublishCompletionBlock)block;

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 @discussion Extension to \c -publish:toChannel:mobilePushPayload:storeInHistory:compressed:withCompletion: 
             and allow to specify metadata payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client publish:@{@"Hello":@"world"} toChannel:@"announcement"
   mobilePushPayload:@{@"apns":@{@"alert":@"Hello from PubNub"}} storeInHistory:YES compressed:NO
        withMetadata:@{@"to":@"John Doe"} completion:^(PNPublishStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Message successfully published to specified channel.
    }
    // Request processing failed.
    else {
    
        // Handle message publish error. Check 'category' property to find out possible issue 
        // because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode

 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                    which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param payloads    Dictionary with payloads for different vendors (Apple with "apns" key and Google with 
                    "gcm").
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param compressed  Compression useful in case if large data should be published, in another case it will lead
                    to packet size grow.
 @param metadata    \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block       Publish processing completion block which pass only one argument - request processing 
                    status to report about how data pushing was successful or not.

 @since 4.3.0
 */
- (void)    publish:(nullable id)message toChannel:(NSString *)channel
  mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
         compressed:(BOOL)compressed withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
         completion:(nullable PNPublishCompletionBlock)block;


///------------------------------------------------
/// @name Message helper
///------------------------------------------------

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to \b PubNub 
             network.
 @note       Size calculation use percent-escaped \c message and all added headers to get full size.
 @discussion \b Example:
 
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
 @param block   Reference on block which should be sent, when message size calculation will be completed.
 
 @since 4.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to \b PubNub 
             network.
 @note       Size calculation use percent-escaped \c message and all added headers to get full size.
 @discussion Extension to \c -sizeOfMessage:toChannel:withCompletion: and allow to specify metadata payload 
             which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client sizeOfMessage:@{@"Hello":@"world"} toChannel:@"announcement"
              withMetadata:@{@"to":@"John Doe"} completion:^(NSInteger size) {

    // Actual message size is: size
}];
 @endcode
 
 @param message  Message for which size should be calculated.
 @param channel  Name of the channel to which message should be sent (it is part of request URI).
 @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block    Reference on block which should be sent, when message size calculation will be completed.
 
 @since 4.3.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel 
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to \b PubNub 
             network.
 @note       Size calculation use percent-escaped \c message and all added headers to get full size.
 @discussion Extension to \c -sizeOfMessage:toChannel:withCompletion: and specify whether message should be 
             compressed or not.
 @discussion \b Example:
 
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
 @param channel         Name of the channel to which message should be sent (it is part of request URI).
 @param compressMessage \c YES in case if message should be compressed before sending to \b PubNub network.
 @param block           Reference on block which should be sent, when message size calculation will be 
                        completed.
 
 @since 4.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to \b PubNub
             network.
 @note       Size calculation use percent-escaped \c message and all added headers to get full size.
 @discussion Extension to \c -sizeOfMessage:toChannel:compressed:withCompletion: and allow to specify metadata 
             payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client sizeOfMessage:@{@"Hello":@"world"} toChannel:@"announcement" compressed:YES
              withMetadata:@{@"to":@"John Doe"} completion:^(NSInteger size) {

    // Actual message size is: size
}];
 @endcode
 
 @param message         Message for which size should be calculated.
 @param channel         Name of the channel to which message should be sent (it is part of request URI).
 @param compressMessage \c YES in case if message should be compressed before sending to \b PubNub network.
 @param metadata        \b NSDictionary with values which should be used by \b PubNub service to filter
                        messages.
 @param block           Reference on block which should be sent, when message size calculation will be 
                        completed.
 
 @since 4.3.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata 
           completion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to \b PubNub 
             network.
 @note       Size calculation use percent-escaped \c message and all added headers to get full size.
 @discussion Extension to \c -sizeOfMessage:toChannel:withCompletion: and specify whether message should be 
             stored in history or not.
 @discussion \b Example:
 
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
 @param block       Reference on block which should be sent, when message size calculation will be completed.
 
 @since 4.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to \b PubNub 
             network.
 @note       Size calculation use percent-escaped \c message and all added headers to get full size.
 @discussion Extension to \c -sizeOfMessage:toChannel:storeInHistory:withCompletion: and allow to specify 
             metadata payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client sizeOfMessage:@{@"Hello":@"world"} toChannel:@"announcement" storeInHistory:NO
              withMetadata:@{@"to":@"John Doe"} completion:^(NSInteger size) {

    // Actual message size is: size
}];
 @endcode
 
 @param message     Message for which size should be calculated.
 @param channel     Name of the channel to which message should be sent (it is part of request URI).
 @param shouldStore \c YES in case if message should be placed into history storage.
 @param metadata    \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block       Reference on block which should be sent, when message size calculation will be completed.
 
 @since 4.3.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata 
           completion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to \b PubNub 
             network.
 @note       Size calculation use percent-escaped \c message and all added headers to get full size.
 @discussion Extension to \c -sizeOfMessage:toChannel:compressed:withCompletion: and specify whether message 
             should be stored in history or not.
 @discussion \b Example:
 
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
 @param channel         Name of the channel to which message should be sent (it is part of request URI).
 @param compressMessage \c YES in case if message should be compressed before sending to \b PubNub network.
 @param shouldStore     \c NO in case if message shouldn't be available after it has been sent via history 
                        storage API methods group.
 @param block           Reference on block which should be sent, when message size calculation will be
                        completed.
 
 @since 4.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore withCompletion:(PNMessageSizeCalculationCompletionBlock)block;

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to \b PubNub 
             network.
 @note       Size calculation use percent-escaped \c message and all added headers to get full size.
 @discussion Extension to \c -sizeOfMessage:toChannel:compressed:storeInHistory:withCompletion: and allow to 
             specify metadata payload which will should be sent along with message.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client sizeOfMessage:@{@"Hello":@"world"} toChannel:@"announcement" compressed:NO 
            storeInHistory:NO withMetadata:@{@"to":@"John Doe"} completion:^(NSInteger size) {

    // Actual message size is: size
}];
 @endcode
 
 @param message         Message for which size should be calculated.
 @param channel         Name of the channel to which message should be sent (it is part of request URI).
 @param compressMessage \c YES in case if message should be compressed before sending to \b PubNub network.
 @param shouldStore     \c NO in case if message shouldn't be available after it has been sent via history
                        storage API methods group.
 @param metadata        \b NSDictionary with values which should be used by \b PubNub service to filter 
                        messages.
 @param block           Reference on block which should be sent, when message size calculation will be 
                        completed.
 
 @since 4.3.0
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
