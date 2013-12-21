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


#pragma mark - Instance methods

/**
 * Allow to reset time token on each of channel which should be used for subscription
 */
 - (void)resetTimeToken;
 - (void)resetTimeTokenTo:(NSString *)timeToken;

#pragma mark -


@end
