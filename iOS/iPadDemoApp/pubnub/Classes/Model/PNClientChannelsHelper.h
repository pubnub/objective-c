//
//  PNClientChannelsHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/2/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNClientChannelsHelper : NSObject


#pragma mark - Properties

/**
 Stores reference on client identifier for which list of channels should be pulled out.
 */
@property (nonatomic, copy) NSString *clientIdentifier;


#pragma mark - Instance methods

/**
 Verify whether helper has all required information for request or not.
 
 @return \c NO in case if user provided empty client's identifier.
 */
- (BOOL)isAbleToProcessRequest;

/**
 Channels on which client subscribed at this moment.
 
 @return List of \b PNChannel instances which represent channels on which specified client subscribed at this moment.
 */
- (NSArray *)channels;

/**
 Perform client channel fetch request with completion block.
 
 @param handlerBlock
 Block which will be called by \b PubNub client during request processing. Block pass three parameters: identifier (for
 which request has been made; list of channels and error instance).
 */
- (void)performRequestWithBlock:(PNClientParticipantChannelsHandlingBlock)handlerBlock;

#pragma mark -


@end
