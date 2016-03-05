#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Useful NSData additions collection.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNData : NSObject


///------------------------------------------------
/// @name Convertion
///------------------------------------------------

/**
 @brief  Convert data bytes from \c data to HEX string.
 
 @param data Reference on data who's content should be provided in HEX format.
 
 @return HEX string containing \c data body.
 
 @since 4.0
 */
+ (NSString *)HEXFrom:(NSData *)data;

/**
 @brief  Convert data bytes from \c data to HEX string.
 
 @param data Reference on data who's content should be provided in HEX format.
 
 @return HEX string containing \c data body.
 
 @since 4.0
 */
+ (NSString *)HEXFromDevicePushToken:(NSData *)data;

/**
 @brief      Convert \c data's content to base64-encoded string.
 @discussion This is shortcut to [... base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0]
             method.
 
 @param data Reference on data which should be converted to base64-encoded string.
 
 @return Base64-encoded string.
 
 @since 4.0
 */
+ (NSString *)base64StringFrom:(NSData *)data;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
