//
//  PNMessageHistoryRequest+Protected.h
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


#import "PNMessageHistoryRequest.h"


#pragma mark Protected interface implementation

@interface PNMessageHistoryRequest (Protected)


#pragma mark - Properties

// Stores reference on channel for which history should
// be pulled out
@property (nonatomic, readonly, strong) PNChannel *channel;

// Stores reference on history time frame start/end dates (time tokens)
@property (nonatomic, readonly, strong) PNDate *startDate;
@property (nonatomic, readonly, strong) PNDate *endDate;

// Stores reference on maximum number of messages which
// should be returned from backend
@property (nonatomic, readonly, assign) NSUInteger limit;

// Stores reference on whether messages should revert
// their order in response or not
@property (nonatomic, readonly, assign, getter = shouldRevertMessages) BOOL revertMessages;

/**
 Stores whether response should include messages times stamp or not.
 */
@property (nonatomic, readonly, assign, getter = shouldIncludeTimeToken) BOOL includeTimeToken;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

#pragma mark -


@end
