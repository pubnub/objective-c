/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PNChannelGroupNamespace.h"


#pragma mark - Public interface implementation

@implementation PNChannelGroupNamespace


#pragma mark - Class methods

+ (PNChannelGroupNamespace *)allNamespaces {
    
    return [self namespaceWithName:@":"];
}

+ (PNChannelGroupNamespace *)namespaceWithName:(NSString *)name {
    
    return (PNChannelGroupNamespace *)[self channelGroupWithName:nil inNamespace:name shouldObservePresence:NO];
}

#pragma mark -


@end
