//
//  PNChannelGroupNamespacesResponseParser+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupNamespacesResponseParser.h"


#pragma mark Static

/**
 @brief Reference on key under which application subscription key should be stored
 
 @since 3.7.0
 */
static NSString * const kPNResponseSubscriptionKey = @"sub_key";

/**
 @brief Reference on key under which stored list of namespaces registered under application subscription key.
 
 @since 3.7.0
 */
static NSString * const kPNResponseNamespacesKey = @"namespaces";


#pragma mark - Private interface declaration

@interface PNChannelGroupNamespacesResponseParser ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *namespaces;

#pragma mark -


@end
