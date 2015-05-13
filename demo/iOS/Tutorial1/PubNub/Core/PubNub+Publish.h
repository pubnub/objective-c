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
 
 @param message Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, 
                \a NSDictionary) which will be published.
 @param channel Reference on name of the channel to which message should be published.
 @param block   Publish processing completion block which pass two arguments: \c result - in case of
                successful request processing \c data field will contain results of message publish 
                operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel
 withCompletion:(PNCompletionBlock)block;

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

 @param message    Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                   \a NSDictionary) which will be published.
 @param channel    Reference on name of the channel to which message should be published.
 @param compressed Whether message should be compressed and sent with request body instead of URI
                   part.
 @param block      Publish processing completion block which pass two arguments: \c result - in case
                   of successful request processing \c data field will contain results of message 
                   publish operation; \c status - in case if error occurred during request 
                   processing.

 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed
 withCompletion:(PNCompletionBlock)block;

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
 
 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                    \a NSDictionary) which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param block       Publish processing completion block which pass two arguments: \c result - in 
                    case of successful request processing \c data field will contain results of 
                    message publish operation; \c status - in case if error occurred during request 
                    processing.
 
 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
 withCompletion:(PNCompletionBlock)block;

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

 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                    \a NSDictionary) which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param compressed  Whether message should be compressed and sent with request body instead of URI
                    part.
 @param block       Publish processing completion block which pass two arguments: \c result - in 
                    case of successful request processing \c data field will contain results of
                    message publish operation; \c status - in case if error occurred during request 
                    processing.

 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
     compressed:(BOOL)compressed withCompletion:(PNCompletionBlock)block;


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
 
 @param message  Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                 \a NSDictionary) which will be published.
 @param channel  Reference on name of the channel to which message should be published.
 @param payloads Dictionary with payloads for different vendors (Apple with "apns" key and Google
                 with "gcm").
 @param block    Publish processing completion block which pass two arguments: \c result - in case 
                 of successful request processing \c data field will contain results of message 
                 publish operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads withCompletion:(PNCompletionBlock)block;

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

 @param message    Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                   \a NSDictionary) which will be published.
 @param channel    Reference on name of the channel to which message should be published.
 @param payloads   Dictionary with payloads for different vendors (Apple with "apns" key and Google
                   with "gcm").
 @param compressed Whether message should be compressed and sent with request body instead of URI
                   part.
 @param block      Publish processing completion block which pass two arguments: \c result - in case
                   of successful request processing \c data field will contain results of message 
                   publish operation; \c status - in case if error occurred during request 
                   processing.

 @since 4.0
 */
- (void)publish:(id)message toChannel:(NSString *)channel mobilePushPayload:(NSDictionary *)payloads
     compressed:(BOOL)compressed withCompletion:(PNCompletionBlock)block;

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
 
 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                    \a NSDictionary) which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param payloads    Dictionary with payloads for different vendors (Apple with "apns" key and Google 
                    with "gcm").
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param block       Publish processing completion block which pass two arguments: \c result - in 
                    case of successful request processing \c data field will contain results of 
                    message publish operation; \c status - in case if error occurred during request 
                    processing.
 
 @since 4.0
 */
- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
     withCompletion:(PNCompletionBlock)block;

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

 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray,
                    \a NSDictionary) which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param payloads    Dictionary with payloads for different vendors (Apple with "apns" key and Google
                    with "gcm").
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param compressed  Whether message should be compressed and sent with request body instead of URI
                    part.
 @param block       Publish processing completion block which pass two arguments: \c result - in 
                    case of successful request processing \c data field will contain results of 
                    message publish operation; \c status - in case if error occurred during request 
                    processing.

 @since 4.0
 */
- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
         compressed:(BOOL)compressed withCompletion:(PNCompletionBlock)block;

#pragma mark -


@end
