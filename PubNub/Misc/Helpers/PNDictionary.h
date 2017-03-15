#import <Foundation/Foundation.h>


/**
 @brief  Useful NSDictionary additions collection.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNDictionary : NSObject


///------------------------------------------------
/// @name URL helper
///------------------------------------------------

/**
 @brief  Encode provided \c dictionary to string which can be used with reuests.
 
 @param dictionary Dictionary which should be encoded.
 
 @return Joined string with percent-escaped kevy values.
 
 @since 4.0
 */
+ (NSString *)queryStringFrom:(NSDictionary *)dictionary;

#pragma mark -


@end
