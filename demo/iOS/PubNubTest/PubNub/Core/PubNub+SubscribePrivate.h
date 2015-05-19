/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Subscribe.h"


#pragma mark Private interface declaration

@interface PubNub (SubscribePrivate)


#pragma mark - Subscription

/**
 @brief  Try restore subscription cycle by using \b 0 time token and if required try to catch up on
         previous subscribe time token (basing on user configuration).
 
 @since 4.0
 */
- (void)restoreSubscriptionCycleIfRequired;

#pragma mark -


@end
