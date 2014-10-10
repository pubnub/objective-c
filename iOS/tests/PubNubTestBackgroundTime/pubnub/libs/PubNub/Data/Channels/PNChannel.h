//
//  PNChannel.h
//  pubnub
//
//  Represents object which is used to subscribe
//  for channels and presence.
//
//
//  Created by Sergey Mamontov on 12/11/12.
//
//

#import <Foundation/Foundation.h>
#import "PNChannelProtocol.h"


#pragma mark Class forward

@class PNDate;


#pragma mark - Public interface declaration

@interface PNChannel : NSObject <PNChannelProtocol>


#pragma mark - Class methods

/**
 * Returns array of channels which has same names as provided in array
 */
+ (NSArray *)channelsWithNames:(NSArray *)channelsName;

/**
 * Retrieve configured channel instance with specified name (if name already was used during client connection session
 * when instance will be pulled out from cache). Channel presence observation won't be created.
 * WARNING: use only this method to operate with channels (if you don't want to store reference on it)
 */
+ (id)channelWithName:(NSString *)channelName;

/**
 * Channel instance will be retrieved with same logic which described in +channelWithName: method but additional
 * parameter allow to mark whether presence observing should be added on this channel or not
 */
+ (id)channelWithName:(NSString *)channelName shouldObservePresence:(BOOL)observePresence;

#pragma mark -


@end
