//
//  PNChannelPresence.m
//  pubnub
//
//  Object used to describe presence for
//  specific channel.
//  This is basically channel, but it will
//  apply some rules to his name which will
//  allow him to observer presence on specific
//  channel.
//
//
//  Created by Sergey Mamontov.
//
//

#import "PNChannelPresence+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel presence must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Public interface methods

@implementation PNChannelPresence


#pragma mark - Class methods

/**
 * Retrieve configured presence observing object
 * for specified channel
 */
+ (PNChannelPresence *)presenceForChannel:(PNChannel *)channel {

    NSString *channelName = channel.name;
    if (![channelName hasSuffix:kPNPresenceObserverChannelSuffix]) {

        channelName = [channelName stringByAppendingString:kPNPresenceObserverChannelSuffix];
    }


    return [super channelWithName:channelName shouldObservePresence:NO];
}

+ (PNChannelPresence *)presenceForChannelWithName:(NSString *)channelName {

    if (![channelName hasSuffix:kPNPresenceObserverChannelSuffix]) {

        channelName = [channelName stringByAppendingString:kPNPresenceObserverChannelSuffix];
    }


    return [super channelWithName:channelName shouldObservePresence:NO];
}

+ (BOOL)isPresenceObservingChannelName:(NSString *)channelName {

    return [channelName hasSuffix:kPNPresenceObserverChannelSuffix];
}


#pragma mark - Instance methods

- (PNChannel *)observedChannel {

    return [PNChannel channelWithName:[self.name stringByReplacingOccurrencesOfString:kPNPresenceObserverChannelSuffix
                                                                           withString:@""]];
}

- (BOOL)isPresenceObserver {

    return YES;
}

#pragma mark -


@end
