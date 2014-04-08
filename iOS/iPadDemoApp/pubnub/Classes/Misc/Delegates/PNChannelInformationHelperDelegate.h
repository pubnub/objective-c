//
//  PNChannelInformationHelperDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/22/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Delegate methods declaration

@protocol PNChannelInformationHelperDelegate <NSObject>


@required

/**
 Called on delegate each time when channel name is changed.
 */
- (void)channelNameDidChange;

/**
 Called on delegate each time when some channel information field changed.
 */
- (void)channelInformationDidChange;


#pragma mark -


@end
