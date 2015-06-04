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
 @brief      Convert provided list of data objects to comma-joined string where evert entry
             percent-escaped.
 @discussion This method simplify data object names list preparation for use in request path and
             queries.
 
 @param names List of data object names which should be joined into single string.
 
 @return Joined percent-escaped string.
 
 @since 4.0
 */
+ (NSString *)namesForRequest:(NSArray *)names;

/**
 @brief      Convert provided list of data objects to comma-joined string where evert entry
             percent-escaped.
 @discussion This method simplify data object names list preparation for use in reuqets path and
             queries.
 
 @code
 @endcode
 Extension to \c -namesForRequest: which allow to specify default value in case if passed array is
 empty.
 
 @param names         List of data object names which should be joined into single string.
 @param defaultString String which will be returned in case if joined string length is equal to 
                      \b 0.
 
 @return Joined percent-escaped string.
 
 @since 4.0
 */
+ (NSString *)namesForRequest:(NSArray *)names defaultString:(NSString *)defaultString;


///------------------------------------------------
/// @name Lists decoding
///------------------------------------------------

/**
 @brief      Convert provided response string with list of data object names back to array dividing
             it by default delimiter..
 @discussion This method simplify data object names list pull from response piece..

 @param response Piece of response which hold list of data object names for processing.

 @return Comma-separated list of data object names.

 @since 4.0
 */
+ (NSArray *)namesFromRequest:(NSString *)response;


///------------------------------------------------
/// @name Subscriber helper
///------------------------------------------------

/**
 @brief  Check whether passed object represence presence event feed or not.
 
 @param object Reference on name of the object against which check should be done.
 
 @return \c NO in case if passed object represent non-presence object.
 
 @since 4.0
 */
+ (BOOL)isPresenceObject:(NSString *)object;

/**
 @brief  Construct name of the channel from it's presence channel name.
 
 @param presenceChannel Reference on presence channel which should be used for construction.
 
 @return Regular channel name.
 
 @since 4.0
 */
+ (NSString *)channelForPresence:(NSString *)presenceChannel;

/**
 @brief  Convert provided list of \c names to names which correspond to presence objects naming 
         conventions.
 
 @param names List of names which should be converted.
 
 @return List of names which correspond to requirements of presence \b PubNub service.
 
 @since 4.0
 */
+ (NSArray *)presenceChannelsFrom:(NSArray *)names;

/**
 @brief  Filter provided mixed list of channels/groups and presence channels/groups to list w/o 
         presence channels in it.
 
 @param names List of names which should be filtered.
 
 @return Filtered channels list.
 
 @since 4.0
 */
+ (NSArray *)objectsWithOutPresenceFrom:(NSArray *)names;

#pragma mark -


@end
