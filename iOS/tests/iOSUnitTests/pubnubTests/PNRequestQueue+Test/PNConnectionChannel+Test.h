//
//  PNConnectionChannel+Test.h
//  pubnub
//
//  Created by Valentin Tuller on 2/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNConnectionChannel.h"

@interface PNConnectionChannel (Test)

@property (nonatomic, strong) NSMutableDictionary *observedRequests;

// Stores reference on all requests which was required to be stored because of some reasons (for example re-schedule
// request in case of error)
@property (nonatomic, strong) NSMutableDictionary *storedRequests;

// Stores list of identifiers from requests which has been sent and waiting for response
// (request objects is stored inside 'storedRequests' and can be accessed with keys from this array)
@property (nonatomic, strong) NSMutableArray *storedRequestsList;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) PNRequestsQueue *requestsQueue;

@end
