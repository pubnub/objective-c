/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Presence.h"


#pragma mark Private interface declaration

@interface PubNub (PresencePrivate)

/**
 @brief      Issue heartbeat request to \b PubNub network.
 @discussion Heartbeat help \b PubNub presence service to control subscribers availability.
 
 @param block Reference on block which should be called with service information.
 
 @since 4.0
 */
- (void)heartbeatWithCompletion:(PNStatusBlock)block;

#pragma mark -


@end
