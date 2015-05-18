/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Subscribe.h"


#pragma mark Private interface declaration

@interface PubNub (SubscribePrivate)


#pragma mark - Subscription information modification

/**
 @brief  Retrieve stored current subscription time token information.
 
 @return Cached current time token information or \b 0 if requested for first time.
 
 @since 4.0
 */
- (NSNumber *)currentTimeToken;

/**
 @brief  Retrieve stored previous subscription time token information.
 
 @return Cached previuos time token information or \b 0 if requested for first time.
 
 @since 4.0
 */
- (NSNumber *)previousTimeToken;

#pragma mark -


@end
