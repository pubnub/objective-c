//
//  PNReachability+Time.h
//  pubnub
//
//  Created by Valentin Tuller on 10/30/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "PNResponseParser.h"
#import "PubNub+Protected.h"
#import "PNConstants.h"
#import "PNResponse.h"
#import <netinet/in.h>
#import <arpa/inet.h>

@interface PNReachability (Time)

+ (SCNetworkReachabilityRef)newReachabilityForWiFi:(BOOL)wifiReachability;


@end
