//
//  PNChannelGroupChange+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupChange.h"


#pragma mark Protected interface declaration

@interface PNChannelGroupChange ()


#pragma mark - Properties

@property (nonatomic, strong) PNChannelGroup *group;
@property (nonatomic, assign) BOOL addingChannels;
@property (nonatomic, strong) NSArray *channels;


#pragma mark - Class methods

/**
 Construct group channels list change descriptor.
 
 @param group
 Reference on gruop for which modification should be done
 
 @param channels
 Reference on \a NSArray list of \b PNChannel instances which will be used for modification
 
 @param addingChannels
 Whether channels used for addition into the group or not.
 
 @return Ready to use \b PNChannelGroupChange instance.
 */
+ (PNChannelGroupChange *)changeForGroup:(PNChannelGroup *)group channels:(NSArray *)channels addingChannels:(BOOL)addingChannels;


#pragma mark - Instance methods

/**
 Initialize group channels list change descriptor.
 
 @param group
 Reference on gruop for which modification should be done
 
 @param channels
 Reference on \a NSArray list of \b PNChannel instances which will be used for modification
 
 @param addingChannels
 Whether channels used for addition into the group or not.
 
 @return Ready to use \b PNChannelGroupChange instance.
 */
- (id)initWithGroup:(PNChannelGroup *)group withChannels:(NSArray *)channels addingChannels:(BOOL)addingChannels;

#pragma mark -


@end
