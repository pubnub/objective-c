#import <Foundation/Foundation.h>


/**
 @brief  Useful Class additions collection.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNClass : NSObject


///------------------------------------------------
/// @name Class filtering
///------------------------------------------------

/**
 @brief  Gather list of classes which conform to specified \c protocol.
 
 @param protocol Reference on protocol for which list of classes should be gathered.
 
 @return Classes which conform to \c protocol.
 
 @since 4.0
 */
+ (NSArray *)classesConformingToProtocol:(Protocol*)protocol;

/**
 @brief  Gather list of classes who's instance is able to respond to \c selector.
 
 @param selector SEL for which check should be done.
 
 @return Classes who's instance is able to respond to \c selector.
 
 @since 4.0
 */
+ (NSArray *)classesRespondingToSelector:(SEL)selector;


#pragma mark -


@end
