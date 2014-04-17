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


#pragma mark - Instance methods

/**
 Instruct helper with base information which can be used for further actions.
 
 @param channel
 \b PNChannel or \b NSString instance for which in future presence information can be pulled out (it can be \c nil).
 
 @param identifier
 String which represent identifier for client, for which data should be pulled from concrete channel.
 
 @param shouldFetchIdentifiers
 In case if presence should be processed globally for channel, \c YES value will force return identifiers for participants
 in other case only number of participants will be returned.
 
 @param shouldFetchState
 Work together with \b shouldFetchIdentifiers property (when set to \c YES) and allow to retrieve client state information.
 */
- (void)configureForChannel:(id)channel clientIdentifier:(NSString *)identifier
           fetchIdentifiers:(BOOL)shouldFetchIdentifiers fetchState:(BOOL)shouldFetchState;

/**
 Execute presence event basing on provided data from \c -configureForChannel:clientIdentifier:fetchIdentifiers:fetchState:
 method.
 
 @param handlerBlock
 This block called during request processing and return three parameters: array of \b PNClient instances, channel and error.
 */
- (void)fetchPresenceInformationWithBlock:(PNClientParticipantsHandlingBlock)handlerBlock;

/**
 Retrun reference on data which has been received using presence API endpoint (it can be list of participants or channels).
 */
- (NSArray *)data;

#pragma mark -


@end
