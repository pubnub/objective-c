#import <Foundation/Foundation.h>


/**
 @brief  Useful JSON manipulation methods collection.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNJSON : NSObject


///------------------------------------------------
/// @name Serialization
///------------------------------------------------

/**
 @brief      Serialize passed object to JSON string which meet with \b PubNub service requirements.
 @discussion \b PubNub service can accept not only JSON objects where root is collections but also
             plain strings and numbers. This helper will pre-process non-collection objects and 
             serialize them into required format.
 
 @param object Reference on Foundation object which should be serialized to JSON string.
 @param error  Reference on pointer into which JSON serialization error will be stored in case of
               error.
 
 @return JSON string which meet \b PubNub service requirements or \c nil in case if object can't be
         serialized to JSON object.
 
 @since 4.0
 */
+ (NSString *)JSONStringFrom:(id)object withError:(NSError *__autoreleasing *)error;


///------------------------------------------------
/// @name De-serialization
///------------------------------------------------

/**
 @brief      Deserialize passed JSON string from \b PubNub service to Foundation object.
 @discussion Because \b PubNub service can accept not only JSON with collection as root but also
             plain strings and numbers this step require additional pre-processing.
 
 @param object Reference on object which should be deserialized to Foundation object.
 @param error  Reference on pointer into which JSON deserialization error will be stored in case of
               error.
 
 @return Foundation object or \c nil in case if object can't be deserialized to JSON object.
 
 @since 4.0
 */
+ (id)JSONObjectFrom:(NSString *)object withError:(NSError *__autoreleasing *)error;


///------------------------------------------------
/// @name Validation
///------------------------------------------------

/**
 @brief      Allow to perform trivial check whether provided \c object already JSON encoded string
             or not.
 @discussion Basically this method ensures what \c object is string and startin and ending 
             characters correspond to expected from JSON string.
 
 @param object Object against which check should be done.
 
 @return \c YES in case if provided \c object responds to \b PubNub service requirements for JSON
         string.
 
 @since 4.0
 */
+ (BOOL)isJSONString:(id)object;

@end
