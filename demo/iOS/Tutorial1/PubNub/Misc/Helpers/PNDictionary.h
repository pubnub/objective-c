#import <Foundation/Foundation.h>


/**
 @brief  Useful NSDictionary additions collection.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNDictionary : NSObject


///------------------------------------------------
/// @name API helper
///------------------------------------------------

/**
 @brief  Check whether specified dictionary has flattened structure or not.
 @discussion Flattened - mean what there is no nested objects stored for keys.

 @param dictionary Reference on dictionary against which check should be done.

 @return \c YES in case if there is collection instance stored inside of dictionary.

 @since 4.0
 */
+ (BOOL)hasFlattenedContent:(NSDictionary *)dictionary;


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
