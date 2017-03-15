#import <Foundation/Foundation.h>


/**
 @brief  Useful NSNumber additions collection.
 
 @author Sergey Mamontov
 @since 4.2.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNNumber : NSObject


///------------------------------------------------
/// @name Conversion
///------------------------------------------------

/**
 @brief  Construct time token object which has higher precision and can be used inside of \b PubNub service 
         during requests.
 
 @param number Reference on original number which should be normalized and returned with new object.
 
 @return Normalized to \b PunNub service time token.
 
 @since 4.2.0
 */
+ (NSNumber *)timeTokenFromNumber:(NSNumber *)number;

#pragma mark -


@end
