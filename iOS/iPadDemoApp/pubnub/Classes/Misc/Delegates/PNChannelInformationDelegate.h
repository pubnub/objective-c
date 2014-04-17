//
//  PNChannelInformationDelegate.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#pragma mark Class forward

@class PNChannelInformationView;


#pragma mark Protocol interface declaration

@protocol PNChannelInformationDelegate <NSObject>


@required

/**
 Called on delegate when user ended manipulation with concrete channel state and data.
 
 @param informationView
 Reference on \b PNChannelInformationView instance which has been used for channel information view and change.
 
 @param channel
 Reference on \b PNChannel instance for which information has been viewed / changed or it can be reference on newly
 created \b PNChannel instance (in case when user add list of channels for usage in one of endpoints).
 
 @param channelState
 Reference on \b NSDictionary which described client's state when subscribed on specified channel.
 
 @param shouldObservePresence
 Whether channel is made to observer presence observation.
 */
- (void)channelInformation:(PNChannelInformationView *)informationView didEndEditingChanne:(PNChannel *)channel
                 withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObserverPresence;

#pragma mark -


@end
