//
//  PNSubscribeRequest.h
//  pubnub
//
//  This request object is used to describe
//  channel(s) subscription request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannel;


@interface PNSubscribeRequest : PNBaseRequest


#pragma mark - Properties

// Stores reference on list of channels on which client should subscribe
@property (nonatomic, readonly, strong) NSArray *channels;

// Stores reference on list of channels for which presence should be enabled/disabled
@property (nonatomic, readonly, strong) NSArray *channelsForPresenceEnabling;
@property (nonatomic, readonly, strong) NSArray *channelsForPresenceDisabling;


#pragma mark - Class methods

<<<<<<< HEAD
+ (PNSubscribeRequest *)subscribeRequestForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest
                                   withClientState:(NSDictionary *)clientState;
+ (PNSubscribeRequest *)subscribeRequestForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest
                                    withClientState:(NSDictionary *)clientState;
=======
+ (PNSubscribeRequest *)subscribeRequestForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest;
+ (PNSubscribeRequest *)subscribeRequestForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest;
>>>>>>> fix-pt65153600


#pragma mark - Instance methods

<<<<<<< HEAD
- (id)initForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest withClientState:(NSDictionary *)clientState;
- (id)initForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest withClientState:(NSDictionary *)clientState;
=======
- (id)initForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest;
- (id)initForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest;
>>>>>>> fix-pt65153600

/**
 * Check whether this is initial subscription request which will mean that it's update time token is '0'
 * and client is waiting for updated time token
 */
- (BOOL)isInitialSubscription;

@end
