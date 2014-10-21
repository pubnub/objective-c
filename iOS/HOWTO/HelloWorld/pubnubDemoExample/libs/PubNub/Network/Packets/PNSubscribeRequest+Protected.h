//
//  PNSubscribeRequest+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov.
//
//

#import "PNSubscribeRequest.h"


#pragma mark Protected interface methods

@interface PNSubscribeRequest (Protected)


#pragma mark - Properties

// Stores whether leave request was sent to subscribe on new channels or as result of user request
@property (nonatomic, assign, getter = isSendingByUserRequest) BOOL sendingByUserRequest;

// Stores reference on list of channels for which presence should be enabled/disabled
@property (nonatomic, strong) NSArray *channelsForPresenceEnabling;
@property (nonatomic, strong) NSArray *channelsForPresenceDisabling;

/**
 Stores user-provided state which should be appended to the client subscription.
 */
@property (nonatomic, strong) NSDictionary *state;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatTimeout;
@property (nonatomic, copy) NSString *subscriptionKey;


#pragma mark - Instance methods

/**
 Retrieve list of channels on which subscribe should subscribe or update timetoken (w/o presence channels).
 
 @return \b PNChannels list
 */
- (NSArray *)channelsForSubscription;

- (void)resetSubscriptionTimeToken;

/**
 * Allow to reset time token on each of channel which should be used for subscription
 */
- (void)resetTimeToken;
- (void)resetTimeTokenTo:(NSString *)timeToken;

#pragma mark -


@end
