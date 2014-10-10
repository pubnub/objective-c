//
//  PNPresenceHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/25/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNPresenceHelper : NSObject


#pragma mark - Properties

/**
 Stores reference on currently selected channel.
 */
@property (nonatomic, strong) PNChannel *currentChannel;

/**
 Stors how many people subscribed to the channels using current subscription key.
 */
@property (nonatomic, readonly, assign) NSUInteger numberOfParticipants;


#pragma mark - Instance methods

/**
 Instruct helper with base information which can be used for further actions.
 
 @param objectName
 \b NSString instance for which in future presence information can be pulled out (it can be \c nil).
 
 @param objectNamespace
 Namespace inside of which channel group is storted (in case if request configured for channel group)
 
 @param identifier
 String which represent identifier for client, for which data should be pulled from concrete channel.
 
 @param isChannelGroup
 Whether request should be done for channel group or not
 
 @param shouldFetchIdentifiers
 In case if presence should be processed globally for channel, \c YES value will force return identifiers for participants
 in other case only number of participants will be returned.
 
 @param shouldFetchState
 Work together with \b shouldFetchIdentifiers property (when set to \c YES) and allow to retrieve client state information.
 */
- (void)configureForObject:(NSString *)objectName namespace:(NSString *)objectNamespace
          clientIdentifier:(NSString *)identifier channelGroup:(BOOL)isChannelGroup
          fetchIdentifiers:(BOOL)shouldFetchIdentifiers fetchState:(BOOL)shouldFetchState;

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
 Execute presence event basing on provided data from \c -configureForChannel:clientIdentifier:fetchIdentifiers:fetchState:
 method.
 
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
