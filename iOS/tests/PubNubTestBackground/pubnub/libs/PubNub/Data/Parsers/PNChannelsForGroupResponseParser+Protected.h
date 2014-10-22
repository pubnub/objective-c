//
//  PNChannelsForGroupResponseParser_Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 10/10/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelsForGroupResponseParser.h"


#pragma mark Static

/**
 @brief Reference on key under which list of channel group channels is stored
 
 @since 3.7.0
 */
static NSString * const kPNResponseChanelsKey = @"channels";


#pragma mark - Private interface declaration

@interface PNChannelsForGroupResponseParser ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *channels;

#pragma mark -


@end
