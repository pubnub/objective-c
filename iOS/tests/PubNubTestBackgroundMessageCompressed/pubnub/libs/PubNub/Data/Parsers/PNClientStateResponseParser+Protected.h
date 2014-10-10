//
//  PNClientStateResponseParser+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 10/2/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientStateResponseParser.h"


#pragma mark Static

/**
 @brief Reference on key under which stored client's state for each channel of channel group
 
 @since 3.6.9
 */
static NSString * const kPNResponseChannelsKey = @"channels";


#pragma mark - Private interface declaration

@interface PNClientStateResponseParser ()


#pragma mark - Properties

/**
 @brief Stores referece on client for which state has been received or updated
 
 @since 3.6.9
 */
@property (nonatomic, strong) PNClient *client;

#pragma mark -


@end
