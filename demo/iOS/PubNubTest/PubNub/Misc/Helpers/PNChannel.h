#import <Foundation/Foundation.h>


/**
 @brief  Useful collection of methods which make it easrier to work with set of channels, groups and
         presence channels.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNChannel : NSObject


///------------------------------------------------
/// @name Lists encoding
///------------------------------------------------

/**
 @brief      Convert provided list of objects to comma-joined string where evert entry 
             percent-escaped.
 @discussion This method simplify object names list preparation for use in reuqets path and queries.
 
 @param names List of object names which should be joined into single string.
 
 @return Joined percent-escaped string.
 
 @since 4.0
 */
+ (NSString *)namesForRequest:(NSArray *)names;

/**
 @brief      Convert provided list of objects to comma-joined string where evert entry 
             percent-escaped.
 @discussion This method simplify object names list preparation for use in reuqets path and queries.
 
 @code
 @endcode
 Extension to \c -namesForRequest: which allow to specify default value in case if passed array is
 empty.
 
 @param names         List of object names which should be joined into single string.
 @param defaultString String which will be returned in case if joined string length is equal to 
                      \b 0.
 
 @return Joined percent-escaped string.
 
 @since 4.0
 */
+ (NSString *)namesForRequest:(NSArray *)names defaultString:(NSString *)defaultString;

#pragma mark -


@end
