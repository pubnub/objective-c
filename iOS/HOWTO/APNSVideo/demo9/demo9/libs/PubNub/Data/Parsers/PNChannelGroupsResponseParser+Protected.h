//
//  PNChannelGroupsResponseParser_Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupsResponseParser.h"


#pragma mark Static

/**
 @brief Reference on key under which target namespace is stored
 
 @since 3.7.0
 */
static NSString * const kPNResponseNamespaceKey = @"namespace";

/**
 @brief Reference on key under which stored list of channel groups registered under target namespace.
 
 @since 3.7.0
 */
static NSString * const kPNResponseChannelGroupsKey = @"groups";


#pragma mark - Private interface declaration

@interface PNChannelGroupsResponseParser ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *channelGroups;

#pragma mark -


@end
