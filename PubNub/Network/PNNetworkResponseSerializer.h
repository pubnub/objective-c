#import <Foundation/Foundation.h>


#pragma mark Externs

/**
 * @brief Key used to store service response in case of request processing error.
 */
extern NSString * _Nonnull const kPNNetworkErrorResponseDataKey;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class which is used by network manager to serialise responses from \b PubNub Network.
 *
 * @author Serhii Mamontov
 * @version 4.15.6
 * @since 4.0.2
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNNetworkResponseSerializer : NSObject


#pragma mark - Serialisation

/**
 * @brief Serialise service response taking into account metadata.
 *
 * @discussion This method used to extract Foundation object from service response if possible. In other cases
 * error will be passed.
 *
 * @param response Reference on HTTP response object which has metadata which should be used in
 *   pre-processing to identify whether body should be processed or not.
 * @param data Binary information which has been provided by service.
 * @param serializationError Pointer to variable which will store service response serialisation error.
 *
 * @return Serialised service response (parsed JSON).
 */
- (id)serializedResponse:(NSHTTPURLResponse *)response
                withData:(NSData *)data
                   error:(NSError *__autoreleasing *)serializationError;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
