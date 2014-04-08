//
//  PNGlobalPresenceHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNGlobalPresenceHelper : NSObject


#pragma mark - Properties

/**
 Stores reference on currently selected channel.
 */
@property (nonatomic, strong) PNChannel *currentChannel;

/**
 Stors how many people subscribed to the channels using current subscription key.
 */
@property (nonatomic, readonly, assign) NSUInteger numberOfParticipants;

/**
 Stores whether client should receive client identifiers or only number of participants.
 */
@property (nonatomic, assign, getter = shouldFetchParticipantNames) BOOL fetchParticipantNames;

/**
 Stores whether client should receive client's state or not.
 */
@property (nonatomic, assign, getter = shouldFetchParticipantState) BOOL fetchParticipantState;


#pragma mark - Instance methods

/**
 List of active channels which has been received from \b PubNub service.
 
 @return List of \b PNChannel instances.
 */
- (NSArray *)channels;

/**
 List of participants for currently selected channel.
 
 @return List of \b PNClient instances.
 */
- (NSArray *)participants;

/**
 Executr global presence request with specified completion block.
 
 @param handlerBlock
 This block called during request processing and return three parameters: array of \b PNClient instances, channel and error.
 */
- (void)fetchPresenceInformationWithBlock:(PNClientParticipantsHandlingBlock)handlerBlock;

/**
 Clean up all cached information.
 */
- (void)reset;

#pragma mark -


@end
