//
//  PNChannelGroupChange.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNChannelGroup;


#pragma mark - Public interface delcaration

@interface PNChannelGroupChange : NSObject


#pragma mark - Properties

/**
 Stores reference on channel group for which modification has been performed.
 */
@property (nonatomic, readonly, strong) PNChannelGroup *group;

/**
 Stores whether adding channels to the group or not
 */
@property (nonatomic, readonly, assign) BOOL addingChannels;

/**
 Stores reference on list of channels which should be used during channel group modification.
 */
@property (nonatomic, readonly, strong) NSArray *channels;

#pragma mark -


@end
