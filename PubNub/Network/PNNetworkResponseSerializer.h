#import <Foundation/Foundation.h>


#pragma mark Externs

/**
 @brief  Key used to store service response in case of request processing error.
 
 @since 4.0.2
 */
extern NSString * const kPNNetworkErrorResponseDataKey;


/**
 @brief      Class which is used by network manager to serialize responses from \b PubNub Network.
 
 @author Sergey Mamontov
 @since 4.0.2
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNNetworkResponseSerializer : NSObject


///------------------------------------------------
/// @name Serialization
///------------------------------------------------

/**
 @brief      Serialize service response taking into account metadata.
 @discussion This method used to extract Foundation object from service response if possible. In 
             other cases error will be passed.
 
 @param response Reference on HTTP response object which has metadata which should be used in
                 pre-processing to identify whether body should be processed or not.
 
 @since 4.0.2
 */
- (id)serializedResponse:(NSHTTPURLResponse *)response withData:(NSData *)data
                   error:(NSError **)serializationError;

#pragma mark -


@end
